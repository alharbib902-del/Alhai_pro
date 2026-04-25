import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_design_system/alhai_design_system.dart' show AlhaiSpacing;
import 'package:alhai_shared_ui/alhai_shared_ui.dart' show SilentLimitBadge;
import 'package:uuid/uuid.dart';
import '../../utils/pdf_font_helper.dart';

/// Wave 8 (P0-33): list size for the debts report. Beyond this the list
/// shows a `SilentLimitBadge`; the summary total above it always reflects
/// the SQL aggregate so the headline number is correct regardless of the
/// list-page count.
const int _kDebtsPageLimit = 500;

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
  int _accountsRowCount = 0;
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

    final db = GetIt.I<AppDatabase>();

    // Wave 8 (P0-33): pull the aggregate total straight from SQL so the
    // headline number stays correct even when the store has more debtors
    // than `_kDebtsPageLimit` (the list below is page-bounded; the badge
    // surfaces that). Previously the total was a `fold` over the bounded
    // list, so a 700-debtor store silently understated the total by
    // however much the bottom 200 rows held.
    final totalReceivable = await db.accountsDao.getTotalReceivable(storeId);
    final accounts = await db.accountsDao.getReceivableAccounts(
      storeId,
      limit: _kDebtsPageLimit,
    );

    if (mounted) {
      setState(() {
        _debts = accounts
            .where((a) => a.balance > 0)
            .map(
              (a) => {
                'id': a.id,
                'name': a.name,
                'phone': a.phone,
                'balance': a.balance,
                'lastPayment': a.lastTransactionAt ?? a.createdAt,
              },
            )
            .toList();

        _totalDebts = totalReceivable;
        _accountsRowCount = accounts.length;
        _sortDebts();
        _isLoading = false;
      });
    }
  }

  void _sortDebts() {
    if (_sortBy == 'amount') {
      _debts.sort(
        (a, b) => (b['balance'] as double).compareTo(a['balance'] as double),
      );
    } else if (_sortBy == 'name') {
      _debts.sort(
        (a, b) => (a['name'] as String).compareTo(b['name'] as String),
      );
    } else if (_sortBy == 'date') {
      _debts.sort(
        (a, b) => (b['lastPayment'] as DateTime).compareTo(
          a['lastPayment'] as DateTime,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).debtsReportTitle),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: AppLocalizations.of(context).sortLabel,
            onSelected: (value) {
              setState(() {
                _sortBy = value;
                _sortDebts();
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'amount',
                child: Text(AppLocalizations.of(context).sortByAmount),
              ),
              PopupMenuItem(
                value: 'name',
                child: Text(AppLocalizations.of(context).sortByName),
              ),
              PopupMenuItem(
                value: 'date',
                child: Text(AppLocalizations.of(context).sortByLastPayment),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: AppLocalizations.of(context).shareAction,
            onPressed: _shareReport,
          ),
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: AppLocalizations.of(context).printAction,
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
                  margin: const EdgeInsets.all(AlhaiSpacing.md),
                  padding: const EdgeInsets.all(AlhaiSpacing.mdl),
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
                          Text(
                            AppLocalizations.of(context).totalDebts,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: AlhaiSpacing.xxs),
                          Text(
                            '${_totalDebts.toStringAsFixed(0)} ${AppLocalizations.of(context).sar}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            AppLocalizations.of(context).customersCount,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: AlhaiSpacing.xxs),
                          Text(
                            '${_debts.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Wave 8 (P0-33): warn the user when the list page hit
                // its ceiling — the headline total above is still correct
                // (SQL aggregate), but the rows below are truncated.
                SilentLimitBadge(
                  rowCount: _accountsRowCount,
                  limit: _kDebtsPageLimit,
                ),

                // Debts list
                Expanded(
                  child: _debts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 64,
                                color: Colors.green.shade400,
                              ),
                              const SizedBox(height: AlhaiSpacing.md),
                              Text(
                                AppLocalizations.of(context).noOutstandingDebts,
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AlhaiSpacing.md,
                          ),
                          itemCount: _debts.length,
                          itemBuilder: (context, index) {
                            final debt = _debts[index];
                            return Card(
                              margin: const EdgeInsets.only(
                                bottom: AlhaiSpacing.xs,
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.red.shade100,
                                  child: Text(
                                    (debt['name'] as String).isNotEmpty
                                        ? (debt['name'] as String)[0]
                                        : '?',
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(debt['name'] as String),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (debt['phone'] != null)
                                      Text(
                                        debt['phone'] as String,
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    Text(
                                      AppLocalizations.of(context).lastUpdate(
                                        _formatDate(
                                          debt['lastPayment'] as DateTime,
                                        ),
                                      ),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${(debt['balance'] as double).toStringAsFixed(0)} ${AppLocalizations.of(context).sar}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                        fontSize: 16,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => _recordPayment(debt),
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: const Size(0, 0),
                                      ),
                                      child: Text(
                                        AppLocalizations.of(
                                          context,
                                        ).recordPayment,
                                        style: const TextStyle(fontSize: 12),
                                      ),
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
    String? errorText;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(
            AppLocalizations.of(
              dialogContext,
            ).recordPaymentFor(debt['name'] as String),
          ),
          content: TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(dialogContext).paymentAmountField,
              suffixText: AppLocalizations.of(dialogContext).sar,
              helperText: AppLocalizations.of(
                dialogContext,
              ).currentDebt((debt['balance'] as double).toStringAsFixed(0)),
              errorText: errorText,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(AppLocalizations.of(dialogContext).cancel),
            ),
            FilledButton(
              onPressed: () async {
                final amount = double.tryParse(amountController.text.trim());
                final balance = debt['balance'] as double;

                if (amount == null || amount <= 0) {
                  setDialogState(() => errorText = 'أدخل مبلغ صحيح');
                  return;
                }
                if (amount > balance) {
                  setDialogState(
                    () => errorText = 'المبلغ أكبر من الدين المتبقي',
                  );
                  return;
                }

                Navigator.pop(dialogContext);
                await _persistPayment(
                  accountId: debt['id'] as String,
                  amount: amount,
                  currentBalance: balance,
                );
              },
              child: Text(AppLocalizations.of(dialogContext).recordAction),
            ),
          ],
        ),
      ),
    );
  }

  /// حفظ الدفعة في القاعدة المحلية
  Future<void> _persistPayment({
    required String accountId,
    required double amount,
    required double currentBalance,
  }) async {
    try {
      final db = GetIt.I<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;

      final newBalance = currentBalance - amount;
      final paymentId = const Uuid().v4();

      // 1. خصم من رصيد الحساب
      await db.accountsDao.subtractFromBalance(accountId, amount);

      // 2. تسجيل حركة الدفعة
      await db.transactionsDao.recordPayment(
        id: paymentId,
        storeId: storeId,
        accountId: accountId,
        amount: amount,
        balanceAfter: newBalance,
        paymentMethod: 'cash',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).paymentRecordedMsg),
            backgroundColor: Colors.green,
          ),
        );
      }

      // 3. إعادة تحميل البيانات
      await _loadDebts();
    } catch (e) {
      debugPrint('DebtsReport: Error persisting payment: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء تسجيل الدفعة: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<pw.Document> _buildDebtsPdf() async {
    final pdf = await PdfFontHelper.createDocument();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'تقرير الديون',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Text('التاريخ: ${_formatDate(DateTime.now())}'),
            pw.Divider(),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'إجمالي الديون',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  '${_totalDebts.toStringAsFixed(0)} ر.س',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [pw.Text('عدد العملاء'), pw.Text('${_debts.length}')],
            ),
            pw.Divider(),
            pw.SizedBox(height: 10),
            pw.Text(
              'تفاصيل الديون:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            // Table header
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 4),
              decoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(width: 1)),
              ),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    flex: 3,
                    child: pw.Text(
                      'العميل',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      'الهاتف',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      'المبلغ',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10,
                      ),
                      textAlign: pw.TextAlign.left,
                    ),
                  ),
                ],
              ),
            ),
            // Table rows
            ...List.generate(_debts.length, (index) {
              final debt = _debts[index];
              return pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 3),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(width: 0.3, color: PdfColors.grey400),
                  ),
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text(
                        debt['name'] as String,
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        (debt['phone'] as String?) ?? '-',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        '${(debt['balance'] as double).toStringAsFixed(0)} ر.س',
                        style: const pw.TextStyle(fontSize: 10),
                        textAlign: pw.TextAlign.left,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
    return pdf;
  }

  void _shareReport() async {
    final pdf = await _buildDebtsPdf();
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename:
          'debts_report_${DateTime.now().toIso8601String().split('T').first}.pdf',
    );
  }

  void _printReport() async {
    final pdf = await _buildDebtsPdf();
    await Printing.layoutPdf(
      onLayout: (_) => pdf.save(),
      name: 'debts_report_${DateTime.now().toIso8601String().split('T').first}',
    );
  }

  void _showCustomerDetails(Map<String, dynamic> debt) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context).showDetails(debt['name'] as String),
        ),
      ),
    );
  }
}
