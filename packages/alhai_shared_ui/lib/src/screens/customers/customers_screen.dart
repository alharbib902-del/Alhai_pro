import 'dart:async';

import '../../widgets/common/adaptive_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/validators/input_sanitizer.dart';
import '../../core/router/routes.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../utils/number_formatter.dart';
import '../../widgets/common/common.dart';
/// شاشة العملاء - تصميم Web محسّن مع DataTable
class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  final _keyboardFocusNode = FocusNode();

  String _filterType = 'all'; // all, debtors, creditors
  String _sortBy = 'name'; // name, balance, recent
  bool _sortAscending = true;
  bool _showFilters = true;

  final _scrollController = ScrollController();
  List<AccountsTableData> _accounts = [];
  final Set<String> _selectedIds = {};
  bool _isLoading = true;
  String? _error;
  bool _hasMoreData = true;
  bool _isLoadingMore = false;
  bool _showScrollToTop = false;
  static const int _pageSize = 50;
  int _currentPage = 0;

  Timer? _searchDebounce;

  // Cached filtered results
  List<AccountsTableData>? _cachedFiltered;
  String? _lastFilterType;
  String? _lastSearchQuery;
  String? _lastSortBy;
  bool? _lastSortAscending;
  int? _lastAccountsHash;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadCustomers();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _keyboardFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Scroll-to-top FAB visibility
    final showFab = _scrollController.offset > 500;
    if (showFab != _showScrollToTop) {
      setState(() => _showScrollToTop = showFab);
    }
    // Load more pagination
    if (_hasMoreData &&
        !_isLoadingMore &&
        !_isLoading &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
      _loadMoreCustomers();
    }
  }

  Future<void> _loadMoreCustomers() async {
    if (_isLoadingMore || !_hasMoreData || _isLoading) return;
    setState(() => _isLoadingMore = true);
    try {
      final db = GetIt.I<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId != null) {
        final nextPage = _currentPage + 1;
        final moreAccounts = await db.accountsDao.getAccountsPaginated(
          storeId,
          offset: nextPage * _pageSize,
          limit: _pageSize,
        );
        if (mounted) {
          setState(() {
            _accounts.addAll(moreAccounts);
            _currentPage = nextPage;
            _hasMoreData = moreAccounts.length >= _pageSize;
            _isLoadingMore = false;
            _cachedFiltered = null; // invalidate cache
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  Future<void> _loadCustomers() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _currentPage = 0;
      _hasMoreData = true;
    });
    try {
      final db = GetIt.I<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider);

      if (storeId != null) {
        final accounts = await db.accountsDao.getAccountsPaginated(
          storeId,
          offset: 0,
          limit: _pageSize,
        );
        setState(() {
          _accounts = accounts;
          _isLoading = false;
          _hasMoreData = accounts.length >= _pageSize;
          _cachedFiltered = null; // invalidate cache
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  List<AccountsTableData> get _filteredCustomers {
    final currentQuery = _searchController.text.toLowerCase();
    final accountsHash = _accounts.length;

    if (_cachedFiltered != null &&
        _lastFilterType == _filterType &&
        _lastSearchQuery == currentQuery &&
        _lastSortBy == _sortBy &&
        _lastSortAscending == _sortAscending &&
        _lastAccountsHash == accountsHash) {
      return _cachedFiltered!;
    }

    var result = List<AccountsTableData>.of(_accounts);

    // Apply filter
    if (_filterType == 'debtors') {
      result = result.where((c) => c.balance > 0 && c.type == 'receivable').toList();
    } else if (_filterType == 'creditors') {
      result = result.where((c) => c.balance < 0 || c.type == 'payable').toList();
    }

    // Apply search
    if (currentQuery.isNotEmpty) {
      result = result.where((c) =>
          c.name.toLowerCase().contains(currentQuery) ||
          (c.phone?.contains(currentQuery) ?? false)).toList();
    }

    // Apply sort
    result.sort((a, b) {
      int comparison;
      switch (_sortBy) {
        case 'balance':
          comparison = a.balance.compareTo(b.balance);
          break;
        case 'recent':
          comparison = (b.createdAt).compareTo(a.createdAt);
          break;
        default:
          comparison = a.name.compareTo(b.name);
      }
      return _sortAscending ? comparison : -comparison;
    });

    _cachedFiltered = result;
    _lastFilterType = _filterType;
    _lastSearchQuery = currentQuery;
    _lastSortBy = _sortBy;
    _lastSortAscending = _sortAscending;
    _lastAccountsHash = accountsHash;

    return result;
  }

  // Stats calculations
  int get _totalCustomers => _accounts.length;
  double get _totalDebt => _accounts
      .where((c) => c.balance > 0 && c.type == 'receivable')
      .fold(0.0, (sum, c) => sum + c.balance);
  double get _totalCredit => _accounts
      .where((c) => c.balance < 0)
      .fold(0.0, (sum, c) => sum + c.balance.abs());
  int get _debtorsCount => _accounts
      .where((c) => c.balance > 0 && c.type == 'receivable')
      .length;

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.screenWidth >= AppSizes.breakpointTablet;
    final isLandscape = MediaQuery.orientationOf(context) == Orientation.landscape;
    // Show filter panel on desktop OR on landscape tablet
    final showFilterPanel = isDesktop || (isLandscape && !context.isMobile);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return KeyboardListener(
      focusNode: _keyboardFocusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        floatingActionButton: AnimatedScale(
          scale: _showScrollToTop ? 1.0 : 0.0,
          duration: AlhaiDurations.standard,
          child: FloatingActionButton.small(
            onPressed: () => _scrollController.animateTo(
              0,
              duration: AlhaiDurations.slow,
              curve: AlhaiMotion.standardDecelerate,
            ),
            child: const Icon(Icons.arrow_upward),
          ),
        ),
        body: Column(
          children: [
            // Header
            _buildHeader(context, isDark, l10n),
            // Stats Cards
            _buildStatsRow(isDark, l10n),
            // Content
            Expanded(
              child: Row(
                children: [
                  // Filters Sidebar (Desktop or landscape tablet)
                  if (showFilterPanel && _showFilters) _buildFiltersSidebar(isDark, l10n),
                  // Customers List/Table
                  Expanded(child: _buildCustomersContent(isDark, l10n)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, AppLocalizations l10n) {
    final isDesktop = context.screenWidth >= AppSizes.breakpointTablet;

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        border: Border(bottom: BorderSide(color: AppColors.getBorder(isDark))),
      ),
      child: Column(
        children: [
          // Title Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSizes.sm),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                          ),
                          child: const Icon(
                            Icons.people_rounded,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: AppSizes.sm),
                        Text(
                          l10n.customers,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.getTextPrimary(isDark),
                          ),
                        ),
                        const SizedBox(width: AppSizes.sm),
                        AppCountBadge(
                          count: _totalCustomers,
                          backgroundColor: AppColors.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.xs),
                    Text(
                      l10n.manageCustomersAndAccounts,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.getTextSecondary(isDark),
                      ),
                    ),
                  ],
                ),
              ),
              // Actions
              if (isDesktop) ...[
                AppIconButton(
                  icon: _showFilters ? Icons.filter_list_off : Icons.filter_list,
                  onPressed: () => setState(() => _showFilters = !_showFilters),
                  tooltip: _showFilters ? l10n.hideFilters : l10n.showFilters,
                ),
                const SizedBox(width: AppSizes.xs),
                AppIconButton(
                  icon: Icons.refresh_rounded,
                  onPressed: _loadCustomers,
                  tooltip: l10n.refreshF5,
                ),
                const SizedBox(width: AppSizes.sm),
              ],
              AppButton.primary(
                onPressed: () => _showAddCustomerDialog(context, isDark, l10n),
                icon: Icons.person_add_rounded,
                label: isDesktop ? l10n.newCustomer : '',
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          // Search Row
          Row(
            children: [
              Expanded(
                child: AppSearchField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  hintText: l10n.searchByNameOrPhone,
                  maxLength: 100,
                  onChanged: (v) {
                    final sanitized = InputSanitizer.sanitize(v);
                    if (sanitized != v) {
                      _searchController.text = sanitized;
                      _searchController.selection = TextSelection.fromPosition(
                        TextPosition(offset: sanitized.length),
                      );
                    }
                    _searchDebounce?.cancel();
                    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
                      setState(() {});
                    });
                  },
                  onClear: () {
                    _searchDebounce?.cancel();
                    _searchController.clear();
                    setState(() {});
                  },
                ),
              ),
              if (isDesktop) ...[
                const SizedBox(width: AppSizes.md),
                // Sort Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.sm,
                    vertical: AppSizes.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.getSurfaceVariant(isDark),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    border: Border.all(color: AppColors.getBorder(isDark)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sort_rounded, size: 18, color: AppColors.getTextSecondary(isDark)),
                      const SizedBox(width: AppSizes.xs),
                      DropdownButton<String>(
                        value: _sortBy,
                        underline: const SizedBox(),
                        isDense: true,
                        dropdownColor: AppColors.getSurface(isDark),
                        style: TextStyle(color: AppColors.getTextPrimary(isDark)),
                        items: [
                          DropdownMenuItem(value: 'name', child: Text(l10n.sortByName)),
                          DropdownMenuItem(value: 'balance', child: Text(l10n.sortByBalance)),
                          DropdownMenuItem(value: 'recent', child: Text(l10n.sortByRecent)),
                        ],
                        onChanged: (value) {
                          if (value != null) setState(() => _sortBy = value);
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          _sortAscending
                              ? Icons.arrow_upward_rounded
                              : Icons.arrow_downward_rounded,
                          size: 18,
                          color: AppColors.getTextSecondary(isDark),
                        ),
                        onPressed: () => setState(() => _sortAscending = !_sortAscending),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          // Mobile Filter Chips
          if (!isDesktop) ...[
            const SizedBox(height: AppSizes.sm),
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildFilterChip(l10n.all, 'all', null, isDark),
                  _buildFilterChip(l10n.debtors, 'debtors', AppColors.error, isDark),
                  _buildFilterChip(l10n.creditorsLabel, 'creditors', AppColors.success, isDark),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsRow(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.people_rounded,
              label: l10n.totalCustomersCount,
              value: '$_totalCustomers',
              color: AppColors.primary,
              isDark: isDark,
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: _StatCard(
              icon: Icons.trending_up_rounded,
              label: l10n.outstandingDebts,
              value: '${AppNumberFormatter.currency(_totalDebt, locale: Localizations.localeOf(context).toString())} ${l10n.currency}',
              color: AppColors.error,
              subtitle: l10n.customerCount(_debtorsCount),
              isDark: isDark,
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: _StatCard(
              icon: Icons.trending_down_rounded,
              label: l10n.creditBalance,
              value: '${AppNumberFormatter.currency(_totalCredit, locale: Localizations.localeOf(context).toString())} ${l10n.currency}',
              color: AppColors.success,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSidebar(bool isDark, AppLocalizations l10n) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        border: Border(left: BorderSide(color: AppColors.getBorder(isDark))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Section
          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Row(
              children: [
                Icon(Icons.filter_alt_rounded, size: 18, color: AppColors.getTextSecondary(isDark)),
                const SizedBox(width: AppSizes.xs),
                Text(
                  l10n.filterByLabel,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
              ],
            ),
          ),
          _buildFilterOption(
            l10n.all,
            Icons.people_rounded,
            _filterType == 'all',
            () => setState(() => _filterType = 'all'),
            isDark: isDark,
            count: _totalCustomers,
          ),
          _buildFilterOption(
            l10n.debtors,
            Icons.warning_rounded,
            _filterType == 'debtors',
            () => setState(() => _filterType = 'debtors'),
            color: AppColors.error,
            isDark: isDark,
            count: _debtorsCount,
          ),
          _buildFilterOption(
            l10n.creditorsLabel,
            Icons.account_balance_wallet_rounded,
            _filterType == 'creditors',
            () => setState(() => _filterType = 'creditors'),
            color: AppColors.success,
            isDark: isDark,
          ),
          Divider(height: 1, color: AppColors.getBorder(isDark)),
          // Quick Actions
          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Row(
              children: [
                Icon(Icons.flash_on_rounded, size: 18, color: AppColors.getTextSecondary(isDark)),
                const SizedBox(width: AppSizes.xs),
                Text(
                  l10n.quickActionsLabel,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
              ],
            ),
          ),
          _buildQuickAction(
            l10n.sendDebtReminder,
            Icons.send_rounded,
            AppColors.primary,
            () {},
            isDark: isDark,
          ),
          _buildQuickAction(
            l10n.exportAccountStatement,
            Icons.download_rounded,
            AppColors.getTextSecondary(isDark),
            () {},
            isDark: isDark,
          ),
          const Spacer(),
          // Clear Selection
          if (_selectedIds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: AppButton.ghost(
                onPressed: () => setState(() => _selectedIds.clear()),
                icon: Icons.clear_all_rounded,
                label: l10n.cancelSelectionCount('${_selectedIds.length}'),
                isFullWidth: true,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap, {
    Color? color,
    int? count,
    required bool isDark,
  }) {
    return Material(
      color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.sm,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? AppColors.primary : (color ?? AppColors.getTextSecondary(isDark)),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? AppColors.primary : AppColors.getTextPrimary(isDark),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
              if (count != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.getSurfaceVariant(isDark),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(fontSize: 12, color: AppColors.getTextSecondary(isDark)),
                  ),
                ),
              if (isSelected)
                const Icon(Icons.check_rounded, size: 18, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.sm,
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(color: AppColors.getTextPrimary(isDark)),
                ),
              ),
              AdaptiveIcon(Icons.chevron_left_rounded, size: 18, color: AppColors.getTextSecondary(isDark)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, Color? color, bool isDark) {
    final isSelected = _filterType == value;
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: AppSizes.xs),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => _filterType = value),
        backgroundColor: AppColors.getSurface(isDark),
        selectedColor: (color ?? AppColors.primary).withValues(alpha: 0.15),
        checkmarkColor: color ?? AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? (color ?? AppColors.primary) : AppColors.getTextPrimary(isDark),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        side: BorderSide(color: isSelected ? (color ?? AppColors.primary) : AppColors.getBorder(isDark)),
      ),
    );
  }

  Widget _buildCustomersContent(bool isDark, AppLocalizations l10n) {
    if (_isLoading) {
      return const ShimmerList(itemCount: 6, itemHeight: 80);
    }

    if (_error != null) {
      return AppErrorState(message: _error!, onRetry: _loadCustomers);
    }

    final customers = _filteredCustomers;

    if (customers.isEmpty) {
      if (_searchController.text.isNotEmpty) {
        return AppEmptyState.noSearchResults(
          query: _searchController.text,
          onClear: () {
            _searchController.clear();
            setState(() {});
          },
        );
      }
      return AppEmptyState.noCustomers(
        onAdd: () => _showAddCustomerDialog(context, isDark, l10n),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCustomers,
      color: AppColors.primary,
      child: AnimatedListView(
        controller: _scrollController,
        padding: const EdgeInsets.all(AppSizes.md),
        itemCount: customers.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Loading more indicator at the bottom
          if (index >= customers.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSizes.lg),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }
          final customer = customers[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.sm),
            child: _CustomerCard(
              customer: customer,
              isSelected: _selectedIds.contains(customer.id),
              isDark: isDark,
              l10n: l10n,
              onTap: () => _showCustomerDetails(customer),
              onSelect: (selected) {
                setState(() {
                  if (selected) {
                    _selectedIds.add(customer.id);
                  } else {
                    _selectedIds.remove(customer.id);
                  }
                });
              },
              onPayment: () => _showPaymentDialog(customer, isDark, l10n),
            ),
          );
        },
      ),
    );
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    // Ctrl+F: Focus search
    if (event.logicalKey == LogicalKeyboardKey.keyF &&
        HardwareKeyboard.instance.isControlPressed) {
      _searchFocusNode.requestFocus();
      return;
    }

    // F5: Refresh
    if (event.logicalKey == LogicalKeyboardKey.f5) {
      _loadCustomers();
      return;
    }

    // Ctrl+N: New customer
    if (event.logicalKey == LogicalKeyboardKey.keyN &&
        HardwareKeyboard.instance.isControlPressed) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final l10n = AppLocalizations.of(context)!;
      _showAddCustomerDialog(context, isDark, l10n);
      return;
    }

    // Escape: Clear selection
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      setState(() => _selectedIds.clear());
      return;
    }
  }

  void _showAddCustomerDialog(BuildContext context, bool isDark, AppLocalizations l10n) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final phoneFocusNode = FocusNode();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.getSurface(isDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.sm),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: const Icon(Icons.person_add_rounded, color: AppColors.primary),
            ),
            const SizedBox(width: AppSizes.sm),
            Text(
              l10n.newCustomer,
              style: TextStyle(color: AppColors.getTextPrimary(isDark)),
            ),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => phoneFocusNode.requestFocus(),
                style: TextStyle(color: AppColors.getTextPrimary(isDark)),
                decoration: InputDecoration(
                  labelText: l10n.customerNameRequired,
                  labelStyle: TextStyle(color: AppColors.getTextSecondary(isDark)),
                  prefixIcon: Icon(Icons.person_rounded, color: AppColors.getTextSecondary(isDark)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    borderSide: BorderSide(color: AppColors.getBorder(isDark)),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.md),
              TextField(
                controller: phoneController,
                focusNode: phoneFocusNode,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.phone,
                style: TextStyle(color: AppColors.getTextPrimary(isDark)),
                decoration: InputDecoration(
                  labelText: l10n.customerPhone,
                  labelStyle: TextStyle(color: AppColors.getTextSecondary(isDark)),
                  prefixIcon: Icon(Icons.phone_rounded, color: AppColors.getTextSecondary(isDark)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    borderSide: BorderSide(color: AppColors.getBorder(isDark)),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          AppButton.primary(
            onPressed: () async {
              if (nameController.text.isEmpty) return;

              // Security: Check for dangerous content
              if (InputSanitizer.containsDangerousContent(nameController.text)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.inputContainsDangerousContent),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
                return;
              }

              final db = GetIt.I<AppDatabase>();
              final storeId = ref.read(currentStoreIdProvider);

              if (storeId != null) {
                final id = DateTime.now().millisecondsSinceEpoch.toString();
                await db.accountsDao.insertAccount(AccountsTableCompanion.insert(
                  id: id,
                  storeId: storeId,
                  name: nameController.text,
                  type: 'receivable',
                  createdAt: DateTime.now(),
                ));

                if (!context.mounted) return;
                Navigator.pop(context);
                _loadCustomers();

                if (!mounted) return;
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Colors.white),
                        const SizedBox(width: AppSizes.sm),
                        Text(l10n.customerAddedSuccess(nameController.text)),
                      ],
                    ),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                  ),
                );
              }
            },
            label: l10n.addAction,
            icon: Icons.add_rounded,
          ),
        ],
      ),
    ).then((_) {
      nameController.dispose();
      phoneController.dispose();
      phoneFocusNode.dispose();
    });
  }

  void _showCustomerDetails(AccountsTableData account) {
    // Navigate to the full customer detail screen
    context.push(AppRoutes.customerDetailPath(account.id));
  }

  void _showPaymentDialog(AccountsTableData account, bool isDark, AppLocalizations l10n) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.getSurface(isDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.sm),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: const Icon(Icons.payment_rounded, color: AppColors.success),
            ),
            const SizedBox(width: AppSizes.sm),
            Text(
              l10n.payDebt,
              style: TextStyle(color: AppColors.getTextPrimary(isDark)),
            ),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Customer Info
              Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: AppColors.getSurfaceVariant(isDark),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.error.withValues(alpha: 0.1),
                      child: Text(
                        account.name.isNotEmpty ? account.name[0] : '?',
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            account.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.getTextPrimary(isDark),
                            ),
                          ),
                          Text(
                            l10n.dueAmountLabel(AppNumberFormatter.currency(account.balance.abs(), locale: Localizations.localeOf(context).toString())),
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.lg),
              // Amount Input
              TextField(
                controller: controller,
                autofocus: true,
                keyboardType: TextInputType.number,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(isDark),
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  labelText: l10n.paymentAmountLabel,
                  labelStyle: TextStyle(color: AppColors.getTextSecondary(isDark)),
                  suffixText: l10n.currency,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    borderSide: BorderSide(color: AppColors.getBorder(isDark)),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.md),
              // Quick Amounts
              Wrap(
                spacing: AppSizes.sm,
                children: [50, 100, 200, 500].map((amount) {
                  return ActionChip(
                    label: Text(
                      '$amount',
                      style: TextStyle(color: AppColors.getTextPrimary(isDark)),
                    ),
                    onPressed: () => controller.text = amount.toString(),
                    backgroundColor: AppColors.getSurfaceVariant(isDark),
                  );
                }).toList()
                  ..add(ActionChip(
                    label: Text(l10n.fullAmount),
                    onPressed: () => controller.text = account.balance.abs().toStringAsFixed(0), // Raw number for input field
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    labelStyle: const TextStyle(color: AppColors.primary),
                  )),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          AppButton.success(
            onPressed: () async {
              final amount = double.tryParse(controller.text);
              if (amount == null || amount <= 0) return;

              final db = GetIt.I<AppDatabase>();
              await db.accountsDao.subtractFromBalance(account.id, amount);

              if (!context.mounted) return;
              Navigator.pop(context);
              _loadCustomers();

              if (!mounted) return;
              ScaffoldMessenger.of(this.context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Colors.white),
                      const SizedBox(width: AppSizes.sm),
                      Text(l10n.paymentRecorded(AppNumberFormatter.currency(amount, locale: Localizations.localeOf(context).toString()))),
                    ],
                  ),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                ),
              );
            },
            label: l10n.payAction,
            icon: Icons.check_rounded,
          ),
        ],
      ),
    ).then((_) {
      controller.dispose();
    });
  }
}

