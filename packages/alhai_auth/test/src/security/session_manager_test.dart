import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_auth/alhai_auth.dart';

void main() {
  late InMemoryStorage storage;

  setUp(() {
    storage = InMemoryStorage();
    SecureStorageService.setStorage(storage);
  });

  tearDown(() async {
    SessionManager.stopSessionMonitor();
    // Clear cache by ending session
    await SessionManager.endSession();
    SecureStorageService.resetStorage();
  });

  group('SessionManager', () {
    group('startSession', () {
      test('stores tokens and user data', () async {
        await SessionManager.startSession(
          accessToken: 'at-123',
          refreshToken: 'rt-456',
          userId: 'user-001',
          storeId: 'store-001',
        );

        final at = await SecureStorageService.getAccessToken();
        final rt = await SecureStorageService.getRefreshToken();
        final uid = await SecureStorageService.getUserId();
        final sid = await SecureStorageService.getStoreId();

        expect(at, equals('at-123'));
        expect(rt, equals('rt-456'));
        expect(uid, equals('user-001'));
        expect(sid, equals('store-001'));
      });

      test('sets session expiry to 30 minutes from now', () async {
        final before = DateTime.now();

        await SessionManager.startSession(
          accessToken: 'at',
          refreshToken: 'rt',
          userId: 'u',
          storeId: 's',
        );

        final expiry = await SessionManager.getSessionExpiry();
        expect(expiry, isNotNull);
        // Should be approximately 30 minutes from now
        final diff = expiry!.difference(before);
        expect(diff.inMinutes, greaterThanOrEqualTo(29));
        expect(diff.inMinutes, lessThanOrEqualTo(31));
      });

      test('session is valid after starting', () async {
        await SessionManager.startSession(
          accessToken: 'at',
          refreshToken: 'rt',
          userId: 'u',
          storeId: 's',
        );

        final valid = await SessionManager.isSessionValid();
        expect(valid, isTrue);
      });
    });

    group('checkSession', () {
      test('returns notAuthenticated when no token exists', () async {
        final status = await SessionManager.checkSession();
        expect(status, equals(SessionStatus.notAuthenticated));
      });

      test('returns valid for a fresh session', () async {
        await SessionManager.startSession(
          accessToken: 'at',
          refreshToken: 'rt',
          userId: 'u',
          storeId: 's',
        );

        final status = await SessionManager.checkSession();
        expect(status, equals(SessionStatus.valid));
      });

      test('returns notAuthenticated after session ends', () async {
        // Start a valid session, then end it
        await SessionManager.startSession(
          accessToken: 'at',
          refreshToken: 'rt',
          userId: 'u',
          storeId: 's',
        );

        await SessionManager.endSession();

        final status = await SessionManager.checkSession();
        expect(status, equals(SessionStatus.notAuthenticated));
      });
    });

    group('refreshSession', () {
      test('returns true and updates tokens', () async {
        await SessionManager.startSession(
          accessToken: 'old-at',
          refreshToken: 'old-rt',
          userId: 'u',
          storeId: 's',
        );

        final result = await SessionManager.refreshSession(
          accessToken: 'new-at',
          refreshToken: 'new-rt',
        );

        expect(result, isTrue);
        final at = await SecureStorageService.getAccessToken();
        expect(at, equals('new-at'));
      });

      test('updates session expiry after refresh', () async {
        await SessionManager.startSession(
          accessToken: 'at',
          refreshToken: 'rt',
          userId: 'u',
          storeId: 's',
        );

        final beforeRefresh = DateTime.now();
        await SessionManager.refreshSession(
          accessToken: 'new-at',
          refreshToken: 'new-rt',
        );

        final expiry = await SessionManager.getSessionExpiry();
        expect(expiry, isNotNull);
        expect(expiry!.isAfter(beforeRefresh), isTrue);
      });
    });

    group('endSession', () {
      test('clears session data', () async {
        await SessionManager.startSession(
          accessToken: 'at',
          refreshToken: 'rt',
          userId: 'u',
          storeId: 's',
        );

        await SessionManager.endSession();

        final at = await SecureStorageService.getAccessToken();
        final uid = await SecureStorageService.getUserId();
        expect(at, isNull);
        expect(uid, isNull);
      });

      test('session is invalid after ending', () async {
        await SessionManager.startSession(
          accessToken: 'at',
          refreshToken: 'rt',
          userId: 'u',
          storeId: 's',
        );

        await SessionManager.endSession();

        final status = await SessionManager.checkSession();
        expect(status, equals(SessionStatus.notAuthenticated));
      });
    });

    group('isSessionValid', () {
      test('returns true for valid or needsRefresh sessions', () async {
        await SessionManager.startSession(
          accessToken: 'at',
          refreshToken: 'rt',
          userId: 'u',
          storeId: 's',
        );

        final valid = await SessionManager.isSessionValid();
        expect(valid, isTrue);
      });

      test('returns false when not authenticated', () async {
        final valid = await SessionManager.isSessionValid();
        expect(valid, isFalse);
      });
    });

    group('getRemainingTime', () {
      test('returns null when no session exists', () async {
        final remaining = await SessionManager.getRemainingTime();
        expect(remaining, isNull);
      });

      test('returns positive duration for active session', () async {
        await SessionManager.startSession(
          accessToken: 'at',
          refreshToken: 'rt',
          userId: 'u',
          storeId: 's',
        );

        final remaining = await SessionManager.getRemainingTime();
        expect(remaining, isNotNull);
        expect(remaining!.inMinutes, greaterThan(0));
      });
    });

    group('getAccessToken / getRefreshToken', () {
      test('returns tokens after session start', () async {
        await SessionManager.startSession(
          accessToken: 'my-at',
          refreshToken: 'my-rt',
          userId: 'u',
          storeId: 's',
        );

        final at = await SessionManager.getAccessToken();
        final rt = await SessionManager.getRefreshToken();
        expect(at, equals('my-at'));
        expect(rt, equals('my-rt'));
      });

      test('returns null when no session', () async {
        final at = await SessionManager.getAccessToken();
        final rt = await SessionManager.getRefreshToken();
        expect(at, isNull);
        expect(rt, isNull);
      });
    });
  });
}
