/// Payment Gateway - بوابات الدفع الإلكتروني
///
/// يوفر:
/// - واجهة موحدة لجميع بوابات الدفع
/// - دعم مدى، Apple Pay، STC Pay، تمارا
/// - معالجة الأخطاء والاسترجاع
/// - تتبع حالة التهيئة لكل بوابة
library payment_gateway;

import 'package:flutter/foundation.dart';

// ============================================================================
// PAYMENT TYPES & ENUMS
// ============================================================================

/// طريقة الدفع
enum PaymentMethod {
  cash('نقدي', 'cash'),
  card('بطاقة', 'card'),
  mada('مدى', 'mada'),
  visa('فيزا', 'visa'),
  mastercard('ماستركارد', 'mastercard'),
  applePay('Apple Pay', 'apple_pay'),
  stcPay('STC Pay', 'stc_pay'),
  tamara('تمارا', 'tamara'),
  tabby('تابي', 'tabby'),
  wallet('محفظة', 'wallet');

  final String arabicName;
  final String code;
  const PaymentMethod(this.arabicName, this.code);

  bool get isElectronic => this != PaymentMethod.cash;
  bool get requiresTerminal =>
      [mada, visa, mastercard, applePay].contains(this);
  bool get isBNPL => [tamara, tabby].contains(this); // Buy Now Pay Later
}

/// حالة الدفع
enum PaymentStatus {
  pending('قيد الانتظار'),
  processing('جاري المعالجة'),
  approved('مقبول'),
  declined('مرفوض'),
  failed('فشل'),
  cancelled('ملغي'),
  refunded('مسترجع'),
  partiallyRefunded('مسترجع جزئياً');

  final String arabicName;
  const PaymentStatus(this.arabicName);

  bool get isSuccessful => this == PaymentStatus.approved;
  bool get isFinal =>
      [approved, declined, failed, cancelled, refunded].contains(this);
}

/// حالة تهيئة بوابة الدفع
///
/// تُستخدم لتمييز البوابات المُهيّأة فعلاً عن المحاكاة:
/// - [notConfigured]: لم يتم إعداد SDK أو مفاتيح API بعد
/// - [configured]: تم إدخال المفاتيح لكن لم يتم التحقق من الاتصال
/// - [available]: البوابة جاهزة لمعالجة المدفوعات
/// - [unavailable]: تم الإعداد لكن الخدمة غير متاحة حالياً (صيانة، خطأ شبكة)
enum PaymentGatewayStatus {
  notConfigured('غير مفعّل - يتطلب إعداد'),
  configured('تم الإعداد - جاري التحقق'),
  available('متاح'),
  unavailable('غير متاح حالياً');

  final String arabicName;
  const PaymentGatewayStatus(this.arabicName);

  bool get isReady => this == PaymentGatewayStatus.available;
  bool get isConfigured =>
      this == PaymentGatewayStatus.configured ||
      this == PaymentGatewayStatus.available;
}

/// نوع خطأ الدفع
enum PaymentErrorType {
  network('خطأ في الاتصال'),
  timeout('انتهت المهلة'),
  declined('مرفوض من البنك'),
  insufficientFunds('رصيد غير كافٍ'),
  invalidCard('بطاقة غير صالحة'),
  expiredCard('بطاقة منتهية'),
  authenticationFailed('فشل التحقق'),
  terminalError('خطأ في الجهاز'),
  cancelled('تم الإلغاء'),
  gatewayNotConfigured('البوابة غير مفعّلة'),
  unknown('خطأ غير معروف');

  final String arabicMessage;
  const PaymentErrorType(this.arabicMessage);
}

// ============================================================================
// PAYMENT MODELS
// ============================================================================

/// طلب الدفع
class PaymentRequest {
  final String orderId;
  final double amount;
  final String currency;
  final PaymentMethod method;
  final String? customerPhone;
  final String? customerEmail;
  final String? customerName;
  final Map<String, dynamic>? metadata;

  const PaymentRequest({
    required this.orderId,
    required this.amount,
    this.currency = 'SAR',
    required this.method,
    this.customerPhone,
    this.customerEmail,
    this.customerName,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'order_id': orderId,
    'amount': amount,
    'currency': currency,
    'method': method.code,
    'customer_phone': customerPhone,
    'customer_email': customerEmail,
    'customer_name': customerName,
    'metadata': metadata,
  };
}

/// نتيجة الدفع
class PaymentResult {
  final bool success;
  final PaymentStatus status;
  final String? transactionId;
  final String? authCode;
  final String? referenceNumber;
  final PaymentErrorType? errorType;
  final String? errorMessage;
  final DateTime timestamp;
  final Map<String, dynamic>? rawResponse;

