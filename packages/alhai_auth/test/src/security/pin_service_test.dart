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

  group('PinService', () {
    group('isEnabled', () {
      test('returns false when PIN is not set', () async {
        final enabled = await PinService.isEnabled();
        expect(enabled, isFalse);
      });

      test('returns true after creating a PIN', () async {
        await PinService.createPin('1234');
        final enabled = await PinService.isEnabled();
        expect(enabled, isTrue);
      });
    });

    group('createPin', () {
      test('succeeds with valid 4-digit PIN', () async {
        final result = await PinService.createPin('1234');
        expect(result.isSuccess, isTrue);
      });

      test('succeeds with valid 6-digit PIN', () async {
        final result = await PinService.createPin('123456');
        expect(result.isSuccess, isTrue);
      });

      test('fails with PIN shorter than 4 digits', () async {
        final result = await PinService.createPin('123');
        expect(result.isSuccess, isFalse);
        expect(result.errorType, equals(PinError.invalidLength));
      });

      test('fails with PIN longer than 6 digits', () async {
        final result = await PinService.createPin('1234567');
        expect(result.isSuccess, isFalse);
        expect(result.errorType, equals(PinError.invalidLength));
      });

      test('fails with non-numeric PIN', () async {
        final result = await PinService.createPin('12ab');
        expect(result.isSuccess, isFalse);
        expect(result.errorType, equals(PinError.invalidFormat));
      });

      test('fails with alphanumeric PIN', () async {
        final result = await PinService.createPin('a1b2');
        expect(result.isSuccess, isFalse);
        expect(result.errorType, equals(PinError.invalidFormat));
      });
    });

    group('verifyPin', () {
      test('succeeds with correct PIN', () async {
        await PinService.createPin('5678');
        final result = await PinService.verifyPin('5678');
        expect(result.isSuccess, isTrue);
      });

      test('fails with incorrect PIN', () async {
        await PinService.createPin('5678');
        final result = await PinService.verifyPin('1111');
        expect(result.isSuccess, isFalse);
        expect(result.errorType, equals(PinError.incorrect));
        expect(result.remainingAttempts, isNotNull);
      });

      test('returns notEnabled when PIN is not set', () async {
        final result = await PinService.verifyPin('1234');
        expect(result.isSuccess, isFalse);
        expect(result.errorType, equals(PinError.notEnabled));
      });

      test('decrements remaining attempts on failure', () async {
        await PinService.createPin('1234');

        final r1 = await PinService.verifyPin('0000');
        expect(r1.remainingAttempts, equals(kMaxPinAttempts - 1));

        final r2 = await PinService.verifyPin('0000');
        expect(r2.remainingAttempts, equals(kMaxPinAttempts - 2));
      });

      test('resets attempts after successful verification', () async {
        await PinService.createPin('1234');
        await PinService.verifyPin('0000'); // fail
        await PinService.verifyPin('0000'); // fail

        final success = await PinService.verifyPin('1234');
        expect(success.isSuccess, isTrue);

        // After success, attempts are reset; next failure should have max-1
        final fail = await PinService.verifyPin('0000');
        expect(fail.remainingAttempts, equals(kMaxPinAttempts - 1));
      });

      test('locks out after max failed attempts', () async {
        await PinService.createPin('1234');

        for (var i = 0; i < kMaxPinAttempts; i++) {
          await PinService.verifyPin('0000');
        }

        final result = await PinService.verifyPin('1234');
        expect(result.isSuccess, isFalse);
        expect(result.errorType, equals(PinError.lockedOut));
      });
    });

    group('changePin', () {
      test('succeeds with correct current PIN and valid new PIN', () async {
        await PinService.createPin('1234');
        final result = await PinService.changePin('1234', '5678');
        expect(result.isSuccess, isTrue);

        // Verify new PIN works
        final verify = await PinService.verifyPin('5678');
        expect(verify.isSuccess, isTrue);
      });

      test('fails with incorrect current PIN', () async {
        await PinService.createPin('1234');
        final result = await PinService.changePin('0000', '5678');
        expect(result.isSuccess, isFalse);
      });
    });

    group('removePin', () {
      test('disables PIN after removal', () async {
        await PinService.createPin('1234');
        expect(await PinService.isEnabled(), isTrue);

        await PinService.removePin();
        expect(await PinService.isEnabled(), isFalse);
      });
    });

    group('isLockedOut', () {
      test('returns false when not locked', () async {
        final locked = await PinService.isLockedOut();
        expect(locked, isFalse);
      });

      test('returns true when locked due to max attempts', () async {
        await PinService.createPin('1234');
        for (var i = 0; i < kMaxPinAttempts; i++) {
          await PinService.verifyPin('0000');
        }
        final locked = await PinService.isLockedOut();
        expect(locked, isTrue);
      });
    });
  });
}
