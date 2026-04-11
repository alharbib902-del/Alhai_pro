import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../../../core/providers/app_providers.dart';
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
final verifyOtpProvider =
    FutureProvider.family<void, ({String phone, String otp})>((
      ref,
      params,
    ) async {
      final datasource = GetIt.instance<DriverAuthDatasource>();
      final result = await datasource.verifyOtp(params.phone, params.otp);
      ref.read(currentDriverProvider.notifier).state = result.user;
    });

/// Load current driver profile from server.
final loadDriverProfileProvider = FutureProvider<void>((ref) async {
  final datasource = GetIt.instance<DriverAuthDatasource>();
  final user = await datasource.getCurrentUser();
  ref.read(currentDriverProvider.notifier).state = user;
});

/// Logout the driver.
final logoutProvider = FutureProvider<void>((ref) async {
  final datasource = GetIt.instance<DriverAuthDatasource>();
  await datasource.logout();
  ref.read(currentDriverProvider.notifier).state = null;
});
