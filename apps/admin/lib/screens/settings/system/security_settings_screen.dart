import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:alhai_auth/alhai_auth.dart';
import '../../../providers/settings_db_providers.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import '../../../core/services/sentry_service.dart';

// ============================================================================
// PIN ATTEMPT TRACKER - Brute-force protection with exponential backoff
// ============================================================================

/// Tracks consecutive failed PIN attempts and enforces lockout with
/// exponential backoff to prevent brute-force attacks.
///
/// After [maxAttempts] consecutive failures the user is locked out for
/// an exponentially increasing duration: 30s, 60s, 120s, 240s, ...
/// A successful verification resets the counter.
class PinAttemptTracker {
  static int _failedAttempts = 0;
  static DateTime? _lockoutUntil;

  /// Maximum consecutive failures before lockout is enforced.
  static const int maxAttempts = 5;

  /// Whether the user is currently locked out.
  static bool get isLockedOut {
    if (_lockoutUntil == null) return false;
    if (DateTime.now().isAfter(_lockoutUntil!)) {
      // Lockout period has passed — clear it but keep the attempt count
      // so the next failure immediately re-locks with a longer duration.
      _lockoutUntil = null;
      return false;
    }
    return true;
  }

  /// Remaining lockout duration (zero if not locked out).
  static Duration get remainingLockout {
    if (_lockoutUntil == null) return Duration.zero;
    final remaining = _lockoutUntil!.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Human-readable remaining lockout string (e.g. "1:30").
  static String get remainingLockoutDisplay {
    final d = remainingLockout;
    if (d == Duration.zero) return '';
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Record a failed PIN attempt. If the threshold is reached, a lockout
  /// period is calculated using exponential backoff.
  static void recordFailedAttempt() {
    _failedAttempts++;
    if (_failedAttempts >= maxAttempts) {
      // Exponential backoff: 30s, 60s, 120s, 240s ...
      final multiplier = (_failedAttempts ~/ maxAttempts) - 1;
      final lockoutSeconds = 30 * pow(2, multiplier).toInt();
      _lockoutUntil = DateTime.now().add(Duration(seconds: lockoutSeconds));
    }
  }

  /// Reset all tracking state (call on successful PIN verification).
  static void reset() {
    _failedAttempts = 0;
    _lockoutUntil = null;
  }

  /// Current failed attempt count (useful for UI warnings).
  static int get failedAttempts => _failedAttempts;
}

/// شاشة إعدادات الأمان
class SecuritySettingsScreen extends ConsumerStatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  ConsumerState<SecuritySettingsScreen> createState() =>
      _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState
    extends ConsumerState<SecuritySettingsScreen> {
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;
  bool _pinEnabled = false;
  Duration? _sessionRemaining;
  bool _isLoading = true;
  String? _autoLockMinutes;

  @override
  void initState() {
    super.initState();
    _loadSecuritySettings();
  }

  Future<void> _loadSecuritySettings() async {
    setState(() => _isLoading = true);
    try {
      final biometricAvailable = await BiometricService.isAvailable().timeout(
        const Duration(seconds: 2),
        onTimeout: () => false,
      );
      final biometricEnabled = await BiometricService.isEnabled().timeout(
        const Duration(seconds: 2),
        onTimeout: () => false,
      );
      final pinEnabled = await PinService.isEnabled().timeout(
        const Duration(seconds: 2),
        onTimeout: () => false,
      );
      final sessionRemaining = await SessionManager.getRemainingTime().timeout(
        const Duration(seconds: 2),
        onTimeout: () => null,
      );

      final storeId = ref.read(currentStoreIdProvider);
      if (storeId != null) {
        final db = getIt<AppDatabase>();
        final dbPinEnabled = await getSettingValue(
          db,
          storeId,
          'security_pin_enabled',
        );
        final dbBiometricEnabled = await getSettingValue(
          db,
          storeId,
          'security_biometric_enabled',
        );
        final dbAutoLockMinutes = await getSettingValue(
          db,
          storeId,
          'security_auto_lock_minutes',
        );

        if (mounted) {
          setState(() {
            _biometricAvailable = biometricAvailable;
            _biometricEnabled = dbBiometricEnabled == 'true'
                ? true
                : (dbBiometricEnabled == 'false' ? false : biometricEnabled);
            _pinEnabled = dbPinEnabled == 'true'
                ? true
                : (dbPinEnabled == 'false' ? false : pinEnabled);
            _sessionRemaining = sessionRemaining;
            _autoLockMinutes = dbAutoLockMinutes;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _biometricAvailable = biometricAvailable;
            _biometricEnabled = biometricEnabled;
            _pinEnabled = pinEnabled;
            _sessionRemaining = sessionRemaining;
            _isLoading = false;
          });
        }
      }
    } catch (e, st) {
      reportError(e, stackTrace: st, hint: 'SecuritySettingsScreen: loadSettings');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSecuritySetting(String key, String value) async {
    final storeId = ref.read(currentStoreIdProvider);
    if (storeId == null) return;
    final db = getIt<AppDatabase>();
    await saveSettingWithSync(
      db: db,
      storeId: storeId,
      key: key,
      value: value,
      ref: ref,
    );
  }

  @override
  Widget build(BuildContext context) {
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

    final user = ref.watch(currentUserProvider);
    final userName = user?.name ?? l10n.defaultUserName;
    final userRole = (user?.role ?? l10n.branchManager).toString();

    return Column(
      children: [
        AppHeader(
          title: l10n.security,
          onMenuTap: isWideScreen
              ? null
              : () => Scaffold.of(context).openDrawer(),
          onNotificationsTap: () => context.push('/notifications'),
          notificationsCount: 3,
          userName: userName,
          userRole: userRole,
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: EdgeInsets.all(padding),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isWideScreen ? 800 : double.infinity,
                      ),
                      child: _buildContent(
                        isWideScreen,
                        isMediumScreen,
                        isDark,
                        l10n,
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildContent(
    bool isWideScreen,
    bool isMediumScreen,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSettingsGroup(l10n.pinSection, [
          _buildSettingsTile(
            icon: Icons.pin_rounded,
            title: l10n.createPinDesc,
            subtitle: _pinEnabled ? l10n.enabled : l10n.disabled,
            trailing: _pinEnabled
                ? const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.success,
                  )
                : Icon(
                    Icons.cancel_rounded,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.3)
                        : AppColors.textTertiary,
                  ),
            onTap: _showPinOptions,
            isDark: isDark,
          ),
        ], isDark),
        _buildSettingsGroup(l10n.biometricSection, [
          if (_biometricAvailable)
            SwitchListTile(
              secondary: Container(
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.fingerprint_rounded,
                  color: _biometricEnabled
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  size: 20,
                ),
              ),
              title: Text(
                l10n.fingerprintOption,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                _biometricEnabled ? l10n.fingerprintDesc : l10n.fingerprintDesc,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
              value: _biometricEnabled,
              onChanged: _toggleBiometric,
            )
          else
            _buildSettingsTile(
              icon: Icons.fingerprint_rounded,
              title: l10n.fingerprintOption,
              subtitle: l10n.fingerprintDesc,
              trailing: const Icon(
                Icons.info_outline_rounded,
                color: AppColors.warning,
              ),
              isDark: isDark,
            ),
        ], isDark),
        _buildSettingsGroup(l10n.sessionSection, [
          _buildSettingsTile(
            icon: Icons.access_time_rounded,
            title: l10n.autoLockOption,
            subtitle: _autoLockMinutes != null
                ? l10n.afterMinutes(int.tryParse(_autoLockMinutes!) ?? 30)
                : (_sessionRemaining != null
                      ? l10n.afterMinutes(_sessionRemaining!.inMinutes)
                      : l10n.disabled),
            trailing: IconButton(
              icon: Icon(
                Icons.refresh_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              onPressed: _loadSecuritySettings,
            ),
            isDark: isDark,
          ),
        ], isDark),
        _buildSettingsGroup(l10n.dangerZone, [
          _buildSettingsTile(
            icon: Icons.logout_rounded,
            title: l10n.logoutAllDevices,
            subtitle: l10n.logoutAllDevicesDesc,
            isDark: isDark,
            onTap: _showLogoutConfirmation,
            iconColor: AppColors.error,
          ),
          _buildSettingsTile(
            icon: Icons.delete_forever_rounded,
            title: l10n.clearAllData,
            subtitle: l10n.clearAllDataDesc,
            isDark: isDark,
            onTap: _showClearAllConfirmation,
            iconColor: AppColors.error,
          ),
        ], isDark),
      ],
    );
  }

  Widget _buildSettingsGroup(String title, List<Widget> children, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              AlhaiSpacing.mdl,
              AlhaiSpacing.md,
              AlhaiSpacing.mdl,
              AlhaiSpacing.xs,
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    required bool isDark,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(AlhaiSpacing.xs),
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor ?? AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            )
          : null,
      trailing:
          trailing ??
          AdaptiveIcon(
            Icons.chevron_left_rounded,
            color: isDark
                ? Colors.white.withValues(alpha: 0.3)
                : AppColors.textTertiary,
          ),
      onTap: onTap,
    );
  }

  void _showPinOptions() {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_pinEnabled) ...[
              ListTile(
                leading: const Icon(Icons.edit),
                title: Text(l10n.changePinOption),
                onTap: () {
                  Navigator.pop(context);
                  _showChangePinDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text(l10n.removePinOption),
                onTap: () {
                  Navigator.pop(context);
                  _showRemovePinConfirmation();
                },
              ),
            ] else ...[
              ListTile(
                leading: const Icon(Icons.add),
                title: Text(l10n.createPinOption),
                onTap: () {
                  Navigator.pop(context);
                  _showCreatePinDialog();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showCreatePinDialog() async {
    final l10n = AppLocalizations.of(context);
    String? newPin;
    String? confirmPin;
    String? error;
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.createPinTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: l10n.enterNewPin,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (v) => newPin = v,
              ),
              const SizedBox(height: AlhaiSpacing.md),
              TextField(
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: l10n.enterNewPinChange,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (v) => confirmPin = v,
              ),
              if (error != null) ...[
                const SizedBox(height: AlhaiSpacing.xs),
                Text(error!, style: const TextStyle(color: Colors.red)),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () async {
                if (newPin == null || newPin!.length < 4) {
                  setDialogState(() => error = l10n.enterNewPin);
                  return;
                }
                if (newPin != confirmPin) {
                  setDialogState(() => error = l10n.removePinConfirm);
                  return;
                }
                final result = await PinService.createPin(newPin!);
                if (result.isSuccess) {
                  if (context.mounted) Navigator.pop(context);
                  await _saveSecuritySetting('security_pin_enabled', 'true');
                  _loadSecuritySettings();
                  if (mounted) {
                    ScaffoldMessenger.of(
                      this.context,
                    ).showSnackBar(SnackBar(content: Text(l10n.pinCreated)));
                  }
                } else {
                  setDialogState(() => error = result.error);
                }
              },
              child: Text(l10n.createPinOption),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showChangePinDialog() async {
    final l10n = AppLocalizations.of(context);
    String? currentPin;
    String? newPin;
    String? error;
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.changePinTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (PinAttemptTracker.isLockedOut) ...[
                Icon(
                  Icons.lock_clock_rounded,
                  size: 48,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: AlhaiSpacing.sm),
                Text(
                  '${l10n.errorOccurred}\n${PinAttemptTracker.remainingLockoutDisplay}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ] else ...[
                TextField(
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: l10n.enterCurrentPin,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (v) => currentPin = v,
                ),
                const SizedBox(height: AlhaiSpacing.md),
                TextField(
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: l10n.enterNewPinChange,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (v) => newPin = v,
                ),
              ],
              if (error != null) ...[
                const SizedBox(height: AlhaiSpacing.xs),
                Text(error!, style: const TextStyle(color: Colors.red)),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            if (!PinAttemptTracker.isLockedOut)
              FilledButton(
                onPressed: () async {
                  if (currentPin == null || newPin == null) return;
                  // Rate-limit check
                  if (PinAttemptTracker.isLockedOut) {
                    setDialogState(
                      () => error =
                          '${l10n.errorOccurred} ${PinAttemptTracker.remainingLockoutDisplay}',
                    );
                    return;
                  }
                  final result = await PinService.changePin(
                    currentPin!,
                    newPin!,
                  );
                  if (result.isSuccess) {
                    PinAttemptTracker.reset();
                    if (context.mounted) Navigator.pop(context);
                    if (mounted) {
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        SnackBar(content: Text(l10n.pinChangedSuccess)),
                      );
                    }
                  } else {
                    PinAttemptTracker.recordFailedAttempt();
                    setDialogState(() {
                      if (PinAttemptTracker.isLockedOut) {
                        error =
                            '${l10n.errorOccurred} ${PinAttemptTracker.remainingLockoutDisplay}';
                      } else {
                        error = result.error;
                      }
                    });
                  }
                },
                child: Text(l10n.changePinOption),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showRemovePinConfirmation() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.removePinTitle),
        content: Text(l10n.removePinConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.removeAction),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await PinService.removePin();
      await _saveSecuritySetting('security_pin_enabled', 'false');
      _loadSecuritySettings();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.pinRemovedSuccess)));
      }
    }
  }

  Future<void> _toggleBiometric(bool enable) async {
    final l10n = AppLocalizations.of(context);
    if (enable) {
      final success = await BiometricService.enable();
      if (success) {
        setState(() => _biometricEnabled = true);
        await _saveSecuritySetting('security_biometric_enabled', 'true');
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.fingerprintDesc)));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.fingerprintDesc)));
        }
      }
    } else {
      await BiometricService.disable();
      setState(() => _biometricEnabled = false);
      await _saveSecuritySetting('security_biometric_enabled', 'false');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.fingerprintDesc)));
      }
    }
  }

  Future<void> _showLogoutConfirmation() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logoutAllTitle),
        content: Text(l10n.logoutAllConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.logoutAllAction),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await SessionManager.endSession();
      if (mounted) context.go('/login');
    }
  }

  Future<void> _showClearAllConfirmation() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearDataTitle),
        content: Text(l10n.clearDataConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.clearDataAction),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await SecureStorageService.clearAll();
      await SessionManager.endSession();
      if (mounted) context.go('/login');
    }
  }
}
