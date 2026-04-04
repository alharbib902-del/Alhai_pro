/// Lite Settings Screen
///
/// Settings screen for Admin Lite with sections:
/// - Appearance (Language, Theme)
/// - Notifications toggles
/// - Alert Thresholds
/// - Security (PIN management)
/// - App Info
/// Supports RTL, dark mode, and responsive layouts.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_auth/alhai_auth.dart' hide themeProvider;

// =============================================================================
// LOCAL STATE PROVIDERS
// =============================================================================

/// Toggle: Low stock alerts
final _lowStockAlertsProvider = StateProvider<bool>((ref) => true);

/// Toggle: Expiry alerts
final _expiryAlertsProvider = StateProvider<bool>((ref) => true);

/// Toggle: Shift reminders
final _shiftRemindersProvider = StateProvider<bool>((ref) => true);

/// Toggle: Refund notifications
final _refundNotificationsProvider = StateProvider<bool>((ref) => true);

/// Low stock threshold value
final _lowStockThresholdProvider = StateProvider<int>((ref) => 10);

/// Expiry warning days
final _expiryDaysThresholdProvider = StateProvider<int>((ref) => 7);

/// Lite Settings Screen
class LiteSettingsScreen extends ConsumerWidget {
  const LiteSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? AlhaiSpacing.md : AlhaiSpacing.xl,
          vertical: AlhaiSpacing.md,
        ),
        children: [
          // =================================================================
          // APPEARANCE SECTION
          // =================================================================
          _SectionHeader(
              title: l10n.appearance,
              icon: Icons.palette_outlined,
              isDark: isDark),
          const SizedBox(height: AlhaiSpacing.xs),
          _SettingsCard(
            isDark: isDark,
            children: [
              _SettingsTile(
                icon: Icons.language,
                title: l10n.language,
                subtitle: _getCurrentLanguageName(ref),
                isDark: isDark,
                onTap: () => context.go(AppRoutes.settingsLanguage),
              ),
              _SettingsDivider(isDark: isDark),
              _SettingsTile(
                icon: Icons.palette_outlined,
                title: l10n.theme,
                subtitle: _getCurrentThemeName(ref, l10n),
                isDark: isDark,
                onTap: () => context.go(AppRoutes.settingsTheme),
              ),
            ],
          ),

          const SizedBox(height: AlhaiSpacing.lg),

          // =================================================================
          // NOTIFICATIONS SECTION
          // =================================================================
          _SectionHeader(
              title: l10n.notifications,
              icon: Icons.notifications_outlined,
              isDark: isDark),
          const SizedBox(height: AlhaiSpacing.xs),
          _SettingsCard(
            isDark: isDark,
            children: [
              _ToggleTile(
                icon: Icons.inventory_2_outlined,
                title: l10n.lowStock,
                subtitle: l10n.lowStockNotifications,
                isDark: isDark,
                value: ref.watch(_lowStockAlertsProvider),
                onChanged: (v) =>
                    ref.read(_lowStockAlertsProvider.notifier).state = v,
              ),
              _SettingsDivider(isDark: isDark),
              _ToggleTile(
                icon: Icons.calendar_today,
                title: l10n.expiryAlertLabel,
                subtitle: l10n.expiryNotifications,
                isDark: isDark,
                value: ref.watch(_expiryAlertsProvider),
                onChanged: (v) =>
                    ref.read(_expiryAlertsProvider.notifier).state = v,
              ),
              _SettingsDivider(isDark: isDark),
              _ToggleTile(
                icon: Icons.access_time,
                title: l10n.shiftsTitle,
                // TODO(l10n): add key for "Shift open/close reminders"
                subtitle: 'Shift open/close reminders',
                isDark: isDark,
                value: ref.watch(_shiftRemindersProvider),
                onChanged: (v) =>
                    ref.read(_shiftRemindersProvider.notifier).state = v,
              ),
              _SettingsDivider(isDark: isDark),
              _ToggleTile(
                icon: Icons.receipt_long,
                title: l10n.returns,
                subtitle: l10n.refundRequestTitle,
                isDark: isDark,
                value: ref.watch(_refundNotificationsProvider),
                onChanged: (v) =>
                    ref.read(_refundNotificationsProvider.notifier).state = v,
              ),
            ],
          ),

          const SizedBox(height: AlhaiSpacing.lg),

          // =================================================================
          // ALERT THRESHOLDS SECTION
          // =================================================================
          _SectionHeader(
              title: l10n.alerts, icon: Icons.tune_rounded, isDark: isDark),
          const SizedBox(height: AlhaiSpacing.xs),
          _SettingsCard(
            isDark: isDark,
            children: [
              _ThresholdTile(
                icon: Icons.inventory_2_outlined,
                title: l10n.lowStock,
                value: ref.watch(_lowStockThresholdProvider),
                unit: l10n.units,
                isDark: isDark,
                onDecrease: () {
                  final v = ref.read(_lowStockThresholdProvider);
                  if (v > 1)
                    ref.read(_lowStockThresholdProvider.notifier).state = v - 1;
                },
                onIncrease: () {
                  final v = ref.read(_lowStockThresholdProvider);
                  ref.read(_lowStockThresholdProvider.notifier).state = v + 1;
                },
              ),
              _SettingsDivider(isDark: isDark),
              _ThresholdTile(
                icon: Icons.calendar_today,
                title: l10n.expiryAlertLabel,
                value: ref.watch(_expiryDaysThresholdProvider),
                unit: l10n.days,
                isDark: isDark,
                onDecrease: () {
                  final v = ref.read(_expiryDaysThresholdProvider);
                  if (v > 1)
                    ref.read(_expiryDaysThresholdProvider.notifier).state =
                        v - 1;
                },
                onIncrease: () {
                  final v = ref.read(_expiryDaysThresholdProvider);
                  ref.read(_expiryDaysThresholdProvider.notifier).state = v + 1;
                },
              ),
            ],
          ),

          const SizedBox(height: AlhaiSpacing.lg),

          // =================================================================
          // SECURITY SECTION
          // =================================================================
          _SectionHeader(
              title: l10n.security,
              icon: Icons.shield_outlined,
              isDark: isDark),
          const SizedBox(height: AlhaiSpacing.xs),
          _SettingsCard(
            isDark: isDark,
            children: [
              _SettingsTile(
                icon: Icons.lock_outline,
                title: l10n.managerPinSetup,
                // TODO(l10n): add key for "Set or change manager PIN"
                subtitle: l10n.managerPinSetup,
                isDark: isDark,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ManagerApprovalScreen(
                        mode: ManagerApprovalMode.setup,
                      ),
                    ),
                  );
                },
              ),
              _SettingsDivider(isDark: isDark),
              _SettingsTile(
                icon: Icons.sync,
                title: l10n.syncStatusTitle,
                // TODO(l10n): add key for "Data synchronization status"
                subtitle: l10n.syncStatusTitle,
                isDark: isDark,
                onTap: () => context.go(AppRoutes.syncStatus),
              ),
            ],
          ),

          const SizedBox(height: AlhaiSpacing.lg),

          // =================================================================
          // APP INFO SECTION
          // =================================================================
          _SectionHeader(
              title: l10n.about, icon: Icons.info_outline, isDark: isDark),
          const SizedBox(height: AlhaiSpacing.xs),
          _SettingsCard(
            isDark: isDark,
            children: [
              _SettingsTile(
                icon: Icons.admin_panel_settings,
                title: 'Al-HAI Lite',
                subtitle: 'v2.4.0',
                isDark: isDark,
                showArrow: false,
              ),
              _SettingsDivider(isDark: isDark),
              _SettingsTile(
                icon: Icons.description_outlined,
                title: l10n.termsAndConditions,
                subtitle: null,
                isDark: isDark,
                onTap: () {
                  // TODO: Navigate to terms
                },
              ),
              _SettingsDivider(isDark: isDark),
              _SettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: l10n.privacyPolicy,
                subtitle: null,
                isDark: isDark,
                onTap: () {
                  // TODO: Navigate to privacy policy
                },
              ),
            ],
          ),

          const SizedBox(height: AlhaiSpacing.xl),

          // Logout button
          Center(
            child: SizedBox(
              width: isMobile ? double.infinity : 300,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(l10n.logout),
                      content: Text(l10n.logoutConfirmMessage),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text(l10n.cancel),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: FilledButton.styleFrom(
                            backgroundColor: AlhaiColors.error,
                          ),
                          child: Text(l10n.logout),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    ref.read(authStateProvider.notifier).logout();
                    context.go(AppRoutes.login);
                  }
                },
                icon: const Icon(Icons.logout, color: AlhaiColors.error),
                label: Text(
                  l10n.logout,
                  style: const TextStyle(color: AlhaiColors.error),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AlhaiColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: AlhaiSpacing.lg),
        ],
      ),
    );
  }

  String _getCurrentLanguageName(WidgetRef ref) {
    final localeState = ref.watch(localeProvider);
    switch (localeState.locale.languageCode) {
      case 'ar':
        return 'العربية';
      case 'en':
        return 'English';
      case 'hi':
        return 'हिंदी';
      case 'bn':
        return 'বাংলা';
      case 'id':
        return 'Indonesia';
      case 'tl':
        return 'Filipino';
      case 'ur':
        return 'اردو';
      default:
        return localeState.locale.languageCode;
    }
  }

  String _getCurrentThemeName(WidgetRef ref, AppLocalizations l10n) {
    final themeState = ref.watch(themeProvider);
    switch (themeState.themeMode) {
      case ThemeMode.dark:
        return l10n.nightMode;
      case ThemeMode.light:
        return l10n.dayMode;
      case ThemeMode.system:
        return l10n.systemMode;
    }
  }
}

