/// Cashier Settings Screen - Main settings hub
///
/// Grid/list of setting categories with icons. Each tile navigates
/// to its sub-screen. Supports: RTL Arabic, dark/light theme, responsive.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_pos/alhai_pos.dart' show cartHapticsEnabled;
import '../../core/constants/timing.dart';
import '../../core/utils/cache_cleaner.dart';
import '../../core/services/haptic_shim.dart';
import '../../core/services/sound_service.dart';
import '../../main.dart'
    show kPrefHapticEnabled, kPrefSoundEnabled, kPrefSoundVolume;
// Phase 4.4 / 4.5 — animation + keyboard-shortcut toggle keys live with the
// router (animations) and an app-level shim (shortcuts). Imported here so
// the settings UI is the single source of truth that mutates them.
import '../../router/cashier_router.dart'
    show kPrefAnimationsEnabled, refreshAnimationsFlag;
import '../../core/services/shortcuts_shim.dart'
    show ShortcutsShim, kPrefKeyboardShortcutsEnabled;
import 'package:alhai_design_system/alhai_design_system.dart'
    show AlhaiBreakpoints, AlhaiSnackbar, AlhaiSpacing;
// alhai_design_system is re-exported via alhai_shared_ui

/// Main settings hub screen
class CashierSettingsScreen extends ConsumerStatefulWidget {
  const CashierSettingsScreen({super.key});

  @override
  ConsumerState<CashierSettingsScreen> createState() =>
      _CashierSettingsScreenState();
}

class _CashierSettingsScreenState extends ConsumerState<CashierSettingsScreen> {
  // Phase 2 §2.5/2.6 — Feedback section state. Loaded from SharedPreferences
  // via [_loadFeedbackPrefs]; mirrored back on every toggle.
  bool _hapticEnabled = true;
  bool _soundEnabled = true;
  double _soundVolume = 0.8;
  bool _feedbackLoaded = false;

