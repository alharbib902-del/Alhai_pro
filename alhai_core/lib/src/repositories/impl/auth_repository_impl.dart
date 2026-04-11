import 'package:dio/dio.dart';

import '../../datasources/local/auth_local_datasource.dart';
import '../../datasources/local/entities/auth_tokens_entity.dart';
import '../../datasources/local/entities/user_entity.dart';
import '../../datasources/remote/auth_remote_datasource.dart';
import '../../exceptions/app_exception.dart';
import '../../exceptions/error_mapper.dart';
import '../../models/auth_result.dart';
import '../../models/auth_tokens.dart';
import '../../models/user.dart';
import '../auth_repository.dart';

/// Implementation of AuthRepository (v3.1)
/// Mapping (DTO → Domain) happens here only
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required AuthLocalDataSource local,
  }) : _remote = remote,
       _local = local;

  @override
  Future<void> sendOtp(String phone) async {
    try {
      await _remote.sendOtp(phone);
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<AuthResult> verifyOtp(String phone, String otp) async {
    try {
      // Call remote and get DTO
      final response = await _remote.verifyOtp(phone, otp);

      // Convert DTO to Domain (mapping happens here only)
      final authResult = response.toDomain();

      // Store tokens locally
      await _local.saveTokens(
        AuthTokensEntity.fromDateTime(
          accessToken: authResult.tokens.accessToken,
          refreshToken: authResult.tokens.refreshToken,
          expiresAt: authResult.tokens.expiresAt,
        ),
      );

      // Store user locally using UserEntity
      await _local.saveUser(UserEntity.fromDomain(authResult.user));

      return authResult;
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<AuthTokens> refreshToken() async {
    try {
      // Get stored refresh token
      final storedTokens = await _local.getTokens();
      if (storedTokens == null || storedTokens.refreshToken.isEmpty) {
        throw const AuthException(
          'No refresh token available',
          code: 'NO_REFRESH_TOKEN',
        );
      }

      // Call remote to refresh
      final response = await _remote.refreshToken(storedTokens.refreshToken);

      // Convert DTO to Domain
      final tokens = response.toDomain();

      // Store new tokens
      await _local.saveTokens(
        AuthTokensEntity.fromDateTime(
          accessToken: tokens.accessToken,
          refreshToken: tokens.refreshToken,
          expiresAt: tokens.expiresAt,
        ),
      );

      return tokens;
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<void> logout() async {
    await _local.clearTokens();
    await _local.clearUser();
  }

  @override
  Future<User?> getCurrentUser() async {
    final userEntity = await _local.getUser();
    if (userEntity == null) return null;

    // Convert Entity to Domain
    return userEntity.toDomain();
  }

  @override
  Future<bool> isAuthenticated() async {
    final tokens = await _local.getTokens();

    if (tokens == null) {
      return false;
    }

    if (tokens.isExpired) {
      try {
        await refreshToken();
        return true;
      } on AppException {
        await logout();
        return false;
      }
    }

    return true;
  }
}
