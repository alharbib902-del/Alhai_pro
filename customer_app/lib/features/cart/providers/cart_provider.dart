import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alhai_core/alhai_core.dart';

const _cartKey = 'customer_cart';

/// Cart state provider with persistence.
final cartProvider = StateNotifierProvider<CartNotifier, Cart>((ref) {
  return CartNotifier();
});

class CartNotifier extends StateNotifier<Cart> {
  CartNotifier() : super(const Cart()) {
    _loadFromDisk();
  }

  Future<void> _loadFromDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_cartKey);
      if (json != null) {
        state = Cart.fromJson(jsonDecode(json) as Map<String, dynamic>);
      }
    } catch (_) {}
  }

  Future<void> _saveToDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cartKey, jsonEncode(state.toJson()));
    } catch (_) {}
  }

  /// Add a product to cart. If from different store, clears cart first.
  void addItem(Product product, String storeId) {
    // Single-store constraint
    if (state.storeId != null && state.storeId != storeId && state.isNotEmpty) {
      // Clear cart for new store
      state = Cart(storeId: storeId, items: []);
    }

    final existing = state.items
        .indexWhere((item) => item.productId == product.id);

    List<CartItem> updatedItems;
    if (existing >= 0) {
      updatedItems = [...state.items];
      final item = updatedItems[existing];
      updatedItems[existing] = item.copyWith(qty: item.qty + 1);
    } else {
      updatedItems = [
        ...state.items,
        CartItem(
          productId: product.id,
          name: product.name,
          unitPrice: product.price,
          qty: 1,
          imageUrl: product.imageThumbnail,
        ),
      ];
    }

    state = state.copyWith(
      items: updatedItems,
      storeId: storeId,
    );
    _saveToDisk();
  }

  /// Update quantity for a product.
  void updateQty(String productId, int qty) {
    if (qty <= 0) {
      removeItem(productId);
      return;
    }

    final updatedItems = state.items.map((item) {
      if (item.productId == productId) {
        return item.copyWith(qty: qty);
      }
      return item;
    }).toList();

    state = state.copyWith(items: updatedItems);
    _saveToDisk();
  }

  /// Remove a product from cart.
  void removeItem(String productId) {
    final updatedItems =
        state.items.where((item) => item.productId != productId).toList();
    state = state.copyWith(items: updatedItems);
    if (state.isEmpty) {
      state = const Cart();
    }
    _saveToDisk();
  }

  /// Clear the entire cart.
  void clear() {
    state = const Cart();
    _saveToDisk();
  }
}
