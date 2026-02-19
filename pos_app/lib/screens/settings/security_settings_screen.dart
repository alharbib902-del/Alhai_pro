import 'package:pos_app/widgets/common/adaptive_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/security/biometric_service.dart';
import '../../core/security/pin_service.dart';
import '../../core/security/session_manager.dart';
import '../../core/security/secure_storage_service.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/layout/app_header.dart';
import '../../di/injection.dart';
import '../../data/local/app_database.dart';
import '../../providers/auth_providers.dart';
import '../../providers/products_providers.dart';
import '../../providers/settings_db_providers.dart';

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

  // Settings from DB
  String? _autoLockMinutes;

  @override
  void initState() {
    super.initState();
    _loadSecuritySettings();
  }

  Future<void> _loadSecuritySettings() async {
    setState(() => _isLoading = true);
    try {
      // Load from local security services
      final biometricAvailable = await BiometricService.isAvailable()
          .timeout(const Duration(seconds: 2), onTimeout: () => false);
      final biometricEnabled = await BiometricService.isEnabled()
          .timeout(const Duration(seconds: 2), onTimeout: () => false);
      final pinEnabled = await PinService.isEnabled()
          .timeout(const Duration(seconds: 2), onTimeout: () => false);
      final sessionRemaining = await SessionManager.getRemainingTime()
          .timeout(const Duration(seconds: 2), onTimeout: () => null);

      // Load settings from DB
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId != null) {
        final db = getIt<AppDatabase>();
        final dbPinEnabled = await getSettingValue(db, storeId, 'security_pin_enabled');
        final dbBiometricEnabled = await getSettingValue(db, storeId, 'security_biometric_enabled');
        final dbAutoLockMinutes = await getSettingValue(db, storeId, 'security_auto_lock_minutes');

        if (mounted) {
          setState(() {
            _biometricAvailable = biometricAvailable;
            // Prefer DB setting if available, otherwise use local service value
            _biometricEnabled = dbBiometricEnabled == 'true' ? true : (dbBiometricEnabled == 'false' ? false : biometricEnabled);
            _pinEnabled = dbPinEnabled == 'true' ? true : (dbPinEnabled == 'false' ? false : pinEnabled);
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
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Save a security setting to DB with sync
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
    final isWideScreen = size.width > 900;
    final isMediumScreen = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    // Get real user data
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
                          padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
                          child: _buildContent(
                              isWideScreen, isMediumScreen, isDark, l10n),
                        ),
                ),
              ],
            );
  }
  Widget _buildContent(
      bool isWideScreen, bool isMediumScreen, bool isDark, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // PIN section
        _buildSettingsGroup(
          l10n.pinSection,
          [
            _buildSettingsTile(
              icon: Icons.pin_rounded,
              title: l10n.createPinDesc,
              subtitle: _pinEnabled
                  ? l10n.enabled
                  : l10n.disabled,
              trailing: _pinEnabled
                  ? const Icon(Icons.check_circle_rounded,
                      color: AppColors.success)
                  : Icon(Icons.cancel_rounded,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.3)
                          : AppColors.textTertiary),
              onTap: _showPinOptions,
              isDark: isDark,
            ),
          ],
          isDark,
        ),

        // Biometric section
        _buildSettingsGroup(
          l10n.biometricSection,
          [
            if (_biometricAvailable)
              SwitchListTile(
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.fingerprint_rounded,
                      color: _biometricEnabled
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      size: 20),
                ),
                title: Text(
                  l10n.fingerprintOption,
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  _biometricEnabled
                      ? l10n.fingerprintDesc
                      : l10n.fingerprintDesc,
                  style: TextStyle(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.5)
                        : AppColors.textSecondary,
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
                trailing: const Icon(Icons.info_outline_rounded,
                    color: AppColors.warning),
                isDark: isDark,
              ),
          ],
          isDark,
        ),

        // Session section
        _buildSettingsGroup(
          l10n.sessionSection,
          [
            _buildSettingsTile(
              icon: Icons.access_time_rounded,
              title: l10n.autoLockOption,
              subtitle: _autoLockMinutes != null
                  ? l10n.afterMinutes(int.tryParse(_autoLockMinutes!) ?? 30)
                  : (_sessionRemaining != null
                      ? l10n.afterMinutes(_sessionRemaining!.inMinutes)
                      : l10n.disabled),
              trailing: IconButton(
                icon: Icon(Icons.refresh_rounded,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.5)
                        : AppColors.textSecondary),
                onPressed: _loadSecuritySettings,
              ),
              isDark: isDark,
            ),
          ],
          isDark,
        ),

        // Danger zone
        _buildSettingsGroup(
          l10n.dangerZone,
          [
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
          ],
          isDark,
        ),
      ],
    );
  }

  Widget _buildSettingsGroup(
      String title, List<Widget> children, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
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
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor ?? AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.5)
                    : AppColors.textSecondary,
                fontSize: 12,
              ),
            )
          : null,
      trailing: trailing ??
          AdaptiveIcon(Icons.chevron_left_rounded,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.3)
                  : AppColors.textTertiary),
      onTap: onTap,
    );
  }

  // === Business logic methods (preserved from original) ===

  void _showPinOptions() {
    final l10n = AppLocalizations.of(context)!;
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
    final l10n = AppLocalizations.of(context)!;
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
              const SizedBox(height: 16),
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
                const SizedBox(height: 8),
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
                  setDialogState(
                      () => error = l10n.enterNewPin);
                  return;
                }
                if (newPin != confirmPin) {
                  setDialogState(
                      () => error = l10n.removePinConfirm);
                  return;
                }
                final result = await PinService.createPin(newPin!);
                if (result.isSuccess) {
                  if (context.mounted) Navigator.pop(context);
                  // Save to DB with sync
                  await _saveSecuritySetting('security_pin_enabled', 'true');
                  _loadSecuritySettings();
                  if (mounted) {
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(
                          content: Text(l10n.pinCreated)),
                    );
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
    final l10n = AppLocalizations.of(context)!;
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
              const SizedBox(height: 16),
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
              if (error != null) ...[
                const SizedBox(height: 8),
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
                if (currentPin == null || newPin == null) return;
                final result =
                    await PinService.changePin(currentPin!, newPin!);
                if (result.isSuccess) {
                  if (context.mounted) Navigator.pop(context);
                  if (mounted) {
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(
                          content: Text(l10n.pinChangedSuccess)),
                    );
                  }
                } else {
                  setDialogState(() => error = result.error);
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
    final l10n = AppLocalizations.of(context)!;
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
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.removeAction),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await PinService.removePin();
      // Save to DB with sync
      await _saveSecuritySetting('security_pin_enabled', 'false');
      _loadSecuritySettings();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.pinRemovedSuccess)),
        );
      }
    }
  }

  Future<void> _toggleBiometric(bool enable) async {
    final l10n = AppLocalizations.of(context)!;
    if (enable) {
      final success = await BiometricService.enable();
      if (success) {
        setState(() => _biometricEnabled = true);
        // Save to DB with sync
        await _saveSecuritySetting('security_biometric_enabled', 'true');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.fingerprintDesc)),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.fingerprintDesc)),
          );
        }
      }
    } else {
      await BiometricService.disable();
      setState(() => _biometricEnabled = false);
      // Save to DB with sync
      await _saveSecuritySetting('security_biometric_enabled', 'false');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.fingerprintDesc)),
        );
      }
    }
  }

  Future<void> _showLogoutConfirmation() async {
    final l10n = AppLocalizations.of(context)!;
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
    final l10n = AppLocalizations.of(context)!;
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
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
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
