import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_pos/src/services/payment/nfc_listener_service.dart';
import 'package:alhai_pos/src/services/payment/payment_gateway.dart';

// =============================================================================
// Fake PaymentGateway للاختبار
// =============================================================================

class FakePaymentGateway implements PaymentGateway {
  PaymentResult? nextResult;
  Duration processDelay;
  int processCallCount = 0;

  FakePaymentGateway({this.nextResult, this.processDelay = Duration.zero});

  @override
  String get name => 'Fake Gateway';

  @override
  List<PaymentMethod> get supportedMethods => [PaymentMethod.mada];

  @override
  PaymentGatewayStatus get configurationStatus =>
      PaymentGatewayStatus.available;

  @override
  bool get isSimulated => true;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<PaymentResult> processPayment(PaymentRequest request) async {
    processCallCount++;
    if (processDelay > Duration.zero) {
      await Future.delayed(processDelay);
    }
    return nextResult ??
        PaymentResult.success(
          transactionId: 'FAKE-${DateTime.now().millisecondsSinceEpoch}',
        );
  }

  @override
  Future<RefundResult> refund(RefundRequest request) async {
    return RefundResult(
      success: true,
      refundedAmount: request.amount,
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<PaymentStatus> checkStatus(String transactionId) async {
    return PaymentStatus.approved;
  }

  @override
  Future<bool> cancel(String transactionId) async => true;
}

void main() {
  // ==========================================================================
  // NfcConfiguration
  // ==========================================================================

  group('NfcConfiguration', () {
    test('القيم الافتراضية صحيحة', () {
      const config = NfcConfiguration();

      expect(config.timeoutDuration, equals(const Duration(seconds: 30)));
      expect(config.isEnabled, isTrue);
      expect(config.autoActivateOnPayment, isTrue);
    });

    test('defaultConfig يطابق القيم الافتراضية', () {
      expect(
        NfcConfiguration.defaultConfig.timeoutDuration,
        equals(const Duration(seconds: 30)),
      );
      expect(NfcConfiguration.defaultConfig.isEnabled, isTrue);
    });

    test('copyWith يعدّل الحقول المطلوبة فقط', () {
      const original = NfcConfiguration(
        timeoutDuration: Duration(seconds: 30),
        isEnabled: true,
        autoActivateOnPayment: true,
      );

      final modified = original.copyWith(
        timeoutDuration: const Duration(seconds: 60),
        isEnabled: false,
      );

      expect(modified.timeoutDuration, equals(const Duration(seconds: 60)));
      expect(modified.isEnabled, isFalse);
      expect(modified.autoActivateOnPayment, isTrue); // لم يتغير
    });

    test('القيم المخصصة تُحفظ بشكل صحيح', () {
      const config = NfcConfiguration(
        timeoutDuration: Duration(seconds: 10),
        isEnabled: false,
        autoActivateOnPayment: false,
      );

      expect(config.timeoutDuration, equals(const Duration(seconds: 10)));
      expect(config.isEnabled, isFalse);
      expect(config.autoActivateOnPayment, isFalse);
    });
  });

  // ==========================================================================
  // NFC Events - toString
  // ==========================================================================

  group('NfcListenerEvent - toString', () {
    test('NfcCardDetected يعرض cardId', () {
      const event = NfcCardDetected(cardId: 'ABC-123');
      expect(event.toString(), contains('ABC-123'));
    });

    test('NfcCardDetected بدون cardId', () {
      const event = NfcCardDetected();
      expect(event.cardId, isNull);
    });

    test('NfcReading toString', () {
      const event = NfcReading();
      expect(event.toString(), equals('NfcReading()'));
    });

    test('NfcProcessing toString', () {
      const event = NfcProcessing();
      expect(event.toString(), equals('NfcProcessing()'));
    });

    test('NfcTimeout toString', () {
      const event = NfcTimeout();
      expect(event.toString(), equals('NfcTimeout()'));
    });

    test('NfcCancelled toString', () {
      const event = NfcCancelled();
      expect(event.toString(), equals('NfcCancelled()'));
    });

    test('NfcError يعرض الرسالة', () {
      const event = NfcError(message: 'خطأ في القراءة');
      expect(event.toString(), contains('خطأ في القراءة'));
    });

    test('NfcCompleted يعرض حالة النجاح', () {
      final event = NfcCompleted(
        result: PaymentResult.success(transactionId: 'TX-1'),
      );
      expect(event.toString(), contains('true'));
    });

    test('NfcCompleted يعرض حالة الفشل', () {
      final event = NfcCompleted(
        result: PaymentResult.failed(errorType: PaymentErrorType.declined),
      );
      expect(event.toString(), contains('false'));
    });
  });

  // ==========================================================================
  // MockNfcBehavior enum
  // ==========================================================================

  group('MockNfcBehavior', () {
    test('جميع القيم لها اسم عربي', () {
      for (final behavior in MockNfcBehavior.values) {
        expect(behavior.arabicName, isNotEmpty);
      }
    });

    test('يحتوي على 4 سلوكيات', () {
      expect(MockNfcBehavior.values, hasLength(4));
    });
  });

  // ==========================================================================
  // MockNfcListenerService - إنشاء وإعدادات
  // ==========================================================================

  group('MockNfcListenerService - إنشاء', () {
    late FakePaymentGateway gateway;

    setUp(() {
      gateway = FakePaymentGateway();
    });

    test('الإعدادات الافتراضية صحيحة', () {
      final service = MockNfcListenerService(gateway: gateway);

      expect(service.isListening, isFalse);
      expect(service.configuration.isEnabled, isTrue);
      expect(
        service.configuration.timeoutDuration,
        equals(const Duration(seconds: 30)),
      );
      expect(service.behavior, equals(MockNfcBehavior.success));

      service.dispose();
    });

    test('تطبيق إعدادات مخصصة', () {
      const config = NfcConfiguration(
        timeoutDuration: Duration(seconds: 10),
        isEnabled: false,
      );

      final service = MockNfcListenerService(
        gateway: gateway,
        configuration: config,
      );

      expect(
        service.configuration.timeoutDuration,
        equals(const Duration(seconds: 10)),
      );
      expect(service.configuration.isEnabled, isFalse);

      service.dispose();
    });

    test('تحديث الإعدادات عبر setter', () {
      final service = MockNfcListenerService(gateway: gateway);

      service.configuration = const NfcConfiguration(
        timeoutDuration: Duration(seconds: 45),
        isEnabled: true,
      );

      expect(
        service.configuration.timeoutDuration,
        equals(const Duration(seconds: 45)),
      );

      service.dispose();
    });
  });

  // ==========================================================================
  // MockNfcListenerService - تدفق النجاح
  // ==========================================================================

  group('MockNfcListenerService - تدفق النجاح', () {
    late FakePaymentGateway gateway;
    late MockNfcListenerService service;

    setUp(() {
      gateway = FakePaymentGateway(
        nextResult: PaymentResult.success(transactionId: 'TX-SUCCESS'),
      );
      service = MockNfcListenerService(
        gateway: gateway,
        behavior: MockNfcBehavior.success,
        // تأخيرات قصيرة للاختبار
        cardDetectDelay: const Duration(milliseconds: 50),
        readDelay: const Duration(milliseconds: 30),
      );
    });

    tearDown(() {
      service.dispose();
    });

    test(
      'ترتيب الأحداث: detected → reading → processing → completed',
      () async {
        final events = <NfcListenerEvent>[];
        final sub = service.events.listen(events.add);

        await service.startListening(100.0);

        // ننتظر لإكمال المحاكاة
        await Future<void>.delayed(const Duration(milliseconds: 500));

        await sub.cancel();

        // التحقق من الترتيب
        expect(events.length, greaterThanOrEqualTo(4));

        expect(events[0], isA<NfcCardDetected>());
        expect(events[1], isA<NfcReading>());
        expect(events[2], isA<NfcProcessing>());
        expect(events[3], isA<NfcCompleted>());

        // التحقق من نتيجة النجاح
        final completed = events[3] as NfcCompleted;
        expect(completed.result.success, isTrue);
      },
    );

    test('isListening يتغير أثناء التدفق', () async {
      expect(service.isListening, isFalse);

      // نبدأ بدون await لنلتقط الحالة أثناء التنفيذ
      final future = service.startListening(50.0);

      // قبل انتهاء cardDetectDelay يجب أن يكون نشطاً
      expect(service.isListening, isTrue);

      await future;
      await Future<void>.delayed(const Duration(milliseconds: 300));

      // بعد الانتهاء
      expect(service.isListening, isFalse);
    });

    test('البوابة تستقبل الطلب', () async {
      await service.startListening(250.0);
      await Future<void>.delayed(const Duration(milliseconds: 500));

      expect(gateway.processCallCount, equals(1));
    });
  });

  // ==========================================================================
  // MockNfcListenerService - الإلغاء
  // ==========================================================================

  group('MockNfcListenerService - الإلغاء', () {
    late FakePaymentGateway gateway;
    late MockNfcListenerService service;

    setUp(() {
      gateway = FakePaymentGateway();
      service = MockNfcListenerService(
        gateway: gateway,
        behavior: MockNfcBehavior.success,
        cardDetectDelay: const Duration(milliseconds: 500), // تأخير طويل
        readDelay: const Duration(milliseconds: 100),
      );
    });

    tearDown(() {
      service.dispose();
    });

    test('stopListening يرسل حدث NfcCancelled', () async {
      final events = <NfcListenerEvent>[];
      final sub = service.events.listen(events.add);

      // نبدأ الاستماع (بدون await لأننا سنلغي)
      unawaited(service.startListening(100.0));

      // ننتظر لحظة ثم نلغي قبل اكتشاف البطاقة
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await service.stopListening();

      await Future<void>.delayed(const Duration(milliseconds: 50));
      await sub.cancel();

      // يجب أن نجد حدث إلغاء
      expect(events.whereType<NfcCancelled>(), isNotEmpty);
      expect(service.isListening, isFalse);
    });

    test('stopListening عندما لا يكون الاستماع نشطاً لا يفعل شيئاً', () async {
      final events = <NfcListenerEvent>[];
      final sub = service.events.listen(events.add);

      await service.stopListening();

      await Future<void>.delayed(const Duration(milliseconds: 50));
      await sub.cancel();

      expect(events, isEmpty);
    });
  });

  // ==========================================================================
  // MockNfcListenerService - انتهاء المهلة (timeout)
  // ==========================================================================

  group('MockNfcListenerService - انتهاء المهلة', () {
    late FakePaymentGateway gateway;

    setUp(() {
      gateway = FakePaymentGateway();
    });

    test('يرسل NfcTimeout عند انتهاء المهلة', () async {
      final service = MockNfcListenerService(
        gateway: gateway,
        behavior: MockNfcBehavior.timeout,
        configuration: const NfcConfiguration(
          timeoutDuration: Duration(milliseconds: 200),
        ),
      );

      final events = <NfcListenerEvent>[];
      final sub = service.events.listen(events.add);

      unawaited(service.startListening(100.0));

      // ننتظر أكثر من المهلة
      await Future<void>.delayed(const Duration(milliseconds: 400));

      await sub.cancel();
      service.dispose();

      expect(events.whereType<NfcTimeout>(), isNotEmpty);
    });
  });

  // ==========================================================================
  // MockNfcListenerService - بطاقة مرفوضة
  // ==========================================================================

  group('MockNfcListenerService - بطاقة مرفوضة', () {
    late FakePaymentGateway gateway;
    late MockNfcListenerService service;

    setUp(() {
      gateway = FakePaymentGateway();
      service = MockNfcListenerService(
        gateway: gateway,
        behavior: MockNfcBehavior.declined,
        cardDetectDelay: const Duration(milliseconds: 50),
        readDelay: const Duration(milliseconds: 30),
      );
    });

    tearDown(() {
      service.dispose();
    });

    test('ينتهي بـ NfcCompleted مع result.success = false', () async {
      final events = <NfcListenerEvent>[];
      final sub = service.events.listen(events.add);

      await service.startListening(100.0);
      await Future<void>.delayed(const Duration(milliseconds: 500));

      await sub.cancel();

      final completed = events.whereType<NfcCompleted>();
      expect(completed, isNotEmpty);
      expect(completed.first.result.success, isFalse);
    });
  });

  // ==========================================================================
  // MockNfcListenerService - خطأ قراءة
  // ==========================================================================

  group('MockNfcListenerService - خطأ قراءة', () {
    late FakePaymentGateway gateway;
    late MockNfcListenerService service;

    setUp(() {
      gateway = FakePaymentGateway();
      service = MockNfcListenerService(
        gateway: gateway,
        behavior: MockNfcBehavior.readError,
        cardDetectDelay: const Duration(milliseconds: 50),
        readDelay: const Duration(milliseconds: 30),
      );
    });

    tearDown(() {
      service.dispose();
    });

    test('ينتهي بـ NfcError', () async {
      final events = <NfcListenerEvent>[];
      final sub = service.events.listen(events.add);

      await service.startListening(100.0);
      await Future<void>.delayed(const Duration(milliseconds: 500));

      await sub.cancel();

      final errors = events.whereType<NfcError>();
      expect(errors, isNotEmpty);
    });
  });

  // ==========================================================================
  // MockNfcListenerService - حالات حدية
  // ==========================================================================

  group('MockNfcListenerService - حالات حدية', () {
    late FakePaymentGateway gateway;

    setUp(() {
      gateway = FakePaymentGateway();
    });

    test('startListening مرتين لا يبدأ من جديد (يتجاهل الثاني)', () async {
      final service = MockNfcListenerService(
        gateway: gateway,
        behavior: MockNfcBehavior.success,
        cardDetectDelay: const Duration(milliseconds: 300),
        readDelay: const Duration(milliseconds: 50),
      );

      unawaited(service.startListening(100.0));

      // محاولة بدء ثانية
      await service.startListening(200.0);

      // يجب أن تُعالج عملية واحدة فقط
      await Future<void>.delayed(const Duration(milliseconds: 800));

      // البوابة يجب أن تُستدعى مرة واحدة فقط
      expect(gateway.processCallCount, lessThanOrEqualTo(1));

      service.dispose();
    });

    test('startListening بعد dispose لا يفعل شيئاً', () async {
      final service = MockNfcListenerService(
        gateway: gateway,
        behavior: MockNfcBehavior.success,
        cardDetectDelay: const Duration(milliseconds: 50),
        readDelay: const Duration(milliseconds: 30),
      );

      service.dispose();

      // لن يحدث خطأ
      await service.startListening(100.0);

      expect(service.isListening, isFalse);
    });

    test('dispose مرتين لا يسبب خطأ', () {
      final service = MockNfcListenerService(gateway: gateway);

      service.dispose();
      // الاستدعاء الثاني لا يسبب خطأ
      service.dispose();
    });

    test('NFC معطّل في الإعدادات يرسل NfcError', () async {
      final service = MockNfcListenerService(
        gateway: gateway,
        configuration: const NfcConfiguration(isEnabled: false),
      );

      final events = <NfcListenerEvent>[];
      final sub = service.events.listen(events.add);

      await service.startListening(100.0);
      await Future<void>.delayed(const Duration(milliseconds: 100));

      await sub.cancel();
      service.dispose();

      expect(events.whereType<NfcError>(), isNotEmpty);
      expect(service.isListening, isFalse);
    });

    test('isAvailable يتبع isEnabled في الإعدادات', () async {
      final service = MockNfcListenerService(
        gateway: gateway,
        configuration: const NfcConfiguration(isEnabled: true),
      );

      // في وضع debug يجب أن يكون متاحاً
      final available = await service.isAvailable;
      expect(available, isTrue);

      service.configuration = const NfcConfiguration(isEnabled: false);
      final notAvailable = await service.isAvailable;
      expect(notAvailable, isFalse);

      service.dispose();
    });
  });

  // ==========================================================================
  // MockNfcListenerService - events stream
  // ==========================================================================

  group('MockNfcListenerService - events stream', () {
    test('events هو broadcast stream', () {
      final gateway = FakePaymentGateway();
      final service = MockNfcListenerService(gateway: gateway);

      // يجب أن يقبل عدة مستمعين
      final sub1 = service.events.listen((_) {});
      final sub2 = service.events.listen((_) {});

      // لا خطأ = broadcast يعمل
      sub1.cancel();
      sub2.cancel();
      service.dispose();
    });
  });
}
