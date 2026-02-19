import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../data/local/app_database.dart';
import '../../di/injection.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/products_providers.dart';
import '../../providers/settings_db_providers.dart';
import '../../providers/sync_providers.dart';
import '../../widgets/layout/app_header.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});
  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> with SingleTickerProviderStateMixin {
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
          _error = 'لم يتم تحديد المتجر';
        });
        return;
      }

      // Load balance from settings
      final balanceStr = await getSettingValue(db, storeId, 'wallet_balance');
      final balance = double.tryParse(balanceStr ?? '0') ?? 0.0;

      // Load transactions using storeId as the account
      final transactions = await db.transactionsDao.getAccountTransactions(storeId);

      // Calculate totals
      double deposits = 0.0;
      double withdrawals = 0.0;
      double transfers = 0.0;
      for (final t in transactions) {
        if (t.type == 'deposit' || (t.type == 'payment' && t.amount > 0)) {
          deposits += t.amount.abs();
        } else if (t.type == 'withdrawal' || (t.type == 'payment' && t.amount < 0)) {
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
          _error = 'حدث خطأ أثناء تحميل بيانات المحفظة: $e';
        });
      }
    }
  }

  List<TransactionsTableData> get _deposits =>
      _allTransactions.where((t) => t.type == 'deposit' || (t.type == 'payment' && t.amount > 0)).toList();

  List<TransactionsTableData> get _transfers =>
      _allTransactions.where((t) => t.type == 'transfer').toList();

  Future<void> _performDeposit(double amount, String paymentMethod, String? note) async {
    try {
      final db = getIt<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;

      final id = const Uuid().v4();
      final newBalance = _balance + amount;

      // Insert transaction
      await db.transactionsDao.insertTransaction(
        TransactionsTableCompanion.insert(
          id: id,
          storeId: storeId,
          accountId: storeId,
          type: 'deposit',
          amount: amount,
          balanceAfter: newBalance,
          paymentMethod: Value(paymentMethod),
          description: Value(note),
          createdAt: DateTime.now(),
        ),
      );

      // Update balance in settings
      await saveSettingWithSync(
        db: db,
        storeId: storeId,
        key: 'wallet_balance',
        value: newBalance.toStringAsFixed(2),
        ref: ref,
      );

      // Enqueue transaction to sync
      ref.read(syncServiceProvider).enqueueUpdate(
        tableName: 'transactions',
        recordId: id,
        changes: {
          'id': id,
          'storeId': storeId,
          'accountId': storeId,
          'type': 'deposit',
          'amount': amount,
          'balanceAfter': newBalance,
          'paymentMethod': paymentMethod,
          'description': note,
          'createdAt': DateTime.now().toIso8601String(),
        },
      );

      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم الإيداع بنجاح: ${amount.toStringAsFixed(2)} ر.س')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء الإيداع: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        AppHeader(
          title: l10n.wallet,
          onMenuTap: isWide ? null : () => Scaffold.of(context).openDrawer(),
          onNotificationsTap: () => context.push('/notifications'),
          notificationsCount: 0,
          userName: l10n.defaultUserName,
          userRole: l10n.branchManager,
          actions: [
            FilledButton.icon(
              onPressed: () => _showDepositDialog(context, isDark),
              icon: const Icon(Icons.add, size: 18),
              label: Text(l10n.walletTopup),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(16),
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          child: Column(
            children: [
                // Balance card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFF5B2D8E)]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('الرصيد الحالي', style: TextStyle(color: Colors.white70, fontSize: 14)),
                            const SizedBox(height: 8),
                            Text(
                              '${_balance.toStringAsFixed(2)} ر.س',
                              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _WalletInfoChip(icon: Icons.arrow_downward, label: 'إيداعات', value: _totalDeposits.toStringAsFixed(2)),
                                const SizedBox(width: 16),
                                _WalletInfoChip(icon: Icons.arrow_upward, label: 'سحوبات', value: _totalWithdrawals.toStringAsFixed(2)),
                                const SizedBox(width: 16),
                                _WalletInfoChip(icon: Icons.swap_horiz, label: 'تحويلات', value: _totalTransfers.toStringAsFixed(2)),
                              ],
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 16),
                TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: isDark ? Colors.white54 : AppColors.textSecondary,
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
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 64, color: AppColors.error.withValues(alpha: 0.7)),
                            const SizedBox(height: 16),
                            Text(
                              _error!,
                              style: TextStyle(fontSize: 16, color: isDark ? Colors.white54 : AppColors.textSecondary),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              onPressed: _loadData,
                              icon: const Icon(Icons.refresh),
                              label: Text(l10n.retry),
                            ),
                          ],
                        ),
                      )
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildTransactionsTab(isDark, _allTransactions),
                          _buildTransactionsTab(isDark, _deposits),
                          _buildTransactionsTab(isDark, _transfers),
                        ],
                      ),
          ),
        ],
    );
  }

  Widget _buildTransactionsTab(bool isDark, List<TransactionsTableData> transactions) {
    if (transactions.isEmpty) {
      String emptyMessage;
      String emptySubMessage;
      IconData emptyIcon;
      if (_tabController.index == 0) {
        emptyMessage = 'لا توجد معاملات';
        emptySubMessage = 'ستظهر المعاملات هنا بعد إجراء عمليات';
        emptyIcon = Icons.receipt_long_outlined;
      } else if (_tabController.index == 1) {
        emptyMessage = 'لا توجد إيداعات';
        emptySubMessage = 'اضغط + لإضافة إيداع جديد';
        emptyIcon = Icons.savings_outlined;
      } else {
        emptyMessage = 'لا توجد تحويلات';
        emptySubMessage = '';
        emptyIcon = Icons.swap_horiz;
      }
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(emptyIcon, size: 80, color: isDark ? Colors.white24 : AppColors.textTertiary),
            const SizedBox(height: 16),
            Text(emptyMessage, style: TextStyle(fontSize: 16, color: isDark ? Colors.white54 : AppColors.textSecondary)),
            if (emptySubMessage.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(emptySubMessage, style: TextStyle(fontSize: 13, color: isDark ? Colors.white38 : AppColors.textTertiary)),
            ],
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: transactions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final t = transactions[index];
        return _buildTransactionCard(t, isDark);
      },
    );
  }

  Widget _buildTransactionCard(TransactionsTableData transaction, bool isDark) {
    final isPositive = transaction.amount >= 0;
    final typeLabel = _getTypeLabel(transaction.type);
    final icon = _getTypeIcon(transaction.type);
    final color = isPositive ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  typeLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                if (transaction.description != null && transaction.description!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    transaction.description!,
                    style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  _formatDateTime(transaction.createdAt),
                  style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : AppColors.textTertiary),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isPositive ? '+' : ''}${transaction.amount.toStringAsFixed(2)} ر.س',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              if (transaction.paymentMethod != null)
                Text(
                  _getPaymentMethodLabel(transaction.paymentMethod!),
                  style: TextStyle(fontSize: 10, color: isDark ? Colors.white38 : AppColors.textTertiary),
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
        return 'إيداع';
      case 'withdrawal':
        return 'سحب';
      case 'transfer':
        return 'تحويل';
      case 'payment':
        return 'دفعة';
      case 'invoice':
        return 'فاتورة';
      case 'interest':
        return 'فائدة';
      case 'adjustment':
        return 'تعديل';
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
        return 'تحويل بنكي';
      case 'card':
        return 'بطاقة';
      case 'cash':
        return 'نقدي';
      case 'transfer':
        return 'تحويل';
      default:
        return method;
    }
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  void _showDepositDialog(BuildContext context, bool isDark) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    String selectedMethod = 'cash';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('إيداع جديد'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                decoration: InputDecoration(
                  labelText: 'المبلغ',
                  suffixText: 'ر.س',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedMethod,
                decoration: InputDecoration(
                  labelText: 'طريقة الدفع',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: const [
                  DropdownMenuItem(value: 'bank', child: Text('تحويل بنكي')),
                  DropdownMenuItem(value: 'card', child: Text('بطاقة ائتمان')),
                  DropdownMenuItem(value: 'cash', child: Text('نقدي')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setDialogState(() => selectedMethod = val);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                decoration: InputDecoration(
                  labelText: 'ملاحظة',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text);
                if (amount == null || amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('الرجاء إدخال مبلغ صحيح')),
                  );
                  return;
                }
                Navigator.pop(ctx);
                _performDeposit(amount, selectedMethod, noteController.text.isEmpty ? null : noteController.text);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              child: const Text('إيداع'),
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
  const _WalletInfoChip({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}
