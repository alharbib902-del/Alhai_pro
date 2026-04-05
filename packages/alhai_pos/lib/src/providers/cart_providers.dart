/// مزودات السلة - Cart Providers
///
/// توفر حالة سلة المشتريات لنقطة البيع مع دعم:
/// - حفظ السلة تلقائياً (مع debounce 2 ثانية)
/// - استعادة السلة عند إعادة فتح التطبيق مع تأكيد
/// - تعليق الفواتير (Hold Invoice)
library cart_providers;

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alhai_core/alhai_core.dart' hide CartItem;

// ============================================================================
// CONSTANTS
// ============================================================================

const String _cartStorageKey = 'pos_cart_state';
const String _heldInvoicesKey = 'pos_held_invoices';

// ============================================================================
// POS CART ITEM
// ============================================================================

/// عنصر في السلة (POS) - يحتوي على المنتج الكامل مع إمكانية السعر المخصص
class PosCartItem {
  final Product product;
  final int quantity;
  final double? customPrice;

  const PosCartItem({
    required this.product,
    this.quantity = 1,
    this.customPrice,
  });

  /// السعر الفعلي (مخصص أو الأصلي)
  double get effectivePrice => customPrice ?? product.price;

  /// إجمالي سعر العنصر
  double get total => effectivePrice * quantity;

  PosCartItem copyWith({
    Product? product,
    int? quantity,
    double? customPrice,
    bool clearCustomPrice = false,
  }) {
    return PosCartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      customPrice: clearCustomPrice ? null : (customPrice ?? this.customPrice),
    );
  }

  /// تحويل لـ JSON للتخزين
  Map<String, dynamic> toJson() => {
        'product': product.toJson(),
        'quantity': quantity,
        'customPrice': customPrice,
      };

  /// إنشاء من JSON
  factory PosCartItem.fromJson(Map<String, dynamic> json) {
    return PosCartItem(
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int? ?? 1,
      customPrice: json['customPrice'] as double?,
    );
  }
}

// ============================================================================
// CART STATE
// ============================================================================

/// حالة السلة
class CartState {
  final List<PosCartItem> items;
  final double discount;
  final PaymentMethod paymentMethod;
  final String? customerId;
  final String? customerName;
  final String? customerPhone;
  final String? notes;
  final DateTime? lastModified;

  const CartState({
    this.items = const [],
    this.discount = 0,
    this.paymentMethod = PaymentMethod.cash,
    this.customerId,
    this.customerName,
    this.customerPhone,
    this.notes,
    this.lastModified,
  });

  /// عدد العناصر الإجمالي
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  /// عدد المنتجات المختلفة
  int get uniqueItemCount => items.length;

  /// المجموع الفرعي (قبل الخصم)
  double get subtotal => items.fold(0.0, (sum, item) => sum + item.total);

  /// الإجمالي (بعد الخصم)
  double get total => subtotal - discount;

  /// هل السلة فارغة
  bool get isEmpty => items.isEmpty;

  /// هل السلة غير فارغة
  bool get isNotEmpty => items.isNotEmpty;

  CartState copyWith({
    List<PosCartItem>? items,
    double? discount,
    PaymentMethod? paymentMethod,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? notes,
    DateTime? lastModified,
    bool clearCustomer = false,
  }) {
    return CartState(
      items: items ?? this.items,
      discount: discount ?? this.discount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      customerId: clearCustomer ? null : (customerId ?? this.customerId),
      customerName: clearCustomer ? null : (customerName ?? this.customerName),
      customerPhone: clearCustomer ? null : (customerPhone ?? this.customerPhone),
      notes: notes ?? this.notes,
      lastModified: lastModified ?? DateTime.now(),
    );
  }

  /// تحويل لـ JSON للتخزين
  Map<String, dynamic> toJson() => {
        'items': items.map((item) => item.toJson()).toList(),
        'discount': discount,
        'paymentMethod': paymentMethod.name,
        'customerId': customerId,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'notes': notes,
        'lastModified': lastModified?.toIso8601String(),
      };

  /// إنشاء من JSON
  factory CartState.fromJson(Map<String, dynamic> json) {
    return CartState(
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => PosCartItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == json['paymentMethod'],
        orElse: () => PaymentMethod.cash,
      ),
      customerId: json['customerId'] as String?,
      customerName: json['customerName'] as String?,
      customerPhone: json['customerPhone'] as String?,
      notes: json['notes'] as String?,
      lastModified: json['lastModified'] != null
          ? DateTime.tryParse(json['lastModified'] as String)
          : null,
    );
  }
}

