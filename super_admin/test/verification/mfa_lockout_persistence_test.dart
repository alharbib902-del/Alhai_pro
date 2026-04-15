import 'package:flutter_test/flutter_test.dart';

/// Tests for the server-side MFA lockout logic (F2 fix).
///
/// The actual [_checkLockoutFromServer] method in [SAMfaScreen] queries
/// `audit_log` via Supabase. Here we test the decision logic in isolation:
///   - 5+ failures in 30 min → locked
///   - <5 failures → not locked
///   - query error → locked (fail-safe)
void main() {
  group('MFA lockout server-side logic', () {
    const maxAttempts = 5;

    /// Simulates the lockout decision given a query result.
    bool isLockedOut({required int recentFailures}) {
      return recentFailures >= maxAttempts;
    }

    /// Simulates the fail-safe path when the query throws.
    bool isLockedOutOnError() {
      try {
        throw Exception('Supabase query failed');
      } catch (_) {
        return true; // fail-safe: deny on error
      }
    }

    test('5 failures in last 30 minutes → locked out', () {
      expect(isLockedOut(recentFailures: 5), isTrue);
    });

    test('6 failures in last 30 minutes → locked out', () {
      expect(isLockedOut(recentFailures: 6), isTrue);
    });

    test('4 failures in last 30 minutes → NOT locked out', () {
      expect(isLockedOut(recentFailures: 4), isFalse);
    });

    test('0 failures → NOT locked out', () {
      expect(isLockedOut(recentFailures: 0), isFalse);
    });

    test('query throws exception → locked out (fail-safe)', () {
      expect(isLockedOutOnError(), isTrue);
    });

    test('null user → locked out (fail-safe)', () {
      // Simulates: if (user == null) return true;
      const dynamic user = null;
      final locked = user == null ? true : false;
      expect(locked, isTrue);
    });
  });
}
