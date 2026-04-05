/// Lite Push Notifications List Screen
///
/// Shows all push notifications queried from notificationsDao,
/// with read/unread state and mark-as-read support.
/// Supports RTL, dark mode, and responsive layouts.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:get_it/get_it.dart';

import '../../providers/lite_screen_providers.dart';

/// Push notifications list for Admin Lite
class LiteNotificationsListScreen extends ConsumerWidget {
  const LiteNotificationsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final l10n = AppLocalizations.of(context);
    final dataAsync = ref.watch(liteNotificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationsTitle),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () async {
              final storeId = ref.read(currentStoreIdProvider);
              if (storeId != null) {
                final db = GetIt.I<AppDatabase>();
                await db.notificationsDao.markAllAsRead(storeId);
                ref.invalidate(liteNotificationsProvider);
              }
            },
            child: Text(l10n.done),
          ),
          const SizedBox(width: AlhaiSpacing.xs),
        ],
      ),
      body: dataAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined,
                      size: 64,
                      color: isDark
                          ? Colors.white24
                          : Theme.of(context).colorScheme.outlineVariant),
                  const SizedBox(height: AlhaiSpacing.md),
                  Text(l10n.noResults,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: isDark
                              ? Colors.white54
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant)),
                ],
              ),
            );
          }

          // Group by date
          final today = DateTime.now();
          final todayStart = DateTime(today.year, today.month, today.day);
          final yesterdayStart = todayStart.subtract(const Duration(days: 1));

          // Single-pass grouping instead of three separate .where() loops
          final todayItems = <NotificationsTableData>[];
          final yesterdayItems = <NotificationsTableData>[];
          final olderItems = <NotificationsTableData>[];
          for (final n in notifications) {
            if (n.createdAt.isAfter(todayStart)) {
              todayItems.add(n);
            } else if (n.createdAt.isAfter(yesterdayStart)) {
              yesterdayItems.add(n);
            } else {
              olderItems.add(n);
            }
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(liteNotificationsProvider),
            child: ListView(
              padding:
                  EdgeInsets.all(isMobile ? AlhaiSpacing.md : AlhaiSpacing.lg),
              children: [
                if (todayItems.isNotEmpty) ...[
                  _buildDateHeader(l10n.today, isDark),
                  const SizedBox(height: AlhaiSpacing.xs),
                  ...todayItems.map((n) => KeyedSubtree(
                        key: ValueKey(n.id),
                        child: _buildNotificationTile(context, n, isDark, ref),
                      )),
                  const SizedBox(height: AlhaiSpacing.lg),
                ],
                if (yesterdayItems.isNotEmpty) ...[
                  _buildDateHeader(l10n.yesterday, isDark),
                  const SizedBox(height: AlhaiSpacing.xs),
                  ...yesterdayItems.map((n) => KeyedSubtree(
                        key: ValueKey(n.id),
                        child: _buildNotificationTile(context, n, isDark, ref),
                      )),
                  const SizedBox(height: AlhaiSpacing.lg),
                ],
                if (olderItems.isNotEmpty) ...[
                  _buildDateHeader('Older', isDark),
                  const SizedBox(height: AlhaiSpacing.xs),
                  ...olderItems.map((n) => KeyedSubtree(
                        key: ValueKey(n.id),
                        child: _buildNotificationTile(context, n, isDark, ref),
                      )),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.errorOccurred),
              TextButton.icon(
                  onPressed: () => ref.invalidate(liteNotificationsProvider),
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(l10n.tryAgain)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateHeader(String label, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AlhaiSpacing.xxs),
      child: Builder(
          builder: (context) => Text(label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurfaceVariant))),
    );
  }

  IconData _notificationIcon(String? type) {
    return switch (type) {
      'low_stock' => Icons.warning_amber_rounded,
      'order' => Icons.receipt_long,
      'shift' => Icons.play_circle_outline,
      'refund' => Icons.undo,
      'sync' => Icons.sync,
      _ => Icons.notifications_outlined,
    };
  }

  Color _notificationColor(String? type) {
    return switch (type) {
      'low_stock' => AlhaiColors.warning,
      'order' => AlhaiColors.info,
      'shift' => AlhaiColors.success,
      'refund' => AlhaiColors.error,
      'sync' => AlhaiColors.success,
      _ => AlhaiColors.primary,
    };
  }

  Widget _buildNotificationTile(BuildContext context,
      NotificationsTableData notification, bool isDark, WidgetRef ref) {
    final color = _notificationColor(notification.type);
    final icon = _notificationIcon(notification.type);
    final time =
        '${notification.createdAt.hour.toString().padLeft(2, '0')}:${notification.createdAt.minute.toString().padLeft(2, '0')}';

    return GestureDetector(
      onTap: () async {
        if (!notification.isRead) {
          final db = GetIt.I<AppDatabase>();
          await db.notificationsDao.markAsRead(notification.id);
          ref.invalidate(liteNotificationsProvider);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AlhaiSpacing.xs),
        padding: const EdgeInsets.all(AlhaiSpacing.sm),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white
                  .withValues(alpha: notification.isRead ? 0.04 : 0.08)
              : (notification.isRead
                  ? Theme.of(context).colorScheme.surface
                  : color.withValues(alpha: 0.04)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: isDark
                  ? Colors.white12
                  : Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: AlhaiSpacing.avatarMd,
              height: AlhaiSpacing.avatarMd,
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: AlhaiSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notification.title,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: notification.isRead
                              ? FontWeight.normal
                              : FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface)),
                  const SizedBox(height: AlhaiSpacing.xxxs),
                  Text(notification.body,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? Colors.white38
                              : Theme.of(context).colorScheme.onSurfaceVariant),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: AlhaiSpacing.xxs),
                  Text(time,
                      style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.outline)),
                ],
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: AlhaiSpacing.xxs),
                decoration: BoxDecoration(
                    color: AlhaiColors.primary, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }
}
