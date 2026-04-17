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

/// Balance Sheet screen with full l10n support
class BalanceSheetScreen extends ConsumerStatefulWidget {
  const BalanceSheetScreen({super.key});

  @override
  ConsumerState<BalanceSheetScreen> createState() => _BalanceSheetScreenState();
}

class _BalanceSheetScreenState extends ConsumerState<BalanceSheetScreen> {
  bool _isLoading = true;
  String? _error;

  // Assets
  double _cashInDrawer = 0;
  double _accountsReceivable = 0;
  double _inventoryValue = 0;

  // Liabilities
  double _accountsPayable = 0;

  double get _totalCurrentAssets =>
      _cashInDrawer + _accountsReceivable + _inventoryValue;
  double get _totalAssets => _totalCurrentAssets;
  double get _totalLiabilities => _accountsPayable;
  double get _equity => _totalAssets - _totalLiabilities;

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

      // Cash in drawer - sum of completed sales - expenses - payables
      final cashResult = await db
          .customSelect(
            '''SELECT COALESCE(SUM(CASE WHEN type IN ('sale','cash_in') THEN amount ELSE -amount END), 0) as cash
           FROM transactions WHERE store_id = ?''',
            variables: [Variable.withString(storeId)],
          )
          .getSingle();

      // Accounts receivable (customer debts)
      final receivables = await db
          .customSelect(
            '''SELECT COALESCE(SUM(balance), 0) as total
           FROM accounts WHERE store_id = ? AND type = 'receivable' AND balance > 0''',
            variables: [Variable.withString(storeId)],
          )
          .getSingle();

      // Inventory value
      final invResult = await db
          .customSelect(
            '''SELECT COALESCE(SUM(p.current_stock * COALESCE(p.cost_price, p.price * 0.7)), 0) as total
           FROM products p WHERE p.store_id = ? AND p.current_stock > 0''',
            variables: [Variable.withString(storeId)],
          )
          .getSingle();

      // Accounts payable (supplier debts)
      final payables = await db
          .customSelect(
            '''SELECT COALESCE(SUM(balance), 0) as total
           FROM accounts WHERE store_id = ? AND type = 'payable' AND balance > 0''',
            variables: [Variable.withString(storeId)],
          )
          .getSingle();

      if (mounted) {
        setState(() {
          _cashInDrawer = _toDouble(cashResult.data['cash']);
          _accountsReceivable = _toDouble(receivables.data['total']);
          _inventoryValue = _toDouble(invResult.data['total']);
          _accountsPayable = _toDouble(payables.data['total']);
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

  Future<pw.Document> _buildReportPdf() async {
    final l10n = AppLocalizations.of(context);
    final pdf = await PdfFontHelper.createDocument();
    final now = DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year}';
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              l10n.reportBalanceSheetTitle,
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Text(l10n.reportBalanceSheetAsOf(dateStr)),
            pw.Divider(),
            pw.SizedBox(height: 10),
            pw.Text(
              l10n.reportAssets,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            _pdfRow(l10n.reportCashInDrawer, _cashInDrawer),
            _pdfRow(l10n.reportAccountsReceivable, _accountsReceivable),
            _pdfRow(l10n.reportInventoryValue, _inventoryValue),
            pw.Divider(),
            _pdfRow(l10n.reportTotalAssets, _totalAssets, bold: true),
            pw.SizedBox(height: 10),
            pw.Text(
              l10n.reportLiabilities,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            _pdfRow(l10n.reportAccountsPayable, _accountsPayable),
            pw.Divider(),
            _pdfRow(l10n.reportTotalLiabilities, _totalLiabilities, bold: true),
            pw.SizedBox(height: 10),
            pw.Divider(),
            _pdfRow(l10n.reportNetEquity, _equity, bold: true),
          ],
        ),
      ),
    );
    return pdf;
  }

