import 'package:dio/dio.dart';

import '../../dto/auth/auth_response.dart';
import '../../dto/auth/auth_tokens_response.dart';

/// Remote data source contract for authentication API calls
/// Repository ↔ DataSource = DTO only
abstract class AuthRemoteDataSource {
  /// Sends OTP to the given phone number
  Future<void> sendOtp(String phone);

  /// Verifies OTP and returns auth response with user and tokens
  Future<AuthResponse> verifyOtp(String phone, String otp);

  /// Refreshes access token using refresh token
  Future<AuthTokensResponse> refreshToken(String refreshToken);
}

/// Implementation of AuthRemoteDataSource
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<void> sendOtp(String phone) async {
    await _dio.post('/auth/send-otp', data: {'phone': phone});
  }

  @override
  Future<AuthResponse> verifyOtp(String phone, String otp) async {
    final response = await _dio.post(
      '/auth/verify-otp',
      data: {'phone': phone, 'otp': otp},
    );
    return AuthResponse.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<AuthTokensResponse> refreshToken(String refreshToken) async {
    final response = await _dio.post(
      '/auth/refresh',
      data: {'refresh_token': refreshToken},
    );
    return AuthTokensResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
