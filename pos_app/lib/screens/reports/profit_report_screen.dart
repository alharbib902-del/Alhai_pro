import 'package:flutter/material.dart';

/// شاشة تقرير الأرباح
class ProfitReportScreen extends StatefulWidget {
  const ProfitReportScreen({super.key});

  @override
  State<ProfitReportScreen> createState() => _ProfitReportScreenState();
}

class _ProfitReportScreenState extends State<ProfitReportScreen> {
  String _period = 'month';
  
  // Mock data
  final double _totalRevenue = 125000;
  final double _costOfGoods = 85000;
  final double _expenses = 18000;
  final double _taxes = 5400;
  
  double get _grossProfit => _totalRevenue - _costOfGoods;
  double get _netProfit => _grossProfit - _expenses - _taxes;
  double get _profitMargin => (_netProfit / _totalRevenue) * 100;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقرير الأرباح'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) => setState(() => _period = v),
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
                  SizedBox(
                    height: 24,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Row(
                        children: [
                          Expanded(
                            flex: (_costOfGoods / _totalRevenue * 100).toInt(),
                            child: Container(color: Colors.red.shade300),
                          ),
                          Expanded(
                            flex: (_expenses / _totalRevenue * 100).toInt(),
                            child: Container(color: Colors.orange.shade300),
                          ),
                          Expanded(
                            flex: (_taxes / _totalRevenue * 100).toInt(),
                            child: Container(color: Colors.purple.shade300),
                          ),
                          Expanded(
                            flex: (_netProfit / _totalRevenue * 100).toInt(),
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
                  const _ProductProfitRow(name: 'أرز بسمتي', revenue: 15000, cost: 9000),
                  const _ProductProfitRow(name: 'زيت زيتون', revenue: 12000, cost: 7200),
                  const _ProductProfitRow(name: 'حليب طازج', revenue: 10000, cost: 6500),
                  const _ProductProfitRow(name: 'مياه معدنية', revenue: 8000, cost: 4000),
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
