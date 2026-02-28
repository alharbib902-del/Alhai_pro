import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/router/routes.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/products_providers.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';
import '../../widgets/layout/app_header.dart';
import '../../widgets/dashboard/sales_chart.dart';

/// شاشة تفاصيل المنتج
class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  // UI state
  bool _isHoveringImage = false;

  // Data state
  bool _isLoading = true;
  Product? _product;
  Category? _category;
  List<InventoryMovementsTableData> _stockMovements = [];
  int _totalSalesCount = 0;

  @override
  void initState() {
    super.initState();
    _loadProductData();
  }

  Future<void> _loadProductData() async {
    setState(() => _isLoading = true);

    try {
      final db = GetIt.I<AppDatabase>();

      // 1. Load product
      final productData = await db.productsDao.getProductById(widget.productId);
      if (productData == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Convert to domain Product
      final product = Product(
        id: productData.id,
        storeId: productData.storeId,
        name: productData.name,
        sku: productData.sku,
        barcode: productData.barcode,
        price: productData.price,
        costPrice: productData.costPrice,
        stockQty: productData.stockQty,
        minQty: productData.minQty,
        unit: productData.unit,
        description: productData.description,
        imageThumbnail: productData.imageThumbnail,
        imageMedium: productData.imageMedium,
        imageLarge: productData.imageLarge,
        imageHash: productData.imageHash,
        categoryId: productData.categoryId,
        isActive: productData.isActive,
        trackInventory: productData.trackInventory,
        createdAt: productData.createdAt,
        updatedAt: productData.updatedAt,
      );

      // 2. Load category
      Category? category;
      if (product.categoryId != null) {
        try {
          final categories = await ref.read(categoriesProvider.future);
          category = categories.firstWhere(
            (c) => c.id == product.categoryId,
            orElse: () => const Category(
              id: '',
              name: '',
            ),
          );
          if (category.id.isEmpty) category = null;
        } catch (_) {}
      }

      // 3. Load stock movements
      List<InventoryMovementsTableData> movements = [];
      try {
        movements =
            await db.inventoryDao.getMovementsByProduct(widget.productId);
      } catch (_) {}

      // 4. Load total sales count
      int salesCount = 0;
      try {
        final count =
            await db.saleItemsDao.getProductSalesCount(widget.productId);
        salesCount = count.toInt();
      } catch (_) {}

      setState(() {
        _product = product;
        _category = category;
        _stockMovements = movements;
        _totalSalesCount = salesCount;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }
  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(AppLocalizations.of(context)!.copiedToClipboard(label)),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = context.isDesktop;
    final isMediumScreen = !context.isMobile;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Column(
              children: [
                AppHeader(
                  title: _product?.name ?? l10n.productDetails,
                  subtitle: l10n.productDetails,
                  showSearch: false,
                  onMenuTap: isWideScreen
                      ? null
                      : () => Scaffold.of(context).openDrawer(),
                  onNotificationsTap: () => context.push('/notifications'),
                  notificationsCount: 3,
                  userName: l10n.defaultUserName,
                  userRole: l10n.branchManager,
                  onUserTap: () {},
                  actions: isWideScreen && _product != null
                      ? [
                          AlhaiButton(
                            label: l10n.edit,
                            variant: AlhaiButtonVariant.outlined,
                            size: AlhaiButtonSize.small,
                            leadingIcon: Icons.edit_outlined,
                            onPressed: () async {
                              await context.push(AppRoutes.productsEditPath(_product!.id));
                              _loadProductData();
                            },
                          ),
                          const SizedBox(width: 8),
                          AlhaiButton(
                            label: l10n.printLabel,
                            variant: AlhaiButtonVariant.filled,
                            size: AlhaiButtonSize.small,
                            leadingIcon: Icons.print_outlined,
                            onPressed: () {},
                          ),
                          const SizedBox(width: 8),
                          AlhaiIconButton(
                            icon: Icons.more_horiz,
                            onPressed: () => _showMoreOptions(context),
                            tooltip: l10n.moreOptions,
                          ),
                        ]
                      : null,
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadProductData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
                      child: _buildContent(
                          isWideScreen, isMediumScreen, isDark, l10n),
                    ),
                  ),
                ),
              ],
            );
  }
  // ============================================================================
  // CONTENT
  // ============================================================================

  Widget _buildContent(
      bool isWideScreen, bool isMediumScreen, bool isDark, AppLocalizations l10n) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(64),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_product == null) {
      return Center(
        child: AlhaiEmptyState(
          icon: Icons.inventory_2_outlined,
          title: l10n.productNotFound,
          description: l10n.noData,
          actionText: l10n.back,
          onAction: () => context.pop(),
        ),
      );
    }

    if (isWideScreen) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: _buildLeftColumn(isDark, isMediumScreen, l10n),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 2,
            child: _buildRightColumn(isDark, l10n),
          ),
        ],
      );
    }

    return _buildMobileColumn(isDark, l10n);
  }

  // ============================================================================
  // LEFT COLUMN (Desktop)
  // ============================================================================

  Widget _buildLeftColumn(
      bool isDark, bool isMediumScreen, AppLocalizations l10n) {
    return Column(
      children: [
        _buildProductInfoCard(isDark, isMediumScreen, l10n),
        const SizedBox(height: 24),
        _buildStockPanel(isDark, l10n),
        const SizedBox(height: 24),
        _buildTabsSection(isDark, l10n),
      ],
    );
  }

  // ============================================================================
  // RIGHT COLUMN (Desktop)
  // ============================================================================

  Widget _buildRightColumn(bool isDark, AppLocalizations l10n) {
    return Column(
      children: [
        _buildQuickStats(isDark, l10n),
        const SizedBox(height: 24),
        _buildCategoryCard(isDark, l10n),
        const SizedBox(height: 24),
        _buildLastSaleCard(isDark, l10n),
      ],
    );
  }

  // ============================================================================
  // MOBILE COLUMN
  // ============================================================================

  Widget _buildMobileColumn(bool isDark, AppLocalizations l10n) {
    return Column(
      children: [
        _buildProductInfoCard(isDark, false, l10n),
        const SizedBox(height: 16),
        _buildQuickStats(isDark, l10n),
        const SizedBox(height: 16),
        _buildMobileStockCard(isDark, l10n),
        const SizedBox(height: 16),
        _buildCategoryCard(isDark, l10n),
        const SizedBox(height: 16),
        _buildTabsSection(isDark, l10n),
        const SizedBox(height: 16),
        _buildLastSaleCard(isDark, l10n),
      ],
    );
  }

  // ============================================================================
  // PRODUCT INFO CARD
  // ============================================================================

  Widget _buildProductInfoCard(
      bool isDark, bool isMediumScreen, AppLocalizations l10n) {
    final product = _product!;

    return _card(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image + Info Row for desktop, stacked for mobile
          if (isMediumScreen)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image with hover overlay
                Column(
                  children: [
                    MouseRegion(
                      onEnter: (_) => setState(() => _isHoveringImage = true),
                      onExit: (_) => setState(() => _isHoveringImage = false),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(
                          width: 200,
                          height: 200,
                          child: Stack(
                            children: [
                              Hero(
                                tag: 'product-image-${product.id}',
                                child: ProductImage(
                                  thumbnail: product.imageThumbnail,
                                  medium: product.imageMedium,
                                  large: product.imageLarge,
                                  size: ImageSize.large,
                                  width: 200,
                                  height: 200,
                                ),
                              ),
                              AnimatedOpacity(
                                duration: AlhaiDurations.standard,
                                opacity: _isHoveringImage ? 1.0 : 0.0,
                                child: Container(
                                  width: 200,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.5),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit_outlined, color: Theme.of(context).colorScheme.onPrimary, size: 22),
                                        onPressed: () async {
                                          await context.push(AppRoutes.productsEditPath(product.id));
                                          _loadProductData();
                                        },
                                        tooltip: l10n.edit,
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: Icon(Icons.fullscreen_rounded, color: Theme.of(context).colorScheme.onPrimary, size: 22),
                                        onPressed: () {
                                          // TODO: Full screen image viewer
                                        },
                                        tooltip: l10n.viewAll,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Status badge below image
                    _statusBadge(product.isActive, l10n),
                  ],
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildProductMeta(product, isDark, l10n),
                ),
              ],
            )
          else ...[
            // Mobile: Stacked layout
            Center(
              child: Hero(
                tag: 'product-image-${product.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 200,
                    child: ProductImage(
                      thumbnail: product.imageThumbnail,
                      medium: product.imageMedium,
                      large: product.imageLarge,
                      size: ImageSize.large,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(child: _statusBadge(product.isActive, l10n)),
            const SizedBox(height: 16),
            _buildProductMeta(product, isDark, l10n),
          ],
        ],
      ),
    );
  }

  Widget _buildProductMeta(
      Product product, bool isDark, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product Name
        Hero(
          tag: 'product-name-${product.id}',
          child: Material(
            type: MaterialType.transparency,
            child: Text(
              product.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextPrimary(isDark),
                  ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // SKU & Barcode badges
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (product.sku != null && product.sku!.isNotEmpty)
              _codeBadge(
                label: l10n.sku,
                value: product.sku!,
                isDark: isDark,
                onCopy: () => _copyToClipboard(product.sku!, l10n.sku),
              ),
            if (product.barcode != null && product.barcode!.isNotEmpty)
              _codeBadge(
                label: l10n.barcode,
                value: product.barcode!,
                isDark: isDark,
                onCopy: () =>
                    _copyToClipboard(product.barcode!, l10n.barcode),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Prices
        _buildPriceSection(product, isDark, l10n),

        // Description
        if (product.description != null &&
            product.description!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Divider(color: AppColors.getBorder(isDark)),
          const SizedBox(height: 12),
          Text(
            l10n.description,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.getTextPrimary(isDark),
                ),
          ),
          const SizedBox(height: 4),
          Text(
            product.description!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.getTextSecondary(isDark),
                  height: 1.6,
                ),
          ),
        ],
      ],
    );
  }

  Widget _buildPriceSection(
      Product product, bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.sellingPrice,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.getTextSecondary(isDark),
                      ),
                ),
                const SizedBox(height: 4),
                AlhaiPriceText(
                  amount: product.price,
                  currency: l10n.sar,
                  size: AlhaiPriceTextSize.large,
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.getBorder(isDark),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsetsDirectional.only(start: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.costPrice,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.getTextSecondary(isDark),
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.format(product.costPrice ?? 0),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.getTextPrimary(isDark),
                        ),
                  ),
                ],
              ),
            ),
          ),
          if (product.profitMargin != null) ...[
            Container(
              width: 1,
              height: 40,
              color: AppColors.getBorder(isDark),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsetsDirectional.only(start: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.profitMargin,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.getTextSecondary(isDark),
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${product.profitMargin!.toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================================
  // STOCK PANEL (Desktop)
  // ============================================================================

  Widget _buildStockPanel(bool isDark, AppLocalizations l10n) {
    final product = _product!;
    final stockColor = AppColors.getStockColor(product.stockQty, product.minQty);

    return _card(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.inventory_2_outlined, size: 20,
                  color: AppColors.getTextSecondary(isDark)),
              const SizedBox(width: 8),
              Text(
                l10n.stockStatus,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.getTextPrimary(isDark),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3 stat cards
          Row(
            children: [
              Expanded(
                child: _stockStatCard(
                  label: l10n.available,
                  value: '${product.stockQty}',
                  suffix: product.unit ?? l10n.units,
                  color: stockColor,
                  icon: Icons.check_circle_outline,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _stockStatCard(
                  label: l10n.alertLevel,
                  value: '${product.minQty}',
                  suffix: product.unit ?? l10n.units,
                  color: AppColors.warning,
                  icon: Icons.warning_amber_rounded,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _stockStatCard(
                  label: l10n.reorderPoint,
                  value: '${(product.minQty * 2).clamp(1, 999)}',
                  suffix: product.unit ?? l10n.units,
                  color: AppColors.info,
                  icon: Icons.shopping_cart_outlined,
                  isDark: isDark,
                ),
              ),
            ],
          ),

          // Mini chart for stock movements
          if (_stockMovements.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: SimpleBarChart(
                data: _stockMovements.take(7).toList().reversed.map((m) {
                  return ChartDataPoint(
                    label: '${m.createdAt.day}/${m.createdAt.month}',
                    value: m.qty.abs().toDouble(),
                  );
                }).toList(),
                height: 120,
                showLabels: true,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _stockStatCard({
    required String label,
    required String value,
    required String suffix,
    required Color color,
    required IconData icon,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.3 : 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            '$label ($suffix)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.getTextSecondary(isDark),
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // MOBILE STOCK CARD
  // ============================================================================

  Widget _buildMobileStockCard(bool isDark, AppLocalizations l10n) {
    final product = _product!;
    final stockColor = AppColors.getStockColor(product.stockQty, product.minQty);

    return _card(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.inventory_2_outlined, size: 20,
                  color: AppColors.getTextSecondary(isDark)),
              const SizedBox(width: 8),
              Text(
                l10n.stockStatus,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.getTextPrimary(isDark),
                    ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: stockColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  product.isOutOfStock
                      ? l10n.outOfStock
                      : product.isLowStock
                          ? l10n.lowStock
                          : l10n.inStock,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: stockColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _miniStatColumn(
                  l10n.currentStock,
                  '${product.stockQty}',
                  isDark,
                ),
              ),
              Expanded(
                child: _miniStatColumn(
                  l10n.alertLevel,
                  '${product.minQty}',
                  isDark,
                ),
              ),
              Expanded(
                child: _miniStatColumn(
                  l10n.reorderPoint,
                  '${(product.minQty * 2).clamp(1, 999)}',
                  isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStatColumn(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.getTextPrimary(isDark),
              ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.getTextSecondary(isDark),
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ============================================================================
  // TABS SECTION (Stock Movement / Price History / Sales History)
  // ============================================================================

  Widget _buildTabsSection(bool isDark, AppLocalizations l10n) {
    return _card(
      isDark: isDark,
      padding: EdgeInsets.zero,
      child: AlhaiTabs(
        viewHeight: 400,
        tabs: [
          AlhaiTabItem(
            label: l10n.stockMovements,
            icon: const Icon(Icons.swap_vert_rounded, size: 18),
          ),
          AlhaiTabItem(
            label: l10n.priceHistory,
            icon: const Icon(Icons.trending_up_rounded, size: 18),
          ),
          AlhaiTabItem(
            label: l10n.salesHistory,
            icon: const Icon(Icons.receipt_long_outlined, size: 18),
          ),
        ],
        views: [
          _stockMovementsTab(isDark, l10n),
          _priceHistoryTab(isDark, l10n),
          _salesHistoryTab(isDark, l10n),
        ],
      ),
    );
  }

  Widget _stockMovementsTab(bool isDark, AppLocalizations l10n) {
    if (_stockMovements.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: AlhaiEmptyState(
          icon: Icons.swap_vert_rounded,
          title: l10n.noStockMovements,
          compact: true,
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DataTable(
          headingTextStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.getTextSecondary(isDark),
              ),
          dataTextStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.getTextPrimary(isDark),
              ),
          columnSpacing: 24,
          columns: [
            DataColumn(label: Text(l10n.date)),
            DataColumn(label: Text(l10n.type)),
            DataColumn(label: Text(l10n.quantity), numeric: true),
            DataColumn(label: Text(l10n.reference)),
            DataColumn(label: Text(l10n.newBalance), numeric: true),
          ],
          rows: _stockMovements.take(10).map((m) {
            final isPositive = m.qty > 0;
            return DataRow(cells: [
              DataCell(Text(
                '${m.createdAt.day}/${m.createdAt.month}/${m.createdAt.year}',
                style: const TextStyle(fontFamily: 'monospace'),
              )),
              DataCell(_movementTypeBadge(m.type, isDark, l10n)),
              DataCell(Text(
                '${isPositive ? "+" : ""}${m.qty}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isPositive ? AppColors.success : AppColors.error,
                ),
              )),
              DataCell(Text(
                m.referenceId ?? '-',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: AppColors.getTextMuted(isDark),
                ),
              )),
              DataCell(Text(
                '${m.newQty}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _priceHistoryTab(bool isDark, AppLocalizations l10n) {
    // Sample data (no price history DAO exists yet)
    final now = DateTime.now();
    final sampleData = [
      _PriceHistoryItem(
        date: now.subtract(const Duration(days: 30)),
        oldPrice: 10.00,
        newPrice: 12.50,
        reason: l10n.supplierPriceUpdate,
      ),
      _PriceHistoryItem(
        date: now.subtract(const Duration(days: 90)),
        oldPrice: 8.00,
        newPrice: 10.00,
        reason: l10n.costIncrease,
      ),
    ];

    if (sampleData.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: AlhaiEmptyState(
          icon: Icons.trending_up_rounded,
          title: l10n.noPriceHistory,
          compact: true,
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DataTable(
          headingTextStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.getTextSecondary(isDark),
              ),
          dataTextStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.getTextPrimary(isDark),
              ),
          columnSpacing: 24,
          columns: [
            DataColumn(label: Text(l10n.date)),
            DataColumn(label: Text(l10n.oldPrice), numeric: true),
            DataColumn(label: Text(l10n.newPrice), numeric: true),
            DataColumn(label: Text(l10n.reason)),
          ],
          rows: sampleData.map((item) {
            return DataRow(cells: [
              DataCell(Text(
                '${item.date.day}/${item.date.month}/${item.date.year}',
                style: const TextStyle(fontFamily: 'monospace'),
              )),
              DataCell(Text(
                CurrencyFormatter.format(item.oldPrice),
                style: TextStyle(
                  color: AppColors.getTextMuted(isDark),
                  decoration: TextDecoration.lineThrough,
                ),
              )),
              DataCell(Text(
                CurrencyFormatter.format(item.newPrice),
                style: const TextStyle(fontWeight: FontWeight.w600),
              )),
              DataCell(Text(item.reason)),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _salesHistoryTab(bool isDark, AppLocalizations l10n) {
    // Sample data
    final now = DateTime.now();
    final sampleSales = [
      _SaleHistoryItem(
        invoiceNo: '#ORD-0245',
        date: now.subtract(const Duration(hours: 2)),
        qty: 3,
        total: 37.50,
      ),
      _SaleHistoryItem(
        invoiceNo: '#ORD-0240',
        date: now.subtract(const Duration(hours: 8)),
        qty: 1,
        total: 12.50,
      ),
      _SaleHistoryItem(
        invoiceNo: '#ORD-0235',
        date: now.subtract(const Duration(days: 1)),
        qty: 5,
        total: 62.50,
      ),
    ];

    if (_totalSalesCount == 0 && sampleSales.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: AlhaiEmptyState(
          icon: Icons.receipt_long_outlined,
          title: l10n.noSalesHistory,
          compact: true,
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DataTable(
          headingTextStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.getTextSecondary(isDark),
              ),
          dataTextStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.getTextPrimary(isDark),
              ),
          columnSpacing: 24,
          columns: [
            DataColumn(label: Text(l10n.invoiceNumber)),
            DataColumn(label: Text(l10n.date)),
            DataColumn(label: Text(l10n.quantity), numeric: true),
            DataColumn(label: Text(l10n.total), numeric: true),
          ],
          rows: sampleSales.map((sale) {
            return DataRow(cells: [
              DataCell(
                InkWell(
                  onTap: () {},
                  child: Text(
                    sale.invoiceNo,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              DataCell(Text(
                '${sale.date.day}/${sale.date.month}/${sale.date.year}',
                style: const TextStyle(fontFamily: 'monospace'),
              )),
              DataCell(Text(
                '${sale.qty}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              )),
              DataCell(Text(
                CurrencyFormatter.format(sale.total),
                style: const TextStyle(fontWeight: FontWeight.w600),
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  // ============================================================================
  // QUICK STATS (Right Column / Mobile)
  // ============================================================================

  Widget _buildQuickStats(bool isDark, AppLocalizations l10n) {
    final revenue = _product!.price * _totalSalesCount;

    return Row(
      children: [
        Expanded(
          child: _card(
            isDark: isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.shopping_bag_outlined,
                      size: 20, color: AppColors.primary),
                ),
                const SizedBox(height: 12),
                Text(
                  '$_totalSalesCount',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.getTextPrimary(isDark),
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.totalSales,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.getTextSecondary(isDark),
                      ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _card(
            isDark: isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.monetization_on_outlined,
                      size: 20, color: AppColors.secondary),
                ),
                const SizedBox(height: 12),
                Text(
                  CurrencyFormatter.formatCompact(revenue),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.getTextPrimary(isDark),
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.revenue,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.getTextSecondary(isDark),
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // CATEGORY CARD
  // ============================================================================

  Widget _buildCategoryCard(bool isDark, AppLocalizations l10n) {
    return _card(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.categoryLabel,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(isDark),
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (_category != null
                          ? AppColors.getCategoryColor(_category!.name)
                          : AppColors.grey400)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.category_outlined,
                  size: 20,
                  color: _category != null
                      ? AppColors.getCategoryColor(_category!.name)
                      : AppColors.grey400,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _category?.name ?? l10n.uncategorized,
                      style:
                          Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.getTextPrimary(isDark),
                              ),
                    ),
                  ],
                ),
              ),
              AlhaiIconButton(
                icon: Icons.edit_outlined,
                iconSize: 18,
                color: AppColors.getTextMuted(isDark),
                onPressed: () {},
                tooltip: l10n.edit,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: AppColors.getBorder(isDark)),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.local_shipping_outlined,
                    size: 20, color: AppColors.info),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.supplier,
                      style:
                          Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.getTextMuted(isDark),
                              ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.noSupplier,
                      style:
                          Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.getTextSecondary(isDark),
                              ),
                    ),
                  ],
                ),
              ),
              AlhaiIconButton(
                icon: Icons.edit_outlined,
                iconSize: 18,
                color: AppColors.getTextMuted(isDark),
                onPressed: () {},
                tooltip: l10n.edit,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // LAST SALE ACTIVITY CARD
  // ============================================================================

  Widget _buildLastSaleCard(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.of(context, size: ShadowSize.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.receipt_outlined,
                    size: 20, color: AppColors.primaryLight),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.lastSale,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '#ORD-0245',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.primaryLight,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'monospace',
                ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatRelativeTime(
                DateTime.now().subtract(const Duration(hours: 2)), l10n),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '3 ${l10n.units} • 37.50 ${l10n.sar}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              InkWell(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    l10n.viewAll,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // HELPERS
  // ============================================================================

  Widget _card({
    required bool isDark,
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
        boxShadow: AppShadows.of(context, size: ShadowSize.md),
      ),
      child: child,
    );
  }

  Widget _statusBadge(bool isActive, AppLocalizations l10n) {
    final color = isActive ? AppColors.success : AppColors.grey400;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isActive ? l10n.active : l10n.inactive,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _codeBadge({
    required String label,
    required String value,
    required bool isDark,
    required VoidCallback onCopy,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.getTextMuted(isDark),
                ),
          ),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                    color: AppColors.getTextPrimary(isDark),
                    letterSpacing: 0.5,
                  ),
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: onCopy,
            borderRadius: BorderRadius.circular(4),
            child: Icon(
              Icons.copy_rounded,
              size: 14,
              color: AppColors.getTextMuted(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _movementTypeBadge(
      String type, bool isDark, AppLocalizations l10n) {
    Color color;
    String label;

    switch (type.toLowerCase()) {
      case 'sale':
        color = AppColors.error;
        label = l10n.sale;
        break;
      case 'purchase':
        color = AppColors.success;
        label = l10n.purchase;
        break;
      case 'adjustment':
        color = AppColors.warning;
        label = l10n.adjustment;
        break;
      case 'return':
        color = AppColors.info;
        label = l10n.returnText;
        break;
      case 'waste':
        color = AppColors.grey500;
        label = l10n.waste;
        break;
      default:
        color = AppColors.grey400;
        label = type;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
      ),
    );
  }

  void _showMoreOptions(BuildContext ctx) {
    final l10n = AppLocalizations.of(ctx)!;
    showModalBottomSheet(
      context: ctx,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      // M124: constrain bottom sheet height and width on desktop
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(ctx).size.height * 0.5,
        maxWidth: 600,
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.share_outlined),
                title: Text(l10n.shareReceipt),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.content_copy_outlined),
                title: Text(l10n.duplicateProduct),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.error),
                title: Text(l10n.delete,
                    style: const TextStyle(color: AppColors.error)),
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  String _formatRelativeTime(DateTime date, AppLocalizations l10n) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) {
      return l10n.minutesAgo(diff.inMinutes);
    } else if (diff.inHours < 24) {
      return l10n.hoursAgo(diff.inHours);
    } else {
      return l10n.daysAgo(diff.inDays);
    }
  }
}

// ============================================================================
// HELPER MODELS
// ============================================================================

class _PriceHistoryItem {
  final DateTime date;
  final double oldPrice;
  final double newPrice;
  final String reason;

  _PriceHistoryItem({
    required this.date,
    required this.oldPrice,
    required this.newPrice,
    required this.reason,
  });
}

class _SaleHistoryItem {
  final String invoiceNo;
  final DateTime date;
  final int qty;
  final double total;

  _SaleHistoryItem({
    required this.invoiceNo,
    required this.date,
    required this.qty,
    required this.total,
  });
}
