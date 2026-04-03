import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_core/alhai_core.dart';

import '../../../core/providers/app_providers.dart';
import '../../../di/injection.dart';
import '../data/auth_datasource.dart';
import '../data/auth_repository_impl.dart';

/// Auth repository instance.
final authRepositoryProvider = Provider<AuthRepositoryImpl>((ref) {
  return locator<AuthRepositoryImpl>();
});

/// Send OTP to phone number.
final sendOtpProvider = FutureProvider.family<void, String>((ref, phone) async {
  final datasource = locator<AuthDatasource>();
  await datasource.sendOtp(phone);
});

/// Verify OTP and authenticate.
final verifyOtpProvider =
    FutureProvider.family<AuthResult, ({String phone, String otp})>(
  (ref, params) async {
    final datasource = locator<AuthDatasource>();
    final result = await datasource.verifyOtp(params.phone, params.otp);

    // Update current user state
    ref.read(currentUserProvider.notifier).state = result.user;

    return result;
  },
);

/// Load current user on app start.
final loadCurrentUserProvider = FutureProvider<User?>((ref) async {
  final datasource = locator<AuthDatasource>();
  final user = await datasource.getCurrentUser();
  ref.read(currentUserProvider.notifier).state = user;
  return user;
});

/// Logout.
final logoutProvider = FutureProvider<void>((ref) async {
  final datasource = locator<AuthDatasource>();
  await datasource.logout();
  ref.read(currentUserProvider.notifier).state = null;
  ref.read(selectedStoreProvider.notifier).state = null;
});
