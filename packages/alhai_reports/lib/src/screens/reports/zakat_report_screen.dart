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

/// Zakat Calculation screen with full l10n support
class ZakatReportScreen extends ConsumerStatefulWidget {
  const ZakatReportScreen({super.key});

  @override
  ConsumerState<ZakatReportScreen> createState() => _ZakatReportScreenState();
}

class _ZakatReportScreenState extends ConsumerState<ZakatReportScreen> {
  bool _isLoading = true;
  String? _error;

  // Zakat base components
  double _inventoryValue = 0;
  double _cashBalance = 0;
  double _accountsReceivable = 0;
  double _accountsPayable = 0;
  double _otherLiabilities = 0;

  // Nisab (as of approximate gold rate in SAR)
  static const double _nisabSar = 5950.0; // ~85g gold x ~70 SAR/g
  static const double _zakatRate = 0.025; // 2.5%

  double get _zakatableAssets =>
      _inventoryValue + _cashBalance + _accountsReceivable;
  double get _zakatableDeductions => _accountsPayable + _otherLiabilities;
  double get _netZakatBase =>
      (_zakatableAssets - _zakatableDeductions).clamp(0.0, double.infinity);
  double get _zakatDue =>
      _netZakatBase >= _nisabSar ? _netZakatBase * _zakatRate : 0;
  bool get _aboveNisab => _netZakatBase >= _nisabSar;

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

      // Inventory value
      final invResult = await db.customSelect(
        '''SELECT COALESCE(SUM(current_stock * COALESCE(cost_price, price * 0.7)), 0) as total
           FROM products WHERE store_id = ? AND current_stock > 0''',
        variables: [Variable.withString(storeId)],
      ).getSingle();

      // Cash balance
      final cashResult = await db.customSelect(
        '''SELECT COALESCE(SUM(CASE WHEN type IN ('sale','cash_in') THEN amount ELSE -amount END), 0) as cash
           FROM transactions WHERE store_id = ?''',
        variables: [Variable.withString(storeId)],
      ).getSingle();

      // Receivables
      final recResult = await db.customSelect(
        '''SELECT COALESCE(SUM(balance), 0) as total
           FROM accounts WHERE store_id = ? AND type = 'receivable' AND balance > 0''',
        variables: [Variable.withString(storeId)],
      ).getSingle();

      // Payables
      final payResult = await db.customSelect(
        '''SELECT COALESCE(SUM(balance), 0) as total
           FROM accounts WHERE store_id = ? AND type = 'payable' AND balance > 0''',
        variables: [Variable.withString(storeId)],
      ).getSingle();

