/// Reprint Receipt Screen - Search past sales and reprint
///
/// Search past sales, select one, and reprint the receipt.
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
import 'package:alhai_design_system/alhai_design_system.dart'
    show AlhaiBreakpoints, AlhaiSnackbar, AlhaiSpacing;
// alhai_design_system is re-exported via alhai_shared_ui
import '../../core/services/sentry_service.dart';
import '../../widgets/zatca_qr_widget.dart';

/// شاشة إعادة طباعة الفاتورة
class ReprintReceiptScreen extends ConsumerStatefulWidget {
  const ReprintReceiptScreen({super.key});

  @override
  ConsumerState<ReprintReceiptScreen> createState() =>
      _ReprintReceiptScreenState();
}

class _ReprintReceiptScreenState extends ConsumerState<ReprintReceiptScreen> {
  final _searchController = TextEditingController();
  final _db = GetIt.I<AppDatabase>();
  List<SalesTableData> _allOrders = [];
  List<SalesTableData> _filteredOrders = [];
  StoresTableData? _store;
  bool _isLoading = true;
  String? _error;
  String? _selectedOrderId;
  bool _isPrinting = false;

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _searchController.addListener(_filterOrders);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;
      final orders = await _db.salesDao.getAllSales(storeId);
      // Sort most recent first, limit to recent 100
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final recentOrders = orders.take(100).toList();
      // Load store data for ZATCA QR
      final store = await _db.storesDao.getStoreById(storeId);

