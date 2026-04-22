/// Periodic stocktaking (M3).
///
/// Operator enters a physical count per product; on save each product with
/// `counted != expected` becomes one `inventory_movements` adjustment row
/// plus a `products.stock_qty` update. Pattern mirrors
/// `packages/alhai_database/lib/src/daos/inventory_dao.dart::recordAdjustment`.
library;

import 'package:alhai_auth/alhai_auth.dart'
    show currentStoreIdProvider, currentUserProvider;
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

final _productsForStocktakingProvider =
    FutureProvider.autoDispose<List<ProductsTableData>>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return const [];
  final db = GetIt.I<AppDatabase>();
  return db.productsDao.getAllProducts(storeId);
});

/// Stocktaking reconciliation screen.
class StocktakingScreen extends ConsumerStatefulWidget {
  const StocktakingScreen({super.key});

  @override
  ConsumerState<StocktakingScreen> createState() => _StocktakingScreenState();
}

class _StocktakingScreenState extends ConsumerState<StocktakingScreen> {
  /// productId → counted qty typed by the operator.
  final Map<String, double> _counted = {};
  final Map<String, TextEditingController> _controllers = {};
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _saving = false;

  @override
  void dispose() {
    _searchController.dispose();
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  int get _adjustedCount => _counted.entries
      .where((e) => _controllers[e.key]?.text.trim().isNotEmpty == true)
      .length;

  Future<void> _saveAll() async {
    if (_saving) return;
    final l10n = AppLocalizations.of(context);
    final storeId = ref.read(currentStoreIdProvider);
    if (storeId == null) return;

    final products = ref.read(_productsForStocktakingProvider).valueOrNull;
    if (products == null) return;

    setState(() => _saving = true);
    final db = GetIt.I<AppDatabase>();
    final currentUser = ref.read(currentUserProvider);
    final messenger = ScaffoldMessenger.of(context);
    var applied = 0;
    try {
      for (final product in products) {
        final typed = _controllers[product.id]?.text.trim();
        if (typed == null || typed.isEmpty) continue;
        final newQty = double.tryParse(typed);
        if (newQty == null) continue;
        if (newQty == product.stockQty) continue;
        await db.inventoryDao.recordAdjustment(
          id: 'sk_${DateTime.now().millisecondsSinceEpoch}_${product.id}',
          productId: product.id,
          storeId: storeId,
          newQty: newQty,
          previousQty: product.stockQty,
          reason: 'stocktaking',
          userId: currentUser?.id,
        );
        await db.productsDao.updateStock(product.id, newQty);
        try {
          await db.auditLogDao.log(
            storeId: storeId,
            userId: currentUser?.id ?? 'unknown',
            userName: currentUser?.name ?? 'unknown',
            action: AuditAction.stockAdjust,
            entityType: 'product',
            entityId: product.id,
            oldValue: {'stock_qty': product.stockQty},
            newValue: {'stock_qty': newQty, 'reason': 'stocktaking'},
            description:
                'Stocktaking adjustment for "${product.name}": '
                '${product.stockQty} \u2192 $newQty',
          );
        } catch (_) {
          // audit is non-fatal
        }
        applied++;
      }
      if (!mounted) return;
      _counted.clear();
      for (final c in _controllers.values) {
        c.clear();
      }
      ref.invalidate(_productsForStocktakingProvider);
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.stocktakingSavedSuccess(applied)),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Stocktaking save failed: $e');
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.errorWithDetails('$e')),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final productsAsync = ref.watch(_productsForStocktakingProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.stocktakingTitle),
        actions: [
          if (_adjustedCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.sm),
              child: Center(
                child: Chip(
                  label: Text(l10n.stocktakingAdjustedCount(_adjustedCount)),
                  backgroundColor: AppColors.warning.withValues(alpha: 0.15),
                  labelStyle: const TextStyle(color: AppColors.warning),
                ),
              ),
            ),
          FilledButton.icon(
            onPressed: _saving || _adjustedCount == 0 ? null : _saveAll,
            icon: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_rounded, size: 18),
            label: Text(l10n.saveAllAdjustments),
          ),
          const SizedBox(width: AlhaiSpacing.sm),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AlhaiSpacing.md),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchByNameOrBarcode,
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (v) => setState(() => _searchQuery = v.trim()),
            ),
          ),
          Expanded(
            child: productsAsync.when(
              data: (products) {
                final filtered = _searchQuery.isEmpty
                    ? products
                    : products.where((p) {
                        final q = _searchQuery.toLowerCase();
                        return p.name.toLowerCase().contains(q) ||
                            (p.barcode?.contains(q) ?? false);
                      }).toList();
                if (filtered.isEmpty) {
                  return Center(child: Text(l10n.noProducts));
                }
                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => _StocktakingRow(
                    product: filtered[i],
                    controller: _controllers.putIfAbsent(
                      filtered[i].id,
                      () => TextEditingController(),
                    ),
                    onChanged: (v) {
                      if (v.isEmpty) {
                        _counted.remove(filtered[i].id);
                      } else {
                        final n = double.tryParse(v);
                        if (n != null) _counted[filtered[i].id] = n;
                      }
                      setState(() {});
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text(l10n.errorWithDetails('$e')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StocktakingRow extends StatelessWidget {
  final ProductsTableData product;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _StocktakingRow({
    required this.product,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final typed = controller.text.trim();
    final parsed = typed.isEmpty ? null : double.tryParse(typed);
    final delta = parsed == null ? null : parsed - product.stockQty;
    final deltaColor = delta == null
        ? null
        : (delta == 0
              ? AppColors.textSecondary
              : (delta > 0 ? AppColors.success : AppColors.error));

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AlhaiSpacing.md,
        vertical: AlhaiSpacing.xxs,
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AlhaiSpacing.sm),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    if (product.barcode != null)
                      Text(
                        product.barcode!,
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.expectedQty,
                      style: const TextStyle(fontSize: 10),
                    ),
                    Text(
                      product.stockQty.toStringAsFixed(0),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'[0-9.]'),
                    ),
                  ],
                  decoration: InputDecoration(
                    labelText: l10n.countedQty,
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: onChanged,
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(l10n.stockDelta, style: const TextStyle(fontSize: 10)),
                    Text(
                      delta == null
                          ? '-'
                          : (delta > 0 ? '+' : '') +
                                delta.toStringAsFixed(0),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: deltaColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
