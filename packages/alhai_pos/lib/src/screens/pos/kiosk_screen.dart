/// شاشة وضع الكشك الذاتي - Kiosk Mode Screen
///
/// شاشة طلب ذاتي للعملاء في المطاعم والكافيتريات والصيدليات
/// تعمل بدون كاشير - يطلب العميل مباشرة
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'dart:convert';

import 'package:drift/drift.dart' hide Column;
import 'package:uuid/uuid.dart';

/// شاشة وضع الكشك الذاتي
class KioskScreen extends ConsumerStatefulWidget {
  const KioskScreen({super.key});

  @override
  ConsumerState<KioskScreen> createState() => _KioskScreenState();
}

class _KioskScreenState extends ConsumerState<KioskScreen> {
  bool _isLoading = true;
  List<_KioskCategory> _categories = [];
  List<_KioskProduct> _products = [];
  String _selectedCategory = 'all';
  final List<_CartItem> _cart = [];
  bool _showCart = false;
  bool _orderPlaced = false;

  double get _subtotal => _cart.fold(0, (s, i) => s + i.total);

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final db = GetIt.I<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final cats = await db.customSelect(
        'SELECT DISTINCT category FROM products WHERE store_id = ? AND is_active = 1 AND category IS NOT NULL',
        variables: [Variable.withString(storeId)],
      ).get();

      final prods = await db.customSelect(
        '''SELECT id, name, price, description, category, image_url, current_stock
           FROM products WHERE store_id = ? AND is_active = 1 AND current_stock > 0
           ORDER BY category, name LIMIT 100''',
        variables: [Variable.withString(storeId)],
      ).get();

