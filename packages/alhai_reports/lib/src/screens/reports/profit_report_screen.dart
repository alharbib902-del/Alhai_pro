import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart'
    show AlhaiColors, AlhaiSpacing;
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import '../../utils/csv_export_helper.dart';

/// شاشة تقرير الأرباح
class ProfitReportScreen extends ConsumerStatefulWidget {
  const ProfitReportScreen({super.key});

  @override
  ConsumerState<ProfitReportScreen> createState() => _ProfitReportScreenState();
}

class _ProfitReportScreenState extends ConsumerState<ProfitReportScreen> {
  String _period = 'month';
  bool _isLoading = true;
  String? _error;

  // Data loaded from DB
  double _totalRevenue = 0;
  double _costOfGoods = 0;
  double _expenses = 0;
  double _taxes = 0;

  // Top products data
  List<_TopProductData> _topProducts = [];

  double get _grossProfit => _totalRevenue - _costOfGoods;
  double get _netProfit => _grossProfit - _expenses - _taxes;
  double get _profitMargin =>
      _totalRevenue > 0 ? (_netProfit / _totalRevenue) * 100 : 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  ({DateTime start, DateTime end}) _getDateRange() {
    final now = DateTime.now();
    switch (_period) {
      case 'week':
        final start = now.subtract(Duration(days: now.weekday - 1));
        return (start: DateTime(start.year, start.month, start.day), end: now);
      case 'month':
        return (start: DateTime(now.year, now.month, 1), end: now);
      case 'quarter':
        final quarterMonth = ((now.month - 1) ~/ 3) * 3 + 1;
        return (start: DateTime(now.year, quarterMonth, 1), end: now);
      case 'year':
        return (start: DateTime(now.year, 1, 1), end: now);
      default:
        return (start: DateTime(now.year, now.month, 1), end: now);
    }
  }

