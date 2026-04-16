import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/services/push_notification_service.dart';
import '../../../core/services/sentry_service.dart';
import '../data/driver_auth_datasource.dart';

/// Auth state for the driver app.
enum DriverAuthState { loading, unauthenticated, needsProfile, authenticated }

/// Provides the current auth state.
final driverAuthStateProvider = Provider<DriverAuthState>((ref) {
  final isAuth = ref.watch(isAuthenticatedProvider);
  if (!isAuth) return DriverAuthState.unauthenticated;

  final driver = ref.watch(currentDriverProvider);
  if (driver == null) return DriverAuthState.loading;

  // Check if driver has completed profile setup
  if (driver.name.isEmpty || driver.name == driver.phone) {
    return DriverAuthState.needsProfile;
  }

  return DriverAuthState.authenticated;
});

/// Send OTP to phone number.
final sendOtpProvider = FutureProvider.family<void, String>((ref, phone) async {
  final datasource = GetIt.instance<DriverAuthDatasource>();
  await datasource.sendOtp(phone);
});

/// Verify OTP and login.
///
/// After successful authentication, registers the FCM token with the
/// backend so the driver can receive push notifications for new orders.
final verifyOtpProvider =
    FutureProvider.family<void, ({String phone, String otp})>((
      ref,
      params,
    ) async {
      final datasource = GetIt.instance<DriverAuthDatasource>();
      final result = await datasource.verifyOtp(params.phone, params.otp);
      ref.read(currentDriverProvider.notifier).state = result.user;

      // Save FCM token to backend (non-blocking — login should not fail
      // if push registration fails).
      _registerFcmToken(datasource);
    });

/// Load current driver profile from server.
///
/// Also refreshes the FCM token on app startup so the backend always has the
/// latest token (tokens can rotate between app launches).
final loadDriverProfileProvider = FutureProvider<void>((ref) async {
  final datasource = GetIt.instance<DriverAuthDatasource>();
  final user = await datasource.getCurrentUser();
  ref.read(currentDriverProvider.notifier).state = user;

  // Refresh FCM token on app startup (non-blocking).
  if (user != null) {
    _registerFcmToken(datasource);
  }
});

/// Logout the driver.
///
/// Deletes the local FCM token so this device stops receiving push
/// notifications. The backend token is cleared by [DriverAuthDatasource.logout].
final logoutProvider = FutureProvider<void>((ref) async {
  // Delete the local FCM registration (best-effort, don't block logout).
  try {
    await PushNotificationService.instance.deleteToken();
  } catch (e, st) {
    reportError(e, stackTrace: st, hint: 'FCM deleteToken on logout');
  }

  final datasource = GetIt.instance<DriverAuthDatasource>();
  await datasource.logout();
  ref.read(currentDriverProvider.notifier).state = null;
});

// ─── FCM token helpers ─────────────────────────────────────────────────────

/// Gets the current FCM token and saves it to the backend.
///
/// Also registers a token-refresh listener so the backend is always
/// up-to-date. Runs asynchronously and never throws — push registration
/// failures must not break login or app startup.
void _registerFcmToken(DriverAuthDatasource datasource) {
  Future<void> save() async {
    final token = await PushNotificationService.instance.getToken();
    if (token != null) {
      await datasource.updateFcmToken(token);
      if (kDebugMode) debugPrint('[FCM] Token saved to backend');
    }
  }

  // Save the current token.
  save().catchError((Object e, StackTrace st) {
    reportError(e, stackTrace: st, hint: 'FCM register token');
  });

  // Re-save whenever the token rotates.
  PushNotificationService.instance.onTokenRefresh((newToken) {
    datasource.updateFcmToken(newToken).catchError((Object e, StackTrace st) {
      reportError(e, stackTrace: st, hint: 'FCM refresh token save');
    });
  });
}
