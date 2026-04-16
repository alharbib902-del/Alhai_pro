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

/// Debt Aging Report screen with full l10n support
class DebtAgingReportScreen extends ConsumerStatefulWidget {
  const DebtAgingReportScreen({super.key});

  @override
  ConsumerState<DebtAgingReportScreen> createState() =>
      _DebtAgingReportScreenState();
}

class _DebtAgingReportScreenState extends ConsumerState<DebtAgingReportScreen> {
  bool _isLoading = true;
  String? _error;
  List<_AgingEntry> _entries = [];
  double _total0_30 = 0;
  double _total31_60 = 0;
  double _total61_90 = 0;
  double _total90plus = 0;

  double get _grandTotal =>
      _total0_30 + _total31_60 + _total61_90 + _total90plus;

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

      final now = DateTime.now();

      final result = await db
          .customSelect(
            '''SELECT
             a.id,
             a.name,
             a.phone,
             a.balance,
             a.last_transaction_at,
             a.created_at
           FROM accounts a
           WHERE a.store_id = ?
             AND a.type = 'receivable'
             AND a.balance > 0
           ORDER BY a.balance DESC''',
            variables: [Variable.withString(storeId)],
          )
          .get();

      final entries = result.map((row) {
        final balance = _toDouble(row.data['balance']);
        final lastTxnStr = row.data['last_transaction_at'] as String?;
        final createdStr = row.data['created_at'] as String;
        final baseDate = lastTxnStr != null
            ? (DateTime.tryParse(lastTxnStr) ??
                  DateTime.tryParse(createdStr) ??
                  now)
            : (DateTime.tryParse(createdStr) ?? now);
        final days = now.difference(baseDate).inDays;

        String bucket;
        Color color;
        if (days <= 30) {
          bucket = '0-30';
          color = Colors.green;
        } else if (days <= 60) {
          bucket = '31-60';
          color = Colors.orange;
        } else if (days <= 90) {
          bucket = '61-90';
          color = Colors.deepOrange;
        } else {
          bucket = '90+';
          color = Colors.red;
        }

        return _AgingEntry(
          id: row.data['id'] as String,
          name: row.data['name'] as String,
          phone: row.data['phone'] as String? ?? '',
          balance: balance,
          days: days,
          bucket: bucket,
          color: color,
        );
      }).toList();

      double t0 = 0, t30 = 0, t60 = 0, t90 = 0;
      for (final e in entries) {
        if (e.days <= 30) {
          t0 += e.balance;
        } else if (e.days <= 60) {
          t30 += e.balance;
        } else if (e.days <= 90) {
          t60 += e.balance;
        } else {
          t90 += e.balance;
        }
      }