  // Phase 4.4 / 4.5 — Appearance / input preferences. Loaded together with
  // the feedback block so the whole settings screen renders in one pass.
  bool _animationsEnabled = true;
  bool _shortcutsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadFeedbackPrefs();
  }

  Future<void> _loadFeedbackPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _hapticEnabled = prefs.getBool(kPrefHapticEnabled) ?? true;
      _soundEnabled = prefs.getBool(kPrefSoundEnabled) ?? true;
      _soundVolume = prefs.getDouble(kPrefSoundVolume) ?? 0.8;
      // Phase 4.4 / 4.5 — read with the same defaults we use at app boot
      // (both ON) so the UI does not flip briefly during first paint.
      _animationsEnabled = prefs.getBool(kPrefAnimationsEnabled) ?? true;
      _shortcutsEnabled =
          prefs.getBool(kPrefKeyboardShortcutsEnabled) ?? true;
      _feedbackLoaded = true;
    });
  }

  /// Phase 4.4 — Persist the animations toggle, then refresh the router's
  /// in-memory flag so subsequent navigations use the new duration.
  Future<void> _setAnimationsEnabled(bool v) async {
    setState(() => _animationsEnabled = v);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kPrefAnimationsEnabled, v);
    await refreshAnimationsFlag();
  }

  /// Phase 4.5 — Persist the keyboard-shortcuts toggle and mirror the flag
  /// into [ShortcutsShim] so the shell/POS bindings go dormant immediately.
  Future<void> _setShortcutsEnabled(bool v) async {
    setState(() => _shortcutsEnabled = v);
    ShortcutsShim.enabled = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kPrefKeyboardShortcutsEnabled, v);
  }

  Future<void> _setHapticEnabled(bool v) async {
    setState(() => _hapticEnabled = v);
    HapticShim.enabled = v;
    cartHapticsEnabled = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kPrefHapticEnabled, v);
    if (v) HapticShim.selectionClick(); // tiny confirmation tick
  }

  Future<void> _setSoundEnabled(bool v) async {
    setState(() => _soundEnabled = v);
    SoundService.instance.enabled = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kPrefSoundEnabled, v);
    if (v) SoundService.instance.barcodeBeep();
  }

  Future<void> _setSoundVolume(double v) async {
    setState(() => _soundVolume = v);
    await SoundService.instance.setVolume(v);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(kPrefSoundVolume, v);
  }

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildGridWithCacheClear(
                  isWideScreen,
                  isMediumScreen,
                  isDark,
                  l10n,
                ),
                const SizedBox(height: AlhaiSpacing.lg),
                _buildAppearanceSection(isDark, l10n),
                const SizedBox(height: AlhaiSpacing.lg),
                _buildFeedbackSection(isDark, l10n),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // APPEARANCE / INPUT SECTION (Phase 4.4 / 4.5)
  //   - Animations toggle: gates all GoRouter page transitions
  //   - Keyboard shortcuts toggle: gates CallbackShortcuts in shell + POS
  // Grouped together because both are "how does the app feel" preferences,
  // distinct from the audio/haptic feedback block below.
  // ============================================================================

  Widget _buildAppearanceSection(bool isDark, AppLocalizations l10n) {
    if (!_feedbackLoaded) {
      return const SizedBox(height: 1);
    }
    final isAr = l10n.localeName == 'ar';
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tune_rounded,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(
                isAr ? 'المظهر والإدخال' : 'Appearance & Input',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const Divider(height: AlhaiSpacing.xl),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            secondary: Icon(
              Icons.animation_rounded,
              color: AppColors.getTextSecondary(isDark),
            ),
            title: Text(
              // Phase 4.4 — intentionally uses a locale-branched literal
              // instead of adding a new AppLocalizations entry. The existing
              // `animationsToggle` ARB key is added in the same commit so
              // future refactors can swap this line for `l10n.animationsToggle`.
              isAr ? 'تأثيرات حركية' : 'Animations',
              style: TextStyle(color: AppColors.getTextPrimary(isDark)),
            ),
            subtitle: Text(
              isAr
                  ? 'تحريك الشاشات والتحولات البصرية'
                  : 'Smooth screen transitions and motion',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.getTextMuted(isDark),
              ),
            ),
            value: _animationsEnabled,
            onChanged: _setAnimationsEnabled,
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            secondary: Icon(
              Icons.keyboard_rounded,
              color: AppColors.getTextSecondary(isDark),
            ),
            title: Text(
              // Phase 4.5 — reuses the existing `keyboardShortcuts` l10n key.
              l10n.keyboardShortcuts,
              style: TextStyle(color: AppColors.getTextPrimary(isDark)),
            ),
            subtitle: Text(
              // Key label — identical in both locales, no branching needed.
              'F1-F8, Ctrl+F/D/P, +/-, Delete',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.getTextMuted(isDark),
              ),
            ),
            value: _shortcutsEnabled,
            onChanged: _setShortcutsEnabled,
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // FEEDBACK SECTION (Phase 2 §2.5/2.6) — haptic + sound toggles
  // ============================================================================

  Widget _buildFeedbackSection(bool isDark, AppLocalizations l10n) {
    if (!_feedbackLoaded) {
      return const SizedBox(height: 1);
    }
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.vibration_rounded,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(
                l10n.localeName == 'ar' ? 'التغذية الراجعة' : 'Feedback',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.sm),
          Text(
            l10n.localeName == 'ar'
                ? 'الاهتزاز والصوت عند الإجراءات (المسح، البيع، الأخطاء)'
                : 'Haptic and sound for key actions (scan, sale, errors)',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.getTextMuted(isDark),
            ),
          ),
          const Divider(height: AlhaiSpacing.xl),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text(
              l10n.localeName == 'ar'
                  ? 'الاهتزاز عند الإجراءات'
                  : 'Haptic on actions',
              style: TextStyle(color: AppColors.getTextPrimary(isDark)),
            ),
            subtitle: Text(
              l10n.localeName == 'ar'
                  ? 'اهتزاز خفيف عند المسح والإضافة، قوي عند إتمام البيع'
                  : 'Light tick on scan/add, strong buzz on sale success',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.getTextMuted(isDark),
              ),
            ),
            value: _hapticEnabled,
            onChanged: _setHapticEnabled,
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text(
              l10n.localeName == 'ar'
                  ? 'أصوات التأكيد'
                  : 'Confirmation sounds',
              style: TextStyle(color: AppColors.getTextPrimary(isDark)),
            ),
            subtitle: Text(
              l10n.localeName == 'ar'
                  ? 'صفير عند المسح، رنّة عند إتمام البيع، نغمة خطأ'
                  : 'Beep on scan, chime on success, buzz on error',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.getTextMuted(isDark),
              ),
            ),
            value: _soundEnabled,
            onChanged: _setSoundEnabled,
          ),
          if (_soundEnabled)
            Padding(
              padding: const EdgeInsets.only(top: AlhaiSpacing.xs),
              child: Row(
                children: [
                  Icon(
                    Icons.volume_down_rounded,
                    size: 18,
                    color: AppColors.getTextMuted(isDark),
                  ),
                  Expanded(
                    child: Slider(
                      value: _soundVolume,
                      min: 0.0,
                      max: 1.0,
                      divisions: 10,
                      label: '${(_soundVolume * 100).round()}%',
                      onChanged: _setSoundVolume,
                    ),
                  ),
                  Icon(
                    Icons.volume_up_rounded,
                    size: 18,
                    color: AppColors.getTextMuted(isDark),
                  ),
                  const SizedBox(width: AlhaiSpacing.xs),
                  SizedBox(
                    width: 36,
                    child: Text(
                      '${(_soundVolume * 100).round()}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.getTextMuted(isDark),
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
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
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.onInverseSurface,
                  ),
                ),
                const SizedBox(width: AlhaiSpacing.sm),
                Text(l10n.clearingCacheProgress),
              ],
            ),
            duration: Timeouts.snackbarDuration,
          ),
        );
      }

      // Clear all web storage (IndexedDB, localStorage, caches, SW)
      await clearAllWebCache();

      // Wait briefly then reload
      await Future.delayed(Timeouts.reloadDelay);
      reloadPage();
    } catch (e) {
      if (mounted) {
        AlhaiSnackbar.error(context, l10n.errorMsgGeneric('$e'));
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
    return Semantics(
      label: '${widget.title}: ${widget.subtitle}',
      button: true,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: AnimationDurations.standard,
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
      ),
    );
  }
}
