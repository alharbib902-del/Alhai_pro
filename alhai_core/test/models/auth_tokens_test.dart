import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_core/src/models/auth_tokens.dart';

void main() {
  group('AuthTokens Model', () {
    group('construction', () {
      test('should create with required fields', () {
        final tokens = AuthTokens(
          accessToken: 'test-access-token',
          refreshToken: 'test-refresh-token',
          expiresAt: DateTime(2026, 1, 15, 12, 0),
        );

        expect(tokens.accessToken, equals('test-access-token'));
        expect(tokens.refreshToken, equals('test-refresh-token'));
        expect(tokens.expiresAt, equals(DateTime(2026, 1, 15, 12, 0)));
      });
    });

    group('serialization', () {
      test('should create AuthTokens from JSON', () {
        final json = {
          'accessToken': 'abc123',
          'refreshToken': 'def456',
          'expiresAt': '2026-01-15T12:00:00.000',
        };

        final tokens = AuthTokens.fromJson(json);

        expect(tokens.accessToken, equals('abc123'));
        expect(tokens.refreshToken, equals('def456'));
        expect(tokens.expiresAt.year, equals(2026));
      });

      test('should serialize to JSON and back', () {
        final tokens = AuthTokens(
          accessToken: 'access-xyz',
          refreshToken: 'refresh-xyz',
          expiresAt: DateTime(2026, 2, 1, 10, 0),
        );
        final json = tokens.toJson();
        final restored = AuthTokens.fromJson(json);

        expect(restored.accessToken, equals(tokens.accessToken));
        expect(restored.refreshToken, equals(tokens.refreshToken));
        expect(restored.expiresAt, equals(tokens.expiresAt));
      });
    });

    group('equality', () {
      test('should be equal for same data', () {
        final expiresAt = DateTime(2026, 1, 15, 12, 0);
        final t1 = AuthTokens(
          accessToken: 'abc',
          refreshToken: 'def',
          expiresAt: expiresAt,
        );
        final t2 = AuthTokens(
          accessToken: 'abc',
          refreshToken: 'def',
          expiresAt: expiresAt,
        );
        expect(t1, equals(t2));
      });

      test('should not be equal for different tokens', () {
        final t1 = AuthTokens(
          accessToken: 'abc',
          refreshToken: 'def',
          expiresAt: DateTime(2026, 1, 15),
        );
        final t2 = AuthTokens(
          accessToken: 'xyz',
          refreshToken: 'def',
          expiresAt: DateTime(2026, 1, 15),
        );
        expect(t1, isNot(equals(t2)));
      });
    });
  });
}