// ============================================================================
// HELD INVOICE (فاتورة معلقة)
// ============================================================================

/// فاتورة معلقة
class HeldInvoice {
  final String id;
  final CartState cart;
  final String? name;
  final DateTime createdAt;

  const HeldInvoice({
    required this.id,
    required this.cart,
    this.name,
    required this.createdAt,
  });

  /// وصف الفاتورة
  String get description {
    if (name != null && name!.isNotEmpty) return name!;
    if (cart.customerName != null) return cart.customerName!;
    return 'فاتورة ${cart.itemCount} عناصر';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'cart': cart.toJson(),
        'name': name,
        'createdAt': createdAt.toIso8601String(),
      };

  factory HeldInvoice.fromJson(Map<String, dynamic> json) {
    return HeldInvoice(
      id: json['id'] as String,
      cart: CartState.fromJson(json['cart'] as Map<String, dynamic>),
      name: json['name'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

// ============================================================================
// CART PERSISTENCE SERVICE
// ============================================================================

/// خدمة حفظ السلة
class CartPersistenceService {
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// حفظ السلة
  Future<void> saveCart(CartState cart) async {
    try {
      final prefs = await _preferences;
      final json = jsonEncode(cart.toJson());
      await prefs.setString(_cartStorageKey, json);
    } catch (e) {
      debugPrint('[CartPersistence] Error saving cart: $e');
    }
  }

  /// استعادة السلة
  Future<CartState?> loadCart() async {
    try {
      final prefs = await _preferences;
      final json = prefs.getString(_cartStorageKey);
      if (json == null || json.isEmpty) return null;

      final data = jsonDecode(json) as Map<String, dynamic>;
      return CartState.fromJson(data);
    } catch (e) {
      debugPrint('[CartPersistence] Error loading cart: $e');
      return null;
    }
  }

  /// مسح السلة المحفوظة
  Future<void> clearCart() async {
    try {
      final prefs = await _preferences;
      await prefs.remove(_cartStorageKey);
    } catch (e) {
      debugPrint('[CartPersistence] Error clearing cart: $e');
    }
  }

  /// حفظ فاتورة معلقة
  Future<void> saveHeldInvoice(HeldInvoice invoice) async {
    try {
      final invoices = await loadHeldInvoices();
      invoices.add(invoice);
      await _saveHeldInvoices(invoices);
    } catch (e) {
      debugPrint('[CartPersistence] Error saving held invoice: $e');
    }
  }

  /// استعادة الفواتير المعلقة
  Future<List<HeldInvoice>> loadHeldInvoices() async {
    try {
      final prefs = await _preferences;
      final json = prefs.getString(_heldInvoicesKey);
      if (json == null || json.isEmpty) return [];

      final list = jsonDecode(json) as List<dynamic>;
      return list
          .map((e) => HeldInvoice.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[CartPersistence] Error loading held invoices: $e');
      return [];
    }
  }

  /// حذف فاتورة معلقة
  Future<void> deleteHeldInvoice(String id) async {
    try {
      final invoices = await loadHeldInvoices();
      invoices.removeWhere((inv) => inv.id == id);
      await _saveHeldInvoices(invoices);
    } catch (e) {
      debugPrint('[CartPersistence] Error deleting held invoice: $e');
    }
  }

  Future<void> _saveHeldInvoices(List<HeldInvoice> invoices) async {
    final prefs = await _preferences;
    final json = jsonEncode(invoices.map((e) => e.toJson()).toList());
    await prefs.setString(_heldInvoicesKey, json);
  }
}

// ============================================================================
// UNDO STACK
// ============================================================================

/// نوع الإجراء القابل للتراجع
enum CartUndoType { add, remove, quantityChange }

/// إجراء واحد يمكن التراجع عنه
class UndoAction {
  final CartUndoType type;
  final String productId;
  final String productName;
  final Product? product; // needed to re-add after remove
  final int? previousQuantity; // for qty changes
  final int? newQuantity; // for qty changes
  final double? customPrice; // preserve custom price on re-add

  const UndoAction({
    required this.type,
    required this.productId,
    required this.productName,
    this.product,
    this.previousQuantity,
    this.newQuantity,
    this.customPrice,
  });
}

// ============================================================================
// CART NOTIFIER
// ============================================================================

/// مُدير حالة السلة مع دعم الحفظ التلقائي (debounce 2 ثانية)
class CartNotifier extends StateNotifier<CartState> {
  final CartPersistenceService _persistence;
  bool _isInitialized = false;
  Timer? _debounceTimer;

  /// Undo stack — max 10 actions
  static const int _maxUndoActions = 10;
  final List<UndoAction> _undoStack = [];

  /// سلة محفوظة بانتظار تأكيد المستخدم
  CartState? _pendingDraft;

  CartNotifier(this._persistence) : super(const CartState()) {
    _init();
  }

  /// تهيئة — يحمّل السلة المحفوظة لكن لا يستعيدها تلقائياً
  /// بل يحفظها في [_pendingDraft] لحين تأكيد المستخدم
  Future<void> _init() async {
    if (_isInitialized) return;

    final savedCart = await _persistence.loadCart();
    if (savedCart != null && savedCart.isNotEmpty) {
      _pendingDraft = savedCart;
      debugPrint(
          '[Cart] Found draft with ${savedCart.itemCount} items — awaiting user confirmation');
    }
    _isInitialized = true;
  }

  /// هل يوجد مسودة محفوظة بانتظار التأكيد
  bool get hasPendingDraft => _pendingDraft != null;

  /// عدد عناصر المسودة المعلقة
  int get pendingDraftItemCount => _pendingDraft?.itemCount ?? 0;

  /// إجمالي المسودة المعلقة
  double get pendingDraftTotal => _pendingDraft?.total ?? 0;

  /// قبول المسودة المحفوظة واستعادتها
  void acceptDraft() {
    if (_pendingDraft != null) {
      state = _pendingDraft!;
      _pendingDraft = null;
      debugPrint('[Cart] Draft restored — ${state.itemCount} items');
    }
  }

  /// تجاهل المسودة المحفوظة ومسحها
  void discardDraft() {
    _pendingDraft = null;
    _persistence.clearCart();
    debugPrint('[Cart] Draft discarded');
  }

  /// حفظ السلة مع debounce (2 ثانية) — يُستدعى تلقائياً عند التغيير
  void _saveCart() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 2), () {
      _persistence.saveCart(state);
    });
  }

  @override
  void dispose() {
    // حفظ فوري عند الإغلاق (بدون debounce)
    _debounceTimer?.cancel();
    _persistence.saveCart(state);
    super.dispose();
  }

  // --------------------------------------------------------------------------
  // Undo helpers
  // --------------------------------------------------------------------------

  void _pushUndo(UndoAction action) {
    _undoStack.add(action);
    if (_undoStack.length > _maxUndoActions) {
      _undoStack.removeAt(0);
    }
  }

  /// Whether there are actions that can be undone.
  bool get canUndo => _undoStack.isNotEmpty;

  /// Pop the last action and reverse it. Returns the action for SnackBar display,
  /// or null if the stack was empty.
  UndoAction? undo() {
    if (_undoStack.isEmpty) return null;
    final action = _undoStack.removeLast();

    switch (action.type) {
      case CartUndoType.add:
        // Undo an add → remove the product (or reduce qty if it was an increment)
        final existingIndex = state.items.indexWhere(
          (item) => item.product.id == action.productId,
        );
        if (existingIndex >= 0) {
          final existing = state.items[existingIndex];
          if (existing.quantity > 1 && action.previousQuantity != null) {
            // Was an existing item that got its qty bumped
            final updatedItems = [...state.items];
            updatedItems[existingIndex] = existing.copyWith(
              quantity: action.previousQuantity!,
            );
            state = state.copyWith(items: updatedItems);
          } else {
            // Was a brand new item → remove entirely
            state = state.copyWith(
              items: state.items
                  .where(
                    (item) => item.product.id != action.productId,
                  )
                  .toList(),
            );
          }
        }

      case CartUndoType.remove:
        // Undo a remove → re-add the product
        if (action.product != null) {
          state = state.copyWith(
            items: [
              ...state.items,
              PosCartItem(
                product: action.product!,
                quantity: action.previousQuantity ?? 1,
                customPrice: action.customPrice,
              ),
            ],
          );
        }

      case CartUndoType.quantityChange:
        // Undo a quantity change → revert to previous quantity
        if (action.previousQuantity != null) {
          if (action.previousQuantity! <= 0) {
            // Was removed due to qty going to 0 → re-add
            if (action.product != null) {
              state = state.copyWith(
                items: [
                  ...state.items,
                  PosCartItem(
                    product: action.product!,
                    quantity: 1,
                    customPrice: action.customPrice,
                  ),
                ],
              );
            }
          } else {
            final updatedItems = state.items.map((item) {
              if (item.product.id == action.productId) {
                return item.copyWith(quantity: action.previousQuantity!);
              }
              return item;
            }).toList();
            state = state.copyWith(items: updatedItems);
          }
        }
    }

    _saveCart();
    return action;
  }

  /// Clear the undo stack (e.g. after payment or cart clear).
  void clearUndoStack() => _undoStack.clear();

  /// Max quantity per item
  static const int _maxQuantityPerItem = 9999;

  /// إضافة منتج للسلة
  void addProduct(Product product, {int quantity = 1, double? customPrice}) {
    final existingIndex = state.items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex >= 0) {
      // تحديث الكمية إذا كان موجود
      final updatedItems = [...state.items];
      final existingItem = updatedItems[existingIndex];
      // Clamp new quantity to max
      final newQty =
          (existingItem.quantity + quantity).clamp(1, _maxQuantityPerItem);
      if (newQty == existingItem.quantity) return; // already at max
      _pushUndo(UndoAction(
        type: CartUndoType.add,
        productId: product.id,
        productName: product.name,
        product: product,
        previousQuantity: existingItem.quantity,
      ));
      updatedItems[existingIndex] = existingItem.copyWith(
        quantity: newQty,
        customPrice: customPrice ?? existingItem.customPrice,
      );
      state = state.copyWith(items: updatedItems);
    } else {
      // إضافة عنصر جديد — clamp quantity to max
      final clampedQty = quantity.clamp(1, _maxQuantityPerItem);
      _pushUndo(UndoAction(
        type: CartUndoType.add,
        productId: product.id,
        productName: product.name,
        product: product,
      ));
      state = state.copyWith(
        items: [
          ...state.items,
          PosCartItem(
            product: product,
            quantity: clampedQty,
            customPrice: customPrice,
          ),
        ],
      );
    }
    _saveCart();
  }

  /// إزالة منتج من السلة
  void removeProduct(String productId) {
    final removedItem = state.items
        .where(
          (item) => item.product.id == productId,
        )
        .firstOrNull;
    if (removedItem != null) {
      _pushUndo(UndoAction(
        type: CartUndoType.remove,
        productId: productId,
        productName: removedItem.product.name,
        product: removedItem.product,
        previousQuantity: removedItem.quantity,
        customPrice: removedItem.customPrice,
      ));
    }
    state = state.copyWith(
      items: state.items.where((item) => item.product.id != productId).toList(),
    );
    _saveCart();
  }

  /// تحديث كمية منتج
  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeProduct(productId);
      return;
    }

