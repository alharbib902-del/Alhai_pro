/// NFC Listener Service - خدمة الاستماع لبطاقات NFC
///
/// يوفر:
/// - استماع تلقائي عند فتح شاشة الدفع (ليس طريقة دفع منفصلة)
/// - تمرير البطاقة المكتشفة إلى MadaPaymentGateway للمعالجة
/// - بث أحداث القراءة والمعالجة عبر Stream
/// - محاكاة في وضع التطوير فقط
library;

import 'dart:async';

import 'package:flutter/foundation.dart';

import 'payment_gateway.dart';

// ============================================================================
// NFC CONFIGURATION
// ============================================================================

/// إعدادات مستمع NFC
class NfcConfiguration {
  /// مهلة الانتظار قبل انتهاء الوقت
  final Duration timeoutDuration;

  /// هل NFC مفعّل
  final bool isEnabled;

  /// تفعيل تلقائي عند فتح شاشة الدفع
  final bool autoActivateOnPayment;

  const NfcConfiguration({
    this.timeoutDuration = const Duration(seconds: 30),
    this.isEnabled = true,
    this.autoActivateOnPayment = true,
  });

  /// إعدادات افتراضية
  static const NfcConfiguration defaultConfig = NfcConfiguration();

  /// نسخة معدّلة
  NfcConfiguration copyWith({
    Duration? timeoutDuration,
    bool? isEnabled,
    bool? autoActivateOnPayment,
  }) {
    return NfcConfiguration(
      timeoutDuration: timeoutDuration ?? this.timeoutDuration,
      isEnabled: isEnabled ?? this.isEnabled,
      autoActivateOnPayment:
          autoActivateOnPayment ?? this.autoActivateOnPayment,
    );
  }
}

// ============================================================================
// NFC LISTENER EVENTS
// ============================================================================

/// أحداث مستمع NFC
sealed class NfcListenerEvent {
  const NfcListenerEvent();
}

/// تم اكتشاف بطاقة
class NfcCardDetected extends NfcListenerEvent {
  /// معرّف البطاقة (إن توفّر)
  final String? cardId;

  const NfcCardDetected({this.cardId});

  @override
  String toString() => 'NfcCardDetected(cardId: $cardId)';
}

/// جارٍ قراءة بيانات البطاقة
class NfcReading extends NfcListenerEvent {
  const NfcReading();

  @override
  String toString() => 'NfcReading()';
}

/// جارٍ إرسال البيانات إلى بوابة الدفع
class NfcProcessing extends NfcListenerEvent {
  const NfcProcessing();

  @override
  String toString() => 'NfcProcessing()';
}

/// اكتملت العملية (نجاح أو فشل)
class NfcCompleted extends NfcListenerEvent {
  /// نتيجة الدفع من البوابة
  final PaymentResult result;

  const NfcCompleted({required this.result});

  @override
  String toString() => 'NfcCompleted(success: ${result.success})';
}

/// خطأ في الأجهزة أو القراءة
class NfcError extends NfcListenerEvent {
  /// رسالة الخطأ
  final String message;

  const NfcError({required this.message});

  @override
  String toString() => 'NfcError(message: $message)';
}

/// انتهت المهلة بدون اكتشاف بطاقة
class NfcTimeout extends NfcListenerEvent {
  const NfcTimeout();

  @override
  String toString() => 'NfcTimeout()';
}

/// ألغى المستخدم الاستماع
class NfcCancelled extends NfcListenerEvent {
  const NfcCancelled();

  @override
  String toString() => 'NfcCancelled()';
}

// ============================================================================
// NFC LISTENER SERVICE (ABSTRACT)
// ============================================================================

/// خدمة الاستماع لبطاقات NFC
///
/// تعمل كمستمع خلفي (ليست طريقة دفع منفصلة):
/// - تُفعّل تلقائياً عند فتح شاشة الدفع
/// - عند اكتشاف بطاقة، تُمرَّر إلى [PaymentGateway] للمعالجة
/// - تبث الأحداث عبر [events] لتحديث واجهة المستخدم
abstract class NfcListenerService {
  /// بث أحداث NFC
  Stream<NfcListenerEvent> get events;

  /// هل الجهاز يدعم NFC
  Future<bool> get isAvailable;

  /// هل المستمع نشط حالياً
  bool get isListening;

  /// الإعدادات الحالية
  NfcConfiguration get configuration;

  /// تحديث الإعدادات
  set configuration(NfcConfiguration config);

