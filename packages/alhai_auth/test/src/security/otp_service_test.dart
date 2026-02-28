import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_auth/alhai_auth.dart';

void main() {
  late InMemoryStorage storage;

  setUp(() {
    storage = InMemoryStorage();
    SecureStorageService.setStorage(storage);
  });

  tearDown(() async {
    // ignore: deprecated_member_use_from_same_package
    await OtpService.reset();
    SecureStorageService.resetStorage();
  });

  group('OtpState', () {
    test('isExpired returns true for past expiry', () {
      final state = OtpState(
        phone: '+966512345678',
        sentAt: DateTime.now().subtract(const Duration(minutes: 10)),
        expiresAt: DateTime.now().subtract(const Duration(minutes: 5)),
      );

      expect(state.isExpired, isTrue);
    });

    test('isExpired returns false for future expiry', () {
      final state = OtpState(
        phone: '+966512345678',
        sentAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
      );

      expect(state.isExpired, isFalse);
    });

    test('remainingTime returns Duration.zero when expired', () {
      final state = OtpState(
        phone: '+966512345678',
        sentAt: DateTime.now().subtract(const Duration(minutes: 10)),
        expiresAt: DateTime.now().subtract(const Duration(minutes: 5)),
      );

      expect(state.remainingTime, equals(Duration.zero));
    });

    test('remainingTime returns positive duration when not expired', () {
      final state = OtpState(
        phone: '+966512345678',
        sentAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
      );

      expect(state.remainingTime.inMinutes, greaterThan(0));
    });

    test('canResend returns false before cooldown expires', () {
      final state = OtpState(
        phone: '+966512345678',
        sentAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
      );

      expect(state.canResend, isFalse);
    });

    test('canResend returns true after cooldown', () {
      final state = OtpState(
        phone: '+966512345678',
        sentAt: DateTime.now().subtract(const Duration(seconds: 61)),
        expiresAt: DateTime.now().add(const Duration(minutes: 4)),
      );

      expect(state.canResend, isTrue);
    });

    test('canResend returns false when blocked', () {
      final state = OtpState(
        phone: '+966512345678',
        sentAt: DateTime.now().subtract(const Duration(seconds: 61)),
        expiresAt: DateTime.now().add(const Duration(minutes: 4)),
        isBlocked: true,
      );

      expect(state.canResend, isFalse);
    });

    test('toJson and fromJson round-trip', () {
      final now = DateTime.now();
      final state = OtpState(
        phone: '+966512345678',
        sentAt: now,
        expiresAt: now.add(const Duration(minutes: 5)),
        attempts: 2,
        isBlocked: false,
      );

      final json = state.toJson();
      final restored = OtpState.fromJson(json);

      expect(restored.phone, equals(state.phone));
      expect(restored.attempts, equals(2));
      expect(restored.isBlocked, isFalse);
    });
  });

  // ignore: deprecated_member_use_from_same_package
  group('OtpService', () {
    test('sendOtp succeeds with valid callback', () async {
      // ignore: deprecated_member_use_from_same_package
      final result = await OtpService.sendOtp(
        phone: '+966512345678',
        onSend: (_) async {},
      );

      expect(result.isSuccess, isTrue);
    });

    test('sendOtp records state after sending', () async {
      // ignore: deprecated_member_use_from_same_package
      await OtpService.sendOtp(
        phone: '+966512345678',
        onSend: (_) async {},
      );

      // ignore: deprecated_member_use_from_same_package
      final state = OtpService.currentState;
      expect(state, isNotNull);
      expect(state!.phone, equals('+966512345678'));
    });

    test('sendOtp returns error when callback fails', () async {
      // ignore: deprecated_member_use_from_same_package
      final result = await OtpService.sendOtp(
        phone: '+966512345678',
        onSend: (_) async => throw Exception('Network error'),
      );

      expect(result.isSuccess, isFalse);
      expect(result.error, isNotNull);
    });

    test('verifyOtp returns noOtpSent when no OTP was sent', () async {
      // ignore: deprecated_member_use_from_same_package
      final result = await OtpService.verifyOtp(
        phone: '+966512345678',
        otp: '123456',
        onVerify: (_, __) async => true,
      );

      expect(result.isSuccess, isFalse);
      expect(result.error, isNotNull);
    });

    test('verifyOtp returns success when callback returns true', () async {
      // ignore: deprecated_member_use_from_same_package
      await OtpService.sendOtp(
        phone: '+966512345678',
        onSend: (_) async {},
      );

      // ignore: deprecated_member_use_from_same_package
      final result = await OtpService.verifyOtp(
        phone: '+966512345678',
        otp: '123456',
        onVerify: (_, __) async => true,
      );

      expect(result.isSuccess, isTrue);
    });

    test('verifyOtp returns invalid when callback returns false', () async {
      // ignore: deprecated_member_use_from_same_package
      await OtpService.sendOtp(
        phone: '+966512345678',
        onSend: (_) async {},
      );

      // ignore: deprecated_member_use_from_same_package
      final result = await OtpService.verifyOtp(
        phone: '+966512345678',
        otp: '000000',
        onVerify: (_, __) async => false,
      );

      expect(result.isSuccess, isFalse);
      expect(result.remainingAttempts, isNotNull);
    });

    test('verifyOtp clears state after successful verification', () async {
      // ignore: deprecated_member_use_from_same_package
      await OtpService.sendOtp(
        phone: '+966512345678',
        onSend: (_) async {},
      );

      // ignore: deprecated_member_use_from_same_package
      await OtpService.verifyOtp(
        phone: '+966512345678',
        otp: '123456',
        onVerify: (_, __) async => true,
      );

      // ignore: deprecated_member_use_from_same_package
      expect(OtpService.currentState, isNull);
    });

    test('reset clears all state', () async {
      // ignore: deprecated_member_use_from_same_package
      await OtpService.sendOtp(
        phone: '+966512345678',
        onSend: (_) async {},
      );

      // ignore: deprecated_member_use_from_same_package
      await OtpService.reset();

      // ignore: deprecated_member_use_from_same_package
      expect(OtpService.currentState, isNull);
    });
  });

  group('OtpSendResult', () {
    test('success factory creates successful result', () {
      final result = OtpSendResult.success();
      expect(result.isSuccess, isTrue);
      expect(result.error, isNull);
    });

    test('error factory creates failed result with message', () {
      final result = OtpSendResult.error('Network error');
      expect(result.isSuccess, isFalse);
      expect(result.error, equals('Network error'));
    });

    test('rateLimited factory includes blockedUntil', () {
      final until = DateTime.now().add(const Duration(minutes: 5));
      final result = OtpSendResult.rateLimited(until);
      expect(result.isSuccess, isFalse);
      expect(result.blockedUntil, equals(until));
    });

    test('cooldown factory includes cooldown duration', () {
      final result = OtpSendResult.cooldown(const Duration(seconds: 30));
      expect(result.isSuccess, isFalse);
      expect(result.cooldown, equals(const Duration(seconds: 30)));
    });
  });

  group('OtpVerifyResult', () {
    test('success factory creates successful result', () {
      final result = OtpVerifyResult.success();
      expect(result.isSuccess, isTrue);
    });

    test('invalid factory includes remaining attempts', () {
      final result = OtpVerifyResult.invalid(2);
      expect(result.isSuccess, isFalse);
      expect(result.remainingAttempts, equals(2));
    });

    test('expired factory creates expired result', () {
      final result = OtpVerifyResult.expired();
      expect(result.isSuccess, isFalse);
    });

    test('maxAttemptsExceeded factory has zero remaining', () {
      final result = OtpVerifyResult.maxAttemptsExceeded();
      expect(result.isSuccess, isFalse);
      expect(result.remainingAttempts, equals(0));
    });
  });
}
