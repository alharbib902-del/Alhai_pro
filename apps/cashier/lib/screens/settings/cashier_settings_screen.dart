/// Cashier Settings Screen - Main settings hub
///
/// Grid/list of setting categories with icons. Each tile navigates
/// to its sub-screen. Supports: RTL Arabic, dark/light theme, responsive.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_auth/alhai_auth.dart';
import '../../core/utils/cache_cleaner.dart';
import 'package:alhai_design_system/alhai_design_system.dart'
    show AlhaiBreakpoints, AlhaiSpacing;
// alhai_design_system is re-exported via alhai_shared_ui

/// Main settings hub screen
class CashierSettingsScreen extends ConsumerStatefulWidget {
  const CashierSettingsScreen({super.key});

  @override
  ConsumerState<CashierSettingsScreen> createState() =>
      _CashierSettingsScreenState();
}

class _CashierSettingsScreenState extends ConsumerState<CashierSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width >= AlhaiBreakpoints.desktop;
    final isMediumScreen = size.width >= AlhaiBreakpoints.tablet;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        AppHeader(
          title: l10n.settings,
          subtitle: l10n.managePreferencesSubtitle,
          showSearch: false,
          onMenuTap: isWideScreen
              ? null
              : () => Scaffold.of(context).openDrawer(),
          onNotificationsTap: () => context.push(AppRoutes.notificationsCenter),
          notificationsCount: 0,
          userName: ref.watch(currentUserProvider)?.name ?? l10n.cashCustomer,
          userRole: l10n.cashier,
          onUserTap: () => context.push(AppRoutes.profile),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(
              isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md,
            ),
            child: _buildGridWithCacheClear(
              isWideScreen,
              isMediumScreen,
              isDark,
              l10n,
            ),
          ),
        ),
      ],
    );
  }

  List<_SettingsItem> _buildSettingsItems(AppLocalizations l10n) {
    return [
      _SettingsItem(
        icon: Icons.store_rounded,
        title: l10n.storeInfo,
        subtitle: l10n.storeNameAddressLogo,
        color: AppColors.primary,
        route: AppRoutes.settingsStore,
      ),
      _SettingsItem(
        icon: Icons.receipt_long_rounded,
        title: l10n.taxSettings,
        subtitle: l10n.taxSettingsSubtitle,
        color: AppColors.info,
        route: AppRoutes.settingsTax,
      ),
      _SettingsItem(
        icon: Icons.receipt_rounded,
        title: l10n.receiptSettings,
        subtitle: l10n.receiptHeaderFooterLogo,
        color: AppColors.secondary,
        route: AppRoutes.settingsReceipt,
      ),
      _SettingsItem(
        icon: Icons.payment_rounded,
        title: l10n.paymentDevicesSettings,
        subtitle: l10n.paymentDevicesSubtitle,
        color: AppColors.card,
        route: AppRoutes.settingsPaymentDevices,
      ),
      _SettingsItem(
        icon: Icons.devices_other,
        title: 'الميزات والأجهزة',
        subtitle: 'شاشة العميل، NFC، إعدادات متقدمة',
        color: AppColors.info,
        route: '/settings/features',
      ),
      _SettingsItem(
        icon: Icons.print_rounded,
        title: l10n.printerSettings,
        subtitle: l10n.printerSettingsSubtitle,
        color: AppColors.warning,
        route: AppRoutes.settingsPrinter,
      ),
      _SettingsItem(
        icon: Icons.keyboard_rounded,
        title: l10n.keyboardShortcuts,
        subtitle: l10n.posPaymentNavSubtitle,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        route: AppRoutes.settingsKeyboardShortcuts,
      ),
      _SettingsItem(
        icon: Icons.people_rounded,
        title: l10n.usersAndPermissions,
        subtitle: l10n.rolesAndAccess,
        color: AppColors.credit,
        route: AppRoutes.settingsUsers,
      ),
      _SettingsItem(
        icon: Icons.backup_rounded,
        title: l10n.backup,
        subtitle: l10n.backupAutoRestore,
        color: AppColors.error,
        route: AppRoutes.settingsBackup,
      ),
      _SettingsItem(
        icon: Icons.privacy_tip_rounded,
        title: l10n.privacyPolicy,
        subtitle: l10n.privacyAndDataRights,
        color: AppColors.info,
        route: AppRoutes.settingsPrivacy,
      ),
      _SettingsItem(
        icon: Icons.language_rounded,
        title: l10n.language,
        subtitle: l10n.arabicEnglish,
        color: AppColors.primaryDark,
        route: AppRoutes.settingsLanguage,
      ),
      _SettingsItem(
        icon: Icons.palette_rounded,
        title: l10n.theme,
        subtitle: l10n.darkLightMode,
        color: AppColors.secondaryDark,
        route: AppRoutes.settingsTheme,
      ),
      // Clear cache - special item (route unused, handled by onTap override)
      _SettingsItem(
        icon: Icons.cleaning_services_rounded,
        title: l10n.clearCacheTitle,
        subtitle: l10n.clearCacheSubtitle,
        color: AppColors.error,
        route: '_clear_cache',
      ),
    ];
  }

  // ============================================================================
  // GRID BUILDER (overridden to handle cache clear tap)
  // ============================================================================

  Widget _buildGridWithCacheClear(
    bool isWideScreen,
    bool isMediumScreen,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final items = _buildSettingsItems(l10n);

    final crossAxisCount = isWideScreen
        ? 4
        : isMediumScreen
        ? 3
        : 2;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: isWideScreen ? 1.3 : 1.1,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _SettingsTile(
          icon: item.icon,
          title: item.title,
          subtitle: item.subtitle,
          color: item.color,
          isDark: isDark,
          onTap: item.route == '_clear_cache'
              ? () => _showClearCacheDialog(context)
              : () => context.push(item.route),
        );
      },
    );
  }

  /// Show confirmation dialog then clear all cached data
  Future<void> _showClearCacheDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.error),
            const SizedBox(width: AlhaiSpacing.xs),
            Text(l10n.clearCacheTitle),
          ],
        ),
        content: Text(l10n.clearCacheDialogBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(ctx).pop(true),
            icon: const Icon(Icons.cleaning_services_rounded),
            label: Text(l10n.clearAndRestart),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _clearAllCacheAndReload();
    }
  }

  /// Clear all browser storage and reload
  Future<void> _clearAllCacheAndReload() async {
    final l10n = AppLocalizations.of(context);
    try {
      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: AlhaiSpacing.sm),
                Text(l10n.clearingCacheProgress),
              ],
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }

      // Clear all web storage (IndexedDB, localStorage, caches, SW)
      await clearAllWebCache();

      // Wait briefly then reload
      await Future.delayed(const Duration(milliseconds: 500));
      reloadPage();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorMsgGeneric('$e')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

/// Data class for a settings item
class _SettingsItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String route;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.route,
  });
}

/// Individual settings tile widget
class _SettingsTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_SettingsTile> createState() => _SettingsTileState();
}

class _SettingsTileState extends State<_SettingsTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(AlhaiSpacing.mdl),
          decoration: BoxDecoration(
            color: _isHovered
                ? widget.color.withValues(alpha: widget.isDark ? 0.15 : 0.06)
                : AppColors.getSurface(widget.isDark),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered
                  ? widget.color.withValues(alpha: 0.4)
                  : AppColors.getBorder(widget.isDark),
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: widget.color.withValues(
                    alpha: widget.isDark ? 0.2 : 0.1,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(widget.icon, color: widget.color, size: 26),
              ),
              const SizedBox(height: 14),
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(widget.isDark),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AlhaiSpacing.xxs),
              Text(
                widget.subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.getTextMuted(widget.isDark),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
