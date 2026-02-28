import 'package:drift/drift.dart' hide Column;
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_design_system/alhai_design_system.dart' show AlhaiColors;
import 'package:alhai_l10n/alhai_l10n.dart';

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
      final db = GetIt.I<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider) ?? kDefaultStoreId;
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
          method: method,
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
  String _translatePaymentMethod(BuildContext context, String method) {
    final l10n = AppLocalizations.of(context)!;
    switch (method.toLowerCase()) {
      case 'cash':
        return l10n.cashPaymentMethod;
      case 'card':
        return l10n.cardPaymentMethod;
      case 'mixed':
        return l10n.mixedPaymentMethod;
      case 'credit':
        return l10n.creditPaymentMethod;
      default:
        return method;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      final l10n = AppLocalizations.of(context)!;
      return Scaffold(
        appBar: AppBar(title: Text(l10n.taxReportTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      final l10n = AppLocalizations.of(context)!;
      return Scaffold(
        appBar: AppBar(title: Text(l10n.taxReportTitle)),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: AlhaiColors.error),
              const SizedBox(height: 16),
              Text(_error!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadTaxData,
                child: Text(l10n.retryAction),
              ),
            ],
          ),
        ),
      );
    }

    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.taxReportTitle),
        actions: [
          IconButton(icon: const Icon(Icons.file_download), onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.exportReportAction)))),
          IconButton(icon: const Icon(Icons.print), onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.printReportAction)))),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // الفترة
            SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'month', label: Text(l10n.monthly)),
                ButtonSegment(value: 'quarter', label: Text(l10n.quarterly)),
                ButtonSegment(value: 'year', label: Text(l10n.yearly)),
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
                  gradient: LinearGradient(colors: [AlhaiColors.successDark, AlhaiColors.success]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.netTaxDue, style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 8),
                    Text('${_netTax.toStringAsFixed(2)} ${l10n.sar}', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
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
                Expanded(child: _DetailCard(title: l10n.salesTaxCollected, subtitle: l10n.salesTaxSubtitle, value: _salesTax.toStringAsFixed(2), color: AlhaiColors.info)),
                const SizedBox(width: 12),
                Expanded(child: _DetailCard(title: l10n.purchasesTaxPaid, subtitle: l10n.purchasesTaxSubtitle, value: _purchasesTax.toStringAsFixed(2), color: Colors.orange)),
              ],
            ),

            const SizedBox(height: 24),

            // تفاصيل الضريبة حسب طريقة الدفع
            if (_taxByPayment.isNotEmpty) ...[
              Text(l10n.taxByPaymentMethod, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: _taxByPayment.map((item) => _TaxRow(
                    label: '${_translatePaymentMethod(context, item.method)} (${l10n.invoiceCount(item.count)})',
                    value: item.tax.toStringAsFixed(2),
                  )).toList(),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // جدول التفاصيل
            Text(l10n.taxDetailsTitle, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  _TaxRow(label: l10n.totalSales, value: _totalSales.toStringAsFixed(2)),
                  _TaxRow(label: l10n.taxableSales, value: _totalSales.toStringAsFixed(2)),
                  _TaxRow(label: l10n.salesTax15, value: _salesTax.toStringAsFixed(2), highlight: true),
                  const Divider(height: 1),
                  _TaxRow(label: l10n.totalPurchases, value: _totalPurchases.toStringAsFixed(2)),
                  _TaxRow(label: l10n.taxablePurchases, value: _totalPurchases.toStringAsFixed(2)),
                  _TaxRow(label: l10n.purchasesTax15, value: _purchasesTax.toStringAsFixed(2), highlight: true),
                  const Divider(height: 1),
                  _TaxRow(label: l10n.netTax, value: _netTax.toStringAsFixed(2), highlight: true, isTotal: true),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // معلومات ZATCA
            Card(
              color: AlhaiColors.info.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AlhaiColors.info),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.zatcaReminder, style: TextStyle(fontWeight: FontWeight.bold, color: AlhaiColors.info)),
                          Text(l10n.zatcaDeadline, style: const TextStyle(fontSize: 12)),
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
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.exportReportAction)),
                      );
                    },
                    icon: const Icon(Icons.history),
                    label: Text(l10n.historyAction),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('إرسال للهيئة الزكاة والضريبة'),
                          content: const Text(
                            'سيتم إرسال بيانات الفوترة الإلكترونية للهيئة. تأكد من صحة بياناتك أولاً.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('إلغاء'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'سيتم الربط بنظام ZATCA قريباً - تأكد من إعداد الشهادة الرقمية',
                                    ),
                                  ),
                                );
                              },
                              child: const Text('إرسال'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const AdaptiveIcon(Icons.send),
                    label: Text(l10n.sendToAuthority),
                  ),
                ),
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
            Text('$value ${AppLocalizations.of(context)!.sar}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
          Text('$value ${AppLocalizations.of(context)!.sar}', style: TextStyle(fontWeight: highlight ? FontWeight.bold : FontWeight.normal, color: isTotal ? AlhaiColors.success : (highlight ? AlhaiColors.info : null), fontSize: isTotal ? 18 : 14)),
        ],
      ),
    );
  }
}