  const PaymentResult({
    required this.success,
    required this.status,
    this.transactionId,
    this.authCode,
    this.referenceNumber,
    this.errorType,
    this.errorMessage,
    required this.timestamp,
    this.rawResponse,
  });

  factory PaymentResult.success({
    required String transactionId,
    String? authCode,
    String? referenceNumber,
    Map<String, dynamic>? rawResponse,
  }) {
    return PaymentResult(
      success: true,
      status: PaymentStatus.approved,
      transactionId: transactionId,
      authCode: authCode,
      referenceNumber: referenceNumber,
      timestamp: DateTime.now(),
      rawResponse: rawResponse,
    );
  }

  factory PaymentResult.failed({
    required PaymentErrorType errorType,
    String? errorMessage,
    String? transactionId,
    Map<String, dynamic>? rawResponse,
  }) {
    return PaymentResult(
      success: false,
      status: PaymentStatus.failed,
      transactionId: transactionId,
      errorType: errorType,
      errorMessage: errorMessage ?? errorType.arabicMessage,
      timestamp: DateTime.now(),
      rawResponse: rawResponse,
    );
  }

  factory PaymentResult.cancelled() {
    return PaymentResult(
      success: false,
      status: PaymentStatus.cancelled,
      errorType: PaymentErrorType.cancelled,
      errorMessage: 'تم إلغاء عملية الدفع',
      timestamp: DateTime.now(),
    );
  }
}

/// طلب الاسترجاع
class RefundRequest {
  final String originalTransactionId;
  final double amount;
  final String reason;
  final bool isPartial;

  const RefundRequest({
    required this.originalTransactionId,
    required this.amount,
    required this.reason,
    this.isPartial = false,
  });
}

/// نتيجة الاسترجاع
class RefundResult {
  final bool success;
  final String? refundId;
  final double refundedAmount;
  final String? errorMessage;
  final DateTime timestamp;

  const RefundResult({
    required this.success,
    this.refundId,
    required this.refundedAmount,
    this.errorMessage,
    required this.timestamp,
  });
}

// ============================================================================
// PAYMENT GATEWAY INTERFACE
// ============================================================================

/// واجهة بوابة الدفع
abstract class PaymentGateway {
  /// اسم البوابة
  String get name;

  /// طرق الدفع المدعومة
  List<PaymentMethod> get supportedMethods;

  /// حالة تهيئة البوابة
  PaymentGatewayStatus get configurationStatus;

  /// هل البوابة متاحة (مهيأة + متصلة)
  Future<bool> isAvailable();

  /// هل البوابة في وضع المحاكاة (للتطوير فقط)
  bool get isSimulated;

  /// معالجة الدفع
  Future<PaymentResult> processPayment(PaymentRequest request);

  /// استرجاع المبلغ
  Future<RefundResult> refund(RefundRequest request);

  /// التحقق من حالة المعاملة
  Future<PaymentStatus> checkStatus(String transactionId);

  /// إلغاء المعاملة
  Future<bool> cancel(String transactionId);
}

// ============================================================================
// CASH PAYMENT
// ============================================================================

/// الدفع النقدي
class CashPaymentGateway implements PaymentGateway {
  @override
  String get name => 'نقدي';

  @override
  List<PaymentMethod> get supportedMethods => [PaymentMethod.cash];

  @override
  PaymentGatewayStatus get configurationStatus =>
      PaymentGatewayStatus.available;

  @override
  bool get isSimulated => false;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<PaymentResult> processPayment(PaymentRequest request) async {
    // الدفع النقدي دائماً ناجح
    return PaymentResult.success(
      transactionId: 'CASH-${DateTime.now().millisecondsSinceEpoch}',
      referenceNumber: request.orderId,
    );
  }

