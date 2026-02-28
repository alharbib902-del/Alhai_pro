import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_design_system/alhai_design_system.dart' show AlhaiColors;
import 'package:alhai_shared_ui/alhai_shared_ui.dart';

/// شاشة تقرير المشتريات الكاملة
class PurchaseReportScreen extends ConsumerStatefulWidget {
  const PurchaseReportScreen({super.key});

  @override
  ConsumerState<PurchaseReportScreen> createState() => _PurchaseReportScreenState();
}

class _PurchaseReportScreenState extends ConsumerState<PurchaseReportScreen> {
  String _period = 'month';
  bool _isLoading = true;
  String? _error;

  double _totalPurchases = 0;
  int _invoiceCount = 0;
  double _avgInvoice = 0;
  double _totalTax = 0;
  List<_SupplierPurchase> _bySupplier = [];
  List<_PurchaseRow> _recent = [];

  ({DateTime start, DateTime end}) _getDateRange() {
    final now = DateTime.now();
    switch (_period) {
      case 'week':
        final start = now.subtract(Duration(days: now.weekday - 1));
        return (start: DateTime(start.year, start.month, start.day), end: now);
      case 'month':
        return (start: DateTime(now.year, now.month, 1), end: now);
      case 'quarter':
        final qm = ((now.month - 1) ~/ 3) * 3 + 1;
        return (start: DateTime(now.year, qm, 1), end: now);
      case 'year':
        return (start: DateTime(now.year, 1, 1), end: now);
      default:
        return (start: DateTime(now.year, now.month, 1), end: now);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() { _isLoading = true; _error = null; });
      final db = GetIt.I<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) {
        setState(() { _error = 'لم يتم تحديد المتجر'; _isLoading = false; });
        return;
      }
      final dr = _getDateRange();

      // Totals
      final totals = await db.customSelect(
        '''SELECT
             COUNT(*) as cnt,
             COALESCE(SUM(total), 0) as total,
             COALESCE(SUM(tax_amount), 0) as tax
           FROM purchases
           WHERE store_id = ?
             AND created_at >= ?
             AND created_at < ?''',
        variables: [
          Variable.withString(storeId),
          Variable.withDateTime(dr.start),
          Variable.withDateTime(dr.end),
        ],
      ).getSingle();
      final cnt = (totals.data['cnt'] as int?) ?? 0;
      final total = _toDouble(totals.data['total']);
      final tax = _toDouble(totals.data['tax']);

      // By supplier
      final bySup = await db.customSelect(
        '''SELECT
             COALESCE(s.name, 'بدون مورد') as sup_name,
             COUNT(*) as cnt,
             COALESCE(SUM(p.total), 0) as total
           FROM purchases p
           LEFT JOIN suppliers s ON s.id = p.supplier_id
           WHERE p.store_id = ?
             AND p.created_at >= ?
             AND p.created_at < ?
           GROUP BY p.supplier_id
           ORDER BY total DESC
           LIMIT 8''',
        variables: [
          Variable.withString(storeId),
          Variable.withDateTime(dr.start),
          Variable.withDateTime(dr.end),
        ],
      ).get();

      // Recent 10
      final recent = await db.customSelect(
        '''SELECT
             p.id,
             p.invoice_number,
             p.created_at,
             p.total,
             COALESCE(s.name, 'بدون مورد') as sup_name
           FROM purchases p
           LEFT JOIN suppliers s ON s.id = p.supplier_id
           WHERE p.store_id = ?
             AND p.created_at >= ?
             AND p.created_at < ?
           ORDER BY p.created_at DESC
           LIMIT 10''',
        variables: [
          Variable.withString(storeId),
          Variable.withDateTime(dr.start),
          Variable.withDateTime(dr.end),
        ],
      ).get();

