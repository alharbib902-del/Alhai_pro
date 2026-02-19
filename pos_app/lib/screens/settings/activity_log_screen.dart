import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/router/routes.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/layout/app_sidebar.dart';
import '../../widgets/layout/app_header.dart';

/// شاشة سجل النشاطات
class ActivityLogScreen extends ConsumerStatefulWidget {
  const ActivityLogScreen({super.key});

  @override
  ConsumerState<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends ConsumerState<ActivityLogScreen> {
  bool _sidebarCollapsed = false;
  String _selectedNavId = 'settings';
  String _selectedFilter = 'all';

  final List<_ActivityItem> _activities = [
    _ActivityItem(
      user: '\u0623\u062d\u0645\u062f \u0645\u062d\u0645\u062f',
      action: '\u062a\u0633\u062c\u064a\u0644 \u062f\u062e\u0648\u0644',
      details: '\u062a\u0645 \u062a\u0633\u062c\u064a\u0644 \u0627\u0644\u062f\u062e\u0648\u0644 \u0628\u0646\u062c\u0627\u062d',
      time: '\u0645\u0646\u0630 5 \u062f\u0642\u0627\u0626\u0642',
      icon: Icons.login_rounded,
      color: AppColors.success,
      type: 'auth',
    ),
    _ActivityItem(
      user: '\u062e\u0627\u0644\u062f \u0639\u0644\u064a',
      action: '\u0628\u064a\u0639 \u0641\u0627\u062a\u0648\u0631\u0629',
      details: '\u0641\u0627\u062a\u0648\u0631\u0629 #1234 - 450.00 \u0631.\u0633',
      time: '\u0645\u0646\u0630 15 \u062f\u0642\u064a\u0642\u0629',
      icon: Icons.receipt_long_rounded,
      color: AppColors.primary,
      type: 'sales',
    ),
    _ActivityItem(
      user: '\u0623\u062d\u0645\u062f \u0645\u062d\u0645\u062f',
      action: '\u062a\u0639\u062f\u064a\u0644 \u0645\u0646\u062a\u062c',
      details: '\u062a\u0645 \u062a\u062d\u062f\u064a\u062b \u0633\u0639\u0631 "\u0623\u0631\u0632 \u0628\u0633\u0645\u062a\u064a"',
      time: '\u0645\u0646\u0630 30 \u062f\u0642\u064a\u0642\u0629',
      icon: Icons.edit_rounded,
      color: AppColors.warning,
      type: 'products',
    ),
    _ActivityItem(
      user: '\u0645\u062d\u0645\u062f \u0633\u0639\u062f',
      action: '\u0627\u0633\u062a\u0631\u062c\u0627\u0639',
      details: '\u0627\u0633\u062a\u0631\u062c\u0627\u0639 \u0641\u0627\u062a\u0648\u0631\u0629 #1230 - 120.00 \u0631.\u0633',
      time: '\u0645\u0646\u0630 \u0633\u0627\u0639\u0629',
      icon: Icons.assignment_return_rounded,
      color: AppColors.error,
      type: 'sales',
    ),
    _ActivityItem(
      user: '\u0623\u062d\u0645\u062f \u0645\u062d\u0645\u062f',
      action: '\u0625\u0636\u0627\u0641\u0629 \u0645\u0633\u062a\u062e\u062f\u0645',
      details: '\u062a\u0645 \u0625\u0636\u0627\u0641\u0629 \u0627\u0644\u0645\u0633\u062a\u062e\u062f\u0645 "\u0641\u0647\u062f \u0639\u0645\u0631"',
      time: '\u0645\u0646\u0630 2 \u0633\u0627\u0639\u0629',
      icon: Icons.person_add_rounded,
      color: AppColors.info,
      type: 'users',
    ),
    _ActivityItem(
      user: '\u062e\u0627\u0644\u062f \u0639\u0644\u064a',
      action: '\u062a\u0633\u062c\u064a\u0644 \u062e\u0631\u0648\u062c',
      details: '\u062a\u0645 \u062a\u0633\u062c\u064a\u0644 \u0627\u0644\u062e\u0631\u0648\u062c',
      time: '\u0645\u0646\u0630 3 \u0633\u0627\u0639\u0627\u062a',
      icon: Icons.logout_rounded,
      color: AppColors.textSecondary,
      type: 'auth',
    ),
    _ActivityItem(
      user: '\u0623\u062d\u0645\u062f \u0645\u062d\u0645\u062f',
      action: '\u0646\u0633\u062e \u0627\u062d\u062a\u064a\u0627\u0637\u064a',
      details: '\u062a\u0645 \u0625\u0646\u0634\u0627\u0621 \u0646\u0633\u062e\u0629 \u0627\u062d\u062a\u064a\u0627\u0637\u064a\u0629 \u064a\u062f\u0648\u064a\u0629',
      time: '\u0645\u0646\u0630 5 \u0633\u0627\u0639\u0627\u062a',
      icon: Icons.backup_rounded,
      color: AppColors.success,
      type: 'system',
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
              userName: '\u0623\u062d\u0645\u062f \u0645\u062d\u0645\u062f',
              userRole: l10n.branchManager,
              onUserTap: () {},
            ),
          Expanded(
            child: Column(
              children: [
                AppHeader(
                  title: l10n.activityLog,
                  onMenuTap: isWideScreen
                      ? () => setState(() => _sidebarCollapsed = !_sidebarCollapsed)
                      : () => Scaffold.of(context).openDrawer(),
                  onNotificationsTap: () => context.push('/notifications'),
                  notificationsCount: 3,
                  userName: '\u0623\u062d\u0645\u062f \u0645\u062d\u0645\u062f',
                  userRole: l10n.branchManager,
                ),
                Expanded(
                  child: SingleChildScrollView(
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

  Widget _buildDrawer(AppLocalizations l10n) {
    return Drawer(
      child: AppSidebar(
        storeName: l10n.brandName,
        groups: DefaultSidebarItems.getGroups(context),
        selectedId: _selectedNavId,
        onItemTap: (item) { Navigator.pop(context); _handleNavigation(item); },
        onSettingsTap: () { Navigator.pop(context); context.push(AppRoutes.settings); },
        onSupportTap: () => Navigator.pop(context),
        onLogoutTap: () { Navigator.pop(context); context.go('/login'); },
        userName: '\u0623\u062d\u0645\u062f \u0645\u062d\u0645\u062f',
        userRole: l10n.branchManager,
        onUserTap: () {},
      ),
    );
  }

  Widget _buildContent(bool isWideScreen, bool isMediumScreen, bool isDark, AppLocalizations l10n) {
    final filtered = _selectedFilter == 'all'
        ? _activities
        : _activities.where((a) => a.type == _selectedFilter).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filters
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            _buildFilterChip('all', '\u0627\u0644\u0643\u0644', isDark),
            const SizedBox(width: 8),
            _buildFilterChip('auth', '\u0627\u0644\u062f\u062e\u0648\u0644/\u0627\u0644\u062e\u0631\u0648\u062c', isDark),
            const SizedBox(width: 8),
            _buildFilterChip('sales', '\u0627\u0644\u0645\u0628\u064a\u0639\u0627\u062a', isDark),
            const SizedBox(width: 8),
            _buildFilterChip('products', '\u0627\u0644\u0645\u0646\u062a\u062c\u0627\u062a', isDark),
            const SizedBox(width: 8),
            _buildFilterChip('users', '\u0627\u0644\u0645\u0633\u062a\u062e\u062f\u0645\u064a\u0646', isDark),
            const SizedBox(width: 8),
            _buildFilterChip('system', '\u0627\u0644\u0646\u0638\u0627\u0645', isDark),
          ]),
        ),
        const SizedBox(height: 20),
        _buildGroup('${l10n.activityLog} (${filtered.length})',
            filtered.map((a) => _buildActivityTile(a, isDark)).toList(), isDark),
      ],
    );
  }

  Widget _buildFilterChip(String filter, String label, bool isDark) {
    final sel = _selectedFilter == filter;
    return FilterChip(
      label: Text(label, style: TextStyle(
        color: sel ? Colors.white : (isDark ? Colors.white : AppColors.textPrimary),
        fontWeight: sel ? FontWeight.bold : FontWeight.normal, fontSize: 12)),
      selected: sel,
      onSelected: (_) => setState(() => _selectedFilter = filter),
      selectedColor: AppColors.primary,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      side: BorderSide(color: sel ? AppColors.primary : (isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
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
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary)),
        ),
        if (children.isEmpty)
          Padding(padding: const EdgeInsets.all(32), child: Center(
            child: Text('\u0644\u0627 \u062a\u0648\u062c\u062f \u0646\u0634\u0627\u0637\u0627\u062a', style: TextStyle(
                color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textSecondary))))
        else ...children,
      ]),
    );
  }

  Widget _buildActivityTile(_ActivityItem a, bool isDark) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: a.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(a.icon, color: a.color, size: 20),
      ),
      title: Row(children: [
        Expanded(child: Text(a.action, style: TextStyle(
            color: isDark ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w500))),
        Text(a.time, style: TextStyle(
            color: isDark ? Colors.white.withValues(alpha: 0.4) : AppColors.textTertiary, fontSize: 11)),
      ]),
      subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(a.details, style: TextStyle(
            color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textSecondary, fontSize: 12)),
        Text(a.user, style: TextStyle(
            color: isDark ? Colors.white.withValues(alpha: 0.3) : AppColors.textTertiary, fontSize: 11)),
      ]),
    );
  }
}

class _ActivityItem {
  final String user, action, details, time, type;
  final IconData icon;
  final Color color;
  _ActivityItem({required this.user, required this.action, required this.details,
      required this.time, required this.icon, required this.color, required this.type});
}
