import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_auth/alhai_auth.dart';

void main() {
  group('BiometricLoginResult', () {
    test('success factory creates successful result', () {
      final result = BiometricLoginResult.success();
      expect(result.isSuccess, isTrue);
      expect(result.error, isNull);
      expect(result.errorType, isNull);
    });

    test('failed factory creates failed result', () {
      final result = BiometricLoginResult.failed();
      expect(result.isSuccess, isFalse);
      expect(result.error, isNotNull);
      expect(result.errorType, BiometricLoginError.failed);
    });

    test('notEnabled factory creates notEnabled result', () {
      final result = BiometricLoginResult.notEnabled();
      expect(result.isSuccess, isFalse);
      expect(result.errorType, BiometricLoginError.notEnabled);
    });

    test('notAvailable factory creates notAvailable result', () {
      final result = BiometricLoginResult.notAvailable();
      expect(result.isSuccess, isFalse);
      expect(result.errorType, BiometricLoginError.notAvailable);
    });

    test('lockedOut factory creates lockedOut result', () {
      final result = BiometricLoginResult.lockedOut();
      expect(result.isSuccess, isFalse);
      expect(result.errorType, BiometricLoginError.lockedOut);
    });
  });

  group('BiometricLoginError', () {
    test('has all expected values', () {
      expect(BiometricLoginError.values, hasLength(4));
      expect(BiometricLoginError.values, contains(BiometricLoginError.failed));
      expect(
          BiometricLoginError.values, contains(BiometricLoginError.notEnabled));
      expect(BiometricLoginError.values,
          contains(BiometricLoginError.notAvailable));
      expect(
          BiometricLoginError.values, contains(BiometricLoginError.lockedOut));
    });
  });

  group('BiometricService settings (with InMemoryStorage)', () {
    late InMemoryStorage storage;

    setUp(() {
      storage = InMemoryStorage();
      SecureStorageService.setStorage(storage);
    });

    tearDown(() {
      SecureStorageService.resetStorage();
    });

    test('isEnabled returns false when not set', () async {
      final enabled = await BiometricService.isEnabled();
      expect(enabled, isFalse);
    });

    test('disable removes the key', () async {
      // Manually set the key
      await storage.write(key: 'biometric_enabled', value: 'true');

      await BiometricService.disable();

      final enabled = await BiometricService.isEnabled();
      expect(enabled, isFalse);
    });
  });
}
