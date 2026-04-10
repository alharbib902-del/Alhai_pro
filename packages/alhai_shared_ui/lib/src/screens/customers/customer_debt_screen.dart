import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_auth/alhai_auth.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/sync_providers.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import '../../widgets/common/app_empty_state.dart';

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
  String? _loadError;

  List<AccountsTableData> _debtors = [];

  double get _totalDebt => _debtors.fold(0.0, (sum, d) => sum + d.balance);
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
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final storeId = ref.read(currentStoreIdProvider) ?? kDefaultStoreId;
      final db = GetIt.I<AppDatabase>();
      final accounts = await db.accountsDao.getReceivableAccounts(storeId);
      // Filter to only those with positive balance (actual debtors)
      final debtors = accounts.where((a) => a.balance > 0).toList();
      if (mounted) {
        setState(() {
          _debtors = debtors;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadError = e.toString();
        });
      }
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
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.debtManagement)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_loadError != null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.debtManagement)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: colorScheme.error),
              SizedBox(height: AlhaiSpacing.md),
              Text(l10n.errorOccurred,
                  style: TextStyle(fontSize: 18, color: colorScheme.onSurface)),
              SizedBox(height: AlhaiSpacing.xs),
              Text(_loadError!,
                  style: TextStyle(color: colorScheme.onSurfaceVariant)),
              SizedBox(height: AlhaiSpacing.md),
              FilledButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.debtManagement),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.retry,
            onPressed: _loadData,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: l10n.sortLabel,
            onSelected: (v) => setState(() => _sortBy = v),
            itemBuilder: (context) => [
              PopupMenuItem(value: 'amount', child: Text(l10n.sortByAmount)),
              PopupMenuItem(value: 'date', child: Text(l10n.sortByDate)),
              PopupMenuItem(value: 'name', child: Text(l10n.sortByName)),
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
          // Summary cards - responsive layout
          _buildSummaryCards(l10n, colorScheme),

          // Debts list
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDebtList('all', l10n, colorScheme),
                _buildDebtList('overdue', l10n, colorScheme),
                _buildDebtList('pending', l10n, colorScheme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(AppLocalizations l10n, ColorScheme colorScheme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 600;
        if (isWide) {
          return Padding(
            padding: const EdgeInsets.all(AlhaiSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.account_balance_wallet,
                    title: l10n.totalDebts,
                    value: l10n.debtAmountWithCurrency(
                        CurrencyFormatter.formatNumber(_totalDebt,
                            decimalDigits: 0)),
                    color: colorScheme.error,
                  ),
                ),
                SizedBox(width: AlhaiSpacing.sm),
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.warning,
                    title: l10n.overdueDebts,
                    value: l10n.customerCount(_overdueCount),
                    color: colorScheme.tertiary,
                  ),
                ),
                SizedBox(width: AlhaiSpacing.sm),
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.people,
                    title: l10n.debtorCustomers,
                    value: '${_debtors.length}',
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          );
        }
        // Narrow: vertical stack
        return Padding(
          padding: const EdgeInsets.all(AlhaiSpacing.md),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      icon: Icons.account_balance_wallet,
                      title: l10n.totalDebts,
                      value: l10n.debtAmountWithCurrency(
                          CurrencyFormatter.formatNumber(_totalDebt,
                              decimalDigits: 0)),
                      color: colorScheme.error,
                    ),
                  ),
                  SizedBox(width: AlhaiSpacing.sm),
                  Expanded(
                    child: _SummaryCard(
                      icon: Icons.warning,
                      title: l10n.overdueDebts,
                      value: l10n.customerCount(_overdueCount),
                      color: colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AlhaiSpacing.sm),
              _SummaryCard(
                icon: Icons.people,
                title: l10n.debtorCustomers,
                value: '${_debtors.length}',
                color: colorScheme.primary,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDebtList(
      String filter, AppLocalizations l10n, ColorScheme colorScheme) {
    final debts = _getFilteredDebts(filter);
    if (debts.isEmpty) {
      return AppEmptyState.noDebts(context);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 800;
        if (isWide) {
          // Grid layout for wide screens
          return GridView.builder(
            padding: const EdgeInsetsDirectional.only(
                start: 16, end: 16, top: 8, bottom: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: debts.length,
            itemBuilder: (context, index) =>
                _buildDebtCard(debts[index], l10n, colorScheme),
          );
        }
        return ListView.builder(
          padding: const EdgeInsetsDirectional.only(start: 16, end: 16),
          itemCount: debts.length,
          itemBuilder: (context, index) =>
              _buildDebtCard(debts[index], l10n, colorScheme),
        );
      },
    );
  }

  Widget _buildDebtCard(
      AccountsTableData debt, AppLocalizations l10n, ColorScheme colorScheme) {
    final status = _getStatus(debt);
    final isOverdue = status == 'overdue';
    final dueDate = _getDueDate(debt);
    final daysLeft = dueDate.difference(DateTime.now()).inDays;

    return Card(
      margin: const EdgeInsets.only(bottom: AlhaiSpacing.sm),
      child: InkWell(
        onTap: () => _showDebtDetails(debt),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AlhaiSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: isOverdue
                        ? colorScheme.errorContainer
                        : colorScheme.primaryContainer,
                    child: Text(
                      debt.name.isNotEmpty ? debt.name[0] : '?',
                      style: TextStyle(
                        color: isOverdue
                            ? colorScheme.onErrorContainer
                            : colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: AlhaiSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          debt.name,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface),
                        ),
                        Text(
                          debt.phone ?? '',
                          style: TextStyle(
                              fontSize: 13,
                              color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        l10n.debtAmountWithCurrency(
                            CurrencyFormatter.formatNumber(debt.balance,
                                decimalDigits: 0)),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: isOverdue
                              ? colorScheme.error
                              : colorScheme.primary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AlhaiSpacing.xs,
                            vertical: AlhaiSpacing.xxxs),
                        decoration: BoxDecoration(
                          color: isOverdue
                              ? colorScheme.errorContainer
                              : colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isOverdue
                              ? l10n.overdueDays(-daysLeft)
                              : l10n.remainingDays(daysLeft),
                          style: TextStyle(
                            fontSize: 11,
                            color: isOverdue
                                ? colorScheme.onErrorContainer
                                : colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (debt.lastTransactionAt != null) ...[
                Divider(height: 24, color: colorScheme.outlineVariant),
                Row(
                  children: [
                    Icon(Icons.history,
                        size: 14, color: colorScheme.onSurfaceVariant),
                    SizedBox(width: AlhaiSpacing.xxs),
                    Text(
                      l10n.lastPaymentDate(
                          _formatDate(debt.lastTransactionAt!)),
                      style: TextStyle(
                          fontSize: 12, color: colorScheme.onSurfaceVariant),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => _recordPayment(debt),
                      icon: const Icon(Icons.payment, size: 16),
                      label: Text(l10n.recordPayment),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AlhaiSpacing.sm),
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
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showDebtDetails(AccountsTableData debt) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final status = _getStatus(debt);
    final isOverdue = status == 'overdue';
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
          padding: const EdgeInsets.all(AlhaiSpacing.lg),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AlhaiSpacing.lg),
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  child: Text(debt.name.isNotEmpty ? debt.name[0] : '?',
                      style: const TextStyle(fontSize: 24)),
                ),
                SizedBox(width: AlhaiSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(debt.name,
                          style: Theme.of(context).textTheme.titleLarge),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(debt.phone ?? '',
                            style:
                                TextStyle(color: colorScheme.onSurfaceVariant)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AlhaiSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AlhaiSpacing.md),
              decoration: BoxDecoration(
                color: isOverdue
                    ? colorScheme.errorContainer
                    : colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    l10n.debtAmountWithCurrency(CurrencyFormatter.formatNumber(
                        debt.balance,
                        decimalDigits: 0)),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: isOverdue
                          ? colorScheme.onErrorContainer
                          : colorScheme.onPrimaryContainer,
                    ),
                  ),
                  Text(l10n.amountDue,
                      style: TextStyle(
                          color: isOverdue
                              ? colorScheme.onErrorContainer
                              : colorScheme.onPrimaryContainer)),
                ],
              ),
            ),
            SizedBox(height: AlhaiSpacing.lg),
            _DetailRow(label: l10n.dueDate, value: _formatDate(dueDate)),
            if (debt.lastTransactionAt != null)
              _DetailRow(
                  label: l10n.lastPaymentLabel,
                  value: _formatDate(debt.lastTransactionAt!)),
            SizedBox(height: AlhaiSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.message),
                    label: Text(l10n.sendReminder),
                  ),
                ),
                SizedBox(width: AlhaiSpacing.sm),
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
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.recordPaymentFor(debt.name)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.currentDebt(CurrencyFormatter.formatNumber(debt.balance,
                  decimalDigits: 0))),
              SizedBox(height: AlhaiSpacing.md),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.paidAmount,
                  prefixIcon: const Icon(Icons.attach_money),
                  suffixText: l10n.currencySAR,
                ),
              ),
              SizedBox(height: AlhaiSpacing.sm),
              DropdownButtonFormField<String>(
                initialValue: paymentMethod,
                decoration: InputDecoration(
                  labelText: l10n.paymentMethodLabel2,
                  prefixIcon: const Icon(Icons.payment),
                ),
                items: [
                  DropdownMenuItem(value: 'cash', child: Text(l10n.cashMethod)),
                  DropdownMenuItem(value: 'card', child: Text(l10n.cardMethod)),
                  DropdownMenuItem(
                      value: 'transfer', child: Text(l10n.transferMethod)),
                ],
                onChanged: (v) => setDialogState(() => paymentMethod = v!),
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
                final amount = double.tryParse(amountController.text);
                if (amount == null || amount <= 0) return;
                Navigator.pop(context);
                try {
                  final db = GetIt.I<AppDatabase>();
                  final storeId =
                      ref.read(currentStoreIdProvider) ?? kDefaultStoreId;
                  final newBalance = debt.balance - amount;
                  final txnId = 'PAY-${DateTime.now().millisecondsSinceEpoch}';
                  await db.transactionsDao.recordPayment(
                    id: txnId,
                    storeId: storeId,
                    accountId: debt.id,
                    amount: amount,
                    balanceAfter: newBalance < 0 ? 0 : newBalance,
                    paymentMethod: paymentMethod,
                    description: l10n.recordPayment,
                  );
                  await db.accountsDao
                      .updateBalance(debt.id, newBalance < 0 ? 0 : newBalance);

                  // Enqueue sync for transaction and account update
                  ref.read(syncServiceProvider).enqueueCreate(
                    tableName: 'transactions',
                    recordId: txnId,
                    data: {
                      'id': txnId,
                      'store_id': storeId,
                      'account_id': debt.id,
                      'amount': amount,
                      'balance_after': newBalance < 0 ? 0 : newBalance,
                      'payment_method': paymentMethod,
                    },
                  );
                  ref.read(syncServiceProvider).enqueueUpdate(
                    tableName: 'accounts',
                    recordId: debt.id,
                    changes: {
                      'balance': newBalance < 0 ? 0 : newBalance,
                    },
                  );

                  await _loadData();
                  if (mounted) {
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(content: Text(l10n.paymentRecordedSuccess)),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(content: Text('${l10n.errorOccurred}: $e')),
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
    final l10n = AppLocalizations.of(context);
    final overdueDebts =
        _debtors.where((d) => _getStatus(d) == 'overdue').toList();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.sendRemindersTitle),
        content: Text(l10n.sendRemindersConfirm(overdueDebts.length)),
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
                    content: Text(l10n.remindersSent(overdueDebts.length))),
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
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          SizedBox(height: AlhaiSpacing.xxs),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
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
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: colorScheme.onSurfaceVariant)),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.w500, color: colorScheme.onSurface)),
        ],
      ),
    );
  }
}
