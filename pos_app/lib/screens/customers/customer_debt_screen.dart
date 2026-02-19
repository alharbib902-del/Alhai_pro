import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/app_database.dart';
import '../../di/injection.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/products_providers.dart';

/// Customer Debt Management Screen
class CustomerDebtScreen extends ConsumerStatefulWidget {
  const CustomerDebtScreen({super.key});

  @override
  ConsumerState<CustomerDebtScreen> createState() => _CustomerDebtScreenState();
}

class _CustomerDebtScreenState extends ConsumerState<CustomerDebtScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _sortBy = 'amount';
  bool _isLoading = true;

  List<AccountsTableData> _debtors = [];

  double get _totalDebt =>
      _debtors.fold(0.0, (sum, d) => sum + d.balance);
  int get _overdueCount => _debtors.where((d) {
        if (d.lastTransactionAt == null) return true;
        return d.lastTransactionAt!
            .isBefore(DateTime.now().subtract(const Duration(days: 30)));
      }).length;

  String _getStatus(AccountsTableData account) {
    if (account.balance <= 0) return 'paid';
    if (account.lastTransactionAt == null) return 'overdue';
    final daysSinceLastTx =
        DateTime.now().difference(account.lastTransactionAt!).inDays;
    return daysSinceLastTx > 30 ? 'overdue' : 'pending';
  }

  DateTime _getDueDate(AccountsTableData account) {
    // Due date = last transaction + 30 days (business convention)
    if (account.lastTransactionAt != null) {
      return account.lastTransactionAt!.add(const Duration(days: 30));
    }
    return account.createdAt.add(const Duration(days: 30));
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final storeId = ref.read(currentStoreIdProvider) ?? kDemoStoreId;
      final db = getIt<AppDatabase>();
      final accounts = await db.accountsDao.getReceivableAccounts(storeId);
      // Filter to only those with positive balance (actual debtors)
      final debtors =
          accounts.where((a) => a.balance > 0).toList();
      if (mounted) {
        setState(() {
          _debtors = debtors;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<AccountsTableData> _getFilteredDebts(String filter) {
    var list = List<AccountsTableData>.from(_debtors);
    if (filter == 'overdue') {
      list = list.where((d) => _getStatus(d) == 'overdue').toList();
    } else if (filter == 'pending') {
      list = list.where((d) => _getStatus(d) == 'pending').toList();
    }

    if (_sortBy == 'amount') {
      list.sort((a, b) => b.balance.compareTo(a.balance));
    } else if (_sortBy == 'date') {
      list.sort((a, b) => _getDueDate(a).compareTo(_getDueDate(b)));
    } else if (_sortBy == 'name') {
      list.sort((a, b) => a.name.compareTo(b.name));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.debtManagement)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.debtManagement),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadData,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: l10n.sortLabel,
            onSelected: (v) => setState(() => _sortBy = v),
            itemBuilder: (context) => [
              PopupMenuItem(
                  value: 'amount', child: Text(l10n.sortByAmount)),
              PopupMenuItem(
                  value: 'date', child: Text(l10n.sortByDate)),
              PopupMenuItem(
                  value: 'name', child: Text(l10n.sortByName)),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            tooltip: l10n.sendReminders,
            onPressed: _sendReminders,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.allTab),
            Tab(text: l10n.overdueTab),
            Tab(text: l10n.upcomingTab),
          ],
        ),
      ),
      body: Column(
        children: [
          // Summary cards
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.account_balance_wallet,
                    title: l10n.totalDebts,
                    value: l10n.debtAmountWithCurrency(
                        _totalDebt.toStringAsFixed(0)),
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.warning,
                    title: l10n.overdueDebts,
                    value: l10n.customerCount('$_overdueCount'),
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.people,
                    title: l10n.debtorCustomers,
                    value: '${_debtors.length}',
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),

          // Debts list
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDebtList('all'),
                _buildDebtList('overdue'),
                _buildDebtList('pending'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebtList(String filter) {
    final l10n = AppLocalizations.of(context)!;
    final debts = _getFilteredDebts(filter);
    if (debts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle,
                size: 64, color: Colors.green.shade300),
            const SizedBox(height: 16),
            Text(l10n.noDebts, style: const TextStyle(fontSize: 18)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: debts.length,
      itemBuilder: (context, index) {
        final debt = debts[index];
        final status = _getStatus(debt);
        final isOverdue = status == 'overdue';
        final dueDate = _getDueDate(debt);
        final daysLeft = dueDate.difference(DateTime.now()).inDays;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => _showDebtDetails(debt),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: isOverdue
                            ? Colors.red.withValues(alpha: 0.1)
                            : Colors.blue.withValues(alpha: 0.1),
                        child: Text(
                          debt.name.isNotEmpty ? debt.name[0] : '?',
                          style: TextStyle(
                            color:
                                isOverdue ? Colors.red : Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              debt.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              debt.phone ?? '',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            l10n.debtAmountWithCurrency(
                                debt.balance.toStringAsFixed(0)),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: isOverdue
                                  ? Colors.red
                                  : Colors.blue,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isOverdue
                                  ? Colors.red
                                      .withValues(alpha: 0.1)
                                  : Colors.green
                                      .withValues(alpha: 0.1),
                              borderRadius:
                                  BorderRadius.circular(8),
                            ),
                            child: Text(
                              isOverdue
                                  ? l10n.overdueDays(-daysLeft)
                                  : l10n.remainingDays(daysLeft),
                              style: TextStyle(
                                fontSize: 11,
                                color: isOverdue
                                    ? Colors.red
                                    : Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (debt.lastTransactionAt != null) ...[
                    const Divider(height: 24),
                    Row(
                      children: [
                        Icon(Icons.history,
                            size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          l10n.lastPaymentDate(
                              _formatDate(debt.lastTransactionAt!)),
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () => _recordPayment(debt),
                          icon:
                              const Icon(Icons.payment, size: 16),
                          label: Text(l10n.recordPayment),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showDebtDetails(AccountsTableData debt) {
    final l10n = AppLocalizations.of(context)!;
    final status = _getStatus(debt);
    final dueDate = _getDueDate(debt);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  child: Text(
                      debt.name.isNotEmpty ? debt.name[0] : '?',
                      style: const TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(debt.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge),
                      Text(debt.phone ?? '',
                          style: TextStyle(
                              color: Colors.grey.shade600)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (status == 'overdue'
                        ? Colors.red
                        : Colors.blue)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    l10n.debtAmountWithCurrency(
                        debt.balance.toStringAsFixed(0)),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: status == 'overdue'
                          ? Colors.red
                          : Colors.blue,
                    ),
                  ),
                  Text(l10n.amountDue),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _DetailRow(
                label: l10n.dueDate,
                value: _formatDate(dueDate)),
            if (debt.lastTransactionAt != null)
              _DetailRow(
                  label: l10n.lastPaymentLabel,
                  value: _formatDate(debt.lastTransactionAt!)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.message),
                    label: Text(l10n.sendReminder),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _recordPayment(debt);
                    },
                    icon: const Icon(Icons.payment),
                    label: Text(l10n.recordPayment),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _recordPayment(AccountsTableData debt) {
    final amountController = TextEditingController();
    String paymentMethod = 'cash';
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.recordPaymentFor(debt.name)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.currentDebt(
                  debt.balance.toStringAsFixed(0))),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.paidAmount,
                  prefixIcon: const Icon(Icons.attach_money),
                  suffixText: l10n.currencySAR,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: paymentMethod,
                decoration: InputDecoration(
                  labelText: l10n.paymentMethodLabel2,
                  prefixIcon: const Icon(Icons.payment),
                ),
                items: [
                  DropdownMenuItem(
                      value: 'cash',
                      child: Text(l10n.cashMethod)),
                  DropdownMenuItem(
                      value: 'card',
                      child: Text(l10n.cardMethod)),
                  DropdownMenuItem(
                      value: 'transfer',
                      child: Text(l10n.transferMethod)),
                ],
                onChanged: (v) =>
                    setDialogState(() => paymentMethod = v!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () async {
                final amount =
                    double.tryParse(amountController.text);
                if (amount == null || amount <= 0) return;
                Navigator.pop(context);
                try {
                  final db = getIt<AppDatabase>();
                  final storeId =
                      ref.read(currentStoreIdProvider) ??
                          kDemoStoreId;
                  final newBalance = debt.balance - amount;
                  final txnId =
                      'PAY-${DateTime.now().millisecondsSinceEpoch}';
                  await db.transactionsDao.recordPayment(
                    id: txnId,
                    storeId: storeId,
                    accountId: debt.id,
                    amount: amount,
                    balanceAfter:
                        newBalance < 0 ? 0 : newBalance,
                    paymentMethod: paymentMethod,
                    description: 'Payment via debt screen',
                  );
                  await db.accountsDao.updateBalance(
                      debt.id,
                      newBalance < 0 ? 0 : newBalance);
                  await _loadData();
                  if (mounted) {
                    ScaffoldMessenger.of(this.context)
                        .showSnackBar(
                      SnackBar(
                          content: Text(
                              l10n.paymentRecordedSuccess)),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(this.context)
                        .showSnackBar(
                      SnackBar(
                          content: Text('Error: $e')),
                    );
                  }
                }
              },
              child: Text(l10n.confirm),
            ),
          ],
        ),
      ),
    );
  }

  void _sendReminders() {
    final l10n = AppLocalizations.of(context)!;
    final overdueDebts =
        _debtors.where((d) => _getStatus(d) == 'overdue').toList();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.sendRemindersTitle),
        content:
            Text(l10n.sendRemindersConfirm(overdueDebts.length)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        l10n.remindersSent(overdueDebts.length))),
              );
            },
            child: Text(l10n.sendAction),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: color),
          ),
          Text(
            title,
            style: TextStyle(
                fontSize: 11,
                color: color.withValues(alpha: 0.8)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(color: Colors.grey.shade600)),
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