      if (mounted) {
        setState(() {
          _invoiceCount = cnt;
          _totalPurchases = total;
          _totalTax = tax;
          _avgInvoice = cnt > 0 ? total / cnt : 0;
          _bySupplier = bySup.map((r) => _SupplierPurchase(
            name: r.data['sup_name'] as String,
            count: (r.data['cnt'] as int?) ?? 0,
            total: _toDouble(r.data['total']),
          )).toList();
          _recent = recent.map((r) => _PurchaseRow(
            id: r.data['id'] as String,
            invoiceNumber: r.data['invoice_number'] as String? ?? '-',
            supplier: r.data['sup_name'] as String,
            total: _toDouble(r.data['total']),
            date: r.data['created_at'] is String
                ? DateTime.tryParse(r.data['created_at'] as String) ?? DateTime.now()
                : (r.data['created_at'] as DateTime? ?? DateTime.now()),
          )).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  double _toDouble(dynamic v) {
    if (v is int) return v.toDouble();
    if (v is double) return v;
    return 0.0;
  }

  String _periodLabel() {
    switch (_period) {
      case 'week': return 'هذا الأسبوع';
      case 'month': return 'هذا الشهر';
      case 'quarter': return 'هذا الربع';
      case 'year': return 'هذه السنة';
      default: return 'هذا الشهر';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('تقرير المشتريات')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('تقرير المشتريات')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: AlhaiColors.error),
              const SizedBox(height: 12),
              Text(_error!),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _loadData, child: const Text('إعادة المحاولة')),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقرير المشتريات'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) { setState(() => _period = v); _loadData(); },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'week', child: Text('هذا الأسبوع')),
              const PopupMenuItem(value: 'month', child: Text('هذا الشهر')),
              const PopupMenuItem(value: 'quarter', child: Text('ربع سنوي')),
              const PopupMenuItem(value: 'year', child: Text('سنوي')),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [
                Text(_periodLabel()),
                const Icon(Icons.arrow_drop_down),
              ]),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Summary cards
            Row(children: [
              Expanded(child: _SummaryCard(
                label: 'إجمالي المشتريات',
                value: '${_totalPurchases.toStringAsFixed(0)} ر.س',
                icon: Icons.shopping_cart_rounded,
                color: AlhaiColors.info,
              )),
              const SizedBox(width: 12),
              Expanded(child: _SummaryCard(
                label: 'عدد الفواتير',
                value: _invoiceCount.toString(),
                icon: Icons.receipt_long_rounded,
                color: Colors.orange,
              )),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _SummaryCard(
                label: 'متوسط الفاتورة',
                value: '${_avgInvoice.toStringAsFixed(0)} ر.س',
                icon: Icons.calculate_rounded,
                color: AlhaiColors.success,
              )),
              const SizedBox(width: 12),
              Expanded(child: _SummaryCard(
                label: 'إجمالي الضريبة',
                value: '${_totalTax.toStringAsFixed(0)} ر.س',
                icon: Icons.percent_rounded,
                color: Colors.purple,
              )),
            ]),
            const SizedBox(height: 20),

            // By supplier
            if (_bySupplier.isNotEmpty) ...[
              const Text('المشتريات حسب المورد',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: _bySupplier.map((s) {
                    final pct = _totalPurchases > 0 ? s.total / _totalPurchases : 0.0;
                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 18,
                        backgroundColor: AlhaiColors.info.withValues(alpha: 0.1),
                        child: Icon(Icons.business_rounded, size: 16, color: AlhaiColors.info),
                      ),
                      title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: LinearProgressIndicator(
                        value: pct.toDouble(),
                        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${s.total.toStringAsFixed(0)} ر.س',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text('${s.count} فاتورة',
                              style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Recent purchases
            if (_recent.isNotEmpty) ...[
              const Text('آخر الفواتير',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: _recent.map((p) => ListTile(
                    dense: true,
                    leading: Icon(Icons.receipt_rounded, color: AlhaiColors.info),
                    title: Text('${p.invoiceNumber} - ${p.supplier}',
                        style: const TextStyle(fontSize: 13)),
                    subtitle: Text(
                      '${p.date.day}/${p.date.month}/${p.date.year}',
                      style: const TextStyle(fontSize: 11),
                    ),
                    trailing: Text(
                      '${p.total.toStringAsFixed(0)} ر.س',
                      style: TextStyle(fontWeight: FontWeight.bold, color: AlhaiColors.info),
                    ),
                  )).toList(),
                ),
              ),
            ],

            if (_invoiceCount == 0)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.shopping_cart_outlined, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      const SizedBox(height: 12),
                      Text('لا توجد مشتريات في هذه الفترة',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
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

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _SupplierPurchase {
  final String name;
  final int count;
  final double total;
  const _SupplierPurchase({required this.name, required this.count, required this.total});
}

class _PurchaseRow {
  final String id;
  final String invoiceNumber;
  final String supplier;
  final double total;
  final DateTime date;
  const _PurchaseRow({
    required this.id,
    required this.invoiceNumber,
    required this.supplier,
    required this.total,
    required this.date,
  });
}
