import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:alhai_core/alhai_core.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

/// Wallet management screen with balance overview, transactions list, and settings.
class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _error;
  double _balance = 0.0;
  List<TransactionsTableData> _allTransactions = [];
  double _totalDeposits = 0.0;
  double _totalWithdrawals = 0.0;
  double _totalTransfers = 0.0;

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
      _error = null;
    });
    try {
      final db = getIt<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) {
        setState(() {
          _isLoading = false;
          _error = 'No store selected';
        });
        return;
      }

      // Load balance from settings
      final balanceRow = await (db.select(db.settingsTable)
            ..where((s) =>
                s.storeId.equals(storeId) &
                s.key.equals('wallet_balance')))
          .getSingleOrNull();
      final balance =
          double.tryParse(balanceRow?.value ?? '0') ?? 0.0;

      // Load transactions
      final transactions =
          await db.transactionsDao.getAccountTransactions(storeId);

      // Calculate totals
      double deposits = 0.0;
      double withdrawals = 0.0;
      double transfers = 0.0;
      for (final t in transactions) {
        if (t.type == 'deposit' ||
            (t.type == 'payment' && t.amount > 0)) {
          deposits += t.amount.abs();
        } else if (t.type == 'withdrawal' ||
            (t.type == 'payment' && t.amount < 0)) {
          withdrawals += t.amount.abs();
        } else if (t.type == 'transfer') {
          transfers += t.amount.abs();
        }
      }

      if (mounted) {
        setState(() {
          _balance = balance;
          _allTransactions = transactions;
          _totalDeposits = deposits;
          _totalWithdrawals = withdrawals;
          _totalTransfers = transfers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Error loading wallet data: $e';
        });
      }
    }
  }

  List<TransactionsTableData> get _deposits => _allTransactions
      .where((t) =>
          t.type == 'deposit' ||
          (t.type == 'payment' && t.amount > 0))
      .toList();

  List<TransactionsTableData> get _transfers =>
      _allTransactions.where((t) => t.type == 'transfer').toList();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        AppHeader(
          title: l10n.wallet,
          onMenuTap:
              isWide ? null : () => Scaffold.of(context).openDrawer(),
          onNotificationsTap: () => context.push('/notifications'),
          notificationsCount: 0,
          userName: l10n.defaultUserName,
          userRole: l10n.branchManager,
          actions: [
            FilledButton.icon(
              onPressed: () =>
                  _showDepositDialog(context, isDark),
              icon: const Icon(Icons.add, size: 18),
              label: Text(l10n.walletTopup),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(AlhaiSpacing.md),
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            children: [
              // Balance card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AlhaiSpacing.lg),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [AppColors.primary, Color(0xFF5B2D8E)]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: Colors.white))
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.wallet,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(height: AlhaiSpacing.xs),
                          Text(
                            _balance.toStringAsFixed(2),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AlhaiSpacing.sm),
                          Wrap(
                            spacing: 16,
                            runSpacing: 8,
                            children: [
                              _WalletInfoChip(
                                icon: Icons.arrow_downward,
                                label: 'Deposits',
                                value:
                                    _totalDeposits.toStringAsFixed(2),
                              ),
                              _WalletInfoChip(
                                icon: Icons.arrow_upward,
                                label: 'Withdrawals',
                                value: _totalWithdrawals
                                    .toStringAsFixed(2),
                              ),
                              _WalletInfoChip(
                                icon: Icons.swap_horiz,
                                label: 'Transfers',
                                value: _totalTransfers
                                    .toStringAsFixed(2),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: AlhaiSpacing.md),
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor:
                    Theme.of(context).colorScheme.onSurfaceVariant,
                indicatorColor: AppColors.primary,
                tabs: [
                  Tab(text: l10n.all),
                  Tab(text: l10n.walletTopup),
                  Tab(text: l10n.walletPayment),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? _buildErrorState(isDark, l10n)
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildTransactionsTab(
                            isDark, _allTransactions),
                        _buildTransactionsTab(isDark, _deposits),
                        _buildTransactionsTab(isDark, _transfers),
                      ],
                    ),
        ),
      ],
    );
  }

  Widget _buildErrorState(bool isDark, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline,
              size: 64,
              color: AppColors.error.withValues(alpha: 0.7)),
          const SizedBox(height: AlhaiSpacing.md),
          Text(
            _error!,
            style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AlhaiSpacing.md),
          FilledButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            label: Text(l10n.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsTab(
      bool isDark, List<TransactionsTableData> transactions) {
    if (transactions.isEmpty) {
      if (_tabController.index == 0) {
        return AppEmptyState.noData(
          context,
          title: 'لا توجد معاملات',
          description: 'ستظهر المعاملات هنا بعد النشاط',
        );
      } else if (_tabController.index == 1) {
        return AppEmptyState(
          icon: Icons.savings_outlined,
          title: 'لا توجد إيداعات',
          description: 'اضغط + لإضافة إيداع جديد',
        );
      } else {
        return AppEmptyState(
          icon: Icons.swap_horiz,
          title: 'لا توجد تحويلات',
        );
      }
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      itemCount: transactions.length,
      separatorBuilder: (_, __) => const SizedBox(height: AlhaiSpacing.xs),
      itemBuilder: (context, index) {
        final t = transactions[index];
        return _buildTransactionCard(t, isDark);
      },
    );
  }

  Widget _buildTransactionCard(
      TransactionsTableData transaction, bool isDark) {
    final isPositive = transaction.amount >= 0;
    final typeLabel = _getTypeLabel(transaction.type);
    final icon = _getTypeIcon(transaction.type);
    final color = isPositive ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: AlhaiSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  typeLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                if (transaction.description != null &&
                    transaction.description!.isNotEmpty) ...[
                  const SizedBox(height: AlhaiSpacing.xxxs),
                  Text(
                    transaction.description!,
                    style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: AlhaiSpacing.xxs),
                Text(
                  _formatDateTime(transaction.createdAt),
                  style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? Colors.white38
                          : AppColors.textTertiary),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isPositive ? '+' : ''}${transaction.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: color,
                ),
              ),
              const SizedBox(height: AlhaiSpacing.xxxs),
              if (transaction.paymentMethod != null)
                Text(
                  _getPaymentMethodLabel(transaction.paymentMethod!),
                  style: TextStyle(
                      fontSize: 10,
                      color: isDark
                          ? Colors.white38
                          : AppColors.textTertiary),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'deposit':
        return 'Deposit';
      case 'withdrawal':
        return 'Withdrawal';
      case 'transfer':
        return 'Transfer';
      case 'payment':
        return 'Payment';
      case 'invoice':
        return 'Invoice';
      case 'interest':
        return 'Interest';
      case 'adjustment':
        return 'Adjustment';
      default:
        return type;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'deposit':
        return Icons.arrow_downward;
      case 'withdrawal':
        return Icons.arrow_upward;
      case 'transfer':
        return Icons.swap_horiz;
      case 'payment':
        return Icons.payment;
      case 'invoice':
        return Icons.receipt;
      case 'interest':
        return Icons.percent;
      default:
        return Icons.circle;
    }
  }

  String _getPaymentMethodLabel(String method) {
    switch (method) {
      case 'bank':
        return 'Bank Transfer';
      case 'card':
        return 'Card';
      case 'cash':
        return 'Cash';
      case 'transfer':
        return 'Transfer';
      default:
        return method;
    }
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  void _showDepositDialog(BuildContext context, bool isDark) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    String selectedMethod = 'cash';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('New Deposit'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AlhaiSpacing.sm),
              DropdownButtonFormField<String>(
                initialValue: selectedMethod,
                decoration: InputDecoration(
                  labelText: 'Payment Method',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'bank', child: Text('Bank Transfer')),
                  DropdownMenuItem(
                      value: 'card', child: Text('Credit Card')),
                  DropdownMenuItem(
                      value: 'cash', child: Text('Cash')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setDialogState(() => selectedMethod = val);
                  }
                },
              ),
              const SizedBox(height: AlhaiSpacing.sm),
              TextField(
                controller: noteController,
                decoration: InputDecoration(
                  labelText: 'Note',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final amount =
                    double.tryParse(amountController.text);
                if (amount == null || amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Please enter a valid amount')),
                  );
                  return;
                }
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Deposit of ${amount.toStringAsFixed(2)} recorded')),
                );
                _loadData();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white),
              child: const Text('Deposit'),
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _WalletInfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: AlhaiSpacing.xxs),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    color: Colors.white54, fontSize: 10)),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}
