import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:driver_app/core/providers/app_providers.dart';
import 'package:driver_app/features/deliveries/data/pickup_otp_service.dart';
import 'package:driver_app/features/deliveries/screens/pickup_otp_screen.dart';

// ─── Mocks ──────────────────────────────────────────────────────────────────

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockUser extends Mock implements User {}

void main() {
  // ─── PickupOtpService unit tests ──────────────────────────────────────────
  // Note: SupabaseClient.rpc() returns PostgrestFilterBuilder (not Future),
  // so we can only test error paths via thenThrow. Success paths require
  // integration testing with a real Supabase instance.

  group('PickupOtpService — error handling', () {
    late MockSupabaseClient mockClient;

    setUp(() {
      mockClient = MockSupabaseClient();
    });

    test('requestOtp throws OtpNotAvailableException on RPC 42883', () {
      when(
        () => mockClient.rpc(
          'request_pickup_otp',
          params: {'order_id': 'order-1'},
        ),
      ).thenThrow(
        PostgrestException(message: 'function does not exist', code: '42883'),
      );

      final service = PickupOtpService(mockClient);

      expect(
        () => service.requestOtp('order-1'),
        throwsA(isA<OtpNotAvailableException>()),
      );
    });

    test('verifyOtp throws OtpNotAvailableException on RPC 42883', () {
      when(
        () => mockClient.rpc(
          'verify_pickup_otp',
          params: {'order_id': 'order-1', 'otp_code': '1234'},
        ),
      ).thenThrow(
        PostgrestException(message: 'function does not exist', code: '42883'),
      );

      final service = PickupOtpService(mockClient);

      expect(
        () => service.verifyOtp(orderId: 'order-1', otpCode: '1234'),
        throwsA(isA<OtpNotAvailableException>()),
      );
    });

    test('verifyOtp with wrong code maps to OtpVerificationException', () {
      when(
        () => mockClient.rpc(
          'verify_pickup_otp',
          params: {'order_id': 'order-1', 'otp_code': '9999'},
        ),
      ).thenThrow(PostgrestException(message: 'invalid code', code: 'P0001'));

      final service = PickupOtpService(mockClient);

      expect(
        () => service.verifyOtp(orderId: 'order-1', otpCode: '9999'),
        throwsA(isA<OtpVerificationException>()),
      );
    });

    test('verifyOtp with max attempts throws locked exception', () {
      when(
        () => mockClient.rpc(
          'verify_pickup_otp',
          params: {'order_id': 'order-1', 'otp_code': '0000'},
        ),
      ).thenThrow(
        PostgrestException(message: 'max_attempts exceeded', code: 'P0001'),
      );

      final service = PickupOtpService(mockClient);

      expect(
        () => service.verifyOtp(orderId: 'order-1', otpCode: '0000'),
        throwsA(
          isA<OtpVerificationException>().having(
            (e) => e.isLocked,
            'isLocked',
            isTrue,
          ),
        ),
      );
    });

    test('verifyOtp with expired OTP throws appropriate error', () {
      when(
        () => mockClient.rpc(
          'verify_pickup_otp',
          params: {'order_id': 'order-1', 'otp_code': '1234'},
        ),
      ).thenThrow(PostgrestException(message: 'OTP expired', code: 'P0001'));

      final service = PickupOtpService(mockClient);

      expect(
        () => service.verifyOtp(orderId: 'order-1', otpCode: '1234'),
        throwsA(
          isA<OtpVerificationException>().having(
            (e) => e.message,
            'message',
            contains('صلاحية'),
          ),
        ),
      );
    });
  });

  // ─── PickupOtpScreen widget tests ─────────────────────────────────────────

  group('PickupOtpScreen', () {
    late MockSupabaseClient mockClient;
    late MockGoTrueClient mockAuth;
    late MockUser mockUser;

    setUp(() {
      mockClient = MockSupabaseClient();
      mockAuth = MockGoTrueClient();
      mockUser = MockUser();

      when(() => mockClient.auth).thenReturn(mockAuth);
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.id).thenReturn('driver-001');
    });

    Widget buildTestWidget({VoidCallback? onVerified}) {
      return ProviderScope(
        overrides: [supabaseClientProvider.overrideWithValue(mockClient)],
        child: MaterialApp(
          theme: AlhaiTheme.light,
          locale: const Locale('ar'),
          supportedLocales: const [Locale('ar'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: PickupOtpScreen(
            orderId: 'order-001',
            onVerified: onVerified ?? () {},
          ),
        ),
      );
    }

    testWidgets('shows request OTP button initially', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('طلب رمز التحقق'), findsOneWidget);
      expect(find.text('اطلب من صاحب المتجر رمز التحقق'), findsOneWidget);
    });

    testWidgets('shows error when RPC not available', (tester) async {
      when(
        () => mockClient.rpc(
          'request_pickup_otp',
          params: {'order_id': 'order-001'},
        ),
      ).thenThrow(
        PostgrestException(message: 'function does not exist', code: '42883'),
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      await tester.tap(find.text('طلب رمز التحقق'));
      await tester.pumpAndSettle();

      expect(
        find.text('خاصية التحقق غير مفعّلة بعد. يرجى التواصل مع الدعم.'),
        findsOneWidget,
      );
    });

    testWidgets('dev skip button visible in debug mode', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // kDebugMode is true in test environment.
      expect(find.text('[DEV] تخطي التحقق'), findsOneWidget);

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('dev skip button calls onVerified', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      bool verified = false;
      await tester.pumpWidget(
        buildTestWidget(onVerified: () => verified = true),
      );
      await tester.pump();

      await tester.tap(find.text('[DEV] تخطي التحقق'));
      await tester.pump();

      expect(verified, isTrue);

      debugDefaultTargetPlatformOverride = null;
    });
  });

  // ─── Exception types ──────────────────────────────────────────────────────

  group('OTP exception types', () {
    test('OtpNotAvailableException has user-friendly message', () {
      final e = OtpNotAvailableException();
      expect(e.message, contains('غير مفعّلة'));
      expect(e.toString(), contains('غير مفعّلة'));
    });

    test('OtpVerificationException carries metadata', () {
      final e = OtpVerificationException(
        'رمز خاطئ',
        attemptsRemaining: 2,
        isLocked: false,
      );
      expect(e.message, 'رمز خاطئ');
      expect(e.attemptsRemaining, 2);
      expect(e.isLocked, isFalse);
    });

    test('OtpVerificationException locked state', () {
      final e = OtpVerificationException('تم القفل', isLocked: true);
      expect(e.isLocked, isTrue);
    });
  });
}