    // Clamp to max quantity per item
    final clampedQty = quantity.clamp(1, _maxQuantityPerItem);

    final existing = state.items
        .where(
          (item) => item.product.id == productId,
        )
        .firstOrNull;
    if (existing != null) {
      if (clampedQty == existing.quantity) return; // no change
      _pushUndo(UndoAction(
        type: CartUndoType.quantityChange,
        productId: productId,
        productName: existing.product.name,
        product: existing.product,
        previousQuantity: existing.quantity,
        newQuantity: clampedQty,
        customPrice: existing.customPrice,
      ));
    }

    final updatedItems = state.items.map((item) {
      if (item.product.id == productId) {
        return item.copyWith(quantity: clampedQty);
      }
      return item;
    }).toList();

    state = state.copyWith(items: updatedItems);
    _saveCart();
  }

  /// زيادة كمية منتج
  void incrementQuantity(String productId) {
    final item = state.items.firstWhere(
      (item) => item.product.id == productId,
      orElse: () => throw Exception('Product not in cart'),
    );
    updateQuantity(productId, item.quantity + 1);
  }

  /// إنقاص كمية منتج
  void decrementQuantity(String productId) {
    final item = state.items.firstWhere(
      (item) => item.product.id == productId,
      orElse: () => throw Exception('Product not in cart'),
    );
    updateQuantity(productId, item.quantity - 1);
  }

  /// تعيين سعر مخصص
  void setCustomPrice(String productId, double? price) {
    // Validate: price must be null (clear) or within [0, 999999]
    if (price != null) {
      if (price < 0 || price > 999999) return; // ignore invalid price
    }

    final updatedItems = state.items.map((item) {
      if (item.product.id == productId) {
        return item.copyWith(
          customPrice: price,
          clearCustomPrice: price == null,
        );
      }
      return item;
    }).toList();

    state = state.copyWith(items: updatedItems);
    _saveCart();
  }

  /// تعيين الخصم
  void setDiscount(double discount) {
    // Validate: discount must be >= 0 and <= subtotal (clamp to range)
    final clamped = discount.clamp(0.0, state.subtotal);
    state = state.copyWith(discount: clamped);
    _saveCart();
  }

  /// تعيين طريقة الدفع
  void setPaymentMethod(PaymentMethod method) {
    state = state.copyWith(paymentMethod: method);
    _saveCart();
  }

  /// تعيين العميل
  void setCustomer(String? customerId, {String? customerName}) {
    state = state.copyWith(
      customerId: customerId,
      customerName: customerName,
      clearCustomer: customerId == null,
    );
    _saveCart();
  }

  /// تعيين رقم جوال العميل
  void setCustomerPhone(String? phone) {
    state = state.copyWith(customerPhone: phone);
    _saveCart();
  }

  /// تعيين الملاحظات
  void setNotes(String? notes) {
    state = state.copyWith(notes: notes);
    _saveCart();
  }

  /// تفريغ السلة
  void clear() {
    state = const CartState();
    _undoStack.clear();
    _persistence.clearCart();
  }

  /// تعليق الفاتورة الحالية
  Future<HeldInvoice> holdInvoice({String? name}) async {
    final invoice = HeldInvoice(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      cart: state,
      name: name,
      createdAt: DateTime.now(),
    );

    await _persistence.saveHeldInvoice(invoice);
    clear();

    return invoice;
  }

  /// استعادة فاتورة معلقة
  Future<void> restoreInvoice(HeldInvoice invoice) async {
    // إذا كانت السلة الحالية غير فارغة، نعلقها أولاً
    if (state.isNotEmpty) {
      await holdInvoice(name: 'تلقائي - ${DateTime.now()}');
    }

    state = invoice.cart;
    await _persistence.deleteHeldInvoice(invoice.id);
    _saveCart();
  }

  /// استعادة حالة سلة مباشرة (تُستخدم من DB-backed held invoices)
  void restoreFromCart(CartState cart) {
    state = cart;
    _saveCart();
  }
}

