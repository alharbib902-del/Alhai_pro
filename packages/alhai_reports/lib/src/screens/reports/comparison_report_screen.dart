import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_design_system/alhai_design_system.dart' show AlhaiSpacing;
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../utils/csv_export_helper.dart';
import '../../utils/pdf_font_helper.dart';

/// Comparison Report screen with full l10n support
class ComparisonReportScreen extends ConsumerStatefulWidget {
  const ComparisonReportScreen({super.key});

  @override
  ConsumerState<ComparisonReportScreen> createState() =>
      _ComparisonReportScreenState();
}

class _ComparisonReportScreenState
    extends ConsumerState<ComparisonReportScreen> {
  String _compareMode = 'month'; // month, quarter, year
  bool _isLoading = true;
  String? _error;

  _PeriodData? _current;
  _PeriodData? _previous;

  ({DateTime start, DateTime end}) _getCurrent() {
    final now = DateTime.now();
    switch (_compareMode) {
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

  ({DateTime start, DateTime end}) _getPrevious() {
    final now = DateTime.now();
    switch (_compareMode) {
      case 'month':
        final prevMonth = now.month == 1 ? 12 : now.month - 1;
        final prevYear = now.month == 1 ? now.year - 1 : now.year;
        return (
          start: DateTime(prevYear, prevMonth, 1),
          end: DateTime(now.year, now.month, 1),
        );
      case 'quarter':
        final currentQStart = ((now.month - 1) ~/ 3) * 3 + 1;
        final prevQStart = currentQStart <= 3 ? 10 : currentQStart - 3;
        final prevYear = currentQStart <= 3 ? now.year - 1 : now.year;
        return (
          start: DateTime(prevYear, prevQStart, 1),
          end: DateTime(now.year, currentQStart, 1),
        );
      case 'year':
        return (
          start: DateTime(now.year - 1, 1, 1),
          end: DateTime(now.year, 1, 1),
        );
      default:
        final prevMonth = now.month == 1 ? 12 : now.month - 1;
        final prevYear = now.month == 1 ? now.year - 1 : now.year;
        return (
          start: DateTime(prevYear, prevMonth, 1),
          end: DateTime(now.year, now.month, 1),
        );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<_PeriodData> _fetchPeriod(
    AppDatabase db,
    String storeId,
    DateTime start,
    DateTime end,
  ) async {
    final salesResult = await db
        .customSelect(
          '''SELECT
           COUNT(*) as cnt,
           COALESCE(SUM(total), 0) as revenue,
           COALESCE(SUM(tax), 0) as tax
         FROM sales
         WHERE store_id = ? AND status = 'completed'
           AND created_at >= ? AND created_at < ?''',
          variables: [
            Variable.withString(storeId),
            Variable.withDateTime(start),
            Variable.withDateTime(end),
          ],
        )
        .getSingle();

    final purchResult = await db
        .customSelect(
          '''SELECT COALESCE(SUM(total), 0) as total
         FROM purchases WHERE store_id = ? AND created_at >= ? AND created_at < ?''',
          variables: [
            Variable.withString(storeId),
            Variable.withDateTime(start),
            Variable.withDateTime(end),
          ],
        )
        .getSingle();

    final expResult = await db
        .customSelect(
          '''SELECT COALESCE(SUM(amount), 0) as total
         FROM expenses WHERE store_id = ? AND created_at >= ? AND created_at < ?''',
          variables: [
            Variable.withString(storeId),
            Variable.withDateTime(start),
            Variable.withDateTime(end),
          ],
        )
        .getSingle();

    final revenue = _toDouble(salesResult.data['revenue']);
    final purchases = _toDouble(purchResult.data['total']);
    final expenses = _toDouble(expResult.data['total']);
    final tax = _toDouble(salesResult.data['tax']);
    final invoices = (salesResult.data['cnt'] as int?) ?? 0;
    final profit = revenue - purchases - expenses - tax;

    return _PeriodData(
      revenue: revenue,
      purchases: purchases,
      expenses: expenses,
      tax: tax,
      profit: profit,
      invoices: invoices,
    );
  }

  static double _toDouble(dynamic v) {
    if (v is int) return v.toDouble();
    if (v is double) return v;
    return 0.0;
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
      final cur = _getCurrent();
      final prev = _getPrevious();
      final curData = await _fetchPeriod(db, storeId, cur.start, cur.end);
      final prevData = await _fetchPeriod(db, storeId, prev.start, prev.end);
      if (mounted) {
        setState(() {
          _current = curData;
          _previous = prevData;
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

  String _currentLabel(AppLocalizations l10n) {
    switch (_compareMode) {
      case 'month':
        return l10n.thisMonth;
      case 'quarter':
        return l10n.reportThisQuarter;
      case 'year':
        return l10n.reportThisYear;
      default:
        return l10n.reportCurrentPeriod;
    }
  }

  String _previousLabel(AppLocalizations l10n) {
    switch (_compareMode) {
      case 'month':
        return l10n.reportLastMonth;
      case 'quarter':
        return l10n.reportLastQuarter;
      case 'year':
        return l10n.reportLastYear;
      default:
        return l10n.reportPreviousPeriod;
    }
  }

  Future<pw.Document> _buildReportPdf() async {
    final l10n = AppLocalizations.of(context);
    final cur = _current!;
    final prev = _previous!;
    final pdf = await PdfFontHelper.createDocument();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              l10n.reportComparisonTitle,
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.Divider(),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.blueGrey700,
                  ),
                  children: [
                    _pdfHeaderCell(l10n.reportIndicator),
                    _pdfHeaderCell(_currentLabel(l10n)),
                    _pdfHeaderCell(_previousLabel(l10n)),
                  ],
                ),
                _pdfDataRow(
                  l10n.sales,
                  cur.revenue,
                  prev.revenue,
                  l10n.currency,
                ),
                _pdfDataRow(
                  l10n.invoices,
                  cur.invoices.toDouble(),
                  prev.invoices.toDouble(),
                  '',
                  isCount: true,
                ),
                _pdfDataRow(
                  l10n.purchases,
                  cur.purchases,
                  prev.purchases,
                  l10n.currency,
                ),
                _pdfDataRow(
                  l10n.expenses,
                  cur.expenses,
                  prev.expenses,
                  l10n.currency,
                ),
                _pdfDataRow(l10n.tax, cur.tax, prev.tax, l10n.currency),
                _pdfDataRow(
                  l10n.netProfit,
                  cur.profit,
                  prev.profit,
                  l10n.currency,
                ),
              ],
            ),
          ],
        ),
      ),
    );
    return pdf;
  }

  pw.Widget _pdfHeaderCell(String text) => pw.Padding(
    padding: const pw.EdgeInsets.all(6),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        color: PdfColors.white,
        fontWeight: pw.FontWeight.bold,
        fontSize: 10,
      ),
    ),
  );

  pw.TableRow _pdfDataRow(
    String label,
    double current,
    double previous,
    String currency, {
    bool isCount = false,
  }) {
    final fmt = isCount
        ? (double v) => v.toStringAsFixed(0)
        : (double v) => '${v.toStringAsFixed(0)} $currency';
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(5),
          child: pw.Text(label, style: const pw.TextStyle(fontSize: 9)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(5),
          child: pw.Text(fmt(current), style: const pw.TextStyle(fontSize: 9)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(5),
          child: pw.Text(fmt(previous), style: const pw.TextStyle(fontSize: 9)),
        ),
      ],
    );
  }

  Future<void> _exportCsv() async {
    final l10n = AppLocalizations.of(context);
    final cur = _current!;
    final prev = _previous!;
    final result = await CsvExportHelper.exportAndShare(
      context: context,
      fileName: l10n.reportComparisonTitle,
      headers: [
        l10n.reportIndicator,
        _currentLabel(l10n),
        _previousLabel(l10n),
      ],
      rows: [
        [
          l10n.sales,
          cur.revenue.toStringAsFixed(2),
          prev.revenue.toStringAsFixed(2),
        ],
        [l10n.invoices, '${cur.invoices}', '${prev.invoices}'],
        [
          l10n.purchases,
          cur.purchases.toStringAsFixed(2),
          prev.purchases.toStringAsFixed(2),
        ],
        [
          l10n.expenses,
          cur.expenses.toStringAsFixed(2),
          prev.expenses.toStringAsFixed(2),
        ],
        [l10n.tax, cur.tax.toStringAsFixed(2), prev.tax.toStringAsFixed(2)],
        [
          l10n.netProfit,
          cur.profit.toStringAsFixed(2),
          prev.profit.toStringAsFixed(2),
        ],
      ],
    );
    if (mounted) CsvExportHelper.showResultSnackBar(context, result);
  }

  Future<void> _sharePdf() async {
    final pdf = await _buildReportPdf();
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename:
          'comparison_${DateTime.now().toIso8601String().split('T').first}.pdf',
    );
  }

  Future<void> _printReport() async {
    final pdf = await _buildReportPdf();
    await Printing.layoutPdf(
      onLayout: (_) => pdf.save(),
      name: 'comparison_${DateTime.now().toIso8601String().split('T').first}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.reportComparisonTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null || _current == null || _previous == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.reportComparisonTitle)),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: AlhaiSpacing.sm),
              Text(
                _error == 'store_not_selected'
                    ? l10n.storeNotSelected
                    : (_error ?? l10n.errorLoadingData),
              ),
              TextButton(onPressed: _loadData, child: Text(l10n.retry)),
            ],
          ),
        ),
      );
    }

    final cur = _current!;
    final prev = _previous!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reportComparisonTitle),
        actions: [
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
            child: SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'month', label: Text(l10n.monthly)),
                ButtonSegment(
                  value: 'quarter',
                  label: Text(l10n.reportQuarterly),
                ),
                ButtonSegment(value: 'year', label: Text(l10n.reportAnnual)),
              ],
              selected: {_compareMode},
              onSelectionChanged: (s) {
                setState(() => _compareMode = s.first);
                _loadData();
              },
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(AlhaiSpacing.md),
          children: [
            // Header labels
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    l10n.reportIndicator,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    _currentLabel(l10n),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    _previousLabel(l10n),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    l10n.reportChange,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20, thickness: 2),

            _CompRow(
              label: l10n.sales,
              current: cur.revenue,
              previous: prev.revenue,
              higherIsBetter: true,
              currency: l10n.currency,
            ),
            _CompRow(
              label: l10n.invoices,
              current: cur.invoices.toDouble(),
              previous: prev.invoices.toDouble(),
              higherIsBetter: true,
              isCount: true,
              currency: l10n.currency,
            ),
            _CompRow(
              label: l10n.purchases,
              current: cur.purchases,
              previous: prev.purchases,
              higherIsBetter: false,
              currency: l10n.currency,
            ),
            _CompRow(
              label: l10n.expenses,
              current: cur.expenses,
              previous: prev.expenses,
              higherIsBetter: false,
              currency: l10n.currency,
            ),
            _CompRow(
              label: l10n.tax,
              current: cur.tax,
              previous: prev.tax,
              higherIsBetter: false,
              currency: l10n.currency,
            ),
            const Divider(),
            _CompRow(
              label: l10n.netProfit,
              current: cur.profit,
              previous: prev.profit,
              higherIsBetter: true,
              bold: true,
              currency: l10n.currency,
            ),
          ],
        ),
      ),
    );
  }
}

