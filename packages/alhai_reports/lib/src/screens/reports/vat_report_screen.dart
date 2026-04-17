import 'package:alhai_design_system/alhai_design_system.dart' show AlhaiSpacing;
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../utils/csv_export_helper.dart';
import '../../utils/pdf_font_helper.dart';

/// شاشة تقرير الضريبة VAT
class VatReportScreen extends ConsumerStatefulWidget {
  const VatReportScreen({super.key});

  @override
  ConsumerState<VatReportScreen> createState() => _VatReportScreenState();
}

class _VatReportScreenState extends ConsumerState<VatReportScreen> {
  DateTimeRange? _dateRange;
  bool _isLoading = true;
  String? _error;

  double _totalSales = 0;
  double _vatCollected = 0;
  double _totalPurchases = 0;
  double _vatPaid = 0;

  double get _netVat => _vatCollected - _vatPaid;

  @override
  void initState() {
    super.initState();
    _loadVatData();
  }

  Future<void> _loadVatData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final db = GetIt.I<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider) ?? kDefaultStoreId;

      final now = DateTime.now();
      final startDate = _dateRange?.start ?? DateTime(now.year, now.month, 1);
      final endDate = _dateRange?.end ?? now;

      final salesStats = await db.salesDao.getSalesStats(
        storeId,
        startDate: startDate,
        endDate: endDate,
      );
      _totalSales = salesStats.total;
      _vatCollected = _totalSales * 0.15;

      // Purchases not readily available, set to 0
      _totalPurchases = 0;
      _vatPaid = _totalPurchases * 0.15;

      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).vatReportTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: AppLocalizations.of(context).exportPdf,
            onPressed: _exportPdf,
          ),
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'CSV',
            onPressed: _exportCsv,
          ),
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: AppLocalizations.of(context).printAction,
            onPressed: _printReportPdf,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          final isDesktop = constraints.maxWidth >= 1200;
          final padding = isMobile
              ? 12.0
              : isDesktop
                  ? 24.0
                  : 16.0;

          return _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AlhaiSpacing.xl),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              size: 64,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                            const SizedBox(height: AlhaiSpacing.md),
                            Text(
                              AppLocalizations.of(context)
                                  .errorLoadingVatReport,
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AlhaiSpacing.md),
                            FilledButton.icon(
                              onPressed: _loadVatData,
                              icon: const Icon(Icons.refresh_rounded),
                              label: Text(
                                  AppLocalizations.of(context).retryAction),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: isDesktop ? 800 : double.infinity,
                        ),
                        child: ListView(
                          padding: EdgeInsets.all(padding),
                          children: [
                            // Date Range Selector
                            Card(
                              child: ListTile(
                                leading: const Icon(Icons.date_range),
                                title: Text(
                                  _dateRange == null
                                      ? AppLocalizations.of(context)
                                          .selectPeriod
                                      : '${_formatDate(_dateRange!.start)} - ${_formatDate(_dateRange!.end)}',
                                ),
                                trailing:
                                    const AdaptiveIcon(Icons.chevron_right),
                                onTap: _selectDateRange,
                              ),
                            ),
                            const SizedBox(height: AlhaiSpacing.md),

                            // Sales VAT
                            _VatCard(
                              title: AppLocalizations.of(context).salesVat,
                              icon: Icons.trending_up,
                              color: Colors.green,
                              items: [
                                _VatItem(
                                  AppLocalizations.of(context).totalSalesIncVat,
                                  _totalSales,
                                ),
                                _VatItem(
                                  AppLocalizations.of(context).vatCollected,
                                  _vatCollected,
                                  isVat: true,
                                ),
                              ],
                            ),
                            const SizedBox(height: AlhaiSpacing.sm),

                            // Purchases VAT
                            _VatCard(
                              title: AppLocalizations.of(context).purchasesVat,
                              icon: Icons.trending_down,
                              color: Colors.orange,
                              items: [
                                _VatItem(
                                  AppLocalizations.of(context)
                                      .totalPurchasesIncVat,
                                  _totalPurchases,
                                ),
                                _VatItem(
                                  AppLocalizations.of(context).vatPaid,
                                  _vatPaid,
                                  isVat: true,
                                ),
                              ],
                            ),
                            const SizedBox(height: AlhaiSpacing.md),

                            // Net VAT
                            Card(
                              color: _netVat >= 0
                                  ? Colors.green.withValues(alpha: 0.1)
                                  : Colors.red.withValues(alpha: 0.1),
                              child: Padding(
                                padding: const EdgeInsets.all(AlhaiSpacing.mdl),
                                child: Column(
                                  children: [
                                    Text(
                                      AppLocalizations.of(context).netVatDue,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: AlhaiSpacing.xs),
                                    Text(
                                      '${_netVat.toStringAsFixed(2)} ${AppLocalizations.of(context).sar}',
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: _netVat >= 0
                                            ? Colors.green.shade700
                                            : Colors.red.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: AlhaiSpacing.xs),
                                    Text(
                                      _netVat >= 0
                                          ? AppLocalizations.of(
                                              context,
                                            ).dueToAuthority
                                          : AppLocalizations.of(
                                              context,
                                            ).dueFromAuthority,
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: AlhaiSpacing.lg),

                            // Actions
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            AppLocalizations.of(
                                              context,
                                            ).exportingPdfReport,
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.print),
                                    label: Text(
                                      AppLocalizations.of(context).printAction,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AlhaiSpacing.sm),
                                Expanded(
                                  child: FilledButton.icon(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text(
                                            'إرسال للهيئة الزكاة والضريبة',
                                          ),
                                          content: const Text(
                                            'سيتم إرسال بيانات الفوترة الإلكترونية للهيئة. تأكد من صحة بياناتك أولاً.',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx),
                                              child: const Text('إلغاء'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(ctx);
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
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
                                    label: Text(
                                      AppLocalizations.of(context)
                                          .sendToAuthority,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _selectDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );
    if (range != null) {
      setState(() {
        _dateRange = range;
        _isLoading = true;
      });
      _loadVatData();
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
              l10n.vatReportTitle,
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.Divider(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(l10n.totalSalesIncVat),
                pw.Text('${_totalSales.toStringAsFixed(2)} ${l10n.sar}'),
              ],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(l10n.vatCollected),
                pw.Text('${_vatCollected.toStringAsFixed(2)} ${l10n.sar}'),
              ],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(l10n.totalPurchasesIncVat),
                pw.Text('${_totalPurchases.toStringAsFixed(2)} ${l10n.sar}'),
              ],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(l10n.vatPaid),
                pw.Text('${_vatPaid.toStringAsFixed(2)} ${l10n.sar}'),
              ],
            ),
            pw.Divider(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  l10n.netVatDue,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  '${_netVat.toStringAsFixed(2)} ${l10n.sar}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    return pdf;
  }

  Future<void> _exportCsv() async {
    final l10n = AppLocalizations.of(context);
    final result = await CsvExportHelper.exportAndShare(
      context: context,
      fileName: l10n.vatReportTitle,
      headers: ['البند', 'المبلغ (${l10n.sar})'],
      rows: [
        [l10n.totalSalesIncVat, _totalSales.toStringAsFixed(2)],
        [l10n.vatCollected, _vatCollected.toStringAsFixed(2)],
        [l10n.totalPurchasesIncVat, _totalPurchases.toStringAsFixed(2)],
        [l10n.vatPaid, _vatPaid.toStringAsFixed(2)],
        [l10n.netVatDue, _netVat.toStringAsFixed(2)],
      ],
    );
    if (mounted) CsvExportHelper.showResultSnackBar(context, result);
  }

  Future<void> _exportPdf() async {
    final pdf = await _buildReportPdf();
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename:
          'vat_report_${DateTime.now().toIso8601String().split('T').first}.pdf',
    );
  }

  Future<void> _printReportPdf() async {
    final pdf = await _buildReportPdf();
    await Printing.layoutPdf(
      onLayout: (_) => pdf.save(),
      name: 'vat_report_${DateTime.now().toIso8601String().split('T').first}',
    );
  }
}

class _VatCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<_VatItem> items;

  const _VatCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
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
                Icon(icon, color: color),
                const SizedBox(width: AlhaiSpacing.xs),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const Divider(),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xs),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item.label),
                    Text(
                      '${item.amount.toStringAsFixed(2)} ${AppLocalizations.of(context).sar}',
                      style: TextStyle(
                        fontWeight:
                            item.isVat ? FontWeight.bold : FontWeight.normal,
                        color: item.isVat ? color : null,
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

class _VatItem {
  final String label;
  final double amount;
  final bool isVat;

  _VatItem(this.label, this.amount, {this.isVat = false});
}
