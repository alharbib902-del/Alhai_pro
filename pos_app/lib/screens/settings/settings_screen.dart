import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/layout/app_sidebar.dart';
import '../../widgets/layout/app_header.dart';

/// شاشة الإعدادات الرئيسية - بتصميم Sidebar + Header
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _sidebarCollapsed = false;
  String _selectedNavId = 'settings';

  void _handleNavigation(AppSidebarItem item) {
    setState(() => _selectedNavId = item.id);
    switch (item.id) {
      case 'dashboard':
        context.go(AppRoutes.dashboard);
        break;
      case 'pos':
        context.go(AppRoutes.pos);
        break;
      case 'products':
        context.push(AppRoutes.products);
        break;
      case 'categories':
        context.push(AppRoutes.categories);
        break;
      case 'inventory':
        context.push(AppRoutes.inventory);
        break;
      case 'customers':
        context.push(AppRoutes.customers);
        break;
      case 'invoices':
        context.push(AppRoutes.invoices);
        break;
      case 'orders':
        context.push(AppRoutes.orders);
        break;
      case 'sales':
        context.push(AppRoutes.invoices);
        break;
      case 'returns':
        context.push(AppRoutes.returns);
        break;
      case 'reports':
        context.push(AppRoutes.reports);
        break;
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
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : AppColors.backgroundSecondary,
      drawer: isWideScreen ? null : _buildDrawer(l10n),
      body: Row(
        children: [
          if (isWideScreen)
            AppSidebar(
              storeName: l10n.brandName,
              groups: DefaultSidebarItems.getGroups(context),
              selectedId: _selectedNavId,
              onItemTap: _handleNavigation,
              onSettingsTap: () {},
              onSupportTap: () {},
              onLogoutTap: () => context.go('/login'),
              collapsed: _sidebarCollapsed,
              userName: '\u0623\u062D\u0645\u062F \u0645\u062D\u0645\u062F',
              userRole: l10n.branchManager,
              onUserTap: () {},
            ),
          Expanded(
            child: Column(
              children: [
                AppHeader(
                  title: l10n.settings,
                  onMenuTap: isWideScreen
                      ? () => setState(
                          () => _sidebarCollapsed = !_sidebarCollapsed)
                      : () => Scaffold.of(context).openDrawer(),
                  onNotificationsTap: () => context.push('/notifications'),
                  notificationsCount: 3,
                  userName:
                      '\u0623\u062D\u0645\u062F \u0645\u062D\u0645\u062F',
                  userRole: l10n.branchManager,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
                    child: _buildContent(
                        isWideScreen, isMediumScreen, isDark, l10n),
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
        onSettingsTap: () => Navigator.pop(context),
        onSupportTap: () => Navigator.pop(context),
        onLogoutTap: () {
          Navigator.pop(context);
          context.go('/login');
        },
        userName: '\u0623\u062D\u0645\u062F \u0645\u062D\u0645\u062F',
        userRole: l10n.branchManager,
        onUserTap: () {},
      ),
    );
  }

  Widget _buildContent(
      bool isWideScreen, bool isMediumScreen, bool isDark, AppLocalizations l10n) {
    final crossAxisCount = isWideScreen
        ? 4
        : isMediumScreen
            ? 3
            : 2;

    final categories = _getSettingsCategories(isDark, l10n);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Row
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.settings_rounded,
                    color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.settings,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '\u0625\u0639\u062F\u0627\u062F\u0627\u062A \u0627\u0644\u062A\u0637\u0628\u064A\u0642 \u0648\u0627\u0644\u062D\u0633\u0627\u0628',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.5)
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Settings Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final cat = categories[index];
            return _buildSettingCard(cat, isDark);
          },
        ),
      ],
    );
  }

  Widget _buildSettingCard(_SettingsCategory cat, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: cat.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : AppColors.border,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cat.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(cat.icon, color: cat.color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                cat.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (cat.subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  cat.subtitle!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.5)
                        : AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<_SettingsCategory> _getSettingsCategories(
      bool isDark, AppLocalizations l10n) {
    return [
      _SettingsCategory(
        icon: Icons.store_rounded,
        title: '\u0627\u0644\u0645\u062A\u062C\u0631',
        subtitle: '\u0627\u0644\u0627\u0633\u0645\u060C \u0627\u0644\u0639\u0646\u0648\u0627\u0646',
        color: AppColors.primary,
        onTap: () => context.push(AppRoutes.settingsStore),
      ),
      _SettingsCategory(
        icon: Icons.point_of_sale_rounded,
        title: '\u0646\u0642\u0637\u0629 \u0627\u0644\u0628\u064A\u0639',
        subtitle: 'POS',
        color: AppColors.info,
        onTap: () => context.push(AppRoutes.settingsPos),
      ),
      _SettingsCategory(
        icon: Icons.print_rounded,
        title: l10n.printer,
        subtitle: '\u0627\u0644\u0637\u0627\u0628\u0639\u0629 \u0627\u0644\u062D\u0631\u0627\u0631\u064A\u0629',
        color: const Color(0xFF8B5CF6),
        onTap: () => context.push(AppRoutes.settingsPrinter),
      ),
      _SettingsCategory(
        icon: Icons.payment_rounded,
        title: '\u0623\u062C\u0647\u0632\u0629 \u0627\u0644\u062F\u0641\u0639',
        subtitle: 'mada, STC Pay',
        color: const Color(0xFF06B6D4),
        onTap: () => context.push(AppRoutes.settingsPaymentDevices),
      ),
      _SettingsCategory(
        icon: Icons.qr_code_scanner_rounded,
        title: l10n.barcode,
        subtitle: '\u0627\u0644\u0645\u0627\u0633\u062D \u0627\u0644\u0636\u0648\u0626\u064A',
        color: const Color(0xFFF59E0B),
        onTap: () => context.push(AppRoutes.settingsBarcode),
      ),
      _SettingsCategory(
        icon: Icons.receipt_long_rounded,
        title: l10n.receipt,
        subtitle: '\u0642\u0627\u0644\u0628 \u0627\u0644\u0625\u064A\u0635\u0627\u0644',
        color: const Color(0xFFEC4899),
        onTap: () => context.push(AppRoutes.settingsReceipt),
      ),
      _SettingsCategory(
        icon: Icons.percent_rounded,
        title: l10n.tax,
        subtitle: 'VAT, ZATCA',
        color: AppColors.success,
        onTap: () => context.push(AppRoutes.settingsTax),
      ),
      _SettingsCategory(
        icon: Icons.local_offer_rounded,
        title: l10n.discount,
        subtitle: '\u0627\u0644\u062E\u0635\u0648\u0645\u0627\u062A',
        color: const Color(0xFFEF4444),
        onTap: () => context.push(AppRoutes.settingsDiscounts),
      ),
      _SettingsCategory(
        icon: Icons.trending_up_rounded,
        title: '\u0627\u0644\u0641\u0648\u0627\u0626\u062F',
        subtitle: '\u0627\u0644\u062F\u064A\u0648\u0646 \u0627\u0644\u0622\u062C\u0644\u0629',
        color: const Color(0xFFF97316),
        onTap: () => context.push(AppRoutes.settingsInterest),
      ),
      _SettingsCategory(
        icon: Icons.language_rounded,
        title: l10n.language,
        color: const Color(0xFF14B8A6),
        onTap: () => context.push(AppRoutes.settingsLanguage),
      ),
      _SettingsCategory(
        icon: Icons.palette_rounded,
        title: l10n.theme,
        color: const Color(0xFF8B5CF6),
        onTap: () => context.push(AppRoutes.settingsTheme),
      ),
      _SettingsCategory(
        icon: Icons.security_rounded,
        title: l10n.security,
        color: const Color(0xFFEF4444),
        onTap: () => context.push(AppRoutes.settingsSecurity),
      ),
      _SettingsCategory(
        icon: Icons.people_rounded,
        title: '\u0627\u0644\u0645\u0633\u062A\u062E\u062F\u0645\u064A\u0646',
        color: AppColors.info,
        onTap: () => context.push(AppRoutes.settingsUsers),
      ),
      _SettingsCategory(
        icon: Icons.admin_panel_settings_rounded,
        title: '\u0627\u0644\u0635\u0644\u0627\u062D\u064A\u0627\u062A',
        color: const Color(0xFF7C3AED),
        onTap: () => context.push(AppRoutes.settingsRoles),
      ),
      _SettingsCategory(
        icon: Icons.history_rounded,
        title: '\u0633\u062C\u0644 \u0627\u0644\u0646\u0634\u0627\u0637',
        color: AppColors.textSecondary,
        onTap: () => context.push(AppRoutes.settingsActivityLog),
      ),
      _SettingsCategory(
        icon: Icons.backup_rounded,
        title: l10n.backup,
        color: const Color(0xFF06B6D4),
        onTap: () => context.push(AppRoutes.settingsBackup),
      ),
      _SettingsCategory(
        icon: Icons.notifications_rounded,
        title: l10n.notifications,
        color: const Color(0xFFF59E0B),
        onTap: () => context.push(AppRoutes.settingsNotifications),
      ),
      _SettingsCategory(
        icon: Icons.verified_rounded,
        title: 'ZATCA',
        subtitle: '\u0627\u0644\u0641\u0648\u062A\u0631\u0629 \u0627\u0644\u0625\u0644\u0643\u062A\u0631\u0648\u0646\u064A\u0629',
        color: AppColors.success,
        onTap: () => context.push(AppRoutes.settingsZatca),
      ),
      _SettingsCategory(
        icon: Icons.help_rounded,
        title: l10n.help,
        color: AppColors.textSecondary,
        onTap: () => context.push(AppRoutes.settingsHelp),
      ),
    ];
  }
}

class _SettingsCategory {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color color;
  final VoidCallback onTap;

  const _SettingsCategory({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.color,
    required this.onTap,
  });
}
