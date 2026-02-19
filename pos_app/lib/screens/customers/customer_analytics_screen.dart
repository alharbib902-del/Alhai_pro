import 'package:drift/drift.dart' show Variable;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/app_database.dart';
import '../../di/injection.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/products_providers.dart';

/// بيانات تحليل العملاء المجمعة
class _CustomerAnalyticsData {
  final int totalCustomers;
  final int newCustomers;
  final double totalDebt;
  final double avgSpending;
  final List<_TopCustomerData> topCustomers;
  final int activeCustomers;
  final int dormantCustomers;
  final int inactiveCustomers;
  final int vipCount;
  final int regularCount;
  final int normalCount;

  const _CustomerAnalyticsData({
    this.totalCustomers = 0,
    this.newCustomers = 0,
    this.totalDebt = 0,
    this.avgSpending = 0,
    this.topCustomers = const [],
    this.activeCustomers = 0,
    this.dormantCustomers = 0,
    this.inactiveCustomers = 0,
    this.vipCount = 0,
    this.regularCount = 0,
    this.normalCount = 0,
  });
}

class _TopCustomerData {
  final String name;
  final int orderCount;
  final double totalSpent;

  const _TopCustomerData({
    required this.name,
    required this.orderCount,
    required this.totalSpent,
  });
}

/// شاشة تحليل العملاء - تعرض إحصائيات حقيقية من قاعدة البيانات
class CustomerAnalyticsScreen extends ConsumerStatefulWidget {
  const CustomerAnalyticsScreen({super.key});

  @override
  ConsumerState<CustomerAnalyticsScreen> createState() => _CustomerAnalyticsScreenState();
}

class _CustomerAnalyticsScreenState extends ConsumerState<CustomerAnalyticsScreen> {
  String _period = 'month';
  _CustomerAnalyticsData _data = const _CustomerAnalyticsData();
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// حساب بداية الفترة الزمنية المحددة
  DateTime _getPeriodStart() {
    final now = DateTime.now();
    switch (_period) {
      case 'week':
        return now.subtract(const Duration(days: 7));
      case 'month':
        return DateTime(now.year, now.month - 1, now.day);
      case 'year':
        return DateTime(now.year - 1, now.month, now.day);
      default:
        return now.subtract(const Duration(days: 30));
    }
  }

  /// تحميل البيانات التحليلية من قاعدة البيانات
  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;

      final db = getIt<AppDatabase>();
      final periodStart = _getPeriodStart();

      // جلب بيانات العملاء
      final allCustomers = await db.customersDao.getAllCustomers(storeId);
      final totalCustomers = allCustomers.length;

      // العملاء الجدد خلال الفترة المحددة
      final newCustomers = allCustomers.where(
        (c) => c.createdAt.isAfter(periodStart),
      ).length;

      // إجمالي الديون
      double totalDebt = 0;
      try {
        totalDebt = await db.accountsDao.getTotalReceivable(storeId);
      } catch (_) {
        // قد لا تكون هناك حسابات بعد
      }

      // جلب إحصائيات الطلبات حسب العميل - أفضل العملاء
      final topCustomersData = <_TopCustomerData>[];
      double totalAllSpending = 0;

      try {
        // استعلام مخصص: أفضل العملاء حسب إجمالي الطلبات
        final topResult = await db.customSelect(
          '''SELECT c.name, COUNT(o.id) as order_count, COALESCE(SUM(o.total), 0) as total_spent
             FROM customers c
             LEFT JOIN orders o ON o.customer_id = c.id AND o.status = 'delivered' AND o.order_date >= ?
             WHERE c.store_id = ? AND c.is_active = 1
             GROUP BY c.id, c.name
             HAVING order_count > 0
             ORDER BY total_spent DESC
             LIMIT 5''',
          variables: [Variable.withDateTime(periodStart), Variable.withString(storeId)],
        ).get();

        for (final row in topResult) {
          final spent = row.read<double>('total_spent');
          topCustomersData.add(_TopCustomerData(
            name: row.read<String>('name'),
            orderCount: row.read<int>('order_count'),
            totalSpent: spent,
          ));
          totalAllSpending += spent;
        }
      } catch (_) {
        // في حالة عدم وجود طلبات
      }

