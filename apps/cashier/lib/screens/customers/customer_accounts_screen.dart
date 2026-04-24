/// Customer Accounts Screen - Outstanding balances overview
///
/// Lists customers with outstanding balances.
/// Shows total debt, overdue amount. Filter: all, overdue, paid.
/// Tap navigates to customer detail.
/// Supports: RTL Arabic, dark/light theme, responsive layout.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_design_system/alhai_design_system.dart'
    show AlhaiBreakpoints, AlhaiSpacing;
// alhai_design_system is re-exported via alhai_shared_ui
import '../../core/services/sentry_service.dart';

/// شاشة حسابات العملاء
class CustomerAccountsScreen extends ConsumerStatefulWidget {
  const CustomerAccountsScreen({super.key});

  @override
  ConsumerState<CustomerAccountsScreen> createState() =>
      _CustomerAccountsScreenState();
}

class _CustomerAccountsScreenState
    extends ConsumerState<CustomerAccountsScreen> {
  final _searchController = TextEditingController();
  final _db = GetIt.I<AppDatabase>();
  List<AccountsTableData> _allAccounts = [];
  List<AccountsTableData> _filteredAccounts = [];
  bool _isLoading = true;
  String? _error;
  String _statusFilter = 'all';

  // Debounce search filter — avoids re-running the filter + setState rebuild
  // on every keystroke (P1 #1). The 500-row cap means each run is cheap, but
  // the subtree rebuild churns the ListView — debounce collapses rapid typing
  // into a single recompute.
  Timer? _searchDebounce;
  String _lastAppliedQuery = '';

  @override
  void initState() {
    super.initState();
    _loadAccounts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final q = _searchController.text;
    // Skip when nothing actually changed (setState from clear() + listener).
    if (q == _lastAppliedQuery) return;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      _lastAppliedQuery = q;
      _applyFilters();
    });
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
      if (mounted) {
        setState(() {
          _allAccounts = accounts;
          _isLoading = false;
        });
        _applyFilters();
      }
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Load customer accounts');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = '$e';
        });
      }
    }
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      _filteredAccounts = _allAccounts.where((account) {
        // Status filter
        bool passStatus = true;
        if (_statusFilter == 'overdue') {
          passStatus =
              account.balance > 0 &&
              account.lastTransactionAt != null &&
              DateTime.now().difference(account.lastTransactionAt!).inDays > 30;
        } else if (_statusFilter == 'paid') {
          passStatus = account.balance <= 0;
        } else if (_statusFilter == 'outstanding') {
          passStatus = account.balance > 0;
        }

        // Search filter
        bool passSearch = true;
        if (query.isNotEmpty) {
          passSearch =
              account.name.toLowerCase().contains(query) ||
              (account.phone?.toLowerCase().contains(query) ?? false);
        }

        return passStatus && passSearch;
      }).toList();

      // Sort by balance descending
      _filteredAccounts.sort((a, b) => b.balance.compareTo(a.balance));
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
          title: l10n.customerAccounts,
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
              ? const AppLoadingState()
              : _error != null
              ? AppErrorState.general(
                  context,
                  message: _error,
                  onRetry: _loadAccounts,
                )
              : Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(
                        isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md,
                      ),
                      child: Column(
                        children: [
                          _buildSearchBar(isDark, l10n),
                          const SizedBox(height: AlhaiSpacing.sm),
                          _buildStatusFilters(isDark, l10n),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMediumScreen ? 24 : 16,
                      ),
                      child: _buildSummaryStats(isDark, l10n),
                    ),
                    const SizedBox(height: AlhaiSpacing.sm),
                    Expanded(
                      child: _filteredAccounts.isEmpty
                          ? _buildEmptyState(isDark, l10n)
                          : ListView.separated(
                              padding: EdgeInsets.symmetric(
                                horizontal: isMediumScreen ? 24 : 16,
                                vertical: AlhaiSpacing.xs,
                              ),
                              itemCount: _filteredAccounts.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: AlhaiSpacing.xs),
                              itemBuilder: (context, index) =>
                                  _buildAccountCard(
                                    _filteredAccounts[index],
                                    isDark,
                                    l10n,
                                  ),
                            ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  String _getDateSubtitle(AppLocalizations l10n) {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year} \u2022 ${l10n.mainBranch}';
  }

  Widget _buildSearchBar(bool isDark, AppLocalizations l10n) {
    return TextField(
      controller: _searchController,
      style: TextStyle(color: AppColors.getTextPrimary(isDark)),
      decoration: InputDecoration(
        hintText: l10n.searchPlaceholder,
        hintStyle: TextStyle(color: AppColors.getTextMuted(isDark)),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: AppColors.getTextMuted(isDark),
        ),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                onPressed: () => _searchController.clear(),
                icon: Icon(
                  Icons.clear_rounded,
                  color: AppColors.getTextMuted(isDark),
                ),
                tooltip: l10n.clearField,
              )
            : null,
        filled: true,
        fillColor: AppColors.getSurface(isDark),
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
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AlhaiSpacing.md,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildStatusFilters(bool isDark, AppLocalizations l10n) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip(l10n.allMovements, _statusFilter == 'all', () {
            setState(() => _statusFilter = 'all');
            _applyFilters();
          }, isDark),
          const SizedBox(width: AlhaiSpacing.xs),
          _buildChip(
            l10n.outstanding,
            _statusFilter == 'outstanding',
            () {
              setState(() => _statusFilter = 'outstanding');
              _applyFilters();
            },
            isDark,
            icon: Icons.warning_amber_rounded,
          ),
          const SizedBox(width: AlhaiSpacing.xs),
          _buildChip(
            l10n.overdue,
            _statusFilter == 'overdue',
            () {
              setState(() => _statusFilter = 'overdue');
              _applyFilters();
            },
            isDark,
            icon: Icons.schedule_rounded,
          ),
          const SizedBox(width: AlhaiSpacing.xs),
          _buildChip(
            l10n.paidLabel,
            _statusFilter == 'paid',
            () {
              setState(() => _statusFilter = 'paid');
              _applyFilters();
            },
            isDark,
            icon: Icons.check_circle_outline_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildChip(
    String label,
    bool isSelected,
    VoidCallback onTap,
    bool isDark, {
    IconData? icon,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: AlhaiSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : AppColors.getSurfaceVariant(isDark),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.getBorder(isDark),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isSelected
                    ? AppColors.textOnPrimary
                    : AppColors.getTextSecondary(isDark),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AppColors.textOnPrimary
                    : AppColors.getTextSecondary(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryStats(bool isDark, AppLocalizations l10n) {
    // accounts.balance is int cents (C-4 schema). Divide at fold boundary
    // so the SAR accumulator does not display 100×.
    final totalDebt = _filteredAccounts
        .where((a) => a.balance > 0)
        .fold<double>(0, (sum, a) => sum + a.balance / 100.0);
    final overdueCount = _filteredAccounts
        .where(
          (a) =>
              a.balance > 0 &&
              a.lastTransactionAt != null &&
              DateTime.now().difference(a.lastTransactionAt!).inDays > 30,
        )
        .length;
    final count = _filteredAccounts.length;

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  l10n.customers,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.getTextSecondary(isDark),
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.xxs),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 40, color: AppColors.getBorder(isDark)),
          Expanded(
            child: Column(
              children: [
                Text(
                  l10n.totalDebit,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.getTextSecondary(isDark),
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.xxs),
                Text(
                  CurrencyFormatter.formatCompactWithContext(
                    context,
                    totalDebt,
                  ),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 40, color: AppColors.getBorder(isDark)),
          Expanded(
            child: Column(
              children: [
                Text(
                  l10n.overdue,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.getTextSecondary(isDark),
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.xxs),
                Text(
                  '$overdueCount',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: overdueCount > 0
                        ? AppColors.warning
                        : AppColors.success,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard(
    AccountsTableData account,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final isDebt = account.balance > 0;
    final isOverdue =
        isDebt &&
        account.lastTransactionAt != null &&
        DateTime.now().difference(account.lastTransactionAt!).inDays > 30;
    final balanceColor = isDebt ? AppColors.error : AppColors.success;
    final initials = _getInitials(account.name);

    return InkWell(
      onTap: () {
        if (account.customerId != null) {
          context.push('/customers/${account.customerId}');
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(AlhaiSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.getSurface(isDark),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isOverdue
                ? AppColors.warning.withValues(alpha: 0.4)
                : AppColors.getBorder(isDark),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: AppColors.avatarGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textOnPrimary,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          account.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.getTextPrimary(isDark),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isOverdue) ...[
                        const SizedBox(width: AlhaiSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: AlhaiSpacing.xxxs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            l10n.overdue,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AlhaiSpacing.xxs),
                  Row(
                    children: [
                      if (account.phone != null) ...[
                        Icon(
                          Icons.phone_outlined,
                          size: 13,
                          color: AppColors.getTextMuted(isDark),
                          semanticLabel: l10n.phone,
                        ),
                        const SizedBox(width: AlhaiSpacing.xxs),
                        Text(
                          account.phone!,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.getTextSecondary(isDark),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  CurrencyFormatter.fromCentsWithContext(
                    context,
                    account.balance.abs(),
                    decimalDigits: 0,
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: balanceColor,
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.xxs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AlhaiSpacing.xs,
                    vertical: AlhaiSpacing.xxxs,
                  ),
                  decoration: BoxDecoration(
                    color: balanceColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    isDebt ? l10n.dueOnCustomer : l10n.customerHasCredit,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: balanceColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: AlhaiSpacing.xs),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.getTextMuted(isDark),
              size: 20,
              semanticLabel: l10n.details,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, AppLocalizations l10n) {
    // P2 #1: hard-coded English removed. No l10n key for "no customer
    // accounts" exists yet; use direct Arabic (primary locale for this app)
    // — matches the policy used elsewhere in the customer flow headers.
    return const AppEmptyState(
      icon: Icons.account_balance_wallet_outlined,
      title: 'لا توجد حسابات عملاء',
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
