/// شاشة تقرير أفضل المنتجات - Top Products Report Screen
///
/// تقرير شامل لأداء المنتجات والمبيعات
/// يستعلم من sale_items مع products للحصول على بيانات المبيعات الحقيقية
library;

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_design_system/alhai_design_system.dart' show AlhaiSpacing;
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../utils/csv_export_helper.dart';

/// شاشة تقرير أفضل المنتجات
class TopProductsReportScreen extends ConsumerStatefulWidget {
  const TopProductsReportScreen({super.key});

  @override
  ConsumerState<TopProductsReportScreen> createState() =>
      _TopProductsReportScreenState();
}

class _TopProductsReportScreenState
    extends ConsumerState<TopProductsReportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );

  String _sortBy = 'revenue';
  String _selectedCategory = 'all';
  bool _isLoading = true;

  // بيانات المنتجات - يتم تحميلها من قاعدة البيانات
  List<ProductReport> _products = [];

  List<String> _categories = ['all'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      setState(() => _isLoading = true);
      final db = GetIt.I<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider) ?? kDefaultStoreId;

      // استعلام المنتجات الأكثر مبيعاً من sale_items مع join على products و sales
      final results = await db.customSelect(
        '''SELECT
             p.id,
             p.name,
             p.sku,
             p.category_id,
             p.price,
             p.cost_price,
             p.stock_qty,
             COALESCE(SUM(si.qty), 0) as units_sold,
             COALESCE(SUM(si.total), 0) as revenue,
             COALESCE(SUM(si.qty * COALESCE(p.cost_price, 0)), 0) as total_cost
           FROM products p
           LEFT JOIN sale_items si ON si.product_id = p.id
           LEFT JOIN sales s ON s.id = si.sale_id
             AND s.status = 'completed'
             AND s.created_at >= ?
             AND s.created_at < ?
           WHERE p.store_id = ?
             AND p.is_active = 1
           GROUP BY p.id
           ORDER BY revenue DESC''',
        variables: [
          Variable.withDateTime(_dateRange.start),
          Variable.withDateTime(
            DateTime(
              _dateRange.end.year,
              _dateRange.end.month,
              _dateRange.end.day + 1,
            ),
          ),
          Variable.withString(storeId),
        ],
      ).get();

      if (results.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      final mappedProducts = results.map((row) {
        final unitsSold = row.data['units_sold'] as int? ?? 0;
        final revenue = (row.data['revenue'] is int)
            ? (row.data['revenue'] as int).toDouble()
            : row.data['revenue'] as double? ?? 0.0;
        final totalCost = (row.data['total_cost'] is int)
            ? (row.data['total_cost'] as int).toDouble()
            : row.data['total_cost'] as double? ?? 0.0;
        final profit = revenue - totalCost;
        final price = (row.data['price'] is int)
            ? (row.data['price'] as int).toDouble()
            : row.data['price'] as double? ?? 0.0;
        final stockQty = (row.data['stock_qty'] as num?)?.toDouble() ?? 0.0;

        // تحديد الاتجاه بناءً على الكمية المباعة
        String trend;
        if (unitsSold > 50) {
          trend = 'up';
        } else if (unitsSold > 10) {
          trend = 'stable';
        } else {
          trend = 'down';
        }

        return ProductReport(
          id: row.data['id'] as String,
          name: row.data['name'] as String,
          sku: row.data['sku'] as String? ?? '',
          category: row.data['category_id'] as String? ?? '',
          unitsSold: unitsSold,
          revenue: revenue,
          profit: profit,
          avgPrice: price,
          stockLevel: stockQty,
          returnRate: 0,
          trend: trend,
        );
      }).toList();

      // استخراج الفئات الفريدة
      final cats = <String>{'all'};
      for (final p in mappedProducts) {
        if (p.category.isNotEmpty) cats.add(p.category);
      }

      setState(() {
        _products = mappedProducts;
        _categories = cats.toList();
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<ProductReport> get _filteredProducts {
    var filtered = List<ProductReport>.from(_products);
    if (_selectedCategory != 'all') {
      filtered =
          filtered.where((p) => p.category == _selectedCategory).toList();
    }

    switch (_sortBy) {
      case 'revenue':
        filtered.sort((a, b) => b.revenue.compareTo(a.revenue));
        break;
      case 'units':
        filtered.sort((a, b) => b.unitsSold.compareTo(a.unitsSold));
        break;
      case 'profit':
        filtered.sort((a, b) => b.profit.compareTo(a.profit));
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.products),
        actions: [
          IconButton(
            onPressed: _selectDateRange,
            icon: const Icon(Icons.date_range),
            tooltip: l10n.date,
          ),
          IconButton(
            onPressed: _exportReport,
            icon: const Icon(Icons.download),
            tooltip: l10n.exportAction,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.topProductsTab),
            Tab(text: l10n.byCategoryTab),
            Tab(text: l10n.performanceAnalysisTab),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // شريط الفترة الزمنية
                _buildDateRangeBanner(),

                // المحتوى
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTopProductsTab(),
                      _buildCategoryTab(),
                      _buildPerformanceTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildDateRangeBanner() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      color: AppColors.primary.withValues(alpha: 0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
          const SizedBox(width: AppSizes.sm),
          Text(
            '${_formatDate(_dateRange.start)} - ${_formatDate(_dateRange.end)}',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopProductsTab() {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        // أدوات الفلترة
        _buildFilterBar(),

        // القائمة
        Expanded(
          child: _filteredProducts.isEmpty
              ? Center(child: Text(l10n.noSalesDataForPeriod))
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSizes.md),
                  itemCount: _filteredProducts.length,
                  itemBuilder: (context, index) {
                    return _buildProductCard(
                      _filteredProducts[index],
                      index + 1,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          // فلتر الفئة
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: InputDecoration(
                labelText: l10n.categoryFilter,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.md,
                  vertical: AppSizes.sm,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
              ),
              items: _categories.map((cat) {
                return DropdownMenuItem(
                  value: cat,
                  child: Text(cat == 'all' ? l10n.allCategoriesFilter : cat),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                  });
                }
              },
            ),
          ),
          const SizedBox(width: AppSizes.md),

          // الترتيب حسب
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: _sortBy,
              decoration: InputDecoration(
                labelText: l10n.sortByField,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.md,
                  vertical: AppSizes.sm,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
              ),
              items: [
                DropdownMenuItem(
                  value: 'revenue',
                  child: Text(l10n.revenueSort),
                ),
                DropdownMenuItem(value: 'units', child: Text(l10n.unitsSort)),
                DropdownMenuItem(value: 'profit', child: Text(l10n.profitSort)),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _sortBy = value;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(ProductReport product, int rank) {
    final l10n = AppLocalizations.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          children: [
            Row(
              children: [
                // الترتيب
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: rank <= 3
                        ? (rank == 1
                            ? AppColors.warning
                            : rank == 2
                                ? AppColors.grey400
                                : const Color(0xFF795548))
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '#$rank',
                    style: AppTypography.labelMedium.copyWith(
                      color: rank <= 3
                          ? Theme.of(context).colorScheme.surface
                          : Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.md),

                // المنتج
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Text(
                            product.sku,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                          if (product.category.isNotEmpty) ...[
                            const SizedBox(width: AppSizes.sm),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(
                                  AppSizes.radiusSm,
                                ),
                              ),
                              child: Text(
                                product.category,
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.textMuted,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Trend
                Icon(
                  product.trend == 'up'
                      ? Icons.trending_up
                      : product.trend == 'down'
                          ? Icons.trending_down
                          : Icons.trending_flat,
                  color: product.trend == 'up'
                      ? AppColors.success
                      : product.trend == 'down'
                          ? AppColors.error
                          : AppColors.warning,
                ),
              ],
            ),
            const Divider(height: AppSizes.lg),

            // الإحصائيات
            Row(
              children: [
                Expanded(
                  child: _buildProductStat(
                    l10n.revenueLabel,
                    '${product.revenue.toStringAsFixed(0)} ${l10n.sar}',
                    AppColors.primary,
                  ),
                ),
                Expanded(
                  child: _buildProductStat(
                    l10n.unitsLabel,
                    '${product.unitsSold}',
                    AppColors.info,
                  ),
                ),
                Expanded(
                  child: _buildProductStat(
                    l10n.profitLabel,
                    '${product.profit.toStringAsFixed(0)} ${l10n.sar}',
                    AppColors.success,
                  ),
                ),
                Expanded(
                  child: _buildProductStat(
                    l10n.stockLabel,
                    '${product.stockLevel}',
                    product.stockLevel < 50
                        ? AppColors.error
                        : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.titleSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _buildCategoryTab() {
    final l10n = AppLocalizations.of(context);
    // حساب إحصائيات الفئات
    final categoryStats = <String, CategoryStats>{};
    for (final product in _products) {
      final catName =
          product.category.isEmpty ? l10n.unclassified : product.category;
      if (!categoryStats.containsKey(catName)) {
        categoryStats[catName] = CategoryStats(
          name: catName,
          productCount: 0,
          totalRevenue: 0,
          totalUnits: 0,
          totalProfit: 0,
        );
      }
      categoryStats[catName] = CategoryStats(
        name: catName,
        productCount: categoryStats[catName]!.productCount + 1,
        totalRevenue: categoryStats[catName]!.totalRevenue + product.revenue,
        totalUnits: categoryStats[catName]!.totalUnits + product.unitsSold,
        totalProfit: categoryStats[catName]!.totalProfit + product.profit,
      );
    }

    final sortedCategories = categoryStats.values.toList()
      ..sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));

    final totalRevenue = sortedCategories.fold(
      0.0,
      (sum, cat) => sum + cat.totalRevenue,
    );

    return ListView(
      padding: const EdgeInsets.all(AppSizes.lg),
      children: [
        // ملخص
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.revenueByCategoryTitle,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSizes.lg),
                if (totalRevenue == 0)
                  Padding(
                    padding: const EdgeInsets.all(AlhaiSpacing.md),
                    child: Center(child: Text(l10n.noRevenueForPeriod)),
                  )
                else
                  // Chart simulation
                  ...sortedCategories.map((cat) {
                    final percentage = totalRevenue > 0
                        ? cat.totalRevenue / totalRevenue * 100
                        : 0.0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(cat.name, style: AppTypography.bodyMedium),
                              Text(
                                '${cat.totalRevenue.toStringAsFixed(0)} ${l10n.sar} (${percentage.toStringAsFixed(0)}%)',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AlhaiSpacing.xxs),
                          LinearProgressIndicator(
                            value: percentage / 100,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation(
                              _getCategoryColor(cat.name),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSizes.lg),

        // تفاصيل الفئات
        ...sortedCategories.map((cat) => _buildCategoryCard(cat)),
      ],
    );
  }

  Widget _buildCategoryCard(CategoryStats category) {
    final l10n = AppLocalizations.of(context);
    final categoryProducts = _products
        .where(
          (p) =>
              (p.category.isEmpty ? l10n.unclassified : p.category) ==
              category.name,
        )
        .toList()
      ..sort((a, b) => b.revenue.compareTo(a.revenue));

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      child: ExpansionTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getCategoryColor(category.name).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          ),
          child: Icon(
            _getCategoryIcon(category.name),
            color: _getCategoryColor(category.name),
          ),
        ),
        title: Text(
          category.name,
          style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${category.productCount} ${l10n.productUnit} | ${category.totalUnits} ${l10n.unitsSoldUnit} | ${category.totalRevenue.toStringAsFixed(0)} ${l10n.sar}',
          style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
        ),
        children: categoryProducts
            .take(10)
            .map(
              (p) => ListTile(
                title: Text(p.name),
                subtitle: Text('${p.unitsSold} ${l10n.unitsSoldUnit}'),
                trailing: Text(
                  '${p.revenue.toStringAsFixed(0)} ${l10n.sar}',
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildPerformanceTab() {
    return ListView(
      padding: const EdgeInsets.all(AppSizes.lg),
      children: [
        // KPIs
        _buildKPICards(),
        const SizedBox(height: AppSizes.lg),

        // أداء المنتجات
        _buildPerformanceOverview(),
        const SizedBox(height: AppSizes.lg),

        // المنتجات بطيئة الحركة
        _buildSlowMovingProducts(),
        const SizedBox(height: AppSizes.lg),

        // المنتجات منخفضة المخزون مع مبيعات عالية
        _buildLowStockHighSales(),
      ],
    );
  }

  Widget _buildKPICards() {
    final l10n = AppLocalizations.of(context);
    final totalRevenue = _products.fold(0.0, (sum, p) => sum + p.revenue);
    final totalUnits = _products.fold(0, (sum, p) => sum + p.unitsSold);
    final totalProfit = _products.fold(0.0, (sum, p) => sum + p.profit);
    final avgMargin = totalRevenue > 0 ? totalProfit / totalRevenue * 100 : 0.0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildKPICard(
                l10n.totalRevenueKpi,
                '${totalRevenue.toStringAsFixed(0)} ${l10n.sar}',
                Icons.attach_money,
                AppColors.success,
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: _buildKPICard(
                l10n.unitsSoldKpi,
                totalUnits.toString(),
                Icons.inventory,
                AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.md),
        Row(
          children: [
            Expanded(
              child: _buildKPICard(
                l10n.totalProfitKpi,
                '${totalProfit.toStringAsFixed(0)} ${l10n.sar}',
                Icons.trending_up,
                AppColors.info,
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: _buildKPICard(
                l10n.profitMarginKpi,
                '${avgMargin.toStringAsFixed(1)}%',
                Icons.percent,
                AppColors.warning,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKPICard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.sm),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: AppSizes.md),
            Text(
              value,
              style: AppTypography.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceOverview() {
    final l10n = AppLocalizations.of(context);
    final upCount = _products.where((p) => p.trend == 'up').length;
    final stableCount = _products.where((p) => p.trend == 'stable').length;
    final downCount = _products.where((p) => p.trend == 'down').length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.performanceOverview,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            Row(
              children: [
                Expanded(
                  child: _buildPerformanceIndicator(
                    l10n.trendingUpProducts,
                    '$upCount',
                    Icons.trending_up,
                    AppColors.success,
                  ),
                ),
                Expanded(
                  child: _buildPerformanceIndicator(
                    l10n.stableProducts,
                    '$stableCount',
                    Icons.trending_flat,
                    AppColors.warning,
                  ),
                ),
                Expanded(
                  child: _buildPerformanceIndicator(
                    l10n.trendingDownProducts,
                    '$downCount',
                    Icons.trending_down,
                    AppColors.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceIndicator(
    String label,
    String count,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: AppSizes.sm),
        Text(
          count,
          style: AppTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSlowMovingProducts() {
    final l10n = AppLocalizations.of(context);
    // المنتجات التي لم تُباع أو مبيعاتها منخفضة جداً
    final slowMoving = _products
        .where((p) => p.unitsSold == 0 && p.stockLevel > 0)
        .toList()
      ..sort((a, b) => b.stockLevel.compareTo(a.stockLevel));

    if (slowMoving.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber, color: AppColors.warning),
                const SizedBox(width: AppSizes.sm),
                Text(
                  l10n.noSalesProducts(slowMoving.length),
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),
            ...slowMoving.take(5).map(
                  (product) => ListTile(
                    title: Text(product.name),
                    subtitle: Text(
                      l10n.inStockCount(product.stockLevel.round()),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.sm,
                        vertical: AppSizes.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      ),
                      child: Text(
                        l10n.slowMovingLabel,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  /// منتجات مبيعاتها عالية ولكن مخزونها منخفض - تحتاج إعادة طلب
  Widget _buildLowStockHighSales() {
    final l10n = AppLocalizations.of(context);
    final needsReorder = _products
        .where((p) => p.unitsSold > 10 && p.stockLevel < 20)
        .toList()
      ..sort((a, b) => a.stockLevel.compareTo(b.stockLevel));

    if (needsReorder.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.inventory_2, color: AppColors.error),
                const SizedBox(width: AppSizes.sm),
                Text(
                  l10n.needsReorder(needsReorder.length),
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),
            ...needsReorder.take(5).map(
                  (product) => ListTile(
                    title: Text(product.name),
                    subtitle: Text(
                      l10n.soldUnitsStock(
                        product.unitsSold,
                        product.stockLevel.round(),
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.sm,
                        vertical: AppSizes.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      ),
                      child: Text(
                        l10n.reorderLabel,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'ألبان ومشتقاتها':
        return AppColors.info;
      case 'أرز ومكرونة':
        return AppColors.secondary;
      case 'زيوت وسمن':
        return AppColors.warning;
      case 'سكر وحلويات':
        return const Color(0xFFE91E63);
      case 'مشروبات':
        return const Color(0xFF009688);
      case 'معلبات':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'ألبان ومشتقاتها':
        return Icons.local_drink;
      case 'أرز ومكرونة':
        return Icons.rice_bowl;
      case 'زيوت وسمن':
        return Icons.water_drop;
      case 'سكر وحلويات':
        return Icons.cake;
      case 'مشروبات':
        return Icons.local_cafe;
      case 'معلبات':
        return Icons.inventory_2;
      default:
        return Icons.category;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );

    if (picked != null) {
      setState(() {
        _dateRange = picked;
        _isLoading = true;
      });
      _loadProducts();
    }
  }

  Future<void> _exportReport() async {
    final l10n = AppLocalizations.of(context);
    final result = await CsvExportHelper.exportAndShare(
      context: context,
      fileName: 'تقرير_المنتجات',
      headers: [
        l10n.products,
        'SKU',
        l10n.revenueLabel,
        l10n.unitsLabel,
        l10n.profitLabel,
        l10n.stockLabel,
      ],
      rows: _filteredProducts
          .map(
            (p) => [
              p.name,
              p.sku,
              p.revenue.toStringAsFixed(2),
              '${p.unitsSold}',
              p.profit.toStringAsFixed(2),
              '${p.stockLevel.round()}',
            ],
          )
          .toList(),
    );
    if (mounted) CsvExportHelper.showResultSnackBar(context, result);
  }
}

/// نموذج تقرير المنتج
class ProductReport {
  final String id;
  final String name;
  final String sku;
  final String category;
  final int unitsSold;
  final double revenue;
  final double profit;
  final double avgPrice;
  final double stockLevel;
  final double returnRate;
  final String trend;

  ProductReport({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.unitsSold,
    required this.revenue,
    required this.profit,
    required this.avgPrice,
    required this.stockLevel,
    required this.returnRate,
    required this.trend,
  });
}

/// إحصائيات الفئة
class CategoryStats {
  final String name;
  final int productCount;
  final double totalRevenue;
  final int totalUnits;
  final double totalProfit;

  CategoryStats({
    required this.name,
    required this.productCount,
    required this.totalRevenue,
    required this.totalUnits,
    required this.totalProfit,
  });
}
