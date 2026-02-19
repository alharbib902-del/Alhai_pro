/// شاشة تقرير أفضل المنتجات - Top Products Report Screen
///
/// تقرير شامل لأداء المنتجات والمبيعات
library;

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';

/// شاشة تقرير أفضل المنتجات
class TopProductsReportScreen extends StatefulWidget {
  const TopProductsReportScreen({super.key});

  @override
  State<TopProductsReportScreen> createState() =>
      _TopProductsReportScreenState();
}

class _TopProductsReportScreenState extends State<TopProductsReportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );

  String _sortBy = 'revenue';
  String _selectedCategory = 'all';

  // بيانات تجريبية
  final List<ProductReport> _products = [
    ProductReport(
      id: '1',
      name: 'حليب المراعي كامل الدسم 1 لتر',
      sku: 'MLK001',
      category: 'ألبان ومشتقاتها',
      unitsSold: 1250,
      revenue: 8750.0,
      profit: 1750.0,
      avgPrice: 7.0,
      stockLevel: 150,
      returnRate: 1.2,
      trend: 'up',
    ),
    ProductReport(
      id: '2',
      name: 'أرز بسمتي أبو كاس 5 كجم',
      sku: 'RIC001',
      category: 'أرز ومكرونة',
      unitsSold: 850,
      revenue: 29750.0,
      profit: 5950.0,
      avgPrice: 35.0,
      stockLevel: 75,
      returnRate: 0.5,
      trend: 'up',
    ),
    ProductReport(
      id: '3',
      name: 'زيت عافية نباتي 1.8 لتر',
      sku: 'OIL001',
      category: 'زيوت وسمن',
      unitsSold: 720,
      revenue: 17280.0,
      profit: 3456.0,
      avgPrice: 24.0,
      stockLevel: 45,
      returnRate: 0.8,
      trend: 'stable',
    ),
    ProductReport(
      id: '4',
      name: 'سكر أبيض 1 كجم',
      sku: 'SUG001',
      category: 'سكر وحلويات',
      unitsSold: 650,
      revenue: 4225.0,
      profit: 845.0,
      avgPrice: 6.5,
      stockLevel: 200,
      returnRate: 0.3,
      trend: 'down',
    ),
    ProductReport(
      id: '5',
      name: 'شاي ربيع 100 كيس',
      sku: 'TEA001',
      category: 'مشروبات',
      unitsSold: 580,
      revenue: 10440.0,
      profit: 2088.0,
      avgPrice: 18.0,
      stockLevel: 120,
      returnRate: 0.6,
      trend: 'up',
    ),
    ProductReport(
      id: '6',
      name: 'معجون طماطم الكبير 400 جم',
      sku: 'TOM001',
      category: 'معلبات',
      unitsSold: 480,
      revenue: 3360.0,
      profit: 672.0,
      avgPrice: 7.0,
      stockLevel: 95,
      returnRate: 1.0,
      trend: 'stable',
    ),
    ProductReport(
      id: '7',
      name: 'مكرونة المهيدب 400 جم',
      sku: 'PAS001',
      category: 'أرز ومكرونة',
      unitsSold: 420,
      revenue: 2100.0,
      profit: 420.0,
      avgPrice: 5.0,
      stockLevel: 180,
      returnRate: 0.4,
      trend: 'up',
    ),
    ProductReport(
      id: '8',
      name: 'جبنة كرافت 200 جم',
      sku: 'CHE001',
      category: 'ألبان ومشتقاتها',
      unitsSold: 380,
      revenue: 5700.0,
      profit: 1140.0,
      avgPrice: 15.0,
      stockLevel: 65,
      returnRate: 0.7,
      trend: 'stable',
    ),
  ];

  final List<String> _categories = [
    'all',
    'ألبان ومشتقاتها',
    'أرز ومكرونة',
    'زيوت وسمن',
    'سكر وحلويات',
    'مشروبات',
    'معلبات',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<ProductReport> get _filteredProducts {
    var filtered = _products;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقرير المنتجات'),
        actions: [
          IconButton(
            onPressed: _selectDateRange,
            icon: const Icon(Icons.date_range),
            tooltip: 'تحديد الفترة',
          ),
          IconButton(
            onPressed: _exportReport,
            icon: const Icon(Icons.download),
            tooltip: 'تصدير',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'أفضل المنتجات'),
            Tab(text: 'حسب الفئة'),
            Tab(text: 'تحليل الأداء'),
          ],
        ),
      ),
      body: Column(
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
    return Column(
      children: [
        // أدوات الفلترة
        _buildFilterBar(),

        // القائمة
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSizes.md),
            itemCount: _filteredProducts.length,
            itemBuilder: (context, index) {
              return _buildProductCard(_filteredProducts[index], index + 1);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: const Border(
          bottom: BorderSide(color: AppColors.grey200),
        ),
      ),
      child: Row(
        children: [
          // فلتر الفئة
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'الفئة',
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
                  child: Text(cat == 'all' ? 'جميع الفئات' : cat),
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
                labelText: 'ترتيب حسب',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.md,
                  vertical: AppSizes.sm,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'revenue',
                  child: Text('الإيرادات'),
                ),
                DropdownMenuItem(
                  value: 'units',
                  child: Text('الوحدات'),
                ),
                DropdownMenuItem(
                  value: 'profit',
                  child: Text('الأرباح'),
                ),
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
                                : Colors.brown)
                        : AppColors.grey200,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '#$rank',
                    style: AppTypography.labelMedium.copyWith(
                      color: rank <= 3 ? Colors.white : AppColors.textPrimary,
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
                          const SizedBox(width: AppSizes.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.grey100,
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusSm),
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
                    'الإيرادات',
                    '${product.revenue.toStringAsFixed(0)} ر.س',
                    AppColors.primary,
                  ),
                ),
                Expanded(
                  child: _buildProductStat(
                    'الوحدات',
                    '${product.unitsSold}',
                    AppColors.info,
                  ),
                ),
                Expanded(
                  child: _buildProductStat(
                    'الربح',
                    '${product.profit.toStringAsFixed(0)} ر.س',
                    AppColors.success,
                  ),
                ),
                Expanded(
                  child: _buildProductStat(
                    'المخزون',
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
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryTab() {
    // حساب إحصائيات الفئات
    final categoryStats = <String, CategoryStats>{};
    for (final product in _products) {
      if (!categoryStats.containsKey(product.category)) {
        categoryStats[product.category] = CategoryStats(
          name: product.category,
          productCount: 0,
          totalRevenue: 0,
          totalUnits: 0,
          totalProfit: 0,
        );
      }
      categoryStats[product.category] = CategoryStats(
        name: product.category,
        productCount: categoryStats[product.category]!.productCount + 1,
        totalRevenue:
            categoryStats[product.category]!.totalRevenue + product.revenue,
        totalUnits:
            categoryStats[product.category]!.totalUnits + product.unitsSold,
        totalProfit:
            categoryStats[product.category]!.totalProfit + product.profit,
      );
    }

    final sortedCategories = categoryStats.values.toList()
      ..sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));

    final totalRevenue =
        sortedCategories.fold(0.0, (sum, cat) => sum + cat.totalRevenue);

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
                  'توزيع الإيرادات حسب الفئة',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSizes.lg),

                // Chart simulation
                ...sortedCategories.map((cat) {
                  final percentage = cat.totalRevenue / totalRevenue * 100;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              cat.name,
                              style: AppTypography.bodyMedium,
                            ),
                            Text(
                              '${cat.totalRevenue.toStringAsFixed(0)} ر.س (${percentage.toStringAsFixed(0)}%)',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: percentage / 100,
                          backgroundColor: AppColors.grey200,
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
    final categoryProducts =
        _products.where((p) => p.category == category.name).toList();

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
          style: AppTypography.titleSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${category.productCount} منتج • ${category.totalRevenue.toStringAsFixed(0)} ر.س',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textMuted,
          ),
        ),
        children: categoryProducts
            .map((p) => ListTile(
                  title: Text(p.name),
                  subtitle: Text('${p.unitsSold} وحدة'),
                  trailing: Text(
                    '${p.revenue.toStringAsFixed(0)} ر.س',
                    style: AppTypography.titleSmall.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ))
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

        // توصيات
        _buildRecommendations(),
      ],
    );
  }

  Widget _buildKPICards() {
    final totalRevenue = _products.fold(0.0, (sum, p) => sum + p.revenue);
    final totalUnits = _products.fold(0, (sum, p) => sum + p.unitsSold);
    final totalProfit = _products.fold(0.0, (sum, p) => sum + p.profit);
    final avgMargin = totalProfit / totalRevenue * 100;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildKPICard(
                'إجمالي الإيرادات',
                '${totalRevenue.toStringAsFixed(0)} ر.س',
                Icons.attach_money,
                AppColors.success,
                '+15%',
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: _buildKPICard(
                'الوحدات المباعة',
                totalUnits.toString(),
                Icons.inventory,
                AppColors.primary,
                '+8%',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.md),
        Row(
          children: [
            Expanded(
              child: _buildKPICard(
                'إجمالي الربح',
                '${totalProfit.toStringAsFixed(0)} ر.س',
                Icons.trending_up,
                AppColors.info,
                '+12%',
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: _buildKPICard(
                'هامش الربح',
                '${avgMargin.toStringAsFixed(1)}%',
                Icons.percent,
                AppColors.warning,
                '+2%',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKPICard(
    String label,
    String value,
    IconData icon,
    Color color,
    String change,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSizes.sm),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.arrow_upward,
                        size: 12,
                        color: AppColors.success,
                      ),
                      Text(
                        change,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'نظرة عامة على الأداء',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            Row(
              children: [
                Expanded(
                  child: _buildPerformanceIndicator(
                    'منتجات متصاعدة',
                    '5',
                    Icons.trending_up,
                    AppColors.success,
                  ),
                ),
                Expanded(
                  child: _buildPerformanceIndicator(
                    'منتجات مستقرة',
                    '2',
                    Icons.trending_flat,
                    AppColors.warning,
                  ),
                ),
                Expanded(
                  child: _buildPerformanceIndicator(
                    'منتجات متراجعة',
                    '1',
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
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textMuted,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSlowMovingProducts() {
    final slowMoving = _products.where((p) => p.unitsSold < 500).toList()
      ..sort((a, b) => a.unitsSold.compareTo(b.unitsSold));

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
                  'منتجات بطيئة الحركة',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),
            ...slowMoving.take(3).map(
                  (product) => ListTile(
                    title: Text(product.name),
                    subtitle: Text(
                      '${product.unitsSold} وحدة • ${product.stockLevel} في المخزون',
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.sm,
                        vertical: AppSizes.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusSm),
                      ),
                      child: Text(
                        'بطيء',
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

  Widget _buildRecommendations() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb, color: AppColors.info),
                const SizedBox(width: AppSizes.sm),
                Text(
                  'توصيات AI',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),
            _buildRecommendationItem(
              'زيادة المخزون',
              'زيت عافية نباتي يحتاج لإعادة طلب - المخزون أقل من الحد الأدنى',
              Icons.inventory,
              AppColors.warning,
            ),
            _buildRecommendationItem(
              'عرض ترويجي',
              'سكر أبيض - أداء منخفض، جرب عرض خاص لزيادة المبيعات',
              Icons.local_offer,
              AppColors.primary,
            ),
            _buildRecommendationItem(
              'فرصة نمو',
              'أرز بسمتي - مبيعات متصاعدة، فكر في زيادة المخزون',
              Icons.trending_up,
              AppColors.success,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
      child: Row(
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
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'ألبان ومشتقاتها':
        return Colors.blue;
      case 'أرز ومكرونة':
        return Colors.orange;
      case 'زيوت وسمن':
        return Colors.amber;
      case 'سكر وحلويات':
        return Colors.pink;
      case 'مشروبات':
        return Colors.teal;
      case 'معلبات':
        return Colors.red;
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
      });
    }
  }

  void _exportReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('جاري تصدير التقرير...'),
      ),
    );
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
  final int stockLevel;
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
