/// Payment Gateway - بوابات الدفع الإلكتروني
///
/// يوفر:
/// - واجهة موحدة لجميع بوابات الدفع
/// - دعم مدى، Apple Pay، STC Pay، تمارا
/// - معالجة الأخطاء والاسترجاع
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
  bool get requiresTerminal => [mada, visa, mastercard, applePay].contains(this);
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
  bool get isFinal => [approved, declined, failed, cancelled, refunded].contains(this);
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

  /// هل البوابة متاحة
  Future<bool> isAvailable();

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
  Future<bool> isAvailable() async {
    // البوابة غير متاحة حتى يتم تكامل SDK الجهاز
    // TODO: التحقق من اتصال الجهاز عند تكامل SDK
    if (kReleaseMode) return false;
    return isTestMode;
  }

  @override
  Future<PaymentResult> processPayment(PaymentRequest request) async {
    debugPrint('[Mada] Processing payment: ${request.amount} SAR');

    // في وضع الإنتاج: رفض الدفع مع رسالة واضحة
    if (kReleaseMode) {
      return PaymentResult.failed(
        errorType: PaymentErrorType.terminalError,
        errorMessage:
            'الدفع الإلكتروني غير مفعل حالياً. يرجى استخدام الدفع النقدي',
      );
    }

    // محاكاة وقت المعالجة (وضع التطوير فقط)
    await Future.delayed(const Duration(seconds: 2));

    if (isTestMode) {
      // في وضع الاختبار: نجاح دائماً (للتطوير فقط)
      debugPrint('[Mada] ⚠ SIMULATED payment - dev/test mode only');
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

    // TODO: تكامل مع SDK الجهاز
    return PaymentResult.failed(
      errorType: PaymentErrorType.terminalError,
      errorMessage:
          'الدفع الإلكتروني غير مفعل حالياً. يرجى استخدام الدفع النقدي',
    );
  }

  @override
  Future<RefundResult> refund(RefundRequest request) async {
    debugPrint('[Mada] Processing refund: ${request.amount} SAR');

    if (kReleaseMode) {
      return RefundResult(
        success: false,
        refundedAmount: 0,
        errorMessage:
            'الدفع الإلكتروني غير مفعل حالياً. يرجى استخدام الدفع النقدي',
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
  Future<bool> isAvailable() async {
    // البوابة غير متاحة حتى يتم تكامل STC Pay API
    // TODO: التحقق من إعداد API عند التكامل
    if (kReleaseMode) return false;
    return isTestMode;
  }

  @override
  Future<PaymentResult> processPayment(PaymentRequest request) async {
    debugPrint('[STC Pay] Processing payment: ${request.amount} SAR');

    // في وضع الإنتاج: رفض الدفع مع رسالة واضحة
    if (kReleaseMode) {
      return PaymentResult.failed(
        errorType: PaymentErrorType.terminalError,
        errorMessage:
            'الدفع الإلكتروني غير مفعل حالياً. يرجى استخدام الدفع النقدي',
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
      debugPrint('[STC Pay] ⚠ SIMULATED payment - dev/test mode only');
      return PaymentResult.success(
        transactionId: 'STC-${DateTime.now().millisecondsSinceEpoch}',
        authCode: 'STC123',
        referenceNumber: request.orderId,
        rawResponse: {
          '_simulated': true,
        },
      );
    }

    // TODO: تكامل مع STC Pay API
    return PaymentResult.failed(
      errorType: PaymentErrorType.unknown,
      errorMessage:
          'الدفع الإلكتروني غير مفعل حالياً. يرجى استخدام الدفع النقدي',
    );
  }

  @override
  Future<RefundResult> refund(RefundRequest request) async {
    if (kReleaseMode) {
      return RefundResult(
        success: false,
        refundedAmount: 0,
        errorMessage:
            'الدفع الإلكتروني غير مفعل حالياً. يرجى استخدام الدفع النقدي',
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
  Future<bool> isAvailable() async {
    // البوابة غير متاحة حتى يتم تكامل Tamara API
    // TODO: التحقق من إعداد API عند التكامل
    if (kReleaseMode) return false;
    return isTestMode;
  }

  /// الحد الأدنى للطلب
  double get minOrderAmount => 100;

  /// الحد الأقصى للطلب
  double get maxOrderAmount => 5000;

  @override
  Future<PaymentResult> processPayment(PaymentRequest request) async {
    debugPrint('[Tamara] Processing payment: ${request.amount} SAR');

    // في وضع الإنتاج: رفض الدفع مع رسالة واضحة
    if (kReleaseMode) {
      return PaymentResult.failed(
        errorType: PaymentErrorType.terminalError,
        errorMessage:
            'الدفع الإلكتروني غير مفعل حالياً. يرجى استخدام الدفع النقدي',
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
      debugPrint('[Tamara] ⚠ SIMULATED payment - dev/test mode only');
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

    // TODO: تكامل مع Tamara API
    return PaymentResult.failed(
      errorType: PaymentErrorType.unknown,
      errorMessage:
          'الدفع الإلكتروني غير مفعل حالياً. يرجى استخدام الدفع النقدي',
    );
  }

  @override
  Future<RefundResult> refund(RefundRequest request) async {
    if (kReleaseMode) {
      return RefundResult(
        success: false,
        refundedAmount: 0,
        errorMessage:
            'الدفع الإلكتروني غير مفعل حالياً. يرجى استخدام الدفع النقدي',
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

/// خدمة الدفع الموحدة
class PaymentService {
  /// رسالة الدفع الإلكتروني غير المفعل
  static const String _electronicPaymentUnavailableMessage =
      'الدفع الإلكتروني غير مفعل حالياً. يرجى استخدام الدفع النقدي';

  final Map<PaymentMethod, PaymentGateway> _gateways = {};

  PaymentService() {
    // تسجيل البوابات الافتراضية
    registerGateway(PaymentMethod.cash, CashPaymentGateway());
  }

  /// التحقق من توفر طريقة الدفع
  /// في الإصدار الحالي، النقد فقط متاح
  // TODO: Enable electronic payments when terminal SDK is integrated
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

  /// طرق الدفع المتاحة
  List<PaymentMethod> get availableMethods => _gateways.keys.toList();

  /// معالجة الدفع
  Future<PaymentResult> processPayment(PaymentRequest request) async {
    // في وضع الإنتاج: رفض طرق الدفع الإلكترونية غير المفعلة
    if (!isMethodAvailable(request.method)) {
      debugPrint(
        '[PaymentService] Rejected unavailable method: ${request.method.arabicName}',
      );
      return PaymentResult.failed(
        errorType: PaymentErrorType.terminalError,
        errorMessage: _electronicPaymentUnavailableMessage,
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
        errorType: PaymentErrorType.terminalError,
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
  Future<RefundResult> refund(RefundRequest request, PaymentMethod method) async {
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
