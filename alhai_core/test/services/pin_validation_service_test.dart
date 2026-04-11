import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_core/src/services/pin_validation_service.dart';

void main() {
  // ── PinActionType Enum ────────────────────────────────────

  group('PinActionType', () {
    test('has correct Arabic display names', () {
      expect(PinActionType.refund.displayNameAr, 'مرتجع');
      expect(PinActionType.discount.displayNameAr, 'خصم');
      expect(PinActionType.voidSale.displayNameAr, 'إلغاء فاتورة');
      expect(PinActionType.cashOut.displayNameAr, 'سحب نقدي');
      expect(PinActionType.priceOverride.displayNameAr, 'تعديل سعر');
      expect(PinActionType.shiftClose.displayNameAr, 'إغلاق وردية');
    });

    test('refund/discount/void/cashOut require SUPERVISOR role', () {
      expect(PinActionType.refund.requiredRole, 'SUPERVISOR');
      expect(PinActionType.discount.requiredRole, 'SUPERVISOR');
      expect(PinActionType.voidSale.requiredRole, 'SUPERVISOR');
      expect(PinActionType.cashOut.requiredRole, 'SUPERVISOR');
    });

    test('priceOverride/shiftClose require MANAGER role', () {
      expect(PinActionType.priceOverride.requiredRole, 'MANAGER');
      expect(PinActionType.shiftClose.requiredRole, 'MANAGER');
    });

    test('all enum values covered', () {
      expect(PinActionType.values.length, 6);
    });
  });

  // ── PinValidationResult ──────────────────────────────────

  group('PinValidationResult', () {
    group('factory constructors', () {
      test('success creates valid result with user info', () {
        final result = PinValidationResult.success(
          userId: 'user-1',
          userName: 'Ahmed',
          role: 'SUPERVISOR',
          permissions: ['refund', 'discount'],
        );

        expect(result.isValid, isTrue);
        expect(result.userId, 'user-1');
        expect(result.userName, 'Ahmed');
        expect(result.role, 'SUPERVISOR');
        expect(result.permissions, ['refund', 'discount']);
        expect(result.errorMessage, isNull);
      });

      test('success with null permissions defaults to empty list', () {
        final result = PinValidationResult.success(
          userId: 'user-1',
          userName: 'Ahmed',
          role: 'MANAGER',
        );

        expect(result.permissions, isEmpty);
      });

      test('failure creates invalid result with error message', () {
        final result = PinValidationResult.failure(
          errorMessage: 'Invalid PIN',
          remainingAttempts: 2,
        );

        expect(result.isValid, isFalse);
        expect(result.errorMessage, 'Invalid PIN');
        expect(result.remainingAttempts, 2);
        expect(result.userId, isNull);
      });

      test('failure with lockout time', () {
        final lockUntil = DateTime.now().add(const Duration(minutes: 30));
        final result = PinValidationResult.failure(
          errorMessage: 'Account locked',
          remainingAttempts: 0,
          lockedUntil: lockUntil,
        );

        expect(result.isValid, isFalse);
        expect(result.lockedUntil, lockUntil);
        expect(result.remainingAttempts, 0);
      });
    });

    group('isLocked', () {
      test('returns true when locked until future time', () {
        final result = PinValidationResult.failure(
          errorMessage: 'Locked',
          lockedUntil: DateTime.now().add(const Duration(hours: 1)),
        );

        expect(result.isLocked, isTrue);
      });

      test('returns false when lock time is in the past', () {
        final result = PinValidationResult.failure(
          errorMessage: 'Was locked',
          lockedUntil: DateTime.now().subtract(const Duration(hours: 1)),
        );

        expect(result.isLocked, isFalse);
      });

      test('returns false when no lock time set', () {
        final result = PinValidationResult.failure(errorMessage: 'Failed');

        expect(result.isLocked, isFalse);
      });
    });

    group('JSON serialization', () {
      test('round-trips success result through JSON', () {
        final original = PinValidationResult.success(
          userId: 'user-1',
          userName: 'Test User',
          role: 'SUPERVISOR',
          permissions: ['refund'],
        );

        final json = original.toJson();
        final restored = PinValidationResult.fromJson(json);

        expect(restored.isValid, original.isValid);
        expect(restored.userId, original.userId);
        expect(restored.userName, original.userName);
        expect(restored.role, original.role);
      });

      test('round-trips failure result through JSON', () {
        final original = PinValidationResult.failure(
          errorMessage: 'Wrong PIN',
          remainingAttempts: 1,
        );

        final json = original.toJson();
        final restored = PinValidationResult.fromJson(json);

        expect(restored.isValid, isFalse);
        expect(restored.errorMessage, 'Wrong PIN');
        expect(restored.remainingAttempts, 1);
      });
    });
  });

  // ── PinValidationRequest ─────────────────────────────────

  group('PinValidationRequest', () {
    test('stores required fields', () {
      const request = PinValidationRequest(
        pin: '1234',
        action: PinActionType.refund,
      );

      expect(request.pin, '1234');
      expect(request.action, PinActionType.refund);
      expect(request.supervisorId, isNull);
    });

    test('stores optional supervisor ID', () {
      const request = PinValidationRequest(
        pin: '5678',
        action: PinActionType.voidSale,
        supervisorId: 'sup-1',
      );

      expect(request.supervisorId, 'sup-1');
    });

    test('round-trips through JSON', () {
      const original = PinValidationRequest(
        pin: '0000',
        action: PinActionType.discount,
        supervisorId: 'sup-1',
      );

      final json = original.toJson();
      final restored = PinValidationRequest.fromJson(json);

      expect(restored.pin, original.pin);
      expect(restored.action, original.action);
      expect(restored.supervisorId, original.supervisorId);
    });
  });

  // ── EmergencyCode ────────────────────────────────────────

  group('EmergencyCode', () {
    test('stores all fields', () {
      final code = EmergencyCode(
        code: 'EMRG-001',
        supervisorId: 'sup-1',
        expiresAt: DateTime(2026, 6, 1),
      );

      expect(code.code, 'EMRG-001');
      expect(code.supervisorId, 'sup-1');
      expect(code.isUsed, isFalse);
    });

    test('round-trips through JSON', () {
      final original = EmergencyCode(
        code: 'EMRG-002',
        supervisorId: 'sup-2',
        expiresAt: DateTime(2026, 6, 15),
        isUsed: true,
      );

      final json = original.toJson();
      final restored = EmergencyCode.fromJson(json);

      expect(restored.code, original.code);
      expect(restored.supervisorId, original.supervisorId);
      expect(restored.isUsed, isTrue);
    });
  });

  // ── TotpSecret ───────────────────────────────────────────

  group('TotpSecret', () {
    test('stores all fields', () {
      final secret = TotpSecret(
        userId: 'user-1',
        secret: 'JBSWY3DPEHPK3PXP',
        syncedAt: DateTime(2026, 1, 1),
      );

      expect(secret.userId, 'user-1');
      expect(secret.secret, 'JBSWY3DPEHPK3PXP');
    });

    test('round-trips through JSON', () {
      final original = TotpSecret(
        userId: 'user-2',
        secret: 'SECRET123',
        syncedAt: DateTime(2026, 3, 15),
      );

      final json = original.toJson();
      final restored = TotpSecret.fromJson(json);

      expect(restored.userId, original.userId);
      expect(restored.secret, original.secret);
    });
  });
}
