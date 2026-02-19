import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/security/otp_service.dart';
import 'package:pos_app/core/security/secure_storage_service.dart';

void main() {
  group('OtpService Tests', () {
    setUp(() async {
      // Use in-memory storage for testing
      SecureStorageService.setStorage(InMemoryStorage());
      await OtpService.reset();
    });

    tearDown(() {
      SecureStorageService.resetStorage();
    });

    group('sendOtp', () {
      test('should send OTP successfully', () async {
        bool apiCalled = false;
        
        final result = await OtpService.sendOtp(
          phone: '+966500000001',
          onSend: (phone) async {
            apiCalled = true;
          },
        );
        
        expect(result.isSuccess, true);
        expect(apiCalled, true);
        expect(OtpService.currentState, isNotNull);
        expect(OtpService.currentState!.phone, '+966500000001');
      });

      test('should set correct expiry time', () async {
        await OtpService.sendOtp(
          phone: '+966500000001',
          onSend: (phone) async {},
        );
        
        final state = OtpService.currentState!;
        
        // يجب أن تكون الصلاحية 5 دقائق
        final expectedExpiry = state.sentAt.add(kOtpExpiry);
        expect(state.expiresAt.difference(expectedExpiry).inSeconds.abs(), lessThan(2));
      });

      test('should handle API errors', () async {
        final result = await OtpService.sendOtp(
          phone: '+966500000001',
          onSend: (phone) async {
            throw Exception('API Error');
          },
        );
        
        expect(result.isSuccess, false);
        expect(result.error, contains('Error'));
      });
    });

    group('verifyOtp', () {
      test('should verify OTP successfully', () async {
        await OtpService.sendOtp(
          phone: '+966500000001',
          onSend: (phone) async {},
        );
        
        final result = await OtpService.verifyOtp(
          phone: '+966500000001',
          otp: '123456',
          onVerify: (phone, otp) async => true,
        );
        
        expect(result.isSuccess, true);
      });

      test('should fail for invalid OTP', () async {
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
        expect(result.error, contains('غير صحيح'));
        expect(result.remainingAttempts, isNotNull);
      });

      test('should fail when no OTP sent', () async {
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
      test('should block after max attempts', () async {
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
        expect(result.error, contains('الانتظار'));
      });

      test('should track remaining attempts', () async {
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

    group('Resend', () {
      test('should not allow resend before cooldown', () async {
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
    });

    group('OtpState', () {
      test('should calculate remaining time correctly', () async {
        await OtpService.sendOtp(
          phone: '+966500000001',
          onSend: (phone) async {},
        );
        
        final state = OtpService.currentState!;
        
        // يجب أن يكون الوقت المتبقي أقل من 5 دقائق
        expect(state.remainingTime.inMinutes, lessThanOrEqualTo(5));
        expect(state.remainingTime.inSeconds, greaterThan(0));
      });

      test('should not be expired immediately after sending', () async {
        await OtpService.sendOtp(
          phone: '+966500000001',
          onSend: (phone) async {},
        );
        
        expect(OtpService.currentState!.isExpired, false);
      });
    });
  });
}
