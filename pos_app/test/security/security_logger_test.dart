import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/security/security_logger.dart';

// ===========================================
// Security Logger Tests
// ===========================================

void main() {
  setUp(() {
    // مسح السجلات قبل كل اختبار
    SecurityLogger.clear();
  });

  group('SecurityEventType enum', () {
    test('يحتوي على جميع أنواع OTP', () {
      expect(SecurityEventType.values, contains(SecurityEventType.otpSent));
      expect(SecurityEventType.values, contains(SecurityEventType.otpVerifySuccess));
      expect(SecurityEventType.values, contains(SecurityEventType.otpVerifyFailed));
      expect(SecurityEventType.values, contains(SecurityEventType.otpExpired));
      expect(SecurityEventType.values, contains(SecurityEventType.otpRateLimited));
    });

    test('يحتوي على جميع أنواع PIN', () {
      expect(SecurityEventType.values, contains(SecurityEventType.pinVerifySuccess));
      expect(SecurityEventType.values, contains(SecurityEventType.pinVerifyFailed));
      expect(SecurityEventType.values, contains(SecurityEventType.pinLocked));
      expect(SecurityEventType.values, contains(SecurityEventType.pinCreated));
      expect(SecurityEventType.values, contains(SecurityEventType.pinChanged));
      expect(SecurityEventType.values, contains(SecurityEventType.pinRemoved));
    });

    test('يحتوي على جميع أنواع Session', () {
      expect(SecurityEventType.values, contains(SecurityEventType.sessionStarted));
      expect(SecurityEventType.values, contains(SecurityEventType.sessionEnded));
      expect(SecurityEventType.values, contains(SecurityEventType.sessionExpired));
      expect(SecurityEventType.values, contains(SecurityEventType.sessionRefreshed));
    });

    test('يحتوي على جميع أنواع Biometric', () {
      expect(SecurityEventType.values, contains(SecurityEventType.biometricSuccess));
      expect(SecurityEventType.values, contains(SecurityEventType.biometricFailed));
      expect(SecurityEventType.values, contains(SecurityEventType.biometricEnabled));
      expect(SecurityEventType.values, contains(SecurityEventType.biometricDisabled));
    });

    test('يحتوي على جميع أنواع Auth', () {
      expect(SecurityEventType.values, contains(SecurityEventType.loginSuccess));
      expect(SecurityEventType.values, contains(SecurityEventType.loginFailed));
      expect(SecurityEventType.values, contains(SecurityEventType.logoutSuccess));
    });
  });

  group('SecurityLogEntry', () {
    test('ينشئ سجل بالقيم الأساسية', () {
      final entry = SecurityLogEntry(
        type: SecurityEventType.otpSent,
        phone: '+966501234567',
      );

      expect(entry.type, SecurityEventType.otpSent);
      expect(entry.phone, '+966501234567');
      expect(entry.timestamp, isNotNull);
      expect(entry.userId, isNull);
      expect(entry.details, isNull);
      expect(entry.metadata, isNull);
    });

    test('ينشئ سجل بجميع القيم', () {
      final entry = SecurityLogEntry(
        type: SecurityEventType.loginSuccess,
        userId: 'user_123',
        phone: '+966501234567',
        details: 'تسجيل دخول ناجح',
        metadata: {'ip': '192.168.1.1'},
      );

      expect(entry.type, SecurityEventType.loginSuccess);
      expect(entry.userId, 'user_123');
      expect(entry.phone, '+966501234567');
      expect(entry.details, 'تسجيل دخول ناجح');
      expect(entry.metadata, {'ip': '192.168.1.1'});
    });

    test('timestamp يُعين تلقائياً', () {
      final before = DateTime.now();
      final entry = SecurityLogEntry(type: SecurityEventType.sessionStarted);
      final after = DateTime.now();

      expect(entry.timestamp.isAfter(before) || entry.timestamp.isAtSameMomentAs(before), true);
      expect(entry.timestamp.isBefore(after) || entry.timestamp.isAtSameMomentAs(after), true);
    });

    group('toJson', () {
      test('يحول السجل إلى JSON', () {
        final entry = SecurityLogEntry(
          type: SecurityEventType.otpVerifySuccess,
          phone: '+966501234567',
          details: 'تم التحقق',
        );

        final json = entry.toJson();

        expect(json['type'], 'otpVerifySuccess');
        expect(json['phone'], '+966501234567');
        expect(json['details'], 'تم التحقق');
        expect(json['timestamp'], isNotNull);
      });

      test('يتضمن userId إذا كان موجوداً', () {
        final entry = SecurityLogEntry(
          type: SecurityEventType.loginSuccess,
          userId: 'user_456',
        );

        final json = entry.toJson();
        expect(json['userId'], 'user_456');
      });

      test('يتضمن metadata إذا كان موجوداً', () {
        final entry = SecurityLogEntry(
          type: SecurityEventType.pinLocked,
          metadata: {'attempts': 3},
        );

        final json = entry.toJson();
        expect(json['metadata'], {'attempts': 3});
      });
    });

    group('toString', () {
      test('يُنشئ نص قابل للقراءة', () {
        final entry = SecurityLogEntry(
          type: SecurityEventType.otpSent,
          phone: '+966501234567',
        );

        final str = entry.toString();

        expect(str, contains('otpSent'));
        expect(str, contains('phone:'));
      });

      test('يخفي رقم الهاتف جزئياً', () {
        final entry = SecurityLogEntry(
          type: SecurityEventType.otpSent,
          phone: '+966501234567',
        );

        final str = entry.toString();

        // يجب ألا يظهر الرقم كاملاً
        expect(str, isNot(contains('+966501234567')));
        // يجب أن يظهر جزء من الرقم
        expect(str, contains('+966'));
        expect(str, contains('****'));
      });

      test('يتضمن التفاصيل إذا كانت موجودة', () {
        final entry = SecurityLogEntry(
          type: SecurityEventType.pinVerifyFailed,
          details: 'remaining=2',
        );

        final str = entry.toString();
        expect(str, contains('remaining=2'));
      });
    });
  });

  group('SecurityLogger - Basic Operations', () {
    test('getLogs يُرجع قائمة فارغة في البداية', () {
      expect(SecurityLogger.getLogs(), isEmpty);
    });

    test('log يضيف سجل', () {
      final entry = SecurityLogEntry(type: SecurityEventType.sessionStarted);
      SecurityLogger.log(entry);

      expect(SecurityLogger.getLogs().length, 1);
      expect(SecurityLogger.getLogs().first.type, SecurityEventType.sessionStarted);
    });

    test('clear يمسح السجلات', () {
      SecurityLogger.logEvent(SecurityEventType.sessionStarted);
      SecurityLogger.logEvent(SecurityEventType.sessionEnded);

      expect(SecurityLogger.getLogs().length, 2);

      SecurityLogger.clear();

      expect(SecurityLogger.getLogs(), isEmpty);
    });

    test('يحافظ على الحد الأقصى 100 سجل', () {
      // إضافة أكثر من 100 سجل
      for (int i = 0; i < 120; i++) {
        SecurityLogger.logEvent(SecurityEventType.sessionRefreshed);
      }

      expect(SecurityLogger.getLogs().length, lessThanOrEqualTo(100));
    });
  });

  group('SecurityLogger - logEvent', () {
    test('يسجل حدث بدون معلومات إضافية', () {
      SecurityLogger.logEvent(SecurityEventType.pinCreated);

      final logs = SecurityLogger.getLogs();
      expect(logs.length, 1);
      expect(logs.first.type, SecurityEventType.pinCreated);
    });

    test('يسجل حدث مع معلومات كاملة', () {
      SecurityLogger.logEvent(
        SecurityEventType.loginSuccess,
        userId: 'user_789',
        phone: '+966509876543',
        details: 'first login',
        metadata: {'device': 'android'},
      );

      final log = SecurityLogger.getLogs().first;
      expect(log.type, SecurityEventType.loginSuccess);
      expect(log.userId, 'user_789');
      expect(log.phone, '+966509876543');
      expect(log.details, 'first login');
      expect(log.metadata, {'device': 'android'});
    });
  });

  group('SecurityLogger - getLogsByType', () {
    test('يُرجع سجلات نوع معين فقط', () {
      SecurityLogger.logEvent(SecurityEventType.otpSent);
      SecurityLogger.logEvent(SecurityEventType.pinCreated);
      SecurityLogger.logEvent(SecurityEventType.otpSent);
      SecurityLogger.logEvent(SecurityEventType.sessionStarted);

      final otpLogs = SecurityLogger.getLogsByType(SecurityEventType.otpSent);

      expect(otpLogs.length, 2);
      expect(otpLogs.every((e) => e.type == SecurityEventType.otpSent), true);
    });

    test('يُرجع قائمة فارغة إذا لم يوجد النوع', () {
      SecurityLogger.logEvent(SecurityEventType.sessionStarted);

      final logs = SecurityLogger.getLogsByType(SecurityEventType.biometricSuccess);

      expect(logs, isEmpty);
    });
  });

  group('SecurityLogger - OTP Logging', () {
    test('logOtpSent يسجل إرسال OTP', () {
      SecurityLogger.logOtpSent('+966501234567');

      final log = SecurityLogger.getLogs().first;
      expect(log.type, SecurityEventType.otpSent);
      expect(log.phone, '+966501234567');
    });

    test('logOtpVerifySuccess يسجل نجاح التحقق', () {
      SecurityLogger.logOtpVerifySuccess('+966501234567');

      final log = SecurityLogger.getLogs().first;
      expect(log.type, SecurityEventType.otpVerifySuccess);
    });

    test('logOtpVerifyFailed يسجل فشل التحقق مع المحاولات المتبقية', () {
      SecurityLogger.logOtpVerifyFailed('+966501234567', 2);

      final log = SecurityLogger.getLogs().first;
      expect(log.type, SecurityEventType.otpVerifyFailed);
      expect(log.details, contains('remaining=2'));
    });

    test('logOtpExpired يسجل انتهاء OTP', () {
      SecurityLogger.logOtpExpired('+966501234567');

      final log = SecurityLogger.getLogs().first;
      expect(log.type, SecurityEventType.otpExpired);
    });

    test('logOtpRateLimited يسجل تجاوز الحد', () {
      SecurityLogger.logOtpRateLimited('+966501234567');

      final log = SecurityLogger.getLogs().first;
      expect(log.type, SecurityEventType.otpRateLimited);
    });
  });

  group('SecurityLogger - PIN Logging', () {
    test('logPinVerifySuccess يسجل نجاح التحقق', () {
      SecurityLogger.logPinVerifySuccess();

      final log = SecurityLogger.getLogs().first;
      expect(log.type, SecurityEventType.pinVerifySuccess);
    });

    test('logPinVerifyFailed يسجل فشل التحقق', () {
      SecurityLogger.logPinVerifyFailed(1);

      final log = SecurityLogger.getLogs().first;
      expect(log.type, SecurityEventType.pinVerifyFailed);
      expect(log.details, contains('remaining=1'));
    });

    test('logPinLocked يسجل القفل مع المدة', () {
      SecurityLogger.logPinLocked(const Duration(minutes: 5));

      final log = SecurityLogger.getLogs().first;
      expect(log.type, SecurityEventType.pinLocked);
      expect(log.details, contains('5min'));
    });

    test('logPinCreated يسجل إنشاء PIN', () {
      SecurityLogger.logPinCreated();

      expect(SecurityLogger.getLogs().first.type, SecurityEventType.pinCreated);
    });

    test('logPinChanged يسجل تغيير PIN', () {
      SecurityLogger.logPinChanged();

      expect(SecurityLogger.getLogs().first.type, SecurityEventType.pinChanged);
    });

    test('logPinRemoved يسجل حذف PIN', () {
      SecurityLogger.logPinRemoved();

      expect(SecurityLogger.getLogs().first.type, SecurityEventType.pinRemoved);
    });
  });

  group('SecurityLogger - Session Logging', () {
    test('logSessionStarted يسجل بدء الجلسة', () {
      SecurityLogger.logSessionStarted('user_123');

      final log = SecurityLogger.getLogs().first;
      expect(log.type, SecurityEventType.sessionStarted);
      expect(log.userId, 'user_123');
    });

    test('logSessionEnded يسجل انتهاء الجلسة', () {
      SecurityLogger.logSessionEnded();

      expect(SecurityLogger.getLogs().first.type, SecurityEventType.sessionEnded);
    });

    test('logSessionExpired يسجل انتهاء صلاحية الجلسة', () {
      SecurityLogger.logSessionExpired();

      expect(SecurityLogger.getLogs().first.type, SecurityEventType.sessionExpired);
    });

    test('logSessionRefreshed يسجل تحديث الجلسة', () {
      SecurityLogger.logSessionRefreshed();

      expect(SecurityLogger.getLogs().first.type, SecurityEventType.sessionRefreshed);
    });
  });

  group('SecurityLogger - Biometric Logging', () {
    test('logBiometricSuccess يسجل نجاح البيومترية', () {
      SecurityLogger.logBiometricSuccess();

      expect(SecurityLogger.getLogs().first.type, SecurityEventType.biometricSuccess);
    });

    test('logBiometricFailed يسجل فشل البيومترية', () {
      SecurityLogger.logBiometricFailed('المستخدم ألغى');

      final log = SecurityLogger.getLogs().first;
      expect(log.type, SecurityEventType.biometricFailed);
      expect(log.details, 'المستخدم ألغى');
    });

    test('logBiometricEnabled يسجل تفعيل البيومترية', () {
      SecurityLogger.logBiometricEnabled();

      expect(SecurityLogger.getLogs().first.type, SecurityEventType.biometricEnabled);
    });

    test('logBiometricDisabled يسجل تعطيل البيومترية', () {
      SecurityLogger.logBiometricDisabled();

      expect(SecurityLogger.getLogs().first.type, SecurityEventType.biometricDisabled);
    });
  });

  group('SecurityLogger - Auth Logging', () {
    test('logLoginSuccess يسجل نجاح الدخول', () {
      SecurityLogger.logLoginSuccess('user_456');

      final log = SecurityLogger.getLogs().first;
      expect(log.type, SecurityEventType.loginSuccess);
      expect(log.userId, 'user_456');
    });

    test('logLoginFailed يسجل فشل الدخول', () {
      SecurityLogger.logLoginFailed('+966501234567', 'كلمة مرور خاطئة');

      final log = SecurityLogger.getLogs().first;
      expect(log.type, SecurityEventType.loginFailed);
      expect(log.phone, '+966501234567');
      expect(log.details, 'كلمة مرور خاطئة');
    });

    test('logLogoutSuccess يسجل نجاح الخروج', () {
      SecurityLogger.logLogoutSuccess();

      expect(SecurityLogger.getLogs().first.type, SecurityEventType.logoutSuccess);
    });
  });

  group('SecurityLogger - Listeners', () {
    test('يُنفذ callback عند تسجيل حدث', () {
      SecurityLogEntry? receivedEntry;

      void listener(SecurityLogEntry entry) {
        receivedEntry = entry;
      }

      SecurityLogger.addListener(listener);
      SecurityLogger.logEvent(SecurityEventType.sessionStarted);

      expect(receivedEntry, isNotNull);
      expect(receivedEntry!.type, SecurityEventType.sessionStarted);

      SecurityLogger.removeListener(listener);
    });

    test('يمكن إزالة المستمع', () {
      int callCount = 0;

      void listener(SecurityLogEntry entry) {
        callCount++;
      }

      SecurityLogger.addListener(listener);
      SecurityLogger.logEvent(SecurityEventType.sessionStarted);
      expect(callCount, 1);

      SecurityLogger.removeListener(listener);
      SecurityLogger.logEvent(SecurityEventType.sessionEnded);
      expect(callCount, 1); // لم يتغير
    });
  });
}