      // حساب متوسط الإنفاق
      final avgSpending = totalCustomers > 0 && totalAllSpending > 0
          ? totalAllSpending / totalCustomers
          : 0.0;

      // تصنيف العملاء حسب إجمالي الإنفاق (VIP, منتظم, عادي)
      int vipCount = 0;
      int regularCount = 0;
      int normalCount = 0;

      try {
        final distResult = await db.customSelect(
          '''SELECT
               COUNT(CASE WHEN total_spent > 5000 THEN 1 END) as vip,
               COUNT(CASE WHEN total_spent BETWEEN 1000 AND 5000 THEN 1 END) as regular,
               COUNT(CASE WHEN total_spent < 1000 THEN 1 END) as normal_c
             FROM (
               SELECT c.id, COALESCE(SUM(o.total), 0) as total_spent
               FROM customers c
               LEFT JOIN orders o ON o.customer_id = c.id AND o.status = 'delivered'
               WHERE c.store_id = ? AND c.is_active = 1
               GROUP BY c.id
             )''',
          variables: [Variable.withString(storeId)],
        ).getSingle();

        vipCount = distResult.read<int>('vip');
        regularCount = distResult.read<int>('regular');
        normalCount = distResult.read<int>('normal_c');
      } catch (_) {
        // في حالة فشل الاستعلام نقسم العملاء بالتساوي
        normalCount = totalCustomers;
      }

      // نشاط العملاء: نشط (طلب خلال 30 يوم)، خامل (30-90 يوم)، غير نشط (أكثر من 90 يوم)
      int activeCount = 0;
      int dormantCount = 0;
      int inactiveCount = 0;

      try {
        final now = DateTime.now();
        final thirtyDaysAgo = now.subtract(const Duration(days: 30));
        final ninetyDaysAgo = now.subtract(const Duration(days: 90));

        final activityResult = await db.customSelect(
          '''SELECT
               COUNT(CASE WHEN last_order >= ? THEN 1 END) as active_c,
               COUNT(CASE WHEN last_order < ? AND last_order >= ? THEN 1 END) as dormant_c,
               COUNT(CASE WHEN last_order < ? OR last_order IS NULL THEN 1 END) as inactive_c
             FROM (
               SELECT c.id, MAX(o.order_date) as last_order
               FROM customers c
               LEFT JOIN orders o ON o.customer_id = c.id AND o.status = 'delivered'
               WHERE c.store_id = ? AND c.is_active = 1
               GROUP BY c.id
             )''',
          variables: [
            Variable.withDateTime(thirtyDaysAgo),
            Variable.withDateTime(thirtyDaysAgo),
            Variable.withDateTime(ninetyDaysAgo),
            Variable.withDateTime(ninetyDaysAgo),
            Variable.withString(storeId),
          ],
        ).getSingle();

        activeCount = activityResult.read<int>('active_c');
        dormantCount = activityResult.read<int>('dormant_c');
        inactiveCount = activityResult.read<int>('inactive_c');
      } catch (_) {
        // في حالة فشل الاستعلام
        activeCount = totalCustomers;
      }