  /// بدء الاستماع لمبلغ محدد
  ///
  /// يُفعّل قارئ NFC وينتظر تقريب بطاقة.
  /// عند اكتشاف بطاقة، يُعالج الدفع تلقائياً عبر البوابة.
  /// ينتهي عند: نجاح/فشل الدفع، انتهاء المهلة، أو الإلغاء.
  Future<void> startListening(double amount);

  /// إيقاف الاستماع
  Future<void> stopListening();

  /// تحرير الموارد
  void dispose();
}

// ============================================================================
// MOCK NFC LISTENER (DEVELOPMENT ONLY)
// ============================================================================

/// سلوك المحاكاة
enum MockNfcBehavior {
  /// نجاح بعد تأخير
  success('نجاح'),

  /// فشل - بطاقة مرفوضة
  declined('مرفوض'),

  /// انتهاء المهلة
  timeout('انتهاء المهلة'),

  /// خطأ في القراءة
  readError('خطأ قراءة');

  final String arabicName;
  const MockNfcBehavior(this.arabicName);
}

/// محاكاة خدمة NFC (وضع التطوير فقط)
///
/// تُحاكي تدفق قراءة البطاقة مع تأخيرات واقعية.
/// لا تعمل في وضع الإنتاج ([kReleaseMode]).
///
/// TODO: تكامل الإنتاج - Flutter NFC plugin
///   الخطوات المطلوبة:
///   1. إضافة nfc_manager إلى pubspec.yaml
///   2. إنشاء RealNfcListenerService يستخدم NfcManager
///   3. ربط قراءة البطاقة بـ MadaPaymentGateway.processPayment
///   4. إضافة أذونات NFC في AndroidManifest.xml و Info.plist
class MockNfcListenerService implements NfcListenerService {
  final PaymentGateway _gateway;
  final StreamController<NfcListenerEvent> _eventController =
      StreamController<NfcListenerEvent>.broadcast();

  NfcConfiguration _configuration;
  bool _isListening = false;
  bool _isDisposed = false;
  Timer? _timeoutTimer;
  Completer<void>? _listeningCompleter;

  /// سلوك المحاكاة القابل للتعديل
  MockNfcBehavior behavior;

  /// تأخير اكتشاف البطاقة (محاكاة وقت تقريب البطاقة)
  Duration cardDetectDelay;

  /// تأخير القراءة (محاكاة وقت قراءة البطاقة)
  Duration readDelay;

  MockNfcListenerService({
    required PaymentGateway gateway,
    NfcConfiguration? configuration,
    this.behavior = MockNfcBehavior.success,
    this.cardDetectDelay = const Duration(milliseconds: 1500),
    this.readDelay = const Duration(milliseconds: 800),
  })  : _gateway = gateway,
        _configuration = configuration ?? NfcConfiguration.defaultConfig {
    // التأكد من أن المحاكاة تعمل في وضع التطوير فقط
    if (kReleaseMode) {
      debugPrint('[NFC] تحذير: محاكاة NFC لا تعمل في وضع الإنتاج');
    }
  }

  @override
  Stream<NfcListenerEvent> get events => _eventController.stream;

  @override
  Future<bool> get isAvailable async {
    // المحاكاة متاحة فقط في وضع التطوير
    if (kReleaseMode) return false;
    return _configuration.isEnabled;
  }

  @override
  bool get isListening => _isListening;

  @override
  NfcConfiguration get configuration => _configuration;

  @override
  set configuration(NfcConfiguration config) {
    _configuration = config;
    debugPrint('[NFC] تم تحديث الإعدادات');
  }

  @override
  Future<void> startListening(double amount) async {
    if (_isDisposed) {
      debugPrint('[NFC] الخدمة متوقفة - لا يمكن بدء الاستماع');
      return;
    }

    if (_isListening) {
      debugPrint('[NFC] الاستماع نشط بالفعل');
      return;
    }

    // لا تعمل في وضع الإنتاج
    if (kReleaseMode) {
      debugPrint('[NFC] محاكاة NFC معطّلة في وضع الإنتاج');
      _emitEvent(const NfcError(message: 'NFC غير متاح في هذا الوضع'));
      return;
    }

    if (!_configuration.isEnabled) {
      debugPrint('[NFC] NFC معطّل في الإعدادات');
      _emitEvent(const NfcError(message: 'NFC معطّل في الإعدادات'));
      return;
    }

    debugPrint('[NFC] بدء الاستماع - المبلغ: $amount SAR');
    _isListening = true;
    _listeningCompleter = Completer<void>();

    // بدء مؤقت المهلة
    _startTimeoutTimer();

    // محاكاة التدفق
    await _simulateFlow(amount);
  }