  pw.Widget _pdfRow(String label, double amount, {bool bold = false}) {
    final style = bold ? pw.TextStyle(fontWeight: pw.FontWeight.bold) : null;
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: style),
          pw.Text(
            '${amount.toStringAsFixed(0)} ${AppLocalizations.of(context).currency}',
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
      fileName: l10n.reportBalanceSheetTitle,
      headers: [l10n.reportIndicator, l10n.currency],
      rows: [
        [l10n.reportCashInDrawer, _cashInDrawer.toStringAsFixed(2)],
        [l10n.reportAccountsReceivable, _accountsReceivable.toStringAsFixed(2)],
        [l10n.reportInventoryValue, _inventoryValue.toStringAsFixed(2)],
        [l10n.reportTotalAssets, _totalAssets.toStringAsFixed(2)],
        [l10n.reportAccountsPayable, _accountsPayable.toStringAsFixed(2)],
        [l10n.reportTotalLiabilities, _totalLiabilities.toStringAsFixed(2)],
        [l10n.reportNetEquity, _equity.toStringAsFixed(2)],
      ],
    );
    if (mounted) CsvExportHelper.showResultSnackBar(context, result);
  }

  Future<void> _sharePdf() async {
    final pdf = await _buildReportPdf();
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename:
          'balance_sheet_${DateTime.now().toIso8601String().split('T').first}.pdf',
    );
  }

  Future<void> _printReport() async {
    final pdf = await _buildReportPdf();
    await Printing.layoutPdf(
      onLayout: (_) => pdf.save(),
      name:
          'balance_sheet_${DateTime.now().toIso8601String().split('T').first}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.reportBalanceSheetTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.reportBalanceSheetTitle)),
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

    final now = DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year}';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reportBalanceSheetTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadData,
            tooltip: l10n.refresh,
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
              // Date
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AlhaiSpacing.md,
                    vertical: AlhaiSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    l10n.reportBalanceSheetAsOf(dateStr),
                    style: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AlhaiSpacing.mdl),

              // ASSETS
              _SectionHeader(
                title: l10n.reportAssets,
                total: _totalAssets,
                color: AlhaiColors.info,
                icon: Icons.account_balance_wallet_rounded,
                currency: l10n.currency,
              ),
              const SizedBox(height: AlhaiSpacing.xs),
              _GroupCard(
                title: l10n.reportCurrentAssets,
                isDark: isDark,
                currency: l10n.currency,
                items: [
                  _LineItem(
                    label: l10n.reportCashInDrawer,
                    amount: _cashInDrawer,
                  ),
                  _LineItem(
                    label: l10n.reportAccountsReceivable,
                    amount: _accountsReceivable,
                  ),
                  _LineItem(
                    label: l10n.reportInventoryValue,
                    amount: _inventoryValue,
                  ),
                ],
                total: _totalCurrentAssets,
                totalLabel: l10n.reportTotalCurrentAssets,
              ),
              const SizedBox(height: AlhaiSpacing.sm),
              _TotalRow(
                label: l10n.reportTotalAssets,
                amount: _totalAssets,
                color: AlhaiColors.info,
                currency: l10n.currency,
              ),

              const SizedBox(height: AlhaiSpacing.mdl),
              const Divider(thickness: 2),
              const SizedBox(height: AlhaiSpacing.mdl),

              // LIABILITIES
              _SectionHeader(
                title: l10n.reportLiabilities,
                total: _totalLiabilities,
                color: AlhaiColors.error,
                icon: Icons.account_balance_rounded,
                currency: l10n.currency,
              ),
              const SizedBox(height: AlhaiSpacing.xs),
              _GroupCard(
                title: l10n.reportCurrentLiabilities,
                isDark: isDark,
                currency: l10n.currency,
                items: [
                  _LineItem(
                    label: l10n.reportAccountsPayable,
                    amount: _accountsPayable,
                  ),
                ],
                total: _totalLiabilities,
                totalLabel: l10n.reportTotalCurrentLiabilities,
              ),
              const SizedBox(height: AlhaiSpacing.sm),
              _TotalRow(
                label: l10n.reportTotalLiabilities,
                amount: _totalLiabilities,
                color: AlhaiColors.error,
                currency: l10n.currency,
              ),

              const SizedBox(height: AlhaiSpacing.mdl),
              const Divider(thickness: 2),
              const SizedBox(height: AlhaiSpacing.mdl),

              // EQUITY
              _SectionHeader(
                title: l10n.reportEquity,
                total: _equity,
                color: AlhaiColors.success,
                icon: Icons.trending_up_rounded,
                currency: l10n.currency,
              ),
              const SizedBox(height: AlhaiSpacing.xs),
              Card(
                color: _equity >= 0
                    ? AlhaiColors.success.withValues(alpha: 0.08)
                    : AlhaiColors.error.withValues(alpha: 0.08),
                child: Padding(
                  padding: const EdgeInsets.all(AlhaiSpacing.mdl),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.reportNetEquity,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_equity.toStringAsFixed(0)} ${l10n.currency}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _equity >= 0
                              ? AlhaiColors.successDark
                              : AlhaiColors.errorDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AlhaiSpacing.mdl),
              // Equation check
              Card(
                color: isDark
                    ? const Color(0xFF1E293B)
                    : theme.colorScheme.surfaceContainerLowest,
                child: Padding(
                  padding: const EdgeInsets.all(AlhaiSpacing.md),
                  child: Column(
                    children: [
                      Text(
                        l10n.reportAccountingEquation,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AlhaiSpacing.xs),
                      Text(
                        l10n.reportAssetsEqualsLiabilitiesPlusEquity,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: AlhaiSpacing.xxs),
                      Text(
                        '${_totalAssets.toStringAsFixed(0)} = '
                        '${_totalLiabilities.toStringAsFixed(0)} + '
                        '${_equity.toStringAsFixed(0)}',
                        style: TextStyle(
                          color:
                              (_totalAssets - _totalLiabilities - _equity)
                                      .abs() <
                                  1
                              ? AlhaiColors.success
                              : AlhaiColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

class _SectionHeader extends StatelessWidget {
  final String title;
  final double total;
  final Color color;
  final IconData icon;
  final String currency;

  const _SectionHeader({
    required this.title,
    required this.total,
    required this.color,
    required this.icon,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: AlhaiSpacing.xs),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const Spacer(),
        Text(
          '${total.toStringAsFixed(0)} $currency',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _GroupCard extends StatelessWidget {
  final String title;
  final bool isDark;
  final String currency;
  final List<_LineItem> items;
  final double total;
  final String totalLabel;

  const _GroupCard({
    required this.title,
    required this.isDark,
    required this.currency,
    required this.items,
    required this.total,
    required this.totalLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AlhaiSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const Divider(),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xxs),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item.label, style: const TextStyle(fontSize: 13)),
                    Text(
                      '${item.amount.toStringAsFixed(0)} $currency',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  totalLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${total.toStringAsFixed(0)} $currency',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
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

class _TotalRow extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final String currency;

  const _TotalRow({
    required this.label,
    required this.amount,
    required this.color,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AlhaiSpacing.md,
        vertical: AlhaiSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 15,
            ),
          ),
          Text(
            '${amount.toStringAsFixed(0)} $currency',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _LineItem {
  final String label;
  final double amount;
  const _LineItem({required this.label, required this.amount});
}
