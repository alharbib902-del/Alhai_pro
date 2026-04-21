/// مصانع بيانات الاختبار - Test Data Factories
///
/// توفر بيانات وهمية متسقة لجميع الاختبارات
library;

import 'package:alhai_core/src/datasources/local/entities/auth_tokens_entity.dart';
import 'package:alhai_core/src/datasources/local/entities/user_entity.dart';
import 'package:alhai_core/src/dto/auth/auth_response.dart';
import 'package:alhai_core/src/dto/auth/auth_tokens_response.dart';
import 'package:alhai_core/src/models/auth_result.dart';
import 'package:alhai_core/src/models/auth_tokens.dart';
import 'package:alhai_core/src/models/category.dart';
import 'package:alhai_core/src/models/enums/order_status.dart';
import 'package:alhai_core/src/models/enums/payment_method.dart';
import 'package:alhai_core/src/models/enums/user_role.dart';
import 'package:alhai_core/src/models/order.dart';
import 'package:alhai_core/src/models/order_item.dart';
import 'package:alhai_core/src/models/product.dart';
import 'package:alhai_core/src/models/store.dart';
import 'package:alhai_core/src/models/user.dart';

/// مصنع بيانات المستخدمين
class UserFactory {
  static int _counter = 0;

  static User create({
    String? id,
    String? phone,
    String? email,
    String? name,
    UserRole? role,
    String? storeId,
    bool? isActive,
    bool? isVerified,
    DateTime? createdAt,
  }) {
    _counter++;
    return User(
      id: id ?? 'user-$_counter',
      phone: phone ?? '+9665000000$_counter',
      email: email,
      name: name ?? 'مستخدم $_counter',
      role: role ?? UserRole.customer,
      storeId: storeId,
      isActive: isActive ?? true,
      isVerified: isVerified ?? false,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  static User customer({String? id, String? name}) =>
      create(id: id, name: name ?? 'عميل', role: UserRole.customer);

  static User storeOwner({String? id, String? storeId}) => create(
    id: id,
    name: 'صاحب متجر',
    role: UserRole.storeOwner,
    storeId: storeId ?? 'store-1',
  );

  static User employee({String? id, String? storeId}) => create(
    id: id,
    name: 'موظف',
    role: UserRole.employee,
    storeId: storeId ?? 'store-1',
  );

  static User delivery({String? id}) =>
      create(id: id, name: 'سائق توصيل', role: UserRole.delivery);

  static User superAdmin({String? id}) =>
      create(id: id, name: 'مدير النظام', role: UserRole.superAdmin);

  static void reset() => _counter = 0;
}

/// مصنع بيانات المنتجات
class ProductFactory {
  static int _counter = 0;

  static Product create({
    String? id,
    String? storeId,
    String? name,
    String? sku,
    String? barcode,
    int? price, // C-4 Stage B: SAR × 100 = cents
    int? costPrice,
    double? stockQty,
    double? minQty,
    String? categoryId,
    bool? isActive,
    DateTime? createdAt,
  }) {
    _counter++;
    return Product(
      id: id ?? 'product-$_counter',
      storeId: storeId ?? 'store-1',
      name: name ?? 'منتج $_counter',
      sku: sku,
      barcode: barcode,
      price: price ?? 1000 * _counter,
      costPrice: costPrice,
      stockQty: stockQty ?? 100,
      minQty: minQty ?? 5,
      categoryId: categoryId,
      isActive: isActive ?? true,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  static Product inStock({String? id, double? qty}) =>
      create(id: id, stockQty: qty ?? 100);

  static Product lowStock({String? id}) =>
      create(id: id, stockQty: 3, minQty: 5);

  static Product outOfStock({String? id}) => create(id: id, stockQty: 0);

  static Product withProfit({String? id, int? price, int? costPrice}) =>
      create(id: id, price: price ?? 10000, costPrice: costPrice ?? 7000);

  static List<Product> createList(int count, {String? storeId}) {
    return List.generate(count, (i) => create(storeId: storeId));
  }

  static void reset() => _counter = 0;
}

/// مصنع بيانات الطلبات
class OrderFactory {
  static int _counter = 0;

  static Order create({
    String? id,
    String? orderNumber,
    String? customerId,
    String? storeId,
    OrderStatus? status,
    List<OrderItem>? items,
    double? subtotal,
    double? discount,
    double? deliveryFee,
    double? total,
    PaymentMethod? paymentMethod,
    bool? isPaid,
    DateTime? createdAt,
  }) {
    _counter++;
    final orderItems = items ?? [OrderItemFactory.create()];
    final double sub =
        subtotal ?? orderItems.fold<double>(0.0, (sum, i) => sum + i.lineTotal);

    return Order(
      id: id ?? 'order-$_counter',
      orderNumber: orderNumber ?? 'ORD-$_counter',
      customerId: customerId ?? 'customer-1',
      storeId: storeId ?? 'store-1',
      status: status ?? OrderStatus.created,
      items: orderItems,
      subtotal: sub,
      discount: discount ?? 0,
      deliveryFee: deliveryFee ?? 0,
      total: total ?? (sub - (discount ?? 0.0) + (deliveryFee ?? 0.0)),
      paymentMethod: paymentMethod ?? PaymentMethod.cash,
      isPaid: isPaid ?? false,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  static Order pending({String? id}) =>
      create(id: id, status: OrderStatus.created);

  static Order confirmed({String? id}) =>
      create(id: id, status: OrderStatus.confirmed);

  static Order preparing({String? id}) =>
      create(id: id, status: OrderStatus.preparing);

  static Order delivered({String? id}) =>
      create(id: id, status: OrderStatus.delivered, isPaid: true);

  static Order cancelled({String? id, String? reason}) =>
      create(id: id, status: OrderStatus.cancelled);

  static void reset() => _counter = 0;
}

/// مصنع عناصر الطلب
class OrderItemFactory {
  static int _counter = 0;

  static OrderItem create({
    String? productId,
    String? name,
    double? unitPrice,
    int? qty,
    double? lineTotal,
  }) {
    _counter++;
    final q = qty ?? 1;
    final p = unitPrice ?? 25.0;

    return OrderItem(
      productId: productId ?? 'product-$_counter',
      name: name ?? 'منتج $_counter',
      unitPrice: p,
      qty: q,
      lineTotal: lineTotal ?? (q * p),
    );
  }

  static List<OrderItem> createList(int count) {
    return List.generate(count, (i) => create());
  }

  static void reset() => _counter = 0;
}

/// مصنع بيانات المتاجر
class StoreFactory {
  static int _counter = 0;

  static Store create({
    String? id,
    String? name,
    String? address,
    String? phone,
    double? lat,
    double? lng,
    bool? isActive,
    String? ownerId,
    double? deliveryRadius,
    double? minOrderAmount,
    double? deliveryFee,
    DateTime? createdAt,
  }) {
    _counter++;
    return Store(
      id: id ?? 'store-$_counter',
      name: name ?? 'متجر $_counter',
      address: address ?? 'الرياض، شارع $_counter',
      phone: phone,
      lat: lat ?? 24.7136 + (_counter * 0.01),
      lng: lng ?? 46.6753 + (_counter * 0.01),
      isActive: isActive ?? true,
      ownerId: ownerId ?? 'owner-$_counter',
      deliveryRadius: deliveryRadius,
      minOrderAmount: minOrderAmount,
      deliveryFee: deliveryFee,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  static Store active({String? id}) => create(id: id, isActive: true);

  static Store inactive({String? id}) => create(id: id, isActive: false);

  static void reset() => _counter = 0;
}

/// مصنع بيانات التصنيفات
class CategoryFactory {
  static int _counter = 0;

  static Category create({
    String? id,
    String? name,
    String? parentId,
    int? sortOrder,
    bool? isActive,
  }) {
    _counter++;
    return Category(
      id: id ?? 'category-$_counter',
      name: name ?? 'تصنيف $_counter',
      parentId: parentId,
      sortOrder: sortOrder ?? _counter,
      isActive: isActive ?? true,
    );
  }

  static List<Category> createList(int count) {
    return List.generate(count, (i) => create());
  }

  static void reset() => _counter = 0;
}

/// مصنع بيانات التوكنات
class AuthTokensFactory {
  static AuthTokens createModel({
    String? accessToken,
    String? refreshToken,
    DateTime? expiresAt,
  }) {
    return AuthTokens(
      accessToken:
          accessToken ??
          'test-access-token-${DateTime.now().millisecondsSinceEpoch}',
      refreshToken:
          refreshToken ??
          'test-refresh-token-${DateTime.now().millisecondsSinceEpoch}',
      expiresAt: expiresAt ?? DateTime.now().add(const Duration(hours: 1)),
    );
  }

  static AuthTokensEntity createEntity({
    String? accessToken,
    String? refreshToken,
    String? expiresAt,
  }) {
    return AuthTokensEntity(
      accessToken: accessToken ?? 'test-access-token',
      refreshToken: refreshToken ?? 'test-refresh-token',
      expiresAt:
          expiresAt ??
          DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
    );
  }

  static AuthTokensEntity expiredEntity() {
    return AuthTokensEntity(
      accessToken: 'expired-access-token',
      refreshToken: 'expired-refresh-token',
      expiresAt: DateTime.now()
          .subtract(const Duration(hours: 1))
          .toIso8601String(),
    );
  }

  static AuthTokensResponse createResponse({
    String? accessToken,
    String? refreshToken,
    String? expiresAt,
  }) {
    return AuthTokensResponse(
      accessToken: accessToken ?? 'test-access-token',
      refreshToken: refreshToken ?? 'test-refresh-token',
      expiresAt:
          expiresAt ??
          DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
    );
  }
}

/// مصنع بيانات نتيجة المصادقة
class AuthResultFactory {
  static AuthResult create({User? user, AuthTokens? tokens}) {
    return AuthResult(
      user: user ?? UserFactory.customer(),
      tokens: tokens ?? AuthTokensFactory.createModel(),
    );
  }

  static AuthResponse createResponse({
    UserResponse? user,
    AuthTokensResponse? tokens,
  }) {
    return AuthResponse(
      user: user ?? UserResponseFactory.create(),
      tokens: tokens ?? AuthTokensFactory.createResponse(),
    );
  }
}

/// مصنع UserResponse
class UserResponseFactory {
  static int _counter = 0;

  static UserResponse create({
    String? id,
    String? phone,
    String? name,
    String? role,
    String? createdAt,
  }) {
    _counter++;
    return UserResponse(
      id: id ?? 'user-$_counter',
      phone: phone ?? '+9665000000$_counter',
      name: name ?? 'مستخدم $_counter',
      role: role ?? 'customer',
      createdAt: createdAt ?? DateTime.now().toIso8601String(),
    );
  }

  static void reset() => _counter = 0;
}

/// مصنع UserEntity
class UserEntityFactory {
  static int _counter = 0;

  static UserEntity create({
    String? id,
    String? phone,
    String? name,
    String? role,
    String? createdAt,
  }) {
    _counter++;
    return UserEntity(
      id: id ?? 'user-$_counter',
      phone: phone ?? '+9665000000$_counter',
      name: name ?? 'مستخدم $_counter',
      role: role ?? 'customer',
      createdAt: createdAt ?? DateTime.now().toIso8601String(),
    );
  }

  static void reset() => _counter = 0;
}

/// إعادة تعيين جميع المصانع
void resetAllFactories() {
  UserFactory.reset();
  ProductFactory.reset();
  OrderFactory.reset();
  OrderItemFactory.reset();
  StoreFactory.reset();
  CategoryFactory.reset();
  UserResponseFactory.reset();
  UserEntityFactory.reset();
}
