/// Customer Ledger Screen - Cashier-specific customer ledger view
///
/// Full implementation: customer info, transactions list, date/type filters,
/// summary totals, manual adjustment dialog.
/// Supports: RTL Arabic, dark/light theme, responsive layout.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
// alhai_auth is re-exported via alhai_shared_ui
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:uuid/uuid.dart';
// alhai_design_system is re-exported via alhai_shared_ui
import 'package:alhai_design_system/alhai_design_system.dart'
    show AlhaiBreakpoints, AlhaiSnackbar, AlhaiSpacing;
import '../../core/services/sentry_service.dart';

/// شاشة كشف حساب العميل
class CustomerLedgerScreen extends ConsumerStatefulWidget {
  final String id;

  const CustomerLedgerScreen({super.key, required this.id});

  @override
  ConsumerState<CustomerLedgerScreen> createState() =>
      _CustomerLedgerScreenState();
}

class _CustomerLedgerScreenState extends ConsumerState<CustomerLedgerScreen> {
  final _db = GetIt.I<AppDatabase>();
  AccountsTableData? _account;
  List<TransactionsTableData> _transactions = [];
  bool _isLoading = true;
  bool _isAdjusting = false;
  String? _error;

  // Filters
  String _dateFilter = 'all';
  String _typeFilter = 'all';
  DateTimeRange? _customDateRange;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final account = await _db.accountsDao.getAccountById(widget.id);
      final transactions = await _db.transactionsDao.getAccountTransactions(
        widget.id,
      );

