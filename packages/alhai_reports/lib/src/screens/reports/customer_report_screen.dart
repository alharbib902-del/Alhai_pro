/// شاشة تقرير العملاء - Customer Report Screen
///
/// تقرير شامل لنشاط وتحليلات العملاء
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_design_system/alhai_design_system.dart' show AlhaiSpacing;
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

/// شاشة تقرير العملاء
class CustomerReportScreen extends ConsumerStatefulWidget {
  const CustomerReportScreen({super.key});

  @override
  ConsumerState<CustomerReportScreen> createState() =>
      _CustomerReportScreenState();
}

class _CustomerReportScreenState extends ConsumerState<CustomerReportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );
  bool _isLoading = true;
  String? _error;

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
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final db = GetIt.I<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider) ?? kDefaultStoreId;
      final accounts = await db.accountsDao.getAllAccounts(storeId);
      final now = _dateRange.end;
      final thirtyDaysAgo = _dateRange.start;

      _totalCustomers = accounts.length;
      _activeCustomers = accounts
          .where(
            (a) =>
                a.lastTransactionAt != null &&
                a.lastTransactionAt!.isAfter(thirtyDaysAgo),
          )
          .length;
      _newCustomers = accounts
          .where((a) => a.createdAt.isAfter(thirtyDaysAgo))
          .length;

      // Try to get sales stats for revenue
      try {
        final salesStats = await db.salesDao.getSalesStats(
          storeId,
          startDate: thirtyDaysAgo,
          endDate: now,
        );
        _totalRevenue = salesStats.total;
        _avgOrderValue = _totalCustomers > 0
            ? _totalRevenue / _totalCustomers
            : 0;
      } catch (_) {
        _totalRevenue = accounts.fold(0.0, (sum, a) => sum + a.balance);
        _avgOrderValue = _totalCustomers > 0
            ? _totalRevenue / _totalCustomers
            : 0;
      }

      // Map accounts to CustomerData, sorted by balance descending
      final sorted = List.of(accounts)
        ..sort((a, b) => b.balance.compareTo(a.balance));
      _topCustomers = sorted.take(20).map((a) {
        String tier;
        if (a.balance >= 10000) {
          tier = 'diamond';
        } else if (a.balance >= 5000) {
          tier = 'gold';
        } else if (a.balance >= 2000) {
          tier = 'silver';
        } else {
          tier = 'bronze';
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

      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
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
        title: Text(AppLocalizations.of(context).customerReport),
        actions: [
          IconButton(
            onPressed: _selectDateRange,
            icon: const Icon(Icons.date_range),
            tooltip: AppLocalizations.of(context).date,
          ),
          IconButton(
            onPressed: _exportReport,
            icon: const Icon(Icons.download),
            tooltip: AppLocalizations.of(context).exportAction,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(text: AppLocalizations.of(context).overviewTab),
            Tab(text: AppLocalizations.of(context).topCustomersTab),
            Tab(text: AppLocalizations.of(context).growthAnalysisTab),
            Tab(text: AppLocalizations.of(context).loyaltyTab),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AlhaiSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 64,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(height: AlhaiSpacing.md),
                    Text(
                      AppLocalizations.of(context).errorLoadingCustomerReport,
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AlhaiSpacing.md),
                    FilledButton.icon(
                      onPressed: _loadCustomerData,
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(AppLocalizations.of(context).retry),
                    ),
                  ],
                ),
              ),
            )
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
            '(${AppLocalizations.of(context).daysCountLabel(_dateRange.duration.inDays)})',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
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
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                l10n.totalCustomersLabel,
                _totalCustomers.toString(),
                Icons.people,
                AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: _buildStatCard(
                l10n.newCustomersLabel,
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
                l10n.activeCustomersLabel,
                _activeCustomers.toString(),
                Icons.trending_up,
                AppColors.info,
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: _buildStatCard(
                l10n.avgOrderValueLabel,
                '${_avgOrderValue.toStringAsFixed(0)} ${l10n.sar}',
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
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    // حساب التوزيع الحقيقي من بيانات العملاء المحملة
    int diamond = 0, gold = 0, silver = 0, bronze = 0;
    for (final c in _topCustomers) {
      switch (c.tier) {
        case 'diamond':
          diamond++;
          break;
        case 'gold':
          gold++;
          break;
        case 'silver':
          silver++;
          break;
        default:
          bronze++;
          break;
      }
    }
    final tiers = [
      {
        'name': l10n.diamondTier,
        'count': diamond,
        'color': const Color(0xFF9C27B0),
      },
      {'name': l10n.goldTier, 'count': gold, 'color': AppColors.warning},
      {'name': l10n.silverTier, 'count': silver, 'color': AppColors.grey500},
      {
        'name': l10n.bronzeTier,
        'count': bronze,
        'color': const Color(0xFF795548),
      },
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.tierDistribution,
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
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusSm,
                              ),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: percentage / 100,
                            child: Container(
                              height: 24,
                              decoration: BoxDecoration(
                                color: tier['color'] as Color,
                                borderRadius: BorderRadius.circular(
                                  AppSizes.radiusSm,
                                ),
                              ),
                              alignment: AlignmentDirectional.centerEnd,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.sm,
                              ),
                              child: Text(
                                '${tier['count']}',
                                style: AppTypography.labelSmall.copyWith(
                                  color: theme.colorScheme.surface,
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
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.activitySummary,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.md),
            const Divider(),
            _buildActivityRow(
              l10n.totalRevenueFromCustomers,
              '${_totalRevenue.toStringAsFixed(0)} ${l10n.sar}',
              Icons.attach_money,
              AppColors.success,
            ),
            _buildActivityRow(
              l10n.avgOrderPerCustomer,
              '${_avgOrderValue.toStringAsFixed(0)} ${l10n.sar}',
              Icons.shopping_bag,
              AppColors.primary,
            ),
            _buildActivityRow(
              l10n.activeCustomersLast30,
              l10n.ofTotalLabel('$_activeCustomers', '$_totalCustomers'),
              Icons.replay,
              AppColors.info,
            ),
            _buildActivityRow(
              l10n.newCustomersLast30,
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
          Expanded(child: Text(label, style: AppTypography.bodyMedium)),
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
    final l10n = AppLocalizations.of(context);
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
                  l10n.topCustomersTitle(_topCustomers.length),
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                DropdownButton<String>(
                  value: 'spent',
                  underline: const SizedBox(),
                  items: [
                    DropdownMenuItem(
                      value: 'spent',
                      child: Text(l10n.bySpending),
                    ),
                    DropdownMenuItem(
                      value: 'orders',
                      child: Text(l10n.byOrders),
                    ),
                    DropdownMenuItem(
                      value: 'points',
                      child: Text(l10n.byPoints),
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
                              : const Color(0xFF795548))
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$rank',
                    style: AppTypography.titleSmall.copyWith(
                      color: rank <= 3
                          ? Theme.of(context).colorScheme.surface
                          : Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.md),

                // الصورة والاسم
                CircleAvatar(
                  backgroundColor: _getTierColor(
                    customer.tier,
                  ).withValues(alpha: 0.1),
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
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusSm,
                              ),
                            ),
                            child: Text(
                              _getTierName(context, customer.tier),
                              style: AppTypography.labelSmall.copyWith(
                                color: Theme.of(context).colorScheme.surface,
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
                      '${customer.totalSpent.toStringAsFixed(0)} ${AppLocalizations.of(context).sar}',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      AppLocalizations.of(
                        context,
                      ).ordersCount(customer.totalOrders),
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
                  AppLocalizations.of(context).avgOrderStat,
                  '${customer.avgOrderValue.toStringAsFixed(0)} ${AppLocalizations.of(context).sar}',
                ),
                _buildCustomerStat(
                  AppLocalizations.of(context).loyaltyPointsStat,
                  '${customer.loyaltyPoints}',
                ),
                _buildCustomerStat(
                  AppLocalizations.of(context).lastOrderStat,
                  _formatRelativeDate(context, customer.lastOrderDate),
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
          style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _buildGrowthTab() {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(AppSizes.lg),
      children: [
        // نمو العملاء الجدد
        _buildGrowthCard(l10n.newCustomerGrowth, [
          {'month': l10n.januaryMonth, 'value': 45},
          {'month': l10n.februaryMonth, 'value': 52},
          {'month': l10n.marchMonth, 'value': 48},
          {'month': l10n.aprilMonth, 'value': 65},
          {'month': l10n.mayMonth, 'value': 72},
          {'month': l10n.juneMonth, 'value': 85},
        ], AppColors.primary),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: AlhaiSpacing.xxs,
                      ),
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
                          const SizedBox(height: AlhaiSpacing.xxs),
                          Container(
                            height: height,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.7),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(height: AlhaiSpacing.xs),
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
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.customerRetentionRate,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            Row(
              children: [
                Expanded(
                  child: _buildRetentionStat(
                    l10n.monthlyPeriod,
                    _totalCustomers > 0
                        ? '${(_activeCustomers / _totalCustomers * 100).toStringAsFixed(0)}%'
                        : '0%',
                    AppColors.success,
                  ),
                ),
                Expanded(
                  child: _buildRetentionStat(
                    l10n.totalCustomersPeriod,
                    '$_totalCustomers',
                    AppColors.info,
                  ),
                ),
                Expanded(
                  child: _buildRetentionStat(
                    l10n.activePeriod,
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
                const Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Text(
                    l10n.activeCustomersInfo,
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
                value: (double.tryParse(rate.replaceAll('%', '')) ?? 0) / 100,
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
          style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _buildCohortAnalysis() {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.cohortAnalysis,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.md),
            Text(
              l10n.cohortDescription,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            // Cohort table simplified
            Table(
              border: TableBorder.all(color: Theme.of(context).dividerColor),
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                  ),
                  children: [
                    _buildTableCell(l10n.cohortGroup, isHeader: true),
                    _buildTableCell(l10n.month1, isHeader: true),
                    _buildTableCell(l10n.month2, isHeader: true),
                    _buildTableCell(l10n.month3, isHeader: true),
                  ],
                ),
                TableRow(
                  children: [
                    _buildTableCell(l10n.januaryMonth),
                    _buildTableCell('100%', color: AppColors.success),
                    _buildTableCell('45%', color: AppColors.info),
                    _buildTableCell('32%', color: AppColors.warning),
                  ],
                ),
                TableRow(
                  children: [
                    _buildTableCell(l10n.februaryMonth),
                    _buildTableCell('100%', color: AppColors.success),
                    _buildTableCell('48%', color: AppColors.info),
                    _buildTableCell('35%', color: AppColors.warning),
                  ],
                ),
                TableRow(
                  children: [
                    _buildTableCell(l10n.marchMonth),
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
    final l10n = AppLocalizations.of(context);
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
                  l10n.loyaltyProgramStats,
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
                    l10n.totalPointsGranted,
                    '125,400',
                    Icons.card_giftcard,
                    AppColors.success,
                  ),
                ),
                Expanded(
                  child: _buildLoyaltyStat(
                    l10n.pointsRedeemed,
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
                    l10n.remainingPoints,
                    '79,600',
                    Icons.account_balance_wallet,
                    AppColors.warning,
                  ),
                ),
                Expanded(
                  child: _buildLoyaltyStat(
                    l10n.pointsValue,
                    '7,960 ${l10n.sar}',
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
      margin: const EdgeInsets.all(AlhaiSpacing.xxs),
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
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.pointsByTier,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            _buildPointsRow(
              l10n.diamondTier,
              35000,
              28,
              const Color(0xFF9C27B0),
            ),
            _buildPointsRow(l10n.goldTier, 45000, 35, AppColors.warning),
            _buildPointsRow(l10n.silverTier, 28000, 22, AppColors.grey500),
            _buildPointsRow(
              l10n.bronzeTier,
              17600,
              15,
              const Color(0xFF795548),
            ),
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
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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
              '$points ${AppLocalizations.of(context).pointsUnit}',
              style: AppTypography.bodySmall,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRedemptionStats() {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.redemptionPatterns,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            _buildRedemptionRow(
              l10n.purchaseDiscount,
              '65%',
              Icons.local_offer,
            ),
            _buildRedemptionRow(l10n.freeProducts, '25%', Icons.card_giftcard),
            _buildRedemptionRow(
              l10n.couponsLabel,
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
        style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Color _getTierColor(String tier) {
    switch (tier) {
      case 'diamond':
        return const Color(0xFF9C27B0);
      case 'gold':
        return AppColors.warning;
      case 'silver':
        return AppColors.grey500;
      case 'bronze':
        return const Color(0xFF795548);
      default:
        return AppColors.grey400;
    }
  }

  String _getTierName(BuildContext context, String tier) {
    final l10n = AppLocalizations.of(context);
    switch (tier) {
      case 'diamond':
        return l10n.diamondTier;
      case 'gold':
        return l10n.goldTier;
      case 'silver':
        return l10n.silverTier;
      case 'bronze':
        return l10n.bronzeTier;
      default:
        return tier;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatRelativeDate(BuildContext context, DateTime date) {
    final l10n = AppLocalizations.of(context);
    final difference = DateTime.now().difference(date);
    if (difference.inDays == 0) {
      return l10n.todayDate;
    } else if (difference.inDays == 1) {
      return l10n.yesterdayDate;
    } else if (difference.inDays < 7) {
      return l10n.daysAgo(difference.inDays);
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
      SnackBar(content: Text(AppLocalizations.of(context).exportingReportMsg)),
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
