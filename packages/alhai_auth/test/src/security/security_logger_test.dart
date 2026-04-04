import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_auth/alhai_auth.dart';

void main() {
  setUp(() {
    SecurityLogger.clear();
  });

  tearDown(() {
    SecurityLogger.clear();
  });

  group('SecurityLogger', () {
    group('log', () {
      test('adds entry to logs', () {
        final entry = SecurityLogEntry(
          type: SecurityEventType.loginSuccess,
          userId: 'user-1',
        );

        SecurityLogger.log(entry);

        final logs = SecurityLogger.getLogs();
        expect(logs, hasLength(1));
        expect(logs.first.type, equals(SecurityEventType.loginSuccess));
        expect(logs.first.userId, equals('user-1'));
      });

      test('respects max log limit of 100', () {
        for (var i = 0; i < 110; i++) {
          SecurityLogger.logEvent(
            SecurityEventType.loginSuccess,
            userId: 'user-$i',
          );
        }

        final logs = SecurityLogger.getLogs();
        expect(logs.length, equals(100));
      });

      test('removes oldest logs when limit exceeded', () {
        for (var i = 0; i < 110; i++) {
          SecurityLogger.logEvent(
            SecurityEventType.loginSuccess,
            userId: 'user-$i',
          );
        }

        final logs = SecurityLogger.getLogs();
        // The first 10 entries should have been removed
        expect(logs.first.userId, equals('user-10'));
        expect(logs.last.userId, equals('user-109'));
      });
    });

    group('logEvent', () {
      test('creates entry with all fields', () {
        SecurityLogger.logEvent(
          SecurityEventType.otpSent,
          userId: 'u1',
          phone: '+966512345678',
          details: 'Test detail',
          metadata: {'key': 'value'},
        );

        final logs = SecurityLogger.getLogs();
        expect(logs, hasLength(1));
        expect(logs.first.type, equals(SecurityEventType.otpSent));
        expect(logs.first.userId, equals('u1'));
        expect(logs.first.phone, equals('+966512345678'));
        expect(logs.first.details, equals('Test detail'));
        expect(logs.first.metadata, equals({'key': 'value'}));
      });
    });

    group('OTP logging helpers', () {
      test('logOtpSent records event with phone', () {
        SecurityLogger.logOtpSent('+966512345678');

        final logs = SecurityLogger.getLogs();
        expect(logs, hasLength(1));
        expect(logs.first.type, equals(SecurityEventType.otpSent));
        expect(logs.first.phone, equals('+966512345678'));
      });

      test('logOtpVerifySuccess records event', () {
        SecurityLogger.logOtpVerifySuccess('+966512345678');

        final logs = SecurityLogger.getLogs();
        expect(logs.first.type, equals(SecurityEventType.otpVerifySuccess));
      });

      test('logOtpVerifyFailed records event with remaining attempts', () {
        SecurityLogger.logOtpVerifyFailed('+966512345678', 2);

        final logs = SecurityLogger.getLogs();
        expect(logs.first.type, equals(SecurityEventType.otpVerifyFailed));
        expect(logs.first.details, contains('remaining=2'));
      });

      test('logOtpExpired records event', () {
        SecurityLogger.logOtpExpired('+966512345678');

        final logs = SecurityLogger.getLogs();
        expect(logs.first.type, equals(SecurityEventType.otpExpired));
      });

      test('logOtpRateLimited records event', () {
        SecurityLogger.logOtpRateLimited('+966512345678');

        final logs = SecurityLogger.getLogs();
        expect(logs.first.type, equals(SecurityEventType.otpRateLimited));
      });
    });

    group('PIN logging helpers', () {
      test('logPinVerifySuccess records event', () {
        SecurityLogger.logPinVerifySuccess();

        final logs = SecurityLogger.getLogs();
        expect(logs.first.type, equals(SecurityEventType.pinVerifySuccess));
      });

      test('logPinVerifyFailed records event with remaining', () {
        SecurityLogger.logPinVerifyFailed(3);

        final logs = SecurityLogger.getLogs();
        expect(logs.first.type, equals(SecurityEventType.pinVerifyFailed));
        expect(logs.first.details, contains('remaining=3'));
      });

      test('logPinLocked records event with duration', () {
        SecurityLogger.logPinLocked(const Duration(minutes: 15));

        final logs = SecurityLogger.getLogs();
        expect(logs.first.type, equals(SecurityEventType.pinLocked));
        expect(logs.first.details, contains('duration=15min'));
      });

      test('logPinCreated records event', () {
        SecurityLogger.logPinCreated();
        expect(SecurityLogger.getLogs().first.type,
            equals(SecurityEventType.pinCreated));
      });

      test('logPinChanged records event', () {
        SecurityLogger.logPinChanged();
        expect(SecurityLogger.getLogs().first.type,
            equals(SecurityEventType.pinChanged));
      });

      test('logPinRemoved records event', () {
        SecurityLogger.logPinRemoved();
        expect(SecurityLogger.getLogs().first.type,
            equals(SecurityEventType.pinRemoved));
      });
    });

    group('Session logging helpers', () {
      test('logSessionStarted records with userId', () {
        SecurityLogger.logSessionStarted('user-123');

        final logs = SecurityLogger.getLogs();
        expect(logs.first.type, equals(SecurityEventType.sessionStarted));
        expect(logs.first.userId, equals('user-123'));
      });

      test('logSessionEnded records event', () {
        SecurityLogger.logSessionEnded();
        expect(SecurityLogger.getLogs().first.type,
            equals(SecurityEventType.sessionEnded));
      });

      test('logSessionExpired records event', () {
        SecurityLogger.logSessionExpired();
        expect(SecurityLogger.getLogs().first.type,
            equals(SecurityEventType.sessionExpired));
      });

      test('logSessionRefreshed records event', () {
        SecurityLogger.logSessionRefreshed();
        expect(SecurityLogger.getLogs().first.type,
            equals(SecurityEventType.sessionRefreshed));
      });
    });

    group('Biometric logging helpers', () {
      test('logBiometricSuccess records event', () {
        SecurityLogger.logBiometricSuccess();
        expect(SecurityLogger.getLogs().first.type,
            equals(SecurityEventType.biometricSuccess));
      });

      test('logBiometricFailed records event with reason', () {
        SecurityLogger.logBiometricFailed('Fingerprint not recognized');

        final logs = SecurityLogger.getLogs();
        expect(logs.first.type, equals(SecurityEventType.biometricFailed));
        expect(logs.first.details, equals('Fingerprint not recognized'));
      });

      test('logBiometricEnabled records event', () {
        SecurityLogger.logBiometricEnabled();
        expect(SecurityLogger.getLogs().first.type,
            equals(SecurityEventType.biometricEnabled));
      });

      test('logBiometricDisabled records event', () {
        SecurityLogger.logBiometricDisabled();
        expect(SecurityLogger.getLogs().first.type,
            equals(SecurityEventType.biometricDisabled));
      });
    });

    group('Auth logging helpers', () {
      test('logLoginSuccess records with userId', () {
        SecurityLogger.logLoginSuccess('user-abc');

        final logs = SecurityLogger.getLogs();
        expect(logs.first.type, equals(SecurityEventType.loginSuccess));
        expect(logs.first.userId, equals('user-abc'));
      });

      test('logLoginFailed records with phone and reason', () {
        SecurityLogger.logLoginFailed('+966512345678', 'Invalid OTP');

        final logs = SecurityLogger.getLogs();
        expect(logs.first.type, equals(SecurityEventType.loginFailed));
        expect(logs.first.phone, equals('+966512345678'));
        expect(logs.first.details, equals('Invalid OTP'));
      });

      test('logLogoutSuccess records event', () {
        SecurityLogger.logLogoutSuccess();
        expect(SecurityLogger.getLogs().first.type,
            equals(SecurityEventType.logoutSuccess));
      });
    });

    group('getLogsByType', () {
      test('filters logs by type', () {
        SecurityLogger.logOtpSent('+966512345678');
        SecurityLogger.logPinCreated();
        SecurityLogger.logOtpSent('+966599998888');
        SecurityLogger.logLoginSuccess('user-1');

        final otpLogs = SecurityLogger.getLogsByType(SecurityEventType.otpSent);
        expect(otpLogs, hasLength(2));
      });

      test('returns empty list when no matching logs', () {
        SecurityLogger.logPinCreated();

        final logs =
            SecurityLogger.getLogsByType(SecurityEventType.loginSuccess);
        expect(logs, isEmpty);
      });
    });

    group('clear', () {
      test('removes all logs', () {
        SecurityLogger.logPinCreated();
        SecurityLogger.logLoginSuccess('u1');

        SecurityLogger.clear();

        expect(SecurityLogger.getLogs(), isEmpty);
      });
    });

    group('listeners', () {
      test('notifies listeners on log', () {
        SecurityLogEntry? received;
        void listener(SecurityLogEntry entry) => received = entry;

        SecurityLogger.addListener(listener);

        SecurityLogger.logPinCreated();

        expect(received, isNotNull);
        expect(received!.type, equals(SecurityEventType.pinCreated));

        SecurityLogger.removeListener(listener);
      });

      test('stops notifying after removeListener', () {
        int callCount = 0;
        void listener(SecurityLogEntry entry) => callCount++;

        SecurityLogger.addListener(listener);
        SecurityLogger.logPinCreated();
        expect(callCount, equals(1));

        SecurityLogger.removeListener(listener);
        SecurityLogger.logPinCreated();
        expect(callCount, equals(1));
      });
    });
  });

  group('SecurityLogEntry', () {
    test('toJson includes all fields', () {
      final entry = SecurityLogEntry(
        type: SecurityEventType.loginFailed,
        userId: 'u1',
        phone: '+966512345678',
        details: 'wrong password',
        metadata: {'attempt': 3},
      );

      final json = entry.toJson();
      expect(json['type'], equals('loginFailed'));
      expect(json['userId'], equals('u1'));
      expect(json['phone'], equals('+966512345678'));
      expect(json['details'], equals('wrong password'));
      expect(json['metadata'], equals({'attempt': 3}));
      expect(json['timestamp'], isNotNull);
    });

    test('toString masks phone number', () {
      final entry = SecurityLogEntry(
        type: SecurityEventType.otpSent,
        phone: '+966512345678',
      );

      final str = entry.toString();
      expect(str, contains('otpSent'));
      // Should mask the phone
      expect(str, isNot(contains('+966512345678')));
    });

    test('toString handles short phone numbers', () {
      final entry = SecurityLogEntry(
        type: SecurityEventType.otpSent,
        phone: '123',
      );

      final str = entry.toString();
      expect(str, contains('***'));
    });
  });
}
