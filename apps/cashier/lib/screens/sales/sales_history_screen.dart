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
import '../../core/services/sentry_service.dart';

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
  List<SalesTableData> _orders = [];
  List<SalesTableData> _filteredOrders = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  bool _showScrollToTop = false;
  String _dateFilter = 'today';
  DateTimeRange? _customRange;

  /// عدد العناصر لكل صفحة
  static const int _pageSize = 50;
  /// هل يوجد المزيد من البيانات؟
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final show = _scrollController.offset > 300;
      if (show != _showScrollToTop) setState(() => _showScrollToTop = show);
      // Infinite scroll: تحميل المزيد عند الوصول لنهاية القائمة
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoadingMore &&
          _hasMore &&
          !_isLoading) {
        _loadMore();
      }
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

  /// حساب نطاق التاريخ بناءً على الفلتر الحالي
  ({DateTime? start, DateTime? end}) _getDateRange() {
    final now = DateTime.now().toUtc();
    final todayStart = DateTime.utc(now.year, now.month, now.day);

    switch (_dateFilter) {
      case 'today':
        return (start: todayStart, end: null);
      case 'week':
        return (start: todayStart.subtract(const Duration(days: 7)), end: null);
      case 'month':
        return (start: DateTime.utc(now.year, now.month, 1), end: null);
      case 'custom' when _customRange != null:
        return (
          start: _customRange!.start,
          end: _customRange!.end.add(const Duration(days: 1)),
        );
      default: // 'all'
        return (start: null, end: null);
    }
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _orders = [];
      _filteredOrders = [];
      _hasMore = true;
    });
    try {
      // ── انتظر اكتمال التزامن العام (InitialSync) إن لم يكتمل بعد ──
      // هذا يضمن توفر البيانات حتى لو المستخدم فتح /sales مباشرة
      try {
        await ref.read(globalSyncActivationProvider.future);
      } catch (_) {
        // التزامن فشل أو غير متاح - نستمر بالبيانات المحلية
      }

      // ── تحميل البيانات من القاعدة المحلية (مع pagination) ──
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;

      final dateRange = _getDateRange();
      final orders = await _db.salesDao.getSalesPaginated(
        storeId,
        offset: 0,
        limit: _pageSize,
        startDate: dateRange.start,
        endDate: dateRange.end,
      );
      if (mounted) {
        setState(() {
          _orders = orders;
          _hasMore = orders.length >= _pageSize;
          _isLoading = false;
        });
        _applyFilters();
      }
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Load sales history');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = '$e';
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;

      final dateRange = _getDateRange();
      final moreOrders = await _db.salesDao.getSalesPaginated(
        storeId,
        offset: _orders.length,
        limit: _pageSize,
        startDate: dateRange.start,
        endDate: dateRange.end,
      );
      if (mounted) {
        setState(() {
          _orders.addAll(moreOrders);
          _hasMore = moreOrders.length >= _pageSize;
          _isLoadingMore = false;
        });
        _applyFilters();
      }
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Load more sales');
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase().trim();

    setState(() {
      if (query.isEmpty) {
        // لا يوجد بحث نصي - البيانات مفلترة بالتاريخ من الاستعلام أصلاً
        _filteredOrders = List.from(_orders);
      } else {
        // بحث نصي على البيانات المحملة فقط
        _filteredOrders = _orders.where((order) {
          return order.id.toLowerCase().contains(query) ||
              (order.customerId?.toLowerCase().contains(query) ?? false) ||
              (order.customerName?.toLowerCase().contains(query) ?? false) ||
              order.total.toStringAsFixed(2).contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isMediumScreen = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
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
              : _error != null
                  ? AppErrorState.general(
                      message: _error!, onRetry: _loadOrders)
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
                              itemCount: _filteredOrders.length + (_isLoadingMore || _hasMore ? 1 : 0),
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                if (index < _filteredOrders.length) {
                                  return _buildOrderCard(
                                      _filteredOrders[index], isDark, l10n);
                                }
                                // مؤشر تحميل المزيد
                                if (_isLoadingMore) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(child: CircularProgressIndicator()),
                                  );
                                }
                                // زر تحميل المزيد
                                if (_hasMore) {
                                  return Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Center(
                                      child: OutlinedButton.icon(
                                        onPressed: _loadMore,
                                        icon: const Icon(Icons.expand_more),
                                        label: const Text('تحميل المزيد'),
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
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
            _loadOrders();
          }, isDark),
          const SizedBox(width: 8),
          _buildChip(l10n.thisWeek, _dateFilter == 'week', () {
            setState(() => _dateFilter = 'week');
            _loadOrders();
          }, isDark),
          const SizedBox(width: 8),
          _buildChip(l10n.thisMonthPeriod, _dateFilter == 'month', () {
            setState(() => _dateFilter = 'month');
            _loadOrders();
          }, isDark),
          const SizedBox(width: 8),
          _buildChip(l10n.allPeriods, _dateFilter == 'all', () {
            setState(() => _dateFilter = 'all');
            _loadOrders();
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
                _loadOrders();
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

    // حساب مجاميع طرق الدفع
    double cashTotal = 0;
    double cardTotal = 0;
    double creditTotal = 0;
    for (final o in _filteredOrders) {
      // استخدام الأعمدة الجديدة إن وجدت (المبيعات الجديدة)
      if (o.cashAmount != null || o.cardAmount != null || o.creditAmount != null) {
        cashTotal += o.cashAmount ?? 0;
        cardTotal += o.cardAmount ?? 0;
        creditTotal += o.creditAmount ?? 0;
      } else {
        // Fallback للمبيعات القديمة بدون تفصيل
        switch (o.paymentMethod) {
          case 'cash':
            cashTotal += o.total;
          case 'card':
            cardTotal += o.total;
          case 'credit':
            creditTotal += o.total;
          case 'mixed':
            final received = o.amountReceived ?? 0;
            if (received > 0) {
              cashTotal += received;
            }
            if (!o.isPaid && received < o.total) {
              creditTotal += (o.total - received);
            } else if (received < o.total) {
              cardTotal += (o.total - received);
            }
        }
      }
    }

    return Column(
      children: [
        // الصف الأول: إجمالي المبيعات والمبلغ
        Container(
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
                    Text('${totalAmount.toStringAsFixed(2)} ${l10n.sar}',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.success)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // الصف الثاني: تفصيل طرق الدفع (نقد - بطاقة - آجل)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.getSurface(isDark),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.getBorder(isDark)),
          ),
          child: Row(
            children: [
              // نقد
              Expanded(
                child: _buildPaymentSummaryItem(
                  icon: Icons.payments_outlined,
                  label: l10n.cash,
                  amount: cashTotal,
                  color: AppColors.success,
                  isDark: isDark,
                  l10n: l10n,
                ),
              ),
              Container(
                width: 1,
                height: 36,
                color: AppColors.getBorder(isDark),
              ),
              // بطاقة
              Expanded(
                child: _buildPaymentSummaryItem(
                  icon: Icons.credit_card_rounded,
                  label: l10n.card,
                  amount: cardTotal,
                  color: AppColors.info,
                  isDark: isDark,
                  l10n: l10n,
                ),
              ),
              Container(
                width: 1,
                height: 36,
                color: AppColors.getBorder(isDark),
              ),
              // آجل
              Expanded(
                child: _buildPaymentSummaryItem(
                  icon: Icons.account_balance_wallet_outlined,
                  label: l10n.credit,
                  amount: creditTotal,
                  color: AppColors.warning,
                  isDark: isDark,
                  l10n: l10n,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSummaryItem({
    required IconData icon,
    required String label,
    required double amount,
    required Color color,
    required bool isDark,
    required AppLocalizations l10n,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.getTextSecondary(isDark))),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${amount.toStringAsFixed(2)} ${l10n.sar}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(
      SalesTableData order, bool isDark, AppLocalizations l10n) {
    final utc = order.createdAt.toUtc();
    final time =
        '${utc.hour.toString().padLeft(2, '0')}:${utc.minute.toString().padLeft(2, '0')}';
    final date =
        '${utc.day}/${utc.month}/${utc.year}';

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
              color: _getPaymentMethodColor(order.paymentMethod)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(_getPaymentMethodIcon(order.paymentMethod),
                color: _getPaymentMethodColor(order.paymentMethod), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '#${order.id.length > 8 ? order.id.substring(0, 8) : order.id}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.getTextPrimary(isDark),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // شارة طريقة الدفع
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getPaymentMethodColor(order.paymentMethod)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _getPaymentMethodLabel(order.paymentMethod, l10n),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color:
                              _getPaymentMethodColor(order.paymentMethod),
                        ),
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
                        order.customerName ?? order.customerId ?? l10n.cashCustomer,
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
                '${order.total.toStringAsFixed(2)} ${l10n.sar}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              // تفاصيل الدفع
              _buildPaymentDetails(order, isDark, l10n),
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

  /// تفاصيل الدفع حسب الطريقة
  Widget _buildPaymentDetails(
      SalesTableData order, bool isDark, AppLocalizations l10n) {
    final method = order.paymentMethod;
    final total = order.total;
    final color = _getPaymentMethodColor(method);

    // دفع بسيط (نقدي أو بطاقة أو آجل)
    if (method != 'mixed') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getPaymentMethodIcon(method), size: 11, color: color),
          const SizedBox(width: 3),
          Text(
            '${total.toStringAsFixed(2)} ${l10n.sar}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      );
    }

    // دفع مختلط - نعرض التفصيل (نقد / بطاقة / آجل)
    // استخدام الأعمدة الجديدة إن وجدت
    if (order.cashAmount != null || order.cardAmount != null || order.creditAmount != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (order.cashAmount != null && order.cashAmount! > 0)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.payments_outlined,
                    size: 11, color: AppColors.success),
                const SizedBox(width: 3),
                Text(
                  order.cashAmount!.toStringAsFixed(2),
                  style: const TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w500,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          if (order.cardAmount != null && order.cardAmount! > 0)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.credit_card_rounded,
                    size: 11, color: AppColors.info),
                const SizedBox(width: 3),
                Text(
                  order.cardAmount!.toStringAsFixed(2),
                  style: const TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w500,
                    color: AppColors.info,
                  ),
                ),
              ],
            ),
          if (order.creditAmount != null && order.creditAmount! > 0)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.account_balance_wallet_outlined,
                    size: 11, color: AppColors.warning),
                const SizedBox(width: 3),
                Text(
                  order.creditAmount!.toStringAsFixed(2),
                  style: const TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w500,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
        ],
      );
    }
    // Fallback للمبيعات القديمة بدون تفصيل
    if (order.amountReceived != null && order.amountReceived! > 0) {
      final paidPart = order.amountReceived!;
      final remainingPart = total - paidPart;
      final isCredit = !order.isPaid && remainingPart > 0;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.payments_outlined,
                  size: 11, color: AppColors.success),
              const SizedBox(width: 3),
              Text(
                paidPart.toStringAsFixed(2),
                style: const TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w500,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          if (remainingPart > 0)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isCredit
                      ? Icons.account_balance_wallet_outlined
                      : Icons.credit_card_rounded,
                  size: 11,
                  color: isCredit ? AppColors.warning : AppColors.info,
                ),
                const SizedBox(width: 3),
                Text(
                  remainingPart.toStringAsFixed(2),
                  style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w500,
                    color: isCredit ? AppColors.warning : AppColors.info,
                  ),
                ),
              ],
            ),
        ],
      );
    }

    // مختلط بدون تفاصيل
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.swap_horiz_rounded, size: 11, color: color),
        const SizedBox(width: 3),
        Text(
          '${total.toStringAsFixed(2)} ${l10n.sar}',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  /// لون طريقة الدفع
  Color _getPaymentMethodColor(String method) {
    switch (method) {
      case 'cash':
        return AppColors.success;
      case 'card':
        return AppColors.info;
      case 'mixed':
        return const Color(0xFF8B5CF6);
      case 'credit':
        return AppColors.warning;
      default:
        return AppColors.info;
    }
  }

  /// أيقونة طريقة الدفع
  IconData _getPaymentMethodIcon(String method) {
    switch (method) {
      case 'cash':
        return Icons.payments_outlined;
      case 'card':
        return Icons.credit_card_rounded;
      case 'mixed':
        return Icons.swap_horiz_rounded;
      case 'credit':
        return Icons.account_balance_wallet_outlined;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  /// اسم طريقة الدفع
  String _getPaymentMethodLabel(String method, AppLocalizations l10n) {
    switch (method) {
      case 'cash':
        return l10n.cash;
      case 'card':
        return l10n.card;
      case 'mixed':
        return l10n.mixed;
      case 'credit':
        return l10n.credit;
      default:
        return method;
    }
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