      if (mounted) {
        setState(() {
          _inventoryValue = _toDouble(invResult.data['total']);
          _cashBalance = _toDouble(
            cashResult.data['cash'],
          ).clamp(0.0, double.infinity);
          _accountsReceivable = _toDouble(recResult.data['total']);
          _accountsPayable = _toDouble(payResult.data['total']);
          _otherLiabilities = 0;
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
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              l10n.reportZakatTitle,
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.Divider(),
            pw.Text(
              l10n.reportZakatAssets,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            _pdfRow(l10n.reportGoodsAndInventory, _inventoryValue),
            _pdfRow(l10n.reportAvailableCash, _cashBalance),
            _pdfRow(l10n.reportExpectedReceivables, _accountsReceivable),
            pw.Divider(),
            pw.Text(
              l10n.reportDeductions,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            _pdfRow(l10n.reportDebtsToSuppliers, _accountsPayable),
            _pdfRow(l10n.reportOtherLiabilities, _otherLiabilities),
            pw.Divider(),
            _pdfRow(l10n.reportNetZakatBase, _netZakatBase, bold: true),
            pw.SizedBox(height: 10),
            if (_aboveNisab)
              pw.Text(
                '${l10n.reportZakatDue}: ${_zakatDue.toStringAsFixed(2)} ${l10n.currency}',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 14,
                ),
              )
            else
              pw.Text(l10n.reportZakatBelowNisab),
            pw.SizedBox(height: 10),
            pw.Text(
              l10n.reportZakatDisclaimer,
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            ),
          ],
        ),
      ),
    );
    return pdf;
  }

  pw.Widget _pdfRow(String label, double amount, {bool bold = false}) {
    final l10n = AppLocalizations.of(context);
    final style = bold ? pw.TextStyle(fontWeight: pw.FontWeight.bold) : null;
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
      fileName: l10n.reportZakatTitle,
      headers: [l10n.reportIndicator, l10n.currency],
      rows: [
        [l10n.reportGoodsAndInventory, _inventoryValue.toStringAsFixed(2)],
        [l10n.reportAvailableCash, _cashBalance.toStringAsFixed(2)],
        [
          l10n.reportExpectedReceivables,
          _accountsReceivable.toStringAsFixed(2),
        ],
        [l10n.reportDebtsToSuppliers, _accountsPayable.toStringAsFixed(2)],
        [l10n.reportOtherLiabilities, _otherLiabilities.toStringAsFixed(2)],
        [l10n.reportNetZakatBase, _netZakatBase.toStringAsFixed(2)],
        [l10n.reportZakatDue, _zakatDue.toStringAsFixed(2)],
      ],
    );
    if (mounted) CsvExportHelper.showResultSnackBar(context, result);
  }

  Future<void> _sharePdf() async {
    final pdf = await _buildReportPdf();
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename:
          'zakat_${DateTime.now().toIso8601String().split('T').first}.pdf',
    );
  }

  Future<void> _printReport() async {
    final pdf = await _buildReportPdf();
    await Printing.layoutPdf(
      onLayout: (_) => pdf.save(),
      name: 'zakat_${DateTime.now().toIso8601String().split('T').first}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.reportZakatTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.reportZakatTitle)),
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
              TextButton(onPressed: _loadData, child: Text(l10n.retry)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reportZakatTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadData,
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
      body: ListView(
        padding: const EdgeInsets.all(AlhaiSpacing.md),
        children: [
          // Zakat result card
          Card(
            color: _aboveNisab
                ? AlhaiColors.success.withValues(alpha: 0.08)
                : AlhaiColors.info.withValues(alpha: 0.08),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: _aboveNisab
                    ? AlhaiColors.success.withValues(alpha: 0.7)
                    : AlhaiColors.info.withValues(alpha: 0.7),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AlhaiSpacing.lg),
              child: Column(
                children: [
                  Icon(
                    Icons.mosque_rounded,
                    size: 48,
                    color: _aboveNisab ? AlhaiColors.success : AlhaiColors.info,
                  ),
                  const SizedBox(height: AlhaiSpacing.sm),
                  Text(
                    _aboveNisab
                        ? l10n.reportZakatDue
                        : l10n.reportZakatBelowNisab,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _aboveNisab
                          ? AlhaiColors.successDark
                          : AlhaiColors.infoDark,
                    ),
                  ),
                  if (_aboveNisab) ...[
                    const SizedBox(height: AlhaiSpacing.xs),
                    Text(
                      l10n.reportZakatAmountDue,
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: AlhaiSpacing.xxs),
                    Text(
                      '${_zakatDue.toStringAsFixed(2)} ${l10n.currency}',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AlhaiColors.successDark,
                      ),
                    ),
                    Text(
                      l10n.reportZakatRateOf(
                        (_zakatRate * 100).toStringAsFixed(1),
                      ),
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: AlhaiSpacing.xs),
                    Text(
                      l10n.reportNisabThreshold(_nisabSar.toStringAsFixed(0)),
                      style: TextStyle(color: AlhaiColors.infoDark),
                    ),
                    Text(
                      l10n.reportCurrentZakatBase(
                        _netZakatBase.toStringAsFixed(0),
                      ),
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.mdl),

          // Nisab info
          Card(
            color: isDark ? const Color(0xFF1E293B) : Colors.amber.shade50,
            child: Padding(
              padding: const EdgeInsets.all(AlhaiSpacing.sm),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.amber.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: AlhaiSpacing.xs),
                  Expanded(
                    child: Text(
                      l10n.reportNisabInfo(_nisabSar.toStringAsFixed(0)),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.amber.shade200
                            : Colors.amber.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.mdl),

          // Zakat base calculation
          Text(
            l10n.reportZakatAssets,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AlhaiSpacing.xs),
          _ZakatLine(
            label: l10n.reportGoodsAndInventory,
            amount: _inventoryValue,
            isAddition: true,
            isDark: isDark,
            currency: l10n.currency,
          ),
          _ZakatLine(
            label: l10n.reportAvailableCash,
            amount: _cashBalance,
            isAddition: true,
            isDark: isDark,
            currency: l10n.currency,
          ),
          _ZakatLine(
            label: l10n.reportExpectedReceivables,
            amount: _accountsReceivable,
            isAddition: true,
            isDark: isDark,
            currency: l10n.currency,
          ),

          const SizedBox(height: AlhaiSpacing.sm),
          Text(
            l10n.reportDeductions,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AlhaiSpacing.xs),
          _ZakatLine(
            label: l10n.reportDebtsToSuppliers,
            amount: _accountsPayable,
            isAddition: false,
            isDark: isDark,
            currency: l10n.currency,
          ),
          _ZakatLine(
            label: l10n.reportOtherLiabilities,
            amount: _otherLiabilities,
            isAddition: false,
            isDark: isDark,
            currency: l10n.currency,
          ),

          const SizedBox(height: AlhaiSpacing.md),
          const Divider(thickness: 2),
          const SizedBox(height: AlhaiSpacing.xs),

          // Net zakat base
          Container(
            padding: const EdgeInsets.all(AlhaiSpacing.md),
            decoration: BoxDecoration(
              color: AlhaiColors.info.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.reportNetZakatBase,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  '${_netZakatBase.toStringAsFixed(0)} ${l10n.currency}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AlhaiColors.info,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xs),

          // Zakat calculation
          if (_aboveNisab)
            Container(
              padding: const EdgeInsets.all(AlhaiSpacing.md),
              decoration: BoxDecoration(
                color: AlhaiColors.success.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_netZakatBase.toStringAsFixed(0)} x ${(_zakatRate * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(fontSize: 13),
                      ),
                      Text(
                        '${_zakatDue.toStringAsFixed(2)} ${l10n.currency}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AlhaiColors.successDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AlhaiSpacing.xs),
                  Text(
                    l10n.reportZakatDisclaimer,
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ZakatLine extends StatelessWidget {
  final String label;
  final double amount;
  final bool isAddition;
  final bool isDark;
  final String currency;

  const _ZakatLine({
    required this.label,
    required this.amount,
    required this.isAddition,
    required this.isDark,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final color = isAddition ? AlhaiColors.successDark : AlhaiColors.errorDark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xxs),
      child: Row(
        children: [
          Icon(
            isAddition ? Icons.add_circle_outline : Icons.remove_circle_outline,
            size: 18,
            color: color,
          ),
          const SizedBox(width: AlhaiSpacing.xs),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
          Text(
            '${amount.toStringAsFixed(0)} $currency',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: color,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
