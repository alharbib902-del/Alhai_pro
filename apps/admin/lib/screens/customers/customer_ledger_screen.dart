import 'dart:math' show min;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

/// Customer Ledger Screen - Admin version
/// Displays customer account statement with filters and manual adjustments
class CustomerLedgerScreen extends ConsumerStatefulWidget {
  final String customerId;

  const CustomerLedgerScreen({super.key, required this.customerId});

  @override
  ConsumerState<CustomerLedgerScreen> createState() =>
      _CustomerLedgerScreenState();
}

class _CustomerLedgerScreenState extends ConsumerState<CustomerLedgerScreen> {
  final _db = getIt<AppDatabase>();
  AccountsTableData? _account;
  List<TransactionsTableData> _transactions = [];
  bool _isLoading = true;

  // Filters
  String _dateFilter = 'all';
  String _typeFilter = 'all';
  DateTimeRange? _customDateRange;

  // Cached filtered results (performance optimization)
  List<Map<String, dynamic>>? _cachedFiltered;
  double? _cachedTotalDebit;
  double? _cachedTotalCredit;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final account = await _db.accountsDao.getAccountById(widget.customerId);
      final transactions =
          await _db.transactionsDao.getAccountTransactions(widget.customerId);

      if (mounted) {
        setState(() {
          _account = account;
          _transactions = transactions;
          _invalidateFilterCache();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ===========================================================================
  // FILTER LOGIC
  // ===========================================================================

  List<Map<String, dynamic>> _txnToMap(TransactionsTableData t) {
    final isDebit = t.amount > 0;
    return [
      {
        'id': t.id,
        'type': t.type,
        'description': t.description ?? t.type,
        'reference': t.referenceId ?? '-',
        'debit': isDebit ? t.amount.abs() : 0.0,
        'credit': isDebit ? 0.0 : t.amount.abs(),
        'balance': t.balanceAfter,
        'date': t.createdAt,
      }
    ];
  }

  void _invalidateFilterCache() {
    _cachedFiltered = null;
    _cachedTotalDebit = null;
    _cachedTotalCredit = null;
  }

  List<Map<String, dynamic>> get _filteredTransactions {
    if (_cachedFiltered != null) return _cachedFiltered!;

    var list = _transactions.expand(_txnToMap).toList();

    final now = DateTime.now();
    if (_dateFilter == 'thisMonth') {
      list = list
          .where((t) =>
              (t['date'] as DateTime).month == now.month &&
              (t['date'] as DateTime).year == now.year)
          .toList();
    } else if (_dateFilter == 'threeMonths') {
      final threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);
      list = list
          .where((t) => (t['date'] as DateTime).isAfter(threeMonthsAgo))
          .toList();
    } else if (_dateFilter == 'custom' && _customDateRange != null) {
      list = list
          .where((t) =>
              (t['date'] as DateTime).isAfter(_customDateRange!.start) &&
              (t['date'] as DateTime)
                  .isBefore(_customDateRange!.end.add(const Duration(days: 1))))
          .toList();
    }

    if (_typeFilter != 'all') {
      list = list.where((t) => t['type'] == _typeFilter).toList();
    }

    _cachedFiltered = list;
    return list;
  }

  double get _totalDebit {
    if (_cachedTotalDebit != null) return _cachedTotalDebit!;
    _cachedTotalDebit = _filteredTransactions.fold<double>(
        0.0, (sum, t) => sum + (t['debit'] as double));
    return _cachedTotalDebit!;
  }

  double get _totalCredit {
    if (_cachedTotalCredit != null) return _cachedTotalCredit!;
    _cachedTotalCredit = _filteredTransactions.fold<double>(
        0.0, (sum, t) => sum + (t['credit'] as double));
    return _cachedTotalCredit!;
  }

  double get _currentBalance {
    return _account?.balance ?? 0.0;
  }

  String get _customerInitials {
    final name = _account?.name ?? widget.customerId;
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String get _customerName {
    return _account?.name ?? widget.customerId;
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final isMobile = context.isMobile;
    final isDesktop = context.isDesktop;
    final isWideScreen = context.isDesktop;

    return Column(
      children: [
        AppHeader(
          title: l10n.customerLedger,
          onMenuTap:
              isWideScreen ? null : () => Scaffold.of(context).openDrawer(),
          onNotificationsTap: () => context.push('/notifications'),
          notificationsCount: 0,
          userName: _customerName,
          userRole: l10n.customerLedger,
          actions: [
            IconButton(
              onPressed: () => _showAdjustmentDialog(isDark, l10n),
              icon: Icon(
                Icons.add_circle_outline,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              tooltip: l10n.manualAdjustment,
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.picture_as_pdf_outlined,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              tooltip: l10n.exportPdf,
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.print_outlined,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              tooltip: l10n.printReport,
            ),
            IconButton(
              onPressed: _loadData,
              icon: Icon(
                Icons.refresh_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? 32 : 16,
                          vertical: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCustomerInfoCard(isDark, l10n, isMobile),
                            const SizedBox(height: AlhaiSpacing.md),
                            _buildFilterSection(isDark, l10n, isMobile),
                            const SizedBox(height: AlhaiSpacing.md),
                            isMobile
                                ? _buildMobileTransactions(isDark, l10n)
                                : _buildDesktopTable(isDark, l10n),
                            const SizedBox(height: AlhaiSpacing.md),
                            if (!isMobile) _buildSummaryBar(isDark, l10n),
                            const SizedBox(height: AlhaiSpacing.lg),
                          ],
                        ),
                      ),
                    ),
                    if (isMobile) _buildMobileBottomSummary(isDark, l10n),
                  ],
                ),
        ),
      ],
    );
  }

  // ===========================================================================
  // CUSTOMER INFO CARD
  // ===========================================================================

  Widget _buildCustomerInfoCard(
      bool isDark, AppLocalizations l10n, bool isMobile) {
    final isDebt = _currentBalance > 0;
    final balanceColor = isDebt ? AppColors.error : AppColors.success;
    final cardColor = Theme.of(context).colorScheme.surface;

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: isDark ? null : AppSizes.shadowSm,
      ),
      child: Row(
        children: [
          Container(
            width: isMobile ? 48 : 56,
            height: isMobile ? 48 : 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.8)
                ],
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusXl),
            ),
            alignment: Alignment.center,
            child: Text(
              _customerInitials,
              style: TextStyle(
                fontSize: isMobile ? 18 : 22,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
          const SizedBox(width: AlhaiSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _customerName,
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.xxs),
                Row(
                  children: [
                    Icon(Icons.phone_outlined,
                        size: 14, color: Theme.of(context).hintColor),
                    const SizedBox(width: AlhaiSpacing.xxs),
                    Text(
                      _account?.phone ?? '-',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: balanceColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                ),
                child: Text(
                  isDebt ? l10n.dueOnCustomer : l10n.customerHasCredit,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: balanceColor,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${_currentBalance.abs().toStringAsFixed(2)} ${l10n.sar}',
                style: TextStyle(
                  fontSize: isMobile ? 18 : 22,
                  fontWeight: FontWeight.w800,
                  color: balanceColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // FILTER SECTION
  // ===========================================================================

  Widget _buildFilterSection(
      bool isDark, AppLocalizations l10n, bool isMobile) {
    final cardColor = Theme.of(context).colorScheme.surface;

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: isDark ? null : AppSizes.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today_outlined,
                  size: 16,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withValues(alpha: 0.5)),
              const SizedBox(width: AlhaiSpacing.xs),
              Text(
                l10n.date,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  l10n.allPeriods,
                  _dateFilter == 'all',
                  () => setState(() {
                    _dateFilter = 'all';
                    _customDateRange = null;
                    _invalidateFilterCache();
                  }),
                  isDark,
                ),
                const SizedBox(width: AlhaiSpacing.xs),
                _buildFilterChip(
                  l10n.thisMonthPeriod,
                  _dateFilter == 'thisMonth',
                  () => setState(() {
                    _dateFilter = 'thisMonth';
                    _invalidateFilterCache();
                  }),
                  isDark,
                ),
                const SizedBox(width: AlhaiSpacing.xs),
                _buildFilterChip(
                  l10n.threeMonths,
                  _dateFilter == 'threeMonths',
                  () => setState(() {
                    _dateFilter = 'threeMonths';
                    _invalidateFilterCache();
                  }),
                  isDark,
                ),
                const SizedBox(width: AlhaiSpacing.xs),
                _buildFilterChip(
                  l10n.dateFromTo,
                  _dateFilter == 'custom',
                  () => _selectDateRange(),
                  isDark,
                  icon: Icons.date_range_outlined,
                ),
              ],
            ),
          ),
          const SizedBox(height: AlhaiSpacing.md),
          Row(
            children: [
              Icon(Icons.filter_list_rounded,
                  size: 16,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withValues(alpha: 0.5)),
              const SizedBox(width: AlhaiSpacing.xs),
              Text(
                l10n.type,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  l10n.allMovements,
                  _typeFilter == 'all',
                  () => setState(() {
                    _typeFilter = 'all';
                    _invalidateFilterCache();
                  }),
                  isDark,
                ),
                const SizedBox(width: AlhaiSpacing.xs),
                _buildFilterChip(
                  l10n.invoices,
                  _typeFilter == 'invoice',
                  () => setState(() {
                    _typeFilter = 'invoice';
                    _invalidateFilterCache();
                  }),
                  isDark,
                ),
                const SizedBox(width: AlhaiSpacing.xs),
                _buildFilterChip(
                  l10n.payment,
                  _typeFilter == 'payment',
                  () => setState(() {
                    _typeFilter = 'payment';
                    _invalidateFilterCache();
                  }),
                  isDark,
                ),
                const SizedBox(width: AlhaiSpacing.xs),
                _buildFilterChip(
                  l10n.returns,
                  _typeFilter == 'return',
                  () => setState(() {
                    _typeFilter = 'return';
                    _invalidateFilterCache();
                  }),
                  isDark,
                ),
                const SizedBox(width: AlhaiSpacing.xs),
                _buildFilterChip(
                  l10n.adjustments,
                  _typeFilter == 'adjustment',
                  () => setState(() {
                    _typeFilter = 'adjustment';
                    _invalidateFilterCache();
                  }),
                  isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    bool isSelected,
    VoidCallback onTap,
    bool isDark, {
    IconData? icon,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          border: Border.all(
            color:
                isSelected ? AppColors.primary : Theme.of(context).dividerColor,
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
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // DESKTOP TABLE
  // ===========================================================================

  Widget _buildDesktopTable(bool isDark, AppLocalizations l10n) {
    final txns = _filteredTransactions;

    if (txns.isEmpty) {
      return _buildEmptyState(isDark, l10n);
    }

    final cardColor = Theme.of(context).colorScheme.surface;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: isDark ? null : AppSizes.shadowSm,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            child: Row(
              children: [
                _tableHeaderCell(l10n.date, flex: 2, isDark: isDark),
                _tableHeaderCell(l10n.statementCol, flex: 3, isDark: isDark),
                _tableHeaderCell(l10n.referenceCol, flex: 2, isDark: isDark),
                _tableHeaderCell(l10n.debitCol,
                    flex: 2, isDark: isDark, align: TextAlign.end),
                _tableHeaderCell(l10n.creditCol,
                    flex: 2, isDark: isDark, align: TextAlign.end),
                _tableHeaderCell(l10n.balanceCol,
                    flex: 2, isDark: isDark, align: TextAlign.end),
              ],
            ),
          ),
          ...txns.asMap().entries.map((entry) {
            final index = entry.key;
            final txn = entry.value;
            return _buildTableRow(txn, index, isDark, l10n);
          }),
        ],
      ),
    );
  }

  Widget _tableHeaderCell(
    String text, {
    required int flex,
    required bool isDark,
    TextAlign align = TextAlign.start,
  }) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildTableRow(
    Map<String, dynamic> txn,
    int index,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final type = txn['type'] as String;
    final isAdjustment = type == 'adjustment';
    final date = txn['date'] as DateTime;
    final debit = txn['debit'] as double;
    final credit = txn['credit'] as double;
    final balance = txn['balance'] as double;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: isAdjustment
            ? AppColors.warning.withValues(alpha: isDark ? 0.08 : 0.05)
            : (index.isEven
                ? Colors.transparent
                : (isDark
                    ? Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.03)
                    : AppColors.surfaceVariant.withValues(alpha: 0.5))),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              _formatDate(date),
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _getTypeColor(type).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    _getTypeIcon(type),
                    size: 15,
                    color: _getTypeColor(type),
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    _getTypeLabel(type, l10n),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: type == 'opening'
                          ? AppColors.info
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              txn['reference'] as String,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontFamily: 'monospace',
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              debit > 0 ? debit.toStringAsFixed(2) : '-',
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13,
                fontWeight: debit > 0 ? FontWeight.w600 : FontWeight.w400,
                color:
                    debit > 0 ? AppColors.error : Theme.of(context).hintColor,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              credit > 0 ? credit.toStringAsFixed(2) : '-',
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13,
                fontWeight: credit > 0 ? FontWeight.w600 : FontWeight.w400,
                color: credit > 0
                    ? AppColors.success
                    : Theme.of(context).hintColor,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              balance.toStringAsFixed(2),
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // MOBILE TRANSACTIONS (CARDS)
  // ===========================================================================

  Widget _buildMobileTransactions(bool isDark, AppLocalizations l10n) {
    final txns = _filteredTransactions;

    if (txns.isEmpty) {
      return _buildEmptyState(isDark, l10n);
    }

    return Column(
      children: txns.map((txn) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildMobileTransactionCard(txn, isDark, l10n),
        );
      }).toList(),
    );
  }

  Widget _buildMobileTransactionCard(
    Map<String, dynamic> txn,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final type = txn['type'] as String;
    final isAdjustment = type == 'adjustment';
    final date = txn['date'] as DateTime;
    final debit = txn['debit'] as double;
    final credit = txn['credit'] as double;
    final balance = txn['balance'] as double;
    final isDebitTx = debit > 0;
    final amount = isDebitTx ? debit : credit;
    final cardColor = Theme.of(context).colorScheme.surface;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: isAdjustment
              ? AppColors.warning.withValues(alpha: 0.4)
              : Theme.of(context).dividerColor,
        ),
        boxShadow: isDark ? null : AppSizes.shadowSm,
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          children: [
            if (isAdjustment)
              Container(
                width: 4,
                color: AppColors.warning,
              ),
            Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.only(
                  start: isAdjustment ? 12 : 16,
                  end: 16,
                  top: 14,
                  bottom: 14,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: _getTypeColor(type).withValues(alpha: 0.12),
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusMd),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            _getTypeIcon(type),
                            size: 16,
                            color: _getTypeColor(type),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getTypeLabel(type, l10n),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: type == 'opening'
                                      ? AppColors.info
                                      : Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                _formatDateTime(date),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Theme.of(context).hintColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${isDebitTx ? '+' : '-'}${amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: isDebitTx
                                    ? AppColors.error
                                    : AppColors.success,
                              ),
                            ),
                            const SizedBox(height: AlhaiSpacing.xxxs),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusFull),
                              ),
                              child: Text(
                                '${l10n.balanceCol}: ${balance.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (txn['reference'] != '-') ...[
                      const SizedBox(height: AlhaiSpacing.xs),
                      Row(
                        children: [
                          const SizedBox(width: 42),
                          Icon(Icons.tag_rounded,
                              size: 12, color: Theme.of(context).hintColor),
                          const SizedBox(width: AlhaiSpacing.xxs),
                          Text(
                            txn['reference'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).hintColor,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // SUMMARY BAR
  // ===========================================================================

  Widget _buildSummaryBar(bool isDark, AppLocalizations l10n) {
    final finalBalance = _totalDebit - _totalCredit;
    final cardColor = Theme.of(context).colorScheme.surface;

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: isDark ? null : AppSizes.shadowSm,
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryItem(
              l10n.totalDebit,
              _totalDebit.toStringAsFixed(2),
              AppColors.error,
              Icons.arrow_upward_rounded,
              isDark,
            ),
          ),
          Container(
            width: 1,
            height: 48,
            color: Theme.of(context).dividerColor,
            margin: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.md),
          ),
          Expanded(
            child: _buildSummaryItem(
              l10n.totalCredit,
              _totalCredit.toStringAsFixed(2),
              AppColors.success,
              Icons.arrow_downward_rounded,
              isDark,
            ),
          ),
          Container(
            width: 1,
            height: 48,
            color: Theme.of(context).dividerColor,
            margin: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.md),
          ),
          Expanded(
            child: _buildSummaryItem(
              l10n.finalBalance,
              finalBalance.abs().toStringAsFixed(2),
              finalBalance > 0 ? AppColors.error : AppColors.success,
              Icons.account_balance_wallet_outlined,
              isDark,
              isBold: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    String value,
    Color color,
    IconData icon,
    bool isDark, {
    bool isBold = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 18 : 16,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // MOBILE BOTTOM SUMMARY
  // ===========================================================================

  Widget _buildMobileBottomSummary(bool isDark, AppLocalizations l10n) {
    final finalBalance = _totalDebit - _totalCredit;
    final cardColor = Theme.of(context).colorScheme.surface;

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AlhaiSpacing.md, vertical: AlhaiSpacing.sm),
      decoration: BoxDecoration(
        color: cardColor,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.totalDebit,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant
                          .withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.xxxs),
                  Text(
                    _totalDebit.toStringAsFixed(0),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.totalCredit,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant
                          .withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.xxxs),
                  Text(
                    _totalCredit.toStringAsFixed(0),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AlhaiSpacing.sm, vertical: AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color:
                      (finalBalance > 0 ? AppColors.error : AppColors.success)
                          .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.finalBalance,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant
                            .withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: AlhaiSpacing.xxxs),
                    Text(
                      finalBalance.abs().toStringAsFixed(0),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: finalBalance > 0
                            ? AppColors.error
                            : AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // EMPTY STATE
  // ===========================================================================

  Widget _buildEmptyState(bool isDark, AppLocalizations l10n) {
    final cardColor = Theme.of(context).colorScheme.surface;

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.xxxl),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: isDark
                  ? Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.2)
                  : AppColors.textMuted.withValues(alpha: 0.4),
            ),
            const SizedBox(height: AlhaiSpacing.md),
            Text(
              l10n.noTransactions,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // MANUAL ADJUSTMENT DIALOG
  // ===========================================================================

  void _showAdjustmentDialog(bool isDark, AppLocalizations l10n) {
    final amountController = TextEditingController();
    final reasonController = TextEditingController();
    String adjustmentType = 'debit';
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          final dialogIsDark =
              Theme.of(dialogContext).brightness == Brightness.dark;
          final dialogCardColor = Theme.of(dialogContext).colorScheme.surface;

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusXl),
            ),
            backgroundColor: dialogCardColor,
            child: Container(
              width: min(MediaQuery.of(dialogContext).size.width * 0.9, 440),
              padding: const EdgeInsets.all(AlhaiSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.12),
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusLg),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.tune_rounded,
                            size: 20, color: AppColors.warning),
                      ),
                      const SizedBox(width: AlhaiSpacing.sm),
                      Text(
                        l10n.manualAdjustment,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(dialogContext).colorScheme.onSurface,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        icon: Icon(Icons.close_rounded,
                            color: Theme.of(dialogContext)
                                .colorScheme
                                .onSurfaceVariant),
                      ),
                    ],
                  ),
                  const SizedBox(height: AlhaiSpacing.lg),
                  Text(
                    l10n.adjustmentType,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color:
                          Theme.of(dialogContext).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.xs),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTypeOption(
                          l10n.debitAdjustment,
                          Icons.arrow_upward_rounded,
                          AppColors.error,
                          adjustmentType == 'debit',
                          () => setDialogState(() => adjustmentType = 'debit'),
                          dialogIsDark,
                        ),
                      ),
                      const SizedBox(width: AlhaiSpacing.sm),
                      Expanded(
                        child: _buildTypeOption(
                          l10n.creditAdjustment,
                          Icons.arrow_downward_rounded,
                          AppColors.success,
                          adjustmentType == 'credit',
                          () => setDialogState(() => adjustmentType = 'credit'),
                          dialogIsDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AlhaiSpacing.mdl),
                  Text(
                    l10n.adjustmentAmount,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color:
                          Theme.of(dialogContext).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.xs),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      color: Theme.of(dialogContext).colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      hintStyle:
                          TextStyle(color: Theme.of(dialogContext).hintColor),
                      prefixText: '${l10n.sar} ',
                      filled: true,
                      fillColor: Theme.of(dialogContext)
                          .colorScheme
                          .surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.mdl),
                  Text(
                    l10n.adjustmentReason,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color:
                          Theme.of(dialogContext).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.xs),
                  TextField(
                    controller: reasonController,
                    maxLines: 2,
                    style: TextStyle(
                      color: Theme.of(dialogContext).colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: l10n.adjustmentReason,
                      hintStyle:
                          TextStyle(color: Theme.of(dialogContext).hintColor),
                      filled: true,
                      fillColor: Theme.of(dialogContext)
                          .colorScheme
                          .surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.mdl),
                  Text(
                    l10n.adjustmentDate,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color:
                          Theme.of(dialogContext).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.xs),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: dialogContext,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setDialogState(() => selectedDate = picked);
                      }
                    },
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Theme.of(dialogContext)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today_outlined,
                              size: 16,
                              color: Theme.of(dialogContext).hintColor),
                          const SizedBox(width: 10),
                          Text(
                            _formatDate(selectedDate),
                            style: TextStyle(
                              fontSize: 14,
                              color:
                                  Theme.of(dialogContext).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Theme.of(dialogContext)
                                .colorScheme
                                .onSurfaceVariant,
                            side: BorderSide(
                                color: Theme.of(dialogContext).dividerColor),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusLg),
                            ),
                          ),
                          child: Text(l10n.cancel),
                        ),
                      ),
                      const SizedBox(width: AlhaiSpacing.sm),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            final amount =
                                double.tryParse(amountController.text);
                            if (amount == null || amount <= 0) {
                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.enterValidAmount),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                              return;
                            }
                            Navigator.pop(dialogContext);
                            _handleSaveAdjustment(
                              adjustmentType,
                              amount,
                              reasonController.text,
                              selectedDate,
                              l10n,
                            );
                          },
                          icon: const Icon(Icons.save_outlined, size: 18),
                          label: Text(l10n.saveAdjustment),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor:
                                Theme.of(dialogContext).colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusLg),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTypeOption(
    String label,
    IconData icon,
    Color color,
    bool isSelected,
    VoidCallback onTap,
    bool isDark,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.1)
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(
            color: isSelected ? color : Theme.of(context).dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 18,
                color: isSelected
                    ? color
                    : Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(width: AlhaiSpacing.xs),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? color
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSaveAdjustment(
    String type,
    double amount,
    String reason,
    DateTime date,
    AppLocalizations l10n,
  ) async {
    final isDebit = type == 'debit';
    final currentBal = _account?.balance ?? 0.0;
    final signedAmount = isDebit ? amount : -amount;
    final newBalance = currentBal + signedAmount;
    final storeId = ref.read(currentStoreIdProvider) ?? kDefaultStoreId;

    try {
      final txnId = 'ADJ-${DateTime.now().millisecondsSinceEpoch}';
      await _db.transactionsDao.insertTransaction(
        TransactionsTableCompanion.insert(
          id: txnId,
          storeId: storeId,
          accountId: widget.customerId,
          type: 'adjustment',
          amount: signedAmount,
          balanceAfter: newBalance,
          description: Value(reason.isEmpty ? l10n.manualAdjustment : reason),
          createdAt: date,
        ),
      );
      await _db.accountsDao.updateBalance(widget.customerId, newBalance);
      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.adjustmentSaved),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorSaving),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // ===========================================================================
  // HELPERS
  // ===========================================================================

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _customDateRange,
    );

    if (picked != null) {
      setState(() {
        _dateFilter = 'custom';
        _customDateRange = picked;
        _invalidateFilterCache();
      });
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'opening':
        return Icons.account_balance_outlined;
      case 'invoice':
        return Icons.receipt_long_outlined;
      case 'payment':
        return Icons.payments_outlined;
      case 'adjustment':
        return Icons.tune_rounded;
      case 'return':
        return Icons.assignment_return_outlined;
      default:
        return Icons.swap_horiz_rounded;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'opening':
        return AppColors.info;
      case 'invoice':
        return const Color(0xFFF97316);
      case 'payment':
        return AppColors.success;
      case 'adjustment':
        return AppColors.warning;
      case 'return':
        return const Color(0xFF8B5CF6);
      default:
        return Theme.of(context).colorScheme.outline;
    }
  }

  String _getTypeLabel(String type, AppLocalizations l10n) {
    switch (type) {
      case 'opening':
        return l10n.openingBalance;
      case 'invoice':
        return l10n.invoices;
      case 'payment':
        return l10n.payment;
      case 'adjustment':
        return l10n.adjustmentEntry;
      case 'return':
        return l10n.returnEntry;
      default:
        return type;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime date) {
    return '${_formatDate(date)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