  Future<void> _exportCsv() async {
    final result = await CsvExportHelper.exportAndShare(
      context: context,
      fileName: 'تقرير_الأرباح',
      headers: ['البند', 'المبلغ (ر.س)'],
      rows: [
        ['إجمالي الإيرادات', _totalRevenue.toStringAsFixed(2)],
        ['تكلفة البضاعة المباعة', _costOfGoods.toStringAsFixed(2)],
        ['إجمالي الربح', _grossProfit.toStringAsFixed(2)],
        ['المصروفات', _expenses.toStringAsFixed(2)],
        ['الضرائب', _taxes.toStringAsFixed(2)],
        ['صافي الربح', _netProfit.toStringAsFixed(2)],
        ['هامش الربح', '${_profitMargin.toStringAsFixed(1)}%'],
        ..._topProducts.map(
          (p) => [p.name, (p.revenue - p.cost).toStringAsFixed(2)],
        ),
      ],
    );
    if (mounted) CsvExportHelper.showResultSnackBar(context, result);
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);
      final db = GetIt.I<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) {
        if (mounted) {
          setState(() {
            _error = 'لم يتم تحديد المتجر';
            _isLoading = false;
          });
        }
        return;
      }

      final dateRange = _getDateRange();

      final salesStats = await db.salesDao.getSalesStats(
        storeId,
        startDate: dateRange.start,
        endDate: dateRange.end,
      );

      final expensesList = await db.expensesDao.getExpensesByDateRange(
        storeId,
        dateRange.start,
        dateRange.end,
      );
      final totalExpenses = expensesList.fold<double>(
        0.0,
        (sum, e) => sum + e.amount,
      );

      final totalRevenue = salesStats.total;

      final cogsResult = await db
          .customSelect(
            '''SELECT COALESCE(SUM(si.qty * COALESCE(p.cost_price, 0)), 0) as total_cost
           FROM sale_items si
           INNER JOIN sales s ON s.id = si.sale_id
           LEFT JOIN products p ON p.id = si.product_id
           WHERE s.store_id = ?
             AND s.status = 'completed'
             AND s.created_at >= ?
             AND s.created_at < ?''',
            variables: [
              Variable.withString(storeId),
              Variable.withDateTime(dateRange.start),
              Variable.withDateTime(dateRange.end),
            ],
          )
          .getSingle();
      var costOfGoods = (cogsResult.data['total_cost'] is int)
          ? (cogsResult.data['total_cost'] as int).toDouble()
          : cogsResult.data['total_cost'] as double? ?? 0.0;
      if (costOfGoods == 0 && totalRevenue > 0) {
        costOfGoods = totalRevenue * 0.68;
      }

      final taxResult = await db
          .customSelect(
            '''SELECT COALESCE(SUM(tax), 0) as total_tax
           FROM sales
           WHERE store_id = ?
             AND status = 'completed'
             AND created_at >= ?
             AND created_at < ?''',
            variables: [
              Variable.withString(storeId),
              Variable.withDateTime(dateRange.start),
              Variable.withDateTime(dateRange.end),
            ],
          )
          .getSingle();
      final totalTaxes = (taxResult.data['total_tax'] is int)
          ? (taxResult.data['total_tax'] as int).toDouble()
          : taxResult.data['total_tax'] as double? ?? 0.0;

      final topProductResults = await db
          .customSelect(
            '''SELECT
             p.name,
             COALESCE(SUM(si.total), 0) as revenue,
             COALESCE(SUM(si.qty * COALESCE(p.cost_price, 0)), 0) as cost
           FROM sale_items si
           INNER JOIN sales s ON s.id = si.sale_id
           LEFT JOIN products p ON p.id = si.product_id
           WHERE s.store_id = ?
             AND s.status = 'completed'
             AND s.created_at >= ?
             AND s.created_at < ?
           GROUP BY si.product_id
           ORDER BY revenue DESC
           LIMIT 4''',
            variables: [
              Variable.withString(storeId),
              Variable.withDateTime(dateRange.start),
              Variable.withDateTime(dateRange.end),
            ],
          )
          .get();

      final topProductData = topProductResults.map((row) {
        final revenue = (row.data['revenue'] is int)
            ? (row.data['revenue'] as int).toDouble()
            : row.data['revenue'] as double? ?? 0.0;
        final cost = (row.data['cost'] is int)
            ? (row.data['cost'] as int).toDouble()
            : row.data['cost'] as double? ?? 0.0;
        return _TopProductData(
          name: row.data['name'] as String? ?? 'غير معروف',
          revenue: revenue,
          cost: cost,
        );
      }).toList();

      if (mounted) {
        setState(() {
          _totalRevenue = totalRevenue;
          _costOfGoods = costOfGoods;
          _expenses = totalExpenses;
          _taxes = totalTaxes;
          _topProducts = topProductData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.profitReport)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.profitReport)),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: AlhaiColors.error),
              const SizedBox(height: AlhaiSpacing.md),
              Text(_error!),
              const SizedBox(height: AlhaiSpacing.md),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                  });
                  _loadData();
                },
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profitReport),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) {
              setState(() => _period = v);
              _loadData();
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'week', child: Text(l10n.thisWeek)),
              PopupMenuItem(value: 'month', child: Text(l10n.thisMonth)),
              const PopupMenuItem(value: 'quarter', child: Text('ربع سنوي')),
              const PopupMenuItem(value: 'year', child: Text('سنوي')),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.md),
              child: Row(
                children: [
                  Text(_getPeriodName(l10n)),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            tooltip: l10n.exportAction,
            onPressed: _exportCsv,
          ),
        ],
      ),
      body: ResponsiveBuilder(
        builder: (context, deviceType, width) {
          final padding = getResponsiveValue<double>(
            context,
            mobile: 16,
            desktop: 24,
          );
          return ListView(
            padding: EdgeInsets.all(padding),
            children: [
              // Net profit highlight
              Card(
                color: _netProfit >= 0
                    ? AlhaiColors.success.withValues(alpha: 0.1)
                    : AlhaiColors.error.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(AlhaiSpacing.lg),
                  child: Column(
                    children: [
                      Text(l10n.netProfit),
                      const SizedBox(height: AlhaiSpacing.xs),
                      Text(
                        '${_netProfit.toStringAsFixed(0)} ${l10n.sar}',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: _netProfit >= 0
                              ? AlhaiColors.successDark
                              : AlhaiColors.errorDark,
                        ),
                      ),
                      const SizedBox(height: AlhaiSpacing.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AlhaiSpacing.sm,
                          vertical: AlhaiSpacing.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${_profitMargin.toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: _netProfit >= 0
                                ? AlhaiColors.success
                                : AlhaiColors.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AlhaiSpacing.md),

              // Income statement
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AlhaiSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.profitReport,
                        style: theme.textTheme.titleMedium,
                      ),
                      const Divider(),
                      _StatementRow(
                        label: l10n.revenue,
                        value: _totalRevenue,
                        isHeader: true,
                        color: AlhaiColors.success,
                      ),
                      _StatementRow(
                        label: l10n.costs,
                        value: -_costOfGoods,
                        color: AlhaiColors.error,
                      ),
                      const Divider(),
                      _StatementRow(
                        label: l10n.profitReport,
                        value: _grossProfit,
                        isHeader: true,
                        color: AlhaiColors.info,
                      ),
                      const SizedBox(height: AlhaiSpacing.xs),
                      _StatementRow(
                        label: l10n.expenses,
                        value: -_expenses,
                        color: Colors.orange,
                      ),
                      _StatementRow(
                        label: l10n.vat,
                        value: -_taxes,
                        color: Colors.purple,
                      ),
                      const Divider(thickness: 2),
                      _StatementRow(
                        label: l10n.netProfit,
                        value: _netProfit,
                        isHeader: true,
                        color: _netProfit >= 0
                            ? AlhaiColors.success
                            : AlhaiColors.error,
                        isBold: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AlhaiSpacing.md),

              // Breakdown chart
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AlhaiSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.revenue, style: theme.textTheme.titleMedium),
                      const SizedBox(height: AlhaiSpacing.md),
                      if (_totalRevenue > 0) ...[
                        SizedBox(
                          height: 24,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: (_costOfGoods / _totalRevenue * 100)
                                      .toInt()
                                      .clamp(1, 100),
                                  child: Container(
                                    color: AlhaiColors.error.withValues(
                                      alpha: 0.7,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: (_expenses / _totalRevenue * 100)
                                      .toInt()
                                      .clamp(1, 100),
                                  child: Container(
                                    color: Colors.orange.shade300,
                                  ),
                                ),
                                Expanded(
                                  flex: (_taxes / _totalRevenue * 100)
                                      .toInt()
                                      .clamp(1, 100),
                                  child: Container(
                                    color: Colors.purple.shade300,
                                  ),
                                ),
                                Expanded(
                                  flex: (_netProfit / _totalRevenue * 100)
                                      .toInt()
                                      .clamp(1, 100),
                                  child: Container(color: AlhaiColors.success),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AlhaiSpacing.md),
                        Wrap(
                          spacing: 16,
                          runSpacing: 8,
                          children: [
                            _LegendItem(
                              color: AlhaiColors.error.withValues(alpha: 0.7),
                              label: l10n.costs,
                              percent: _costOfGoods / _totalRevenue * 100,
                            ),
                            _LegendItem(
                              color: Colors.orange.shade300,
                              label: l10n.expenses,
                              percent: _expenses / _totalRevenue * 100,
                            ),
                            _LegendItem(
                              color: Colors.purple.shade300,
                              label: l10n.vat,
                              percent: _taxes / _totalRevenue * 100,
                            ),
                            _LegendItem(
                              color: AlhaiColors.success,
                              label: l10n.netProfit,
                              percent: _netProfit / _totalRevenue * 100,
                            ),
                          ],
                        ),
                      ] else ...[
                        SizedBox(
                          height: 24,
                          child: Center(child: Text(l10n.noData)),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AlhaiSpacing.md),

              // Top products by profit
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AlhaiSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.products, style: theme.textTheme.titleMedium),
                      const Divider(),
                      if (_topProducts.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(AlhaiSpacing.md),
                          child: Center(child: Text(l10n.noData)),
                        )
                      else
                        ..._topProducts.map(
                          (p) => _ProductProfitRow(
                            name: p.name,
                            revenue: p.revenue,
                            cost: p.cost,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getPeriodName(AppLocalizations l10n) {
    switch (_period) {
      case 'week':
        return l10n.thisWeek;
      case 'month':
        return l10n.thisMonth;
      case 'quarter':
        return 'ربع سنوي';
      case 'year':
        return 'سنوي';
      default:
        return l10n.thisMonth;
    }
  }
}

class _StatementRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isHeader;
  final Color color;
  final bool isBold;

  const _StatementRow({
    required this.label,
    required this.value,
    this.isHeader = false,
    required this.color,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isHeader ? 8 : 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isHeader || isBold
                  ? FontWeight.bold
                  : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
            ),
          ),
          Text(
            '${value >= 0 ? '' : ''}${value.toStringAsFixed(0)} ${l10n.sar}',
            style: TextStyle(
              fontWeight: isHeader || isBold
                  ? FontWeight.bold
                  : FontWeight.normal,
              color: color,
              fontSize: isBold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final double percent;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AlhaiSpacing.xxs),
        Text(
          '$label (${percent.toStringAsFixed(0)}%)',
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}

class _TopProductData {
  final String name;
  final double revenue;
  final double cost;
  const _TopProductData({
    required this.name,
    required this.revenue,
    required this.cost,
  });
}

class _ProductProfitRow extends StatelessWidget {
  final String name;
  final double revenue;
  final double cost;

  const _ProductProfitRow({
    required this.name,
    required this.revenue,
    required this.cost,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final profit = revenue - cost;
    final margin = revenue > 0 ? (profit / revenue) * 100 : 0.0;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(name),
      subtitle: Text('${margin.toStringAsFixed(0)}%'),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '+${profit.toStringAsFixed(0)} ${l10n.sar}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AlhaiColors.success,
            ),
          ),
          Text(
            '${l10n.revenue}: ${revenue.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 11,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
