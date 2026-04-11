import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../core/router/routes.dart';
import '../../core/responsive/responsive_utils.dart';
import '../../core/utils/currency_formatter.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import '../../providers/dashboard_providers.dart';
import '../../widgets/layout/app_header.dart';
import '../../widgets/dashboard/stat_card.dart';
import '../../widgets/dashboard/sales_chart.dart';
import '../../widgets/dashboard/elegant_quick_actions.dart';
import '../../widgets/dashboard/recent_transactions.dart';
import '../../widgets/common/shimmer_loading.dart';

/// Main dashboard screen with real-time data from database
// TODO(L30): Add pull-to-refresh haptic feedback on dashboard refresh.
// TODO(L31): Improve loading state with shimmer placeholders matching stat card shapes.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  Future<void> _refreshDashboard(WidgetRef ref) async {
    // Invalidate the provider to force a refresh
    ref.invalidate(dashboardDataProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWideScreen = context.isDesktop;
    final isMediumScreen = !context.isMobile;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    // Watch the dashboard data provider reactively
    final dashboardAsync = ref.watch(dashboardDataProvider);

    return Column(
      children: [
        AppHeader(
          title: l10n.dashboardTitle,
          subtitle: _getDateSubtitle(l10n),
          showSearch: isWideScreen,
          searchHint: l10n.searchPlaceholder,
          onMenuTap: isWideScreen
              ? null
              : () => Scaffold.of(context).openDrawer(),
          onNotificationsTap: () => context.push('/notifications'),
          notificationsCount: 3,
          userName: l10n.defaultUserName,
          userRole: l10n.branchManager,
          onUserTap: () {},
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _refreshDashboard(ref),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(
                isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md,
              ),
              child: dashboardAsync.when(
                data: (data) => _buildContent(
                  context,
                  data,
                  isWideScreen,
                  isMediumScreen,
                  l10n,
                ),
                loading: () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerStats(isWide: isWideScreen),
                    SizedBox(height: AlhaiSpacing.lg),
                    const ShimmerCard(height: 200),
                    SizedBox(height: AlhaiSpacing.md),
                    const ShimmerList(itemCount: 4),
                  ],
                ),
                error: (error, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AlhaiSpacing.massive),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 48,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.3)
                              : AppColors.textTertiary,
                        ),
                        SizedBox(height: AlhaiSpacing.md),
                        Text(
                          l10n.errorOccurred,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: AlhaiSpacing.sm),
                        TextButton.icon(
                          onPressed: () => _refreshDashboard(ref),
                          icon: const Icon(Icons.refresh_rounded),
                          label: Text(l10n.tryAgain),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Main content with real data
  Widget _buildContent(
    BuildContext context,
    DashboardData data,
    bool isWideScreen,
    bool isMediumScreen,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stats cards
        _buildStatsSection(context, data, isWideScreen, isMediumScreen, l10n),

        // Expiry alert banner
        if (data.expiringProductsCount > 0) ...[
          const ResponsiveGap.sm(),
          _buildExpiryAlert(context, data.expiringProductsCount),
        ],

        const ResponsiveGap.md(),

        // Chart + Quick Actions + Top Selling
        if (isWideScreen)
          _buildMainRow(context, data, l10n)
        else
          _buildMainColumn(context, data, l10n),

        const ResponsiveGap.md(),

        // Recent transactions
        _buildRecentTransactions(context, data, l10n),
      ],
    );
  }

  /// Stats section with real data from DB
  Widget _buildStatsSection(
    BuildContext context,
    DashboardData data,
    bool isWideScreen,
    bool isMediumScreen,
    AppLocalizations l10n,
  ) {
    final isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;
    final cards = [
      DefaultStatCards.todaySales(
        l10n: l10n,
        value: CurrencyFormatter.formatNumberWithContext(
          context,
          data.todaySales,
          decimalDigits: 0,
        ),
        change: data.salesChangePercent,
        onTap: () => context.push('/sales'),
      ),
      DefaultStatCards.ordersCount(
        l10n: l10n,
        value: '${data.todayOrders}',
        change: data.ordersChangePercent,
        onTap: () => context.push('/sales'),
      ),
      DefaultStatCards.newCustomers(
        l10n: l10n,
        value: '${data.newCustomersToday}',
        change: null,
        onTap: () => context.push(AppRoutes.customers),
      ),
      DefaultStatCards.lowStock(
        l10n: l10n,
        value: '${data.lowStockCount}',
        alertIncrease: data.lowStockCount > 0 ? data.lowStockCount : null,
        onTap: () => context.push(AppRoutes.inventory),
      ),
    ];

    final spacing = isMediumScreen ? AlhaiSpacing.md : AlhaiSpacing.sm;

    // Desktop OR landscape phone: show all 4 cards in a single row
    if (isWideScreen || (isLandscape && !isMediumScreen)) {
      return Row(
        children: cards.asMap().entries.map((entry) {
          return Expanded(
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                end: entry.key < cards.length - 1 ? spacing : 0,
              ),
              child: entry.value,
            ),
          );
        }).toList(),
      );
    }

    // Mobile/Tablet portrait: 2x2
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: cards[0]),
            SizedBox(width: spacing),
            Expanded(child: cards[1]),
          ],
        ),
        SizedBox(height: spacing),
        Row(
          children: [
            Expanded(child: cards[2]),
            SizedBox(width: spacing),
            Expanded(child: cards[3]),
          ],
        ),
      ],
    );
  }

  /// Desktop main row: Chart(2/3) + QuickActions+TopSelling(1/3)
  Widget _buildMainRow(
    BuildContext context,
    DashboardData data,
    AppLocalizations l10n,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: SalesChartCard(
            title: l10n.salesAnalysis,
            subtitle: l10n.storePerformance,
            data: _buildChartData(data, l10n),
          ),
        ),
        SizedBox(width: AlhaiSpacing.lg),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              ElegantQuickActions(
                onNewSale: () => context.go(AppRoutes.pos),
                onAddProduct: () => context.push(AppRoutes.products),
                onRefund: () => context.push(AppRoutes.returns),
                onDailyReport: () => context.push('/reports'),
              ),
              SizedBox(height: AlhaiSpacing.lg),
              TopProductsList(
                products: _buildTopProducts(data),
                onProductTap: (id) =>
                    context.push(AppRoutes.productDetailPath(id)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Mobile/Tablet main column
  Widget _buildMainColumn(
    BuildContext context,
    DashboardData data,
    AppLocalizations l10n,
  ) {
    return Column(
      children: [
        SalesChartCard(
          title: l10n.salesAnalysis,
          subtitle: l10n.storePerformance,
          data: _buildChartData(data, l10n),
        ),
        const ResponsiveGap.sm(),
        ElegantQuickActions(
          onNewSale: () => context.go(AppRoutes.pos),
          onAddProduct: () => context.push(AppRoutes.products),
          onRefund: () => context.push(AppRoutes.returns),
          onDailyReport: () => context.push('/reports'),
        ),
        const ResponsiveGap.sm(),
        TopProductsList(
          products: _buildTopProducts(data),
          onProductTap: (id) => context.push(AppRoutes.productDetailPath(id)),
        ),
      ],
    );
  }

  /// Recent transactions from real sales data
  Widget _buildRecentTransactions(
    BuildContext context,
    DashboardData data,
    AppLocalizations l10n,
  ) {
    final transactions = data.recentSales.map((sale) {
      return Transaction(
        id: sale.receiptNo,
        customerName: sale.customerName ?? l10n.cashCustomer,
        amount: sale.total,
        type: TransactionType.sale,
        timestamp: sale.createdAt,
        paymentMethod: sale.paymentMethod,
      );
    }).toList();

    return RecentTransactionsList(
      transactions: transactions,
      onViewAll: () => context.push('/sales'),
      onViewDetails: (orderId) {},
    );
  }

  /// Expiry alert banner for products expiring within 7 days
  Widget _buildExpiryAlert(BuildContext context, int count) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(AppRoutes.expiryTracking),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AlhaiSpacing.md,
            vertical: AlhaiSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AlhaiColors.warning.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AlhaiColors.warning.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: AlhaiColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: AlhaiColors.warningDark,
                  size: 20,
                ),
              ),
              SizedBox(width: AlhaiSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$count منتج قريب الانتهاء',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AlhaiColors.warning,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: AlhaiSpacing.xxxs),
                    Text(
                      'منتجات تنتهي صلاحيتها خلال 7 ايام',
                      style: TextStyle(
                        color: AlhaiColors.warningDark,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AlhaiColors.warning,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDateSubtitle(AppLocalizations l10n) {
    final now = DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year}';
    return '$dateStr \u2022 ${l10n.mainBranch}';
  }

  /// Build chart data from real weekly/monthly sales
  Map<ChartPeriod, List<ChartDataPoint>> _buildChartData(
    DashboardData data,
    AppLocalizations l10n,
  ) {
    // Weekly data from real DB queries
    final weeklyData = data.weeklySales.map((day) {
      return ChartDataPoint(
        label: _getDayLabel(day.date.weekday, l10n),
        value: day.total,
        date: day.date,
      );
    }).toList();

    // Monthly data (4 weeks) from real DB queries
    final monthlyData = data.monthlySales.asMap().entries.map((entry) {
      final weekNum = entry.key + 1;
      return ChartDataPoint(
        label: '${l10n.weekly} $weekNum',
        value: entry.value.total,
        date: entry.value.date,
      );
    }).toList();

    return {
      ChartPeriod.weekly: weeklyData,
      ChartPeriod.monthly: monthlyData,
      // Yearly still uses empty since we don't have year-level aggregation yet
      ChartPeriod.yearly: const [],
    };
  }

  /// Build top products from real DB query
  List<TopProductItem> _buildTopProducts(DashboardData data) {
    if (data.topSellingProducts.isEmpty) {
      return const [];
    }

    return data.topSellingProducts.map((product) {
      return TopProductItem(
        id: product.id,
        name: product.name,
        icon: Icons.inventory_2_rounded,
        quantity: product.stockQty.toInt(),
        revenue: product.price * product.stockQty,
      );
    }).toList();
  }

  /// Get localized short day name from weekday number
  String _getDayLabel(int weekday, AppLocalizations l10n) {
    switch (weekday) {
      case DateTime.saturday:
        return l10n.sat;
      case DateTime.sunday:
        return l10n.sun;
      case DateTime.monday:
        return l10n.mon;
      case DateTime.tuesday:
        return l10n.tue;
      case DateTime.wednesday:
        return l10n.wed;
      case DateTime.thursday:
        return l10n.thu;
      case DateTime.friday:
        return l10n.fri;
      default:
        return '';
    }
  }
}
