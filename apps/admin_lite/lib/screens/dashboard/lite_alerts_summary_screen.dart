/// Alerts Summary Screen
///
/// Displays a summary of active alerts grouped by type:
/// stock alerts, order alerts, system alerts, and notifications.
/// Pulls real counts from providers.
/// Supports RTL, dark mode, and responsive layouts.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_database/alhai_database.dart';

import '../../providers/lite_screen_providers.dart';

/// Alerts summary screen with grouped alert counts
class LiteAlertsSummaryScreen extends ConsumerWidget {
  const LiteAlertsSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final l10n = AppLocalizations.of(context)!;

    final stockAsync = ref.watch(liteStockAlertsProvider);
    final orderAsync = ref.watch(liteOrderAlertsProvider);
    final systemAsync = ref.watch(liteSystemAlertsProvider);
    final notifAsync = ref.watch(liteNotificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.alerts),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              ref.invalidate(liteStockAlertsProvider);
              ref.invalidate(liteOrderAlertsProvider);
              ref.invalidate(liteSystemAlertsProvider);
              ref.invalidate(liteNotificationsProvider);
            },
            icon: const Icon(Icons.refresh),
            tooltip: l10n.tryAgain,
          ),
          const SizedBox(width: AlhaiSpacing.xs),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? AlhaiSpacing.md : AlhaiSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Alert summary cards
            _buildAlertCategories(context, isDark, isMobile, l10n,
              stockCount: stockAsync.valueOrNull?.length ?? 0,
              orderCount: orderAsync.valueOrNull?.length ?? 0,
              systemCount: systemAsync.valueOrNull?.length ?? 0,
              notifCount: notifAsync.valueOrNull?.where((n) => !n.isRead).length ?? 0,
            ),
            const SizedBox(height: AlhaiSpacing.lg),

            // Recent notifications
            _buildSectionTitle(l10n.notifications, Icons.access_time, isDark),
            const SizedBox(height: AlhaiSpacing.sm),
            notifAsync.when(
              data: (notifs) => _buildRecentAlerts(context, isDark, l10n, notifs.take(5).toList()),
              loading: () => const Center(child: Padding(
                padding: EdgeInsets.all(AlhaiSpacing.lg),
                child: CircularProgressIndicator(),
              )),
              error: (_, __) => Center(child: Text(l10n.errorOccurred)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCategories(BuildContext context, bool isDark, bool isMobile, AppLocalizations l10n, {
    required int stockCount,
    required int orderCount,
    required int systemCount,
    required int notifCount,
  }) {
    final categories = [
      _AlertCategory(
        title: l10n.lowStock,
        count: stockCount,
        icon: Icons.inventory_2_outlined,
        color: AlhaiColors.warning,
        route: '/lite/alerts/stock',
      ),
      _AlertCategory(
        title: l10n.orders,
        count: orderCount,
        icon: Icons.receipt_long_outlined,
        color: AlhaiColors.info,
        route: '/lite/alerts/orders',
      ),
      _AlertCategory(
        title: l10n.notifications,
        count: systemCount,
        icon: Icons.settings_outlined,
        color: AlhaiColors.error,
        route: '/lite/alerts/system',
      ),
      _AlertCategory(
        title: l10n.notifications,
        count: notifCount,
        icon: Icons.notifications_outlined,
        color: Colors.orange,
        route: '/lite/alerts/notifications',
      ),
    ];

    if (isMobile) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildCategoryCard(context, categories[0], isDark)),
              const SizedBox(width: AlhaiSpacing.sm),
              Expanded(child: _buildCategoryCard(context, categories[1], isDark)),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.sm),
          Row(
            children: [
              Expanded(child: _buildCategoryCard(context, categories[2], isDark)),
              const SizedBox(width: AlhaiSpacing.sm),
              Expanded(child: _buildCategoryCard(context, categories[3], isDark)),
            ],
          ),
        ],
      );
    }

    return Row(
      children: categories.asMap().entries.map((entry) {
        return Expanded(
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              end: entry.key < categories.length - 1 ? AlhaiSpacing.sm : 0,
            ),
            child: _buildCategoryCard(context, entry.value, isDark),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategoryCard(BuildContext context, _AlertCategory category, bool isDark) {
    return InkWell(
      onTap: () => context.go(category.route),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(AlhaiSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white12 : Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: category.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(category.icon, color: category.color, size: 20),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: AlhaiSpacing.xxxs),
                  decoration: BoxDecoration(
                    color: category.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${category.count}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: category.color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AlhaiSpacing.sm),
            Text(
              category.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AlhaiColors.primary),
        const SizedBox(width: AlhaiSpacing.xs),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : null,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentAlerts(BuildContext context, bool isDark, AppLocalizations l10n, List<NotificationsTableData> notifs) {
    if (notifs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AlhaiSpacing.lg),
          child: Text(l10n.noResults, style: TextStyle(color: isDark ? Colors.white54 : Colors.black45)),
        ),
      );
    }

    return Column(
      children: notifs.map((n) => _buildNotifTile(context, n, isDark)).toList(),
    );
  }

  Widget _buildNotifTile(BuildContext context, NotificationsTableData notif, bool isDark) {
    final color = notif.isRead ? Colors.grey : AlhaiColors.primary;
    return Container(
      margin: const EdgeInsets.only(bottom: AlhaiSpacing.xs),
      padding: const EdgeInsets.all(AlhaiSpacing.sm),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: notif.isRead ? 0.04 : 0.08)
            : (notif.isRead ? Colors.white : AlhaiColors.primary.withValues(alpha: 0.04)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white12 : Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.notifications_outlined, color: color, size: 18),
          ),
          const SizedBox(width: AlhaiSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notif.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                if (notif.body != null) ...[
                  const SizedBox(height: AlhaiSpacing.xxxs),
                  Text(
                    notif.body!,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white38 : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (!notif.isRead)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsetsDirectional.only(start: AlhaiSpacing.xs),
              decoration: const BoxDecoration(
                color: AlhaiColors.primary,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}

class _AlertCategory {
  final String title;
  final int count;
  final IconData icon;
  final Color color;
  final String route;

  const _AlertCategory({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    required this.route,
  });
}