class _CompRow extends StatelessWidget {
  final String label;
  final double current;
  final double previous;
  final bool higherIsBetter;
  final bool isCount;
  final bool bold;
  final String currency;

  const _CompRow({
    required this.label,
    required this.current,
    required this.previous,
    required this.higherIsBetter,
    required this.currency,
    this.isCount = false,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final change = previous != 0
        ? ((current - previous) / previous) * 100
        : (current != 0 ? 100.0 : 0.0);
    final isPositive = higherIsBetter ? change >= 0 : change <= 0;
    final changeColor = isPositive
        ? Colors.green.shade700
        : Colors.red.shade700;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xs),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                fontSize: bold ? 14 : 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              isCount
                  ? current.toStringAsFixed(0)
                  : '${current.toStringAsFixed(0)} $currency',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.w500,
                fontSize: bold ? 14 : 13,
                color: Colors.blue.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              isCount
                  ? previous.toStringAsFixed(0)
                  : '${previous.toStringAsFixed(0)} $currency',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  change >= 0
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  size: 14,
                  color: changeColor,
                ),
                Text(
                  '${change.abs().toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: changeColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodData {
  final double revenue;
  final double purchases;
  final double expenses;
  final double tax;
  final double profit;
  final int invoices;

  const _PeriodData({
    required this.revenue,
    required this.purchases,
    required this.expenses,
    required this.tax,
    required this.profit,
    required this.invoices,
  });
}
