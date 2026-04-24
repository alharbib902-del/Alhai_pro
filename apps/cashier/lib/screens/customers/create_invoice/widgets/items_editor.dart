/// Items Editor — بحث منتج + قائمة بنود الفاتورة مع +/- وحذف
///
/// يشترك في [invoiceDraftProvider] لقراءة/تعديل قائمة البنود.
/// البحث عبر `productsDao.searchProducts` مع debounce 300ms.
///
/// ملاحظة C-4: `product.price` في DB بوحدة cents (int)؛ نُحوّله إلى
/// SAR (double) عند الإضافة إلى مسودّة الفاتورة.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_design_system/alhai_design_system.dart'
    show AlhaiSnackbar, AlhaiSpacing;

import '../../../../core/services/sentry_service.dart';
import '../providers/invoice_draft_notifier.dart';

class ItemsEditor extends ConsumerStatefulWidget {
  const ItemsEditor({super.key});

  @override
  ConsumerState<ItemsEditor> createState() => _ItemsEditorState();
}

class _ItemsEditorState extends ConsumerState<ItemsEditor> {
  final _db = GetIt.I<AppDatabase>();
  final _searchController = TextEditingController();

  List<ProductsTableData> _results = [];
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _search(query);
    });
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;
      final results = await _db.productsDao.searchProducts(query, storeId);
      if (mounted) {
        setState(() => _results = results.take(5).toList());
      }
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Product search');
      if (mounted) {
        AlhaiSnackbar.error(
          context,
          AppLocalizations.of(context).productSearchFailed('$e'),
        );
      }
    }
  }

  void _add(ProductsTableData product) {
    ref.read(invoiceDraftProvider.notifier).addProduct(
          productId: product.id,
          productName: product.name,
          // C-4 Stage B: product.price is int cents; invoice in double SAR.
          priceSar: product.price / 100.0,
        );
    _searchController.clear();
    setState(() => _results = []);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final items = ref.watch(invoiceDraftProvider.select((s) => s.items));

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.shopping_bag_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(
                l10n.items,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              if (items.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: AlhaiSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${items.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.md),
          // Product search
          TextField(
            controller: _searchController,
            style: TextStyle(color: colorScheme.onSurface),
            onChanged: _onChanged,
            decoration: InputDecoration(
              hintText: l10n.searchPlaceholder,
              hintStyle: TextStyle(color: colorScheme.outline),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: colorScheme.outline,
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AlhaiSpacing.md,
                vertical: 14,
              ),
            ),
          ),
          if (_results.isNotEmpty)
            _ProductResults(
              results: _results,
              sarLabel: l10n.sar,
              onPick: _add,
            ),
          const SizedBox(height: AlhaiSpacing.sm),
          // Items list
          ...List.generate(items.length, (index) {
            final item = items[index];
            return _ItemRow(
              key: ValueKey('${item.productId}-$index'),
              index: index,
              productName: item.productName,
              price: item.price,
              qty: item.qty,
              lineTotal: item.lineTotal,
              sarLabel: l10n.sar,
              decreaseLabel: l10n.decreaseQuantity,
              increaseLabel: l10n.increaseQuantity,
              deleteLabel: l10n.delete,
              onDecrease: () =>
                  ref.read(invoiceDraftProvider.notifier).updateQty(index, item.qty - 1),
              onIncrease: () =>
                  ref.read(invoiceDraftProvider.notifier).updateQty(index, item.qty + 1),
              onRemove: () =>
                  ref.read(invoiceDraftProvider.notifier).removeItemAt(index),
            );
          }),
        ],
      ),
    );
  }
}

class _ProductResults extends StatelessWidget {
  final List<ProductsTableData> results;
  final String sarLabel;
  final ValueChanged<ProductsTableData> onPick;

  const _ProductResults({
    required this.results,
    required this.sarLabel,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsetsDirectional.only(top: AlhaiSpacing.xs),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: results.map((product) {
          return InkWell(
            onTap: () => onPick(product),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AlhaiSpacing.md,
                vertical: AlhaiSpacing.sm,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 18,
                    color: colorScheme.outline,
                  ),
                  const SizedBox(width: AlhaiSpacing.sm),
                  Expanded(
                    child: Text(
                      product.name,
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${product.price.toStringAsFixed(2)} $sarLabel',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final int index;
  final String productName;
  final double price;
  final int qty;
  final double lineTotal;
  final String sarLabel;
  final String decreaseLabel;
  final String increaseLabel;
  final String deleteLabel;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onRemove;

  const _ItemRow({
    super.key,
    required this.index,
    required this.productName,
    required this.price,
    required this.qty,
    required this.lineTotal,
    required this.sarLabel,
    required this.decreaseLabel,
    required this.increaseLabel,
    required this.deleteLabel,
    required this.onDecrease,
    required this.onIncrease,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsetsDirectional.only(bottom: AlhaiSpacing.xs),
      padding: const EdgeInsets.all(AlhaiSpacing.sm),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${price.toStringAsFixed(2)} $sarLabel',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: onDecrease,
                icon: const Icon(Icons.remove_circle_outline_rounded),
                iconSize: 22,
                color: colorScheme.onSurfaceVariant,
                constraints: const BoxConstraints(
                  minWidth: 48,
                  minHeight: 48,
                ),
                padding: EdgeInsets.zero,
                tooltip: decreaseLabel,
              ),
              SizedBox(
                width: 28,
                child: Text(
                  '$qty',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              IconButton(
                onPressed: onIncrease,
                icon: const Icon(Icons.add_circle_outline_rounded),
                iconSize: 22,
                color: AppColors.primary,
                constraints: const BoxConstraints(
                  minWidth: 48,
                  minHeight: 48,
                ),
                padding: EdgeInsets.zero,
                tooltip: increaseLabel,
              ),
            ],
          ),
          const SizedBox(width: AlhaiSpacing.xs),
          Text(
            lineTotal.toStringAsFixed(2),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.close_rounded, size: 18),
            color: AppColors.error,
            constraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 48,
            ),
            padding: EdgeInsets.zero,
            tooltip: deleteLabel,
          ),
        ],
      ),
    );
  }
}
