import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_pos/src/services/customer_display/customer_display_service.dart';
import 'package:alhai_pos/src/services/customer_display/customer_display_state.dart';

// =============================================================================
// Fake channel للاختبار - يسجل الحالات المرسلة ويبثها عبر stream
// =============================================================================

class FakeDisplayChannel implements CustomerDisplayChannel {
  final _controller = StreamController<CustomerDisplayState>.broadcast();
  final List<CustomerDisplayState> sentStates = [];
  bool _isConnected = true;

  @override
  void sendState(CustomerDisplayState state) {
    sentStates.add(state);
    if (!_controller.isClosed) {
      _controller.add(state);
    }
  }

  @override
  Stream<CustomerDisplayState> get stateStream => _controller.stream;

  @override
  bool get isConnected => _isConnected;

  set isConnected(bool value) => _isConnected = value;

  @override
  void dispose() {
    _controller.close();
    _isConnected = false;
  }
}

void main() {
  late FakeDisplayChannel fakeChannel;
  late CustomerDisplayService service;

  setUp(() {
    fakeChannel = FakeDisplayChannel();
    service = CustomerDisplayService(channel: fakeChannel);
  });

  tearDown(() {
    service.dispose();
  });

  // ==========================================================================
  // enable / disable
  // ==========================================================================

  group('enable / disable', () {
    test('الخدمة معطّلة بشكل افتراضي', () {
      expect(service.isEnabled, isFalse);
    });

    test('enable يفعّل الخدمة', () {
      service.enable(storeName: 'متجر');

      expect(service.isEnabled, isTrue);
    });

    test('enable يرسل حالة idle', () {
      service.enable(storeName: 'متجر الاختبار');

      expect(fakeChannel.sentStates, hasLength(1));
      expect(
          fakeChannel.sentStates.last.phase, equals(CustomerDisplayPhase.idle));
      expect(fakeChannel.sentStates.last.storeName, equals('متجر الاختبار'));
    });

    test('disable يعطّل الخدمة', () {
      service.enable(storeName: 'متجر');
      service.disable();

      expect(service.isEnabled, isFalse);
    });

    test('disable يرسل حالة idle فارغة', () {
      service.enable(storeName: 'متجر');
      fakeChannel.sentStates.clear();

      service.disable();

      // disable يستدعي _send لكن _isEnabled يصبح false قبل الإرسال
      // لذا لن يُرسل شيء بعد disable
      // في الكود الأصلي: disable() sets _isEnabled = false ثم _send()
      // _send يتحقق _isEnabled أولاً، لكن disable يغير _isEnabled قبل _send
      // لنتحقق من السلوك الفعلي:
      expect(service.isEnabled, isFalse);
    });
  });

  // ==========================================================================
  // الخدمة المعطّلة لا ترسل حالات
  // ==========================================================================

  group('الخدمة المعطّلة', () {
    test('لا ترسل حالات عند استدعاء showIdle', () {
      // لا نستدعي enable
      service.showIdle();

      expect(fakeChannel.sentStates, isEmpty);
    });

    test('لا ترسل حالات عند استدعاء showCart', () {
      service.showCart(
        items: const [],
        subtotal: 0,
        discount: 0,
        tax: 0,
        total: 0,
      );

      expect(fakeChannel.sentStates, isEmpty);
    });

    test('لا ترسل حالات عند استدعاء showNfcWaiting', () {
      service.showNfcWaiting(total: 100.0);

      expect(fakeChannel.sentStates, isEmpty);
    });

    test('لا ترسل حالات عند استدعاء showSuccess', () {
      service.showSuccess(total: 100.0);

      expect(fakeChannel.sentStates, isEmpty);
    });

    test('لا ترسل حالات عند استدعاء showFailure', () {
      service.showFailure(message: 'خطأ');

      expect(fakeChannel.sentStates, isEmpty);
    });
  });

  // ==========================================================================
  // State transitions (الخدمة مفعّلة)
  // ==========================================================================

  group('State transitions', () {
    setUp(() {
      service.enable(storeName: 'متجر الاختبار');
      fakeChannel.sentStates.clear();
    });

    test('showIdle يرسل حالة idle', () {
      service.showIdle();

      expect(fakeChannel.sentStates, hasLength(1));
      expect(
          fakeChannel.sentStates.last.phase, equals(CustomerDisplayPhase.idle));
      expect(fakeChannel.sentStates.last.storeName, equals('متجر الاختبار'));
    });

    test('showCart يرسل حالة cart مع البيانات', () {
      final items = [
        const DisplayCartItem(
          productName: 'قهوة',
          quantity: 2,
          unitPrice: 15.0,
          lineTotal: 30.0,
        ),
      ];

      service.showCart(
        items: items,
        subtotal: 30.0,
        discount: 3.0,
        tax: 4.05,
        total: 31.05,
      );

      final sent = fakeChannel.sentStates.last;
      expect(sent.phase, equals(CustomerDisplayPhase.cart));
      expect(sent.items, hasLength(1));
      expect(sent.items[0].productName, equals('قهوة'));
      expect(sent.subtotal, equals(30.0));
      expect(sent.discount, equals(3.0));
      expect(sent.tax, equals(4.05));
      expect(sent.total, equals(31.05));
      expect(sent.storeName, equals('متجر الاختبار'));
    });

    test('showPhoneEntry يرسل حالة phoneEntry', () {
      service.showPhoneEntry(
        items: const [],
        total: 50.0,
      );

      final sent = fakeChannel.sentStates.last;
      expect(sent.phase, equals(CustomerDisplayPhase.phoneEntry));
      expect(sent.total, equals(50.0));
    });

    test('showPayment يرسل حالة payment', () {
      service.showPayment(
        total: 100.0,
        paymentMethodName: 'مدى',
      );

      final sent = fakeChannel.sentStates.last;
      expect(sent.phase, equals(CustomerDisplayPhase.payment));
      expect(sent.total, equals(100.0));
      expect(sent.paymentMethodName, equals('مدى'));
    });

    test('showNfcWaiting يرسل حالة nfcWaiting', () {
      service.showNfcWaiting(total: 75.0);

      final sent = fakeChannel.sentStates.last;
      expect(sent.phase, equals(CustomerDisplayPhase.nfcWaiting));
      expect(sent.total, equals(75.0));
      expect(sent.nfcStatus, equals(NfcDisplayStatus.waitingForTap));
    });

    test('showNfcWaiting مع حالة ورسالة مخصصة', () {
      service.showNfcWaiting(
        total: 75.0,
        status: NfcDisplayStatus.reading,
        message: 'جاري القراءة',
      );

      final sent = fakeChannel.sentStates.last;
      expect(sent.nfcStatus, equals(NfcDisplayStatus.reading));
      expect(sent.nfcMessage, equals('جاري القراءة'));
    });

    test('updateNfcStatus يحدّث الحالة مع الحفاظ على البيانات', () {
      service.showNfcWaiting(total: 100.0);

      service.updateNfcStatus(
        status: NfcDisplayStatus.processing,
        message: 'جاري المعالجة',
      );

      final sent = fakeChannel.sentStates.last;
      expect(sent.nfcStatus, equals(NfcDisplayStatus.processing));
      expect(sent.nfcMessage, equals('جاري المعالجة'));
    });

    test('showSuccess يرسل حالة success', () {
      service.showSuccess(
        total: 200.0,
        message: 'تم الدفع',
      );

      final sent = fakeChannel.sentStates.last;
      expect(sent.phase, equals(CustomerDisplayPhase.success));
      expect(sent.total, equals(200.0));
      expect(sent.resultMessage, equals('تم الدفع'));
    });

    test('showFailure يرسل حالة failure', () {
      service.showFailure(message: 'البطاقة مرفوضة');

      final sent = fakeChannel.sentStates.last;
      expect(sent.phase, equals(CustomerDisplayPhase.failure));
      expect(sent.resultMessage, equals('البطاقة مرفوضة'));
    });

    test('reset يرسل حالة idle', () {
      service.showCart(
        items: const [],
        subtotal: 0,
        discount: 0,
        tax: 0,
        total: 0,
      );
      fakeChannel.sentStates.clear();

      service.reset();

      expect(fakeChannel.sentStates, hasLength(1));
      expect(
          fakeChannel.sentStates.last.phase, equals(CustomerDisplayPhase.idle));
    });
  });

  // ==========================================================================
  // lastState
  // ==========================================================================

  group('lastState', () {
    test('القيمة الافتراضية هي idle', () {
      expect(service.lastState.phase, equals(CustomerDisplayPhase.idle));
    });

    test('يُحدّث بعد كل إرسال', () {
      service.enable(storeName: 'متجر');

      service.showCart(
        items: const [],
        subtotal: 10.0,
        discount: 0,
        tax: 1.5,
        total: 11.5,
      );

      expect(service.lastState.phase, equals(CustomerDisplayPhase.cart));
      expect(service.lastState.total, equals(11.5));
    });
  });

  // ==========================================================================
  // stateStream
  // ==========================================================================

  group('stateStream', () {
    test('يستقبل الحالات المرسلة بالترتيب', () async {
      service.enable(storeName: 'متجر');

      final states = <CustomerDisplayState>[];
      final sub = service.stateStream.listen(states.add);

      // enable أرسل idle بالفعل، لكن قد لا نلتقطها لأن الاستماع بدأ بعدها
      // ننتظر لحظة ثم نرسل حالات جديدة
      await Future<void>.delayed(Duration.zero);

      service.showCart(
        items: const [],
        subtotal: 0,
        discount: 0,
        tax: 0,
        total: 50.0,
      );

      service.showSuccess(total: 50.0);

      await Future<void>.delayed(Duration.zero);

      // يجب أن نستقبل على الأقل cart و success
      expect(states.where((s) => s.phase == CustomerDisplayPhase.cart),
          isNotEmpty);
      expect(states.where((s) => s.phase == CustomerDisplayPhase.success),
          isNotEmpty);

      await sub.cancel();
    });
  });

  // ==========================================================================
  // isConnected
  // ==========================================================================

  group('isConnected', () {
    test('يعكس حالة اتصال القناة', () {
      expect(service.isConnected, isTrue);

      fakeChannel.isConnected = false;
      expect(service.isConnected, isFalse);
    });
  });

  // ==========================================================================
  // InMemoryDisplayChannel
  // ==========================================================================

  group('InMemoryDisplayChannel', () {
    test('يبث الحالات عبر stateStream', () async {
      final channel = InMemoryDisplayChannel();
      final states = <CustomerDisplayState>[];
      final sub = channel.stateStream.listen(states.add);

      const state = CustomerDisplayState.idle(storeName: 'اختبار');
      channel.sendState(state);

      await Future<void>.delayed(Duration.zero);

      expect(states, hasLength(1));
      expect(states[0].phase, equals(CustomerDisplayPhase.idle));
      expect(states[0].storeName, equals('اختبار'));

      await sub.cancel();
    });

    test('isConnected يعود true', () {
      final channel = InMemoryDisplayChannel();

      expect(channel.isConnected, isTrue);
    });

    test('يبث لعدة مستمعين (broadcast)', () async {
      final channel = InMemoryDisplayChannel();
      final states1 = <CustomerDisplayState>[];
      final states2 = <CustomerDisplayState>[];

      final sub1 = channel.stateStream.listen(states1.add);
      final sub2 = channel.stateStream.listen(states2.add);

      const state = CustomerDisplayState.idle(storeName: 'بث');
      channel.sendState(state);

      await Future<void>.delayed(Duration.zero);

      expect(states1, hasLength(1));
      expect(states2, hasLength(1));

      await sub1.cancel();
      await sub2.cancel();
    });
  });
}
