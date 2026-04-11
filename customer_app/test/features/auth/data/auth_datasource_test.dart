import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import 'package:alhai_core/alhai_core.dart' as core;

import 'package:customer_app/features/auth/data/auth_datasource.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockSupabaseClient extends Mock implements supa.SupabaseClient {
  final MockGoTrueClient mockAuth = MockGoTrueClient();

  @override
  supa.GoTrueClient get auth => mockAuth;
}

class MockGoTrueClient extends Mock implements supa.GoTrueClient {}

class MockSupabaseQueryBuilder extends Mock
    implements supa.SupabaseQueryBuilder {}

class MockFilterBuilderList extends Mock
    implements supa.PostgrestFilterBuilder<List<Map<String, dynamic>>> {}

class MockTransformBuilderMap extends Mock
    implements supa.PostgrestTransformBuilder<Map<String, dynamic>> {}

class _FakeAuthResponse extends Fake implements supa.AuthResponse {
  final _FakeUser _user;
  final _FakeSession _session;

  _FakeAuthResponse({
    required String userId,
    required String phone,
    String accessToken = 'test-access-token',
    String refreshToken = 'test-refresh-token',
    int expiresAt = 1700000000,
  }) : _user = _FakeUser(id: userId, phone: phone),
       _session = _FakeSession(
         accessToken: accessToken,
         refreshToken: refreshToken,
         expiresAt: expiresAt,
       );

  @override
  supa.User? get user => _user;

  @override
  supa.Session? get session => _session;
}

class _FakeUser extends Fake implements supa.User {
  @override
  final String id;
  @override
  final String phone;
  @override
  Map<String, dynamic>? get userMetadata => null;

  _FakeUser({required this.id, this.phone = ''});
}

class _FakeSession extends Fake implements supa.Session {
  @override
  final String accessToken;
  @override
  final String refreshToken;
  @override
  final int? expiresAt;

  _FakeSession({
    required this.accessToken,
    required this.refreshToken,
    this.expiresAt,
  });
}

class _NullUserAuthResponse extends Fake implements supa.AuthResponse {
  @override
  supa.User? get user => null;

  @override
  supa.Session? get session => null;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockSupabaseClient mockClient;
  late MockGoTrueClient mockAuth;
  late AuthDatasource datasource;

  setUpAll(() {
    registerFallbackValue(Duration.zero);
    registerFallbackValue('');
  });

  setUp(() {
    resetMocktailState();
    mockClient = MockSupabaseClient();
    mockAuth = mockClient.mockAuth;
    datasource = AuthDatasource(mockClient);
  });

  group('verifyOtp', () {
    test('returns AuthResult on successful verification', () async {
      // Arrange
      const phone = '+966500000000';
      const otp = '123456';
      const userId = 'user-abc-123';

      final authResponse = _FakeAuthResponse(
        userId: userId,
        phone: phone,
        accessToken: 'access-tok',
        refreshToken: 'refresh-tok',
        expiresAt: 1700000000,
      );

      when(
        () => mockAuth.verifyOTP(
          phone: phone,
          token: otp,
          type: supa.OtpType.sms,
        ),
      ).thenAnswer((_) async => authResponse);

      final mockQueryBuilder = MockSupabaseQueryBuilder();
      final mockFilterBuilder = MockFilterBuilderList();
      final mockTransformBuilder = MockTransformBuilderMap();

      when(() => mockClient.from('users')).thenAnswer((_) => mockQueryBuilder);
      when(
        () => mockQueryBuilder.upsert(
          any(),
          onConflict: any(named: 'onConflict'),
        ),
      ).thenAnswer((_) => mockFilterBuilder);
      when(
        () => mockFilterBuilder.select(any()),
      ).thenAnswer((_) => mockFilterBuilder);
      when(
        () => mockFilterBuilder.single(),
      ).thenAnswer((_) => mockTransformBuilder);
      when(() => mockTransformBuilder.timeout(any())).thenAnswer(
        (_) async => <String, dynamic>{
          'id': userId,
          'phone': phone,
          'name': phone,
          'email': null,
          'is_active': true,
          'created_at': '2024-01-01T00:00:00.000Z',
        },
      );

      // Act
      final result = await datasource.verifyOtp(phone, otp);

      // Assert
      expect(result.user.id, equals(userId));
      expect(result.user.phone, equals(phone));
      expect(result.user.role, equals(core.UserRole.customer));
      expect(result.tokens.accessToken, equals('access-tok'));
      expect(result.tokens.refreshToken, equals('refresh-tok'));
    });

    test('throws when OTP verification returns null user', () async {
      // Arrange
      const phone = '+966500000000';
      const otp = '000000';

      when(
        () => mockAuth.verifyOTP(
          phone: phone,
          token: otp,
          type: supa.OtpType.sms,
        ),
      ).thenAnswer((_) async => _NullUserAuthResponse());

      // Act & Assert
      expect(
        () => datasource.verifyOtp(phone, otp),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('OTP verification failed'),
          ),
        ),
      );
    });

