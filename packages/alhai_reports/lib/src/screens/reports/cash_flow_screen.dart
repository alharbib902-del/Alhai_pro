import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../utils/csv_export_helper.dart';
import '../../utils/pdf_font_helper.dart';

/// Cash Flow Statement screen with full l10n support
class CashFlowScreen extends ConsumerStatefulWidget {
  const CashFlowScreen({super.key});

  @override
  ConsumerState<CashFlowScreen> createState() => _CashFlowScreenState();
}

class _CashFlowScreenState extends ConsumerState<CashFlowScreen> {
  String _period = 'month';
  bool _isLoading = true;
  String? _error;

  // Operating
  double _salesReceipts = 0;
  double _expensesPaid = 0;
  double _taxesPaid = 0;

  // Investing
  double _purchasesPaid = 0;

  // Financing
  double _cashIn = 0;
  double _cashOut = 0;

  double get _operatingNet => _salesReceipts - _expensesPaid - _taxesPaid;
  double get _investingNet => -_purchasesPaid;
  double get _financingNet => _cashIn - _cashOut;
  double get _netCashFlow => _operatingNet + _investingNet + _financingNet;

  ({DateTime start, DateTime end}) _getDateRange() {
    final now = DateTime.now();
    switch (_period) {
      case 'week':
        final s = now.subtract(Duration(days: now.weekday - 1));
        return (start: DateTime(s.year, s.month, s.day), end: now);
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

      // Cash from sales
      final salesResult = await db
          .customSelect(
            '''SELECT COALESCE(SUM(total), 0) as total
           FROM sales
           WHERE store_id = ? AND status = 'completed'
             AND created_at >= ? AND created_at < ?''',
            variables: [
              Variable.withString(storeId),
              Variable.withDateTime(dr.start),
              Variable.withDateTime(dr.end),
            ],
          )
          .getSingle();

      // Expenses paid
      final expResult = await db
          .customSelect(
            '''SELECT COALESCE(SUM(amount), 0) as total
           FROM expenses
           WHERE store_id = ? AND created_at >= ? AND created_at < ?''',
            variables: [
              Variable.withString(storeId),
              Variable.withDateTime(dr.start),
              Variable.withDateTime(dr.end),
            ],
          )
          .getSingle();

      // Taxes paid
      final taxResult = await db
          .customSelect(
            '''SELECT COALESCE(SUM(tax), 0) as total
           FROM sales
           WHERE store_id = ? AND status = 'completed'
             AND created_at >= ? AND created_at < ?''',
            variables: [
              Variable.withString(storeId),
              Variable.withDateTime(dr.start),
              Variable.withDateTime(dr.end),
            ],
          )
          .getSingle();

      // Purchases paid
      final purchResult = await db
          .customSelect(
            '''SELECT COALESCE(SUM(total), 0) as total
           FROM purchases
           WHERE store_id = ? AND created_at >= ? AND created_at < ?''',
            variables: [
              Variable.withString(storeId),
              Variable.withDateTime(dr.start),
              Variable.withDateTime(dr.end),
            ],
          )
          .getSingle();

      // Cash movements
      final cashMovResult = await db
          .customSelect(
            '''SELECT
             COALESCE(SUM(CASE WHEN type = 'cash_in' THEN amount ELSE 0 END), 0) as cash_in,
             COALESCE(SUM(CASE WHEN type = 'cash_out' THEN amount ELSE 0 END), 0) as cash_out
           FROM transactions
           WHERE store_id = ? AND created_at >= ? AND created_at < ?''',
            variables: [
              Variable.withString(storeId),
              Variable.withDateTime(dr.start),
              Variable.withDateTime(dr.end),
            ],
          )
          .getSingle();

      if (mounted) {
        setState(() {
          _salesReceipts = _toDouble(salesResult.data['total']);
          _expensesPaid = _toDouble(expResult.data['total']);
          _taxesPaid = _toDouble(taxResult.data['total']);
          _purchasesPaid = _toDouble(purchResult.data['total']);
          _cashIn = _toDouble(cashMovResult.data['cash_in']);
          _cashOut = _toDouble(cashMovResult.data['cash_out']);
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
              l10n.reportCashFlowTitle,
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Text(_periodLabel(l10n)),
            pw.Divider(),
            pw.Text(
              l10n.reportOperatingActivities,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            _pdfRow(l10n.reportSalesReceipts, _salesReceipts),
            _pdfRow(l10n.reportExpensesPaid, -_expensesPaid),
            _pdfRow(l10n.reportTaxesPaidVat, -_taxesPaid),
            pw.Divider(),
            pw.Text(
              l10n.reportInvestingActivities,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            _pdfRow(l10n.reportPurchasePayments, -_purchasesPaid),
            pw.Divider(),
            pw.Text(
              l10n.reportFinancingActivities,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            _pdfRow(l10n.reportCashDeposit, _cashIn),
            _pdfRow(l10n.reportCashWithdrawal, -_cashOut),
            pw.Divider(),
            _pdfRow(l10n.reportNetCashFlow, _netCashFlow, bold: true),
          ],
        ),
      ),
    );
    return pdf;
  }

  pw.Widget _pdfRow(String label, double amount, {bool bold = false}) {
    final style = bold ? pw.TextStyle(fontWeight: pw.FontWeight.bold) : null;
    final l10n = AppLocalizations.of(context);
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: style),
          pw.Text(
            '${amount.toStringAsFixed(0)} ${l10n.currency}',
            style: style,
          ),
        ],
      ),
    );
  }

  Future<void> _exportCsv() async {
    final l10n = AppLocalizations.of(context);
    final result = await CsvExportHelper.exportAndShare(
      context: context,
      fileName: l10n.reportCashFlowTitle,
      headers: [l10n.reportIndicator, l10n.currency],
      rows: [
        [l10n.reportSalesReceipts, _salesReceipts.toStringAsFixed(2)],
        [l10n.reportExpensesPaid, (-_expensesPaid).toStringAsFixed(2)],
        [l10n.reportTaxesPaidVat, (-_taxesPaid).toStringAsFixed(2)],
        [l10n.reportPurchasePayments, (-_purchasesPaid).toStringAsFixed(2)],
        [l10n.reportCashDeposit, _cashIn.toStringAsFixed(2)],
        [l10n.reportCashWithdrawal, (-_cashOut).toStringAsFixed(2)],
        [l10n.reportNetCashFlow, _netCashFlow.toStringAsFixed(2)],
      ],
    );
    if (mounted) CsvExportHelper.showResultSnackBar(context, result);
  }

  Future<void> _sharePdf() async {
    final pdf = await _buildReportPdf();
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename:
          'cash_flow_${DateTime.now().toIso8601String().split('T').first}.pdf',
    );
  }

  Future<void> _printReport() async {
    final pdf = await _buildReportPdf();
    await Printing.layoutPdf(
      onLayout: (_) => pdf.save(),
      name: 'cash_flow_${DateTime.now().toIso8601String().split('T').first}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.reportCashFlowTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.reportCashFlowTitle)),
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
              ElevatedButton(onPressed: _loadData, child: Text(l10n.retry)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reportCashFlowTitle),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) {
              setState(() => _period = v);
              _loadData();
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'week', child: Text(l10n.thisWeek)),
              PopupMenuItem(value: 'month', child: Text(l10n.thisMonth)),
              PopupMenuItem(
                value: 'quarter',
                child: Text(l10n.reportQuarterly),
              ),
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
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: ListView(
            padding: const EdgeInsets.all(AlhaiSpacing.md),
            children: [
              // Net cash flow card
              _NetCard(
                label: l10n.reportNetCashFlow,
                amount: _netCashFlow,
                isPositive: _netCashFlow >= 0,
                currency: l10n.currency,
              ),
              const SizedBox(height: AlhaiSpacing.mdl),

              // Operating activities
              _ActivitySection(
                title: l10n.reportOperatingActivities,
                icon: Icons.storefront_rounded,
                color: AlhaiColors.info,
                netAmount: _operatingNet,
                isDark: isDark,
                currency: l10n.currency,
                rows: [
                  _FlowRow(
                    label: l10n.reportSalesReceipts,
                    amount: _salesReceipts,
                    isInflow: true,
                  ),
                  _FlowRow(
                    label: l10n.reportExpensesPaid,
                    amount: -_expensesPaid,
                    isInflow: false,
                  ),
                  _FlowRow(
                    label: l10n.reportTaxesPaidVat,
                    amount: -_taxesPaid,
                    isInflow: false,
                  ),
                ],
              ),
              const SizedBox(height: AlhaiSpacing.md),

              // Investing activities
              _ActivitySection(
                title: l10n.reportInvestingActivities,
                icon: Icons.trending_up_rounded,
                color: Colors.orange,
                netAmount: _investingNet,
                isDark: isDark,
                currency: l10n.currency,
                rows: [
                  _FlowRow(
                    label: l10n.reportPurchasePayments,
                    amount: -_purchasesPaid,
                    isInflow: false,
                  ),
                ],
              ),
              const SizedBox(height: AlhaiSpacing.md),

              // Financing activities
              _ActivitySection(
                title: l10n.reportFinancingActivities,
                icon: Icons.account_balance_rounded,
                color: AlhaiColors.success,
                netAmount: _financingNet,
                isDark: isDark,
                currency: l10n.currency,
                rows: [
                  _FlowRow(
                    label: l10n.reportCashDeposit,
                    amount: _cashIn,
                    isInflow: true,
                  ),
                  _FlowRow(
                    label: l10n.reportCashWithdrawal,
                    amount: -_cashOut,
                    isInflow: false,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NetCard extends StatelessWidget {
  final String label;
  final double amount;
  final bool isPositive;
  final String currency;

  const _NetCard({
    required this.label,
    required this.amount,
    required this.isPositive,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final color = isPositive ? AlhaiColors.successDark : AlhaiColors.errorDark;
    final bg = isPositive
        ? AlhaiColors.success.withValues(alpha: 0.1)
        : AlhaiColors.error.withValues(alpha: 0.1);
    return Card(
      color: bg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AlhaiSpacing.mdl),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AlhaiSpacing.xs),
            Text(
              '${isPositive ? '+' : ''}${amount.toStringAsFixed(0)} $currency',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Icon(
              isPositive
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              color: color,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivitySection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final double netAmount;
  final bool isDark;
  final String currency;
  final List<_FlowRow> rows;

  const _ActivitySection({
    required this.title,
    required this.icon,
    required this.color,
    required this.netAmount,
    required this.isDark,
    required this.currency,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AlhaiSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: AlhaiSpacing.xs),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${netAmount >= 0 ? '+' : ''}${netAmount.toStringAsFixed(0)} $currency',
                    style: TextStyle(
                      color: netAmount >= 0 ? color : AlhaiColors.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            ...rows.map(
              (row) => Padding(
                padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xxs),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          row.isInflow
                              ? Icons.add_circle_outline
                              : Icons.remove_circle_outline,
                          size: 14,
                          color: row.isInflow
                              ? AlhaiColors.success
                              : AlhaiColors.error,
                        ),
                        const SizedBox(width: 6),
                        Text(row.label, style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                    Text(
                      '${row.amount >= 0 ? '+' : ''}${row.amount.toStringAsFixed(0)} $currency',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: row.amount >= 0
                            ? AlhaiColors.successDark
                            : AlhaiColors.errorDark,
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

class _FlowRow {
  final String label;
  final double amount;
  final bool isInflow;
  const _FlowRow({
    required this.label,
    required this.amount,
    required this.isInflow,
  });
}
