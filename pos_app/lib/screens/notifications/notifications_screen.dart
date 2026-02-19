import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/layout/app_header.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/router/routes.dart';
import '../../data/local/app_database.dart';
import '../../di/injection.dart';
import '../../providers/products_providers.dart';
import '../../widgets/common/app_empty_state.dart';

/// شاشة الإشعارات
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  List<NotificationsTableData> _notifications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;
      final db = getIt<AppDatabase>();
      final notifications = await db.notificationsDao.getAllNotifications(storeId);
      if (mounted) {
        setState(() {
          _notifications = notifications;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; _error = e.toString(); });
    }
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isMediumScreen = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final unread = _notifications.where((n) => !n.isRead).length;

    return Column(
              children: [
                AppHeader(
                  title: l10n.notifications,
                  onMenuTap: isWideScreen
                      ? null
                      : () => Scaffold.of(context).openDrawer(),
                  onNotificationsTap: () {},
                  notificationsCount: unread,
                  userName: l10n.defaultUserName,
                  userRole: l10n.branchManager,
                  actions: [
                    if (unread > 0)
                      TextButton(
                        onPressed: _markAllRead,
                        child: Text(
                          l10n.readAll,
                          style: const TextStyle(color: AppColors.primary),
                        ),
                      ),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: isDark ? Colors.white70 : AppColors.textSecondary,
                      ),
                      onSelected: (v) {
                        if (v == 'settings') context.push(AppRoutes.settingsNotifications);
                        if (v == 'clear') {
                          setState(() => _notifications = []);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(value: 'settings', child: Text(l10n.notificationSettings)),
                        PopupMenuItem(value: 'clear', child: Text(l10n.clearAll)),
                      ],
                    ),
                  ],
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null
                      ? AppErrorState.general(message: _error, onRetry: _loadData)
                      : _notifications.isEmpty
                      ? AppEmptyState.noNotifications()
                      : ListView.builder(
                          padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
                          itemCount: _notifications.length,
                          itemBuilder: (context, index) {
                            final notification = _notifications[index];
                            return Dismissible(
                              key: Key(notification.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.error,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: AlignmentDirectional.centerStart,
                                padding: const EdgeInsetsDirectional.only(start: 16),
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              onDismissed: (_) async {
                                try {
                                  final db = getIt<AppDatabase>();
                                  await db.notificationsDao.deleteNotification(notification.id);
                                } catch (_) {}
                                setState(() => _notifications.removeAt(index));
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: notification.isRead
                                      ? (isDark ? const Color(0xFF1E293B) : Colors.white)
                                      : (isDark ? const Color(0xFF1E293B) : AppColors.infoSurface),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: notification.isRead
                                        ? (isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border)
                                        : AppColors.info.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  leading: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: _getColor(notification.type).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(_getIcon(notification.type), color: _getColor(notification.type)),
                                  ),
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          notification.title,
                                          style: TextStyle(
                                            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                                            color: isDark ? Colors.white : AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      if (!notification.isRead)
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(color: AppColors.info, shape: BoxShape.circle),
                                        ),
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text(
                                        notification.body,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark ? Colors.white54 : AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _formatTime(notification.createdAt),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isDark ? Colors.white38 : AppColors.textTertiary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  onTap: () => _openNotification(notification),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
  }
  Color _getColor(String type) => {
    'info': AppColors.info,
    'warning': AppColors.warning,
    'error': AppColors.error,
    'success': AppColors.success,
  }[type] ?? AppColors.textSecondary;

  IconData _getIcon(String type) => {
    'info': Icons.info,
    'warning': Icons.warning,
    'error': Icons.error,
    'success': Icons.check_circle,
  }[type] ?? Icons.notifications;

  String _formatTime(DateTime d) {
    final l10n = AppLocalizations.of(context)!;
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 60) return l10n.minutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.hoursAgo(diff.inHours);
    return l10n.daysAgo(diff.inDays);
  }

  Future<void> _markAllRead() async {
    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;
      final db = getIt<AppDatabase>();
      await db.notificationsDao.markAllAsRead(storeId);
      await _loadData();
    } catch (_) {}
  }

  Future<void> _openNotification(NotificationsTableData n) async {
    try {
      if (!n.isRead) {
        final db = getIt<AppDatabase>();
        await db.notificationsDao.markAsRead(n.id);
        await _loadData();
      }
    } catch (_) {}
    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l10n.openedNotification}: ${n.title}')));
    }
  }
}