    test('role is always customer regardless of database value', () async {
      // Arrange
      const phone = '+966500000000';
      const otp = '123456';
      const userId = 'user-role-test';

      final authResponse = _FakeAuthResponse(userId: userId, phone: phone);

      when(
        () => mockAuth.verifyOTP(
          phone: phone,
          token: otp,
          type: supa.OtpType.sms,
        ),
      ).thenAnswer((_) async => authResponse);

      final mockQueryBuilder = MockSupabaseQueryBuilder();
      final mockFilterBuilder = MockFilterBuilderList();
      final mockTransformBuilder = MockTransformBuilderMap();

      when(() => mockClient.from('users')).thenAnswer((_) => mockQueryBuilder);
      when(
        () => mockQueryBuilder.upsert(
          any(),
          onConflict: any(named: 'onConflict'),
        ),
      ).thenAnswer((_) => mockFilterBuilder);
      when(
        () => mockFilterBuilder.select(any()),
      ).thenAnswer((_) => mockFilterBuilder);
      when(
        () => mockFilterBuilder.single(),
      ).thenAnswer((_) => mockTransformBuilder);
      when(() => mockTransformBuilder.timeout(any())).thenAnswer(
        (_) async => <String, dynamic>{
          'id': userId,
          'phone': phone,
          'name': 'Test',
          'role': 'storeOwner',
          'is_active': true,
          'created_at': '2024-01-01T00:00:00.000Z',
        },
      );

      // Act
      final result = await datasource.verifyOtp(phone, otp);

      // Assert
      expect(result.user.role, equals(core.UserRole.customer));
    });
  });

  group('getCurrentUser', () {
    test('returns null when no supabase user is signed in', () async {
      // Arrange
      when(() => mockAuth.currentUser).thenReturn(null);

      // Act
      final user = await datasource.getCurrentUser();

      // Assert
      expect(user, isNull);
    });
  });

  group('logout', () {
    test('calls signOut on auth client', () async {
      // Arrange
      when(() => mockAuth.signOut()).thenAnswer((_) async {});
      when(() => mockAuth.currentSession).thenReturn(null);

      // Act
      try {
        await datasource.logout();
      } catch (_) {
        // Expected: SharedPreferences/SecureStorage not available in tests
      }

      // Assert
      verify(() => mockAuth.signOut()).called(1);
    });

    test(
      'session null check after logout does not throw (no assert)',
      () async {
        // Arrange
        when(() => mockAuth.signOut()).thenAnswer((_) async {});
        when(() => mockAuth.currentSession).thenReturn(null);

        // Act
        try {
          await datasource.logout();
        } catch (_) {
          // SharedPreferences/SecureStorage not available in tests
        }

        // Assert
        verify(() => mockAuth.currentSession).called(1);
      },
    );
  });

  group('isAuthenticated', () {
    test('returns false when no session exists', () {
      // Arrange
      when(() => mockAuth.currentSession).thenReturn(null);

      // Assert
      expect(datasource.isAuthenticated, isFalse);
    });
  });
}
