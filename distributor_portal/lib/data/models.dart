/// Data models for Distributor Portal.
///
/// Maps to Supabase tables: orders, order_items, products, stores, organizations.
library;

// ─── Distributor Order ──────────────────────────────────────────

class DistributorOrder {
  final String id;
  final String purchaseNumber;
  final String storeName;
  final String storeId;
  final double total;
  final String status; // draft, sent, approved, received, rejected
  final DateTime createdAt;
  final String? notes;

  const DistributorOrder({
    required this.id,
    required this.purchaseNumber,
    required this.storeName,
    required this.storeId,
    required this.total,
    required this.status,
    required this.createdAt,
    this.notes,
  });

  factory DistributorOrder.fromJson(Map<String, dynamic> json) {
    // The store name comes from a join: orders.store_id -> stores.name
    final storeName = json['stores'] is Map
        ? (json['stores']['name'] as String? ?? '')
        : (json['store_name'] as String? ?? '');

    return DistributorOrder(
      id: json['id'] as String,
      purchaseNumber: json['purchase_number'] as String? ?? 'PO-${(json['id'] as String).substring(0, 8)}',
      storeName: storeName,
      storeId: json['store_id'] as String? ?? '',
      total: (json['total'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String? ?? 'draft',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      notes: json['notes'] as String?,
    );
  }
}

// ─── Order Item ─────────────────────────────────────────────────

class DistributorOrderItem {
  final String id;
  final String orderId;
  final String productId;
  final String productName;
  final int quantity;
  final double suggestedPrice;
  final double? distributorPrice;
  final String? barcode;

  const DistributorOrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.suggestedPrice,
    this.distributorPrice,
    this.barcode,
  });

  double get suggestedTotal => quantity * suggestedPrice;
  double get distributorTotal =>
      distributorPrice != null ? quantity * distributorPrice! : 0;

  factory DistributorOrderItem.fromJson(Map<String, dynamic> json) {
    final productName = json['products'] is Map
        ? (json['products']['name'] as String? ?? '')
        : (json['product_name'] as String? ?? '');
    final barcode = json['products'] is Map
        ? (json['products']['barcode'] as String?)
        : (json['barcode'] as String?);

    return DistributorOrderItem(
      id: json['id'] as String,
      orderId: json['order_id'] as String? ?? '',
      productId: json['product_id'] as String? ?? '',
      productName: productName,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      suggestedPrice: (json['unit_price'] as num?)?.toDouble() ?? 0,
      distributorPrice: (json['distributor_price'] as num?)?.toDouble(),
      barcode: barcode,
    );
  }
}

// ─── Product ────────────────────────────────────────────────────

class DistributorProduct {
  final String id;
  final String name;
  final String? barcode;
  final String category;
  final double price;
  final int stock;
  final DateTime? updatedAt;

  const DistributorProduct({
    required this.id,
    required this.name,
    this.barcode,
    required this.category,
    required this.price,
    required this.stock,
    this.updatedAt,
  });

  factory DistributorProduct.fromJson(Map<String, dynamic> json) {
    final categoryName = json['categories'] is Map
        ? (json['categories']['name'] as String? ?? '')
        : (json['category_name'] as String? ?? '');

    return DistributorProduct(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      barcode: json['barcode'] as String?,
      category: categoryName,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? ''),
    );
  }
}

// ─── Dashboard KPIs ─────────────────────────────────────────────

class DashboardKpis {
  final int totalOrders;
  final int pendingOrders;
  final int approvedOrders;
  final double totalRevenue;
  final List<MonthlySales> monthlySales;
  final List<DistributorOrder> recentOrders;

  const DashboardKpis({
    required this.totalOrders,
    required this.pendingOrders,
    required this.approvedOrders,
    required this.totalRevenue,
    required this.monthlySales,
    required this.recentOrders,
  });
}

class MonthlySales {
  final String month;
  final double amount;
  const MonthlySales(this.month, this.amount);
}

// ─── Report Data ────────────────────────────────────────────────

class ReportData {
  final double totalSales;
  final int orderCount;
  final double avgOrderValue;
  final String topProduct;
  final int topProductOrders;
  final List<DailySales> dailySales;
  final List<TopProduct> topProducts;

  const ReportData({
    required this.totalSales,
    required this.orderCount,
    required this.avgOrderValue,
    required this.topProduct,
    required this.topProductOrders,
    required this.dailySales,
    required this.topProducts,
  });
}

class DailySales {
  final String day;
  final double amount;
  const DailySales(this.day, this.amount);
}

class TopProduct {
  final String name;
  final int orderCount;
  final double revenue;
  const TopProduct(this.name, this.orderCount, this.revenue);
}

// ─── Organization Settings ──────────────────────────────────────

class OrgSettings {
  final String id;
  final String companyName;
  final String? phone;
  final String? email;
  final String? address;
  final String? deliveryZones;
  final double? minOrderAmount;
  final double? deliveryFee;
  final double? freeDeliveryMin;
  final bool freeDeliveryEnabled;
  final bool emailNotifications;
  final bool pushNotifications;
  final bool smsNotifications;

  const OrgSettings({
    required this.id,
    required this.companyName,
    this.phone,
    this.email,
    this.address,
    this.deliveryZones,
    this.minOrderAmount,
    this.deliveryFee,
    this.freeDeliveryMin,
    this.freeDeliveryEnabled = true,
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.smsNotifications = false,
  });

  factory OrgSettings.fromJson(Map<String, dynamic> json) {
    return OrgSettings(
      id: json['id'] as String,
      companyName: json['name'] as String? ?? '',
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      deliveryZones: json['delivery_zones'] as String?,
      minOrderAmount: (json['min_order_amount'] as num?)?.toDouble(),
      deliveryFee: (json['delivery_fee'] as num?)?.toDouble(),
      freeDeliveryMin: (json['free_delivery_min'] as num?)?.toDouble(),
      freeDeliveryEnabled: json['free_delivery_enabled'] as bool? ?? true,
      emailNotifications: json['email_notifications'] as bool? ?? true,
      pushNotifications: json['push_notifications'] as bool? ?? true,
      smsNotifications: json['sms_notifications'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': companyName,
        'phone': phone,
        'email': email,
        'address': address,
        'delivery_zones': deliveryZones,
        'min_order_amount': minOrderAmount,
        'delivery_fee': deliveryFee,
        'free_delivery_min': freeDeliveryMin,
        'free_delivery_enabled': freeDeliveryEnabled,
        'email_notifications': emailNotifications,
        'push_notifications': pushNotifications,
        'sms_notifications': smsNotifications,
      };
}