      if (mounted) {
        setState(() {
          _allOrders = recentOrders;
          _filteredOrders = recentOrders;
          _store = store;
          _isLoading = false;
        });
      }
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Load orders for reprint');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = '$e';
        });
      }
    }
  }

  void _filterOrders() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredOrders = _allOrders;
      } else {
        _filteredOrders = _allOrders.where((order) {
          return order.id.toLowerCase().contains(query) ||
              (order.customerId?.toLowerCase().contains(query) ?? false) ||
              order.total.toStringAsFixed(2).contains(query);
        }).toList();
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
          title: l10n.reprintReceipt,
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
                  message: _error!,
                  onRetry: _loadOrders,
                )
              : isWideScreen
              ? _buildWideLayout(isDark, l10n, isMediumScreen)
              : _buildNarrowLayout(isDark, l10n, isMediumScreen),
        ),
      ],
    );
  }

  String _getDateSubtitle(AppLocalizations l10n) {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year} \u2022 ${l10n.mainBranch}';
  }

  Widget _buildWideLayout(
    bool isDark,
    AppLocalizations l10n,
    bool isMediumScreen,
  ) {
    return Padding(
      padding: const EdgeInsets.all(AlhaiSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              children: [
                _buildSearchBar(isDark, l10n),
                const SizedBox(height: AlhaiSpacing.md),
                Expanded(child: _buildOrdersList(isDark, l10n)),
              ],
            ),
          ),
          const SizedBox(width: AlhaiSpacing.lg),
          Expanded(flex: 2, child: _buildSelectedOrderPreview(isDark, l10n)),
        ],
      ),
    );
  }

  Widget _buildNarrowLayout(
    bool isDark,
    AppLocalizations l10n,
    bool isMediumScreen,
  ) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(
            isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md,
          ),
          child: _buildSearchBar(isDark, l10n),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isMediumScreen ? 24 : 16),
            child: _buildOrdersList(isDark, l10n),
          ),
        ),
        if (_selectedOrderId != null) _buildMobileReprintBar(isDark, l10n),
      ],
    );
  }

  Widget _buildSearchBar(bool isDark, AppLocalizations l10n) {
    return TextField(
      controller: _searchController,
      style: TextStyle(color: AppColors.getTextPrimary(isDark)),
      decoration: InputDecoration(
        hintText: l10n.searchByInvoiceOrCustomer,
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

  Widget _buildOrdersList(bool isDark, AppLocalizations l10n) {
    if (_filteredOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: AppColors.getTextMuted(isDark).withValues(alpha: 0.4),
            ),
            const SizedBox(height: AlhaiSpacing.md),
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
      );
    }

    return ListView.separated(
      itemCount: _filteredOrders.length,
      separatorBuilder: (_, __) => const SizedBox(height: AlhaiSpacing.xs),
      itemBuilder: (context, index) =>
          _buildOrderCard(_filteredOrders[index], isDark, l10n),
    );
  }

  Widget _buildOrderCard(
    SalesTableData order,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final isSelected = _selectedOrderId == order.id;
    final time =
        '${order.createdAt.hour.toString().padLeft(2, '0')}:${order.createdAt.minute.toString().padLeft(2, '0')}';
    final date =
        '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}';

    return InkWell(
      onTap: () => setState(() => _selectedOrderId = order.id),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AlhaiSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.08)
              : AppColors.getSurface(isDark),
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
            // Check indicator
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
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
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            // Receipt icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.receipt_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            // Order details
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
                  const SizedBox(height: AlhaiSpacing.xxs),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline_rounded,
                        size: 12,
                        color: AppColors.getTextMuted(isDark),
                      ),
                      const SizedBox(width: AlhaiSpacing.xxs),
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
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 12,
                        color: AppColors.getTextMuted(isDark),
                      ),
                      const SizedBox(width: AlhaiSpacing.xxs),
                      Text(
                        '$date $time',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.getTextMuted(isDark),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Amount
            Text(
              // C-4 Session 3: sales.total is int cents.
              '${(order.total / 100.0).toStringAsFixed(0)} ${l10n.sar}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.getTextPrimary(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedOrderPreview(bool isDark, AppLocalizations l10n) {
    if (_selectedOrderId == null) {
      return Container(
        padding: const EdgeInsets.all(AlhaiSpacing.xxxl),
        decoration: BoxDecoration(
          color: AppColors.getSurface(isDark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.getBorder(isDark)),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.print_outlined,
                size: 64,
                color: AppColors.getTextMuted(isDark).withValues(alpha: 0.4),
              ),
              const SizedBox(height: AlhaiSpacing.md),
              Text(
                l10n.selectInvoiceToPrint,
                textAlign: TextAlign.center,
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

    final order = _allOrders.firstWhere((o) => o.id == _selectedOrderId);

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Expanded(
                child: Text(
                  l10n.receiptPreview,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.mdl),
          // Order info
          _buildPreviewRow(
            l10n.invoiceNumber,
            '#${order.id.length > 8 ? order.id.substring(0, 8) : order.id}',
            isDark,
          ),
          _buildPreviewRow(
            l10n.customerName,
            order.customerId ?? l10n.cashCustomer,
            isDark,
          ),
          _buildPreviewRow(
            l10n.date,
            '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
            isDark,
          ),
          _buildPreviewRow(
            l10n.time,
            '${order.createdAt.hour.toString().padLeft(2, '0')}:${order.createdAt.minute.toString().padLeft(2, '0')}',
            isDark,
          ),
          _buildPreviewRow(l10n.paymentMethod, order.paymentMethod, isDark),
          Divider(height: 24, color: AppColors.getBorder(isDark)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xxs),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.totalAmountLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
                Text(
                  // C-4 Session 3: sales.total is int cents.
                  '${(order.total / 100.0).toStringAsFixed(2)} ${l10n.sar}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AlhaiSpacing.md),
          // ZATCA QR Code
          Center(
            child: ZatcaQrWidget(
              sellerName: _store?.name ?? 'Al-HAI Store',
              vatNumber: _store?.taxNumber,
              timestamp: order.createdAt,
              // C-4 Session 3: sale money columns are int cents; ZATCA
              // widget expects SAR doubles.
              totalWithVat: order.total / 100.0,
              vatAmount: order.tax / 100.0,
              size: 100,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.md),
          // Print button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isPrinting ? null : () => _printReceipt(order, l10n),
              icon: _isPrinting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.textOnPrimary,
                      ),
                    )
                  : const Icon(Icons.print_rounded, size: 20),
              label: Text(
                l10n.reprintReceipt,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileReprintBar(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
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
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _isPrinting
                ? null
                : () {
                    final order = _allOrders.firstWhere(
                      (o) => o.id == _selectedOrderId,
                    );
                    _printReceipt(order, l10n);
                  },
            icon: _isPrinting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.textOnPrimary,
                    ),
                  )
                : const Icon(Icons.print_rounded, size: 20),
            label: Text(
              l10n.reprintReceipt,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _printReceipt(
    SalesTableData order,
    AppLocalizations l10n,
  ) async {
    setState(() => _isPrinting = true);

    try {
      // Simulate printing delay
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;
      AlhaiSnackbar.success(context, l10n.receiptPrinted);
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Reprint receipt');
      if (!mounted) return;
      AlhaiSnackbar.error(context, l10n.errorWithDetails('$e'));
    } finally {
      if (mounted) setState(() => _isPrinting = false);
    }
  }
}
