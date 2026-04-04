/// Distributor Dashboard Screen
///
/// Shows real KPI cards and charts from Supabase via Riverpod providers.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:intl/intl.dart' show NumberFormat;

import '../../data/models.dart';
import '../../providers/distributor_providers.dart';
import '../../ui/skeleton_loading.dart';
import '../../ui/shared_widgets.dart';

class DistributorDashboardScreen extends ConsumerWidget {
  const DistributorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.sizeOf(context).width;
    final crossCount = width >= AlhaiBreakpoints.desktop
        ? 4
        : (width >= AlhaiBreakpoints.tablet ? 2 : 1);
    final l10n = AppLocalizations.of(context);
    final kpisAsync = ref.watch(dashboardKpisProvider);
    final padding = responsivePadding(width);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: kpisAsync.when(
        loading: () => const DashboardSkeleton(),
        error: (e, _) => ErrorStateWidget(
          message: l10n?.distributorLoadError ?? 'Error loading data',
          onRetry: () => ref.invalidate(dashboardKpisProvider),
          isDark: isDark,
          retryLabel: l10n?.distributorRetry ?? 'Retry',
        ),
        data: (kpis) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(dashboardKpisProvider),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      l10n?.distributorDashboard ?? 'Dashboard',
                      style: TextStyle(
                        fontSize: responsiveHeaderFontSize(width),
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AlhaiSpacing.xs),
                    Text(
                      l10n?.distributorDashboardSubtitle ??
                          'Distribution performance overview',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AlhaiSpacing.lg),

                    // Onboarding card for first-time users
                    if (kpis.totalOrders == 0)
                      _OnboardingCard(isDark: isDark, l10n: l10n),

                    if (kpis.totalOrders == 0)
                      const SizedBox(height: AlhaiSpacing.lg),

                    // Summary cards
                    GridView.count(
                      crossAxisCount: crossCount,
                      mainAxisSpacing: AlhaiSpacing.md,
                      crossAxisSpacing: AlhaiSpacing.md,
                      childAspectRatio: 1.8,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _SummaryCard(
                          title: l10n?.distributorTotalOrders ?? 'Total Orders',
                          value: '${kpis.totalOrders}',
                          icon: Icons.shopping_bag_outlined,
                          color: AppColors.primary,
                          isDark: isDark,
                        ),
                        _SummaryCard(
                          title: l10n?.distributorPendingOrders ?? 'Pending',
                          value: '${kpis.pendingOrders}',
                          icon: Icons.pending_outlined,
                          color: AppColors.warning,
                          isDark: isDark,
                        ),
                        _SummaryCard(
                          title: l10n?.distributorApprovedOrders ?? 'Approved',
                          value: '${kpis.approvedOrders}',
                          icon: Icons.check_circle_outline,
                          color: AppColors.success,
                          isDark: isDark,
                        ),
                        _SummaryCard(
                          title: l10n?.distributorRevenue ?? 'Revenue',
                          value:
                              '${NumberFormat('#,##0').format(kpis.totalRevenue)} ${l10n?.distributorSar ?? 'SAR'}',
                          icon: Icons.payments_outlined,
                          color: AppColors.credit,
                          isDark: isDark,
                        ),
                      ],
                    ),

                    const SizedBox(height: AlhaiSpacing.xl),

                    // Chart section
                    if (kpis.monthlySales.isNotEmpty)
                      Semantics(
                        label:
                            'Monthly sales bar chart showing sales amounts per month',
                        child: _ChartCard(
                          title:
                              l10n?.distributorMonthlySales ?? 'Monthly Sales',
                          monthlySales: kpis.monthlySales,
                          isDark: isDark,
                        ),
                      ),

                    const SizedBox(height: AlhaiSpacing.xl),