  @override
  Future<RefundResult> refund(RefundRequest request) async {
    return RefundResult(
      success: true,
      refundId: 'CASH-REF-${DateTime.now().millisecondsSinceEpoch}',
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

// ============================================================================
// MADA PAYMENT (SIMULATED)
// ============================================================================

/// بوابة مدى (محاكاة للتطوير)
///
/// TODO: تكامل الإنتاج - Nearpay SDK (https://docs.nearpay.io)
///   أو SoftPOS SDK لدعم الدفع بدون جهاز POS مادي.
///   الخطوات المطلوبة:
///   1. إضافة nearpay_flutter إلى pubspec.yaml
///   2. تسجيل حساب تاجر في Nearpay وإعداد Terminal ID
///   3. استبدال محاكاة processPayment بالتكامل الفعلي
///   4. تحديث configurationStatus بناءً على وجود المفاتيح
class MadaPaymentGateway implements PaymentGateway {
  final String merchantId;
  final String terminalId;
  final bool isTestMode;

  MadaPaymentGateway({
    required this.merchantId,
    required this.terminalId,
    this.isTestMode = true,
  });

  @override
  String get name => 'مدى';

  @override
  List<PaymentMethod> get supportedMethods => [
    PaymentMethod.mada,
    PaymentMethod.visa,
    PaymentMethod.mastercard,
    PaymentMethod.applePay,
  ];

  @override
  PaymentGatewayStatus get configurationStatus {
    // TODO: عند تكامل Nearpay SDK، تحقق من:
    //   - وجود merchantId و terminalId صالحين
    //   - اتصال الجهاز / SoftPOS جاهز
    if (kReleaseMode) return PaymentGatewayStatus.notConfigured;
    if (isTestMode) return PaymentGatewayStatus.available; // محاكاة فقط
    return PaymentGatewayStatus.notConfigured;
  }

  @override
  bool get isSimulated => !kReleaseMode && isTestMode;

  @override
  Future<bool> isAvailable() async {
    return configurationStatus == PaymentGatewayStatus.available;
  }

  @override
  Future<PaymentResult> processPayment(PaymentRequest request) async {
    debugPrint('[Mada] Processing payment: ${request.amount} SAR');

    // في وضع الإنتاج: رفض الدفع - SDK غير مُدمج
    if (kReleaseMode) {
      return PaymentResult.failed(
        errorType: PaymentErrorType.gatewayNotConfigured,
        errorMessage: 'الدفع بمدى غير مفعّل - يتطلب إعداد Nearpay SDK',
      );
    }

    // محاكاة وقت المعالجة (وضع التطوير فقط)
    await Future.delayed(const Duration(seconds: 2));

    if (isTestMode) {
      debugPrint('[Mada] SIMULATED payment - dev/test mode only');
      return PaymentResult.success(
        transactionId: 'MADA-${DateTime.now().millisecondsSinceEpoch}',
        authCode: '123456',
        referenceNumber: request.orderId,
        rawResponse: {
          'merchant_id': merchantId,
          'terminal_id': terminalId,
          'amount': request.amount,
          '_simulated': true,
        },
      );
    }

    // TODO: تكامل مع Nearpay SDK / SoftPOS SDK
    return PaymentResult.failed(
      errorType: PaymentErrorType.gatewayNotConfigured,
      errorMessage: 'الدفع بمدى غير مفعّل - يتطلب إعداد Nearpay SDK',
    );
  }

  @override
  Future<RefundResult> refund(RefundRequest request) async {
    debugPrint('[Mada] Processing refund: ${request.amount} SAR');

    if (kReleaseMode) {
      return RefundResult(
        success: false,
        refundedAmount: 0,
        errorMessage: 'الاسترجاع غير متاح - بوابة مدى غير مفعّلة',
        timestamp: DateTime.now(),
      );
    }

    await Future.delayed(const Duration(seconds: 1));

    return RefundResult(
      success: true,
      refundId: 'MADA-REF-${DateTime.now().millisecondsSinceEpoch}',
      refundedAmount: request.amount,
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<PaymentStatus> checkStatus(String transactionId) async {
    return PaymentStatus.approved;
  }

  @override
  Future<bool> cancel(String transactionId) async {
    debugPrint('[Mada] Cancelling transaction: $transactionId');
    return true;
  }
}

// ============================================================================
// STC PAY (SIMULATED)
// ============================================================================

/// بوابة STC Pay
///
/// TODO: تكامل الإنتاج - STC Pay Merchant SDK
///   الخطوات المطلوبة:
///   1. التقديم على STC Pay Merchant Portal للحصول على API credentials
///   2. إضافة STC Pay Merchant SDK (حزمة Flutter أو REST API wrapper)
///   3. إعداد webhook URL لاستلام إشعارات الدفع
///   4. استبدال محاكاة processPayment بتدفق OTP الفعلي
///   5. تحديث configurationStatus بناءً على وجود المفاتيح
class StcPayGateway implements PaymentGateway {
  final String merchantId;
  final String apiKey;
  final bool isTestMode;

  StcPayGateway({
    required this.merchantId,
    required this.apiKey,
    this.isTestMode = true,
  });

  @override
  String get name => 'STC Pay';

  @override
  List<PaymentMethod> get supportedMethods => [PaymentMethod.stcPay];

  @override
  PaymentGatewayStatus get configurationStatus {
    // TODO: عند تكامل STC Pay Merchant SDK، تحقق من:
    //   - وجود merchantId و apiKey صالحين
    //   - إعداد webhook URL
    if (kReleaseMode) return PaymentGatewayStatus.notConfigured;
    if (isTestMode) return PaymentGatewayStatus.available; // محاكاة فقط
    return PaymentGatewayStatus.notConfigured;
  }

  @override
  bool get isSimulated => !kReleaseMode && isTestMode;

  @override
  Future<bool> isAvailable() async {
    return configurationStatus == PaymentGatewayStatus.available;
  }

  @override
  Future<PaymentResult> processPayment(PaymentRequest request) async {
    debugPrint('[STC Pay] Processing payment: ${request.amount} SAR');

    // في وضع الإنتاج: رفض الدفع - SDK غير مُدمج
    if (kReleaseMode) {
      return PaymentResult.failed(
        errorType: PaymentErrorType.gatewayNotConfigured,
        errorMessage:
            'الدفع بـ STC Pay غير مفعّل - يتطلب إعداد STC Pay Merchant SDK',
      );
    }

    if (request.customerPhone == null) {
      return PaymentResult.failed(
        errorType: PaymentErrorType.authenticationFailed,
        errorMessage: 'رقم الجوال مطلوب لـ STC Pay',
      );
    }

    // محاكاة وقت المعالجة (وضع التطوير فقط)
    await Future.delayed(const Duration(seconds: 2));

    if (isTestMode) {
      debugPrint('[STC Pay] SIMULATED payment - dev/test mode only');
      return PaymentResult.success(
        transactionId: 'STC-${DateTime.now().millisecondsSinceEpoch}',
        authCode: 'STC123',
        referenceNumber: request.orderId,
        rawResponse: {'_simulated': true},
      );
    }

    // TODO: تكامل مع STC Pay Merchant SDK
    return PaymentResult.failed(
      errorType: PaymentErrorType.gatewayNotConfigured,
      errorMessage:
          'الدفع بـ STC Pay غير مفعّل - يتطلب إعداد STC Pay Merchant SDK',
    );
  }

  @override
  Future<RefundResult> refund(RefundRequest request) async {
    if (kReleaseMode) {
      return RefundResult(
        success: false,
        refundedAmount: 0,
        errorMessage: 'الاسترجاع غير متاح - بوابة STC Pay غير مفعّلة',
        timestamp: DateTime.now(),
      );
    }

    return RefundResult(
      success: true,
      refundId: 'STC-REF-${DateTime.now().millisecondsSinceEpoch}',
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

// ============================================================================
// TAMARA BNPL
// ============================================================================

/// بوابة تمارا (اشتري الآن وادفع لاحقاً)
///
/// TODO: تكامل الإنتاج - Tamara Flutter SDK (https://pub.dev/packages/tamara_sdk)
///   أو tamara_checkout حسب المتاح.
///   الخطوات المطلوبة:
///   1. التسجيل في Tamara Merchant Portal
///   2. إضافة tamara_sdk إلى pubspec.yaml
///   3. إعداد API token و notification webhook
///   4. استبدال محاكاة processPayment بتدفق Checkout الفعلي
///   5. تحديث configurationStatus بناءً على وجود المفاتيح
class TamaraGateway implements PaymentGateway {
  final String apiToken;
  final String merchantUrl;
  final bool isTestMode;

  TamaraGateway({
    required this.apiToken,
    required this.merchantUrl,
    this.isTestMode = true,
  });

  @override
  String get name => 'تمارا';

  @override
  List<PaymentMethod> get supportedMethods => [PaymentMethod.tamara];

  @override
  PaymentGatewayStatus get configurationStatus {
    // TODO: عند تكامل Tamara Flutter SDK، تحقق من:
    //   - وجود apiToken صالح
    //   - إعداد merchantUrl و notification webhook
    if (kReleaseMode) return PaymentGatewayStatus.notConfigured;
    if (isTestMode) return PaymentGatewayStatus.available; // محاكاة فقط
    return PaymentGatewayStatus.notConfigured;
  }

  @override
  bool get isSimulated => !kReleaseMode && isTestMode;

  @override
  Future<bool> isAvailable() async {
    return configurationStatus == PaymentGatewayStatus.available;
  }

  /// الحد الأدنى للطلب
  double get minOrderAmount => 100;

  /// الحد الأقصى للطلب
  double get maxOrderAmount => 5000;

  @override
  Future<PaymentResult> processPayment(PaymentRequest request) async {
    debugPrint('[Tamara] Processing payment: ${request.amount} SAR');

    // في وضع الإنتاج: رفض الدفع - SDK غير مُدمج
    if (kReleaseMode) {
      return PaymentResult.failed(
        errorType: PaymentErrorType.gatewayNotConfigured,
        errorMessage: 'الدفع بتمارا غير مفعّل - يتطلب إعداد Tamara Flutter SDK',
      );
    }

    // التحقق من الحدود
    if (request.amount < minOrderAmount) {
      return PaymentResult.failed(
        errorType: PaymentErrorType.declined,
        errorMessage: 'الحد الأدنى للطلب $minOrderAmount ريال',
      );
    }

    if (request.amount > maxOrderAmount) {
      return PaymentResult.failed(
        errorType: PaymentErrorType.declined,
        errorMessage: 'الحد الأقصى للطلب $maxOrderAmount ريال',
      );
    }

    if (request.customerPhone == null) {
      return PaymentResult.failed(
        errorType: PaymentErrorType.authenticationFailed,
        errorMessage: 'رقم الجوال مطلوب لـ تمارا',
      );
    }

    // محاكاة وقت المعالجة (وضع التطوير فقط)
    await Future.delayed(const Duration(seconds: 2));

    if (isTestMode) {
      debugPrint('[Tamara] SIMULATED payment - dev/test mode only');
      return PaymentResult.success(
        transactionId: 'TAMARA-${DateTime.now().millisecondsSinceEpoch}',
        referenceNumber: request.orderId,
        rawResponse: {
          'installments': 4,
          'first_payment': request.amount / 4,
          '_simulated': true,
        },
      );
    }

    // TODO: تكامل مع Tamara Flutter SDK
    return PaymentResult.failed(
      errorType: PaymentErrorType.gatewayNotConfigured,
      errorMessage: 'الدفع بتمارا غير مفعّل - يتطلب إعداد Tamara Flutter SDK',
    );
  }

  @override
  Future<RefundResult> refund(RefundRequest request) async {
    if (kReleaseMode) {
      return RefundResult(
        success: false,
        refundedAmount: 0,
        errorMessage: 'الاسترجاع غير متاح - بوابة تمارا غير مفعّلة',
        timestamp: DateTime.now(),
      );
    }

    return RefundResult(
      success: true,
      refundId: 'TAMARA-REF-${DateTime.now().millisecondsSinceEpoch}',
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

// ============================================================================
// PAYMENT SERVICE
// ============================================================================

/// معلومات بوابة دفع مسجّلة
class RegisteredGateway {
  final PaymentMethod method;
  final PaymentGateway gateway;

  const RegisteredGateway({required this.method, required this.gateway});

  PaymentGatewayStatus get status => gateway.configurationStatus;
  bool get isSimulated => gateway.isSimulated;
  String get displayName => gateway.name;
}

/// خدمة الدفع الموحدة
class PaymentService {
  final Map<PaymentMethod, PaymentGateway> _gateways = {};

  PaymentService() {
    // تسجيل البوابات الافتراضية
    registerGateway(PaymentMethod.cash, CashPaymentGateway());
  }

  /// التحقق من توفر طريقة الدفع
  /// في الإصدار الحالي، النقد فقط متاح فعلياً
  // TODO: Enable electronic payments when SDKs are integrated:
  //   - mada: Nearpay SDK / SoftPOS SDK
  //   - STC Pay: STC Pay Merchant SDK
  //   - Tamara: Tamara Flutter SDK
  static bool isMethodAvailable(PaymentMethod method) {
    return method == PaymentMethod.cash;
  }

  /// تسجيل بوابة دفع
  void registerGateway(PaymentMethod method, PaymentGateway gateway) {
    _gateways[method] = gateway;
    debugPrint('[PaymentService] Registered gateway: ${gateway.name}');
  }

  /// الحصول على البوابة
  PaymentGateway? getGateway(PaymentMethod method) => _gateways[method];

  /// جميع طرق الدفع المسجّلة (بما فيها غير المفعّلة)
  List<PaymentMethod> get registeredMethods => _gateways.keys.toList();

  /// طرق الدفع المتاحة فعلياً (مهيأة وجاهزة)
  ///
  /// تُرجع فقط البوابات التي [PaymentGatewayStatus.available].
  /// في وضع التطوير تشمل البوابات المحاكاة.
  List<PaymentMethod> get availableMethods => _gateways.entries
      .where(
        (e) => e.value.configurationStatus == PaymentGatewayStatus.available,
      )
      .map((e) => e.key)
      .toList();

  /// البوابات المهيأة فعلياً (ليست محاكاة)
  ///
  /// تُرجع البوابات التي تم إعداد SDK/API لها وهي جاهزة للإنتاج.
  List<RegisteredGateway> get configuredGateways => _gateways.entries
      .where((e) => !e.value.isSimulated && e.value.configurationStatus.isReady)
      .map((e) => RegisteredGateway(method: e.key, gateway: e.value))
      .toList();

  /// البوابات المحاكاة (وضع التطوير فقط)
  ///
  /// تُرجع البوابات التي تعمل بالمحاكاة ولم يتم تكامل SDK الفعلي لها.
  List<RegisteredGateway> get simulatedGateways => _gateways.entries
      .where((e) => e.value.isSimulated)
      .map((e) => RegisteredGateway(method: e.key, gateway: e.value))
      .toList();

  /// الحصول على جميع البوابات مع حالة كل منها
  ///
  /// مفيدة لعرض حالة كل بوابة في واجهة الإعدادات:
  /// - متاح / محاكاة / غير مفعّل
  List<RegisteredGateway> getGatewayStatuses() => _gateways.entries
      .map((e) => RegisteredGateway(method: e.key, gateway: e.value))
      .toList();

  /// معالجة الدفع
  Future<PaymentResult> processPayment(PaymentRequest request) async {
    // التحقق من أن الطريقة متاحة فعلياً
    if (!isMethodAvailable(request.method)) {
      final gateway = _gateways[request.method];
      final status =
          gateway?.configurationStatus ?? PaymentGatewayStatus.notConfigured;

      debugPrint(
        '[PaymentService] Rejected ${request.method.arabicName} '
        '(status: ${status.arabicName})',
      );

      return PaymentResult.failed(
        errorType: PaymentErrorType.gatewayNotConfigured,
        errorMessage: status == PaymentGatewayStatus.notConfigured
            ? '${request.method.arabicName} غير مفعّل - يتطلب إعداد'
            : 'بوابة ${request.method.arabicName} غير متاحة حالياً',
      );
    }

    final gateway = _gateways[request.method];

    if (gateway == null) {
      return PaymentResult.failed(
        errorType: PaymentErrorType.unknown,
        errorMessage: 'طريقة الدفع غير مدعومة',
      );
    }

    final isAvailable = await gateway.isAvailable();
    if (!isAvailable) {
      return PaymentResult.failed(
        errorType: PaymentErrorType.gatewayNotConfigured,
        errorMessage: 'بوابة الدفع غير متاحة حالياً',
      );
    }

    try {
      return await gateway.processPayment(request);
    } catch (e) {
      debugPrint('[PaymentService] Error: $e');
      return PaymentResult.failed(
        errorType: PaymentErrorType.unknown,
        errorMessage: 'حدث خطأ أثناء معالجة الدفع',
      );
    }
  }

  /// استرجاع المبلغ
  Future<RefundResult> refund(
    RefundRequest request,
    PaymentMethod method,
  ) async {
    final gateway = _gateways[method];

    if (gateway == null) {
      return RefundResult(
        success: false,
        refundedAmount: 0,
        errorMessage: 'بوابة الدفع غير متاحة',
        timestamp: DateTime.now(),
      );
    }

    try {
      return await gateway.refund(request);
    } catch (e) {
      return RefundResult(
        success: false,
        refundedAmount: 0,
        errorMessage: 'حدث خطأ أثناء الاسترجاع',
        timestamp: DateTime.now(),
      );
    }
  }
}
