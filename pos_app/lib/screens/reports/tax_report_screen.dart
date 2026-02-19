import 'package:pos_app/widgets/common/adaptive_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/app_database.dart';
import '../../di/injection.dart';
import '../../providers/products_providers.dart';

/// شاشة تقرير الضرائب
class TaxReportScreen extends ConsumerStatefulWidget {
  const TaxReportScreen({super.key});

  @override
  ConsumerState<TaxReportScreen> createState() => _TaxReportScreenState();
}

class _TaxReportScreenState extends ConsumerState<TaxReportScreen> {
  String _period = 'month';
  bool _isLoading = true;

  double _totalSales = 0;
  double _salesTax = 0;
  double _totalPurchases = 0;
  double _purchasesTax = 0;
  double _netTax = 0;

  @override
  void initState() {
    super.initState();
    _loadTaxData();
  }

  Future<void> _loadTaxData() async {
    try {
      final db = getIt<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider) ?? kDemoStoreId;
      final now = DateTime.now();
      DateTime startDate;
      switch (_period) {
        case 'quarter':
          startDate = DateTime(now.year, now.month - 3, 1);
          break;
        case 'year':
          startDate = DateTime(now.year, 1, 1);
          break;
        default:
          startDate = DateTime(now.year, now.month, 1);
      }

      final salesStats = await db.salesDao.getSalesStats(storeId, startDate: startDate, endDate: now);
      _totalSales = salesStats.total;
      _salesTax = _totalSales * 0.15;
      // Purchases not readily available from salesDao, set to 0
      _totalPurchases = 0;
      _purchasesTax = _totalPurchases * 0.15;
      _netTax = _salesTax - _purchasesTax;

      setState(() => _isLoading = false);
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('تقرير الضرائب')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقرير الضرائب'),
        actions: [
          IconButton(icon: const Icon(Icons.file_download), onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تصدير التقرير')))),
          IconButton(icon: const Icon(Icons.print), onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('طباعة التقرير')))),
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
                ButtonSegment(value: 'month', label: Text('شهري')),
                ButtonSegment(value: 'quarter', label: Text('ربع سنوي')),
                ButtonSegment(value: 'year', label: Text('سنوي')),
              ],
              selected: {_period},
              onSelectionChanged: (v) {
                setState(() {
                  _period = v.first;
                  _isLoading = true;
                });
                _loadTaxData();
              },
            ),
            const SizedBox(height: 24),

            // ملخص الضريبة
            Card(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.green.shade600, Colors.green.shade400]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('صافي الضريبة المستحقة', style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 8),
                    Text('${_netTax.toStringAsFixed(2)} ر.س', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('${DateTime.now().month}/${DateTime.now().year}', style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // تفاصيل
            Row(
              children: [
                Expanded(child: _DetailCard(title: 'ضريبة المبيعات', subtitle: 'المحصلة', value: _salesTax.toStringAsFixed(2), color: Colors.blue)),
                const SizedBox(width: 12),
                Expanded(child: _DetailCard(title: 'ضريبة المشتريات', subtitle: 'المدفوعة', value: _purchasesTax.toStringAsFixed(2), color: Colors.orange)),
              ],
            ),

            const SizedBox(height: 24),

            // جدول التفاصيل
            Text('تفاصيل الضريبة', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  _TaxRow(label: 'إجمالي المبيعات', value: _totalSales.toStringAsFixed(2)),
                  _TaxRow(label: 'المبيعات الخاضعة للضريبة', value: _totalSales.toStringAsFixed(2)),
                  _TaxRow(label: 'ضريبة المبيعات (15%)', value: _salesTax.toStringAsFixed(2), highlight: true),
                  const Divider(height: 1),
                  _TaxRow(label: 'إجمالي المشتريات', value: _totalPurchases.toStringAsFixed(2)),
                  _TaxRow(label: 'المشتريات الخاضعة للضريبة', value: _totalPurchases.toStringAsFixed(2)),
                  _TaxRow(label: 'ضريبة المشتريات (15%)', value: _purchasesTax.toStringAsFixed(2), highlight: true),
                  const Divider(height: 1),
                  _TaxRow(label: 'صافي الضريبة', value: _netTax.toStringAsFixed(2), highlight: true, isTotal: true),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // معلومات ZATCA
            Card(
              color: Colors.blue.shade50,
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('تذكير ZATCA', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                          Text('الموعد النهائي للإقرار: 28 فبراير 2026', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // أزرار الإجراءات
            Row(
              children: [
                Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.history), label: const Text('السجل'))),
                const SizedBox(width: 12),
                Expanded(child: FilledButton.icon(onPressed: () {}, icon: const AdaptiveIcon(Icons.send), label: const Text('إرسال للهيئة'))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final String title, subtitle, value;
  final Color color;
  const _DetailCard({required this.title, required this.subtitle, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            const SizedBox(height: 8),
            Text('$value ر.س', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _TaxRow extends StatelessWidget {
  final String label, value;
  final bool highlight, isTotal;
  const _TaxRow({required this.label, required this.value, this.highlight = false, this.isTotal = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, fontSize: isTotal ? 16 : 14)),
          Text('$value ر.س', style: TextStyle(fontWeight: highlight ? FontWeight.bold : FontWeight.normal, color: isTotal ? Colors.green : (highlight ? Colors.blue : null), fontSize: isTotal ? 18 : 14)),
        ],
      ),
    );
  }
}
