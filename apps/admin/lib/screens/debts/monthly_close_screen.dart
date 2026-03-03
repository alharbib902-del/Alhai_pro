import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';

/// Monthly Close Screen - شاشة إقفال الشهر وحساب الفوائد
class MonthlyCloseScreen extends ConsumerStatefulWidget {
  const MonthlyCloseScreen({super.key});

  @override
  ConsumerState<MonthlyCloseScreen> createState() => _MonthlyCloseScreenState();
}

class _MonthlyCloseScreenState extends ConsumerState<MonthlyCloseScreen> {
  final _db = GetIt.I<AppDatabase>();
  List<_CustomerDebt> _customers = [];
  bool _isLoading = true;
  bool _isProcessing = false;
  String? _lastCloseDate;
  double _interestRate = 5.0;
  int _graceDays = 30;
  String _currentPeriod = '';

  @override
  void initState() {
    super.initState();
    _currentPeriod = _getPeriodKey(DateTime.now());
    _loadData();
  }

  String _getPeriodKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}';
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      _lastCloseDate = prefs.getString('last_month_close');
      _interestRate = prefs.getDouble('interest_rate') ?? 5.0;
      _graceDays = prefs.getInt('interest_grace_days') ?? 30;

      final storeId = prefs.getString('selected_store_id') ?? '';
      final accounts = await _db.accountsDao.getReceivableAccounts(storeId);

      final customers = <_CustomerDebt>[];
      final gracePeriod = DateTime.now().subtract(Duration(days: _graceDays));

      for (final account in accounts) {
        if (account.balance > 0) {
          final hasInterest = await _db.transactionsDao.hasInterestForPeriod(account.id, _currentPeriod);
          final isOverdue = account.lastTransactionAt != null && account.lastTransactionAt!.isBefore(gracePeriod);

          if (!hasInterest && isOverdue) {
            customers.add(_CustomerDebt(
              account: account,
              expectedInterest: account.balance * (_interestRate / 100),
              isSelected: true,
            ));
          }
        }
      }

      setState(() {
        _customers = customers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isMediumScreen = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        AppHeader(
          title: l10n.monthlyCloseTitle,
          subtitle: _getDateSubtitle(l10n),
          showSearch: isWideScreen,
          searchHint: l10n.searchPlaceholder,
          onMenuTap: isWideScreen ? null : () => Scaffold.of(context).openDrawer(),
          onNotificationsTap: () => context.push('/notifications'),
          notificationsCount: 3,
          userName: l10n.defaultUserName,
          userRole: l10n.branchManager,
          actions: [
            IconButton(
              icon: Icon(Icons.refresh_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant),
              onPressed: _loadData,
            ),
          ],
          onUserTap: () {},
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
                        child: _buildContent(isWideScreen, isMediumScreen, isDark, l10n),
                      ),
                    ),
                    _buildBottomBar(isDark, l10n),
                  ],
                ),
        ),
      ],
    );
  }

  String _getDateSubtitle(AppLocalizations l10n) {
    final now = DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year}';
    return '$dateStr \u2022 ${l10n.mainBranch}';
  }

  Widget _buildContent(bool isWideScreen, bool isMediumScreen, bool isDark, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPeriodInfo(isDark, l10n),
        SizedBox(height: isMediumScreen ? 24 : 16),
        _buildSummary(isWideScreen, isMediumScreen, isDark, l10n),
        SizedBox(height: isMediumScreen ? 24 : 16),
        _buildCustomersList(isDark, l10n),
      ],
    );
  }

  Widget _buildPeriodInfo(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.info.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.calendar_month_rounded, color: AppColors.info, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.closingPeriod(_currentPeriod), style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface, fontSize: 16)),
                if (_lastCloseDate != null)
                  Text(l10n.lastClosing(_lastCloseDate ?? '-'), style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
                Text(l10n.interestRateAndGrace(_interestRate.toString(), _graceDays.toString()), style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(bool isWideScreen, bool isMediumScreen, bool isDark, AppLocalizations l10n) {
    final selectedCustomers = _customers.where((c) => c.isSelected).toList();
    final totalInterest = selectedCustomers.fold<double>(0, (sum, c) => sum + c.expectedInterest);
    final totalDebt = selectedCustomers.fold<double>(0, (sum, c) => sum + c.account.balance);

    final cards = [
      _buildSummaryCard(title: l10n.selectedCustomers, value: '${selectedCustomers.length}', icon: Icons.people_rounded, color: AppColors.info, isDark: isDark),
      _buildSummaryCard(title: l10n.totalDebts, value: '${totalDebt.toStringAsFixed(0)} ${l10n.sar}', icon: Icons.account_balance_rounded, color: AppColors.warning, isDark: isDark),
      _buildSummaryCard(title: l10n.expectedInterests, value: '${totalInterest.toStringAsFixed(2)} ${l10n.sar}', icon: Icons.trending_up_rounded, color: AppColors.success, isDark: isDark),
    ];

    final spacing = isMediumScreen ? 16.0 : 12.0;

    if (isWideScreen) {
      return Row(
        children: cards.asMap().entries.map((entry) {
          return Expanded(
            child: Padding(
              padding: EdgeInsetsDirectional.only(end: entry.key < cards.length - 1 ? spacing : 0),
              child: entry.value,
            ),
          );
        }).toList(),
      );
    }

    return Column(children: [
      Row(children: [Expanded(child: cards[0]), SizedBox(width: spacing), Expanded(child: cards[1])]),
      SizedBox(height: spacing),
      cards[2],
    ]);
  }

  Widget _buildSummaryCard({required String title, required String value, required IconData icon, required Color color, required bool isDark}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 22)),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildCustomersList(bool isDark, AppLocalizations l10n) {
    if (_customers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Center(
          child: Column(children: [
            Icon(Icons.check_circle_rounded, size: 64, color: AppColors.success.withValues(alpha: 0.6)),
            const SizedBox(height: 16),
            Text(l10n.noDebtsNeedClosing, style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 4),
            Text(l10n.allCustomersWithinGrace, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
          ]),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(children: [
            Text(l10n.debtors, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
            const Spacer(),
            Text('${_customers.length}', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ]),
        ),
        const Divider(height: 1),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _customers.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final customer = _customers[index];
            return CheckboxListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              value: customer.isSelected,
              onChanged: (v) => setState(() => _customers[index] = customer.copyWith(isSelected: v!)),
              title: Text(customer.account.name, style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
              subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l10n.debtLabel(customer.account.balance.toStringAsFixed(2)), style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
                Text(l10n.expectedInterestLabel(customer.expectedInterest.toStringAsFixed(2)), style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 12)),
              ]),
              secondary: CircleAvatar(
                backgroundColor: AppColors.info.withValues(alpha: 0.15),
                child: Text(customer.account.name.isNotEmpty ? customer.account.name[0] : '?', style: const TextStyle(color: AppColors.info, fontWeight: FontWeight.bold)),
              ),
              isThreeLine: true,
            );
          },
        ),
      ]),
    );
  }

  Widget _buildBottomBar(bool isDark, AppLocalizations l10n) {
    final selectedCount = _customers.where((c) => c.isSelected).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Row(children: [
        Expanded(child: Text(l10n.selectedCustomerCount(selectedCount), style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))),
        FilledButton.icon(
          onPressed: selectedCount > 0 && !_isProcessing ? _showConfirmationDialog : null,
          icon: _isProcessing
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.check_rounded),
          label: Text(_isProcessing ? l10n.processingClose : l10n.executeClose),
        ),
      ]),
    );
  }

  void _showConfirmationDialog() {
    final l10n = AppLocalizations.of(context);
    final selectedCustomers = _customers.where((c) => c.isSelected).toList();
    final totalInterest = selectedCustomers.fold<double>(0, (sum, c) => sum + c.expectedInterest);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirm),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l10n.interestWillBeAdded(selectedCustomers.length)),
          const SizedBox(height: 8),
          Text(l10n.totalInterestsLabel(totalInterest.toStringAsFixed(2)), style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              const Icon(Icons.warning_rounded, color: AppColors.warning),
              const SizedBox(width: 8),
              Expanded(child: Text(l10n.cannotUndo, style: const TextStyle(fontSize: 13))),
            ]),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _processMonthlyClose();
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  Future<void> _processMonthlyClose() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _isProcessing = true);

    try {
      final selectedCustomers = _customers.where((c) => c.isSelected).toList();

      for (final customer in selectedCustomers) {
        final newBalance = customer.account.balance + customer.expectedInterest;

        await _db.transactionsDao.recordInterest(
          id: 'INT-${DateTime.now().millisecondsSinceEpoch}-${customer.account.id}',
          storeId: customer.account.storeId,
          accountId: customer.account.id,
          amount: customer.expectedInterest,
          balanceAfter: newBalance,
          periodKey: _currentPeriod,
        );

        await _db.accountsDao.addToBalance(customer.account.id, customer.expectedInterest);
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_month_close', _currentPeriod);

      setState(() => _isProcessing = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.monthCloseSuccess(selectedCustomers.length)), backgroundColor: AppColors.success),
        );
        await _loadData();
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.errorOccurred}: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }
}

class _CustomerDebt {
  final AccountsTableData account;
  final double expectedInterest;
  final bool isSelected;

  _CustomerDebt({required this.account, required this.expectedInterest, required this.isSelected});

  _CustomerDebt copyWith({bool? isSelected}) {
    return _CustomerDebt(account: account, expectedInterest: expectedInterest, isSelected: isSelected ?? this.isSelected);
  }
}