  @override
  Future<void> stopListening() async {
    if (!_isListening) return;

    debugPrint('[NFC] إيقاف الاستماع');
    _cancelTimeoutTimer();
    _isListening = false;

    _emitEvent(const NfcCancelled());

    if (_listeningCompleter != null && !_listeningCompleter!.isCompleted) {
      _listeningCompleter!.complete();
    }
    _listeningCompleter = null;
  }

  @override
  void dispose() {
    if (_isDisposed) return;

    debugPrint('[NFC] تحرير موارد NFC');
    _isDisposed = true;
    _isListening = false;
    _cancelTimeoutTimer();

    if (_listeningCompleter != null && !_listeningCompleter!.isCompleted) {
      _listeningCompleter!.complete();
    }
    _listeningCompleter = null;

    _eventController.close();
  }

  // --------------------------------------------------------------------------
  // PRIVATE HELPERS
  // --------------------------------------------------------------------------

  /// بث حدث مع حماية من البث بعد الإغلاق
  void _emitEvent(NfcListenerEvent event) {
    if (_isDisposed) return;
    debugPrint('[NFC] حدث: $event');
    _eventController.add(event);
  }

  /// بدء مؤقت المهلة
  void _startTimeoutTimer() {
    _cancelTimeoutTimer();
    _timeoutTimer = Timer(_configuration.timeoutDuration, () {
      if (_isListening && !_isDisposed) {
        debugPrint('[NFC] انتهت المهلة');
        _isListening = false;
        _emitEvent(const NfcTimeout());

        if (_listeningCompleter != null && !_listeningCompleter!.isCompleted) {
          _listeningCompleter!.complete();
        }
        _listeningCompleter = null;
      }
    });
  }

  /// إلغاء مؤقت المهلة
  void _cancelTimeoutTimer() {
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
  }

  /// محاكاة تدفق قراءة البطاقة ومعالجة الدفع
  Future<void> _simulateFlow(double amount) async {
    try {
      // التحقق من السلوك المطلوب قبل البدء
      if (behavior == MockNfcBehavior.timeout) {
        // في حالة محاكاة انتهاء المهلة، ننتظر حتى ينتهي المؤقت
        debugPrint('[NFC] محاكاة: انتظار انتهاء المهلة...');
        return;
      }

      // محاكاة: انتظار تقريب البطاقة
      await Future.delayed(cardDetectDelay);
      if (!_isListening || _isDisposed) return;

      // اكتشاف البطاقة
      _cancelTimeoutTimer();
      _emitEvent(NfcCardDetected(
        cardId: 'SIM-${DateTime.now().millisecondsSinceEpoch}',
      ));

      // محاكاة: قراءة البطاقة
      await Future.delayed(readDelay);
      if (!_isListening || _isDisposed) return;
      _emitEvent(const NfcReading());

      // التحقق من خطأ القراءة
      if (behavior == MockNfcBehavior.readError) {
        _isListening = false;
        _emitEvent(const NfcError(message: 'فشل في قراءة بيانات البطاقة'));
        _completeListing();
        return;
      }

      // إرسال إلى بوابة الدفع
      await Future.delayed(const Duration(milliseconds: 500));
      if (!_isListening || _isDisposed) return;
      _emitEvent(const NfcProcessing());

      // إنشاء طلب الدفع ومعالجته عبر البوابة
      final request = PaymentRequest(
        orderId: 'NFC-${DateTime.now().millisecondsSinceEpoch}',
        amount: amount,
        method: PaymentMethod.mada,
        metadata: {
          'source': 'nfc_tap',
          '_simulated': true,
        },
      );

      PaymentResult result;

      if (behavior == MockNfcBehavior.declined) {
        // محاكاة: رفض البطاقة
        result = PaymentResult.failed(
          errorType: PaymentErrorType.declined,
          errorMessage: 'البطاقة مرفوضة',
          rawResponse: {'_simulated': true},
        );
      } else {
        // معالجة الدفع عبر البوابة
        result = await _gateway.processPayment(request);
      }

      if (!_isListening || _isDisposed) return;

      _isListening = false;
      _emitEvent(NfcCompleted(result: result));
      _completeListing();
    } catch (e) {
      debugPrint('[NFC] خطأ في المحاكاة: $e');
      if (_isListening && !_isDisposed) {
        _isListening = false;
        _emitEvent(NfcError(message: 'خطأ غير متوقع: $e'));
        _completeListing();
      }
    }
  }

  /// إكمال عملية الاستماع
  void _completeListing() {
    if (_listeningCompleter != null && !_listeningCompleter!.isCompleted) {
      _listeningCompleter!.complete();
    }
    _listeningCompleter = null;
  }
}
