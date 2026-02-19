import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/security/otp_service.dart';
import 'package:pos_app/core/security/secure_storage_service.dart';

void main() {
  group('LoginScreen Tests', () {
    setUp(() async {
      // Use in-memory storage for testing
      SecureStorageService.setStorage(InMemoryStorage());
      await OtpService.reset();
    });

    tearDown(() {
      SecureStorageService.resetStorage();
    });

    group('OTP Integration', () {
      test('OtpService.sendOtp يُرسل OTP بنجاح', () async {
        bool apiCalled = false;

        final result = await OtpService.sendOtp(
          phone: '+966500000001',
          onSend: (phone) async {
            apiCalled = true;
            expect(phone, '+966500000001');
          },
        );

        expect(result.isSuccess, true);
        expect(apiCalled, true);
        expect(OtpService.currentState, isNotNull);
        expect(OtpService.currentState!.phone, '+966500000001');
      });

      test('OtpService.verifyOtp يتحقق من OTP بنجاح', () async {
        // إرسال OTP أولاً
        await OtpService.sendOtp(
          phone: '+966500000001',
          onSend: (phone) async {},
        );

        // التحقق
        final result = await OtpService.verifyOtp(
          phone: '+966500000001',
          otp: '123456',
          onVerify: (phone, otp) async {
            expect(phone, '+966500000001');
            expect(otp, '123456');
            return true;
          },
        );

        expect(result.isSuccess, true);
      });

      test('OtpService.verifyOtp يفشل مع OTP خاطئ', () async {
        await OtpService.sendOtp(
          phone: '+966500000001',
          onSend: (phone) async {},
        );

        final result = await OtpService.verifyOtp(
          phone: '+966500000001',
          otp: '000000',
          onVerify: (phone, otp) async => false,
        );

        expect(result.isSuccess, false);
        expect(result.error, isNotNull);
        expect(result.remainingAttempts, isNotNull);
      });

      test('لا يمكن التحقق بدون إرسال OTP', () async {
        final result = await OtpService.verifyOtp(
          phone: '+966500000001',
          otp: '123456',
          onVerify: (phone, otp) async => true,
        );

        expect(result.isSuccess, false);
        expect(result.error, contains('لم يتم إرسال'));
      });
    });

    group('Rate Limiting', () {
      test('يحظر بعد 3 محاولات فاشلة', () async {
        await OtpService.sendOtp(
          phone: '+966500000001',
          onSend: (phone) async {},
        );

        // 3 محاولات فاشلة
        for (var i = 0; i < 3; i++) {
          await OtpService.verifyOtp(
            phone: '+966500000001',
            otp: 'wrong',
            onVerify: (phone, otp) async => false,
          );
        }

        // المحاولة الـ 4 يجب أن تكون محظورة
        final result = await OtpService.verifyOtp(
          phone: '+966500000001',
          otp: 'correct',
          onVerify: (phone, otp) async => true,
        );

        expect(result.isSuccess, false);
      });

      test('يتتبع المحاولات المتبقية', () async {
        await OtpService.sendOtp(
          phone: '+966500000001',
          onSend: (phone) async {},
        );

        // محاولة أولى فاشلة
        final result1 = await OtpService.verifyOtp(
          phone: '+966500000001',
          otp: 'wrong',
          onVerify: (phone, otp) async => false,
        );
        expect(result1.remainingAttempts, 2);

        // محاولة ثانية فاشلة
        final result2 = await OtpService.verifyOtp(
          phone: '+966500000001',
          otp: 'wrong',
          onVerify: (phone, otp) async => false,
        );
        expect(result2.remainingAttempts, 1);
      });
    });

    group('Resend Cooldown', () {
      test('لا يمكن إعادة الإرسال قبل انتهاء Cooldown', () async {
        await OtpService.sendOtp(
          phone: '+966500000001',
          onSend: (phone) async {},
        );

        final result = await OtpService.resendOtp(
          phone: '+966500000001',
          onSend: (phone) async {},
        );

        expect(result.isSuccess, false);
        expect(result.cooldown, isNotNull);
      });

      test('OtpState.canResend يُرجع false فوراً بعد الإرسال', () async {
        await OtpService.sendOtp(
          phone: '+966500000001',
          onSend: (phone) async {},
        );

        expect(OtpService.currentState!.canResend, false);
      });

      test('OtpState.resendCooldownRemaining يحسب الوقت المتبقي', () async {
        await OtpService.sendOtp(
          phone: '+966500000001',
          onSend: (phone) async {},
        );

        final remaining = OtpService.currentState!.resendCooldownRemaining;
        expect(remaining.inSeconds, greaterThan(0));
        expect(remaining.inSeconds, lessThanOrEqualTo(60));
      });
    });

    group('OTP Expiry', () {
      test('OTP ليس منتهي الصلاحية فوراً بعد الإرسال', () async {
        await OtpService.sendOtp(
          phone: '+966500000001',
          onSend: (phone) async {},
        );

        expect(OtpService.currentState!.isExpired, false);
      });

      test('يحسب الوقت المتبقي للصلاحية بشكل صحيح', () async {
        await OtpService.sendOtp(
          phone: '+966500000001',
          onSend: (phone) async {},
        );

        final remaining = OtpService.currentState!.remainingTime;
        expect(remaining.inMinutes, lessThanOrEqualTo(5));
        expect(remaining.inSeconds, greaterThan(0));
      });
    });

    group('Phone Validation', () {
      test('يقبل أرقام سعودية صحيحة', () async {
        final phones = ['+966500000001', '+966550000001', '+966590000001'];

        for (final phone in phones) {
          await OtpService.reset();
          final result = await OtpService.sendOtp(
            phone: phone,
            onSend: (_) async {},
          );
          expect(result.isSuccess, true, reason: 'فشل مع الرقم: $phone');
        }
      });
    });

    group('Error Handling', () {
      test('يتعامل مع أخطاء API بشكل صحيح', () async {
        final result = await OtpService.sendOtp(
          phone: '+966500000001',
          onSend: (phone) async {
            throw Exception('Network error');
          },
        );

        expect(result.isSuccess, false);
        expect(result.error, isNotNull);
      });

      test('يتعامل مع أخطاء التحقق بشكل صحيح', () async {
        await OtpService.sendOtp(
          phone: '+966500000001',
          onSend: (phone) async {},
        );

        final result = await OtpService.verifyOtp(
          phone: '+966500000001',
          otp: '123456',
          onVerify: (phone, otp) async {
            throw Exception('Server error');
          },
        );

        expect(result.isSuccess, false);
        expect(result.error, isNotNull);
      });
    });
  });
}
