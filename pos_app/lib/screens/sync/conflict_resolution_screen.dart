import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/layout/app_sidebar.dart';
import '../../widgets/layout/app_header.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/router/routes.dart';

/// شاشة حل التعارضات في المزامنة
class ConflictResolutionScreen extends ConsumerStatefulWidget {
  const ConflictResolutionScreen({super.key});

  @override
  ConsumerState<ConflictResolutionScreen> createState() => _ConflictResolutionScreenState();
}

class _ConflictResolutionScreenState extends ConsumerState<ConflictResolutionScreen> {
  bool _sidebarCollapsed = false;
  String _selectedNavId = 'dashboard';

  final List<_Conflict> _conflicts = [
    _Conflict(
      id: '1',
      type: 'product',
      description: 'تعارض في سعر المنتج',
      localValue: '25.00 ر.س',
      serverValue: '27.50 ر.س',
      localTime: DateTime.now().subtract(const Duration(hours: 2)),
      serverTime: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    _Conflict(
      id: '2',
      type: 'stock',
      description: 'تعارض في كمية المخزون',
      localValue: '45 قطعة',
      serverValue: '42 قطعة',
      localTime: DateTime.now().subtract(const Duration(hours: 3)),
      serverTime: DateTime.now().subtract(const Duration(hours: 2)),
    ),
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
                  title: 'حل التعارضات', // TODO: localize
                  onMenuTap: isWideScreen
                      ? () => setState(() => _sidebarCollapsed = !_sidebarCollapsed)
                      : () => Scaffold.of(context).openDrawer(),
                  onNotificationsTap: () => context.push('/notifications'),
                  notificationsCount: 3,
                  userName: 'أحمد محمد', // TODO: localize
                  userRole: l10n.branchManager,
                ),
                Expanded(
                  child: _conflicts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle, size: 64, color: isDark ? Colors.white24 : AppColors.success),
                              const SizedBox(height: 16),
                              Text(
                                'لا توجد تعارضات', // TODO: localize
                                style: TextStyle(color: isDark ? Colors.white54 : AppColors.textSecondary, fontSize: 16),
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
                          child: _buildContent(isWideScreen, isMediumScreen, isDark, l10n),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isWideScreen, bool isMediumScreen, bool isDark, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Warning header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.error.withValues(alpha: 0.1) : AppColors.errorSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.error),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_conflicts.length} تعارضات تحتاج حل', // TODO: localize
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'اختر القيمة الصحيحة لكل تعارض', // TODO: localize
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Conflicts list
        ...List.generate(_conflicts.length, (index) {
          final conflict = _conflicts[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      conflict.type == 'product' ? Icons.inventory : Icons.storage,
                      color: isDark ? Colors.white54 : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        conflict.description,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Local value
                _ConflictOption(
                  title: 'القيمة المحلية', // TODO: localize
                  value: conflict.localValue,
                  time: conflict.localTime,
                  color: AppColors.warning,
                  isDark: isDark,
                  onSelect: () => _resolveConflict(conflict, 'local'),
                ),
                const SizedBox(height: 8),

                // Server value
                _ConflictOption(
                  title: 'القيمة من السيرفر', // TODO: localize
                  value: conflict.serverValue,
                  time: conflict.serverTime,
                  color: AppColors.info,
                  isDark: isDark,
                  onSelect: () => _resolveConflict(conflict, 'server'),
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 8),

        // Quick actions
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _resolveAll('local'),
                child: const Text('استخدام الكل المحلي'), // TODO: localize
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () => _resolveAll('server'),
                child: const Text('استخدام الكل من السيرفر'), // TODO: localize
              ),
            ),
          ],
        ),
      ],
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

  void _resolveConflict(_Conflict conflict, String choice) {
    setState(() => _conflicts.remove(conflict));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم حل التعارض باستخدام القيمة ${choice == 'local' ? 'المحلية' : 'من السيرفر'}'), // TODO: localize
        backgroundColor: Colors.green,
      ),
    );
  }

  void _resolveAll(String choice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('استخدام ${choice == 'local' ? 'القيم المحلية' : 'قيم السيرفر'}'), // TODO: localize
        content: Text('سيتم تطبيق ${choice == 'local' ? 'القيم المحلية' : 'قيم السيرفر'} على جميع التعارضات'), // TODO: localize
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')), // TODO: localize
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _conflicts.clear());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم حل جميع التعارضات'), backgroundColor: Colors.green), // TODO: localize
              );
            },
            child: const Text('تأكيد'), // TODO: localize
          ),
        ],
      ),
    );
  }
}

class _Conflict {
  final String id;
  final String type;
  final String description;
  final String localValue;
  final String serverValue;
  final DateTime localTime;
  final DateTime serverTime;

  _Conflict({
    required this.id,
    required this.type,
    required this.description,
    required this.localValue,
    required this.serverValue,
    required this.localTime,
    required this.serverTime,
  });
}

class _ConflictOption extends StatelessWidget {
  final String title;
  final String value;
  final DateTime time;
  final Color color;
  final bool isDark;
  final VoidCallback onSelect;

  const _ConflictOption({
    required this.title,
    required this.value,
    required this.time,
    required this.color,
    required this.isDark,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.radio_button_unchecked, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white54 : AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(fontWeight: FontWeight.bold, color: color),
                  ),
                ],
              ),
            ),
            Text(
              '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white38 : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