// =============================================================================
// SECTION HEADER
// =============================================================================

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isDark;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AlhaiColors.primary),
        const SizedBox(width: AlhaiSpacing.xs),
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isDark
                ? Colors.white70
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// SETTINGS CARD
// =============================================================================

class _SettingsCard extends StatelessWidget {
  final bool isDark;
  final List<Widget> children;

  const _SettingsCard({required this.isDark, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white12
              : Theme.of(context).colorScheme.surfaceContainer,
        ),
      ),
      child: Column(children: children),
    );
  }
}

// =============================================================================
// SETTINGS TILE
// =============================================================================

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool isDark;
  final VoidCallback? onTap;
  final bool showArrow;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.isDark,
    this.onTap,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AlhaiSpacing.md, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AlhaiColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: AlhaiColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.white38
                            : Theme.of(context).colorScheme.outline,
                      ),
                    ),
                ],
              ),
            ),
            if (showArrow && onTap != null)
              Icon(
                Icons.chevron_right,
                size: 20,
                color: isDark ? Colors.white24 : Theme.of(context).dividerColor,
              ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// TOGGLE TILE
// =============================================================================

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool isDark;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.isDark,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AlhaiSpacing.md, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AlhaiColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: AlhaiColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? Colors.white38
                          : Theme.of(context).colorScheme.outline,
                    ),
                  ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AlhaiColors.primary,
            activeThumbColor: isDark ? Colors.black : Colors.white,
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// THRESHOLD TILE
// =============================================================================

class _ThresholdTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final int value;
  final String unit;
  final bool isDark;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const _ThresholdTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.unit,
    required this.isDark,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AlhaiSpacing.md, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AlhaiColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: AlhaiColors.warning),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          // Stepper control
          Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Decrease',
                  onPressed: onDecrease,
                  icon: const Icon(Icons.remove, size: 16),
                  constraints:
                      const BoxConstraints(minWidth: 36, minHeight: 36),
                  padding: EdgeInsets.zero,
                  color: isDark
                      ? Colors.white54
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AlhaiSpacing.xxs),
                  child: Text(
                    '$value $unit',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Increase',
                  onPressed: onIncrease,
                  icon: const Icon(Icons.add, size: 16),
                  constraints:
                      const BoxConstraints(minWidth: 36, minHeight: 36),
                  padding: EdgeInsets.zero,
                  color: isDark
                      ? Colors.white54
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SETTINGS DIVIDER
// =============================================================================

class _SettingsDivider extends StatelessWidget {
  final bool isDark;

  const _SettingsDivider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 66,
      color: isDark
          ? Colors.white.withValues(alpha: 0.06)
          : Theme.of(context).colorScheme.surfaceContainerLow,
    );
  }
}
