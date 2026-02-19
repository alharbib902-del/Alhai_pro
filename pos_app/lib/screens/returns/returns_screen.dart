/// شاشة المرتجعات - Returns Screen
///
/// تعرض قائمة المرتجعات مع إحصائيات، فلاتر، جدول بيانات،
/// وإنشاء مرتجع جديد عبر drawer/bottom sheet wizard
/// متوافقة مع جميع الشاشات (desktop + tablet + mobile)
/// تدعم الوضع الفاتح والداكن
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/router/routes.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/layout/app_sidebar.dart';
import '../../widgets/returns/returns_stat_card.dart';
import '../../widgets/returns/returns_data_table.dart';
import '../../widgets/returns/create_return_drawer.dart';

// ============================================================================
// RETURN MODEL
// ============================================================================

/// نموذج بيانات المرتجع
class ReturnModel {
  final String id;
  final String invoiceNo;
  final String customer;
  final String? customerAvatar;
  final DateTime date;
  final double amount;
  final String status; // pending, refunded, rejected
  final String reason; // defective, wrong, customer_request, other
  final String type; // sales, purchase

  const ReturnModel({
    required this.id,
    required this.invoiceNo,
    required this.customer,
    this.customerAvatar,
    required this.date,
    required this.amount,
    required this.status,
    required this.reason,
    required this.type,
  });
}

// ============================================================================
// RETURNS SCREEN
// ============================================================================

class ReturnsScreen extends ConsumerStatefulWidget {
  const ReturnsScreen({super.key});

  @override
  ConsumerState<ReturnsScreen> createState() => _ReturnsScreenState();
}

class _ReturnsScreenState extends ConsumerState<ReturnsScreen> {
  bool _sidebarCollapsed = false;
  String _selectedNavId = 'returns';
  String _activeTab = 'sales'; // sales, purchase
  String _searchQuery = '';
  int _currentPage = 1;
  static const int _pageSize = 10;

  // Demo data
  final List<ReturnModel> _salesReturns = [
    ReturnModel(id: 'RET-24001', invoiceNo: 'INV-889', customer: 'أحمد محمد', customerAvatar: 'https://storage.googleapis.com/uxpilot-auth.appspot.com/avatars/avatar-3.jpg', date: DateTime(2024, 8, 15), amount: 150.00, status: 'pending', reason: 'defective', type: 'sales'),
    ReturnModel(id: 'RET-24002', invoiceNo: 'INV-902', customer: 'سارة علي', customerAvatar: 'https://storage.googleapis.com/uxpilot-auth.appspot.com/avatars/avatar-5.jpg', date: DateTime(2024, 8, 14), amount: 45.50, status: 'refunded', reason: 'customer_request', type: 'sales'),
    ReturnModel(id: 'RET-24003', invoiceNo: 'INV-915', customer: 'محمد العلي', date: DateTime(2024, 8, 13), amount: 320.00, status: 'rejected', reason: 'wrong', type: 'sales'),
    ReturnModel(id: 'RET-24004', invoiceNo: 'INV-920', customer: 'فاطمة حسن', customerAvatar: 'https://storage.googleapis.com/uxpilot-auth.appspot.com/avatars/avatar-1.jpg', date: DateTime(2024, 8, 12), amount: 85.00, status: 'refunded', reason: 'defective', type: 'sales'),
    ReturnModel(id: 'RET-24005', invoiceNo: 'INV-935', customer: 'عبدالله سعد', date: DateTime(2024, 8, 11), amount: 210.00, status: 'pending', reason: 'customer_request', type: 'sales'),
    ReturnModel(id: 'RET-24006', invoiceNo: 'INV-940', customer: 'نورة خالد', customerAvatar: 'https://storage.googleapis.com/uxpilot-auth.appspot.com/avatars/avatar-2.jpg', date: DateTime(2024, 8, 10), amount: 125.00, status: 'refunded', reason: 'wrong', type: 'sales'),
    ReturnModel(id: 'RET-24007', invoiceNo: 'INV-948', customer: 'خالد يوسف', date: DateTime(2024, 8, 9), amount: 95.50, status: 'refunded', reason: 'defective', type: 'sales'),
    ReturnModel(id: 'RET-24008', invoiceNo: 'INV-955', customer: 'ريم عبدالرحمن', date: DateTime(2024, 8, 8), amount: 180.00, status: 'pending', reason: 'other', type: 'sales'),
  ];

