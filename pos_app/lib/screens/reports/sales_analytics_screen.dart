import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/settings_providers.dart';

/// شاشة تحليلات المبيعات - بيانات حقيقية من قاعدة البيانات
class SalesAnalyticsScreen extends ConsumerStatefulWidget {
  const SalesAnalyticsScreen({super.key});

  @override
  ConsumerState<SalesAnalyticsScreen> createState() => _SalesAnalyticsScreenState();
}

class _SalesAnalyticsScreenState extends ConsumerState<SalesAnalyticsScreen> {
  String _selectedPeriod = 'week';

  DateRange? get _dateRange {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'today':
        final start = DateTime(now.year, now.month, now.day);
        return DateRange(start: start, end: now);
      case 'week':
        return DateRange(start: now.subtract(const Duration(days: 7)), end: now);
      case 'month':
        return DateRange(start: now.subtract(const Duration(days: 30)), end: now);
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(salesAnalyticsProvider(_dateRange));

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
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطأ: $e')),
        data: (stats) => SingleChildScrollView(
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
                    value: '${stats.total.toStringAsFixed(0)} ر.س', color: Colors.green,
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _MetricCard(
                    icon: Icons.receipt_long, title: 'عدد الفواتير',
                    value: '${stats.count}', color: Colors.blue,
                  )),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _MetricCard(
                    icon: Icons.shopping_cart, title: 'متوسط الفاتورة',
                    value: '${stats.average.toStringAsFixed(0)} ر.س', color: Colors.orange,
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _MetricCard(
                    icon: Icons.trending_up, title: 'أعلى فاتورة',
                    value: '${stats.maxSale.toStringAsFixed(0)} ر.س', color: Colors.purple,
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
                      Text('ملخص', style: Theme.of(context).textTheme.titleMedium),
                      const Divider(),
                      _SummaryRow(label: 'إجمالي المبيعات', value: '${stats.total.toStringAsFixed(2)} ر.س'),
                      _SummaryRow(label: 'عدد الفواتير', value: '${stats.count}'),
                      _SummaryRow(label: 'متوسط الفاتورة', value: '${stats.average.toStringAsFixed(2)} ر.س'),
                      _SummaryRow(label: 'أعلى فاتورة', value: '${stats.maxSale.toStringAsFixed(2)} ر.س'),
                      _SummaryRow(label: 'أقل فاتورة', value: '${stats.minSale.toStringAsFixed(2)} ر.س'),
                    ],
                  ),
                ),
              ),
            ],
          ),
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

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
