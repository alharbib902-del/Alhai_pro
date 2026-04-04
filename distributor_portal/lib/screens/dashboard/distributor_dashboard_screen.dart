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

class DistributorDashboardScreen extends ConsumerWidget {
  const DistributorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.sizeOf(context).width;
    final crossCount = width > 900 ? 4 : (width > 600 ? 2 : 1);
    final l10n = AppLocalizations.of(context);
    final kpisAsync = ref.watch(dashboardKpisProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: kpisAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(
          message: l10n?.distributorLoadError ?? 'Error loading data',
          onRetry: () => ref.invalidate(dashboardKpisProvider),
          isDark: isDark,
          l10n: l10n,
        ),
        data: (kpis) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(dashboardKpisProvider),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AlhaiSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  l10n?.distributorDashboard ?? 'Dashboard',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.xs),
                Text(
                  l10n?.distributorDashboardSubtitle ?? 'Distribution performance overview',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
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
                      color: Colors.orange,
                      isDark: isDark,
                    ),
                    _SummaryCard(
                      title: l10n?.distributorApprovedOrders ?? 'Approved',
                      value: '${kpis.approvedOrders}',
                      icon: Icons.check_circle_outline,
                      color: Colors.green,
                      isDark: isDark,
                    ),
                    _SummaryCard(
                      title: l10n?.distributorRevenue ?? 'Revenue',
                      value: '${NumberFormat('#,##0').format(kpis.totalRevenue)} ${l10n?.distributorSar ?? 'SAR'}',
                      icon: Icons.payments_outlined,
                      color: Colors.teal,
                      isDark: isDark,
                    ),
                  ],
                ),

                const SizedBox(height: AlhaiSpacing.xl),

                // Chart section
                if (kpis.monthlySales.isNotEmpty)
                  _ChartCard(
                    title: l10n?.distributorMonthlySales ?? 'Monthly Sales',
                    monthlySales: kpis.monthlySales,
                    isDark: isDark,
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
    );
  }
}

// ─── Shared Widgets ─────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final bool isDark;
  final AppLocalizations? l10n;

  const _ErrorView({
    required this.message,
    required this.onRetry,
    required this.isDark,
    this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(height: AlhaiSpacing.md),
          Text(message, style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          )),
          const SizedBox(height: AlhaiSpacing.md),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
            label: Text(l10n?.distributorRetry ?? 'Retry'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
            ),
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
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xxs),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
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
    final maxY = monthlySales.fold<double>(
            0, (max, s) => s.amount > max ? s.amount : max) *
        1.2;

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.lg),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY > 0 ? maxY : 100,
                barTouchData: BarTouchData(enabled: true),
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
                            padding: const EdgeInsets.only(top: AlhaiSpacing.xs),
                            child: Text(
                              monthlySales[idx].month,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? Theme.of(context).colorScheme.onSurfaceVariant
                                    : AppColors.textSecondary,
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
                            color: isDark
                                ? Colors.white54
                                : AppColors.textSecondary,
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
                    color: isDark
                        ? Theme.of(context).colorScheme.outlineVariant
                        : Theme.of(context)
                            .colorScheme
                            .surfaceContainerLow,
                    strokeWidth: 1,
                  ),
                ),
                barGroups: List.generate(monthlySales.length, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: monthlySales[i].amount,
                        color: AppColors.primary,
                        width: 20,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6)),
                      ),
                    ],
                  );
                }),
              ),
            ),
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

  Color _statusColor(String status) {
    switch (status) {
      case 'sent':
        return Colors.blue;
      case 'approved':
        return Colors.green;
      case 'received':
        return Colors.teal;
      case 'rejected':
        return Colors.red;
      default:
        return AppColors.grey500;
    }
  }

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
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.md),
          ...orders.map((order) => Padding(
                padding: const EdgeInsets.only(bottom: AlhaiSpacing.sm),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => context.go('/orders/${order.id}'),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          order.purchaseNumber,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color:
                                isDark ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          order.storeName,
                          style: TextStyle(
                            color: isDark
                                ? Theme.of(context).colorScheme.onSurface
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${NumberFormat('#,##0').format(order.total)} ${l10n?.distributorSar ?? 'SAR'}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color:
                                isDark ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _statusColor(order.status)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _statusLabel(order.status),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _statusColor(order.status),
                          ),
                        ),
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