  final List<ReturnModel> _purchaseReturns = [
    ReturnModel(id: 'PRET-24001', invoiceNo: 'PO-050', customer: 'شركة التوريدات', date: DateTime(2024, 8, 12), amount: 1500.00, status: 'refunded', reason: 'defective', type: 'purchase'),
    ReturnModel(id: 'PRET-24002', invoiceNo: 'PO-055', customer: 'مصنع الألبان', date: DateTime(2024, 8, 10), amount: 800.00, status: 'pending', reason: 'wrong', type: 'purchase'),
  ];

  List<ReturnModel> get _currentReturns => _activeTab == 'sales' ? _salesReturns : _purchaseReturns;

  List<ReturnModel> get _filteredReturns {
    var list = _currentReturns;
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((r) => r.id.toLowerCase().contains(q) || r.customer.toLowerCase().contains(q) || r.invoiceNo.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  int get _totalPages => (_filteredReturns.length / _pageSize).ceil().clamp(1, 999);

  List<ReturnModel> get _paginatedReturns {
    final start = (_currentPage - 1) * _pageSize;
    final end = (start + _pageSize).clamp(0, _filteredReturns.length);
    return _filteredReturns.sublist(start, end);
  }

  double get _totalRefundedAmount {
    return _currentReturns.where((r) => r.status == 'refunded').fold(0.0, (sum, r) => sum + r.amount);
  }

  // ============================================================================
  // NAVIGATION
  // ============================================================================

  void _handleNavigation(AppSidebarItem item) {
    setState(() => _selectedNavId = item.id);
    switch (item.id) {
      case 'dashboard':
        context.go(AppRoutes.dashboard);
      case 'pos':
        context.go(AppRoutes.pos);
      case 'products':
        context.push(AppRoutes.products);
      case 'inventory':
        context.push(AppRoutes.inventory);
      case 'customers':
        context.push(AppRoutes.customers);
      case 'sales':
        context.push(AppRoutes.invoices);
      case 'returns':
        break; // already here
      case 'reports':
        context.push(AppRoutes.reports);
      case 'suppliers':
        context.push(AppRoutes.suppliers);
    }
  }

  // ============================================================================
  // ACTIONS
  // ============================================================================

  void _copyReturnId(String id) {
    Clipboard.setData(ClipboardData(text: id));
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(l10n.returnCopied),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openCreateReturn() {
    final isWide = MediaQuery.of(context).size.width > 900;
    if (isWide) {
      // Desktop: Side drawer
      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: 'Close',
        barrierColor: Colors.black54,
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) {
          return Align(
            alignment: AlignmentDirectional.centerStart,
            child: Material(
              color: Colors.transparent,
              child: CreateReturnDrawer(
                onSuccess: () {
                  Navigator.of(context).pop();
                  _showSuccessToast();
                },
              ),
            ),
          );
        },
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          final isRtl = Directionality.of(context) == TextDirection.rtl;
          return SlideTransition(
            position: Tween<Offset>(
              begin: Offset(isRtl ? 1.0 : -1.0, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          );
        },
      );
    } else {
      // Mobile: Bottom sheet
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.92,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) => CreateReturnDrawer(
            scrollController: scrollController,
            onSuccess: () {
              Navigator.of(context).pop();
              _showSuccessToast();
            },
          ),
        ),
      );
    }
  }

  void _showSuccessToast() {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(l10n.returnCreatedSuccess, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ============================================================================
  // BUILD
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isMediumScreen = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : AppColors.backgroundSecondary,
      drawer: isWideScreen ? null : _buildDrawer(l10n),
      floatingActionButton: !isWideScreen
          ? FloatingActionButton(
              onPressed: _openCreateReturn,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            )
          : null,
      body: Row(
        children: [
          if (isWideScreen)
            AppSidebar(
              storeName: l10n.brandName,
              groups: _getSidebarGroups(l10n),
              selectedId: _selectedNavId,
              onItemTap: _handleNavigation,
              onSettingsTap: () => context.push(AppRoutes.settings),
              onSupportTap: () {},
              onLogoutTap: () => context.go('/login'),
              collapsed: _sidebarCollapsed,
              userName: 'كريم محمود',
              userRole: l10n.branchManager,
              onUserTap: () {},
            ),
          Expanded(
            child: Column(
              children: [
                _buildHeader(context, isWideScreen, isDark, l10n),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
                    child: Column(
                      children: [
                        // Tabs
                        _buildTabs(l10n, isDark),
                        SizedBox(height: isMediumScreen ? 24 : 16),
                        // Stats
                        _buildStatsSection(l10n, isDark, isWideScreen, isMediumScreen),
                        SizedBox(height: isMediumScreen ? 24 : 16),
                        // Data Table
                        _buildTableSection(l10n, isDark, isWideScreen, isMediumScreen),
                        const SizedBox(height: 24),
                        _buildFooter(l10n, isDark),
                      ],
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

  // ============================================================================
  // SIDEBAR GROUPS (with returns item)
  // ============================================================================

  List<SidebarGroup> _getSidebarGroups(AppLocalizations l10n) {
    return [
      SidebarGroup(
        items: [
          AppSidebarItem(id: 'dashboard', title: l10n.dashboard, icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard_rounded),
          AppSidebarItem(id: 'pos', title: l10n.pos, icon: Icons.point_of_sale_outlined, activeIcon: Icons.point_of_sale_rounded),
        ],
      ),
      SidebarGroup(
        title: l10n.storeManagement,
        items: [
          AppSidebarItem(id: 'products', title: l10n.products, icon: Icons.inventory_2_outlined, activeIcon: Icons.inventory_2_rounded),
          AppSidebarItem(id: 'inventory', title: l10n.inventory, icon: Icons.warehouse_outlined, activeIcon: Icons.warehouse_rounded),
          AppSidebarItem(id: 'customers', title: l10n.customers, icon: Icons.people_outline_rounded, activeIcon: Icons.people_rounded),
          AppSidebarItem(id: 'suppliers', title: l10n.supplier, icon: Icons.local_shipping_outlined, activeIcon: Icons.local_shipping_rounded),
        ],
      ),
      SidebarGroup(
        title: l10n.finance,
        items: [
          AppSidebarItem(id: 'sales', title: l10n.invoices, icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long_rounded),
          AppSidebarItem(id: 'returns', title: l10n.returns, icon: Icons.assignment_return_outlined, activeIcon: Icons.assignment_return_rounded),
          AppSidebarItem(id: 'reports', title: l10n.reports, icon: Icons.analytics_outlined, activeIcon: Icons.analytics_rounded),
        ],
      ),
    ];
  }

  // ============================================================================
  // HEADER
  // ============================================================================

  Widget _buildHeader(BuildContext context, bool isWideScreen, bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        border: Border(bottom: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border)),
      ),
      child: Row(
        children: [
          // Menu button
          IconButton(
            onPressed: isWideScreen
                ? () => setState(() => _sidebarCollapsed = !_sidebarCollapsed)
                : () => Scaffold.of(context).openDrawer(),
            icon: Icon(Icons.menu_rounded, color: isDark ? AppColors.textMutedDark : AppColors.textSecondary),
          ),
          const SizedBox(width: 8),
          Text(
            l10n.returns,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary),
          ),

          if (isWideScreen) ...[
            Container(height: 28, width: 1, margin: const EdgeInsets.symmetric(horizontal: 16), color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
            // New return button
            FilledButton.icon(
              onPressed: _openCreateReturn,
              icon: const Icon(Icons.add, size: 18),
              label: Text(l10n.newReturn),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],

          const Spacer(),

          // Search
          if (isWideScreen)
            SizedBox(
              width: 280,
              child: TextField(
                onChanged: (v) => setState(() {
                  _searchQuery = v;
                  _currentPage = 1;
                }),
                decoration: InputDecoration(
                  hintText: l10n.quickSearch,
                  hintStyle: TextStyle(color: isDark ? AppColors.textMutedDark : AppColors.textMuted, fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: isDark ? AppColors.textMutedDark : AppColors.textMuted),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF0F172A) : AppColors.backgroundSecondary,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.5))),
                ),
                style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary, fontSize: 14),
              ),
            ),
          const SizedBox(width: 8),
          // Notifications
          IconButton(
            onPressed: () {},
            icon: Badge(
              smallSize: 8,
              backgroundColor: AppColors.secondary,
              child: Icon(Icons.notifications_outlined, color: isDark ? AppColors.textMutedDark : AppColors.textSecondary),
            ),
          ),
          // Dark mode toggle
          IconButton(
            onPressed: () {},
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: isDark ? const Color(0xFFFBBF24) : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // TABS
  // ============================================================================

  Widget _buildTabs(AppLocalizations l10n, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : AppColors.grey200,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              _buildTabButton(l10n.salesReturns, 'sales', isDark),
              _buildTabButton(l10n.purchaseReturns, 'purchase', isDark),
            ],
          ),
        ),
        const Spacer(),
        // Mobile search button
        if (MediaQuery.of(context).size.width <= 900)
          IconButton(
            onPressed: () {
              // Show search bottom sheet
              _showMobileSearch(l10n, isDark);
            },
            icon: Icon(Icons.search, color: isDark ? AppColors.textMutedDark : AppColors.textSecondary),
          ),
      ],
    );
  }

  Widget _buildTabButton(String label, String tab, bool isDark) {
    final isActive = _activeTab == tab;
    return GestureDetector(
      onTap: () => setState(() {
        _activeTab = tab;
        _currentPage = 1;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? (isDark ? const Color(0xFF374151) : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isActive ? AppSizes.shadowSm : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive
                ? (isDark ? Colors.white : AppColors.textPrimary)
                : (isDark ? AppColors.textMutedDark : AppColors.textSecondary),
          ),
        ),
      ),
    );
  }

  void _showMobileSearch(AppLocalizations l10n, bool isDark) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 16, right: 16, top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.grey300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            TextField(
              autofocus: true,
              onChanged: (v) => setState(() {
                _searchQuery = v;
                _currentPage = 1;
              }),
              decoration: InputDecoration(
                hintText: l10n.quickSearch,
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: isDark ? const Color(0xFF374151) : AppColors.backgroundSecondary,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // STATS SECTION
  // ============================================================================

  Widget _buildStatsSection(AppLocalizations l10n, bool isDark, bool isWideScreen, bool isMediumScreen) {
    final totalCount = _currentReturns.length;
    final totalAmount = _totalRefundedAmount;
    final processedPercent = totalCount > 0
        ? ((_currentReturns.where((r) => r.status == 'refunded').length / totalCount) * 100).round()
        : 0;

    // Most returned product (demo data)
    const mostReturnedProduct = 'حليب كامل الدسم';
    const mostReturnedSku = 'SKU: 882910';

    final stats = <ReturnsStatData>[
      ReturnsStatData(
        title: l10n.totalReturns,
        value: '$totalCount',
        icon: Icons.assignment_return_rounded,
        iconBgColor: AppColors.info.withValues(alpha: 0.1),
        iconColor: AppColors.info,
        changeLabel: '12% ${l10n.comparedToLastMonth}',
        changeIcon: Icons.arrow_downward,
        changeColor: AppColors.success,
      ),
      ReturnsStatData(
        title: l10n.totalRefundedAmount,
        value: '${totalAmount.toStringAsFixed(0)} ${l10n.sar}',
        icon: Icons.payments_rounded,
        iconBgColor: AppColors.primary.withValues(alpha: 0.1),
        iconColor: AppColors.primary,
        badgeText: l10n.processed,
        badgeColor: AppColors.success,
        subtitle: l10n.ofTotalProcessed(processedPercent),
      ),
      ReturnsStatData(
        title: l10n.mostReturned,
        value: mostReturnedProduct,
        icon: Icons.inventory_2_rounded,
        iconBgColor: AppColors.secondary.withValues(alpha: 0.1),
        iconColor: AppColors.secondary,
        subtitle: mostReturnedSku,
        progressValue: 0.75,
        progressColor: AppColors.secondary,
        footerText: l10n.timesReturned(8, 75),
      ),
    ];

    if (isWideScreen) {
      return Row(
        children: stats.map((s) => Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: ReturnsStatCard(data: s),
          ),
        )).toList(),
      );
    }

    // Mobile/Tablet: stacked
    return Column(
      children: stats.map((s) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: ReturnsStatCard(data: s, compact: !isMediumScreen),
      )).toList(),
    );
  }

  // ============================================================================
  // TABLE SECTION
  // ============================================================================

  Widget _buildTableSection(AppLocalizations l10n, bool isDark, bool isWideScreen, bool isMediumScreen) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.border),
      ),
      child: Column(
        children: [
          // Toolbar
          _buildTableToolbar(l10n, isDark, isWideScreen),
          // Data
          if (isMediumScreen)
            ReturnsDataTable(
              returns: _paginatedReturns,
              onCopyId: _copyReturnId,
              onView: (r) {},
              onApprove: (r) {
                setState(() {
                  final index = _currentReturns.indexWhere((e) => e.id == r.id);
                  if (index != -1) {
                    final list = _activeTab == 'sales' ? _salesReturns : _purchaseReturns;
                    list[index] = ReturnModel(
                      id: r.id, invoiceNo: r.invoiceNo, customer: r.customer,
                      customerAvatar: r.customerAvatar, date: r.date, amount: r.amount,
                      status: 'refunded', reason: r.reason, type: r.type,
                    );
                  }
                });
              },
              onReject: (r) {
                setState(() {
                  final index = _currentReturns.indexWhere((e) => e.id == r.id);
                  if (index != -1) {
                    final list = _activeTab == 'sales' ? _salesReturns : _purchaseReturns;
                    list[index] = ReturnModel(
                      id: r.id, invoiceNo: r.invoiceNo, customer: r.customer,
                      customerAvatar: r.customerAvatar, date: r.date, amount: r.amount,
                      status: 'rejected', reason: r.reason, type: r.type,
                    );
                  }
                });
              },
            )
          else
            _buildMobileCards(l10n, isDark),
          // Pagination
          _buildPagination(l10n, isDark),
        ],
      ),
    );
  }

  Widget _buildTableToolbar(AppLocalizations l10n, bool isDark, bool isWideScreen) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.divider)),
      ),
      child: Row(
        children: [
          // Quick search (inside table)
          Expanded(
            child: SizedBox(
              height: 40,
              child: TextField(
                onChanged: (v) => setState(() {
                  _searchQuery = v;
                  _currentPage = 1;
                }),
                decoration: InputDecoration(
                  hintText: l10n.quickSearch,
                  hintStyle: TextStyle(color: isDark ? AppColors.textMutedDark : AppColors.textMuted, fontSize: 13),
                  prefixIcon: Icon(Icons.search, size: 18, color: isDark ? AppColors.textMutedDark : AppColors.textMuted),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF0F172A) : AppColors.grey50,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.5))),
                ),
                style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary, fontSize: 13),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Export & Print
          _buildToolbarButton(Icons.download_outlined, l10n.exportData, isDark),
          const SizedBox(width: 4),
          _buildToolbarButton(Icons.print_outlined, l10n.printData, isDark),
        ],
      ),
    );
  }

  Widget _buildToolbarButton(IconData icon, String tooltip, bool isDark) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: isDark ? AppColors.textMutedDark : AppColors.textSecondary),
        ),
      ),
    );
  }

  // ============================================================================
  // MOBILE CARDS
  // ============================================================================

  Widget _buildMobileCards(AppLocalizations l10n, bool isDark) {
    if (_paginatedReturns.isEmpty) {
      return _buildEmptyState(l10n, isDark);
    }

    return Column(
      children: _paginatedReturns.map((r) => _buildMobileReturnCard(r, l10n, isDark)).toList(),
    );
  }

  Widget _buildMobileReturnCard(ReturnModel ret, AppLocalizations l10n, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.border),
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _activeTab == 'sales' ? l10n.salesReturns : l10n.purchaseReturns,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 8),
              Text('#${ret.id}', style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMutedDark : AppColors.textMuted)),
              const Spacer(),
              _buildStatusBadge(ret.status, l10n, isDark),
            ],
          ),
          const SizedBox(height: 12),
          // Customer & Amount
          Row(
            children: [
              // Avatar
              _buildAvatar(ret, isDark),
              const SizedBox(width: 10),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ret.customer, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
                    Text('${l10n.fromInvoice} #${ret.invoiceNo}', style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMutedDark : AppColors.textMuted)),
                  ],
                ),
              ),
              // Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${ret.amount.toStringAsFixed(2)} ${l10n.sar}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
                  Text(_formatDate(ret.date), style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMutedDark : AppColors.textMuted)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Footer
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(border: Border(top: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.divider))),
            child: Row(
              children: [
                _buildReasonIcon(ret.reason, isDark),
                const SizedBox(width: 6),
                Text(_getReasonText(ret.reason, l10n), style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMutedDark : AppColors.textMuted)),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  child: Text(l10n.viewDetails, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // PAGINATION
  // ============================================================================

  Widget _buildPagination(AppLocalizations l10n, bool isDark) {
    final total = _filteredReturns.length;
    final from = total == 0 ? 0 : ((_currentPage - 1) * _pageSize + 1);
    final to = (_currentPage * _pageSize).clamp(0, total);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.divider)),
      ),
      child: Row(
        children: [
          Text(
            l10n.showingResults(from, to, total),
            style: TextStyle(fontSize: 12, color: isDark ? AppColors.textMutedDark : AppColors.textMuted),
          ),
          const Spacer(),
          // Page buttons
          _buildPageButton(l10n.previous, isDark, enabled: _currentPage > 1, onTap: () => setState(() => _currentPage--)),
          const SizedBox(width: 4),
          for (int i = 1; i <= _totalPages; i++) ...[
            _buildPageNumberButton(i, isDark),
            if (i < _totalPages) const SizedBox(width: 4),
          ],
          const SizedBox(width: 4),
          _buildPageButton(l10n.next, isDark, enabled: _currentPage < _totalPages, onTap: () => setState(() => _currentPage++)),
        ],
      ),
    );
  }

  Widget _buildPageButton(String label, bool isDark, {required bool enabled, VoidCallback? onTap}) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: enabled
                ? (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)
                : (isDark ? AppColors.textMutedDark : AppColors.textMuted).withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildPageNumberButton(int page, bool isDark) {
    final isActive = page == _currentPage;
    return InkWell(
      onTap: () => setState(() => _currentPage = page),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32, height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isActive ? null : Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
        ),
        child: Text(
          '$page',
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? Colors.white : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // EMPTY STATE
  // ============================================================================

  Widget _buildEmptyState(AppLocalizations l10n, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? const Color(0xFF374151) : AppColors.grey100,
            ),
            child: Icon(Icons.inventory_2_outlined, size: 40, color: isDark ? AppColors.textMutedDark : AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          Text(l10n.noReturns, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text(l10n.noReturnsDesc, style: TextStyle(fontSize: 13, color: isDark ? AppColors.textMutedDark : AppColors.textMuted)),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _openCreateReturn,
            icon: const Icon(Icons.add, size: 18),
            label: Text(l10n.createNewReturn),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // HELPERS
  // ============================================================================

  Widget _buildStatusBadge(String status, AppLocalizations l10n, bool isDark) {
    Color bgColor;
    Color textColor;
    Color borderColor;
    String label;
    IconData? icon;

    switch (status) {
      case 'pending':
        bgColor = isDark ? AppColors.warning.withValues(alpha: 0.15) : const Color(0xFFFEF3C7);
        textColor = isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309);
        borderColor = isDark ? AppColors.warning.withValues(alpha: 0.3) : const Color(0xFFFDE68A);
        label = l10n.pending;
        icon = Icons.access_time;
      case 'refunded':
        bgColor = isDark ? AppColors.success.withValues(alpha: 0.15) : const Color(0xFFDCFCE7);
        textColor = isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D);
        borderColor = isDark ? AppColors.success.withValues(alpha: 0.3) : const Color(0xFFBBF7D0);
        label = l10n.returnRefunded;
        icon = Icons.check_circle;
      case 'rejected':
        bgColor = isDark ? AppColors.error.withValues(alpha: 0.15) : const Color(0xFFFEE2E2);
        textColor = isDark ? const Color(0xFFF87171) : const Color(0xFFB91C1C);
        borderColor = isDark ? AppColors.error.withValues(alpha: 0.3) : const Color(0xFFFECACA);
        label = l10n.returnRejected;
        icon = Icons.block;
      default:
        bgColor = AppColors.grey100;
        textColor = AppColors.textSecondary;
        borderColor = AppColors.border;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor)),
        ],
      ),
    );
  }

  Widget _buildAvatar(ReturnModel ret, bool isDark) {
    if (ret.customerAvatar != null) {
      return CircleAvatar(
        radius: 18,
        backgroundImage: NetworkImage(ret.customerAvatar!),
        backgroundColor: isDark ? const Color(0xFF374151) : AppColors.grey100,
      );
    }
    // Initial letter avatar
    final initial = ret.customer.isNotEmpty ? ret.customer[0] : '?';
    return CircleAvatar(
      radius: 18,
      backgroundColor: isDark ? const Color(0xFF374151) : AppColors.grey200,
      child: Text(initial, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? AppColors.textMutedDark : AppColors.textSecondary)),
    );
  }

  Widget _buildReasonIcon(String reason, bool isDark) {
    IconData icon;
    Color color;
    switch (reason) {
      case 'defective':
        icon = Icons.broken_image_outlined;
        color = AppColors.error;
      case 'wrong':
        icon = Icons.warning_amber;
        color = AppColors.warning;
      case 'customer_request':
        icon = Icons.assignment_return;
        color = AppColors.info;
      default:
        icon = Icons.edit_note;
        color = AppColors.textMuted;
    }
    return Icon(icon, size: 14, color: color);
  }

  String _getReasonText(String reason, AppLocalizations l10n) {
    switch (reason) {
      case 'defective':
        return l10n.defectiveProduct;
      case 'wrong':
        return l10n.wrongProduct;
      case 'customer_request':
        return l10n.customerRequest;
      default:
        return l10n.otherReason;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  // ============================================================================
  // FOOTER
  // ============================================================================

  Widget _buildFooter(AppLocalizations l10n, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Column(
        children: [
          Divider(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
          const SizedBox(height: 12),
          Text(l10n.allRightsReservedFooter, style: TextStyle(fontSize: 12, color: isDark ? AppColors.textMutedDark : AppColors.textMuted)),
        ],
      ),
    );
  }

  // ============================================================================
  // DRAWER (mobile)
  // ============================================================================

  Widget _buildDrawer(AppLocalizations l10n) {
    return Drawer(
      child: AppSidebar(
        storeName: l10n.brandName,
        groups: _getSidebarGroups(l10n),
        selectedId: _selectedNavId,
        onItemTap: (item) {
          Navigator.pop(context);
          _handleNavigation(item);
        },
        onSettingsTap: () {
          Navigator.pop(context);
          context.push(AppRoutes.settings);
        },
        onSupportTap: () => Navigator.pop(context),
        onLogoutTap: () {
          Navigator.pop(context);
          context.go('/login');
        },
        userName: 'كريم محمود',
        userRole: l10n.branchManager,
        onUserTap: () => Navigator.pop(context),
      ),
    );
  }
}
