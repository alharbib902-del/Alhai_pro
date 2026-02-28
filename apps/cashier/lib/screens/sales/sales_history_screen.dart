/// Sales History Screen - Simplified invoices list
///
/// Shows past sales with date filter and search functionality.
/// Uses providers from alhai_shared_ui.
/// Supports: RTL Arabic, dark/light theme, responsive layout.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
// alhai_design_system is re-exported via alhai_shared_ui

/// شاشة سجل المبيعات
class SalesHistoryScreen extends ConsumerStatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  ConsumerState<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends ConsumerState<SalesHistoryScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final _db = GetIt.I<AppDatabase>();
  List<OrdersTableData> _orders = [];
  List<OrdersTableData> _filteredOrders = [];
  bool _isLoading = true;
  bool _showScrollToTop = false;
  String _dateFilter = 'today';
  DateTimeRange? _customRange;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final show = _scrollController.offset > 300;
      if (show != _showScrollToTop) setState(() => _showScrollToTop = show);
    });
    _loadOrders();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;
      final orders = await _db.ordersDao.getOrders(storeId);
      if (mounted) {
        setState(() {
          _orders = orders;
          _isLoading = false;
        });
        _applyFilters();
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase().trim();
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    setState(() {
      _filteredOrders = _orders.where((order) {
        // Date filter
        bool passDate = true;
        if (_dateFilter == 'today') {
          passDate = order.createdAt.isAfter(todayStart);
        } else if (_dateFilter == 'week') {
          passDate = order.createdAt
              .isAfter(todayStart.subtract(const Duration(days: 7)));
        } else if (_dateFilter == 'month') {
          passDate = order.createdAt.month == now.month &&
              order.createdAt.year == now.year;
        } else if (_dateFilter == 'custom' && _customRange != null) {
          passDate = order.createdAt.isAfter(_customRange!.start) &&
              order.createdAt
                  .isBefore(_customRange!.end.add(const Duration(days: 1)));
        }

        // Search filter
        bool passSearch = true;
        if (query.isNotEmpty) {
          passSearch = order.id.toLowerCase().contains(query) ||
              (order.customerId?.toLowerCase().contains(query) ?? false) ||
              order.total.toStringAsFixed(2).contains(query);
        }

        return passDate && passSearch;
      }).toList();

      // Sort by most recent
      _filteredOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
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

    return Scaffold(
      floatingActionButton: _showScrollToTop
          ? FloatingActionButton.small(
              onPressed: () => _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              ),
              child: const Icon(Icons.arrow_upward),
            )
          : null,
      body: Column(
      children: [
        AppHeader(
          title: l10n.salesHistory,
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
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: ShimmerList(itemCount: 6, itemHeight: 72),
                )
              : Column(
                  children: [
                    // Filters & Search Bar
                    Padding(
                      padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
                      child: Column(
                        children: [
                          _buildSearchBar(isDark, l10n),
                          const SizedBox(height: 12),
                          _buildDateFilters(isDark, l10n),
                        ],
                      ),
                    ),
                    // Summary stats
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: isMediumScreen ? 24 : 16),
                      child: _buildSummaryStats(isDark, l10n),
                    ),
                    const SizedBox(height: 12),
                    // Orders list
                    Expanded(
                      child: _filteredOrders.isEmpty
                          ? _buildEmptyState(isDark, l10n)
                          : RefreshIndicator(
                              onRefresh: _loadOrders,
                              color: AppColors.primary,
                              child: ListView.separated(
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: EdgeInsets.symmetric(
                                  horizontal: isMediumScreen ? 24 : 16,
                                  vertical: 8),
                              itemCount: _filteredOrders.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) => _buildOrderCard(
                                  _filteredOrders[index], isDark, l10n),
                            ),
                            ),
                    ),
                  ],
                ),
        ),
      ],
    ),
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
                onPressed: () {
                  _searchController.clear();
                },
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

  Widget _buildDateFilters(bool isDark, AppLocalizations l10n) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip(l10n.today, _dateFilter == 'today', () {
            setState(() => _dateFilter = 'today');
            _applyFilters();
          }, isDark),
          const SizedBox(width: 8),
          _buildChip(l10n.thisWeek, _dateFilter == 'week', () {
            setState(() => _dateFilter = 'week');
            _applyFilters();
          }, isDark),
          const SizedBox(width: 8),
          _buildChip(l10n.thisMonthPeriod, _dateFilter == 'month', () {
            setState(() => _dateFilter = 'month');
            _applyFilters();
          }, isDark),
          const SizedBox(width: 8),
          _buildChip(l10n.allPeriods, _dateFilter == 'all', () {
            setState(() => _dateFilter = 'all');
            _applyFilters();
          }, isDark),
          const SizedBox(width: 8),
          _buildChip(
            l10n.dateFromTo,
            _dateFilter == 'custom',
            () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                initialDateRange: _customRange,
              );
              if (picked != null) {
                setState(() {
                  _dateFilter = 'custom';
                  _customRange = picked;
                });
                _applyFilters();
              }
            },
            isDark,
            icon: Icons.date_range_outlined,
          ),
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
    final totalAmount = _filteredOrders.fold<double>(
        0, (sum, o) => sum + o.total);
    final count = _filteredOrders.length;

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
                Text(l10n.totalSales,
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
                Text(l10n.amount,
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.getTextSecondary(isDark))),
                const SizedBox(height: 4),
                Text('${totalAmount.toStringAsFixed(0)} ${l10n.sar}',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.success)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(
      OrdersTableData order, bool isDark, AppLocalizations l10n) {
    final time =
        '${order.createdAt.hour.toString().padLeft(2, '0')}:${order.createdAt.minute.toString().padLeft(2, '0')}';
    final date =
        '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.receipt_long_rounded,
                color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#${order.id.length > 8 ? order.id.substring(0, 8) : order.id}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.person_outline_rounded,
                        size: 13,
                        color: AppColors.getTextMuted(isDark)),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        order.customerId ?? l10n.cashCustomer,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.getTextSecondary(isDark),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.access_time_rounded,
                        size: 13,
                        color: AppColors.getTextMuted(isDark)),
                    const SizedBox(width: 4),
                    Text('$date $time',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.getTextMuted(isDark),
                        )),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${order.total.toStringAsFixed(0)} ${l10n.sar}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getStatusColor(order.status)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _getStatusLabel(order.status, l10n),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(order.status),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 64,
              color: AppColors.getTextMuted(isDark).withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(l10n.noTransactions,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.getTextMuted(isDark))),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return AppColors.success;
      case 'created':
        return AppColors.warning;
      case 'cancelled':
        return AppColors.error;
      case 'refunded':
        return const Color(0xFF8B5CF6);
      default:
        return AppColors.info;
    }
  }

  String _getStatusLabel(String status, AppLocalizations l10n) {
    switch (status) {
      case 'completed':
        return l10n.completed;
      case 'created':
        return l10n.pending;
      case 'cancelled':
        return l10n.cancelled;
      case 'refunded':
        return l10n.refunded;
      default:
        return status;
    }
  }
}
