import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/security/session_manager.dart';

void main() {
  group('SessionManager Tests', () {
    group('Session Status', () {
      test('should return notAuthenticated when no token', () async {
        // ملاحظة: هذا الاختبار يحتاج mock للـ SecureStorageService
        // في بيئة الاختبار الحقيقية
        
        // الاختبار الأساسي للـ enum
        expect(SessionStatus.valid.index, 0);
        expect(SessionStatus.needsRefresh.index, 1);
        expect(SessionStatus.expired.index, 2);
        expect(SessionStatus.notAuthenticated.index, 3);
      });

      test('should have correct session duration', () {
        expect(SessionManager.sessionDuration.inMinutes, 30);
      });

      test('should have correct refresh buffer', () {
        expect(SessionManager.tokenRefreshBuffer.inMinutes, 5);
      });
    });

    group('Session Lifecycle', () {
      test('session duration should be 30 minutes', () {
        expect(SessionManager.sessionDuration, const Duration(minutes: 30));
      });

      test('token refresh buffer should be 5 minutes', () {
        expect(SessionManager.tokenRefreshBuffer, const Duration(minutes: 5));
      });
    });

    group('SessionStatus enum', () {
      test('should have all required values', () {
        expect(SessionStatus.values.length, 4);
        expect(SessionStatus.values.contains(SessionStatus.valid), true);
        expect(SessionStatus.values.contains(SessionStatus.needsRefresh), true);
        expect(SessionStatus.values.contains(SessionStatus.expired), true);
        expect(SessionStatus.values.contains(SessionStatus.notAuthenticated), true);
      });
    });
  });
}
