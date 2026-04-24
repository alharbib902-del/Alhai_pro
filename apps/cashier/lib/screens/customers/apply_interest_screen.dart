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
import 'package:alhai_sync/alhai_sync.dart' show SyncPriority;
import 'package:uuid/uuid.dart';
import 'package:alhai_design_system/alhai_design_system.dart'
    show AlhaiBreakpoints, AlhaiSnackbar, AlhaiSpacing;
// alhai_design_system is re-exported via alhai_shared_ui
import '../../core/services/sentry_service.dart';
import '../../core/services/audit_service.dart';

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
  String? _error;

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
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;
      final accounts = await _db.accountsDao.getReceivableAccounts(storeId);
      // Only accounts with outstanding balance
      final withDebt = accounts.where((a) => a.balance > 0).toList();
      withDebt.sort((a, b) => b.balance.compareTo(a.balance));
      if (mounted) {
        setState(() {
          _accounts = withDebt;
          _isLoading = false;
        });
      }
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Load accounts for interest');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = '$e';
        });
      }
    }
  }

  double get _rate => double.tryParse(_rateController.text) ?? 0;

  double _calculateInterest(double balance) {
    return balance * (_rate / 100);
  }

  double get _totalInterest {
    // C-4 Session 4: accounts.balance is int cents; convert to SAR double.
    return _accounts
        .where((a) => _selectedIds.contains(a.id))
        .fold<double>(0, (sum, a) => sum + _calculateInterest(a.balance / 100.0));
  }

  double get _totalDebt {
    // C-4 Session 4: accounts.balance is int cents; convert to SAR double.
    return _accounts
        .where((a) => _selectedIds.contains(a.id))
        .fold<double>(0, (sum, a) => sum + a.balance / 100.0);
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
    final isWideScreen = size.width >= AlhaiBreakpoints.desktop;
    final isMediumScreen = size.width >= AlhaiBreakpoints.tablet;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider);

    return Column(
      children: [
        AppHeader(
          title: l10n.applyInterest,
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
          // Phase 4.4 — AnimatedSwitcher softens the loading → content swap.
          // Each branch needs a unique ValueKey so the switcher can tell them
          // apart and crossfade correctly; without distinct keys Flutter
          // treats the subtree as "same child" and skips the animation.
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _isLoading
                ? const AppLoadingState(key: ValueKey('apply-interest-loading'))
                : _error != null
                ? KeyedSubtree(
                    key: const ValueKey('apply-interest-error'),
                    child: AppErrorState.general(
                      context,
                      message: _error!,
                      onRetry: _loadAccounts,
                    ),
                  )
                : _accounts.isEmpty
                ? KeyedSubtree(
                    key: const ValueKey('apply-interest-empty'),
                    child: _buildNoAccountsMessage(isDark, l10n),
                  )
                : SingleChildScrollView(
                    key: const ValueKey('apply-interest-content'),
                    padding: EdgeInsets.all(
                      isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md,
                    ),
                    child: isWideScreen
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: _buildCustomersList(isDark, l10n),
                              ),
                              const SizedBox(width: AlhaiSpacing.lg),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  children: [
                                    _buildRateCard(isDark, l10n),
                                    const SizedBox(height: AlhaiSpacing.lg),
                                    _buildPreviewCard(isDark, l10n),
                                    const SizedBox(height: AlhaiSpacing.lg),
                                    _buildApplyButton(isDark, l10n),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildRateCard(isDark, l10n),
                              SizedBox(
                                height: isMediumScreen
                                    ? AlhaiSpacing.lg
                                    : AlhaiSpacing.md,
                              ),
                              _buildCustomersList(isDark, l10n),
                              SizedBox(
                                height: isMediumScreen
                                    ? AlhaiSpacing.lg
                                    : AlhaiSpacing.md,
                              ),
                              _buildPreviewCard(isDark, l10n),
                              const SizedBox(height: AlhaiSpacing.lg),
                              _buildApplyButton(isDark, l10n),
                              const SizedBox(height: AlhaiSpacing.lg),
                            ],
                          ),
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
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 64,
            color: AppColors.getTextMuted(isDark),
          ),
          const SizedBox(height: AlhaiSpacing.md),
          Text(
            l10n.noOutstandingDebts,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xs),
          Text(
            l10n.allAccountsSettled,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.getTextMuted(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRateCard(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
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
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.percent_rounded,
                  color: AppColors.warning,
                  size: 20,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(
                l10n.interestRate,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.md),
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
                color: AppColors.warning,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.getBorder(isDark)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.getBorder(isDark)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.warning,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: AppColors.getSurfaceVariant(isDark),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.sm),
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
                      horizontal: AlhaiSpacing.md,
                      vertical: 10,
                    ),
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
                    child: Text(
                      '$rate%',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppColors.warning
                            : AppColors.getTextSecondary(isDark),
                      ),
                    ),
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
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
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
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.people_rounded,
                  color: AppColors.info,
                  size: 20,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Expanded(
                child: Text(
                  l10n.selectCustomers,
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
                      ? l10n.deselectAll
                      : l10n.selectAll,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.sm),
          ..._accounts.map((account) {
            final isSelected = _selectedIds.contains(account.id);
            // C-4 Session 4: accounts.balance is int cents; convert to SAR double.
            final interest = _calculateInterest(account.balance / 100.0);
            final initials = _getInitials(account.name);

            return Padding(
              padding: const EdgeInsetsDirectional.only(
                bottom: AlhaiSpacing.xs,
              ),
              child: InkWell(
                onTap: () => _toggleSelect(account.id),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(
                            alpha: isDark ? 0.12 : 0.06,
                          )
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
                            ? const Icon(
                                Icons.check_rounded,
                                size: 16,
                                color: AppColors.textOnPrimary,
                              )
                            : null,
                      ),
                      const SizedBox(width: AlhaiSpacing.sm),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: AppColors.avatarGradient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initials,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textOnPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: AlhaiSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              account.name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.getTextPrimary(isDark),
                              ),
                            ),
                            Text(
                              // C-4 Session 4: accounts.balance is int cents.
                              // Use CurrencyFormatter for grouping separators
                              // (P1 #8). `decimalDigits: 0` to match the
                              // previous 0-decimal display.
                              '${l10n.balanceCol}: '
                              '${CurrencyFormatter.fromCentsWithContext(context, account.balance, decimalDigits: 0)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.getTextSecondary(isDark),
                              ),
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
                                color: AppColors.getTextMuted(isDark),
                              ),
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
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
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
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.preview_rounded,
                  color: AppColors.success,
                  size: 20,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(
                l10n.preview,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.md),
          _buildPreviewRow(
            l10n.selectedCustomers,
            '${_selectedIds.length}',
            isDark,
          ),
          const SizedBox(height: AlhaiSpacing.xs),
          _buildPreviewRow(
            l10n.interestRate,
            '${_rate.toStringAsFixed(1)}%',
            isDark,
          ),
          const SizedBox(height: AlhaiSpacing.xs),
          _buildPreviewRow(
            l10n.totalDebt,
            '${_totalDebt.toStringAsFixed(2)} ${l10n.sar}',
            isDark,
          ),
          Divider(height: 24, color: AppColors.getBorder(isDark)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.totalInterest,
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
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.getTextSecondary(isDark),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.getTextPrimary(isDark),
          ),
        ),
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
                  strokeWidth: 2,
                  color: AppColors.textOnPrimary,
                ),
              )
            : const Icon(Icons.percent_rounded, size: 20),
        label: Text(
          l10n.applyInterest,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.warning,
          foregroundColor: AppColors.textOnPrimary,
          padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Future<void> _applyInterest(AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.confirmInterest),
        content: Text(
          l10n.confirmInterestMessage(
            _rate.toStringAsFixed(1),
            _selectedIds.length,
            _totalInterest.toStringAsFixed(2),
            l10n.sar,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.warning),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isApplying = true);

    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;
      final user = ref.read(currentUserProvider);
      final syncService = ref.read(syncServiceProvider);
      final now = DateTime.now();
      final periodKey = '${now.year}-${now.month.toString().padLeft(2, '0')}';

      // C-4 §4h — Idempotency + sync enqueue:
      // كنا نسمح بضغط "تطبيق" مرتين في نفس الشهر → فائدة مزدوجة. الآن
      // نفحص hasInterestForPeriod لكل حساب ونتجاهل المُطَبَّق مسبقاً.
      // ونضع كل معاملة + تحديث رصيد في sync_queue لأن الجداول
      // bidirectional ولن تُدفَع تلقائياً للسيرفر بدون enqueue.
      final appliedTxns = <_AppliedInterest>[];
      int skipped = 0;

      await _db.transaction(() async {
        for (final accountId in _selectedIds) {
          // Re-fetch each account inside the transaction to defeat TOCTOU:
          // the in-memory `_accounts` snapshot may be stale if a sale, a
          // payment, or a sync pulled new data since the UI loaded. Using
          // a stale balance would write the wrong `balance_after` row.
          final account = await _db.accountsDao.getAccountById(accountId);
          if (account == null) continue;
          final balanceSar = account.balance / 100.0;
          final interest = _calculateInterest(balanceSar);
          if (interest <= 0) continue;

          // Idempotency guard: لا نطبّق فائدة مرتين على نفس الحساب في
          // نفس الشهر (YYYY-MM). DAO method يفحص جدول transactions.
          final alreadyApplied = await _db.transactionsDao
              .hasInterestForPeriod(accountId, periodKey);
          if (alreadyApplied) {
            skipped++;
            continue;
          }

          final newBalance = balanceSar + interest;
          // P2 #4: `now.millisecondsSinceEpoch` reused for every account in
          // this tight loop would collide if two accounts shared the same
          // millisecond tick. `Uuid().v4()` is globally unique and already
          // imported, so use it for the txn id (prefix retained for log
          // filtering — interest transactions are easy to grep for).
          final txnId = 'INT-${const Uuid().v4()}';

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

          appliedTxns.add(
            _AppliedInterest(
              txnId: txnId,
              accountId: accountId,
              amountSar: interest,
              balanceAfterSar: newBalance,
            ),
          );
        }
      });

      // Sync enqueue خارج الـ transaction — الـ writes إلى sync_queue
      // يجب ألا تمنع الـ DB transaction من الـ commit.
      for (final entry in appliedTxns) {
        try {
          await syncService.enqueueCreate(
            tableName: 'transactions',
            recordId: entry.txnId,
            data: {
              'id': entry.txnId,
              'storeId': storeId,
              'accountId': entry.accountId,
              'type': 'interest',
              'amount': (entry.amountSar * 100).round(),
              'balanceAfter': (entry.balanceAfterSar * 100).round(),
              'periodKey': periodKey,
              'createdBy': user?.name,
              'createdAt': now.toIso8601String(),
            },
            priority: SyncPriority.high,
          );
          await syncService.enqueueUpdate(
            tableName: 'accounts',
            recordId: entry.accountId,
            changes: {
              'id': entry.accountId,
              'balance': (entry.balanceAfterSar * 100).round(),
              'lastTransactionAt': now.toIso8601String(),
              'updatedAt': now.toIso8601String(),
            },
            priority: SyncPriority.high,
          );
        } catch (e, stack) {
          // sync enqueue فشل = لا يمنع نجاح البيع المحلي؛ ستُلتقَط في
          // المزامنة الدورية التالية. Sentry يسجل لنعرف إن كانت مشكلة
          // دائمة.
          reportError(
            e,
            stackTrace: stack,
            hint: 'Apply interest sync enqueue (txn=${entry.txnId})',
          );
        }
      }

      // Audit log
      auditService.logInterestApply(
        storeId: storeId,
        userId: user?.id ?? 'unknown',
        userName: user?.name ?? 'unknown',
        accountCount: appliedTxns.length,
        rate: _rate,
        totalInterest: _totalInterest,
      );

      if (!mounted) return;
      final msg = skipped > 0
          ? l10n.interestAppliedWithSkipped(appliedTxns.length, skipped)
          : l10n.success;
      AlhaiSnackbar.success(context, msg);

      _selectedIds.clear();
      await _loadAccounts();
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Apply interest to accounts');
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 48,
          ),
          title: Text(l10n.error),
          content: Text(l10n.errorWithDetails('$e')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.close),
            ),
          ],
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

/// قيمة مؤقتة داخلية لتمرير نتائج عمليات الفائدة المُطبَّقة إلى مرحلة
/// Sync enqueue (التي تجري خارج الـ DB transaction).
class _AppliedInterest {
  final String txnId;
  final String accountId;
  final double amountSar;
  final double balanceAfterSar;

  const _AppliedInterest({
    required this.txnId,
    required this.accountId,
    required this.amountSar,
    required this.balanceAfterSar,
  });
}
