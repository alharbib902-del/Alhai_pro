/// Lite Push Notifications List Screen
///
/// Shows all push notifications with read/unread state,
/// grouped by date with swipe-to-dismiss support.
/// Supports RTL, dark mode, and responsive layouts.
library;

import 'package:flutter/material.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

/// Push notifications list for Admin Lite
class LiteNotificationsListScreen extends StatelessWidget {
  const LiteNotificationsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationsTitle),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(l10n.done),
          ),
          const SizedBox(width: AlhaiSpacing.xs),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(isMobile ? AlhaiSpacing.md : AlhaiSpacing.lg),
        children: [
          // Today section
          _buildDateHeader(l10n.today, isDark),
          const SizedBox(height: AlhaiSpacing.xs),
          ..._todayNotifications.map((n) => _buildNotificationTile(context, n, isDark)),

          const SizedBox(height: AlhaiSpacing.lg),

          // Yesterday section
          _buildDateHeader(l10n.yesterday, isDark),
          const SizedBox(height: AlhaiSpacing.xs),
          ..._yesterdayNotifications.map((n) => _buildNotificationTile(context, n, isDark)),
        ],
      ),
    );
  }

  Widget _buildDateHeader(String label, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AlhaiSpacing.xxs),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white54 : Colors.black54,
        ),
      ),
    );
  }

  Widget _buildNotificationTile(BuildContext context, _NotificationData notification, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: AlhaiSpacing.xs),
      padding: const EdgeInsets.all(AlhaiSpacing.sm),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: notification.isRead ? 0.04 : 0.08)
            : (notification.isRead ? Colors.white : notification.color.withValues(alpha: 0.04)),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white12 : Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: notification.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(notification.icon, color: notification.color, size: 20),
          ),
          const SizedBox(width: AlhaiSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.xxxs),
                Text(
                  notification.body,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white38 : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AlhaiSpacing.xxs),
                Text(
                  notification.time,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white24 : Colors.black38,
                  ),
                ),
              ],
            ),
          ),
          if (!notification.isRead)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: AlhaiSpacing.xxs),
              decoration: BoxDecoration(
                color: AlhaiColors.primary,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  static const _todayNotifications = [
    _NotificationData(
      title: 'Low Stock Alert',
      body: 'Rice 5kg is now out of stock. Consider reordering.',
      time: '10 min ago',
      icon: Icons.warning_amber_rounded,
      color: AlhaiColors.warning,
      isRead: false,
    ),
    _NotificationData(
      title: 'New Order',
      body: 'Order #1052 received from online store.',
      time: '25 min ago',
      icon: Icons.receipt_long,
      color: AlhaiColors.info,
      isRead: false,
    ),
    _NotificationData(
      title: 'Shift Opened',
      body: 'Ahmed Al-Salem opened shift at 08:00 AM.',
      time: '2 hours ago',
      icon: Icons.play_circle_outline,
      color: AlhaiColors.success,
      isRead: true,
    ),
  ];

  static const _yesterdayNotifications = [
    _NotificationData(
      title: 'Refund Request',
      body: 'Pending refund #R-2045 requires approval.',
      time: '14:30',
      icon: Icons.undo,
      color: AlhaiColors.error,
      isRead: true,
    ),
    _NotificationData(
      title: 'Sync Complete',
      body: 'All data synchronized successfully.',
      time: '12:00',
      icon: Icons.sync,
      color: AlhaiColors.success,
      isRead: true,
    ),
    _NotificationData(
      title: 'Product Expiry',
      body: '3 products expiring within 7 days.',
      time: '09:15',
      icon: Icons.calendar_today,
      color: Colors.orange,
      isRead: true,
    ),
  ];
}

class _NotificationData {
  final String title;
  final String body;
  final String time;
  final IconData icon;
  final Color color;
  final bool isRead;

  const _NotificationData({
    required this.title,
    required this.body,
    required this.time,
    required this.icon,
    required this.color,
    required this.isRead,
  });
}
