import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/router/routes.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/layout/app_sidebar.dart';
import '../../widgets/layout/app_header.dart';

/// شاشة إعدادات الإشعارات
class NotificationsSettingsScreen extends ConsumerStatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  ConsumerState<NotificationsSettingsScreen> createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends ConsumerState<NotificationsSettingsScreen> {
  bool _sidebarCollapsed = false;
  String _selectedNavId = 'settings';

  bool _pushEnabled = true;
  bool _emailEnabled = false;
  bool _smsEnabled = false;
  bool _salesAlerts = true;
  bool _inventoryAlerts = true;
  bool _securityAlerts = true;
  bool _reportAlerts = false;

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
      body: Row(children: [
        if (isWideScreen)
          AppSidebar(
            storeName: l10n.brandName, groups: DefaultSidebarItems.getGroups(context),
            selectedId: _selectedNavId, onItemTap: _handleNavigation,
            onSettingsTap: () => context.push(AppRoutes.settings),
            onSupportTap: () {}, onLogoutTap: () => context.go('/login'),
            collapsed: _sidebarCollapsed, userName: '\u0623\u062d\u0645\u062f \u0645\u062d\u0645\u062f',
            userRole: l10n.branchManager, onUserTap: () {},
          ),
        Expanded(child: Column(children: [
          AppHeader(
            title: l10n.notificationSettings,
            onMenuTap: isWideScreen
                ? () => setState(() => _sidebarCollapsed = !_sidebarCollapsed)
                : () => Scaffold.of(context).openDrawer(),
            onNotificationsTap: () => context.push('/notifications'),
            notificationsCount: 3, userName: '\u0623\u062d\u0645\u062f \u0645\u062d\u0645\u062f', userRole: l10n.branchManager,
          ),
          Expanded(child: SingleChildScrollView(
            padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
            child: _buildContent(isDark, l10n),
          )),
        ])),
      ]),
    );
  }

  Widget _buildDrawer(AppLocalizations l10n) {
    return Drawer(child: AppSidebar(
      storeName: l10n.brandName, groups: DefaultSidebarItems.getGroups(context),
      selectedId: _selectedNavId,
      onItemTap: (item) { Navigator.pop(context); _handleNavigation(item); },
      onSettingsTap: () { Navigator.pop(context); context.push(AppRoutes.settings); },
      onSupportTap: () => Navigator.pop(context),
      onLogoutTap: () { Navigator.pop(context); context.go('/login'); },
      userName: '\u0623\u062d\u0645\u062f \u0645\u062d\u0645\u062f', userRole: l10n.branchManager, onUserTap: () {},
    ));
  }

  Widget _buildContent(bool isDark, AppLocalizations l10n) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Channels
      _buildGroup(l10n.notificationChannels, [
        _switchTile(Icons.notifications_active_rounded, l10n.pushNotifications,
            '\u0625\u0634\u0639\u0627\u0631\u0627\u062a \u0641\u0648\u0631\u064a\u0629 \u0639\u0644\u0649 \u0627\u0644\u062c\u0647\u0627\u0632', _pushEnabled,
            (v) => setState(() => _pushEnabled = v), isDark),
        _switchTile(Icons.email_rounded, l10n.emailNotifications,
            '\u0625\u0631\u0633\u0627\u0644 \u0625\u0634\u0639\u0627\u0631\u0627\u062a \u0639\u0628\u0631 \u0627\u0644\u0628\u0631\u064a\u062f', _emailEnabled,
            (v) => setState(() => _emailEnabled = v), isDark),
        _switchTile(Icons.sms_rounded, l10n.smsNotifications,
            '\u0625\u0634\u0639\u0627\u0631\u0627\u062a \u0639\u0628\u0631 \u0627\u0644\u0631\u0633\u0627\u0626\u0644 \u0627\u0644\u0646\u0635\u064a\u0629', _smsEnabled,
            (v) => setState(() => _smsEnabled = v), isDark),
      ], isDark),

      // Alert types
      _buildGroup(l10n.alertTypes, [
        _switchTile(Icons.receipt_long_rounded, l10n.salesAlerts,
            '\u062a\u0646\u0628\u064a\u0647\u0627\u062a \u0627\u0644\u0645\u0628\u064a\u0639\u0627\u062a \u0648\u0627\u0644\u0641\u0648\u0627\u062a\u064a\u0631', _salesAlerts,
            (v) => setState(() => _salesAlerts = v), isDark),
        _switchTile(Icons.inventory_2_rounded, l10n.inventoryAlerts,
            '\u062a\u0646\u0628\u064a\u0647\u0627\u062a \u0627\u0644\u0645\u062e\u0632\u0648\u0646 \u0627\u0644\u0645\u0646\u062e\u0641\u0636', _inventoryAlerts,
            (v) => setState(() => _inventoryAlerts = v), isDark),
        _switchTile(Icons.security_rounded, l10n.securityAlerts,
            '\u062a\u0646\u0628\u064a\u0647\u0627\u062a \u0627\u0644\u0623\u0645\u0627\u0646 \u0648\u062a\u0633\u062c\u064a\u0644 \u0627\u0644\u062f\u062e\u0648\u0644', _securityAlerts,
            (v) => setState(() => _securityAlerts = v), isDark),
        _switchTile(Icons.analytics_rounded, l10n.reportAlerts,
            '\u062a\u0642\u0627\u0631\u064a\u0631 \u064a\u0648\u0645\u064a\u0629 \u0648\u0623\u0633\u0628\u0648\u0639\u064a\u0629', _reportAlerts,
            (v) => setState(() => _reportAlerts = v), isDark),
      ], isDark),
    ]);
  }

  Widget _buildGroup(String title, List<Widget> children, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary))),
        ...children,
      ]),
    );
  }

  Widget _switchTile(IconData icon, String title, String subtitle, bool value,
      ValueChanged<bool> onChanged, bool isDark) {
    return SwitchListTile(
      secondary: Container(padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: value ? AppColors.primary : AppColors.textSecondary, size: 20)),
      title: Text(title, style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: TextStyle(
          color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textSecondary, fontSize: 12)),
      value: value, onChanged: onChanged,
    );
  }
}
