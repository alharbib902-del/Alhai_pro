// نموذج الطلب الأونلاين
// 
// يمثل طلب من تطبيق العميل مع جميع التفاصيل

/// حالة الطلب
enum OrderStatus {
  /// طلب جديد بانتظار القبول
  pending,
  
  /// تم قبول الطلب
  accepted,
  
  /// جاري التجهيز
  preparing,
  
  /// في الطريق للتوصيل
  outForDelivery,
  
  /// تم التسليم
  delivered,
  
  /// ملغي
  cancelled,
}

/// حالة الدفع
enum PaymentStatus {
  /// مدفوع مسبقاً
  paid,
  
  /// الدفع عند الاستلام
  cashOnDelivery,
  
  /// فشل الدفع
  failed,
}

/// عنصر في الطلب
class OrderItem {
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double? discount;
  final String? notes;

  const OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    this.discount,
    this.notes,
  });

  /// إجمالي العنصر
  double get total => (unitPrice * quantity) - (discount ?? 0);

  /// نسخ مع تعديل
  OrderItem copyWith({
    String? productId,
    String? productName,
    int? quantity,
    double? unitPrice,
    double? discount,
    String? notes,
  }) {
    return OrderItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      discount: discount ?? this.discount,
      notes: notes ?? this.notes,
    );
  }

  /// تحويل لـ JSON
  Map<String, dynamic> toJson() => {
    'productId': productId,
    'productName': productName,
    'quantity': quantity,
    'unitPrice': unitPrice,
    'discount': discount,
    'notes': notes,
  };

  /// إنشاء من JSON
  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      quantity: json['quantity'] as int,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      discount: json['discount'] != null ? (json['discount'] as num).toDouble() : null,
      notes: json['notes'] as String?,
    );
  }
}

/// الطلب الأونلاين
class OnlineOrder {
  final String id;
  final String storeId;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String? customerAddress;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double total;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? preparedAt;
  final DateTime? deliveredAt;
  final String? driverId;
  final String? driverName;
  final String? notes;
  final String? cancellationReason;

  const OnlineOrder({
    required this.id,
    required this.storeId,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    this.customerAddress,
    required this.items,
    required this.subtotal,
    this.deliveryFee = 0,
    this.discount = 0,
    required this.total,
    this.status = OrderStatus.pending,
    required this.paymentStatus,
    required this.createdAt,
    this.acceptedAt,
    this.preparedAt,
    this.deliveredAt,
    this.driverId,
    this.driverName,
    this.notes,
    this.cancellationReason,
  });

  /// عدد المنتجات
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  /// هل الطلب جديد (أقل من 5 دقائق)
  bool get isNew => DateTime.now().difference(createdAt).inMinutes < 5;

  /// الوقت منذ الإنشاء
  Duration get timeSinceCreated => DateTime.now().difference(createdAt);

  /// هل مدفوع
  bool get isPaid => paymentStatus == PaymentStatus.paid;

  /// هل ملغي
  bool get isCancelled => status == OrderStatus.cancelled;

  /// هل مكتمل
  bool get isCompleted => status == OrderStatus.delivered;

  /// هل يحتاج إجراء
  bool get needsAction => status == OrderStatus.pending || status == OrderStatus.accepted;

  /// نسخ مع تعديل
  OnlineOrder copyWith({
    String? id,
    String? storeId,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? customerAddress,
    List<OrderItem>? items,
    double? subtotal,
    double? deliveryFee,
    double? discount,
    double? total,
    OrderStatus? status,
    PaymentStatus? paymentStatus,
    DateTime? createdAt,
    DateTime? acceptedAt,
    DateTime? preparedAt,
    DateTime? deliveredAt,
    String? driverId,
    String? driverName,
    String? notes,
    String? cancellationReason,
  }) {
    return OnlineOrder(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerAddress: customerAddress ?? this.customerAddress,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      preparedAt: preparedAt ?? this.preparedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      notes: notes ?? this.notes,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }

  /// تحويل لـ JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'storeId': storeId,
    'customerId': customerId,
    'customerName': customerName,
    'customerPhone': customerPhone,
    'customerAddress': customerAddress,
    'items': items.map((e) => e.toJson()).toList(),
    'subtotal': subtotal,
    'deliveryFee': deliveryFee,
    'discount': discount,
    'total': total,
    'status': status.name,
    'paymentStatus': paymentStatus.name,
    'createdAt': createdAt.toIso8601String(),
    'acceptedAt': acceptedAt?.toIso8601String(),
    'preparedAt': preparedAt?.toIso8601String(),
    'deliveredAt': deliveredAt?.toIso8601String(),
    'driverId': driverId,
    'driverName': driverName,
    'notes': notes,
    'cancellationReason': cancellationReason,
  };

  /// إنشاء من JSON
  factory OnlineOrder.fromJson(Map<String, dynamic> json) {
    return OnlineOrder(
      id: json['id'] as String,
      storeId: json['storeId'] as String,
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String,
      customerPhone: json['customerPhone'] as String,
      customerAddress: json['customerAddress'] as String?,
      items: (json['items'] as List).map((e) => OrderItem.fromJson(e)).toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num).toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name == json['paymentStatus'],
        orElse: () => PaymentStatus.cashOnDelivery,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      acceptedAt: json['acceptedAt'] != null ? DateTime.parse(json['acceptedAt'] as String) : null,
      preparedAt: json['preparedAt'] != null ? DateTime.parse(json['preparedAt'] as String) : null,
      deliveredAt: json['deliveredAt'] != null ? DateTime.parse(json['deliveredAt'] as String) : null,
      driverId: json['driverId'] as String?,
      driverName: json['driverName'] as String?,
      notes: json['notes'] as String?,
      cancellationReason: json['cancellationReason'] as String?,
    );
  }
}

/// Extension لـ OrderStatus
extension OrderStatusExtension on OrderStatus {
  /// الاسم بالعربي
  String get arabicName {
    switch (this) {
      case OrderStatus.pending:
        return 'بانتظار القبول';
      case OrderStatus.accepted:
        return 'تم القبول';
      case OrderStatus.preparing:
        return 'جاري التجهيز';
      case OrderStatus.outForDelivery:
        return 'في الطريق';
      case OrderStatus.delivered:
        return 'تم التسليم';
      case OrderStatus.cancelled:
        return 'ملغي';
    }
  }

  /// الأيقونة
  String get icon {
    switch (this) {
      case OrderStatus.pending:
        return '🟡';
      case OrderStatus.accepted:
        return '🔵';
      case OrderStatus.preparing:
        return '🟠';
      case OrderStatus.outForDelivery:
        return '🚗';
      case OrderStatus.delivered:
        return '✅';
      case OrderStatus.cancelled:
        return '❌';
    }
  }
}

/// Extension لـ PaymentStatus
extension PaymentStatusExtension on PaymentStatus {
  /// الاسم بالعربي
  String get arabicName {
    switch (this) {
      case PaymentStatus.paid:
        return 'مدفوع';
      case PaymentStatus.cashOnDelivery:
        return 'الدفع عند الاستلام';
      case PaymentStatus.failed:
        return 'فشل الدفع';
    }
  }

  /// الأيقونة
  String get icon {
    switch (this) {
      case PaymentStatus.paid:
        return '✅';
      case PaymentStatus.cashOnDelivery:
        return '💵';
      case PaymentStatus.failed:
        return '❌';
    }
  }
}