/// Stats Card Widget - Dark mode aware
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final String? subtitle;
  final bool isDark;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.sm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.getTextSecondary(isDark),
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.getTextSecondary(isDark),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Customer Card Widget - Dark mode aware
class _CustomerCard extends StatefulWidget {
  final AccountsTableData customer;
  final bool isSelected;
  final bool isDark;
  final AppLocalizations l10n;
  final VoidCallback onTap;
  final ValueChanged<bool> onSelect;
  final VoidCallback onPayment;

  const _CustomerCard({
    required this.customer,
    required this.isSelected,
    required this.isDark,
    required this.l10n,
    required this.onTap,
    required this.onSelect,
    required this.onPayment,
  });

  @override
  State<_CustomerCard> createState() => _CustomerCardState();
}

class _CustomerCardState extends State<_CustomerCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final hasDebt = widget.customer.balance > 0 && widget.customer.type == 'receivable';
    final hasCredit = widget.customer.balance < 0;
    final isDark = widget.isDark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: AlhaiDurations.standard,
        decoration: BoxDecoration(
          color: widget.isSelected
              ? AppColors.primary.withValues(alpha: 0.05)
              : AppColors.getSurface(isDark),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(
            color: widget.isSelected
                ? AppColors.primary
                : _isHovered
                    ? AppColors.primary.withValues(alpha: 0.5)
                    : AppColors.getBorder(isDark),
            width: widget.isSelected ? 2 : 1,
          ),
          boxShadow: _isHovered ? AppSizes.shadowMd : AppSizes.shadowSm,
        ),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Row(
              children: [
                // Checkbox
                Checkbox(
                  value: widget.isSelected,
                  onChanged: (value) => widget.onSelect(value ?? false),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                // Avatar
                Hero(
                  tag: 'customer-avatar-${widget.customer.id}',
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: hasDebt
                            ? [AppColors.error.withValues(alpha: 0.7), AppColors.error]
                            : hasCredit
                                ? [AppColors.success.withValues(alpha: 0.7), AppColors.success]
                                : [AppColors.textSecondary.withValues(alpha: 0.7), AppColors.textSecondary],
                        begin: AlignmentDirectional.topStart,
                        end: AlignmentDirectional.bottomEnd,
                      ),
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                    child: Center(
                      child: Text(
                        widget.customer.name.isNotEmpty
                            ? widget.customer.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.customer.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.getTextPrimary(isDark),
                        ),
                      ),
                      const SizedBox(height: AppSizes.xxs),
                      Row(
                        children: [
                          Icon(
                            Icons.phone_rounded,
                            size: 14,
                            color: AppColors.getTextSecondary(isDark),
                          ),
                          const SizedBox(width: AppSizes.xxs),
                          Text(
                            widget.customer.phone ?? '-',
                            style: TextStyle(
                              color: AppColors.getTextSecondary(isDark),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Balance
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${AppNumberFormatter.currency(widget.customer.balance.abs(), locale: Localizations.localeOf(context).toString())} ${widget.l10n.currency}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: hasDebt
                            ? AppColors.error
                            : hasCredit
                                ? AppColors.success
                                : AppColors.getTextSecondary(isDark),
                      ),
                    ),
                    AppBadge(
                      label: hasDebt ? widget.l10n.owedLabel : hasCredit ? widget.l10n.hasBalanceLabel : widget.l10n.zeroLabel,
                      color: hasDebt
                          ? AppColors.error
                          : hasCredit
                              ? AppColors.success
                              : AppColors.getTextSecondary(isDark),
                      variant: AppBadgeVariant.soft,
                    ),
                  ],
                ),
                const SizedBox(width: AppSizes.sm),
                // Actions
                if (_isHovered && hasDebt)
                  AppIconButton(
                    icon: Icons.payment_rounded,
                    onPressed: widget.onPayment,
                    tooltip: widget.l10n.payAction,
                  ),
                AdaptiveIcon(Icons.chevron_left_rounded, color: AppColors.getTextSecondary(isDark)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
