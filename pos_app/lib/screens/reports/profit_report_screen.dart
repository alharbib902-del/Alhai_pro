import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/app_database.dart';
import '../../di/injection.dart';
import '../../providers/products_providers.dart';

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
  double get _profitMargin => _totalRevenue > 0 ? (_netProfit / _totalRevenue) * 100 : 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Calculate the date range based on the selected period
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

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);
      final db = getIt<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) {
        if (mounted) setState(() { _error = 'لم يتم تحديد المتجر'; _isLoading = false; });
        return;
      }

      final dateRange = _getDateRange();

      // Get sales stats for the period
      final salesStats = await db.salesDao.getSalesStats(
        storeId,
        startDate: dateRange.start,
        endDate: dateRange.end,
      );

      // Get expenses for the period
      final expensesList = await db.expensesDao.getExpensesByDateRange(
        storeId,
        dateRange.start,
        dateRange.end,
      );
      final totalExpenses = expensesList.fold<double>(0.0, (sum, e) => sum + e.amount);

      // Revenue from sales stats
      final totalRevenue = salesStats.total;

      // تكلفة البضاعة المباعة: حساب من sale_items مع cost_price من المنتجات
      final cogsResult = await db.customSelect(
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
      ).getSingle();
      var costOfGoods = (cogsResult.data['total_cost'] is int)
          ? (cogsResult.data['total_cost'] as int).toDouble()
          : cogsResult.data['total_cost'] as double? ?? 0.0;
      // إذا لم تتوفر بيانات التكلفة، استخدم تقدير 68%
      if (costOfGoods == 0 && totalRevenue > 0) {
        costOfGoods = totalRevenue * 0.68;
      }

      // الضرائب: مجموع الضريبة الفعلية من جدول المبيعات
      final taxResult = await db.customSelect(
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
      ).getSingle();
      final totalTaxes = (taxResult.data['total_tax'] is int)
          ? (taxResult.data['total_tax'] as int).toDouble()
          : taxResult.data['total_tax'] as double? ?? 0.0;

      // أكثر المنتجات ربحية: من sale_items مع products
      final topProductResults = await db.customSelect(
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
      ).get();

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
        setState(() { _error = e.toString(); _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('تقرير الأرباح')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('تقرير الأرباح')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(_error!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () { setState(() { _isLoading = true; _error = null; }); _loadData(); },
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('تقرير الأرباح'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) { setState(() => _period = v); _loadData(); },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'week', child: Text('هذا الأسبوع')),
              PopupMenuItem(value: 'month', child: Text('هذا الشهر')),
              PopupMenuItem(value: 'quarter', child: Text('ربع سنوي')),
              PopupMenuItem(value: 'year', child: Text('سنوي')),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(_getPeriodName()),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            tooltip: 'تصدير',
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Net profit highlight
          Card(
            color: _netProfit >= 0 ? Colors.green.shade50 : Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text('صافي الربح'),
                  const SizedBox(height: 8),
                  Text(
                    '${_netProfit.toStringAsFixed(0)} ر.س',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: _netProfit >= 0 ? Colors.green.shade700 : Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'هامش الربح ${_profitMargin.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: _netProfit >= 0 ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Income statement
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('قائمة الدخل', style: Theme.of(context).textTheme.titleMedium),
                  const Divider(),
                  
                  // Revenue
                  _StatementRow(
                    label: 'إجمالي الإيرادات',
                    value: _totalRevenue,
                    isHeader: true,
                    color: Colors.green,
                  ),
                  
                  // COGS
                  _StatementRow(
                    label: 'تكلفة البضاعة المباعة',
                    value: -_costOfGoods,
                    color: Colors.red,
                  ),
                  
                  const Divider(),
                  
                  // Gross profit
                  _StatementRow(
                    label: 'مجمل الربح',
                    value: _grossProfit,
                    isHeader: true,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 8),
                  
                  // Operating expenses
                  _StatementRow(
                    label: 'المصروفات التشغيلية',
                    value: -_expenses,
                    color: Colors.orange,
                  ),
                  
                  // Taxes
                  _StatementRow(
                    label: 'الضرائب',
                    value: -_taxes,
                    color: Colors.purple,
                  ),
                  
                  const Divider(thickness: 2),
                  
                  // Net profit
                  _StatementRow(
                    label: 'صافي الربح',
                    value: _netProfit,
                    isHeader: true,
                    color: _netProfit >= 0 ? Colors.green : Colors.red,
                    isBold: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Breakdown chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('توزيع الإيرادات', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  if (_totalRevenue > 0) ...[
                    SizedBox(
                      height: 24,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Row(
                          children: [
                            Expanded(
                              flex: (_costOfGoods / _totalRevenue * 100).toInt().clamp(1, 100),
                              child: Container(color: Colors.red.shade300),
                            ),
                            Expanded(
                              flex: (_expenses / _totalRevenue * 100).toInt().clamp(1, 100),
                              child: Container(color: Colors.orange.shade300),
                            ),
                            Expanded(
                              flex: (_taxes / _totalRevenue * 100).toInt().clamp(1, 100),
                              child: Container(color: Colors.purple.shade300),
                            ),
                            Expanded(
                              flex: (_netProfit / _totalRevenue * 100).toInt().clamp(1, 100),
                              child: Container(color: Colors.green.shade400),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        _LegendItem(color: Colors.red.shade300, label: 'تكلفة البضاعة', percent: _costOfGoods / _totalRevenue * 100),
                        _LegendItem(color: Colors.orange.shade300, label: 'المصروفات', percent: _expenses / _totalRevenue * 100),
                        _LegendItem(color: Colors.purple.shade300, label: 'الضرائب', percent: _taxes / _totalRevenue * 100),
                        _LegendItem(color: Colors.green.shade400, label: 'صافي الربح', percent: _netProfit / _totalRevenue * 100),
                      ],
                    ),
                  ] else ...[
                    const SizedBox(
                      height: 24,
                      child: Center(child: Text('لا توجد إيرادات في هذه الفترة')),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Top products by profit
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('أكثر المنتجات ربحية', style: Theme.of(context).textTheme.titleMedium),
                  const Divider(),
                  if (_topProducts.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: Text('لا توجد بيانات كافية')),
                    )
                  else
                    ..._topProducts.map((p) => _ProductProfitRow(
                      name: p.name,
                      revenue: p.revenue,
                      cost: p.cost,
                    )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  String _getPeriodName() {
    switch (_period) {
      case 'week': return 'هذا الأسبوع';
      case 'month': return 'هذا الشهر';
      case 'quarter': return 'ربع سنوي';
      case 'year': return 'سنوي';
      default: return 'هذا الشهر';
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
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isHeader ? 8 : 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isHeader || isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
            ),
          ),
          Text(
            '${value >= 0 ? '' : ''}${value.toStringAsFixed(0)} ر.س',
            style: TextStyle(
              fontWeight: isHeader || isBold ? FontWeight.bold : FontWeight.normal,
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
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 4),
        Text('$label (${percent.toStringAsFixed(0)}%)', style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

/// Internal helper for top product data
class _TopProductData {
  final String name;
  final double revenue;
  final double cost;
  const _TopProductData({required this.name, required this.revenue, required this.cost});
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
    final profit = revenue - cost;
    final margin = (profit / revenue) * 100;
    
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(name),
      subtitle: Text('هامش الربح: ${margin.toStringAsFixed(0)}%'),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '+${profit.toStringAsFixed(0)} ر.س',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
          ),
          Text(
            'إيراد: ${revenue.toStringAsFixed(0)}',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
