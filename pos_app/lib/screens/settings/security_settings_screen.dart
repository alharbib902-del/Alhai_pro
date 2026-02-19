import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/security/biometric_service.dart';
import '../../core/security/pin_service.dart';
import '../../core/security/session_manager.dart';
import '../../core/security/secure_storage_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/router/routes.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/layout/app_sidebar.dart';
import '../../widgets/layout/app_header.dart';

/// شاشة إعدادات الأمان
class SecuritySettingsScreen extends ConsumerStatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  ConsumerState<SecuritySettingsScreen> createState() =>
      _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState
    extends ConsumerState<SecuritySettingsScreen> {
  bool _sidebarCollapsed = false;
  String _selectedNavId = 'settings';

  bool _biometricAvailable = false;
  bool _biometricEnabled = false;
  bool _pinEnabled = false;
  Duration? _sessionRemaining;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSecuritySettings();
  }

  Future<void> _loadSecuritySettings() async {
    setState(() => _isLoading = true);
    try {
      final biometricAvailable = await BiometricService.isAvailable()
          .timeout(const Duration(seconds: 2), onTimeout: () => false);
      final biometricEnabled = await BiometricService.isEnabled()
          .timeout(const Duration(seconds: 2), onTimeout: () => false);
      final pinEnabled = await PinService.isEnabled()
          .timeout(const Duration(seconds: 2), onTimeout: () => false);
      final sessionRemaining = await SessionManager.getRemainingTime()
          .timeout(const Duration(seconds: 2), onTimeout: () => null);
      if (mounted) {
        setState(() {
          _biometricAvailable = biometricAvailable;
          _biometricEnabled = biometricEnabled;
          _pinEnabled = pinEnabled;
          _sessionRemaining = sessionRemaining;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

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
                  title: l10n.security,
                  onMenuTap: isWideScreen
                      ? () => setState(
                          () => _sidebarCollapsed = !_sidebarCollapsed)
                      : () => Scaffold.of(context).openDrawer(),
                  onNotificationsTap: () => context.push('/notifications'),
                  notificationsCount: 3,
                  userName:
                      '\u0623\u062d\u0645\u062f \u0645\u062d\u0645\u062f',
                  userRole: l10n.branchManager,
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
        onSettingsTap: () {
          Navigator.pop(context);
          context.push(AppRoutes.settings);
        },
        onSupportTap: () => Navigator.pop(context),
        onLogoutTap: () {
          Navigator.pop(context);
          context.go('/login');
        },
        userName: '\u0623\u062d\u0645\u062f \u0645\u062d\u0645\u062f',
        userRole: l10n.branchManager,
        onUserTap: () {},
      ),
    );
  }

  Widget _buildContent(
      bool isWideScreen, bool isMediumScreen, bool isDark, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // PIN section
        _buildSettingsGroup(
          '\u0631\u0645\u0632 PIN',
          [
            _buildSettingsTile(
              icon: Icons.pin_rounded,
              title: '\u0631\u0645\u0632 \u0627\u0644\u0645\u0634\u0631\u0641 (PIN)',
              subtitle: _pinEnabled
                  ? '\u0645\u0641\u0639\u0651\u0644'
                  : '\u063a\u064a\u0631 \u0645\u0641\u0639\u0651\u0644',
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
          '\u0627\u0644\u0645\u0635\u0627\u062f\u0642\u0629 \u0627\u0644\u0628\u064a\u0648\u0645\u062a\u0631\u064a\u0629',
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
                  '\u062a\u0633\u062c\u064a\u0644 \u0627\u0644\u062f\u062e\u0648\u0644 \u0628\u0627\u0644\u0628\u0635\u0645\u0629',
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  _biometricEnabled
                      ? '\u064a\u0645\u0643\u0646\u0643 \u0627\u0633\u062a\u062e\u062f\u0627\u0645 \u0628\u0635\u0645\u062a\u0643 \u0644\u0644\u062f\u062e\u0648\u0644 \u0627\u0644\u0633\u0631\u064a\u0639'
                      : '\u0642\u0645 \u0628\u062a\u0641\u0639\u064a\u0644 \u0627\u0644\u0628\u0635\u0645\u0629 \u0644\u0644\u062f\u062e\u0648\u0644 \u0628\u0634\u0643\u0644 \u0623\u0633\u0631\u0639',
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
                title: '\u0627\u0644\u0628\u0635\u0645\u0629 \u063a\u064a\u0631 \u0645\u062a\u0627\u062d\u0629',
                subtitle: '\u062c\u0647\u0627\u0632\u0643 \u0644\u0627 \u064a\u062f\u0639\u0645 \u0627\u0644\u0628\u0635\u0645\u0629 \u0623\u0648 Face ID',
                trailing: const Icon(Icons.info_outline_rounded,
                    color: AppColors.warning),
                isDark: isDark,
              ),
          ],
          isDark,
        ),

        // Session section
        _buildSettingsGroup(
          '\u0627\u0644\u062c\u0644\u0633\u0629',
          [
            _buildSettingsTile(
              icon: Icons.access_time_rounded,
              title: '\u0627\u0644\u0648\u0642\u062a \u0627\u0644\u0645\u062a\u0628\u0642\u064a \u0644\u0644\u062c\u0644\u0633\u0629',
              subtitle: _sessionRemaining != null
                  ? '${_sessionRemaining!.inMinutes} \u062f\u0642\u064a\u0642\u0629'
                  : '\u063a\u064a\u0631 \u0645\u062a\u0627\u062d',
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
          '\u0645\u0646\u0637\u0642\u0629 \u0627\u0644\u062e\u0637\u0631',
          [
            _buildSettingsTile(
              icon: Icons.logout_rounded,
              title: l10n.logout,
              subtitle: '\u0625\u0646\u0647\u0627\u0621 \u0627\u0644\u062c\u0644\u0633\u0629 \u0627\u0644\u062d\u0627\u0644\u064a\u0629',
              isDark: isDark,
              onTap: _showLogoutConfirmation,
              iconColor: AppColors.error,
            ),
            _buildSettingsTile(
              icon: Icons.delete_forever_rounded,
              title: '\u0645\u0633\u062d \u0643\u0644 \u0627\u0644\u0628\u064a\u0627\u0646\u0627\u062a',
              subtitle: '\u062d\u0630\u0641 \u062c\u0645\u064a\u0639 \u0627\u0644\u0628\u064a\u0627\u0646\u0627\u062a \u0627\u0644\u0645\u062d\u0641\u0648\u0638\u0629 \u0648\u0627\u0644\u062e\u0631\u0648\u062c',
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
          Icon(Icons.chevron_left_rounded,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.3)
                  : AppColors.textTertiary),
      onTap: onTap,
    );
  }

  // === Business logic methods (preserved from original) ===

  void _showPinOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_pinEnabled) ...[
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('\u062a\u063a\u064a\u064a\u0631 \u0631\u0645\u0632 PIN'),
                onTap: () {
                  Navigator.pop(context);
                  _showChangePinDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('\u062d\u0630\u0641 \u0631\u0645\u0632 PIN'),
                onTap: () {
                  Navigator.pop(context);
                  _showRemovePinConfirmation();
                },
              ),
            ] else ...[
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('\u0625\u0646\u0634\u0627\u0621 \u0631\u0645\u0632 PIN'),
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
    String? newPin;
    String? confirmPin;
    String? error;
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('\u0625\u0646\u0634\u0627\u0621 \u0631\u0645\u0632 PIN'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '\u0631\u0645\u0632 PIN (4 \u0623\u0631\u0642\u0627\u0645)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => newPin = v,
              ),
              const SizedBox(height: 16),
              TextField(
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '\u062a\u0623\u0643\u064a\u062f \u0627\u0644\u0631\u0645\u0632',
                  border: OutlineInputBorder(),
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
              child: const Text('\u0625\u0644\u063a\u0627\u0621'),
            ),
            FilledButton(
              onPressed: () async {
                if (newPin == null || newPin!.length < 4) {
                  setDialogState(
                      () => error = '\u0627\u0644\u0631\u0645\u0632 \u0642\u0635\u064a\u0631 \u062c\u062f\u0627\u064b');
                  return;
                }
                if (newPin != confirmPin) {
                  setDialogState(
                      () => error = '\u0627\u0644\u0631\u0645\u0632\u0627\u0646 \u063a\u064a\u0631 \u0645\u062a\u0637\u0627\u0628\u0642\u064a\u0646');
                  return;
                }
                final result = await PinService.createPin(newPin!);
                if (result.isSuccess) {
                  if (context.mounted) Navigator.pop(context);
                  _loadSecuritySettings();
                  if (mounted) {
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      const SnackBar(
                          content: Text('\u062a\u0645 \u0625\u0646\u0634\u0627\u0621 \u0631\u0645\u0632 PIN')),
                    );
                  }
                } else {
                  setDialogState(() => error = result.error);
                }
              },
              child: const Text('\u0625\u0646\u0634\u0627\u0621'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showChangePinDialog() async {
    String? currentPin;
    String? newPin;
    String? error;
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('\u062a\u063a\u064a\u064a\u0631 \u0631\u0645\u0632 PIN'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '\u0627\u0644\u0631\u0645\u0632 \u0627\u0644\u062d\u0627\u0644\u064a',
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => currentPin = v,
              ),
              const SizedBox(height: 16),
              TextField(
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '\u0627\u0644\u0631\u0645\u0632 \u0627\u0644\u062c\u062f\u064a\u062f',
                  border: OutlineInputBorder(),
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
              child: const Text('\u0625\u0644\u063a\u0627\u0621'),
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
                      const SnackBar(
                          content: Text('\u062a\u0645 \u062a\u063a\u064a\u064a\u0631 \u0631\u0645\u0632 PIN')),
                    );
                  }
                } else {
                  setDialogState(() => error = result.error);
                }
              },
              child: const Text('\u062a\u063a\u064a\u064a\u0631'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showRemovePinConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('\u062d\u0630\u0641 \u0631\u0645\u0632 PIN'),
        content: const Text(
            '\u0647\u0644 \u0623\u0646\u062a \u0645\u062a\u0623\u0643\u062f \u0645\u0646 \u062d\u0630\u0641 \u0631\u0645\u0632 PIN\u061f \u0633\u062a\u062d\u062a\u0627\u062c \u0644\u0625\u0639\u0627\u062f\u0629 \u0625\u0646\u0634\u0627\u0626\u0647 \u0644\u0627\u062d\u0642\u0627\u064b.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('\u0625\u0644\u063a\u0627\u0621'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('\u062d\u0630\u0641'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await PinService.removePin();
      _loadSecuritySettings();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('\u062a\u0645 \u062d\u0630\u0641 \u0631\u0645\u0632 PIN')),
        );
      }
    }
  }

  Future<void> _toggleBiometric(bool enable) async {
    if (enable) {
      final success = await BiometricService.enable();
      if (success) {
        setState(() => _biometricEnabled = true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('\u062a\u0645 \u062a\u0641\u0639\u064a\u0644 \u0627\u0644\u0628\u0635\u0645\u0629')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('\u0641\u0634\u0644 \u062a\u0641\u0639\u064a\u0644 \u0627\u0644\u0628\u0635\u0645\u0629')),
          );
        }
      }
    } else {
      await BiometricService.disable();
      setState(() => _biometricEnabled = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('\u062a\u0645 \u062a\u0639\u0637\u064a\u0644 \u0627\u0644\u0628\u0635\u0645\u0629')),
        );
      }
    }
  }

  Future<void> _showLogoutConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('\u062a\u0633\u062c\u064a\u0644 \u0627\u0644\u062e\u0631\u0648\u062c'),
        content: const Text(
            '\u0647\u0644 \u062a\u0631\u064a\u062f \u062a\u0633\u062c\u064a\u0644 \u0627\u0644\u062e\u0631\u0648\u062c \u0645\u0646 \u0627\u0644\u062c\u0644\u0633\u0629 \u0627\u0644\u062d\u0627\u0644\u064a\u0629\u061f'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('\u0625\u0644\u063a\u0627\u0621'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('\u062a\u0633\u062c\u064a\u0644 \u0627\u0644\u062e\u0631\u0648\u062c'),
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('\u0645\u0633\u062d \u0643\u0644 \u0627\u0644\u0628\u064a\u0627\u0646\u0627\u062a'),
        content: const Text(
          '\u0633\u064a\u062a\u0645 \u062d\u0630\u0641 \u062c\u0645\u064a\u0639 \u0627\u0644\u0628\u064a\u0627\u0646\u0627\u062a \u0627\u0644\u0645\u062d\u0641\u0648\u0638\u0629 \u0628\u0645\u0627 \u0641\u064a\u0647\u0627:\n'
          '\u2022 \u0631\u0645\u0632 PIN\n'
          '\u2022 \u0625\u0639\u062f\u0627\u062f\u0627\u062a \u0627\u0644\u0628\u0635\u0645\u0629\n'
          '\u2022 \u0628\u064a\u0627\u0646\u0627\u062a \u0627\u0644\u062c\u0644\u0633\u0629\n\n'
          '\u0647\u0630\u0627 \u0627\u0644\u0625\u062c\u0631\u0627\u0621 \u0644\u0627 \u064a\u0645\u0643\u0646 \u0627\u0644\u062a\u0631\u0627\u062c\u0639 \u0639\u0646\u0647!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('\u0625\u0644\u063a\u0627\u0621'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('\u0645\u0633\u062d \u0627\u0644\u0643\u0644'),
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