      if (mounted) {
        setState(() {
          _account = account;
          _transactions = transactions;
          _isLoading = false;
        });
      }
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Load customer ledger data');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = '$e';
        });
      }
    }
  }

  List<Map<String, dynamic>> _txnToMap(TransactionsTableData t) {
    final isDebit = t.amount > 0;
    // C-4 Session 4: transactions.amount, balance_after are int cents.
    // Convert to SAR doubles for display/aggregation.
    final amountSar = t.amount.abs() / 100.0;
    final balanceSar = t.balanceAfter / 100.0;
    return [
      {
        'id': t.id,
        'type': t.type,
        'description': t.description ?? t.type,
        'reference': t.referenceId ?? '-',
        'debit': isDebit ? amountSar : 0.0,
        'credit': isDebit ? 0.0 : amountSar,
        'balance': balanceSar,
        'date': t.createdAt,
      },
    ];
  }

  List<Map<String, dynamic>> get _filteredTransactions {
    var list = _transactions.expand(_txnToMap).toList();

    final now = DateTime.now();
    if (_dateFilter == 'thisMonth') {
      list = list
          .where(
            (t) =>
                (t['date'] as DateTime).month == now.month &&
                (t['date'] as DateTime).year == now.year,
          )
          .toList();
    } else if (_dateFilter == 'threeMonths') {
      final threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);
      list = list
          .where((t) => (t['date'] as DateTime).isAfter(threeMonthsAgo))
          .toList();
    } else if (_dateFilter == 'custom' && _customDateRange != null) {
      list = list
          .where(
            (t) =>
                (t['date'] as DateTime).isAfter(_customDateRange!.start) &&
                (t['date'] as DateTime).isBefore(
                  _customDateRange!.end.add(const Duration(days: 1)),
                ),
          )
          .toList();
    }

    if (_typeFilter != 'all') {
      list = list.where((t) => t['type'] == _typeFilter).toList();
    }

    return list;
  }

  double get _totalDebit =>
      _filteredTransactions.fold(0.0, (sum, t) => sum + (t['debit'] as double));

  double get _totalCredit => _filteredTransactions.fold(
    0.0,
    (sum, t) => sum + (t['credit'] as double),
  );

  // C-4 Session 4: accounts.balance is int cents; return as SAR double.
  double get _currentBalance => (_account?.balance ?? 0) / 100.0;

  String get _customerName => _account?.name ?? widget.id;

  String get _customerInitials {
    final parts = _customerName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return _customerName.isNotEmpty ? _customerName[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWideScreen = screenWidth >= AlhaiBreakpoints.desktop;
    final isMobile = screenWidth < AlhaiBreakpoints.tablet;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        tooltip: l10n.manualAdjustment,
        onPressed: _isAdjusting
            ? null
            : () => _showAdjustmentDialog(colorScheme, l10n),
        backgroundColor: _isAdjusting
            ? AppColors.primary.withValues(alpha: 0.5)
            : AppColors.primary,
        foregroundColor: colorScheme.onPrimary,
        icon: _isAdjusting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.textOnPrimary,
                ),
              )
            : const Icon(Icons.tune_rounded, size: 20),
        label: Text(l10n.manualAdjustment),
      ),
      body: _isLoading
          ? const AppLoadingState()
          : _error != null
          ? AppErrorState.general(context, message: _error, onRetry: _loadData)
          : Column(
              children: [
                _buildTopBar(colorScheme, l10n),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isWideScreen
                          ? AlhaiSpacing.xxxl
                          : (isMobile ? AlhaiSpacing.md : AlhaiSpacing.lg),
                      vertical: AlhaiSpacing.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCustomerInfoCard(colorScheme, l10n, isMobile),
                        const SizedBox(height: AlhaiSpacing.md),
                        _buildFilterSection(colorScheme, l10n),
                        const SizedBox(height: AlhaiSpacing.md),
                        isMobile
                            ? _buildMobileTransactions(colorScheme, l10n)
                            : _buildDesktopTable(colorScheme, l10n),
                        const SizedBox(height: AlhaiSpacing.md),
                        if (!isMobile) _buildSummaryBar(colorScheme, l10n),
                        const SizedBox(height: AlhaiSpacing.lg),
                      ],
                    ),
                  ),
                ),
                if (isMobile) _buildMobileBottomSummary(colorScheme, l10n),
              ],
            ),
    );
  }

  Widget _buildTopBar(ColorScheme colorScheme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AlhaiSpacing.md,
        vertical: AlhaiSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              onPressed: () => context.pop(),
              icon: Icon(
                Icons.arrow_back_rounded,
                color: colorScheme.onSurface,
              ),
              tooltip: l10n.back,
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(width: AlhaiSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.customerLedger,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    _customerName,
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: _loadData,
              icon: Icon(
                Icons.refresh_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
              tooltip: l10n.refresh,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfoCard(
    ColorScheme colorScheme,
    AppLocalizations l10n,
    bool isMobile,
  ) {
    final isDebt = _currentBalance > 0;
    final balanceColor = isDebt ? AppColors.error : AppColors.success;

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: Theme.of(context).brightness == Brightness.dark
            ? null
            : AppSizes.shadowSm,
      ),
      child: Row(
        children: [
          Container(
            width: isMobile ? 48 : 56,
            height: isMobile ? 48 : 56,
            decoration: BoxDecoration(
              gradient: AppColors.avatarGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text(
              _customerInitials,
              style: TextStyle(
                fontSize: isMobile ? 18 : 22,
                fontWeight: FontWeight.w700,
                color: colorScheme.onPrimary,
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
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.xxs),
                Row(
                  children: [
                    Icon(
                      Icons.phone_outlined,
                      size: 14,
                      color: colorScheme.outline,
                    ),
                    const SizedBox(width: AlhaiSpacing.xxs),
                    Text(
                      _account?.phone ?? '',
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: AlhaiSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: balanceColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
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

  Widget _buildFilterSection(ColorScheme colorScheme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: Theme.of(context).brightness == Brightness.dark
            ? null
            : AppSizes.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: colorScheme.outline,
              ),
              const SizedBox(width: AlhaiSpacing.xs),
              Text(
                l10n.date,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
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
                  }),
                  colorScheme,
                ),
                const SizedBox(width: AlhaiSpacing.xs),
                _buildFilterChip(
                  l10n.thisMonthPeriod,
                  _dateFilter == 'thisMonth',
                  () => setState(() => _dateFilter = 'thisMonth'),
                  colorScheme,
                ),
                const SizedBox(width: AlhaiSpacing.xs),
                _buildFilterChip(
                  l10n.threeMonths,
                  _dateFilter == 'threeMonths',
                  () => setState(() => _dateFilter = 'threeMonths'),
                  colorScheme,
                ),
                const SizedBox(width: AlhaiSpacing.xs),
                _buildFilterChip(
                  l10n.dateFromTo,
                  _dateFilter == 'custom',
                  _selectDateRange,
                  colorScheme,
                  icon: Icons.date_range_outlined,
                ),
              ],
            ),
          ),
          const SizedBox(height: AlhaiSpacing.md),
          Row(
            children: [
              Icon(
                Icons.filter_list_rounded,
                size: 16,
                color: colorScheme.outline,
              ),
              const SizedBox(width: AlhaiSpacing.xs),
              Text(
                l10n.type,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
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
                  () => setState(() => _typeFilter = 'all'),
                  colorScheme,
                ),
                const SizedBox(width: AlhaiSpacing.xs),
                _buildFilterChip(
                  l10n.invoices,
                  _typeFilter == 'invoice',
                  () => setState(() => _typeFilter = 'invoice'),
                  colorScheme,
                ),
                const SizedBox(width: AlhaiSpacing.xs),
                _buildFilterChip(
                  l10n.payment,
                  _typeFilter == 'payment',
                  () => setState(() => _typeFilter = 'payment'),
                  colorScheme,
                ),
                const SizedBox(width: AlhaiSpacing.xs),
                _buildFilterChip(
                  l10n.returns,
                  _typeFilter == 'return',
                  () => setState(() => _typeFilter = 'return'),
                  colorScheme,
                ),
                const SizedBox(width: AlhaiSpacing.xs),
                _buildFilterChip(
                  l10n.adjustments,
                  _typeFilter == 'adjustment',
                  () => setState(() => _typeFilter = 'adjustment'),
                  colorScheme,
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
    ColorScheme colorScheme, {
    IconData? icon,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: AlhaiSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? AppColors.primary : colorScheme.outlineVariant,
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
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopTable(ColorScheme colorScheme, AppLocalizations l10n) {
    final txns = _filteredTransactions;
    if (txns.isEmpty) return _buildEmptyState(colorScheme, l10n);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: Theme.of(context).brightness == Brightness.dark
            ? null
            : AppSizes.shadowSm,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AlhaiSpacing.mdl,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
            ),
            child: Row(
              children: [
                _tableHeaderCell(l10n.date, flex: 2, colorScheme: colorScheme),
                _tableHeaderCell(
                  l10n.statementCol,
                  flex: 3,
                  colorScheme: colorScheme,
                ),
                _tableHeaderCell(
                  l10n.referenceCol,
                  flex: 2,
                  colorScheme: colorScheme,
                ),
                _tableHeaderCell(
                  l10n.debitCol,
                  flex: 2,
                  colorScheme: colorScheme,
                  align: TextAlign.end,
                ),
                _tableHeaderCell(
                  l10n.creditCol,
                  flex: 2,
                  colorScheme: colorScheme,
                  align: TextAlign.end,
                ),
                _tableHeaderCell(
                  l10n.balanceCol,
                  flex: 2,
                  colorScheme: colorScheme,
                  align: TextAlign.end,
                ),
              ],
            ),
          ),
          ...txns.asMap().entries.map(
            (entry) =>
                _buildTableRow(entry.value, entry.key, colorScheme, l10n),
          ),
        ],
      ),
    );
  }

  Widget _tableHeaderCell(
    String text, {
    required int flex,
    required ColorScheme colorScheme,
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
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildTableRow(
    Map<String, dynamic> txn,
    int index,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    final type = txn['type'] as String;
    final date = txn['date'] as DateTime;
    final debit = txn['debit'] as double;
    final credit = txn['credit'] as double;
    final balance = txn['balance'] as double;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AlhaiSpacing.mdl,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: type == 'adjustment'
            ? AppColors.warning.withValues(
                alpha: Theme.of(context).brightness == Brightness.dark
                    ? 0.08
                    : 0.05,
              )
            : (index.isEven
                  ? Colors.transparent
                  : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)),
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
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
                color: colorScheme.onSurfaceVariant,
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
                    borderRadius: BorderRadius.circular(6),
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
                      color: colorScheme.onSurface,
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
                color: colorScheme.onSurfaceVariant,
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
                color: debit > 0 ? AppColors.error : colorScheme.outline,
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
                color: credit > 0 ? AppColors.success : colorScheme.outline,
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
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileTransactions(
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    final txns = _filteredTransactions;
    if (txns.isEmpty) return _buildEmptyState(colorScheme, l10n);

    return Column(
      children: txns
          .map(
            (txn) => Padding(
              padding: const EdgeInsetsDirectional.only(bottom: 10),
              child: _buildMobileTransactionCard(txn, colorScheme, l10n),
            ),
          )
          .toList(),
    );
  }

  Widget _buildMobileTransactionCard(
    Map<String, dynamic> txn,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    final type = txn['type'] as String;
    final date = txn['date'] as DateTime;
    final debit = txn['debit'] as double;
    final credit = txn['credit'] as double;
    final balance = txn['balance'] as double;
    final isDebitTx = debit > 0;
    final amount = isDebitTx ? debit : credit;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: type == 'adjustment'
              ? AppColors.warning.withValues(alpha: 0.4)
              : colorScheme.outlineVariant,
        ),
        boxShadow: Theme.of(context).brightness == Brightness.dark
            ? null
            : AppSizes.shadowSm,
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          children: [
            if (type == 'adjustment')
              Container(width: 4, color: AppColors.warning),
            Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.only(
                  start: type == 'adjustment' ? 12 : 16,
                  end: 16,
                  top: 14,
                  bottom: 14,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _getTypeColor(type).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
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
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            _formatDateTime(date),
                            style: TextStyle(
                              fontSize: 11,
                              color: colorScheme.outline,
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
                            horizontal: AlhaiSpacing.xs,
                            vertical: AlhaiSpacing.xxxs,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${l10n.balanceCol}: ${balance.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildSummaryBar(ColorScheme colorScheme, AppLocalizations l10n) {
    final finalBalance = _totalDebit - _totalCredit;

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: Theme.of(context).brightness == Brightness.dark
            ? null
            : AppSizes.shadowSm,
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryItem(
              l10n.totalDebit,
              _totalDebit.toStringAsFixed(2),
              AppColors.error,
              Icons.arrow_upward_rounded,
              colorScheme,
            ),
          ),
          Container(
            width: 1,
            height: 48,
            color: colorScheme.outlineVariant,
            margin: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.md),
          ),
          Expanded(
            child: _buildSummaryItem(
              l10n.totalCredit,
              _totalCredit.toStringAsFixed(2),
              AppColors.success,
              Icons.arrow_downward_rounded,
              colorScheme,
            ),
          ),
          Container(
            width: 1,
            height: 48,
            color: colorScheme.outlineVariant,
            margin: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.md),
          ),
          Expanded(
            child: _buildSummaryItem(
              l10n.finalBalance,
              finalBalance.abs().toStringAsFixed(2),
              finalBalance > 0 ? AppColors.error : AppColors.success,
              Icons.account_balance_wallet_outlined,
              colorScheme,
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
    ColorScheme colorScheme, {
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
                color: colorScheme.onSurfaceVariant,
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

  Widget _buildMobileBottomSummary(
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    final finalBalance = _totalDebit - _totalCredit;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AlhaiSpacing.md,
        vertical: AlhaiSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
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
                      color: colorScheme.outline,
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
                      color: colorScheme.outline,
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
                  horizontal: AlhaiSpacing.sm,
                  vertical: AlhaiSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color:
                      (finalBalance > 0 ? AppColors.error : AppColors.success)
                          .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.finalBalance,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.outline,
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

  Widget _buildEmptyState(ColorScheme colorScheme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.xxxl),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: colorScheme.outline.withValues(alpha: 0.4),
            ),
            const SizedBox(height: AlhaiSpacing.md),
            Text(
              l10n.noTransactions,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAdjustmentDialog(ColorScheme colorScheme, AppLocalizations l10n) {
    final amountController = TextEditingController();
    final reasonController = TextEditingController();
    String adjustmentType = 'debit';

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          final dialogColorScheme = Theme.of(dialogContext).colorScheme;

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: dialogColorScheme.surface,
            child: Container(
              width: 440,
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
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.tune_rounded,
                          size: 20,
                          color: AppColors.warning,
                        ),
                      ),
                      const SizedBox(width: AlhaiSpacing.sm),
                      Text(
                        l10n.manualAdjustment,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: dialogColorScheme.onSurface,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        icon: Icon(
                          Icons.close_rounded,
                          color: dialogColorScheme.onSurfaceVariant,
                        ),
                        tooltip: l10n.close,
                      ),
                    ],
                  ),
                  const SizedBox(height: AlhaiSpacing.lg),
                  Text(
                    l10n.adjustmentType,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: dialogColorScheme.onSurfaceVariant,
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
                          dialogColorScheme,
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
                          dialogColorScheme,
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
                      color: dialogColorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.xs),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: dialogColorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      hintStyle: TextStyle(color: dialogColorScheme.outline),
                      prefixText: '${l10n.sar} ',
                      filled: true,
                      fillColor: dialogColorScheme.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AlhaiSpacing.md,
                        vertical: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.mdl),
                  Text(
                    l10n.adjustmentReason,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: dialogColorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.xs),
                  TextField(
                    controller: reasonController,
                    maxLines: 2,
                    style: TextStyle(color: dialogColorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: l10n.adjustmentReason,
                      hintStyle: TextStyle(color: dialogColorScheme.outline),
                      filled: true,
                      fillColor: dialogColorScheme.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AlhaiSpacing.md,
                        vertical: 14,
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
                            foregroundColor: dialogColorScheme.onSurfaceVariant,
                            side: BorderSide(
                              color: dialogColorScheme.outlineVariant,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(l10n.cancel),
                        ),
                      ),
                      const SizedBox(width: AlhaiSpacing.sm),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            final amount = double.tryParse(
                              amountController.text,
                            );
                            if (amount == null || amount <= 0) {
                              AlhaiSnackbar.error(
                                dialogContext,
                                l10n.enterValidAmount,
                              );
                              return;
                            }
                            Navigator.pop(dialogContext);
                            _handleSaveAdjustment(
                              adjustmentType,
                              amount,
                              reasonController.text,
                              DateTime.now(),
                              l10n,
                            );
                          },
                          icon: const Icon(Icons.save_outlined, size: 18),
                          label: Text(l10n.saveAdjustment),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
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
    ColorScheme colorScheme,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.1)
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? color : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: AlhaiSpacing.xs),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? color : colorScheme.onSurfaceVariant,
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
    setState(() => _isAdjusting = true);

    final isDebit = type == 'debit';
    // C-4 Session 4: accounts.balance, transactions.amount, balance_after are int cents.
    // Keep SAR doubles for display/public API; convert at DB boundary.
    final currentBal = (_account?.balance ?? 0) / 100.0;
    final signedAmount = isDebit ? amount : -amount;
    final newBalance = currentBal + signedAmount;
    final storeId = ref.read(currentStoreIdProvider);
    if (storeId == null) return;

    try {
      final txnId = const Uuid().v4();
      await _db.transaction(() async {
        await _db.transactionsDao.insertTransaction(
          TransactionsTableCompanion.insert(
            id: txnId,
            storeId: storeId,
            accountId: widget.id,
            type: 'adjustment',
            amount: (signedAmount * 100).round(),
            balanceAfter: (newBalance * 100).round(),
            description: Value(reason.isEmpty ? l10n.manualAdjustment : reason),
            createdAt: date,
          ),
        );
        await _db.accountsDao.updateBalance(widget.id, newBalance);
      });
      await _loadData();

      if (mounted) {
        AlhaiSnackbar.success(context, l10n.adjustmentSaved);
      }
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Save ledger adjustment');
      if (mounted) {
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
      }
    } finally {
      if (mounted) setState(() => _isAdjusting = false);
    }
  }

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
        return AppColors.secondary;
      case 'payment':
        return AppColors.success;
      case 'adjustment':
        return AppColors.warning;
      case 'return':
        return AppColors.purple;
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

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  String _formatDateTime(DateTime date) =>
      '${_formatDate(date)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}
