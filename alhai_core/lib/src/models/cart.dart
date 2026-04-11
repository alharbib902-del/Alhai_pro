import 'package:freezed_annotation/freezed_annotation.dart';

import 'order_item.dart';

part 'cart.freezed.dart';
part 'cart.g.dart';

/// Cart domain model for local cart management
@freezed
class Cart with _$Cart {
  const Cart._();

  const factory Cart({
    @Default([]) List<CartItem> items,
    String? storeId,
    String? notes,
  }) = _Cart;

  factory Cart.fromJson(Map<String, dynamic> json) => _$CartFromJson(json);

  /// Calculate cart total
  double get total => items.fold(0, (sum, item) => sum + item.lineTotal);

  /// Get total items count
  int get itemCount => items.fold(0, (sum, item) => sum + item.qty);

  /// Check if cart is empty
  bool get isEmpty => items.isEmpty;

  /// Check if cart is not empty
  bool get isNotEmpty => items.isNotEmpty;
}

/// Cart item model
@freezed
class CartItem with _$CartItem {
  const CartItem._();

  const factory CartItem({
    required String productId,
    required String name,
    required double unitPrice,
    required int qty,
    String? imageUrl,
    String? notes,
  }) = _CartItem;

  factory CartItem.fromJson(Map<String, dynamic> json) =>
      _$CartItemFromJson(json);

  /// Calculate line total
  double get lineTotal => unitPrice * qty;

  /// Convert to OrderItem for checkout
  OrderItem toOrderItem() => OrderItem(
    productId: productId,
    name: name,
    unitPrice: unitPrice,
    qty: qty,
    lineTotal: lineTotal,
  );
}
