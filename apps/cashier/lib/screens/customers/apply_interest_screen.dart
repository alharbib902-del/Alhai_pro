/// Apply Interest Screen - Apply interest to outstanding customer debts
///
/// Select customers with outstanding debt, set interest rate,
/// preview calculation, and apply.
/// Supports: RTL Arabic, dark/light theme, responsive layout.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_auth/alhai_auth.dart';
// alhai_design_system is re-exported via alhai_shared_ui

/// شاشة تطبيق الفائدة
class ApplyInterestScreen extends ConsumerStatefulWidget {
  const ApplyInterestScreen({super.key});

  @override
  ConsumerState<ApplyInterestScreen> createState() =>
      _ApplyInterestScreenState();
}

class _ApplyInterestScreenState extends ConsumerState<ApplyInterestScreen> {
  final _db = GetIt.I<AppDatabase>();
  final _rateController = TextEditingController(text: '5');
  List<AccountsTableData> _accounts = [];
  final Set<String> _selectedIds = {};
  bool _isLoading = true;
  bool _isApplying = false;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  @override
  void dispose() {
    _rateController.dispose();
    super.dispose();
  }

  Future<void> _loadAccounts() async {
    setState(() => _isLoading = true);
    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;
      final accounts = await _db.accountsDao.getReceivableAccounts(storeId);
      // Only accounts with outstanding balance
      final withDebt =
          accounts.where((a) => a.balance > 0).toList();
      withDebt.sort((a, b) => b.balance.compareTo(a.balance));
      if (mounted) {
        setState(() {
          _accounts = withDebt;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  double get _rate => double.tryParse(_rateController.text) ?? 0;

  double _calculateInterest(double balance) {
    return balance * (_rate / 100);
  }

  double get _totalInterest {
    return _accounts
        .where((a) => _selectedIds.contains(a.id))
        .fold<double>(0, (sum, a) => sum + _calculateInterest(a.balance));
  }

  double get _totalDebt {
    return _accounts
        .where((a) => _selectedIds.contains(a.id))
        .fold<double>(0, (sum, a) => sum + a.balance);
  }

  void _toggleSelect(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _selectAll() {
    setState(() {
      if (_selectedIds.length == _accounts.length) {
        _selectedIds.clear();
      } else {
        _selectedIds
          ..clear()
          ..addAll(_accounts.map((a) => a.id));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isMediumScreen = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(currentUserProvider);

    return Column(
      children: [
        AppHeader(
          title: 'Apply Interest',
          subtitle: _getDateSubtitle(l10n),
          showSearch: false,
          searchHint: l10n.searchPlaceholder,
          onMenuTap: isWideScreen
              ? null
              : () => Scaffold.of(context).openDrawer(),
          onNotificationsTap: () => context.push('/notifications'),
          notificationsCount: 3,
          userName: user?.name ?? l10n.cashCustomer,
          userRole: l10n.branchManager,
          onUserTap: () {},
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _accounts.isEmpty
                  ? _buildNoAccountsMessage(isDark, l10n)
                  : SingleChildScrollView(
                      padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
                      child: isWideScreen
                          ? Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: _buildCustomersList(
                                      isDark, l10n),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    children: [
                                      _buildRateCard(isDark, l10n),
                                      const SizedBox(height: 24),
                                      _buildPreviewCard(isDark, l10n),
                                      const SizedBox(height: 24),
                                      _buildApplyButton(isDark, l10n),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.stretch,
                              children: [
                                _buildRateCard(isDark, l10n),
                                SizedBox(
                                    height:
                                        isMediumScreen ? 24 : 16),
                                _buildCustomersList(isDark, l10n),
                                SizedBox(
                                    height:
                                        isMediumScreen ? 24 : 16),
                                _buildPreviewCard(isDark, l10n),
                                const SizedBox(height: 24),
                                _buildApplyButton(isDark, l10n),
                                const SizedBox(height: 24),
                              ],
                            ),
                    ),
        ),
      ],
    );
  }

  String _getDateSubtitle(AppLocalizations l10n) {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year} \u2022 ${l10n.mainBranch}';
  }

  Widget _buildNoAccountsMessage(bool isDark, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.account_balance_wallet_outlined,
              size: 64, color: AppColors.getTextMuted(isDark)),
          const SizedBox(height: 16),
          Text('No outstanding debts',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextSecondary(isDark))),
          const SizedBox(height: 8),
          Text('All customer accounts are settled',
              style: TextStyle(
                  fontSize: 13,
                  color: AppColors.getTextMuted(isDark))),
        ],
      ),
    );
  }

  Widget _buildRateCard(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.percent_rounded,
                    color: AppColors.warning, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Interest Rate',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _rateController,
            keyboardType: TextInputType.number,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(isDark),
            ),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: TextStyle(
                color: AppColors.getTextMuted(isDark),
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              suffixText: '%',
              suffixStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.warning),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: AppColors.getBorder(isDark)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: AppColors.getBorder(isDark)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: AppColors.warning, width: 2),
              ),
              filled: true,
              fillColor: AppColors.getSurfaceVariant(isDark),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [2, 5, 10, 15].map((rate) {
              final isSelected = _rateController.text == rate.toString();
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    _rateController.text = rate.toString();
                    setState(() {});
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.warning.withValues(alpha: 0.1)
                          : AppColors.getSurfaceVariant(isDark),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.warning.withValues(alpha: 0.5)
                            : AppColors.getBorder(isDark),
                      ),
                    ),
                    child: Text('$rate%',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.warning
                                : AppColors.getTextSecondary(isDark))),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomersList(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.people_rounded,
                    color: AppColors.info, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Select Customers',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
              ),
              TextButton(
                onPressed: _selectAll,
                child: Text(
                  _selectedIds.length == _accounts.length
                      ? 'Deselect All'
                      : 'Select All',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._accounts.map((account) {
            final isSelected = _selectedIds.contains(account.id);
            final interest = _calculateInterest(account.balance);
            final initials = _getInitials(account.name);

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => _toggleSelect(account.id),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                            .withValues(alpha: isDark ? 0.12 : 0.06)
                        : AppColors.getSurfaceVariant(isDark),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.5)
                          : AppColors.getBorder(isDark),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.getBorder(isDark),
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check_rounded,
                                size: 16, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF3B82F6),
                              Color(0xFF2563EB)
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(initials,
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(account.name,
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.getTextPrimary(
                                        isDark))),
                            Text(
                              '${l10n.balanceCol}: ${account.balance.toStringAsFixed(0)} ${l10n.sar}',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.getTextSecondary(
                                      isDark)),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '+${interest.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.warning,
                              ),
                            ),
                            Text(
                              l10n.sar,
                              style: TextStyle(
                                  fontSize: 10,
                                  color:
                                      AppColors.getTextMuted(isDark)),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPreviewCard(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.preview_rounded,
                    color: AppColors.success, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Preview',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPreviewRow(
              'Selected Customers', '${_selectedIds.length}', isDark),
          const SizedBox(height: 8),
          _buildPreviewRow(
              'Interest Rate', '${_rate.toStringAsFixed(1)}%', isDark),
          const SizedBox(height: 8),
          _buildPreviewRow('Total Debt',
              '${_totalDebt.toStringAsFixed(2)} ${l10n.sar}', isDark),
          Divider(height: 24, color: AppColors.getBorder(isDark)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Interest',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
              Text(
                '${_totalInterest.toStringAsFixed(2)} ${l10n.sar}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 13,
                color: AppColors.getTextSecondary(isDark))),
        Text(value,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.getTextPrimary(isDark))),
      ],
    );
  }

  Widget _buildApplyButton(bool isDark, AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _isApplying || _selectedIds.isEmpty || _rate <= 0
            ? null
            : () => _applyInterest(l10n),
        icon: _isApplying
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.percent_rounded, size: 20),
        label: const Text('Apply Interest',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600)),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.warning,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Future<void> _applyInterest(AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Interest'),
        content: Text(
            'Apply ${_rate.toStringAsFixed(1)}% interest to ${_selectedIds.length} accounts?\n'
            'Total interest: ${_totalInterest.toStringAsFixed(2)} ${l10n.sar}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.warning),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isApplying = true);

    try {
      final storeId = ref.read(currentStoreIdProvider) ?? 'demo-store';
      final user = ref.read(currentUserProvider);
      final now = DateTime.now();
      final periodKey =
          '${now.year}-${now.month.toString().padLeft(2, '0')}';

      for (final accountId in _selectedIds) {
        final account = _accounts.firstWhere((a) => a.id == accountId);
        final interest = _calculateInterest(account.balance);
        if (interest <= 0) continue;

        final newBalance = account.balance + interest;
        final txnId = 'INT-${now.millisecondsSinceEpoch}-$accountId';

        await _db.transactionsDao.recordInterest(
          id: txnId,
          storeId: storeId,
          accountId: accountId,
          amount: interest,
          balanceAfter: newBalance,
          periodKey: periodKey,
          createdBy: user?.name,
        );
        await _db.accountsDao.updateBalance(accountId, newBalance);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.success),
          backgroundColor: AppColors.success,
        ),
      );

      _selectedIds.clear();
      await _loadAccounts();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorWithDetails('$e')),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isApplying = false);
    }
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
