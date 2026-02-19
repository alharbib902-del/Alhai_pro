import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/layout/app_sidebar.dart';
import '../../widgets/layout/app_header.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/router/routes.dart';

/// شاشة الإشعارات
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _sidebarCollapsed = false;
  String _selectedNavId = 'dashboard';

  final List<_Notification> _notifications = [
    _Notification(id: '1', type: 'order', title: 'طلب جديد', message: 'لديك طلب جديد #2024-050 بقيمة 450 ر.س', time: DateTime.now().subtract(const Duration(minutes: 5)), read: false),
    _Notification(id: '2', type: 'inventory', title: 'تنبيه مخزون', message: 'أرز بسمتي - الكمية منخفضة (3 وحدات)', time: DateTime.now().subtract(const Duration(minutes: 30)), read: false),
    _Notification(id: '3', type: 'payment', title: 'دفعة مستلمة', message: 'تم استلام 1,500 ر.س من أحمد محمد', time: DateTime.now().subtract(const Duration(hours: 2)), read: true),
    _Notification(id: '4', type: 'system', title: 'تحديث النظام', message: 'تم تحديث التطبيق إلى الإصدار 2.1.0', time: DateTime.now().subtract(const Duration(hours: 5)), read: true),
    _Notification(id: '5', type: 'expiry', title: 'منتج قريب الانتهاء', message: 'حليب طازج - ينتهي خلال 3 أيام', time: DateTime.now().subtract(const Duration(days: 1)), read: true),
    _Notification(id: '6', type: 'order', title: 'طلب مكتمل', message: 'تم توصيل الطلب #2024-045 بنجاح', time: DateTime.now().subtract(const Duration(days: 1)), read: true),
  ];

  void _handleNavigation(AppSidebarItem item) {
    setState(() => _selectedNavId = item.id);
    switch (item.id) {
      case 'dashboard': context.go(AppRoutes.dashboard); break;
      case 'pos': context.go(AppRoutes.pos); break;
      case 'products': context.push(AppRoutes.products); break;
      case 'categories': context.push(AppRoutes.categories); break;
      case 'inventory': context.push(AppRoutes.inventory); break;
      case 'customers': context.push(AppRoutes.customers); break;
      case 'invoices': context.push(AppRoutes.invoices); break;
      case 'orders': context.push(AppRoutes.orders); break;
      case 'sales': context.push(AppRoutes.invoices); break;
      case 'returns': context.push(AppRoutes.returns); break;
      case 'reports': context.push(AppRoutes.reports); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isMediumScreen = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final unread = _notifications.where((n) => !n.read).length;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : AppColors.backgroundSecondary,
      drawer: isWideScreen ? null : _buildDrawer(l10n),
      body: Row(
        children: [
          if (isWideScreen)
            AppSidebar(
              storeName: l10n.brandName,
              groups: DefaultSidebarItems.getGroups(context),
              selectedId: _selectedNavId,
              onItemTap: _handleNavigation,
              onSettingsTap: () => context.push(AppRoutes.settings),
              onSupportTap: () {},
              onLogoutTap: () => context.go('/login'),
              collapsed: _sidebarCollapsed,
              userName: 'أحمد محمد', // TODO: localize
              userRole: l10n.branchManager,
              onUserTap: () {},
            ),
          Expanded(
            child: Column(
              children: [
                AppHeader(
                  title: 'الإشعارات', // TODO: localize
                  onMenuTap: isWideScreen
                      ? () => setState(() => _sidebarCollapsed = !_sidebarCollapsed)
                      : () => Scaffold.of(context).openDrawer(),
                  onNotificationsTap: () {},
                  notificationsCount: unread,
                  userName: 'أحمد محمد', // TODO: localize
                  userRole: l10n.branchManager,
                  actions: [
                    if (unread > 0)
                      TextButton(
                        onPressed: _markAllRead,
                        child: Text(
                          'قراءة الكل', // TODO: localize
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: isDark ? Colors.white70 : AppColors.textSecondary,
                      ),
                      onSelected: (v) {
                        if (v == 'settings') context.push(AppRoutes.settingsNotifications);
                        if (v == 'clear') setState(() => _notifications.clear());
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'settings', child: Text('إعدادات الإشعارات')), // TODO: localize
                        PopupMenuItem(value: 'clear', child: Text('مسح الكل')), // TODO: localize
                      ],
                    ),
                  ],
                ),
                Expanded(
                  child: _notifications.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.notifications_off, size: 64, color: isDark ? Colors.white24 : Colors.grey.shade400),
                              const SizedBox(height: 16),
                              Text(
                                'لا توجد إشعارات', // TODO: localize
                                style: TextStyle(color: isDark ? Colors.white54 : Colors.grey.shade600),
                              ),
                            ],
                          ),
                        )
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
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.only(left: 16),
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              onDismissed: (_) => setState(() => _notifications.removeAt(index)),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: notification.read
                                      ? (isDark ? const Color(0xFF1E293B) : Colors.white)
                                      : (isDark ? const Color(0xFF1E293B) : AppColors.infoSurface),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: notification.read
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
                                            fontWeight: notification.read ? FontWeight.normal : FontWeight.bold,
                                            color: isDark ? Colors.white : AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      if (!notification.read)
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
                                        notification.message,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark ? Colors.white54 : AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _formatTime(notification.time),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(AppLocalizations l10n) {
    return Drawer(
      child: AppSidebar(
        storeName: l10n.brandName,
        groups: DefaultSidebarItems.getGroups(context),
        selectedId: _selectedNavId,
        onItemTap: (item) {
          Navigator.pop(context);
          _handleNavigation(item);
        },
        onSettingsTap: () {
          Navigator.pop(context);
          context.push(AppRoutes.settings);
        },
        onSupportTap: () => Navigator.pop(context),
        onLogoutTap: () {
          Navigator.pop(context);
          context.go('/login');
        },
        userName: 'أحمد محمد', // TODO: localize
        userRole: l10n.branchManager,
        onUserTap: () => Navigator.pop(context),
      ),
    );
  }

  Color _getColor(String type) => {
    'order': AppColors.info,
    'inventory': AppColors.warning,
    'payment': AppColors.success,
    'system': const Color(0xFF8B5CF6),
    'expiry': AppColors.error,
  }[type] ?? AppColors.textSecondary;

  IconData _getIcon(String type) => {
    'order': Icons.shopping_bag,
    'inventory': Icons.inventory,
    'payment': Icons.payment,
    'system': Icons.system_update,
    'expiry': Icons.timer,
  }[type] ?? Icons.notifications;

  String _formatTime(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة'; // TODO: localize
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة'; // TODO: localize
    return 'منذ ${diff.inDays} يوم'; // TODO: localize
  }

  void _markAllRead() => setState(() {
    for (var n in _notifications) {
      n.read = true;
    }
  });

  void _openNotification(_Notification n) {
    setState(() => n.read = true);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فتح: ${n.title}'))); // TODO: localize
  }
}

class _Notification {
  final String id, type, title, message;
  final DateTime time;
  bool read;
  _Notification({required this.id, required this.type, required this.title, required this.message, required this.time, required this.read});
}
