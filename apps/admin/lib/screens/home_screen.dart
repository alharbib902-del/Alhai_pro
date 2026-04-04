/// Admin Home Screen - Dashboard overview
///
/// Entry dashboard for the Admin app showing overview stats
/// from the database (today's sales, orders, low stock, customers)
/// and quick access to all management features.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

/// Admin Home Screen - wired to [dashboardDataProvider] for real-time stats
class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = Localizations.localeOf(context).toString();
    final dashboardAsync = ref.watch(dashboardDataProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: dashboardAsync.when(
        loading: () => SingleChildScrollView(
          padding: const EdgeInsets.all(AlhaiSpacing.mdl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header skeleton
              const SkeletonLoader(width: 160, height: 24),
              const SizedBox(height: AlhaiSpacing.xxs),
              const SkeletonLoader(width: 100, height: 14),
              const SizedBox(height: AlhaiSpacing.lg),
              // Stat cards skeleton
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount =
                      constraints.maxWidth >= AlhaiBreakpoints.desktop
                          ? 4
                          : constraints.maxWidth >= AlhaiBreakpoints.tablet
                              ? 2
                              : 1;
                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: AlhaiSpacing.md,
                    mainAxisSpacing: AlhaiSpacing.md,
                    childAspectRatio: 1.8,
                    children: List.generate(4, (_) => const SkeletonCard()),
                  );
                },
              ),
              const SizedBox(height: AlhaiSpacing.lg),
              // Quick actions skeleton
              const SkeletonLoader(width: 120, height: 16),
              const SizedBox(height: AlhaiSpacing.md),
              Wrap(
                spacing: AlhaiSpacing.sm,
                runSpacing: AlhaiSpacing.sm,
                children: List.generate(
                  4,
                  (_) => const SkeletonLoader(width: 120, height: 38, borderRadius: 12),
                ),
              ),
              const SizedBox(height: AlhaiSpacing.lg),
              // Recent sales skeleton
              const SkeletonLoader(width: 140, height: 16),
              const SizedBox(height: AlhaiSpacing.md),
              ...List.generate(5, (_) => const SkeletonListItem(hasTrailing: true)),
            ],
          ),
        ),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ExcludeSemantics(
                child: Icon(Icons.error_outline, size: 48, color: AppColors.error),
              ),
              const SizedBox(height: AlhaiSpacing.md),
              Text(
                l10n.errorWithDetails('$err'),
                style: TextStyle(color: AppColors.getTextSecondary(isDark)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AlhaiSpacing.md),
              FilledButton.icon(
                onPressed: () => ref.invalidate(dashboardDataProvider),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(l10n.retry),
              ),
            ],
          ),
        ),
        data: (data) {
          final screenWidth = MediaQuery.of(context).size.width;
          final isTablet = screenWidth >= AlhaiBreakpoints.tablet &&
              screenWidth < AlhaiBreakpoints.desktop;

          return RefreshIndicator(
          onRefresh: () async => ref.invalidate(dashboardDataProvider),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AlhaiSpacing.mdl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome header
                Text(
                  l10n.home,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: AlhaiSpacing.xxs),
                Text(
                  l10n.dashboardTitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: AlhaiSpacing.lg),

                // Stat cards grid
                LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount =
                        constraints.maxWidth >= AlhaiBreakpoints.desktop
                            ? 4
                            : constraints.maxWidth >= AlhaiBreakpoints.tablet
                                ? 2
                                : 1;
                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: AlhaiSpacing.md,
                      mainAxisSpacing: AlhaiSpacing.md,
                      childAspectRatio: 1.8,
                      children: [
                        _StatTile(
                          icon: Icons.attach_money_rounded,
                          label: l10n.todaySales,
                          value: '${AppNumberFormatter.currency(data.todaySales, locale: locale)} ${l10n.sar}',
                          changePercent: data.salesChangePercent,
                          color: AppColors.primary,
                          isDark: isDark,
                        ),
                        _StatTile(
                          icon: Icons.receipt_long_rounded,
                          label: l10n.orders,
                          value: AppNumberFormatter.integer(data.todayOrders, locale: locale),
                          changePercent: data.ordersChangePercent,
                          color: AppColors.info,
                          isDark: isDark,
                        ),
                        _StatTile(
                          icon: Icons.warning_amber_rounded,
                          label: l10n.lowStockLabel,
                          value: AppNumberFormatter.integer(data.lowStockCount, locale: locale),
                          color: AppColors.warning,
                          isDark: isDark,
                        ),
                        _StatTile(
                          icon: Icons.people_outline_rounded,
                          label: l10n.newCustomers,
                          value: AppNumberFormatter.integer(data.newCustomersToday, locale: locale),
                          color: AppColors.success,
                          isDark: isDark,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: AlhaiSpacing.lg),

                // Quick actions row
                Text(
                  l10n.quickActions,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: AlhaiSpacing.md),
                Wrap(
                  spacing: AlhaiSpacing.sm,
                  runSpacing: AlhaiSpacing.sm,
                  children: [
                    _QuickAction(
                      icon: Icons.dashboard_rounded,
                      label: l10n.dashboardTitle,
                      onTap: () => context.go(AppRoutes.dashboard),
                      isDark: isDark,
                    ),
                    _QuickAction(
                      icon: Icons.inventory_2_rounded,
                      label: l10n.products,
                      onTap: () => context.go(AppRoutes.products),
                      isDark: isDark,
                    ),
                    _QuickAction(
                      icon: Icons.analytics_rounded,
                      label: l10n.reports,
                      onTap: () => context.go(AppRoutes.reports),
                      isDark: isDark,
                    ),
                    _QuickAction(
                      icon: Icons.settings_rounded,
                      label: l10n.settings,
                      onTap: () => context.go(AppRoutes.settings),
                      isDark: isDark,
                    ),
                  ],
                ),
                const SizedBox(height: AlhaiSpacing.lg),

                // Recent sales -- tablet uses a 2-column side-by-side layout
                if (isTablet && data.recentSales.isNotEmpty)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: _RecentSalesColumn(
                          sales: data.recentSales.take(5).toList(),
                          title: l10n.recentTransactions,
                          locale: locale,
                          isDark: isDark,
                          l10n: l10n,
                        ),
                      ),
                    ],
                  )
                else if (data.recentSales.isNotEmpty) ...[
                  Text(
                    l10n.recentTransactions,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: AlhaiSpacing.md),
                  ...data.recentSales.take(5).map((sale) {
                    final receiptLabel = sale.receiptNo.isNotEmpty ? sale.receiptNo : sale.id.substring(0, 8);
                    final totalLabel = '${AppNumberFormatter.currency(sale.total, locale: locale)} ${l10n.sar}';
                    return Semantics(
                      label: '${l10n.recentTransactions}: $receiptLabel, $totalLabel',
                      child: Container(
                        margin: const EdgeInsets.only(bottom: AlhaiSpacing.xs),
                        padding: const EdgeInsets.all(AlhaiSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.getSurface(isDark),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.getBorder(isDark)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AlhaiSpacing.xs),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const ExcludeSemantics(
                                child: Icon(Icons.receipt_rounded,
                                    color: AppColors.primary, size: 18),
                              ),
                            ),
                            const SizedBox(width: AlhaiSpacing.sm),
                            Expanded(
                              child: Text(
                                receiptLabel,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.getTextPrimary(isDark),
                                ),
                              ),
                            ),
                            Text(
                              totalLabel,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        );
        },
      ),
      ),
    );
  }
}