      if (mounted) {
        setState(() {
          _categories = [
            const _KioskCategory(id: 'all', name: ''),
            ...cats.map((r) => _KioskCategory(
              id: r.data['category'] as String,
              name: r.data['category'] as String,
            )),
          ];
          _products = prods.map((r) => _KioskProduct(
            id: r.data['id'] as String,
            name: r.data['name'] as String,
            price: _toDouble(r.data['price']),
            description: r.data['description'] as String? ?? '',
            category: r.data['category'] as String? ?? '',
            imageUrl: r.data['image_url'] as String? ?? '',
          )).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  double _toDouble(dynamic v) {
    if (v is int) return v.toDouble();
    if (v is double) return v;
    return 0.0;
  }

  List<_KioskProduct> get _filteredProducts => _selectedCategory == 'all'
      ? _products
      : _products.where((p) => p.category == _selectedCategory).toList();

  void _addToCart(_KioskProduct product) {
    setState(() {
      final existing = _cart.where((i) => i.productId == product.id);
      if (existing.isNotEmpty) {
        final idx = _cart.indexOf(existing.first);
        _cart[idx] = _cart[idx].copyWith(qty: _cart[idx].qty + 1);
      } else {
        _cart.add(_CartItem(
          productId: product.id,
          name: product.name,
          price: product.price,
          qty: 1,
        ));
      }
    });
  }

  void _updateQty(String productId, int delta) {
    setState(() {
      final idx = _cart.indexWhere((i) => i.productId == productId);
      if (idx < 0) return;
      final newQty = _cart[idx].qty + delta;
      if (newQty <= 0) {
        _cart.removeAt(idx);
      } else {
        _cart[idx] = _cart[idx].copyWith(qty: newQty);
      }
    });
  }

  Future<void> _placeOrder() async {
    if (_cart.isEmpty) return;
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.confirmOrder, textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ..._cart.map((i) => Padding(
              padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xxs),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(i.name, overflow: TextOverflow.ellipsis, maxLines: 1)),
                  const SizedBox(width: AlhaiSpacing.xs),
                  Text(l10n.qtyTimesPrice(i.qty, i.price.toStringAsFixed(0))),
                ],
              ),
            )),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: Text(l10n.totalAmountLabel, style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis, maxLines: 1)),
                const SizedBox(width: AlhaiSpacing.xs),
                Text(l10n.amountWithSar(_subtotal.toStringAsFixed(2)),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.edit)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.confirmOrder)),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      final db = GetIt.I<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider) ?? '';
      final orderId = const Uuid().v4();
      final now = DateTime.now();

      // Save as an order in held_invoices (kiosk orders)
      final itemsJson = jsonEncode(_cart.map((i) => {'productId': i.productId, 'name': i.name, 'qty': i.qty, 'price': i.price}).toList());
      await db.customStatement(
        '''INSERT INTO held_invoices (id, store_id, cashier_id, items, subtotal, discount, total, notes, created_at)
           VALUES (?, ?, 'kiosk', ?, ?, 0, ?, ?, ?)''',
        [orderId, storeId, itemsJson, _subtotal, _subtotal, l10n.kioskOrderNote, now.toIso8601String()],
      );

      if (mounted) {
        setState(() {
          _cart.clear();
          _showCart = false;
          _orderPlaced = true;
        });
        // Reset after 4 seconds
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted) setState(() => _orderPlaced = false);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.error}: $e'), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_orderPlaced) {
      return _buildOrderSuccess();
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      body: SafeArea(
        child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildHeader(),
                _buildCategoryBar(),
                Expanded(
                  child: _showCart ? _buildCartPanel() : _buildProductGrid(),
                ),
                _buildFooter(),
              ],
            ),
      ),
    );
  }

  Widget _buildOrderSuccess() {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AlhaiColors.success.withValues(alpha: 0.08),
      body: SafeArea(
        child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AlhaiColors.success,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 64),
            ),
            const SizedBox(height: AlhaiSpacing.lg),
            Text(
              l10n.orderReceived,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AlhaiColors.success),
            ),
            const SizedBox(height: AlhaiSpacing.sm),
            Text(
              l10n.orderBeingPrepared,
              style: TextStyle(fontSize: 18, color: Theme.of(context).hintColor),
            ),
            const SizedBox(height: AlhaiSpacing.xl),
            const CircularProgressIndicator(color: AlhaiColors.success),
            const SizedBox(height: AlhaiSpacing.md),
            Text(l10n.redirectingToHome, style: TextStyle(color: Theme.of(context).hintColor)),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.lg, vertical: AlhaiSpacing.md),
      child: Row(
        children: [
          const Icon(Icons.store_rounded, color: Colors.white, size: 28),
          const SizedBox(width: AlhaiSpacing.sm),
          Text(
            l10n.orderNow,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          if (_cart.isNotEmpty)
            Stack(
              children: [
                IconButton(
                  onPressed: () => setState(() => _showCart = !_showCart),
                  icon: Icon(
                    _showCart ? Icons.grid_view_rounded : Icons.shopping_cart_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(AlhaiSpacing.xxs),
                    decoration: const BoxDecoration(color: AlhaiColors.error, shape: BoxShape.circle),
                    child: Text(
                      '${_cart.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryBar() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      height: 56,
      color: Colors.white,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.sm, vertical: AlhaiSpacing.xs),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: AlhaiSpacing.xs),
        itemBuilder: (ctx, i) {
          final cat = _categories[i];
          final isSelected = cat.id == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat.id),
            child: AnimatedContainer(
              duration: AlhaiDurations.standard,
              padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.md, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                cat.id == 'all' ? l10n.allCategories : cat.name,
                style: TextStyle(
                  color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid() {
    final l10n = AppLocalizations.of(context)!;
    final prods = _filteredProducts;
    if (prods.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Theme.of(context).hintColor),
          const SizedBox(height: AlhaiSpacing.sm),
          Text(l10n.noProducts, style: TextStyle(color: Theme.of(context).hintColor, fontSize: 16)),
        ]),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        mainAxisExtent: 200,
        crossAxisSpacing: AlhaiSpacing.sm,
        mainAxisSpacing: AlhaiSpacing.sm,
      ),
      itemCount: prods.length,
      itemBuilder: (ctx, i) {
        final p = prods[i];
        final inCart = _cart.where((c) => c.productId == p.id).firstOrNull;
        return GestureDetector(
          onTap: () => _addToCart(p),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: const Icon(Icons.fastfood_rounded, size: 56, color: AppColors.primary),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: AlhaiSpacing.xxs),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.amountWithSar(p.price.toStringAsFixed(0)),
                            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                          ),
                          if (inCart != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.xs, vertical: 2),
                              decoration: BoxDecoration(
                                color: AlhaiColors.success,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text('${inCart.qty}',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                            )
                          else
                            const Icon(Icons.add_circle_outline, color: AppColors.primary, size: 20),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCartPanel() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AlhaiSpacing.md),
          child: Row(
            children: [
              const Icon(Icons.shopping_cart_rounded, color: AppColors.primary),
              const SizedBox(width: AlhaiSpacing.xs),
              Expanded(
                child: Text(l10n.orderCartWithCount(_cart.length),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis, maxLines: 1),
              ),
            ],
          ),
        ),
        Expanded(
          child: _cart.isEmpty
              ? Center(child: Text(l10n.cartEmpty, style: TextStyle(color: Theme.of(context).hintColor)))
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.md),
                  itemCount: _cart.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (ctx, i) {
                    final item = _cart[i];
                    return ListTile(
                      title: Text(item.name),
                      subtitle: Text(l10n.pricePerUnit(item.price.toStringAsFixed(2))),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => _updateQty(item.productId, -1),
                            icon: const Icon(Icons.remove_circle_outline, color: AlhaiColors.error),
                          ),
                          Text('${item.qty}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          IconButton(
                            onPressed: () => _updateQty(item.productId, 1),
                            icon: const Icon(Icons.add_circle_outline, color: AlhaiColors.success),
                          ),
                          Text(
                            l10n.amountWithSar(item.total.toStringAsFixed(2)),
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      color: Colors.white,
      child: Row(
        children: [
          if (_cart.isNotEmpty) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.itemCount(_cart.length), style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12)),
                Text(
                  l10n.amountWithSar(_subtotal.toStringAsFixed(2)),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(width: AlhaiSpacing.md),
          ],
          Expanded(
            child: FilledButton.icon(
              onPressed: _cart.isEmpty ? null : _placeOrder,
              icon: const Icon(Icons.check_circle_rounded),
              label: Text(_cart.isEmpty ? l10n.selectFromMenu : l10n.orderNow),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.md),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Data classes ─────────────────────────────────────────────────────────────

class _KioskCategory {
  final String id;
  final String name;
  const _KioskCategory({required this.id, required this.name});
}

class _KioskProduct {
  final String id;
  final String name;
  final double price;
  final String description;
  final String category;
  final String imageUrl;
  const _KioskProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.category,
    required this.imageUrl,
  });
}

class _CartItem {
  final String productId;
  final String name;
  final double price;
  final int qty;

  const _CartItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.qty,
  });

  double get total => price * qty;

  _CartItem copyWith({int? qty}) => _CartItem(
    productId: productId,
    name: name,
    price: price,
    qty: qty ?? this.qty,
  );
}
