import 'package:drift/drift.dart' hide Column;
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
  String? _error;

  double _totalSales = 0;
  double _salesTax = 0;
  double _totalPurchases = 0;
  double _purchasesTax = 0;
  double _netTax = 0;

  // تفاصيل الضريبة حسب طريقة الدفع
  List<_TaxByPaymentMethod> _taxByPayment = [];

  @override
  void initState() {
    super.initState();
    _loadTaxData();
  }

  Future<void> _loadTaxData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final db = getIt<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider) ?? kDemoStoreId;
      final now = DateTime.now();
      DateTime startDate;
      switch (_period) {
        case 'quarter':
          final quarterMonth = ((now.month - 1) ~/ 3) * 3 + 1;
          startDate = DateTime(now.year, quarterMonth, 1);
          break;
        case 'year':
          startDate = DateTime(now.year, 1, 1);
          break;
        default:
          startDate = DateTime(now.year, now.month, 1);
      }

      // استعلام إجمالي المبيعات وإجمالي الضريبة الفعلية من جدول المبيعات
      final taxResult = await db.customSelect(
        '''SELECT
             COALESCE(SUM(total), 0) as total_sales,
             COALESCE(SUM(tax), 0) as total_tax,
             COUNT(*) as sale_count
           FROM sales
           WHERE store_id = ?
             AND status = 'completed'
             AND created_at >= ?
             AND created_at < ?''',
        variables: [
          Variable.withString(storeId),
          Variable.withDateTime(startDate),
          Variable.withDateTime(now),
        ],
      ).getSingle();

      _totalSales = (taxResult.data['total_sales'] is int)
          ? (taxResult.data['total_sales'] as int).toDouble()
          : taxResult.data['total_sales'] as double? ?? 0.0;

      _salesTax = (taxResult.data['total_tax'] is int)
          ? (taxResult.data['total_tax'] as int).toDouble()
          : taxResult.data['total_tax'] as double? ?? 0.0;

      // إذا كانت الضريبة صفر ولكن هناك مبيعات، احسب 15% كتقدير
      if (_salesTax == 0 && _totalSales > 0) {
        _salesTax = _totalSales * 0.15;
      }

      // استعلام الضريبة حسب طريقة الدفع
      final paymentTaxResults = await db.customSelect(
        '''SELECT
             payment_method,
             COALESCE(SUM(total), 0) as method_total,
             COALESCE(SUM(tax), 0) as method_tax,
             COUNT(*) as method_count
           FROM sales
           WHERE store_id = ?
             AND status = 'completed'
             AND created_at >= ?
             AND created_at < ?
           GROUP BY payment_method
           ORDER BY method_total DESC''',
        variables: [
          Variable.withString(storeId),
          Variable.withDateTime(startDate),
          Variable.withDateTime(now),
        ],
      ).get();

      _taxByPayment = paymentTaxResults.map((row) {
        final method = row.data['payment_method'] as String? ?? 'unknown';
        final total = (row.data['method_total'] is int)
            ? (row.data['method_total'] as int).toDouble()
            : row.data['method_total'] as double? ?? 0.0;
        var tax = (row.data['method_tax'] is int)
            ? (row.data['method_tax'] as int).toDouble()
            : row.data['method_tax'] as double? ?? 0.0;
        final count = row.data['method_count'] as int? ?? 0;

        // إذا الضريبة صفر ولكن هناك مبيعات، احسب 15%
        if (tax == 0 && total > 0) {
          tax = total * 0.15;
        }

        return _TaxByPaymentMethod(
          method: _translatePaymentMethod(method),
          total: total,
          tax: tax,
          count: count,
        );
      }).toList();

      // المشتريات - ليس متاحاً حالياً من قاعدة البيانات
      _totalPurchases = 0;
      _purchasesTax = 0;
      _netTax = _salesTax - _purchasesTax;

      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  /// ترجمة أسماء طرق الدفع
  String _translatePaymentMethod(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return 'نقدي';
      case 'card':
        return 'بطاقة';
      case 'mixed':
        return 'مختلط';
      case 'credit':
        return 'آجل';
      default:
        return method;
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

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('تقرير الضرائب')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(_error!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadTaxData,
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
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

            // تفاصيل الضريبة حسب طريقة الدفع
            if (_taxByPayment.isNotEmpty) ...[
              Text('الضريبة حسب طريقة الدفع', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: _taxByPayment.map((item) => _TaxRow(
                    label: '${item.method} (${item.count} فاتورة)',
                    value: item.tax.toStringAsFixed(2),
                  )).toList(),
                ),
              ),
              const SizedBox(height: 24),
            ],

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
              color: Colors.blue.withValues(alpha: 0.1),
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
                          Text('الموعد النهائي للإقرار: نهاية الشهر التالي', style: TextStyle(fontSize: 12)),
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

/// بيانات الضريبة حسب طريقة الدفع
class _TaxByPaymentMethod {
  final String method;
  final double total;
  final double tax;
  final int count;

  const _TaxByPaymentMethod({
    required this.method,
    required this.total,
    required this.tax,
    required this.count,
  });
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
            Text(subtitle, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
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
