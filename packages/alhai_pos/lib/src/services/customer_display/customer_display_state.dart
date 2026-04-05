/// Customer Display State - حالات شاشة العميل
///
/// يحدد جميع الحالات الممكنة لشاشة العميل الثانية:
/// - [idle]: شاشة ترحيب / انتظار
/// - [cart]: عرض الفاتورة الحالية
/// - [phoneEntry]: إدخال رقم الجوال
/// - [payment]: جاري الدفع
/// - [nfcWaiting]: انتظار NFC
/// - [success]: نجاح الدفع
/// - [failure]: فشل الدفع
library;

import 'dart:convert';
import '../../providers/cart_providers.dart';

// ============================================================================
// DISPLAY PHASE ENUM
// ============================================================================

/// مرحلة العرض على شاشة العميل
enum CustomerDisplayPhase {
  idle,
  cart,
  phoneEntry,
  payment,
  nfcWaiting,
  success,
  failure,
}

// ============================================================================
// NFC STATUS (for customer display)
// ============================================================================

/// حالة NFC المعروضة للعميل
enum NfcDisplayStatus {
  waitingForTap,
  reading,
  processing,
  success,
  failed,
  cancelled,
  timeout,
}

// ============================================================================
// CART DISPLAY ITEM (lightweight, serializable)
// ============================================================================

/// عنصر فاتورة للعرض على شاشة العميل (خفيف وقابل للتسلسل)
class DisplayCartItem {
  final String productName;
  final int quantity;
  final double unitPrice;
  final double lineTotal;

  const DisplayCartItem({
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
  });

  Map<String, dynamic> toJson() => {
        'productName': productName,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'lineTotal': lineTotal,
      };

  factory DisplayCartItem.fromJson(Map<String, dynamic> json) {
    return DisplayCartItem(
      productName: json['productName'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 0,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0,
      lineTotal: (json['lineTotal'] as num?)?.toDouble() ?? 0,
    );
  }

  factory DisplayCartItem.fromPosCartItem(PosCartItem item) {
    return DisplayCartItem(
      productName: item.product.name,
      quantity: item.quantity,
      unitPrice: item.effectivePrice,
      lineTotal: item.total,
    );
  }
}

// ============================================================================
// CUSTOMER DISPLAY STATE
// ============================================================================

/// حالة شاشة العميل الكاملة
class CustomerDisplayState {
  final CustomerDisplayPhase phase;
  final String storeName;

  // Cart data
  final List<DisplayCartItem> items;
  final double subtotal;
  final double discount;
  final double tax;
  final double total;

  // Payment data
  final String? paymentMethodName;
  final NfcDisplayStatus? nfcStatus;
  final String? nfcMessage;

  // Result
  final String? resultMessage;

  const CustomerDisplayState({
    this.phase = CustomerDisplayPhase.idle,
    this.storeName = '',
    this.items = const [],
    this.subtotal = 0,
    this.discount = 0,
    this.tax = 0,
    this.total = 0,
    this.paymentMethodName,
    this.nfcStatus,
    this.nfcMessage,
    this.resultMessage,
  });

  /// حالة الانتظار الافتراضية
  const CustomerDisplayState.idle({String storeName = ''})
      : this(phase: CustomerDisplayPhase.idle, storeName: storeName);

  /// حالة عرض السلة
  CustomerDisplayState.cart({
    required List<DisplayCartItem> items,
    required double subtotal,
    required double discount,
    required double tax,
    required double total,
    String storeName = '',
  }) : this(
          phase: CustomerDisplayPhase.cart,
          storeName: storeName,
          items: items,
          subtotal: subtotal,
          discount: discount,
          tax: tax,
          total: total,
        );

  /// حالة إدخال رقم الجوال
  CustomerDisplayState.phoneEntry({
    required List<DisplayCartItem> items,
    required double total,
    String storeName = '',
  }) : this(
          phase: CustomerDisplayPhase.phoneEntry,
          storeName: storeName,
          items: items,
          total: total,
        );

  /// حالة انتظار NFC
  CustomerDisplayState.nfcWaiting({
    required double total,
    NfcDisplayStatus nfcStatus = NfcDisplayStatus.waitingForTap,
    String? nfcMessage,
    String storeName = '',
  }) : this(
          phase: CustomerDisplayPhase.nfcWaiting,
          storeName: storeName,
          total: total,
          nfcStatus: nfcStatus,
          nfcMessage: nfcMessage,
        );

  /// حالة نجاح الدفع
  CustomerDisplayState.success({
    required double total,
    String? resultMessage,
    String storeName = '',
  }) : this(
          phase: CustomerDisplayPhase.success,
          storeName: storeName,
          total: total,
          resultMessage: resultMessage,
        );

  /// حالة فشل الدفع
  CustomerDisplayState.failure({
    String? resultMessage,
    String storeName = '',
  }) : this(
          phase: CustomerDisplayPhase.failure,
          storeName: storeName,
          resultMessage: resultMessage,
        );

  CustomerDisplayState copyWith({
    CustomerDisplayPhase? phase,
    String? storeName,
    List<DisplayCartItem>? items,
    double? subtotal,
    double? discount,
    double? tax,
    double? total,
    String? paymentMethodName,
    NfcDisplayStatus? nfcStatus,
    String? nfcMessage,
    String? resultMessage,
  }) {
    return CustomerDisplayState(
      phase: phase ?? this.phase,
      storeName: storeName ?? this.storeName,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      paymentMethodName: paymentMethodName ?? this.paymentMethodName,
      nfcStatus: nfcStatus ?? this.nfcStatus,
      nfcMessage: nfcMessage ?? this.nfcMessage,
      resultMessage: resultMessage ?? this.resultMessage,
    );
  }

  // =========================================================================
  // Serialization (for cross-window BroadcastChannel)
  // =========================================================================

  Map<String, dynamic> toJson() => {
        'phase': phase.name,
        'storeName': storeName,
        'items': items.map((e) => e.toJson()).toList(),
        'subtotal': subtotal,
        'discount': discount,
        'tax': tax,
        'total': total,
        'paymentMethodName': paymentMethodName,
        'nfcStatus': nfcStatus?.name,
        'nfcMessage': nfcMessage,
        'resultMessage': resultMessage,
      };

  String toJsonString() => jsonEncode(toJson());

  factory CustomerDisplayState.fromJson(Map<String, dynamic> json) {
    return CustomerDisplayState(
      phase: CustomerDisplayPhase.values.firstWhere(
        (e) => e.name == json['phase'],
        orElse: () => CustomerDisplayPhase.idle,
      ),
      storeName: json['storeName'] as String? ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => DisplayCartItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
      paymentMethodName: json['paymentMethodName'] as String?,
      nfcStatus: json['nfcStatus'] != null
          ? NfcDisplayStatus.values.firstWhere(
              (e) => e.name == json['nfcStatus'],
              orElse: () => NfcDisplayStatus.waitingForTap,
            )
          : null,
      nfcMessage: json['nfcMessage'] as String?,
      resultMessage: json['resultMessage'] as String?,
    );
  }

  factory CustomerDisplayState.fromJsonString(String jsonString) {
    return CustomerDisplayState.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }
}