      if (mounted) {
        setState(() {
          _data = _CustomerAnalyticsData(
            totalCustomers: totalCustomers,
            newCustomers: newCustomers,
            totalDebt: totalDebt,
            avgSpending: avgSpending,
            topCustomers: topCustomersData,
            activeCustomers: activeCount,
            dormantCustomers: dormantCount,
            inactiveCustomers: inactiveCount,
            vipCount: vipCount,
            regularCount: regularCount,
            normalCount: normalCount,
          );
          _isLoading = false;
        });
      }
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
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.customerAnalytics)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // حالة الخطأ
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.customerAnalytics)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: colorScheme.error),
              const SizedBox(height: 16),
              Text(l10n.errorOccurred,
                  style: TextStyle(fontSize: 18, color: colorScheme.onSurface)),
              const SizedBox(height: 8),
              Text(_error!,
                  style: TextStyle(color: colorScheme.onSurfaceVariant)),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    // حساب النسب المئوية لتوزيع العملاء
    final totalForDist = _data.vipCount + _data.regularCount + _data.normalCount;
    final vipPct = totalForDist > 0 ? (_data.vipCount * 100 / totalForDist).round() : 0;
    final regularPct = totalForDist > 0 ? (_data.regularCount * 100 / totalForDist).round() : 0;
    final normalPct = totalForDist > 0 ? (_data.normalCount * 100 / totalForDist).round() : 0;

    // حساب النسب المئوية لنشاط العملاء
    final totalForActivity = _data.activeCustomers + _data.dormantCustomers + _data.inactiveCustomers;
    final activePct = totalForActivity > 0 ? (_data.activeCustomers * 100 / totalForActivity).round() : 0;
    final dormantPct = totalForActivity > 0 ? (_data.dormantCustomers * 100 / totalForActivity).round() : 0;
    final inactivePct = totalForActivity > 0 ? (_data.inactiveCustomers * 100 / totalForActivity).round() : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.customerAnalytics),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
          IconButton(icon: const Icon(Icons.file_download), onPressed: () {}),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 800;
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // اختيار الفترة الزمنية
                  SegmentedButton<String>(
                    segments: [
                      ButtonSegment(value: 'week', label: Text(l10n.weekPeriod)),
                      ButtonSegment(value: 'month', label: Text(l10n.monthPeriod)),
                      ButtonSegment(value: 'year', label: Text(l10n.yearPeriod)),
                    ],
                    selected: {_period},
                    onSelectionChanged: (v) {
                      setState(() => _period = v.first);
                      _loadData();
                    },
                  ),

                  const SizedBox(height: 24),

                  // الإحصائيات الرئيسية - responsive
                  if (isWide)
                    Row(
                      children: [
                        _StatCard(
                          icon: Icons.people,
                          label: l10n.totalCustomers,
                          value: '${_data.totalCustomers}',
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        _StatCard(
                          icon: Icons.person_add,
                          label: l10n.newCustomers,
                          value: '${_data.newCustomers}',
                          color: colorScheme.tertiary,
                        ),
                        const SizedBox(width: 12),
                        _StatCard(
                          icon: Icons.account_balance_wallet,
                          label: l10n.totalDebts,
                          value: l10n.priceWithCurrency(_data.totalDebt.toStringAsFixed(0)),
                          color: colorScheme.error,
                        ),
                        const SizedBox(width: 12),
                        _StatCard(
                          icon: Icons.attach_money,
                          label: l10n.averageSpending,
                          value: l10n.priceWithCurrency(_data.avgSpending.toStringAsFixed(0)),
                          color: colorScheme.secondary,
                        ),
                      ],
                    )
                  else ...[
                    Row(
                      children: [
                        _StatCard(
                          icon: Icons.people,
                          label: l10n.totalCustomers,
                          value: '${_data.totalCustomers}',
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        _StatCard(
                          icon: Icons.person_add,
                          label: l10n.newCustomers,
                          value: '${_data.newCustomers}',
                          color: colorScheme.tertiary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _StatCard(
                          icon: Icons.account_balance_wallet,
                          label: l10n.totalDebts,
                          value: l10n.priceWithCurrency(_data.totalDebt.toStringAsFixed(0)),
                          color: colorScheme.error,
                        ),
                        const SizedBox(width: 12),
                        _StatCard(
                          icon: Icons.attach_money,
                          label: l10n.averageSpending,
                          value: l10n.priceWithCurrency(_data.avgSpending.toStringAsFixed(0)),
                          color: colorScheme.secondary,
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Wide: top customers + distribution side by side
                  if (isWide) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // أفضل العملاء
                        Expanded(
                          flex: 3,
                          child: _buildTopCustomersSection(l10n, colorScheme),
                        ),
                        const SizedBox(width: 16),
                        // توزيع العملاء
                        Expanded(
                          flex: 2,
                          child: _buildDistributionSection(l10n, colorScheme, vipPct, regularPct, normalPct),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildActivitySection(l10n, colorScheme, activePct, dormantPct, inactivePct),
                  ] else ...[
                    // أفضل العملاء
                    _buildTopCustomersSection(l10n, colorScheme),
                    const SizedBox(height: 24),
                    // توزيع العملاء
                    _buildDistributionSection(l10n, colorScheme, vipPct, regularPct, normalPct),
                    const SizedBox(height: 24),
                    // نشاط العملاء
                    _buildActivitySection(l10n, colorScheme, activePct, dormantPct, inactivePct),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopCustomersSection(AppLocalizations l10n, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.topCustomers, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        _data.topCustomers.isEmpty
            ? Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Text(l10n.noData,
                        style: TextStyle(color: colorScheme.onSurfaceVariant)),
                  ),
                ),
              )
            : Card(
                child: Column(
                  children: _data.topCustomers.asMap().entries.map((entry) {
                    final index = entry.key;
                    final customer = entry.value;
                    return Column(
                      children: [
                        if (index > 0) const Divider(height: 1),
                        _CustomerTile(
                          rank: index + 1,
                          name: customer.name,
                          orders: customer.orderCount,
                          spent: customer.totalSpent,
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
      ],
    );
  }

  Widget _buildDistributionSection(
      AppLocalizations l10n, ColorScheme colorScheme, int vipPct, int regularPct, int normalPct) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.customerDistribution, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _DistributionRow(
                    label: '${l10n.vipCustomers} (> 5000)',
                    percentage: vipPct,
                    color: colorScheme.tertiary),
                const SizedBox(height: 12),
                _DistributionRow(
                    label: '${l10n.regularCustomers} (1000-5000)',
                    percentage: regularPct,
                    color: colorScheme.primary),
                const SizedBox(height: 12),
                _DistributionRow(
                    label: '${l10n.normalCustomers} (< 1000)',
                    percentage: normalPct,
                    color: colorScheme.outline),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivitySection(
      AppLocalizations l10n, ColorScheme colorScheme, int activePct, int dormantPct, int inactivePct) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.customerActivity, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ActivityStat(
                  label: l10n.activeLabel,
                  value: '${_data.activeCustomers}',
                  percentage: activePct,
                  color: colorScheme.primary,
                ),
                _ActivityStat(
                  label: l10n.dormantLabel,
                  value: '${_data.dormantCustomers}',
                  percentage: dormantPct,
                  color: colorScheme.tertiary,
                ),
                _ActivityStat(
                  label: l10n.inactiveLabel,
                  value: '${_data.inactiveCustomers}',
                  percentage: inactivePct,
                  color: colorScheme.error,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 8),
              Text(value,
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, color: color)),
              Text(label,
                  style: TextStyle(
                      fontSize: 11, color: colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomerTile extends StatelessWidget {
  final int rank;
  final String name;
  final int orders;
  final double spent;
  const _CustomerTile({required this.rank, required this.name, required this.orders, required this.spent});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: rank <= 3
            ? colorScheme.tertiaryContainer
            : colorScheme.surfaceContainerHighest,
        child: Text('$rank',
            style: TextStyle(
                color: rank <= 3
                    ? colorScheme.onTertiaryContainer
                    : colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold)),
      ),
      title: Text(name),
      subtitle: Text('$orders ${l10n.orders}'),
      trailing: Text(l10n.priceWithCurrency(spent.toStringAsFixed(0)),
          style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.primary)),
    );
  }
}

class _DistributionRow extends StatelessWidget {
  final String label;
  final int percentage;
  final Color color;
  const _DistributionRow({required this.label, required this.percentage, required this.color});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: TextStyle(fontSize: 12, color: colorScheme.onSurface)),
            Text('$percentage%',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(color)),
      ],
    );
  }
}

class _ActivityStat extends StatelessWidget {
  final String label, value;
  final int percentage;
  final Color color;
  const _ActivityStat({required this.label, required this.value, required this.percentage, required this.color});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation(color),
                    strokeWidth: 6)),
            Text('$percentage%',
                style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 8),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
        Text(label,
            style: TextStyle(
                fontSize: 11, color: colorScheme.onSurfaceVariant)),
      ],
    );
  }
}
