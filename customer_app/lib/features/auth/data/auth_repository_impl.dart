import 'package:alhai_core/alhai_core.dart';

import 'auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDatasource _datasource;

  AuthRepositoryImpl(this._datasource);

  @override
  Future<void> sendOtp(String phone) => _datasource.sendOtp(phone);

  @override
  Future<AuthResult> verifyOtp(String phone, String otp) =>
      _datasource.verifyOtp(phone, otp);

  @override
  Future<AuthTokens> refreshToken() async {
    // Supabase handles token refresh automatically
    throw UnimplementedError('Supabase handles refresh automatically');
  }

  @override
  Future<void> logout() => _datasource.logout();

  @override
  Future<User?> getCurrentUser() => _datasource.getCurrentUser();

  @override
  Future<bool> isAuthenticated() async => _datasource.isAuthenticated;
}
