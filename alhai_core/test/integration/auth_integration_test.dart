import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';

import 'package:alhai_core/src/repositories/auth_repository.dart';
import 'package:alhai_core/src/repositories/impl/auth_repository_impl.dart';
import 'package:alhai_core/src/datasources/remote/auth_remote_datasource.dart';
import 'package:alhai_core/src/datasources/local/auth_local_datasource.dart';
import 'package:alhai_core/src/datasources/local/entities/auth_tokens_entity.dart';
import 'package:alhai_core/src/datasources/local/entities/user_entity.dart';
import 'package:alhai_core/src/dto/auth/auth_response.dart';

/// Mock classes for integration testing
class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

/// Integration Tests for AuthRepository
///
/// These tests verify the complete flow from Repository -> DataSource -> API
void main() {
  late AuthRepository authRepository;
  late MockAuthRemoteDataSource mockRemote;
  late MockAuthLocalDataSource mockLocal;

  setUpAll(() {
    registerFallbackValue(FakeAuthTokensEntity());
    registerFallbackValue(FakeUserEntity());
  });

  setUp(() {
    mockRemote = MockAuthRemoteDataSource();
    mockLocal = MockAuthLocalDataSource();
    authRepository = AuthRepositoryImpl(
      remote: mockRemote,
      local: mockLocal,
    );
  });

  group('Auth Integration Tests', () {
    group('Send OTP', () {
      test('should send OTP successfully', () async {
        // Arrange
        const phone = '+966512345678';
        when(() => mockRemote.sendOtp(phone)).thenAnswer((_) async {});

        // Act & Assert - no exception means success
        await expectLater(
          authRepository.sendOtp(phone),
          completes,
        );
        verify(() => mockRemote.sendOtp(phone)).called(1);
      });

      test('should throw on network error', () async {
        // Arrange
        const phone = '+966512345678';
        when(() => mockRemote.sendOtp(phone)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/auth/send-otp'),
            type: DioExceptionType.connectionTimeout,
          ),
        );

        // Act & Assert
        await expectLater(
          authRepository.sendOtp(phone),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Verify OTP', () {
      test('should verify OTP and return AuthResult', () async {
        // Arrange
        const phone = '+966512345678';
        const otp = '123456';
        final authResponse = AuthResponse.fromJson({
          'user': {
            'id': 'user-123',
            'phone': phone,
            'name': 'Test User',
            'role': 'customer',
            'created_at': '2026-01-19T00:00:00Z',
          },
          'tokens': {
            'access_token': 'access-token',
            'refresh_token': 'refresh-token',
            'expires_at': '2026-01-19T01:00:00Z',
          },
        });

        when(() => mockRemote.verifyOtp(phone, otp))
            .thenAnswer((_) async => authResponse);
        when(() => mockLocal.saveTokens(any())).thenAnswer((_) async {});
        when(() => mockLocal.saveUser(any())).thenAnswer((_) async {});

        // Act
        final result = await authRepository.verifyOtp(phone, otp);

        // Assert
        expect(result.user.phone, phone);
        expect(result.tokens.accessToken, 'access-token');
      });
    });

    group('Logout', () {
      test('should clear tokens on logout', () async {
        // Arrange
        when(() => mockLocal.clearTokens()).thenAnswer((_) async {});
        when(() => mockLocal.clearUser()).thenAnswer((_) async {});

        // Act & Assert
        await expectLater(
          authRepository.logout(),
          completes,
        );
        verify(() => mockLocal.clearTokens()).called(1);
        verify(() => mockLocal.clearUser()).called(1);
      });
    });

    group('Check Auth Status', () {
      test('should return true when authenticated', () async {
        // Arrange
        when(() => mockLocal.getTokens())
            .thenAnswer((_) async => FakeAuthTokensEntity());

        // Act
        final result = await authRepository.isAuthenticated();

        // Assert
        expect(result, true);
      });
    });
  });
}

/// Fake entity for testing
class FakeAuthTokensEntity extends AuthTokensEntity {
  FakeAuthTokensEntity()
      : super(
          accessToken: 'test-token',
          refreshToken: 'test-refresh',
          expiresAt:
              DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
        );
}

/// Fake user entity for testing
class FakeUserEntity extends UserEntity {
  FakeUserEntity()
      : super(
          id: 'test-user-id',
          phone: '+966512345678',
          name: 'Test User',
          role: 'customer',
          createdAt: DateTime.now().toIso8601String(),
        );
}
