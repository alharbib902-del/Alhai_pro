import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../data/local/app_database.dart';
import '../../di/injection.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/products_providers.dart';

/// شاشة تقرير الديون
class DebtsReportScreen extends ConsumerStatefulWidget {
  const DebtsReportScreen({super.key});

  @override
  ConsumerState<DebtsReportScreen> createState() => _DebtsReportScreenState();
}

class _DebtsReportScreenState extends ConsumerState<DebtsReportScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _debts = [];
  double _totalDebts = 0;
  String _sortBy = 'amount';

  @override
  void initState() {
    super.initState();
    _loadDebts();
  }

  Future<void> _loadDebts() async {
    setState(() => _isLoading = true);

    final storeId = ref.read(currentStoreIdProvider);
    if (storeId == null) {
      setState(() => _isLoading = false);
      return;
    }

    final db = getIt<AppDatabase>();
    final accounts = await db.accountsDao.getReceivableAccounts(storeId);

    if (mounted) {
      setState(() {
        _debts = accounts
            .where((a) => a.balance > 0)
            .map((a) => {
              'id': a.id,
              'name': a.name,
              'phone': a.phone,
              'balance': a.balance,
              'lastPayment': a.lastTransactionAt ?? a.createdAt,
            })
            .toList();

        _totalDebts = _debts.fold(0.0, (sum, d) => sum + (d['balance'] as double));
        _sortDebts();
        _isLoading = false;
      });
    }
  }

  void _sortDebts() {
    if (_sortBy == 'amount') {
      _debts.sort((a, b) => (b['balance'] as double).compareTo(a['balance'] as double));
    } else if (_sortBy == 'name') {
      _debts.sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
    } else if (_sortBy == 'date') {
      _debts.sort((a, b) => (b['lastPayment'] as DateTime).compareTo(a['lastPayment'] as DateTime));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.debtsReportTitle),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: AppLocalizations.of(context)!.sortLabel,
            onSelected: (value) {
              setState(() {
                _sortBy = value;
                _sortDebts();
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'amount', child: Text(AppLocalizations.of(context)!.sortByAmount)),
              PopupMenuItem(value: 'name', child: Text(AppLocalizations.of(context)!.sortByName)),
              PopupMenuItem(value: 'date', child: Text(AppLocalizations.of(context)!.sortByLastPayment)),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: AppLocalizations.of(context)!.shareAction,
            onPressed: _shareReport,
          ),
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: AppLocalizations.of(context)!.printAction,
            onPressed: _printReport,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Summary card
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.red.shade400, Colors.red.shade600],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppLocalizations.of(context)!.totalDebts, style: const TextStyle(color: Colors.white70)),
                          const SizedBox(height: 4),
                          Text(
                            '${_totalDebts.toStringAsFixed(0)} ${AppLocalizations.of(context)!.sar}',
                            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(AppLocalizations.of(context)!.customersCount, style: const TextStyle(color: Colors.white70)),
                          const SizedBox(height: 4),
                          Text(
                            '${_debts.length}',
                            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Debts list
                Expanded(
                  child: _debts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle, size: 64, color: Colors.green.shade400),
                              const SizedBox(height: 16),
                              Text(AppLocalizations.of(context)!.noOutstandingDebts, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _debts.length,
                          itemBuilder: (context, index) {
                            final debt = _debts[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.red.shade100,
                                  child: Text(
                                    (debt['name'] as String).isNotEmpty ? (debt['name'] as String)[0] : '?',
                                    style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                title: Text(debt['name'] as String),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (debt['phone'] != null)
                                      Text(debt['phone'] as String, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                                    Text(
                                      AppLocalizations.of(context)!.lastUpdate(_formatDate(debt['lastPayment'] as DateTime)),
                                      style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${(debt['balance'] as double).toStringAsFixed(0)} ${AppLocalizations.of(context)!.sar}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 16),
                                    ),
                                    TextButton(
                                      onPressed: () => _recordPayment(debt),
                                      style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0)),
                                      child: Text(AppLocalizations.of(context)!.recordPayment, style: const TextStyle(fontSize: 12)),
                                    ),
                                  ],
                                ),
                                onTap: () => _showCustomerDetails(debt),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _recordPayment(Map<String, dynamic> debt) {
    final amountController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(dialogContext)!.recordPaymentFor(debt['name'] as String)),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(dialogContext)!.paymentAmountField,
            suffixText: AppLocalizations.of(dialogContext)!.sar,
            helperText: AppLocalizations.of(dialogContext)!.currentDebt((debt['balance'] as double).toStringAsFixed(0)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(AppLocalizations.of(dialogContext)!.cancel)),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(context)!.paymentRecordedMsg), backgroundColor: Colors.green),
              );
              _loadDebts();
            },
            child: Text(AppLocalizations.of(dialogContext)!.recordAction),
          ),
        ],
      ),
    );
  }

  pw.Document _buildDebtsPdf() {
    final pdf = pw.Document();
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      textDirection: pw.TextDirection.rtl,
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('تقرير الديون',
              style: pw.TextStyle(
                  fontSize: 20, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Text(
              'التاريخ: ${_formatDate(DateTime.now())}'),
          pw.Divider(),
          pw.SizedBox(height: 10),
          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('إجمالي الديون',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold)),
                pw.Text(
                    '${_totalDebts.toStringAsFixed(0)} ر.س',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold)),
              ]),
          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('عدد العملاء'),
                pw.Text('${_debts.length}'),
              ]),
          pw.Divider(),
          pw.SizedBox(height: 10),
          pw.Text('تفاصيل الديون:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          // Table header
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 4),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                  bottom: pw.BorderSide(width: 1)),
            ),
            child: pw.Row(
              children: [
                pw.Expanded(
                    flex: 3,
                    child: pw.Text('العميل',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 10))),
                pw.Expanded(
                    flex: 2,
                    child: pw.Text('الهاتف',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 10))),
                pw.Expanded(
                    flex: 2,
                    child: pw.Text('المبلغ',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 10),
                        textAlign: pw.TextAlign.left)),
              ],
            ),
          ),
          // Table rows
          ...List.generate(_debts.length, (index) {
            final debt = _debts[index];
            return pw.Container(
              padding:
                  const pw.EdgeInsets.symmetric(vertical: 3),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                    bottom: pw.BorderSide(
                        width: 0.3,
                        color: PdfColors.grey400)),
              ),
              child: pw.Row(
                children: [
                  pw.Expanded(
                      flex: 3,
                      child: pw.Text(
                          debt['name'] as String,
                          style: const pw.TextStyle(
                              fontSize: 10))),
                  pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                          (debt['phone'] as String?) ??
                              '-',
                          style: const pw.TextStyle(
                              fontSize: 10))),
                  pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                          '${(debt['balance'] as double).toStringAsFixed(0)} ر.س',
                          style: const pw.TextStyle(
                              fontSize: 10),
                          textAlign: pw.TextAlign.left)),
                ],
              ),
            );
          }),
        ],
      ),
    ));
    return pdf;
  }

  void _shareReport() async {
    final pdf = _buildDebtsPdf();
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename:
          'debts_report_${DateTime.now().toIso8601String().split('T').first}.pdf',
    );
  }

  void _printReport() async {
    final pdf = _buildDebtsPdf();
    await Printing.layoutPdf(
      onLayout: (_) => pdf.save(),
      name:
          'debts_report_${DateTime.now().toIso8601String().split('T').first}',
    );
  }

  void _showCustomerDetails(Map<String, dynamic> debt) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.showDetails(debt['name'] as String))),
    );
  }
}
