import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:alhai_core/src/datasources/local/auth_local_datasource.dart';
import 'package:alhai_core/src/datasources/local/entities/auth_tokens_entity.dart';
import 'package:alhai_core/src/datasources/local/entities/user_entity.dart';
import 'package:alhai_core/src/datasources/remote/auth_remote_datasource.dart';
import 'package:alhai_core/src/dto/auth/auth_response.dart';
import 'package:alhai_core/src/dto/auth/auth_tokens_response.dart';
import 'package:alhai_core/src/exceptions/app_exception.dart';
import 'package:alhai_core/src/models/enums/user_role.dart';
import 'package:alhai_core/src/repositories/impl/auth_repository_impl.dart';

// Mock classes
class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

// Fake classes
class FakeAuthTokensEntity extends Fake implements AuthTokensEntity {}

class FakeUserEntity extends Fake implements UserEntity {}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemote;
  late MockAuthLocalDataSource mockLocal;

  // Test data
  const testAuthTokensResponse = AuthTokensResponse(
    accessToken: 'test-access-token',
    refreshToken: 'test-refresh-token',
    expiresAt: '2026-01-10T11:00:00Z',
  );

  const testAuthResponse = AuthResponse(
    user: UserResponse(
      id: 'user-1',
      phone: '+966500000000',
      name: 'Test User',
      role: 'customer',
      createdAt: '2026-01-10T10:00:00Z',
    ),
    tokens: testAuthTokensResponse,
  );

  const testUserEntity = UserEntity(
    id: 'user-1',
    phone: '+966500000000',
    name: 'Test User',
    role: 'customer',
    createdAt: '2026-01-10T10:00:00Z',
  );

  final testTokensEntity = AuthTokensEntity(
    accessToken: 'test-access-token',
    refreshToken: 'test-refresh-token',
    expiresAt: DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
  );

  final expiredTokensEntity = AuthTokensEntity(
    accessToken: 'expired-access-token',
    refreshToken: 'expired-refresh-token',
    expiresAt:
        DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
  );

  setUpAll(() {
    registerFallbackValue(FakeAuthTokensEntity());
    registerFallbackValue(FakeUserEntity());
  });

  setUp(() {
    mockRemote = MockAuthRemoteDataSource();
    mockLocal = MockAuthLocalDataSource();
    repository = AuthRepositoryImpl(remote: mockRemote, local: mockLocal);
  });

  group('AuthRepositoryImpl', () {
    group('sendOtp', () {
      test('sends OTP successfully', () async {
        // Arrange
        when(() => mockRemote.sendOtp(any())).thenAnswer((_) async {});

        // Act & Assert
        await expectLater(repository.sendOtp('+966500000000'), completes);
        verify(() => mockRemote.sendOtp('+966500000000')).called(1);
      });

      test('throws NetworkException on connection error', () async {
        // Arrange
        when(() => mockRemote.sendOtp(any())).thenThrow(DioException(
          type: DioExceptionType.connectionError,
          requestOptions: RequestOptions(path: '/auth/otp'),
        ));

        // Act & Assert
        expect(
          () => repository.sendOtp('+966500000000'),
          throwsA(isA<NetworkException>()),
        );
      });
    });

    group('verifyOtp', () {
      test('verifies OTP and stores tokens locally', () async {
        // Arrange
        when(() => mockRemote.verifyOtp(any(), any()))
            .thenAnswer((_) async => testAuthResponse);
        when(() => mockLocal.saveTokens(any())).thenAnswer((_) async {});
        when(() => mockLocal.saveUser(any())).thenAnswer((_) async {});

        // Act
        final result = await repository.verifyOtp('+966500000000', '1234');

        // Assert
        expect(result.user.id, equals('user-1'));
        expect(result.user.phone, equals('+966500000000'));
        expect(result.tokens.accessToken, equals('test-access-token'));
        verify(() => mockRemote.verifyOtp('+966500000000', '1234')).called(1);
        verify(() => mockLocal.saveTokens(any())).called(1);
        verify(() => mockLocal.saveUser(any())).called(1);
      });

      test('throws AuthException on invalid OTP', () async {
        // Arrange
        when(() => mockRemote.verifyOtp(any(), any())).thenThrow(DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 401,
            data: {'message': 'Invalid OTP'},
            requestOptions: RequestOptions(path: '/auth/verify'),
          ),
          requestOptions: RequestOptions(path: '/auth/verify'),
        ));

        // Act & Assert
        expect(
          () => repository.verifyOtp('+966500000000', 'wrong'),
          throwsA(isA<AuthException>()),
        );
      });
    });

    group('refreshToken', () {
      test('refreshes token and stores new tokens', () async {
        // Arrange
        when(() => mockLocal.getTokens())
            .thenAnswer((_) async => testTokensEntity);
        when(() => mockRemote.refreshToken(any()))
            .thenAnswer((_) async => testAuthTokensResponse);
        when(() => mockLocal.saveTokens(any())).thenAnswer((_) async {});

        // Act
        final result = await repository.refreshToken();

        // Assert
        expect(result.accessToken, equals('test-access-token'));
        verify(() => mockLocal.getTokens()).called(1);
        verify(() => mockRemote.refreshToken('test-refresh-token')).called(1);
        verify(() => mockLocal.saveTokens(any())).called(1);
      });

      test('throws AuthException when no refresh token', () async {
        // Arrange
        when(() => mockLocal.getTokens()).thenAnswer((_) async => null);

        // Act & Assert
        expect(
          () => repository.refreshToken(),
          throwsA(isA<AuthException>()),
        );
      });
    });

    group('logout', () {
      test('clears local storage on logout', () async {
        // Arrange
        when(() => mockLocal.clearTokens()).thenAnswer((_) async {});
        when(() => mockLocal.clearUser()).thenAnswer((_) async {});

        // Act
        await repository.logout();

        // Assert
        verify(() => mockLocal.clearTokens()).called(1);
        verify(() => mockLocal.clearUser()).called(1);
      });
    });

    group('getCurrentUser', () {
      test('returns User from local storage', () async {
        // Arrange
        when(() => mockLocal.getUser()).thenAnswer((_) async => testUserEntity);

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result, isNotNull);
        expect(result!.id, equals('user-1'));
        expect(result.role, equals(UserRole.customer));
      });

      test('returns null when no user stored', () async {
        // Arrange
        when(() => mockLocal.getUser()).thenAnswer((_) async => null);

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result, isNull);
      });
    });

    group('isAuthenticated', () {
      test('returns true when valid tokens exist', () async {
        // Arrange
        when(() => mockLocal.getTokens())
            .thenAnswer((_) async => testTokensEntity);

        // Act
        final result = await repository.isAuthenticated();

        // Assert
        expect(result, isTrue);
      });

      test('returns false when no tokens', () async {
        // Arrange
        when(() => mockLocal.getTokens()).thenAnswer((_) async => null);

        // Act
        final result = await repository.isAuthenticated();

        // Assert
        expect(result, isFalse);
      });

      test('refreshes token when expired and returns true', () async {
        // Arrange
        when(() => mockLocal.getTokens())
            .thenAnswer((_) async => expiredTokensEntity);
        when(() => mockRemote.refreshToken(any()))
            .thenAnswer((_) async => testAuthTokensResponse);
        when(() => mockLocal.saveTokens(any())).thenAnswer((_) async {});

        // Act
        final result = await repository.isAuthenticated();

        // Assert
        expect(result, isTrue);
        verify(() => mockRemote.refreshToken(any())).called(1);
      });

      test('returns false and logs out when refresh fails', () async {
        // Arrange
        when(() => mockLocal.getTokens())
            .thenAnswer((_) async => expiredTokensEntity);
        when(() => mockRemote.refreshToken(any())).thenThrow(DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 401,
            requestOptions: RequestOptions(path: '/auth/refresh'),
          ),
          requestOptions: RequestOptions(path: '/auth/refresh'),
        ));
        when(() => mockLocal.clearTokens()).thenAnswer((_) async {});
        when(() => mockLocal.clearUser()).thenAnswer((_) async {});

        // Act
        final result = await repository.isAuthenticated();

        // Assert
        expect(result, isFalse);
        verify(() => mockLocal.clearTokens()).called(1);
        verify(() => mockLocal.clearUser()).called(1);
      });
    });
  });
}