                    // Recent orders section
                    if (kpis.recentOrders.isNotEmpty)
                      _RecentOrdersCard(
                        title: l10n?.distributorRecentOrders ?? 'Recent Orders',
                        orders: kpis.recentOrders,
                        isDark: isDark,
                        l10n: l10n,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Private Widgets ────────────────────────────────────────────

class _OnboardingCard extends StatelessWidget {
  final bool isDark;
  final AppLocalizations? l10n;

  const _OnboardingCard({required this.isDark, this.l10n});

  @override
  Widget build(BuildContext context) {
    final steps = [
      (
        icon: Icons.receipt_long_rounded,
        color: AppColors.primary,
        title: l10n?.distributorOrders ?? 'Review Orders',
        subtitle: l10n?.distributorReviewOrdersDesc ??
            'Review and manage incoming purchase orders from stores',
        route: '/orders',
      ),
      (
        icon: Icons.price_change_rounded,
        color: AppColors.secondary,
        title: l10n?.distributorManagePrices ?? 'Manage Prices',
        subtitle: l10n?.distributorManagePricesDesc ??
            'Set and update product prices for your distribution',
        route: '/pricing',
      ),
      (
        icon: Icons.bar_chart_rounded,
        color: AppColors.info,
        title: l10n?.distributorViewReports ?? 'View Reports',
        subtitle: l10n?.distributorViewReportsDesc ??
            'Track sales performance and view analytics',
        route: '/reports',
      ),
      (
        icon: Icons.settings_rounded,
        color: AppColors.warning,
        title: l10n?.distributorUpdateSettings ?? 'Update Settings',
        subtitle: l10n?.distributorUpdateSettingsDesc ??
            'Configure company info, delivery zones, and notifications',
        route: '/settings',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(AlhaiRadius.lg),
        boxShadow: AppColors.getCardShadow(isDark),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.sm),
                decoration: BoxDecoration(
                  color:
                      AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(AlhaiRadius.md),
                ),
                child: ExcludeSemantics(
                  child: const Icon(Icons.waving_hand_rounded,
                      color: AppColors.primary, size: 28),
                ),
              ),
              const SizedBox(width: AlhaiSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n?.distributorWelcomePortal ??
                          'Welcome to the Distributor Portal!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.getTextPrimary(isDark),
                      ),
                    ),
                    const SizedBox(height: AlhaiSpacing.xxs),
                    Text(
                      l10n?.distributorGetStarted ??
                          'Get started by exploring these key features:',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.getTextSecondary(isDark),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.lg),
          Wrap(
            spacing: AlhaiSpacing.sm,
            runSpacing: AlhaiSpacing.sm,
            children: steps.map((step) {
              final screenWidth = MediaQuery.sizeOf(context).width;
              return SizedBox(
                width: screenWidth >= AlhaiBreakpoints.desktop
                    ? (screenWidth - 120) / 4
                    : screenWidth >= AlhaiBreakpoints.tablet
                        ? (screenWidth - 90) / 2
                        : double.infinity,
                child: Semantics(
                  button: true,
                  label: '${step.title}: ${step.subtitle}',
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AlhaiRadius.md),
                    onTap: () => GoRouter.of(context).go(step.route),
                    child: Container(
                      padding: const EdgeInsets.all(AlhaiSpacing.md),
                      decoration: BoxDecoration(
                        color:
                            step.color.withValues(alpha: isDark ? 0.08 : 0.04),
                        borderRadius: BorderRadius.circular(AlhaiRadius.md),
                        border: Border.all(
                          color: step.color.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ExcludeSemantics(
                            child: Icon(step.icon, color: step.color, size: 24),
                          ),
                          const SizedBox(height: AlhaiSpacing.sm),
                          Text(
                            step.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.getTextPrimary(isDark),
                            ),
                          ),
                          const SizedBox(height: AlhaiSpacing.xxs),
                          Text(
                            step.subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.getTextSecondary(isDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Semantics(
        label: '$title: $value',
        child: Container(
          padding: const EdgeInsets.all(AlhaiSpacing.mdl),
          decoration: BoxDecoration(
            color: AppColors.getSurface(isDark),
            borderRadius: BorderRadius.circular(AlhaiRadius.lg),
            boxShadow: AppColors.getCardShadow(isDark),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ExcludeSemantics(
                child: Container(
                  padding: const EdgeInsets.all(AlhaiSpacing.xs),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(AlhaiRadius.sm + 2),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
              const SizedBox(height: AlhaiSpacing.xxs),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.getTextSecondary(isDark),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final List<MonthlySales> monthlySales;
  final bool isDark;

  const _ChartCard({
    required this.title,
    required this.monthlySales,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final maxY = monthlySales.fold<double>(
            0, (max, s) => s.amount > max ? s.amount : max) *
        1.2;

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(AlhaiRadius.lg),
        boxShadow: AppColors.getCardShadow(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: responsiveSectionFontSize(width),
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.lg),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY > 0 ? maxY : 100,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipRoundedRadius: 8,
                    tooltipBgColor:
                        isDark ? AppColors.getSurface(true) : AppColors.grey800,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${(rod.toY / 1000).toStringAsFixed(0)}K',
                        TextStyle(
                          color: isDark
                              ? AppColors.getTextPrimary(true)
                              : AppColors.textOnPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < monthlySales.length) {
                          return Padding(
                            padding:
                                const EdgeInsets.only(top: AlhaiSpacing.xs),
                            child: Text(
                              monthlySales[idx].month,
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.getTextSecondary(isDark),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${(value / 1000).toStringAsFixed(0)}K',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.getTextMuted(isDark),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY > 0 ? maxY / 4 : 25,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.getBorder(isDark),
                    strokeWidth: 1,
                  ),
                ),
                barGroups: List.generate(monthlySales.length, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: monthlySales[i].amount,
                        gradient: LinearGradient(
                          colors: isDark
                              ? [AppColors.primaryLight, AppColors.primary]
                              : [AppColors.primary, AppColors.primaryDark],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        width: 20,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6)),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxY > 0 ? maxY : 100,
                          color: AppColors.primary
                              .withValues(alpha: isDark ? 0.08 : 0.04),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
          // Chart legend
          const SizedBox(height: AlhaiSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: AlhaiSpacing.xs),
              Text(
                l10n?.distributorMonthlySalesSar ?? 'Monthly Sales (SAR)',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.getTextSecondary(isDark),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecentOrdersCard extends StatelessWidget {
  final String title;
  final List<DistributorOrder> orders;
  final bool isDark;
  final AppLocalizations? l10n;

  const _RecentOrdersCard({
    required this.title,
    required this.orders,
    required this.isDark,
    this.l10n,
  });

  String _statusLabel(String status) {
    switch (status) {
      case 'sent':
      case 'draft':
        return l10n?.distributorStatusPending ?? 'Pending';
      case 'approved':
        return l10n?.distributorStatusApproved ?? 'Approved';
      case 'received':
        return l10n?.distributorStatusReceived ?? 'Received';
      case 'rejected':
        return l10n?.distributorStatusRejected ?? 'Rejected';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(AlhaiRadius.lg),
        boxShadow: AppColors.getCardShadow(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: responsiveSectionFontSize(width),
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.md),
          ...orders.map((order) => Padding(
                padding: const EdgeInsets.only(bottom: AlhaiSpacing.sm),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AlhaiRadius.sm),
                  onTap: () => context.go('/orders/${order.id}'),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          order.purchaseNumber,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.getTextPrimary(isDark),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          order.storeName,
                          style: TextStyle(
                            color: AppColors.getTextSecondary(isDark),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${NumberFormat('#,##0').format(order.total)} ${l10n?.distributorSar ?? 'SAR'}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.getTextPrimary(isDark),
                          ),
                        ),
                      ),
                      StatusBadge(
                        status: order.status,
                        label: _statusLabel(order.status),
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
