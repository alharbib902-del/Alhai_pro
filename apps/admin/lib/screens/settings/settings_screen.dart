import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_auth/alhai_auth.dart' show authStateProvider;
import 'package:alhai_design_system/alhai_design_system.dart';

/// Provider for store info
final _storeInfoProvider = FutureProvider.autoDispose<StoresTableData?>((
  ref,
) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return null;
  final db = getIt<AppDatabase>();
  return db.storesDao.getStoreById(storeId);
});

/// Provider for pending sync count
final _syncPendingCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final db = getIt<AppDatabase>();
  return db.syncQueueDao.getPendingCount();
});

/// شاشة الإعدادات الرئيسية - بتصميم Sidebar + Header
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width >= 1200;
    final isMediumScreen = size.width >= 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final padding = size.width < 600
        ? 12.0
        : isWideScreen
        ? 24.0
        : 16.0;

    // Get real user data from auth state
    final authState = ref.watch(authStateProvider);
    final user = authState.user;
    final userName = user?.name ?? l10n.defaultUserName;
    final userRole = (user?.role ?? l10n.branchManager).toString();

    // Get store info
    final storeAsync = ref.watch(_storeInfoProvider);
    final storeName = storeAsync.valueOrNull?.name;

    // Get sync pending count
    final syncCount = ref.watch(_syncPendingCountProvider).valueOrNull ?? 0;

    return SafeArea(
      child: Column(
        children: [
          AppHeader(
            title: storeName ?? l10n.settings,
            onMenuTap: isWideScreen
                ? null
                : () => Scaffold.of(context).openDrawer(),
            onNotificationsTap: () => context.push('/notifications'),
            notificationsCount: syncCount,
            userName: userName,
            userRole: userRole,
          ),
          Expanded(
            child: storeAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(AlhaiSpacing.xl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 64,
                        color: isDark
                            ? Colors.white38
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(height: AlhaiSpacing.md),
                      Text(
                        '\u062D\u062F\u062B \u062E\u0637\u0623 \u0641\u064A \u062A\u062D\u0645\u064A\u0644 \u0627\u0644\u0625\u0639\u062F\u0627\u062F\u0627\u062A',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AlhaiSpacing.md),
                      FilledButton.icon(
                        onPressed: () => ref.invalidate(_storeInfoProvider),
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text(l10n.retry),
                      ),
                    ],
                  ),
                ),
              ),
              data: (_) => SingleChildScrollView(
                padding: EdgeInsets.all(padding),
                child: _buildContent(
                  context,
                  isWideScreen,
                  isMediumScreen,
                  isDark,
                  l10n,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    bool isWideScreen,
    bool isMediumScreen,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final crossAxisCount = isWideScreen
        ? 4
        : isMediumScreen
        ? 3
        : 2;

    final categories = _getSettingsCategories(context, isDark, l10n);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Row
        Padding(
          padding: const EdgeInsets.only(bottom: AlhaiSpacing.mdl),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.settings_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.settings,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    '\u0625\u0639\u062F\u0627\u062F\u0627\u062A \u0627\u0644\u062A\u0637\u0628\u064A\u0642 \u0648\u0627\u0644\u062D\u0633\u0627\u0628',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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
            return _buildSettingCard(context, cat, isDark);
          },
        ),
      ],
    );
  }

  Widget _buildSettingCard(
    BuildContext context,
    _SettingsCategory cat,
    bool isDark,
  ) {
    final adaptedColor = _adaptAccentColor(cat.color, isDark);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: cat.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(AlhaiSpacing.md),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.sm),
                decoration: BoxDecoration(
                  color: adaptedColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(cat.icon, color: adaptedColor, size: 28),
              ),
              const SizedBox(height: AlhaiSpacing.sm),
              Text(
                cat.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (cat.subtitle != null) ...[
                const SizedBox(height: AlhaiSpacing.xxs),
                Text(
                  cat.subtitle!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return [
      _SettingsCategory(
        icon: Icons.store_rounded,
        title: l10n.storeSettings,
        subtitle: l10n.storeInfo,
        color: AppColors.primary,
        onTap: () => context.push(AppRoutes.settingsStore),
      ),
      _SettingsCategory(
        icon: Icons.point_of_sale_rounded,
        title: l10n.posSettings,
        subtitle: 'POS',
        color: AppColors.info,
        onTap: () => context.push(AppRoutes.settingsPos),
      ),
      _SettingsCategory(
        icon: Icons.print_rounded,
        title: l10n.printer,
        subtitle:
            '\u0627\u0644\u0637\u0627\u0628\u0639\u0629 \u0627\u0644\u062D\u0631\u0627\u0631\u064A\u0629',
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
        subtitle:
            '\u0627\u0644\u0645\u0627\u0633\u062D \u0627\u0644\u0636\u0648\u0626\u064A',
        color: const Color(0xFFF59E0B),
        onTap: () => context.push(AppRoutes.settingsBarcode),
      ),
      _SettingsCategory(
        icon: Icons.receipt_long_rounded,
        title: l10n.receipt,
        subtitle:
            '\u0642\u0627\u0644\u0628 \u0627\u0644\u0625\u064A\u0635\u0627\u0644',
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
        title: l10n.interestSettings,
        subtitle: l10n.interestSettingsSubtitle,
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
        title: l10n.usersManagement,
        color: AppColors.info,
        onTap: () => context.push(AppRoutes.settingsUsers),
      ),
      _SettingsCategory(
        icon: Icons.admin_panel_settings_rounded,
        title: l10n.rolesPermissions,
        color: const Color(0xFF7C3AED),
        onTap: () => context.push(AppRoutes.settingsRoles),
      ),
      _SettingsCategory(
        icon: Icons.history_rounded,
        title: l10n.activityLog,
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
        subtitle:
            '\u0627\u0644\u0641\u0648\u062A\u0631\u0629 \u0627\u0644\u0625\u0644\u0643\u062A\u0631\u0648\u0646\u064A\u0629',
        color: AppColors.success,
        onTap: () => context.push(AppRoutes.settingsZatca),
      ),
      _SettingsCategory(
        icon: Icons.chat_rounded,
        title: 'WhatsApp',
        subtitle: 'إدارة الرسائل والقوالب',
        color: const Color(0xFF25D366),
        onTap: () => context.push('/settings/whatsapp'),
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

/// Adjusts accent colors for dark mode readability.
/// Keeps the hue but lightens overly dark or saturated colors in dark mode.
Color _adaptAccentColor(Color color, bool isDark) {
  if (!isDark) return color;
  final hsl = HSLColor.fromColor(color);
  // In dark mode, ensure lightness is at least 0.55 so icons remain visible
  if (hsl.lightness < 0.55) {
    return hsl
        .withLightness(0.55)
        .withSaturation((hsl.saturation * 0.85).clamp(0.0, 1.0))
        .toColor();
  }
  return color;
}
