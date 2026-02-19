import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../data/local/app_database.dart';
import '../../di/injection.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/products_providers.dart';

/// شاشة كشف حساب العميل (Customer Ledger)
/// تعرض جميع حركات العميل مع فلترة ومجاميع وتسويات يدوية
class CustomerLedgerScreen extends ConsumerStatefulWidget {
  final String accountId;
  final String customerName;

  const CustomerLedgerScreen({
    super.key,
    required this.accountId,
    required this.customerName,
  });

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
  String _dateFilter = 'all'; // all, thisMonth, threeMonths
  String _typeFilter = 'all'; // all, invoice, payment, return, adjustment
  DateTimeRange? _customDateRange;

  @override
  void initState() {
    super.initState();
    _loadData();
  }  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final account = await _db.accountsDao.getAccountById(widget.accountId);
      final transactions =
          await _db.transactionsDao.getAccountTransactions(widget.accountId);

      if (mounted) {
        setState(() {
          _account = account;
          _transactions = transactions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // =========================================================================
  // FILTER LOGIC
  // =========================================================================

  /// Convert TransactionsTableData to ledger map format used by the UI.
  /// Positive amount = debit (invoice/interest), negative = credit (payment/return).
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

  List<Map<String, dynamic>> get _filteredTransactions {
    // Convert all DB transactions to map format
    var list = _transactions.expand(_txnToMap).toList();

    // Date filter
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
              (t['date'] as DateTime).isBefore(
                  _customDateRange!.end.add(const Duration(days: 1))))
          .toList();
    }

    // Type filter
    if (_typeFilter != 'all') {
      list = list.where((t) => t['type'] == _typeFilter).toList();
    }

    return list;
  }

  double get _totalDebit {
    return _filteredTransactions.fold(
        0.0, (sum, t) => sum + (t['debit'] as double));
  }

  double get _totalCredit {
    return _filteredTransactions.fold(
        0.0, (sum, t) => sum + (t['credit'] as double));
  }

  double get _currentBalance {
    return _account?.balance ?? 0.0;
  }

  String get _customerInitials {
    final parts = widget.customerName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return widget.customerName.isNotEmpty
        ? widget.customerName[0].toUpperCase()
        : '?';
  }

  // =========================================================================
  // BUILD
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < AppBreakpoints.tablet;
    final isDesktop = screenWidth >= AppBreakpoints.laptop;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAdjustmentDialog(isDark, l10n),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.tune_rounded, size: 20),
        label: Text(l10n.manualAdjustment),
      ),
      body: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      // Top bar
                      _buildTopBar(isDark, l10n),
                      // Scrollable content
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 32 : 16,
                            vertical: 16,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Customer info card
                              _buildCustomerInfoCard(isDark, l10n, isMobile),
                              const SizedBox(height: 16),
                              // Filter section
                              _buildFilterSection(isDark, l10n, isMobile),
                              const SizedBox(height: 16),
                              // Transactions (table or cards)
                              isMobile
                                  ? _buildMobileTransactions(isDark, l10n)
                                  : _buildDesktopTable(isDark, l10n),
                              const SizedBox(height: 16),
                              // Summary (desktop only, mobile has bottom bar)
                              if (!isMobile)
                                _buildSummaryBar(isDark, l10n, isMobile),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                      // Mobile fixed bottom summary
                      if (isMobile) _buildMobileBottomSummary(isDark, l10n),
                    ],
                  ),
    );
  }

  // =========================================================================
  // TOP BAR
  // =========================================================================

  Widget _buildTopBar(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        border: Border(
          bottom: BorderSide(color: AppColors.getBorder(isDark), width: 1),
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
                color: AppColors.getTextPrimary(isDark),
              ),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.getSurfaceVariant(isDark),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.customerLedger,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.getTextPrimary(isDark),
                    ),
                  ),
                  Text(
                    widget.customerName,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.getTextSecondary(isDark),
                    ),
                  ),
                ],
              ),
            ),
            // Export PDF button
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.picture_as_pdf_outlined,
                color: AppColors.getTextSecondary(isDark),
              ),
              tooltip: l10n.exportPdf,
            ),
            // Print button
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.print_outlined,
                color: AppColors.getTextSecondary(isDark),
              ),
              tooltip: l10n.printReport,
            ),
            // Refresh
            IconButton(
              onPressed: _loadData,
              icon: Icon(
                Icons.refresh_rounded,
                color: AppColors.getTextSecondary(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // CUSTOMER INFO CARD
  // =========================================================================

  Widget _buildCustomerInfoCard(
      bool isDark, AppLocalizations l10n, bool isMobile) {
    final isDebt = _currentBalance > 0;
    final balanceColor = isDebt ? AppColors.error : AppColors.success;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(color: AppColors.getBorder(isDark)),
        boxShadow: isDark ? null : AppSizes.shadowSm,
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: isMobile ? 48 : 56,
            height: isMobile ? 48 : 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
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
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Name + Phone
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.customerName,
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.phone_outlined,
                        size: 14, color: AppColors.getTextMuted(isDark)),
                    const SizedBox(width: 4),
                    Text(
                      _account?.phone ?? '+966 50 123 4567',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.getTextSecondary(isDark),
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

  // =========================================================================
  // FILTER SECTION
  // =========================================================================

  Widget _buildFilterSection(
      bool isDark, AppLocalizations l10n, bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(color: AppColors.getBorder(isDark)),
        boxShadow: isDark ? null : AppSizes.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date range filter
          Row(
            children: [
              Icon(Icons.calendar_today_outlined,
                  size: 16, color: AppColors.getTextMuted(isDark)),
              const SizedBox(width: 8),
              Text(
                l10n.date,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getTextSecondary(isDark),
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
                  isDark,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  l10n.thisMonthPeriod,
                  _dateFilter == 'thisMonth',
                  () => setState(() => _dateFilter = 'thisMonth'),
                  isDark,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  l10n.threeMonths,
                  _dateFilter == 'threeMonths',
                  () => setState(() => _dateFilter = 'threeMonths'),
                  isDark,
                ),
                const SizedBox(width: 8),
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
          const SizedBox(height: 16),
          // Type filter
          Row(
            children: [
              Icon(Icons.filter_list_rounded,
                  size: 16, color: AppColors.getTextMuted(isDark)),
              const SizedBox(width: 8),
              Text(
                l10n.type,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getTextSecondary(isDark),
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
                  isDark,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  l10n.invoices,
                  _typeFilter == 'invoice',
                  () => setState(() => _typeFilter = 'invoice'),
                  isDark,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  l10n.payment,
                  _typeFilter == 'payment',
                  () => setState(() => _typeFilter = 'payment'),
                  isDark,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  l10n.returns,
                  _typeFilter == 'return',
                  () => setState(() => _typeFilter = 'return'),
                  isDark,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  l10n.adjustments,
                  _typeFilter == 'adjustment',
                  () => setState(() => _typeFilter = 'adjustment'),
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
              : AppColors.getSurfaceVariant(isDark),
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.getBorder(isDark),
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
                    ? Colors.white
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
                    ? Colors.white
                    : AppColors.getTextSecondary(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // DESKTOP TABLE
  // =========================================================================

  Widget _buildDesktopTable(bool isDark, AppLocalizations l10n) {
    final txns = _filteredTransactions;

    if (txns.isEmpty) {
      return _buildEmptyState(isDark, l10n);
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(color: AppColors.getBorder(isDark)),
        boxShadow: isDark ? null : AppSizes.shadowSm,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Table header
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.getSurfaceVariant(isDark),
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
          // Table rows
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
          color: AppColors.getTextSecondary(isDark),
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
                : AppColors.getSurfaceVariant(isDark)
                    .withValues(alpha: 0.5)),
        border: Border(
          bottom: BorderSide(
            color: AppColors.getBorder(isDark).withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          // Date
          Expanded(
            flex: 2,
            child: Text(
              _formatDate(date),
              style: TextStyle(
                fontSize: 13,
                color: AppColors.getTextSecondary(isDark),
              ),
            ),
          ),
          // Statement (icon + text)
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
                          : AppColors.getTextPrimary(isDark),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Reference
          Expanded(
            flex: 2,
            child: Text(
              txn['reference'] as String,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.getTextSecondary(isDark),
                fontFamily: 'monospace',
              ),
            ),
          ),
          // Debit
          Expanded(
            flex: 2,
            child: Text(
              debit > 0 ? debit.toStringAsFixed(2) : '-',
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13,
                fontWeight: debit > 0 ? FontWeight.w600 : FontWeight.w400,
                color: debit > 0
                    ? AppColors.error
                    : AppColors.getTextMuted(isDark),
              ),
            ),
          ),
          // Credit
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
                    : AppColors.getTextMuted(isDark),
              ),
            ),
          ),
          // Balance
          Expanded(
            flex: 2,
            child: Text(
              balance.toStringAsFixed(2),
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.getTextPrimary(isDark),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // MOBILE TRANSACTIONS (CARDS)
  // =========================================================================

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

    return Container(
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: isAdjustment
              ? AppColors.warning.withValues(alpha: 0.4)
              : AppColors.getBorder(isDark),
        ),
        boxShadow: isDark ? null : AppSizes.shadowSm,
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Left accent bar for adjustments
            if (isAdjustment)
              Container(
                width: 4,
                color: AppColors.warning,
              ),
            // Content
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
                    // Row 1: Icon + Type + Date
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color:
                                _getTypeColor(type).withValues(alpha: 0.12),
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
                                      : AppColors.getTextPrimary(isDark),
                                ),
                              ),
                              Text(
                                _formatDateTime(date),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.getTextMuted(isDark),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Amount
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
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.getSurfaceVariant(isDark),
                                borderRadius: BorderRadius.circular(
                                    AppSizes.radiusFull),
                              ),
                              child: Text(
                                '${l10n.balanceCol}: ${balance.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      AppColors.getTextSecondary(isDark),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Row 2: Reference
                    if (txn['reference'] != '-') ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const SizedBox(width: 42),
                          Icon(Icons.tag_rounded,
                              size: 12,
                              color: AppColors.getTextMuted(isDark)),
                          const SizedBox(width: 4),
                          Text(
                            txn['reference'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.getTextMuted(isDark),
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

  // =========================================================================
  // SUMMARY BAR
  // =========================================================================

  Widget _buildSummaryBar(bool isDark, AppLocalizations l10n, bool isMobile) {
    final finalBalance = _totalDebit - _totalCredit;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(color: AppColors.getBorder(isDark)),
        boxShadow: isDark ? null : AppSizes.shadowSm,
      ),
      child: Row(
        children: [
          // Total Debit
          Expanded(
            child: _buildSummaryItem(
              l10n.totalDebit,
              _totalDebit.toStringAsFixed(2),
              AppColors.error,
              Icons.arrow_upward_rounded,
              isDark,
            ),
          ),
          // Divider
          Container(
            width: 1,
            height: 48,
            color: AppColors.getBorder(isDark),
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
          // Total Credit
          Expanded(
            child: _buildSummaryItem(
              l10n.totalCredit,
              _totalCredit.toStringAsFixed(2),
              AppColors.success,
              Icons.arrow_downward_rounded,
              isDark,
            ),
          ),
          // Divider
          Container(
            width: 1,
            height: 48,
            color: AppColors.getBorder(isDark),
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
          // Final Balance
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
                color: AppColors.getTextSecondary(isDark),
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

  // =========================================================================
  // MOBILE BOTTOM SUMMARY
  // =========================================================================

  Widget _buildMobileBottomSummary(bool isDark, AppLocalizations l10n) {
    final finalBalance = _totalDebit - _totalCredit;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        border: Border(
          top: BorderSide(color: AppColors.getBorder(isDark), width: 1),
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
            // Total Debit
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.totalDebit,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.getTextMuted(isDark),
                    ),
                  ),
                  const SizedBox(height: 2),
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
            // Total Credit
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.totalCredit,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.getTextMuted(isDark),
                    ),
                  ),
                  const SizedBox(height: 2),
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
            // Final Balance
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: (finalBalance > 0
                          ? AppColors.error
                          : AppColors.success)
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
                        color: AppColors.getTextMuted(isDark),
                      ),
                    ),
                    const SizedBox(height: 2),
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

  // =========================================================================
  // EMPTY STATE
  // =========================================================================

  Widget _buildEmptyState(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: AppColors.getTextMuted(isDark).withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noTransactions,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.getTextMuted(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // MANUAL ADJUSTMENT DIALOG
  // =========================================================================

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

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusXl),
            ),
            backgroundColor: AppColors.getSurface(dialogIsDark),
            child: Container(
              width: 440,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
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
                      const SizedBox(width: 12),
                      Text(
                        l10n.manualAdjustment,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.getTextPrimary(dialogIsDark),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        icon: Icon(Icons.close_rounded,
                            color:
                                AppColors.getTextSecondary(dialogIsDark)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Adjustment Type
                  Text(
                    l10n.adjustmentType,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.getTextSecondary(dialogIsDark),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTypeOption(
                          l10n.debitAdjustment,
                          Icons.arrow_upward_rounded,
                          AppColors.error,
                          adjustmentType == 'debit',
                          () => setDialogState(
                              () => adjustmentType = 'debit'),
                          dialogIsDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTypeOption(
                          l10n.creditAdjustment,
                          Icons.arrow_downward_rounded,
                          AppColors.success,
                          adjustmentType == 'credit',
                          () => setDialogState(
                              () => adjustmentType = 'credit'),
                          dialogIsDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Amount
                  Text(
                    l10n.adjustmentAmount,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.getTextSecondary(dialogIsDark),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      color: AppColors.getTextPrimary(dialogIsDark),
                    ),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      hintStyle: TextStyle(
                          color: AppColors.getTextMuted(dialogIsDark)),
                      prefixText: '${l10n.sar} ',
                      filled: true,
                      fillColor:
                          AppColors.getSurfaceVariant(dialogIsDark),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusLg),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Reason
                  Text(
                    l10n.adjustmentReason,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.getTextSecondary(dialogIsDark),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: reasonController,
                    maxLines: 2,
                    style: TextStyle(
                      color: AppColors.getTextPrimary(dialogIsDark),
                    ),
                    decoration: InputDecoration(
                      hintText: l10n.adjustmentReason,
                      hintStyle: TextStyle(
                          color: AppColors.getTextMuted(dialogIsDark)),
                      filled: true,
                      fillColor:
                          AppColors.getSurfaceVariant(dialogIsDark),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusLg),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Date
                  Text(
                    l10n.adjustmentDate,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.getTextSecondary(dialogIsDark),
                    ),
                  ),
                  const SizedBox(height: 8),
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
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusLg),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color:
                            AppColors.getSurfaceVariant(dialogIsDark),
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusLg),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today_outlined,
                              size: 16,
                              color: AppColors.getTextMuted(
                                  dialogIsDark)),
                          const SizedBox(width: 10),
                          Text(
                            _formatDate(selectedDate),
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.getTextPrimary(
                                  dialogIsDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              Navigator.pop(dialogContext),
                          style: OutlinedButton.styleFrom(
                            foregroundColor:
                                AppColors.getTextSecondary(dialogIsDark),
                            side: BorderSide(
                                color: AppColors.getBorder(dialogIsDark)),
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppSizes.radiusLg),
                            ),
                          ),
                          child: Text(l10n.cancel),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            final amount = double.tryParse(
                                amountController.text);
                            if (amount == null || amount <= 0) {
                              ScaffoldMessenger.of(dialogContext)
                                  .showSnackBar(
                                SnackBar(
                                  content:
                                      Text(l10n.enterValidAmount),
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
                          icon: const Icon(Icons.save_outlined,
                              size: 18),
                          label: Text(l10n.saveAdjustment),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppSizes.radiusLg),
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
              : AppColors.getSurfaceVariant(isDark),
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(
            color: isSelected ? color : AppColors.getBorder(isDark),
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
                    : AppColors.getTextSecondary(isDark)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? color
                    : AppColors.getTextSecondary(isDark),
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
    final storeId = ref.read(currentStoreIdProvider) ?? kDemoStoreId;

    try {
      final txnId = 'ADJ-${DateTime.now().millisecondsSinceEpoch}';
      await _db.transactionsDao.insertTransaction(
        TransactionsTableCompanion.insert(
          id: txnId,
          storeId: storeId,
          accountId: widget.accountId,
          type: 'adjustment',
          amount: signedAmount,
          balanceAfter: newBalance,
          description: Value(reason.isEmpty ? l10n.manualAdjustment : reason),
          createdAt: date,
        ),
      );
      // Update account balance
      await _db.accountsDao.updateBalance(widget.accountId, newBalance);
      // Reload data
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
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // =========================================================================
  // HELPERS
  // =========================================================================

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
        return const Color(0xFFF97316); // Orange
      case 'payment':
        return AppColors.success;
      case 'adjustment':
        return AppColors.warning;
      case 'return':
        return const Color(0xFF8B5CF6); // Purple
      default:
        return AppColors.grey400;
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
