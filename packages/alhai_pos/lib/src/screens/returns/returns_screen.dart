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
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../providers/returns_providers.dart';
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

  /// تحويل من بيانات قاعدة البيانات
  factory ReturnModel.fromData(ReturnsTableData data) {
    return ReturnModel(
      id: data.returnNumber,
      invoiceNo: data.saleId,
      customer: data.customerName ?? '',
      date: data.createdAt,
      amount: data.totalRefund,
      status: data.status,
      reason: data.reason ?? 'other',
      type: data.type,
    );
  }
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
  String _activeTab = 'sales'; // sales, purchase
  String _searchQuery = '';
  int _currentPage = 1;
  static const int _pageSize = 10;

  List<ReturnModel> _filterReturns(List<ReturnModel> allReturns) {
    var list = allReturns
        .where((r) => r.type == (_activeTab == 'sales' ? 'sales' : 'purchase'))
        .toList();
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where(
            (r) =>
                r.id.toLowerCase().contains(q) ||
                r.customer.toLowerCase().contains(q) ||
                r.invoiceNo.toLowerCase().contains(q),
          )
          .toList();
    }
    return list;
  }

  List<ReturnModel> _paginateReturns(List<ReturnModel> filtered) {
    final start = (_currentPage - 1) * _pageSize;
    final end = (start + _pageSize).clamp(0, filtered.length);
    if (start >= filtered.length) return [];
    return filtered.sublist(start, end);
  }

  // ============================================================================
  // NAVIGATION
  // ============================================================================
  // ============================================================================
  // ACTIONS
  // ============================================================================

  void _copyReturnId(String id) {
    Clipboard.setData(ClipboardData(text: id));
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: colorScheme.onPrimary, size: 18),
            const SizedBox(width: AlhaiSpacing.xs),
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
    final isWide = context.isDesktop;
    if (isWide) {
      // Desktop: Side drawer
      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: 'Close',
        barrierColor: Colors.black54,
        transitionDuration: AlhaiDurations.slow,
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
            position:
                Tween<Offset>(
                  begin: Offset(isRtl ? 1.0 : -1.0, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: AlhaiMotion.standardDecelerate,
                  ),
                ),
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
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: colorScheme.onPrimary, size: 20),
            const SizedBox(width: AlhaiSpacing.xs),
            Text(
              l10n.returnCreatedSuccess,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
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
    final isWideScreen = context.isDesktop;
    final isMediumScreen = !context.isMobile;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      floatingActionButton: !isWideScreen
          ? FloatingActionButton(
              onPressed: _openCreateReturn,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.add, color: colorScheme.onPrimary, size: 28),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isWideScreen, isDark, l10n),
            Expanded(
              child: ref
                  .watch(returnsListProvider)
                  .when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => AppErrorState.general(
                      context,
                      message: e.toString(),
                      onRetry: () => ref.invalidate(returnsListProvider),
                    ),
                    data: (returnsData) {
                      final allReturns = returnsData
                          .map((r) => ReturnModel.fromData(r))
                          .toList();
                      final filteredReturns = _filterReturns(allReturns);
                      return SingleChildScrollView(
                        padding: EdgeInsets.all(
                          isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md,
                        ),
                        child: Column(
                          children: [
                            // Tabs
                            _buildTabs(l10n, isDark),
                            SizedBox(
                              height: isMediumScreen
                                  ? AlhaiSpacing.lg
                                  : AlhaiSpacing.md,
                            ),
                            // Stats
                            _buildStatsSection(
                              filteredReturns,
                              l10n,
                              isDark,
                              isWideScreen,
                              isMediumScreen,
                            ),
                            SizedBox(
                              height: isMediumScreen
                                  ? AlhaiSpacing.lg
                                  : AlhaiSpacing.md,
                            ),
                            // Data Table
                            _buildTableSection(
                              filteredReturns,
                              l10n,
                              isDark,
                              isWideScreen,
                              isMediumScreen,
                            ),
                            const SizedBox(height: AlhaiSpacing.lg),
                            _buildFooter(l10n, isDark),
                          ],
                        ),
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // HEADER
  // ============================================================================

  Widget _buildHeader(
    BuildContext context,
    bool isWideScreen,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AlhaiSpacing.lg,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          // Menu button
          IconButton(
            onPressed: isWideScreen
                ? null
                : () => Scaffold.of(context).openDrawer(),
            icon: Icon(
              Icons.menu_rounded,
              color: isDark ? AppColors.textMutedDark : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: AlhaiSpacing.xs),
          Text(
            l10n.returns,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),

          if (isWideScreen) ...[
            Container(
              height: 28,
              width: 1,
              margin: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.md),
              color: Theme.of(context).dividerColor,
            ),
            // New return button
            FilledButton.icon(
              onPressed: _openCreateReturn,
              icon: const Icon(Icons.add, size: 18),
              label: Text(l10n.newReturn),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: AlhaiSpacing.mdl,
                  vertical: AlhaiSpacing.sm,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
                  hintStyle: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.backgroundDark
                      : AppColors.backgroundSecondary,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AlhaiSpacing.md,
                    vertical: AlhaiSpacing.sm,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                style: TextStyle(color: colorScheme.onSurface, fontSize: 14),
              ),
            ),
          const SizedBox(width: AlhaiSpacing.xs),
          // Notifications
          IconButton(
            onPressed: () {},
            icon: Badge(
              smallSize: 8,
              backgroundColor: AppColors.secondary,
              child: Icon(
                Icons.notifications_outlined,
                color: isDark
                    ? AppColors.textMutedDark
                    : AppColors.textSecondary,
              ),
            ),
          ),
          // Dark mode toggle
          IconButton(
            onPressed: () {},
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: isDark ? AppColors.warning : AppColors.textSecondary,
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
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AlhaiSpacing.xxs),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
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
        if (!context.isDesktop)
          IconButton(
            onPressed: () {
              // Show search bottom sheet
              _showMobileSearch(l10n, isDark);
            },
            icon: Icon(
              Icons.search,
              color: isDark ? AppColors.textMutedDark : AppColors.textSecondary,
            ),
          ),
      ],
    );
  }

  Widget _buildTabButton(String label, String tab, bool isDark) {
    final isActive = _activeTab == tab;
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => setState(() {
        _activeTab = tab;
        _currentPage = 1;
      }),
      child: AnimatedContainer(
        duration: AlhaiDurations.standard,
        padding: const EdgeInsets.symmetric(
          horizontal: AlhaiSpacing.mdl,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isActive ? colorScheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isActive ? AppSizes.shadowSm : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive
                ? colorScheme.onSurface
                : colorScheme.onSurfaceVariant,
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
        padding: EdgeInsetsDirectional.only(
          start: 16,
          end: 16,
          top: 16,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AlhaiSpacing.md),
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
                fillColor: isDark
                    ? AppColors.surfaceVariantDark
                    : AppColors.backgroundSecondary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: AlhaiSpacing.md),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // STATS SECTION
  // ============================================================================

  Widget _buildStatsSection(
    List<ReturnModel> currentReturns,
    AppLocalizations l10n,
    bool isDark,
    bool isWideScreen,
    bool isMediumScreen,
  ) {
    final totalCount = currentReturns.length;
    final totalAmount = currentReturns.fold<double>(
      0.0,
      (sum, r) => sum + r.amount,
    );
    final processedPercent = totalCount > 0
        ? ((currentReturns
                          .where(
                            (r) =>
                                r.status == 'refunded' ||
                                r.status == 'completed',
                          )
                          .length /
                      totalCount) *
                  100)
              .round()
        : 0;

    // Most returned product (calculated from current returns)
    String mostReturnedProduct = '-';
    const mostReturnedSku = '';
    if (currentReturns.isNotEmpty) {
      final counts = <String, int>{};
      for (final r in currentReturns) {
        final key = r.invoiceNo.isNotEmpty
            ? r.invoiceNo
            : AppLocalizations.of(context).notSpecified;
        counts[key] = (counts[key] ?? 0) + 1;
      }
      if (counts.isNotEmpty) {
        mostReturnedProduct = counts.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key;
      }
    }

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
        children: stats
            .map(
              (s) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: ReturnsStatCard(data: s),
                ),
              ),
            )
            .toList(),
      );
    }

    // Mobile/Tablet: stacked
    return Column(
      children: stats
          .map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: AlhaiSpacing.sm),
              child: ReturnsStatCard(data: s, compact: !isMediumScreen),
            ),
          )
          .toList(),
    );
  }

  // ============================================================================
  // TABLE SECTION
  // ============================================================================

  Widget _buildTableSection(
    List<ReturnModel> filtered,
    AppLocalizations l10n,
    bool isDark,
    bool isWideScreen,
    bool isMediumScreen,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final paginated = _paginateReturns(filtered);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          // Toolbar
          _buildTableToolbar(l10n, isDark, isWideScreen),
          // Data
          if (isMediumScreen)
            ReturnsDataTable(
              returns: paginated,
              onCopyId: _copyReturnId,
              onView: (r) {},
              onApprove: (r) {},
              onReject: (r) {},
            )
          else
            _buildMobileCards(paginated, l10n, isDark),
          // Pagination
          _buildPagination(filtered.length, l10n, isDark),
        ],
      ),
    );
  }

  Widget _buildTableToolbar(
    AppLocalizations l10n,
    bool isDark,
    bool isWideScreen,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : AppColors.divider,
          ),
        ),
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
                  hintStyle: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    size: 18,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.backgroundDark
                      : AppColors.grey50,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AlhaiSpacing.sm,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                style: TextStyle(color: colorScheme.onSurface, fontSize: 13),
              ),
            ),
          ),
          const SizedBox(width: AlhaiSpacing.xs),
          // Export & Print
          _buildToolbarButton(Icons.download_outlined, l10n.exportData, isDark),
          const SizedBox(width: AlhaiSpacing.xxs),
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
          width: 36,
          height: 36,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          child: Icon(
            icon,
            size: 18,
            color: isDark ? AppColors.textMutedDark : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // MOBILE CARDS
  // ============================================================================

  Widget _buildMobileCards(
    List<ReturnModel> paginated,
    AppLocalizations l10n,
    bool isDark,
  ) {
    if (paginated.isEmpty) {
      return _buildEmptyState(l10n, isDark);
    }

    return Column(
      children: paginated
          .map((r) => _buildMobileReturnCard(r, l10n, isDark))
          .toList(),
    );
  }

  Widget _buildMobileReturnCard(
    ReturnModel ret,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AlhaiSpacing.sm,
        vertical: AlhaiSpacing.xxs,
      ),
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AlhaiSpacing.xs,
                  vertical: AlhaiSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _activeTab == 'sales'
                      ? l10n.salesReturns
                      : l10n.purchaseReturns,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: AlhaiSpacing.xs),
              Text(
                '#${ret.id}',
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              _buildStatusBadge(ret.status, l10n, isDark),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.sm),
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
                    Text(
                      ret.customer,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      '${l10n.fromInvoice} #${ret.invoiceNo}',
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurfaceVariant,
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
                    '${ret.amount.toStringAsFixed(2)} ${l10n.sar}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    _formatDate(ret.date),
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.sm),
          // Footer
          Container(
            padding: const EdgeInsets.only(top: AlhaiSpacing.sm),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : AppColors.divider,
                ),
              ),
            ),
            child: Row(
              children: [
                _buildReasonIcon(ret.reason, isDark),
                const SizedBox(width: 6),
                Text(
                  _getReasonText(ret.reason, l10n),
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    l10n.viewDetails,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
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
  // PAGINATION
  // ============================================================================

  Widget _buildPagination(int total, AppLocalizations l10n, bool isDark) {
    final colorScheme = Theme.of(context).colorScheme;
    final totalPages = (total / _pageSize).ceil().clamp(1, 999);
    final from = total == 0 ? 0 : ((_currentPage - 1) * _pageSize + 1);
    final to = (_currentPage * _pageSize).clamp(0, total);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AlhaiSpacing.md,
        vertical: AlhaiSpacing.sm,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : AppColors.divider,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            l10n.showingResults(from, to, total),
            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
          ),
          const Spacer(),
          // Page buttons
          _buildPageButton(
            l10n.previous,
            isDark,
            enabled: _currentPage > 1,
            onTap: () => setState(() => _currentPage--),
          ),
          const SizedBox(width: AlhaiSpacing.xxs),
          for (int i = 1; i <= totalPages; i++) ...[
            _buildPageNumberButton(i, isDark),
            if (i < totalPages) const SizedBox(width: AlhaiSpacing.xxs),
          ],
          const SizedBox(width: AlhaiSpacing.xxs),
          _buildPageButton(
            l10n.next,
            isDark,
            enabled: _currentPage < totalPages,
            onTap: () => setState(() => _currentPage++),
          ),
        ],
      ),
    );
  }

  Widget _buildPageButton(
    String label,
    bool isDark, {
    required bool enabled,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AlhaiSpacing.sm,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: enabled
                ? (isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary)
                : (isDark ? AppColors.textMutedDark : AppColors.textMuted)
                      .withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildPageNumberButton(int page, bool isDark) {
    final isActive = page == _currentPage;
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => setState(() => _currentPage = page),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isActive
              ? null
              : Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Text(
          '$page',
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive
                ? colorScheme.onPrimary
                : (isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary),
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // EMPTY STATE
  // ============================================================================

  Widget _buildEmptyState(AppLocalizations l10n, bool isDark) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xxxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 40,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.md),
          Text(
            l10n.noReturns,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xs),
          Text(
            l10n.noReturnsDesc,
            style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: AlhaiSpacing.lg),
          FilledButton.icon(
            onPressed: _openCreateReturn,
            icon: const Icon(Icons.add, size: 18),
            label: Text(l10n.createNewReturn),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(
                horizontal: AlhaiSpacing.lg,
                vertical: AlhaiSpacing.sm,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
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
        bgColor = isDark
            ? AppColors.warning.withValues(alpha: 0.15)
            : AppColors.warningSurface;
        textColor = isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309);
        borderColor = isDark
            ? AppColors.warning.withValues(alpha: 0.3)
            : const Color(0xFFFDE68A);
        label = l10n.pending;
        icon = Icons.access_time;
      case 'refunded':
        bgColor = isDark
            ? AppColors.success.withValues(alpha: 0.15)
            : AppColors.successSurface;
        textColor = isDark ? const Color(0xFF4ADE80) : AlhaiColors.successDark;
        borderColor = isDark
            ? AppColors.success.withValues(alpha: 0.3)
            : const Color(0xFFBBF7D0);
        label = l10n.returnRefunded;
        icon = Icons.check_circle;
      case 'rejected':
        bgColor = isDark
            ? AppColors.error.withValues(alpha: 0.15)
            : AppColors.errorSurface;
        textColor = isDark ? const Color(0xFFF87171) : const Color(0xFFB91C1C);
        borderColor = isDark
            ? AppColors.error.withValues(alpha: 0.3)
            : const Color(0xFFFECACA);
        label = l10n.returnRejected;
        icon = Icons.block;
      default:
        bgColor = AppColors.grey100;
        textColor = AppColors.textSecondary;
        borderColor = AppColors.border;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AlhaiSpacing.xs,
        vertical: AlhaiSpacing.xxs,
      ),
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
            const SizedBox(width: AlhaiSpacing.xxs),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(ReturnModel ret, bool isDark) {
    if (ret.customerAvatar != null) {
      return CircleAvatar(
        radius: 18,
        backgroundImage: NetworkImage(ret.customerAvatar!),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      );
    }
    // Initial letter avatar
    final initial = ret.customer.isNotEmpty ? ret.customer[0] : '?';
    return CircleAvatar(
      radius: 18,
      backgroundColor: isDark
          ? AppColors.surfaceVariantDark
          : AppColors.grey200,
      child: Text(
        initial,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.textMutedDark : AppColors.textSecondary,
        ),
      ),
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
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(
        top: AlhaiSpacing.md,
        bottom: AlhaiSpacing.xs,
      ),
      child: Column(
        children: [
          Divider(color: Theme.of(context).dividerColor),
          const SizedBox(height: AlhaiSpacing.sm),
          Text(
            l10n.allRightsReservedFooter,
            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // DRAWER (mobile)
  // ============================================================================
}
