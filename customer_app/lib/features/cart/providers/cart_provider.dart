import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alhai_core/alhai_core.dart';

import '../../../core/services/sentry_service.dart';

const _cartKey = 'customer_cart';

/// Cart state provider with persistence.
final cartProvider = StateNotifierProvider<CartNotifier, Cart>((ref) {
  return CartNotifier();
});

/// Whether the cart has finished loading from disk.
final cartLoadedProvider = FutureProvider<bool>((ref) async {
  final notifier = ref.read(cartProvider.notifier);
  await notifier.loadFromDisk();
  return true;
});

class CartNotifier extends StateNotifier<Cart> {
  bool _loaded = false;
  bool _loading = false;
  bool _saving = false;

  CartNotifier() : super(const Cart()) {
    loadFromDisk();
  }

  Future<void> loadFromDisk() async {
    if (_loaded || _loading) return;
    _loading = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_cartKey);
      if (json != null && mounted) {
        state = Cart.fromJson(jsonDecode(json) as Map<String, dynamic>);
      }
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('[CartProvider] Error loading cart from disk: $e');
      }
      reportError(e, stackTrace: stack, hint: 'CartProvider.loadFromDisk');
    } finally {
      _loaded = true;
      _loading = false;
    }
  }

  Future<void> _saveToDisk() async {
    if (_saving) return;
    _saving = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cartKey, jsonEncode(state.toJson()));
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('[CartProvider] Error saving cart to disk: $e');
      }
      reportError(e, stackTrace: stack, hint: 'CartProvider._saveToDisk');
    } finally {
      _saving = false;
    }
  }

  /// Add a product to cart.
  /// Returns `true` if added, `false` if store mismatch (cart not cleared).
  /// When `false`, the UI should show a confirmation dialog then call
  /// [clearAndSwitchStore] before retrying.
  bool addItem(Product product, String storeId) {
    // Single-store constraint — don't silently clear
    if (state.storeId != null && state.storeId != storeId && state.isNotEmpty) {
      return false;
    }

    final existing = state.items.indexWhere(
      (item) => item.productId == product.id,
    );

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

    state = state.copyWith(items: updatedItems, storeId: storeId);
    _saveToDisk();
    return true;
  }

  /// Clear the cart and switch to a new store.
  /// Call this after the user confirms they want to discard the current cart.
  void clearAndSwitchStore(String newStoreId) {
    state = Cart(storeId: newStoreId, items: []);
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
    final updatedItems = state.items
        .where((item) => item.productId != productId)
        .toList();
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
