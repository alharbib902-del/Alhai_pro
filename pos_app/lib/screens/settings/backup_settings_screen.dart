import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/router/routes.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/layout/app_sidebar.dart';
import '../../widgets/layout/app_header.dart';

/// شاشة إعدادات النسخ الاحتياطي
class BackupSettingsScreen extends ConsumerStatefulWidget {
  const BackupSettingsScreen({super.key});

  @override
  ConsumerState<BackupSettingsScreen> createState() => _BackupSettingsScreenState();
}

class _BackupSettingsScreenState extends ConsumerState<BackupSettingsScreen> {
  bool _sidebarCollapsed = false;
  String _selectedNavId = 'settings';
  bool _autoBackupEnabled = true;
  String _backupFrequency = 'daily';
  bool _isBackingUp = false;

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
            title: l10n.backupSettings,
            onMenuTap: isWideScreen
                ? () => setState(() => _sidebarCollapsed = !_sidebarCollapsed)
                : () => Scaffold.of(context).openDrawer(),
            onNotificationsTap: () => context.push('/notifications'),
            notificationsCount: 3, userName: '\u0623\u062d\u0645\u062f \u0645\u062d\u0645\u062f', userRole: l10n.branchManager,
          ),
          Expanded(child: SingleChildScrollView(
            padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
            child: _buildContent(isWideScreen, isMediumScreen, isDark, l10n),
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

  Widget _buildContent(bool isWideScreen, bool isMediumScreen, bool isDark, AppLocalizations l10n) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildGroup(l10n.autoBackup, [
        SwitchListTile(
          secondary: Container(padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.backup_rounded, color: AppColors.primary, size: 20)),
          title: Text(l10n.autoBackup, style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w500)),
          subtitle: Text(_autoBackupEnabled ? '\u064a\u062a\u0645 \u0627\u0644\u0646\u0633\u062e \u062a\u0644\u0642\u0627\u0626\u064a\u0627\u064b' : '\u0645\u0639\u0637\u0644',
            style: TextStyle(color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textSecondary, fontSize: 12)),
          value: _autoBackupEnabled, onChanged: (v) => setState(() => _autoBackupEnabled = v),
        ),
        if (_autoBackupEnabled)
          _tile(Icons.schedule_rounded, '\u062a\u0643\u0631\u0627\u0631 \u0627\u0644\u0646\u0633\u062e', _getFreqLabel(), isDark,
            trailing: DropdownButton<String>(value: _backupFrequency, underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'hourly', child: Text('\u0643\u0644 \u0633\u0627\u0639\u0629')),
                DropdownMenuItem(value: 'daily', child: Text('\u064a\u0648\u0645\u064a\u0627\u064b')),
                DropdownMenuItem(value: 'weekly', child: Text('\u0623\u0633\u0628\u0648\u0639\u064a\u0627\u064b')),
              ],
              onChanged: (v) => setState(() => _backupFrequency = v ?? _backupFrequency))),
      ], isDark),

      _buildGroup('\u0627\u0644\u0646\u0633\u062e \u0627\u0644\u064a\u062f\u0648\u064a', [
        _tile(Icons.cloud_upload_rounded, '\u0625\u0646\u0634\u0627\u0621 \u0646\u0633\u062e\u0629 \u0627\u062d\u062a\u064a\u0627\u0637\u064a\u0629 \u0627\u0644\u0622\u0646', '\u0622\u062e\u0631 \u0646\u0633\u062e\u0629: \u0645\u0646\u0630 3 \u0633\u0627\u0639\u0627\u062a', isDark,
          trailing: _isBackingUp
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.play_arrow_rounded, color: AppColors.primary),
          onTap: _isBackingUp ? null : _startBackup),
      ], isDark),

      _buildGroup('\u0627\u0633\u062a\u0639\u0627\u062f\u0629 \u0627\u0644\u0628\u064a\u0627\u0646\u0627\u062a', [
        _tile(Icons.restore_rounded, '\u0627\u0633\u062a\u0639\u0627\u062f\u0629 \u0645\u0646 \u0646\u0633\u062e\u0629', '\u0627\u0633\u062a\u0631\u062c\u0627\u0639 \u0627\u0644\u0628\u064a\u0627\u0646\u0627\u062a \u0645\u0646 \u0646\u0633\u062e\u0629 \u0633\u0627\u0628\u0642\u0629', isDark, onTap: _showRestoreDialog),
      ], isDark),

      _buildGroup('\u0633\u062c\u0644 \u0627\u0644\u0646\u0633\u062e', [
        _historyItem('\u0646\u0633\u062e\u0629 \u062a\u0644\u0642\u0627\u0626\u064a\u0629', '\u0627\u0644\u064a\u0648\u0645 10:00 \u0635', '2.4 MB', true, isDark),
        _historyItem('\u0646\u0633\u062e\u0629 \u064a\u062f\u0648\u064a\u0629', '\u0623\u0645\u0633 14:30', '2.3 MB', true, isDark),
        _historyItem('\u0646\u0633\u062e\u0629 \u062a\u0644\u0642\u0627\u0626\u064a\u0629', '\u0623\u0645\u0633 10:00 \u0635', '2.3 MB', true, isDark),
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

  Widget _tile(IconData icon, String title, String? subtitle, bool isDark,
      {Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      leading: Container(padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: AppColors.primary, size: 20)),
      title: Text(title, style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle, style: TextStyle(
          color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textSecondary, fontSize: 12)) : null,
      trailing: trailing ?? Icon(Icons.chevron_left_rounded,
          color: isDark ? Colors.white.withValues(alpha: 0.3) : AppColors.textTertiary),
      onTap: onTap,
    );
  }

  Widget _historyItem(String type, String date, String size, bool success, bool isDark) {
    return ListTile(
      leading: Container(padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (success ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8)),
        child: Icon(success ? Icons.check_circle_rounded : Icons.error_rounded,
            color: success ? AppColors.success : AppColors.error, size: 20)),
      title: Text(type, style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w500)),
      subtitle: Text('$date \u2022 $size', style: TextStyle(
          color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textSecondary, fontSize: 12)),
    );
  }

  String _getFreqLabel() {
    switch (_backupFrequency) {
      case 'hourly': return '\u0643\u0644 \u0633\u0627\u0639\u0629';
      case 'daily': return '\u064a\u0648\u0645\u064a\u0627\u064b';
      case 'weekly': return '\u0623\u0633\u0628\u0648\u0639\u064a\u0627\u064b';
      default: return '\u064a\u0648\u0645\u064a\u0627\u064b';
    }
  }

  Future<void> _startBackup() async {
    setState(() => _isBackingUp = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isBackingUp = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('\u062a\u0645 \u0625\u0646\u0634\u0627\u0621 \u0627\u0644\u0646\u0633\u062e\u0629 \u0627\u0644\u0627\u062d\u062a\u064a\u0627\u0637\u064a\u0629 \u0628\u0646\u062c\u0627\u062d'), backgroundColor: AppColors.success));
    }
  }

  void _showRestoreDialog() {
    showDialog(context: context, builder: (context) => AlertDialog(
      title: const Text('\u0627\u0633\u062a\u0639\u0627\u062f\u0629 \u0627\u0644\u0628\u064a\u0627\u0646\u0627\u062a'),
      content: const Text('\u0633\u064a\u062a\u0645 \u0627\u0633\u062a\u0628\u062f\u0627\u0644 \u062c\u0645\u064a\u0639 \u0627\u0644\u0628\u064a\u0627\u0646\u0627\u062a \u0627\u0644\u062d\u0627\u0644\u064a\u0629 \u0628\u0628\u064a\u0627\u0646\u0627\u062a \u0627\u0644\u0646\u0633\u062e\u0629 \u0627\u0644\u0627\u062d\u062a\u064a\u0627\u0637\u064a\u0629.\n\u0647\u0630\u0627 \u0627\u0644\u0625\u062c\u0631\u0627\u0621 \u0644\u0627 \u064a\u0645\u0643\u0646 \u0627\u0644\u062a\u0631\u0627\u062c\u0639 \u0639\u0646\u0647!'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('\u0625\u0644\u063a\u0627\u0621')),
        FilledButton(onPressed: () { Navigator.pop(context);
          ScaffoldMessenger.of(this.context).showSnackBar(
            const SnackBar(content: Text('\u062c\u0627\u0631\u064a \u0627\u0644\u0627\u0633\u062a\u0639\u0627\u062f\u0629...'), backgroundColor: AppColors.info));
        }, style: FilledButton.styleFrom(backgroundColor: AppColors.warning), child: const Text('\u0627\u0633\u062a\u0639\u0627\u062f\u0629')),
      ],
    ));
  }
}
