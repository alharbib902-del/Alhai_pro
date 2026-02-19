import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';

/// شاشة تحليل العملاء
class CustomerAnalyticsScreen extends StatefulWidget {
  const CustomerAnalyticsScreen({super.key});

  @override
  State<CustomerAnalyticsScreen> createState() => _CustomerAnalyticsScreenState();
}

class _CustomerAnalyticsScreenState extends State<CustomerAnalyticsScreen> {
  String _period = 'month';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('تحليل العملاء'),
        actions: [
          IconButton(icon: const Icon(Icons.file_download), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // الفترة
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'week', label: Text('أسبوع')),
                ButtonSegment(value: 'month', label: Text('شهر')),
                ButtonSegment(value: 'year', label: Text('سنة')),
              ],
              selected: {_period},
              onSelectionChanged: (v) => setState(() => _period = v.first),
            ),

            const SizedBox(height: 24),

            // الإحصائيات الرئيسية
            const Row(
              children: [
                _StatCard(icon: Icons.people, label: 'إجمالي العملاء', value: '1,250', trend: '+12%', trendUp: true, color: Colors.blue),
                SizedBox(width: 12),
                _StatCard(icon: Icons.person_add, label: 'عملاء جدد', value: '45', trend: '+8%', trendUp: true, color: Colors.green),
              ],
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                _StatCard(icon: Icons.repeat, label: 'عملاء متكررون', value: '68%', trend: '+5%', trendUp: true, color: Colors.purple),
                SizedBox(width: 12),
                _StatCard(icon: Icons.attach_money, label: 'متوسط الإنفاق', value: '245 ر.س', trend: '-3%', trendUp: false, color: Colors.orange),
              ],
            ),

            const SizedBox(height: 24),

            // أفضل العملاء
            Text('أفضل العملاء', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  _CustomerTile(rank: 1, name: l10n.defaultUserName, orders: 45, spent: 12500),
                  const Divider(height: 1),
                  const _CustomerTile(rank: 2, name: 'خالد عمر', orders: 38, spent: 9800),
                  const Divider(height: 1),
                  const _CustomerTile(rank: 3, name: 'محمد علي', orders: 32, spent: 8200),
                  const Divider(height: 1),
                  const _CustomerTile(rank: 4, name: 'سعد العمري', orders: 28, spent: 7500),
                  const Divider(height: 1),
                  const _CustomerTile(rank: 5, name: 'فهد عبدالله', orders: 25, spent: 6800),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // توزيع العملاء
            Text('توزيع العملاء', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    _DistributionRow(label: 'VIP (أكثر من 5000 ر.س)', percentage: 15, color: Colors.amber),
                    SizedBox(height: 12),
                    _DistributionRow(label: 'منتظمين (1000-5000 ر.س)', percentage: 35, color: Colors.blue),
                    SizedBox(height: 12),
                    _DistributionRow(label: 'عاديين (أقل من 1000 ر.س)', percentage: 50, color: Colors.grey),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // نشاط العملاء
            Text('نشاط العملاء', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _ActivityStat(label: 'نشط', value: '780', percentage: 62, color: Colors.green),
                        _ActivityStat(label: 'خامل', value: '350', percentage: 28, color: Colors.orange),
                        _ActivityStat(label: 'غير نشط', value: '120', percentage: 10, color: Colors.red),
                      ],
                    ),
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

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label, value, trend;
  final bool trendUp;
  final Color color;
  const _StatCard({required this.icon, required this.label, required this.value, required this.trend, required this.trendUp, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: (trendUp ? Colors.green : Colors.red).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                    child: Row(
                      children: [
                        Icon(trendUp ? Icons.arrow_upward : Icons.arrow_downward, size: 12, color: trendUp ? Colors.green : Colors.red),
                        Text(trend, style: TextStyle(fontSize: 10, color: trendUp ? Colors.green : Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
              Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
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
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: rank <= 3 ? Colors.amber.shade100 : Colors.grey.shade100,
        child: Text('$rank', style: TextStyle(color: rank <= 3 ? Colors.amber.shade800 : Colors.grey, fontWeight: FontWeight.bold)),
      ),
      title: Text(name),
      subtitle: Text('$orders طلب'),
      trailing: Text('${spent.toStringAsFixed(0)} ر.س', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(label, style: const TextStyle(fontSize: 12)), Text('$percentage%', style: const TextStyle(fontWeight: FontWeight.bold))],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(value: percentage / 100, backgroundColor: Colors.grey.shade200, valueColor: AlwaysStoppedAnimation(color)),
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
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(width: 60, height: 60, child: CircularProgressIndicator(value: percentage / 100, backgroundColor: Colors.grey.shade200, valueColor: AlwaysStoppedAnimation(color), strokeWidth: 6)),
            Text('$percentage%', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
      ],
    );
  }
}
