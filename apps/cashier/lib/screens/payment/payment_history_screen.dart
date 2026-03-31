/// Payment History Screen - List all payments with filters
///
/// Lists all payments with filters (cash, card, credit).
/// Shows payment method icon, amount, date, order reference.
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
import 'package:alhai_design_system/alhai_design_system.dart' show AlhaiBreakpoints;
// alhai_design_system is re-exported via alhai_shared_ui
import '../../core/services/sentry_service.dart';

/// شاشة سجل المدفوعات
class PaymentHistoryScreen extends ConsumerStatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  ConsumerState<PaymentHistoryScreen> createState() =>
      _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends ConsumerState<PaymentHistoryScreen> {
  final _searchController = TextEditingController();
  final _db = GetIt.I<AppDatabase>();
  List<SalesTableData> _allOrders = [];
  List<SalesTableData> _filteredOrders = [];
  bool _isLoading = true;
  String? _error;
  String _methodFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadPayments();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPayments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;
      final orders = await _db.salesDao.getAllSales(storeId);
      // Only completed orders
      final completed =
          orders.where((o) => o.status == 'completed').toList();
      completed.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (mounted) {
        setState(() {
          _allOrders = completed;
          _isLoading = false;
        });
        _applyFilters();
      }
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Load payment history');
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
      _filteredOrders = _allOrders.where((order) {
        // Method filter
        bool passMethod = true;
        if (_methodFilter != 'all') {
          passMethod =
              order.paymentMethod == _methodFilter;
        }

        // Search filter
        bool passSearch = true;
        if (query.isNotEmpty) {
          passSearch = order.id.toLowerCase().contains(query) ||
              (order.customerId?.toLowerCase().contains(query) ?? false) ||
              order.total.toStringAsFixed(2).contains(query);
        }

        return passMethod && passSearch;
      }).toList();
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
          title: 'Payment History',
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
                      message: _error!, onRetry: _loadPayments)
                  : Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
                      child: Column(
                        children: [
                          _buildSearchBar(isDark, l10n),
                          const SizedBox(height: 12),
                          _buildMethodFilters(isDark, l10n),
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
                      child: _filteredOrders.isEmpty
                          ? _buildEmptyState(isDark, l10n)
                          : ListView.separated(
                              padding: EdgeInsets.symmetric(
                                  horizontal: isMediumScreen ? 24 : 16,
                                  vertical: 8),
                              itemCount: _filteredOrders.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) =>
                                  _buildPaymentCard(
                                      _filteredOrders[index], isDark, l10n),
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

  Widget _buildMethodFilters(bool isDark, AppLocalizations l10n) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip(l10n.allMovements, _methodFilter == 'all', () {
            setState(() => _methodFilter = 'all');
            _applyFilters();
          }, isDark),
          const SizedBox(width: 8),
          _buildChip(l10n.cash, _methodFilter == 'cash', () {
            setState(() => _methodFilter = 'cash');
            _applyFilters();
          }, isDark, icon: Icons.money_rounded),
          const SizedBox(width: 8),
          _buildChip(l10n.card, _methodFilter == 'card', () {
            setState(() => _methodFilter = 'card');
            _applyFilters();
          }, isDark, icon: Icons.credit_card_rounded),
          const SizedBox(width: 8),
          _buildChip(l10n.credit, _methodFilter == 'credit', () {
            setState(() => _methodFilter = 'credit');
            _applyFilters();
          }, isDark, icon: Icons.account_balance_wallet_rounded),
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
                Text('Payments',
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

  Widget _buildPaymentCard(
      SalesTableData order, bool isDark, AppLocalizations l10n) {
    final method = order.paymentMethod;
    final icon = _getPaymentIcon(method);
    final color = _getPaymentColor(method);
    final label = _getPaymentLabel(method, l10n);
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
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '#${order.id.length > 8 ? order.id.substring(0, 8) : order.id}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.getTextPrimary(isDark),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
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
          Text(
            '${order.total.toStringAsFixed(0)} ${l10n.sar}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
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
          Icon(Icons.payments_outlined,
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

  IconData _getPaymentIcon(String method) {
    switch (method) {
      case 'cash':
        return Icons.money_rounded;
      case 'card':
        return Icons.credit_card_rounded;
      case 'credit':
        return Icons.account_balance_wallet_rounded;
      case 'transfer':
        return Icons.swap_horiz_rounded;
      default:
        return Icons.payment_rounded;
    }
  }

  Color _getPaymentColor(String method) {
    switch (method) {
      case 'cash':
        return AppColors.success;
      case 'card':
        return AppColors.info;
      case 'credit':
        return AppColors.warning;
      case 'transfer':
        return const Color(0xFF8B5CF6);
      default:
        return AppColors.primary;
    }
  }

  String _getPaymentLabel(String method, AppLocalizations l10n) {
    switch (method) {
      case 'cash':
        return l10n.cash;
      case 'card':
        return l10n.card;
      case 'credit':
        return l10n.credit;
      case 'transfer':
        return 'Transfer';
      default:
        return method;
    }
  }
}
