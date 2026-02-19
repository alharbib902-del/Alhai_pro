/// شاشة تقرير العملاء - Customer Report Screen
///
/// تقرير شامل لنشاط وتحليلات العملاء
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';
import '../../data/local/app_database.dart';
import '../../di/injection.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/products_providers.dart';

/// شاشة تقرير العملاء
class CustomerReportScreen extends ConsumerStatefulWidget {
  const CustomerReportScreen({super.key});

  @override
  ConsumerState<CustomerReportScreen> createState() => _CustomerReportScreenState();
}

class _CustomerReportScreenState extends ConsumerState<CustomerReportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );
  bool _isLoading = true;

  // إحصائيات عامة
  int _totalCustomers = 0;
  int _newCustomers = 0;
  int _activeCustomers = 0;
  double _totalRevenue = 0.0;
  double _avgOrderValue = 0.0;

  // أفضل العملاء
  List<CustomerData> _topCustomers = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadCustomerData();
  }

  Future<void> _loadCustomerData() async {
    try {
      final db = getIt<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider) ?? kDemoStoreId;
      final accounts = await db.accountsDao.getAllAccounts(storeId);
      final now = _dateRange.end;
      final thirtyDaysAgo = _dateRange.start;

      _totalCustomers = accounts.length;
      _activeCustomers = accounts.where((a) =>
        a.lastTransactionAt != null && a.lastTransactionAt!.isAfter(thirtyDaysAgo)
      ).length;
      _newCustomers = accounts.where((a) =>
        a.createdAt.isAfter(thirtyDaysAgo)
      ).length;

      // Try to get sales stats for revenue
      try {
        final salesStats = await db.salesDao.getSalesStats(storeId, startDate: thirtyDaysAgo, endDate: now);
        _totalRevenue = salesStats.total;
        _avgOrderValue = _totalCustomers > 0 ? _totalRevenue / _totalCustomers : 0;
      } catch (_) {
        _totalRevenue = accounts.fold(0.0, (sum, a) => sum + a.balance);
        _avgOrderValue = _totalCustomers > 0 ? _totalRevenue / _totalCustomers : 0;
      }

      // Map accounts to CustomerData, sorted by balance descending
      final sorted = List.of(accounts)..sort((a, b) => b.balance.compareTo(a.balance));
      _topCustomers = sorted.take(20).map((a) {
        String tier;
        if (a.balance >= 10000) {
          tier = '\u0645\u0627\u0633\u064a';
        } else if (a.balance >= 5000) {
          tier = '\u0630\u0647\u0628\u064a';
        } else if (a.balance >= 2000) {
          tier = '\u0641\u0636\u064a';
        } else {
          tier = '\u0628\u0631\u0648\u0646\u0632\u064a';
        }

        return CustomerData(
          id: a.id,
          name: a.name,
          phone: a.phone ?? '',
          totalOrders: 0,
          totalSpent: a.balance,
          avgOrderValue: 0,
          lastOrderDate: a.lastTransactionAt ?? a.createdAt,
          tier: tier,
          loyaltyPoints: 0,
        );
      }).toList();

      setState(() => _isLoading = false);
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.customerReport),
        actions: [
          IconButton(
            onPressed: _selectDateRange,
            icon: const Icon(Icons.date_range),
            tooltip: AppLocalizations.of(context)!.date,
          ),
          IconButton(
            onPressed: _exportReport,
            icon: const Icon(Icons.download),
            tooltip: AppLocalizations.of(context)!.exportAction,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'نظرة عامة'),
            Tab(text: 'أفضل العملاء'),
            Tab(text: 'تحليل النمو'),
            Tab(text: 'الولاء'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // شريط الفترة الزمنية
          _buildDateRangeBanner(),

          // محتوى التقرير
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildTopCustomersTab(),
                _buildGrowthTab(),
                _buildLoyaltyTab(),
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
          const SizedBox(width: AppSizes.sm),
          Text(
            '(${_dateRange.duration.inDays} يوم)',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return ListView(
      padding: const EdgeInsets.all(AppSizes.lg),
      children: [
        // بطاقات الإحصائيات
        _buildStatsRow(),
        const SizedBox(height: AppSizes.lg),

        // توزيع العملاء حسب المستوى
        _buildTierDistribution(),
        const SizedBox(height: AppSizes.lg),

        // نشاط العملاء
        _buildActivitySummary(),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'إجمالي العملاء',
                _totalCustomers.toString(),
                Icons.people,
                AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: _buildStatCard(
                'عملاء جدد',
                '+$_newCustomers',
                Icons.person_add,
                AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.md),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'عملاء نشطين',
                _activeCustomers.toString(),
                Icons.trending_up,
                AppColors.info,
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: _buildStatCard(
                'متوسط قيمة الطلب',
                '${_avgOrderValue.toStringAsFixed(0)} ر.س',
                Icons.shopping_cart,
                AppColors.warning,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
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
                const SizedBox.shrink(),
              ],
            ),
            const SizedBox(height: AppSizes.md),
            Text(
              value,
              style: AppTypography.headlineMedium.copyWith(
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

  Widget _buildTierDistribution() {
    // حساب التوزيع الحقيقي من بيانات العملاء المحملة
    int diamond = 0, gold = 0, silver = 0, bronze = 0;
    for (final c in _topCustomers) {
      switch (c.tier) {
        case '\u0645\u0627\u0633\u064a': diamond++; break;
        case '\u0630\u0647\u0628\u064a': gold++; break;
        case '\u0641\u0636\u064a': silver++; break;
        default: bronze++; break;
      }
    }
    final tiers = [
      {'name': '\u0645\u0627\u0633\u064a', 'count': diamond, 'color': Colors.purple},
      {'name': '\u0630\u0647\u0628\u064a', 'count': gold, 'color': AppColors.warning},
      {'name': '\u0641\u0636\u064a', 'count': silver, 'color': AppColors.grey500},
      {'name': '\u0628\u0631\u0648\u0646\u0632\u064a', 'count': bronze, 'color': Colors.brown},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'توزيع العملاء حسب المستوى',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.lg),

            // Bar Chart simulation
            ...tiers.map((tier) {
              final percentage = _totalCustomers > 0
                  ? (tier['count'] as int) / _totalCustomers * 100
                  : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.md),
                child: Row(
                  children: [
                    SizedBox(
                      width: 60,
                      child: Text(
                        tier['name'] as String,
                        style: AppTypography.bodySmall,
                      ),
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppColors.grey200,
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusSm),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: percentage / 100,
                            child: Container(
                              height: 24,
                              decoration: BoxDecoration(
                                color: tier['color'] as Color,
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusSm),
                              ),
                              alignment: AlignmentDirectional.centerEnd,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.sm,
                              ),
                              child: Text(
                                '${tier['count']}',
                                style: AppTypography.labelSmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 50,
                      child: Text(
                        '${percentage.toStringAsFixed(0)}%',
                        textAlign: TextAlign.end,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitySummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ملخص النشاط',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.md),
            const Divider(),
            _buildActivityRow(
              'إجمالي الإيرادات من العملاء المسجلين',
              '${_totalRevenue.toStringAsFixed(0)} ر.س',
              Icons.attach_money,
              AppColors.success,
            ),
            _buildActivityRow(
              'متوسط قيمة الطلب لكل عميل',
              '${_avgOrderValue.toStringAsFixed(0)} ر.س',
              Icons.shopping_bag,
              AppColors.primary,
            ),
            _buildActivityRow(
              'عملاء نشطين (آخر 30 يوم)',
              '$_activeCustomers من $_totalCustomers',
              Icons.replay,
              AppColors.info,
            ),
            _buildActivityRow(
              'عملاء جدد (آخر 30 يوم)',
              '$_newCustomers',
              Icons.person_add,
              AppColors.warning,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityRow(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.xs),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodyMedium,
            ),
          ),
          Text(
            value,
            style: AppTypography.titleSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopCustomersTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.lg),
      itemCount: _topCustomers.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.md),
            child: Row(
              children: [
                Text(
                  'أفضل ${_topCustomers.length} عملاء',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                DropdownButton<String>(
                  value: 'spent',
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(
                      value: 'spent',
                      child: Text('حسب الإنفاق'),
                    ),
                    DropdownMenuItem(
                      value: 'orders',
                      child: Text('حسب الطلبات'),
                    ),
                    DropdownMenuItem(
                      value: 'points',
                      child: Text('حسب النقاط'),
                    ),
                  ],
                  onChanged: (value) {},
                ),
              ],
            ),
          );
        }

        final customer = _topCustomers[index - 1];
        return _buildTopCustomerCard(customer, index);
      },
    );
  }

  Widget _buildTopCustomerCard(CustomerData customer, int rank) {
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
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: rank <= 3
                        ? (rank == 1
                            ? AppColors.warning
                            : rank == 2
                                ? AppColors.grey400
                                : Colors.brown)
                        : AppColors.grey200,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$rank',
                    style: AppTypography.titleSmall.copyWith(
                      color: rank <= 3 ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.md),

                // الصورة والاسم
                CircleAvatar(
                  backgroundColor: _getTierColor(customer.tier).withValues(alpha: 0.1),
                  child: Text(
                    customer.name[0],
                    style: TextStyle(
                      color: _getTierColor(customer.tier),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.md),

                // المعلومات
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            customer.name,
                            style: AppTypography.titleSmall.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: AppSizes.xs),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getTierColor(customer.tier),
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusSm),
                            ),
                            child: Text(
                              customer.tier,
                              style: AppTypography.labelSmall.copyWith(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        customer.phone,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),

                // الإجمالي
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${customer.totalSpent.toStringAsFixed(0)} ر.س',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${customer.totalOrders} طلب',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: AppSizes.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCustomerStat(
                  'متوسط الطلب',
                  '${customer.avgOrderValue.toStringAsFixed(0)} ر.س',
                ),
                _buildCustomerStat(
                  'نقاط الولاء',
                  '${customer.loyaltyPoints}',
                ),
                _buildCustomerStat(
                  'آخر طلب',
                  _formatRelativeDate(customer.lastOrderDate),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.titleSmall.copyWith(
            fontWeight: FontWeight.bold,
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

  Widget _buildGrowthTab() {
    return ListView(
      padding: const EdgeInsets.all(AppSizes.lg),
      children: [
        // نمو العملاء الجدد
        _buildGrowthCard(
          'نمو العملاء الجدد',
          [
            {'month': 'يناير', 'value': 45},
            {'month': 'فبراير', 'value': 52},
            {'month': 'مارس', 'value': 48},
            {'month': 'أبريل', 'value': 65},
            {'month': 'مايو', 'value': 72},
            {'month': 'يونيو', 'value': 85},
          ],
          AppColors.primary,
        ),
        const SizedBox(height: AppSizes.lg),

        // معدل الاحتفاظ
        _buildRetentionCard(),
        const SizedBox(height: AppSizes.lg),

        // تحليل Cohort
        _buildCohortAnalysis(),
      ],
    );
  }

  Widget _buildGrowthCard(
    String title,
    List<Map<String, dynamic>> data,
    Color color,
  ) {
    final maxValue = data
        .map((d) => d['value'] as int)
        .reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            SizedBox(
              height: 200,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: data.map((d) {
                  final height = (d['value'] as int) / maxValue * 150;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${d['value']}',
                            style: AppTypography.labelSmall.copyWith(
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: height,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.7),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            d['month'] as String,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textMuted,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRetentionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'معدل الاحتفاظ بالعملاء',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            Row(
              children: [
                Expanded(
                  child: _buildRetentionStat(
                    'شهري',
                    _totalCustomers > 0 ? '${(_activeCustomers / _totalCustomers * 100).toStringAsFixed(0)}%' : '0%',
                    AppColors.success,
                  ),
                ),
                Expanded(
                  child: _buildRetentionStat(
                    'إجمالي العملاء',
                    '$_totalCustomers',
                    AppColors.info,
                  ),
                ),
                Expanded(
                  child: _buildRetentionStat(
                    'نشطين',
                    '$_activeCustomers',
                    AppColors.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.lg),
            const Divider(),
            const SizedBox(height: AppSizes.md),
            Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: AppColors.textMuted),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Text(
                    'العملاء النشطين: من اشترى خلال آخر 30 يوم',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRetentionStat(String period, String rate, Color color) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                value: double.parse(rate.replaceAll('%', '')) / 100,
                strokeWidth: 8,
                backgroundColor: color.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
            Text(
              rate,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.sm),
        Text(
          period,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildCohortAnalysis() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تحليل Cohort (مجموعات العملاء)',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.md),
            Text(
              'نسبة العودة للشراء بعد الشراء الأول',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            // Cohort table simplified
            Table(
              border: TableBorder.all(color: AppColors.grey300),
              children: [
                TableRow(
                  decoration: const BoxDecoration(color: AppColors.grey100),
                  children: [
                    _buildTableCell('المجموعة', isHeader: true),
                    _buildTableCell('شهر 1', isHeader: true),
                    _buildTableCell('شهر 2', isHeader: true),
                    _buildTableCell('شهر 3', isHeader: true),
                  ],
                ),
                TableRow(
                  children: [
                    _buildTableCell('يناير'),
                    _buildTableCell('100%', color: AppColors.success),
                    _buildTableCell('45%', color: AppColors.info),
                    _buildTableCell('32%', color: AppColors.warning),
                  ],
                ),
                TableRow(
                  children: [
                    _buildTableCell('فبراير'),
                    _buildTableCell('100%', color: AppColors.success),
                    _buildTableCell('48%', color: AppColors.info),
                    _buildTableCell('35%', color: AppColors.warning),
                  ],
                ),
                TableRow(
                  children: [
                    _buildTableCell('مارس'),
                    _buildTableCell('100%', color: AppColors.success),
                    _buildTableCell('52%', color: AppColors.info),
                    _buildTableCell('-'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.sm),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: isHeader
            ? AppTypography.labelMedium.copyWith(fontWeight: FontWeight.bold)
            : AppTypography.bodySmall.copyWith(color: color),
      ),
    );
  }

  Widget _buildLoyaltyTab() {
    return ListView(
      padding: const EdgeInsets.all(AppSizes.lg),
      children: [
        // إحصائيات برنامج الولاء
        _buildLoyaltyStats(),
        const SizedBox(height: AppSizes.lg),

        // توزيع النقاط
        _buildPointsDistribution(),
        const SizedBox(height: AppSizes.lg),

        // استبدال النقاط
        _buildRedemptionStats(),
      ],
    );
  }

  Widget _buildLoyaltyStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.stars, color: AppColors.warning),
                const SizedBox(width: AppSizes.sm),
                Text(
                  'إحصائيات برنامج الولاء',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.lg),
            Row(
              children: [
                Expanded(
                  child: _buildLoyaltyStat(
                    'إجمالي النقاط الممنوحة',
                    '125,400',
                    Icons.card_giftcard,
                    AppColors.success,
                  ),
                ),
                Expanded(
                  child: _buildLoyaltyStat(
                    'النقاط المستبدلة',
                    '45,800',
                    Icons.redeem,
                    AppColors.info,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),
            Row(
              children: [
                Expanded(
                  child: _buildLoyaltyStat(
                    'النقاط المتبقية',
                    '79,600',
                    Icons.account_balance_wallet,
                    AppColors.warning,
                  ),
                ),
                Expanded(
                  child: _buildLoyaltyStat(
                    'قيمة النقاط',
                    '7,960 ر.س',
                    Icons.monetization_on,
                    AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoyaltyStat(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: AppSizes.sm),
          Text(
            value,
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
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
      ),
    );
  }

  Widget _buildPointsDistribution() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'توزيع النقاط حسب المستوى',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            _buildPointsRow('ماسي', 35000, 28, Colors.purple),
            _buildPointsRow('ذهبي', 45000, 35, AppColors.warning),
            _buildPointsRow('فضي', 28000, 22, AppColors.grey500),
            _buildPointsRow('برونزي', 17600, 15, Colors.brown),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsRow(String tier, int points, int percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          SizedBox(
            width: 60,
            child: Text(tier, style: AppTypography.bodySmall),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: color.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(width: AppSizes.md),
          SizedBox(
            width: 80,
            child: Text(
              '$points نقطة',
              style: AppTypography.bodySmall,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRedemptionStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'أنماط استبدال النقاط',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            _buildRedemptionRow(
              'خصم على المشتريات',
              '65%',
              Icons.local_offer,
            ),
            _buildRedemptionRow(
              'منتجات مجانية',
              '25%',
              Icons.card_giftcard,
            ),
            _buildRedemptionRow(
              'كوبونات',
              '10%',
              Icons.confirmation_number,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRedemptionRow(String label, String percentage, IconData icon) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(AppSizes.sm),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(label),
      trailing: Text(
        percentage,
        style: AppTypography.titleMedium.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getTierColor(String tier) {
    switch (tier) {
      case 'ماسي':
        return Colors.purple;
      case 'ذهبي':
        return AppColors.warning;
      case 'فضي':
        return AppColors.grey500;
      case 'برونزي':
        return Colors.brown;
      default:
        return AppColors.grey400;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatRelativeDate(DateTime date) {
    final difference = DateTime.now().difference(date);
    if (difference.inDays == 0) {
      return 'اليوم';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    } else {
      return _formatDate(date);
    }
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
      _loadCustomerData();
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

/// نموذج بيانات العميل
class CustomerData {
  final String id;
  final String name;
  final String phone;
  final int totalOrders;
  final double totalSpent;
  final double avgOrderValue;
  final DateTime lastOrderDate;
  final String tier;
  final int loyaltyPoints;

  CustomerData({
    required this.id,
    required this.name,
    required this.phone,
    required this.totalOrders,
    required this.totalSpent,
    required this.avgOrderValue,
    required this.lastOrderDate,
    required this.tier,
    required this.loyaltyPoints,
  });
}
