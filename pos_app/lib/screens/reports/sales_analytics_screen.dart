import 'package:flutter/material.dart';

/// شاشة تحليلات المبيعات
class SalesAnalyticsScreen extends StatefulWidget {
  const SalesAnalyticsScreen({super.key});

  @override
  State<SalesAnalyticsScreen> createState() => _SalesAnalyticsScreenState();
}

class _SalesAnalyticsScreenState extends State<SalesAnalyticsScreen> {
  String _selectedPeriod = 'week';
  
  final Map<String, dynamic> _analytics = {
    'totalSales': 125000.0,
    'ordersCount': 342,
    'avgOrderValue': 365.50,
    'growth': 15.3,
    'topProducts': [
      {'name': 'أرز بسمتي 5 كجم', 'sales': 15000.0, 'quantity': 150},
      {'name': 'حليب طازج 1 لتر', 'sales': 12500.0, 'quantity': 500},
      {'name': 'زيت زيتون 500مل', 'sales': 9800.0, 'quantity': 98},
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تحليلات المبيعات'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.date_range),
            onSelected: (v) => setState(() => _selectedPeriod = v),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'today', child: Text('اليوم')),
              const PopupMenuItem(value: 'week', child: Text('الأسبوع')),
              const PopupMenuItem(value: 'month', child: Text('الشهر')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _selectedPeriod == 'today' ? 'اليوم' : _selectedPeriod == 'week' ? 'الأسبوع' : 'الشهر',
                style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _MetricCard(
                  icon: Icons.attach_money, title: 'إجمالي المبيعات',
                  value: '${_analytics['totalSales'].toStringAsFixed(0)} ر.س', color: Colors.green,
                )),
                const SizedBox(width: 12),
                Expanded(child: _MetricCard(
                  icon: Icons.receipt_long, title: 'عدد الطلبات',
                  value: '${_analytics['ordersCount']}', color: Colors.blue,
                )),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _MetricCard(
                  icon: Icons.shopping_cart, title: 'متوسط الطلب',
                  value: '${_analytics['avgOrderValue'].toStringAsFixed(0)} ر.س', color: Colors.orange,
                )),
                const SizedBox(width: 12),
                Expanded(child: _MetricCard(
                  icon: Icons.trending_up, title: 'النمو',
                  value: '+${_analytics['growth']}%', color: Colors.purple,
                )),
              ],
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('أفضل المنتجات', style: Theme.of(context).textTheme.titleMedium),
                    const Divider(),
                    ...(_analytics['topProducts'] as List).asMap().entries.map((e) {
                      final p = e.value as Map<String, dynamic>;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            CircleAvatar(radius: 14, child: Text('${e.key + 1}')),
                            const SizedBox(width: 12),
                            Expanded(child: Text(p['name'] as String)),
                            Text('${(p['sales'] as num).toStringAsFixed(0)} ر.س'),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  
  const _MetricCard({required this.icon, required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            ]),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
