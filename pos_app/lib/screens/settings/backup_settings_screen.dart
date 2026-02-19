import 'package:pos_app/widgets/common/adaptive_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/layout/app_header.dart';

/// شاشة إعدادات النسخ الاحتياطي
class BackupSettingsScreen extends ConsumerStatefulWidget {
  const BackupSettingsScreen({super.key});

  @override
  ConsumerState<BackupSettingsScreen> createState() => _BackupSettingsScreenState();
}

class _BackupSettingsScreenState extends ConsumerState<BackupSettingsScreen> {
  bool _autoBackupEnabled = true;
  String _backupFrequency = 'daily';
  bool _isBackingUp = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isMediumScreen = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        AppHeader(
          title: l10n.backupSettings,
          onMenuTap: isWideScreen ? null : () => Scaffold.of(context).openDrawer(),
          onNotificationsTap: () => context.push('/notifications'),
          notificationsCount: 3,
          userName: l10n.defaultUserName,
          userRole: l10n.branchManager,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
            child: _buildContent(isWideScreen, isMediumScreen, isDark, l10n),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(bool isWideScreen, bool isMediumScreen, bool isDark, AppLocalizations l10n) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildGroup(l10n.autoBackup, [
        SwitchListTile(
          secondary: Container(padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.backup_rounded, color: AppColors.primary, size: 20)),
          title: Text(l10n.autoBackup, style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w500)),
          subtitle: Text(_autoBackupEnabled ? l10n.autoBackupEnabled : l10n.autoBackupDisabledLabel,
            style: TextStyle(color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textSecondary, fontSize: 12)),
          value: _autoBackupEnabled, onChanged: (v) => setState(() => _autoBackupEnabled = v),
        ),
        if (_autoBackupEnabled)
          _tile(Icons.schedule_rounded, l10n.backupFrequency, _getFreqLabel(l10n), isDark,
            trailing: DropdownButton<String>(value: _backupFrequency, underline: const SizedBox(),
              items: [
                DropdownMenuItem(value: 'hourly', child: Text(l10n.everyHour)),
                DropdownMenuItem(value: 'daily', child: Text(l10n.dailyBackup)),
                DropdownMenuItem(value: 'weekly', child: Text(l10n.weeklyBackup)),
              ],
              onChanged: (v) => setState(() => _backupFrequency = v ?? _backupFrequency))),
      ], isDark),

      _buildGroup(l10n.manualBackupSection, [
        _tile(Icons.cloud_upload_rounded, l10n.createBackupNow, l10n.lastBackupTime, isDark,
          trailing: _isBackingUp
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.play_arrow_rounded, color: AppColors.primary),
          onTap: _isBackingUp ? null : _startBackup),
      ], isDark),

      _buildGroup(l10n.restoreSection, [
        _tile(Icons.restore_rounded, l10n.restoreFromBackup, l10n.restoreFromBackupDesc, isDark, onTap: _showRestoreDialog),
      ], isDark),

      _buildGroup(l10n.backupHistoryLabel, [
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
      trailing: trailing ?? AdaptiveIcon(Icons.chevron_left_rounded,
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

  String _getFreqLabel(AppLocalizations l10n) {
    switch (_backupFrequency) {
      case 'hourly': return l10n.everyHour;
      case 'daily': return l10n.dailyBackup;
      case 'weekly': return l10n.weeklyBackup;
      default: return l10n.dailyBackup;
    }
  }

  Future<void> _startBackup() async {
    setState(() => _isBackingUp = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isBackingUp = false);
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.backupCreated), backgroundColor: AppColors.success));
    }
  }

  void _showRestoreDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(context: context, builder: (context) => AlertDialog(
      title: Text(l10n.restoreConfirmTitle),
      content: Text(l10n.restoreConfirmMessage),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
        FilledButton(onPressed: () { Navigator.pop(context);
          ScaffoldMessenger.of(this.context).showSnackBar(
            SnackBar(content: Text(l10n.restoreInProgress), backgroundColor: AppColors.info));
        }, style: FilledButton.styleFrom(backgroundColor: AppColors.warning), child: Text(l10n.restoreAction)),
      ],
    ));
  }
}
