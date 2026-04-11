import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../providers/cart_providers.dart';
import '../../widgets/pos/quantity_input_dialog.dart';
import 'pos_category_widgets.dart';
import 'pos_product_shortcuts.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

// =============================================================================
// PRODUCTS PANEL
// =============================================================================

/// لوحة المنتجات - تعرض شبكة المنتجات مع التصنيفات
class PosProductsPanel extends ConsumerStatefulWidget {
  final String? selectedCategoryId;
  final ValueChanged<String?> onCategorySelected;
  final int columns;
  final bool showShortcutsBar;
  final VoidCallback? onHoldInvoice;
  final VoidCallback? onShowHeldInvoices;

  const PosProductsPanel({
    super.key,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    this.columns = 3,
    this.showShortcutsBar = false,
    this.onHoldInvoice,
    this.onShowHeldInvoices,
  });

  @override
  ConsumerState<PosProductsPanel> createState() => _PosProductsPanelState();
}

class _PosProductsPanelState extends ConsumerState<PosProductsPanel> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId != null) {
        ref.read(productsStateProvider.notifier).loadMore(storeId: storeId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // M93: Use .select() to only rebuild when products/loading/error change,
    // not when currentPage, hasMore, searchQuery, or categoryId change alone
    final productsState = ref.watch(
      productsStateProvider.select(
        (state) => (state.products, state.isLoading, state.error),
      ),
    );
    final categoriesAsync = ref.watch(categoriesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final isDesktop = widget.showShortcutsBar; // Desktop has shortcuts bar

    // Reconstruct a minimal ProductsState for the grid builder
    final productsStateForGrid = ProductsState(
      products: productsState.$1,
      isLoading: productsState.$2,
      error: productsState.$3,
    );

    return Container(
      color: isDark ? AppColors.backgroundDark : AppColors.background,
      child: Stack(
        children: [
          if (isDesktop)
            // Desktop: عمود تصنيفات جانبي + شبكة منتجات
            Row(
              children: [
                PosCategoryColumn(
                  categories: categoriesAsync,
                  selectedCategoryId: widget.selectedCategoryId,
                  onCategorySelected: widget.onCategorySelected,
                ),
                Expanded(
                  child: _buildProductsGrid(
                    context,
                    ref,
                    productsStateForGrid,
                    l10n,
                  ),
                ),
              ],
            )
          else
            // Mobile: شريط تصنيفات أفقي + شبكة منتجات
            Column(
              children: [
                PosCategoryBar(
                  categories: categoriesAsync,
                  selectedCategoryId: widget.selectedCategoryId,
                  onCategorySelected: widget.onCategorySelected,
                ),
                Expanded(
                  child: _buildProductsGrid(
                    context,
                    ref,
                    productsStateForGrid,
                    l10n,
                  ),
                ),
              ],
            ),

          // Desktop shortcuts bar
          if (widget.showShortcutsBar)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: PosShortcutsBar(
                  onHoldInvoice: widget.onHoldInvoice,
                  onShowHeldInvoices: widget.onShowHeldInvoices,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductsGrid(
    BuildContext context,
    WidgetRef ref,
    ProductsState state,
    AppLocalizations l10n,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (state.isLoading && state.products.isEmpty) {
      return ShimmerGrid(
        crossAxisCount: widget.columns,
        itemCount: widget.columns * 3,
        childAspectRatio: widget.columns <= 3 ? 0.9 : 1.0,
      );
    }

    if (state.error != null && state.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error.withValues(alpha: 0.6),
            ),
            const SizedBox(height: AlhaiSpacing.md),
            Text(
              '${l10n.error}: ${state.error}',
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AlhaiSpacing.md),
            FilledButton.icon(
              onPressed: () {
                final storeId = ref.read(currentStoreIdProvider);
                if (storeId != null) {
                  ref
                      .read(productsStateProvider.notifier)
                      .loadProducts(storeId: storeId, refresh: true);
                }
              },
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    if (state.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: isDark ? AppColors.grey600 : AppColors.grey400,
            ),
            const SizedBox(height: AlhaiSpacing.md),
            Text(
              l10n.noProducts,
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: AlhaiSpacing.xs),
            Text(
              l10n.addProductsToStart,
              style: TextStyle(
                color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    final cols = widget.columns;
    return RefreshIndicator(
      onRefresh: () async {
        final storeId = ref.read(currentStoreIdProvider);
        if (storeId != null) {
          await ref
              .read(productsStateProvider.notifier)
              .loadProducts(storeId: storeId, refresh: true);
        }
      },
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          start: AlhaiSpacing.xs,
          end: AlhaiSpacing.xs,
          top: AlhaiSpacing.xs,
          bottom: widget.showShortcutsBar ? 80 : 8,
        ),
        child: GridView.builder(
          controller: _scrollController,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            childAspectRatio: cols <= 3 ? 0.9 : 1.0,
            crossAxisSpacing: AlhaiSpacing.xs,
            mainAxisSpacing: AlhaiSpacing.xs,
          ),
          // +1 عنصر إضافي لعرض مؤشر التحميل عند التمرير
          itemCount: state.products.length + (state.isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            // مؤشر تحميل في نهاية القائمة
            if (index >= state.products.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(AlhaiSpacing.md),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            }

            final product = state.products[index];
            return PosProductCard(
              product: product,
              onAddToCart: () {
                ref.read(cartStateProvider.notifier).addProduct(product);
                // لا SnackBar - الكارت يعرض المنتج المضاف كتأكيد بصري
              },
              onAddWithQuantity: () async {
                final qty = await QuantityInputDialog.show(context, product);
                if (qty != null && qty > 0 && context.mounted) {
                  ref
                      .read(cartStateProvider.notifier)
                      .addProduct(product, quantity: qty);
                }
              },
            );
          },
        ),
      ),
    );
  }
}
