import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_auth/alhai_auth.dart';

void main() {
  late InMemoryStorage storage;

  setUp(() {
    storage = InMemoryStorage();
    SecureStorageService.setStorage(storage);
  });

  tearDown(() {
    SecureStorageService.resetStorage();
  });

  group('SecureStorageService', () {
    group('getDatabaseKey', () {
      test('generates and stores a new key if none exists', () async {
        final key = await SecureStorageService.getDatabaseKey();
        expect(key, isNotEmpty);

        // Calling again returns the same key
        final key2 = await SecureStorageService.getDatabaseKey();
        expect(key2, equals(key));
      });

      test('returns existing key if already stored', () async {
        await storage.write(key: 'db_encryption_key', value: 'test-key-123');
        final key = await SecureStorageService.getDatabaseKey();
        expect(key, equals('test-key-123'));
      });
    });

    group('saveAccessToken / getAccessToken', () {
      test('stores and retrieves access token', () async {
        await SecureStorageService.saveAccessToken('my-access-token');
        final token = await SecureStorageService.getAccessToken();
        expect(token, equals('my-access-token'));
      });

      test('returns null when no token stored', () async {
        final token = await SecureStorageService.getAccessToken();
        expect(token, isNull);
      });
    });

    group('saveRefreshToken / getRefreshToken', () {
      test('stores and retrieves refresh token', () async {
        await SecureStorageService.saveRefreshToken('my-refresh-token');
        final token = await SecureStorageService.getRefreshToken();
        expect(token, equals('my-refresh-token'));
      });

      test('returns null when no token stored', () async {
        final token = await SecureStorageService.getRefreshToken();
        expect(token, isNull);
      });
    });

    group('saveTokens', () {
      test('stores all token data atomically', () async {
        final expiry = DateTime.now().add(const Duration(hours: 1));
        await SecureStorageService.saveTokens(
          accessToken: 'at-123',
          refreshToken: 'rt-456',
          expiry: expiry,
        );

        final at = await SecureStorageService.getAccessToken();
        final rt = await SecureStorageService.getRefreshToken();
        final exp = await SecureStorageService.getSessionExpiry();

        expect(at, equals('at-123'));
        expect(rt, equals('rt-456'));
        expect(exp, isNotNull);
      });
    });

    group('isSessionValid', () {
      test('returns false when no expiry stored', () async {
        final valid = await SecureStorageService.isSessionValid();
        expect(valid, isFalse);
      });

      test('returns true when session is not expired', () async {
        final future = DateTime.now().add(const Duration(hours: 1));
        await storage.write(
          key: 'session_expiry',
          value: future.toIso8601String(),
        );
        final valid = await SecureStorageService.isSessionValid();
        expect(valid, isTrue);
      });

      test('returns false when session is expired', () async {
        final past = DateTime.now().subtract(const Duration(hours: 1));
        await storage.write(
          key: 'session_expiry',
          value: past.toIso8601String(),
        );
        final valid = await SecureStorageService.isSessionValid();
        expect(valid, isFalse);
      });
    });

    group('getSessionExpiry', () {
      test('returns null when no expiry stored', () async {
        final exp = await SecureStorageService.getSessionExpiry();
        expect(exp, isNull);
      });

      test('returns parsed DateTime when stored', () async {
        final date = DateTime(2026, 6, 15, 12, 0, 0);
        await storage.write(
          key: 'session_expiry',
          value: date.toIso8601String(),
        );
        final exp = await SecureStorageService.getSessionExpiry();
        expect(exp, isNotNull);
        expect(exp!.year, equals(2026));
        expect(exp.month, equals(6));
      });
    });

    group('saveUserData / getUserId / getStoreId', () {
      test('stores and retrieves user data', () async {
        await SecureStorageService.saveUserData(
          userId: 'user-001',
          storeId: 'store-001',
        );
        final uid = await SecureStorageService.getUserId();
        final sid = await SecureStorageService.getStoreId();
        expect(uid, equals('user-001'));
        expect(sid, equals('store-001'));
      });

      test('returns null when no user data stored', () async {
        final uid = await SecureStorageService.getUserId();
        final sid = await SecureStorageService.getStoreId();
        expect(uid, isNull);
        expect(sid, isNull);
      });
    });

    group('clearSession', () {
      test('clears session data but preserves database key', () async {
        await SecureStorageService.saveTokens(
          accessToken: 'at',
          refreshToken: 'rt',
          expiry: DateTime.now().add(const Duration(hours: 1)),
        );
        await SecureStorageService.saveUserData(
          userId: 'u1',
          storeId: 's1',
        );
        final dbKey = await SecureStorageService.getDatabaseKey();

        await SecureStorageService.clearSession();

        expect(await SecureStorageService.getAccessToken(), isNull);
        expect(await SecureStorageService.getRefreshToken(), isNull);
        expect(await SecureStorageService.getUserId(), isNull);
        expect(await SecureStorageService.getStoreId(), isNull);
        // Database key should still exist
        final dbKeyAfter = await SecureStorageService.getDatabaseKey();
        expect(dbKeyAfter, equals(dbKey));
      });
    });

    group('clearAll', () {
      test('clears all data including database key', () async {
        await SecureStorageService.getDatabaseKey();
        await SecureStorageService.saveAccessToken('token');
        await SecureStorageService.clearAll();

        expect(await SecureStorageService.getAccessToken(), isNull);
      });
    });

    group('generic read/write/delete', () {
      test('read returns null for missing key', () async {
        final val = await SecureStorageService.read('nonexistent');
        expect(val, isNull);
      });

      test('write and read round-trip', () async {
        await SecureStorageService.write('test_key', 'test_value');
        final val = await SecureStorageService.read('test_key');
        expect(val, equals('test_value'));
      });

      test('delete removes a key', () async {
        await SecureStorageService.write('key1', 'val1');
        await SecureStorageService.delete('key1');
        final val = await SecureStorageService.read('key1');
        expect(val, isNull);
      });
    });
  });
}
