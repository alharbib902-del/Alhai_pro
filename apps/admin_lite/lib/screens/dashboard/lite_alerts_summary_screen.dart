/// Alerts Summary Screen
///
/// Displays a summary of active alerts grouped by type:
/// stock alerts, order alerts, system alerts, and expiry alerts.
/// Supports RTL, dark mode, and responsive layouts.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

/// Alerts summary screen with grouped alert counts
class LiteAlertsSummaryScreen extends StatelessWidget {
  const LiteAlertsSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.alerts),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.done_all),
            tooltip: l10n.done,
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
            _buildAlertCategories(context, isDark, isMobile, l10n),
            const SizedBox(height: AlhaiSpacing.lg),

            // Recent alerts list
            _buildSectionTitle(l10n.notifications, Icons.access_time, isDark),
            const SizedBox(height: AlhaiSpacing.sm),
            _buildRecentAlerts(context, isDark, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCategories(BuildContext context, bool isDark, bool isMobile, AppLocalizations l10n) {
    final categories = [
      _AlertCategory(
        title: l10n.lowStock,
        count: 8,
        icon: Icons.inventory_2_outlined,
        color: AlhaiColors.warning,
        route: '/lite/alerts/stock',
      ),
      _AlertCategory(
        title: l10n.orders,
        count: 3,
        icon: Icons.receipt_long_outlined,
        color: AlhaiColors.info,
        route: '/lite/alerts/orders',
      ),
      _AlertCategory(
        title: l10n.notifications,
        count: 2,
        icon: Icons.settings_outlined,
        color: AlhaiColors.error,
        route: '/lite/alerts/system',
      ),
      _AlertCategory(
        title: l10n.products,
        count: 5,
        icon: Icons.calendar_today,
        color: Colors.orange,
        route: '/lite/alerts/stock',
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

  Widget _buildRecentAlerts(BuildContext context, bool isDark, AppLocalizations l10n) {
    final alerts = [
      _AlertItem(
        title: l10n.lowStock,
        subtitle: 'Rice 5kg - 3 units remaining',
        time: '10m',
        icon: Icons.warning_amber_rounded,
        color: AlhaiColors.warning,
        isRead: false,
      ),
      _AlertItem(
        title: l10n.orders,
        subtitle: 'New order #1052 received',
        time: '25m',
        icon: Icons.receipt_long,
        color: AlhaiColors.info,
        isRead: false,
      ),
      _AlertItem(
        title: l10n.products,
        subtitle: 'Yogurt expires in 3 days',
        time: '1h',
        icon: Icons.calendar_today,
        color: Colors.orange,
        isRead: true,
      ),
      _AlertItem(
        title: l10n.lowStock,
        subtitle: 'Olive Oil 1L - 5 units remaining',
        time: '2h',
        icon: Icons.warning_amber_rounded,
        color: AlhaiColors.warning,
        isRead: true,
      ),
      _AlertItem(
        title: l10n.sync,
        subtitle: l10n.syncComplete,
        time: '3h',
        icon: Icons.sync,
        color: AlhaiColors.success,
        isRead: true,
      ),
    ];

    return Column(
      children: alerts.map((alert) {
        return _buildAlertTile(context, alert, isDark);
      }).toList(),
    );
  }

  Widget _buildAlertTile(BuildContext context, _AlertItem alert, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: AlhaiSpacing.xs),
      padding: const EdgeInsets.all(AlhaiSpacing.sm),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: alert.isRead ? 0.04 : 0.08)
            : (alert.isRead ? Colors.white : alert.color.withValues(alpha: 0.04)),
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
              color: alert.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(alert.icon, color: alert.color, size: 18),
          ),
          const SizedBox(width: AlhaiSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: alert.isRead ? FontWeight.normal : FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.xxxs),
                Text(
                  alert.subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white38 : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            alert.time,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white24 : Colors.black38,
            ),
          ),
          if (!alert.isRead)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsetsDirectional.only(start: AlhaiSpacing.xs),
              decoration: BoxDecoration(
                color: alert.color,
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

class _AlertItem {
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color color;
  final bool isRead;

  const _AlertItem({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.color,
    required this.isRead,
  });
}