/// Extracted recent sales column widget for tablet layout
class _RecentSalesColumn extends StatelessWidget {
  final List<dynamic> sales;
  final String title;
  final String locale;
  final bool isDark;
  final AppLocalizations l10n;

  const _RecentSalesColumn({
    required this.sales,
    required this.title,
    required this.locale,
    required this.isDark,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        const SizedBox(height: AlhaiSpacing.md),
        ...sales.map((sale) {
          final receiptLabel = sale.receiptNo.isNotEmpty ? sale.receiptNo : sale.id.substring(0, 8);
          final totalLabel = '${AppNumberFormatter.currency(sale.total, locale: locale)} ${l10n.sar}';
          return Semantics(
            label: '${l10n.recentTransactions}: $receiptLabel, $totalLabel',
            child: Container(
              margin: const EdgeInsets.only(bottom: AlhaiSpacing.xs),
              padding: const EdgeInsets.all(AlhaiSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.getSurface(isDark),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.getBorder(isDark)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AlhaiSpacing.xs),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const ExcludeSemantics(
                      child: Icon(Icons.receipt_rounded,
                          color: AppColors.primary, size: 18),
                    ),
                  ),
                  const SizedBox(width: AlhaiSpacing.sm),
                  Expanded(
                    child: Text(
                      receiptLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AppColors.getTextPrimary(isDark),
                      ),
                    ),
                  ),
                  Text(
                    totalLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final double? changePercent;
  final Color color;
  final bool isDark;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    this.changePercent,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final changeDesc = changePercent != null && changePercent != 0
        ? ', ${changePercent! > 0 ? "increased" : "decreased"} by ${changePercent!.abs().toStringAsFixed(0)}%'
        : '';
    return Semantics(
      label: '$label: $value$changeDesc',
      child: Container(
        padding: const EdgeInsets.all(AlhaiSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.getSurface(isDark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.getBorder(isDark)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AlhaiSpacing.xs),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ExcludeSemantics(
                    child: Icon(icon, color: color, size: 18),
                  ),
                ),
                const Spacer(),
                if (changePercent != null && changePercent != 0)
                  ExcludeSemantics(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          changePercent! >= 0
                              ? Icons.arrow_upward_rounded
                              : Icons.arrow_downward_rounded,
                          size: 14,
                          color: changePercent! >= 0 ? AppColors.success : AppColors.error,
                        ),
                        Text(
                          '${changePercent!.abs().toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: changePercent! >= 0 ? AppColors.success : AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.getTextPrimary(isDark),
              ),
            ),
            const SizedBox(height: AlhaiSpacing.xxxs),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.getTextMuted(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDark;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AlhaiSpacing.md, vertical: AlhaiSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.getSurface(isDark),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.getBorder(isDark)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ExcludeSemantics(
                  child: Icon(icon, size: 18, color: AppColors.primary),
                ),
                const SizedBox(width: AlhaiSpacing.xs),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
