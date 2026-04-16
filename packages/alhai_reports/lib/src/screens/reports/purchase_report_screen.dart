import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_design_system/alhai_design_system.dart'
    show AlhaiColors, AlhaiSpacing;
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../utils/csv_export_helper.dart';
import '../../utils/pdf_font_helper.dart';

/// Purchase Report screen with full l10n support
class PurchaseReportScreen extends ConsumerStatefulWidget {
  const PurchaseReportScreen({super.key});

  @override
  ConsumerState<PurchaseReportScreen> createState() =>
      _PurchaseReportScreenState();
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
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final db = GetIt.I<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) {
        setState(() {
          _error = 'store_not_selected';
          _isLoading = false;
        });
        return;
      }
      final dr = _getDateRange();

      // Totals
      final totals = await db
          .customSelect(
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
          )
          .getSingle();
      final cnt = (totals.data['cnt'] as int?) ?? 0;
      final total = _toDouble(totals.data['total']);
      final tax = _toDouble(totals.data['tax']);

      // By supplier
      final bySup = await db
          .customSelect(
            '''SELECT
             COALESCE(s.name, ?) as sup_name,
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
              Variable.withString('—'),
              Variable.withString(storeId),
              Variable.withDateTime(dr.start),
              Variable.withDateTime(dr.end),
            ],
          )
          .get();

      // Recent 10
      final recent = await db
          .customSelect(
            '''SELECT
             p.id,
             p.invoice_number,
             p.created_at,
             p.total,
             COALESCE(s.name, ?) as sup_name
           FROM purchases p
           LEFT JOIN suppliers s ON s.id = p.supplier_id
           WHERE p.store_id = ?
             AND p.created_at >= ?
             AND p.created_at < ?
           ORDER BY p.created_at DESC
           LIMIT 10''',
            variables: [
              Variable.withString('—'),
              Variable.withString(storeId),
              Variable.withDateTime(dr.start),
              Variable.withDateTime(dr.end),
            ],
          )
          .get();

      if (mounted) {
        setState(() {
          _invoiceCount = cnt;
          _totalPurchases = total;
          _totalTax = tax;
          _avgInvoice = cnt > 0 ? total / cnt : 0;
          _bySupplier = bySup
              .map(
                (r) => _SupplierPurchase(
                  name: r.data['sup_name'] as String,
                  count: (r.data['cnt'] as int?) ?? 0,
                  total: _toDouble(r.data['total']),
                ),
              )
              .toList();
          _recent = recent
              .map(
                (r) => _PurchaseRow(
                  id: r.data['id'] as String,
                  invoiceNumber: r.data['invoice_number'] as String? ?? '-',
                  supplier: r.data['sup_name'] as String,
                  total: _toDouble(r.data['total']),
                  date: r.data['created_at'] is String
                      ? DateTime.tryParse(r.data['created_at'] as String) ??
                            DateTime.now()
                      : (r.data['created_at'] as DateTime? ?? DateTime.now()),
                ),
              )
              .toList();
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

  double _toDouble(dynamic v) {
    if (v is int) return v.toDouble();
    if (v is double) return v;
    return 0.0;
  }

  String _periodLabel(AppLocalizations l10n) {
    switch (_period) {
      case 'week':
        return l10n.thisWeek;
      case 'month':
        return l10n.thisMonth;
      case 'quarter':
        return l10n.reportThisQuarter;
      case 'year':
        return l10n.reportThisYear;
      default:
        return l10n.thisMonth;
    }
  }

  Future<pw.Document> _buildReportPdf() async {
    final l10n = AppLocalizations.of(context);
    final pdf = await PdfFontHelper.createDocument();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              l10n.reportPurchaseTitle,
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Text(_periodLabel(l10n)),
            pw.Divider(),
            _pdfSummaryRow(l10n.totalPurchases, '${_totalPurchases.toStringAsFixed(0)} ${l10n.currency}'),
            _pdfSummaryRow(l10n.invoices, '$_invoiceCount'),
            _pdfSummaryRow(l10n.averageInvoice, '${_avgInvoice.toStringAsFixed(0)} ${l10n.currency}'),
            _pdfSummaryRow(l10n.reportTotalTax, '${_totalTax.toStringAsFixed(0)} ${l10n.currency}'),
            pw.Divider(),
            if (_bySupplier.isNotEmpty) ...[
              pw.Text(
                l10n.reportPurchasesBySupplier,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 5),
              ..._bySupplier.map(
                (s) => pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(s.name),
                    pw.Text('${s.total.toStringAsFixed(0)} ${l10n.currency}'),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
    return pdf;
  }

  pw.Widget _pdfSummaryRow(String label, String value) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 2),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [pw.Text(label), pw.Text(value)],
        ),
      );

  Future<void> _exportCsv() async {
    final l10n = AppLocalizations.of(context);
    final rows = <List<dynamic>>[
      [l10n.totalPurchases, _totalPurchases.toStringAsFixed(2)],
      [l10n.invoices, '$_invoiceCount'],
      [l10n.averageInvoice, _avgInvoice.toStringAsFixed(2)],
      [l10n.reportTotalTax, _totalTax.toStringAsFixed(2)],
    ];
    for (final s in _bySupplier) {
      rows.add([s.name, s.total.toStringAsFixed(2)]);
    }
    final result = await CsvExportHelper.exportAndShare(
      context: context,
      fileName: l10n.reportPurchaseTitle,
      headers: [l10n.reportIndicator, l10n.currency],
      rows: rows,
    );
    if (mounted) CsvExportHelper.showResultSnackBar(context, result);
  }

  Future<void> _sharePdf() async {
    final pdf = await _buildReportPdf();
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'purchases_${DateTime.now().toIso8601String().split('T').first}.pdf',
    );
  }

  Future<void> _printReport() async {
    final pdf = await _buildReportPdf();
    await Printing.layoutPdf(
      onLayout: (_) => pdf.save(),
      name: 'purchases_${DateTime.now().toIso8601String().split('T').first}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.reportPurchaseTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.reportPurchaseTitle)),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: AlhaiColors.error),
              const SizedBox(height: AlhaiSpacing.sm),
              Text(
                _error == 'store_not_selected'
                    ? l10n.storeNotSelected
                    : _error!,
              ),
              const SizedBox(height: AlhaiSpacing.sm),
              ElevatedButton(
                onPressed: _loadData,
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reportPurchaseTitle),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) {
              setState(() => _period = v);
              _loadData();
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'week', child: Text(l10n.thisWeek)),
              PopupMenuItem(value: 'month', child: Text(l10n.thisMonth)),
              PopupMenuItem(value: 'quarter', child: Text(l10n.reportQuarterly)),
              PopupMenuItem(value: 'year', child: Text(l10n.reportAnnual)),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.md),
              child: Row(
                children: [
                  Text(_periodLabel(l10n)),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: l10n.shareAction,
            onPressed: _sharePdf,
          ),
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: l10n.exportCsv,
            onPressed: _exportCsv,
          ),
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: l10n.printAction,
            onPressed: _printReport,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(AlhaiSpacing.md),
          children: [
            // Summary cards
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    label: l10n.totalPurchases,
                    value: '${_totalPurchases.toStringAsFixed(0)} ${l10n.currency}',
                    icon: Icons.shopping_cart_rounded,
                    color: AlhaiColors.info,
                  ),
                ),
                const SizedBox(width: AlhaiSpacing.sm),
                Expanded(
                  child: _SummaryCard(
                    label: l10n.invoices,
                    value: _invoiceCount.toString(),
                    icon: Icons.receipt_long_rounded,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AlhaiSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    label: l10n.averageInvoice,
                    value: '${_avgInvoice.toStringAsFixed(0)} ${l10n.currency}',
                    icon: Icons.calculate_rounded,
                    color: AlhaiColors.success,
                  ),
                ),
                const SizedBox(width: AlhaiSpacing.sm),
                Expanded(
                  child: _SummaryCard(
                    label: l10n.reportTotalTax,
                    value: '${_totalTax.toStringAsFixed(0)} ${l10n.currency}',
                    icon: Icons.percent_rounded,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AlhaiSpacing.mdl),

            // By supplier
            if (_bySupplier.isNotEmpty) ...[
              Text(
                l10n.reportPurchasesBySupplier,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AlhaiSpacing.xs),
              Card(
                child: Column(
                  children: _bySupplier.map((s) {
                    final pct = _totalPurchases > 0
                        ? s.total / _totalPurchases
                        : 0.0;
                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 18,
                        backgroundColor: AlhaiColors.info.withValues(
                          alpha: 0.1,
                        ),
                        child: Icon(
                          Icons.business_rounded,
                          size: 16,
                          color: AlhaiColors.info,
                        ),
                      ),
                      title: Text(
                        s.name,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: LinearProgressIndicator(
                        value: pct.toDouble(),
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerLow,
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${s.total.toStringAsFixed(0)} ${l10n.currency}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            l10n.reportNInvoices(s.count),
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: AlhaiSpacing.mdl),
            ],

            // Recent purchases
            if (_recent.isNotEmpty) ...[
              Text(
                l10n.reportRecentInvoices,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AlhaiSpacing.xs),
              Card(
                child: Column(
                  children: _recent
                      .map(
                        (p) => ListTile(
                          dense: true,
                          leading: Icon(
                            Icons.receipt_rounded,
                            color: AlhaiColors.info,
                          ),
                          title: Text(
                            '${p.invoiceNumber} - ${p.supplier}',
                            style: const TextStyle(fontSize: 13),
                          ),
                          subtitle: Text(
                            '${p.date.day}/${p.date.month}/${p.date.year}',
                            style: const TextStyle(fontSize: 11),
                          ),
                          trailing: Text(
                            '${p.total.toStringAsFixed(0)} ${l10n.currency}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AlhaiColors.info,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],

            if (_invoiceCount == 0)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(AlhaiSpacing.xl),
                  child: Column(
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 64,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: AlhaiSpacing.sm),
                      Text(
                        l10n.reportNoPurchasesInPeriod,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
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
        padding: const EdgeInsets.all(AlhaiSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: AlhaiSpacing.xs),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
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
  const _SupplierPurchase({
    required this.name,
    required this.count,
    required this.total,
  });
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