      if (mounted) {
        setState(() {
          _entries = entries;
          _total0_30 = t0;
          _total31_60 = t30;
          _total61_90 = t60;
          _total90plus = t90;
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

  String _bucketLabel(AppLocalizations l10n, String bucket) {
    switch (bucket) {
      case '0-30':
        return l10n.reportDebtBucket0to30;
      case '31-60':
        return l10n.reportDebtBucket31to60;
      case '61-90':
        return l10n.reportDebtBucket61to90;
      default:
        return l10n.reportDebtBucket90plus;
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
              l10n.reportDebtAgingTitle,
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.Divider(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(l10n.reportDebtBucket0to30),
                pw.Text('${_total0_30.toStringAsFixed(0)} ${l10n.currency}'),
              ],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(l10n.reportDebtBucket31to60),
                pw.Text('${_total31_60.toStringAsFixed(0)} ${l10n.currency}'),
              ],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(l10n.reportDebtBucket61to90),
                pw.Text('${_total61_90.toStringAsFixed(0)} ${l10n.currency}'),
              ],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(l10n.reportDebtBucket90plus),
                pw.Text('${_total90plus.toStringAsFixed(0)} ${l10n.currency}'),
              ],
            ),
            pw.Divider(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  l10n.reportTotalDebts,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  '${_grandTotal.toStringAsFixed(0)} ${l10n.currency}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            if (_entries.isNotEmpty) ...[
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.blueGrey700,
                    ),
                    children: [
                      _pdfHeaderCell(l10n.reportIndicator),
                      _pdfHeaderCell(l10n.currency),
                      _pdfHeaderCell(l10n.day),
                    ],
                  ),
                  ..._entries.take(30).map(
                    (e) => pw.TableRow(
                      children: [
                        _pdfCell(e.name),
                        _pdfCell('${e.balance.toStringAsFixed(0)} ${l10n.currency}'),
                        _pdfCell(l10n.reportNDays(e.days)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
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

  pw.Widget _pdfCell(String text) => pw.Padding(
        padding: const pw.EdgeInsets.all(5),
        child: pw.Text(text, style: const pw.TextStyle(fontSize: 9)),
      );

  Future<void> _exportCsv() async {
    final l10n = AppLocalizations.of(context);
    final result = await CsvExportHelper.exportAndShare(
      context: context,
      fileName: l10n.reportDebtAgingTitle,
      headers: [l10n.reportIndicator, l10n.currency, l10n.day],
      rows: _entries
          .map((e) => [e.name, e.balance.toStringAsFixed(2), '${e.days}'])
          .toList(),
    );
    if (mounted) CsvExportHelper.showResultSnackBar(context, result);
  }

  Future<void> _sharePdf() async {
    final pdf = await _buildReportPdf();
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'debt_aging_${DateTime.now().toIso8601String().split('T').first}.pdf',
    );
  }

  Future<void> _printReport() async {
    final pdf = await _buildReportPdf();
    await Printing.layoutPdf(
      onLayout: (_) => pdf.save(),
      name: 'debt_aging_${DateTime.now().toIso8601String().split('T').first}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.reportDebtAgingTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.reportDebtAgingTitle)),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: AlhaiSpacing.sm),
              Text(
                _error == 'store_not_selected'
                    ? l10n.storeNotSelected
                    : _error!,
              ),
              TextButton(
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
        title: Text(l10n.reportDebtAgingTitle),
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
      body: Column(
        children: [
          // Aging summary bands
          Container(
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.all(AlhaiSpacing.md),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _BucketCard(
                        label: l10n.reportDebtBucket0to30,
                        amount: _total0_30,
                        color: Colors.green,
                        pct: _grandTotal > 0 ? _total0_30 / _grandTotal : 0,
                        currency: l10n.currency,
                      ),
                    ),
                    const SizedBox(width: AlhaiSpacing.xs),
                    Expanded(
                      child: _BucketCard(
                        label: l10n.reportDebtBucket31to60,
                        amount: _total31_60,
                        color: Colors.orange,
                        pct: _grandTotal > 0 ? _total31_60 / _grandTotal : 0,
                        currency: l10n.currency,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AlhaiSpacing.xs),
                Row(
                  children: [
                    Expanded(
                      child: _BucketCard(
                        label: l10n.reportDebtBucket61to90,
                        amount: _total61_90,
                        color: Colors.deepOrange,
                        pct: _grandTotal > 0 ? _total61_90 / _grandTotal : 0,
                        currency: l10n.currency,
                      ),
                    ),
                    const SizedBox(width: AlhaiSpacing.xs),
                    Expanded(
                      child: _BucketCard(
                        label: l10n.reportDebtBucket90plus,
                        amount: _total90plus,
                        color: Colors.red,
                        pct: _grandTotal > 0 ? _total90plus / _grandTotal : 0,
                        currency: l10n.currency,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AlhaiSpacing.sm),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AlhaiSpacing.md,
                    vertical: AlhaiSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A8FE3), Color(0xFF0EC9C9)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.reportTotalDebts,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${_grandTotal.toStringAsFixed(0)} ${l10n.currency}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: _entries.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          size: 64,
                          color: Colors.green,
                        ),
                        const SizedBox(height: AlhaiSpacing.sm),
                        Text(
                          l10n.noOutstandingDebts,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(AlhaiSpacing.sm),
                    itemCount: _entries.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AlhaiSpacing.xxs),
                    itemBuilder: (ctx, i) {
                      final e = _entries[i];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: e.color.withValues(alpha: 0.15),
                            child: Text(
                              e.name.isNotEmpty ? e.name[0] : '?',
                              style: TextStyle(
                                color: e.color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            e.name,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: e.color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _bucketLabel(l10n, e.bucket),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: e.color,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                l10n.reportNDays(e.days),
                                style: const TextStyle(fontSize: 11),
                              ),
                            ],
                          ),
                          trailing: Text(
                            '${e.balance.toStringAsFixed(0)} ${l10n.currency}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: e.color,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _BucketCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final double pct;
  final String currency;

  const _BucketCard({
    required this.label,
    required this.amount,
    required this.color,
    required this.pct,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xxs),
          Text(
            '${amount.toStringAsFixed(0)} $currency',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xxs),
          LinearProgressIndicator(
            value: pct,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
          const SizedBox(height: AlhaiSpacing.xxxs),
          Text(
            '${(pct * 100).toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _AgingEntry {
  final String id;
  final String name;
  final String phone;
  final double balance;
  final int days;
  final String bucket;
  final Color color;
  const _AgingEntry({
    required this.id,
    required this.name,
    required this.phone,
    required this.balance,
    required this.days,
    required this.bucket,
    required this.color,
  });
}
