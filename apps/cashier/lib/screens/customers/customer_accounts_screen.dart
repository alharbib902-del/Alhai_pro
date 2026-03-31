/// Customer Accounts Screen - Outstanding balances overview
///
/// Lists customers with outstanding balances.
/// Shows total debt, overdue amount. Filter: all, overdue, paid.
/// Tap navigates to customer detail.
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
import 'package:alhai_design_system/alhai_design_system.dart' show AlhaiBreakpoints;
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

  @override
  void initState() {
    super.initState();
    _loadAccounts();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
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
          passStatus = account.balance > 0 &&
              account.lastTransactionAt != null &&
              DateTime.now()
                      .difference(account.lastTransactionAt!)
                      .inDays >
                  30;
        } else if (_statusFilter == 'paid') {
          passStatus = account.balance <= 0;
        } else if (_statusFilter == 'outstanding') {
          passStatus = account.balance > 0;
        }

        // Search filter
        bool passSearch = true;
        if (query.isNotEmpty) {
          passSearch = account.name.toLowerCase().contains(query) ||
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
          title: 'Customer Accounts',
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
                  message: _error,
                  onRetry: _loadAccounts,
                )
              : Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
                      child: Column(
                        children: [
                          _buildSearchBar(isDark, l10n),
                          const SizedBox(height: 12),
                          _buildStatusFilters(isDark, l10n),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: isMediumScreen ? 24 : 16),
                      child: _buildSummaryStats(isDark, l10n),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: _filteredAccounts.isEmpty
                          ? _buildEmptyState(isDark, l10n)
                          : ListView.separated(
                              padding: EdgeInsets.symmetric(
                                  horizontal: isMediumScreen ? 24 : 16,
                                  vertical: 8),
                              itemCount: _filteredAccounts.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) =>
                                  _buildAccountCard(
                                      _filteredAccounts[index],
                                      isDark,
                                      l10n),
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
        prefixIcon: Icon(Icons.search_rounded,
            color: AppColors.getTextMuted(isDark)),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                onPressed: () => _searchController.clear(),
                icon: Icon(Icons.clear_rounded,
                    color: AppColors.getTextMuted(isDark)),
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          const SizedBox(width: 8),
          _buildChip('Outstanding', _statusFilter == 'outstanding', () {
            setState(() => _statusFilter = 'outstanding');
            _applyFilters();
          }, isDark, icon: Icons.warning_amber_rounded),
          const SizedBox(width: 8),
          _buildChip('Overdue', _statusFilter == 'overdue', () {
            setState(() => _statusFilter = 'overdue');
            _applyFilters();
          }, isDark, icon: Icons.schedule_rounded),
          const SizedBox(width: 8),
          _buildChip('Paid', _statusFilter == 'paid', () {
            setState(() => _statusFilter = 'paid');
            _applyFilters();
          }, isDark, icon: Icons.check_circle_outline_rounded),
        ],
      ),
    );
  }

  Widget _buildChip(
      String label, bool isSelected, VoidCallback onTap, bool isDark,
      {IconData? icon}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : AppColors.getSurfaceVariant(isDark),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.getBorder(isDark)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon,
                  size: 14,
                  color: isSelected
                      ? Colors.white
                      : AppColors.getTextSecondary(isDark)),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : AppColors.getTextSecondary(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryStats(bool isDark, AppLocalizations l10n) {
    final totalDebt = _filteredAccounts
        .where((a) => a.balance > 0)
        .fold<double>(0, (sum, a) => sum + a.balance);
    final overdueCount = _filteredAccounts
        .where((a) =>
            a.balance > 0 &&
            a.lastTransactionAt != null &&
            DateTime.now().difference(a.lastTransactionAt!).inDays > 30)
        .length;
    final count = _filteredAccounts.length;

    return Container(
      padding: const EdgeInsets.all(16),
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
                Text('Customers',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.getTextSecondary(isDark))),
                const SizedBox(height: 4),
                Text('$count',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.getTextPrimary(isDark))),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.getBorder(isDark),
          ),
          Expanded(
            child: Column(
              children: [
                Text(l10n.totalDebit,
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.getTextSecondary(isDark))),
                const SizedBox(height: 4),
                Text('${totalDebt.toStringAsFixed(0)} ${l10n.sar}',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.error)),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.getBorder(isDark),
          ),
          Expanded(
            child: Column(
              children: [
                Text('Overdue',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.getTextSecondary(isDark))),
                const SizedBox(height: 4),
                Text('$overdueCount',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: overdueCount > 0
                            ? AppColors.warning
                            : AppColors.success)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard(
      AccountsTableData account, bool isDark, AppLocalizations l10n) {
    final isDebt = account.balance > 0;
    final isOverdue = isDebt &&
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
        padding: const EdgeInsets.all(16),
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
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                  begin: AlignmentDirectional.topStart,
                  end: AlignmentDirectional.bottomEnd,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
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
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color:
                                AppColors.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'Overdue',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (account.phone != null) ...[
                        Icon(Icons.phone_outlined,
                            size: 13,
                            color: AppColors.getTextMuted(isDark)),
                        const SizedBox(width: 4),
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
                  '${account.balance.abs().toStringAsFixed(0)} ${l10n.sar}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: balanceColor,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
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
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded,
                color: AppColors.getTextMuted(isDark), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, AppLocalizations l10n) {
    return const AppEmptyState(
      icon: Icons.account_balance_wallet_outlined,
      title: 'No customer accounts found',
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