// ============================================================================
// HELD INVOICES NOTIFIER
// ============================================================================

/// مُدير الفواتير المعلقة
class HeldInvoicesNotifier extends StateNotifier<List<HeldInvoice>> {
  final CartPersistenceService _persistence;

  HeldInvoicesNotifier(this._persistence) : super([]) {
    _load();
  }

  Future<void> _load() async {
    state = await _persistence.loadHeldInvoices();
  }

  Future<void> refresh() async {
    await _load();
  }

  Future<void> delete(String id) async {
    await _persistence.deleteHeldInvoice(id);
    state = state.where((inv) => inv.id != id).toList();
  }
}

// ============================================================================
// PROVIDERS
// ============================================================================

/// مزود خدمة الحفظ
final cartPersistenceProvider = Provider<CartPersistenceService>((ref) {
  return CartPersistenceService();
});

/// مزود حالة السلة
final cartStateProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  final persistence = ref.watch(cartPersistenceProvider);
  return CartNotifier(persistence);
});

/// مزود الفواتير المعلقة
final heldInvoicesProvider =
    StateNotifierProvider<HeldInvoicesNotifier, List<HeldInvoice>>((ref) {
  final persistence = ref.watch(cartPersistenceProvider);
  return HeldInvoicesNotifier(persistence);
});

/// مزود عناصر السلة (اختصار)
final cartItemsProvider = Provider<List<PosCartItem>>((ref) {
  return ref.watch(cartStateProvider).items;
});

/// مزود هل السلة فارغة
final isCartEmptyProvider = Provider<bool>((ref) {
  return ref.watch(cartStateProvider).isEmpty;
});

/// مزود الحصول على عنصر سلة بـ ID المنتج
final cartItemByProductIdProvider =
    Provider.autoDispose.family<PosCartItem?, String>((ref, productId) {
  final items = ref.watch(cartItemsProvider);
  try {
    return items.firstWhere((item) => item.product.id == productId);
  } catch (_) {
    return null;
  }
});

/// مزود عدد الفواتير المعلقة
final heldInvoicesCountProvider = Provider<int>((ref) {
  return ref.watch(heldInvoicesProvider).length;
});
