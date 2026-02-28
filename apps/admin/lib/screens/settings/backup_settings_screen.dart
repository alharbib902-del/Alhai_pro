import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../providers/settings_db_providers.dart';

// مفاتيح إعدادات النسخ الاحتياطي
const String _kBackupAutoEnabled = 'backup_auto_enabled';
const String _kBackupFrequency = 'backup_frequency';

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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// تحميل الإعدادات من قاعدة البيانات
  Future<void> _loadSettings() async {
    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final db = getIt<AppDatabase>();
      final settings = await getSettingsByPrefix(db, storeId, 'backup_');

      if (mounted) {
        setState(() {
          _autoBackupEnabled = settings[_kBackupAutoEnabled] != 'false';
          _backupFrequency = settings[_kBackupFrequency] ?? 'daily';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// حفظ إعداد فردي في قاعدة البيانات مع المزامنة
  Future<void> _saveSingleSetting(String key, String value) async {
    final storeId = ref.read(currentStoreIdProvider);
    if (storeId == null) return;

    final db = getIt<AppDatabase>();
    try {
      await saveSettingWithSync(
        db: db,
        storeId: storeId,
        key: key,
        value: value,
        ref: ref,
      );
    } catch (e) {
      // الخطأ اختياري
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isMediumScreen = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
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
          const Expanded(
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      );
    }

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
          title: Text(l10n.autoBackup, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w500)),
          subtitle: Text(_autoBackupEnabled ? l10n.autoBackupEnabled : l10n.autoBackupDisabledLabel,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
          value: _autoBackupEnabled,
          onChanged: (v) {
            setState(() => _autoBackupEnabled = v);
            _saveSingleSetting(_kBackupAutoEnabled, v.toString());
          },
        ),
        if (_autoBackupEnabled)
          _tile(Icons.schedule_rounded, l10n.backupFrequency, _getFreqLabel(l10n), isDark,
            trailing: DropdownButton<String>(value: _backupFrequency, underline: const SizedBox(),
              items: [
                DropdownMenuItem(value: 'hourly', child: Text(l10n.everyHour)),
                DropdownMenuItem(value: 'daily', child: Text(l10n.dailyBackup)),
                DropdownMenuItem(value: 'weekly', child: Text(l10n.weeklyBackup)),
              ],
              onChanged: (v) {
                setState(() => _backupFrequency = v ?? _backupFrequency);
                _saveSingleSetting(_kBackupFrequency, v ?? _backupFrequency);
              })),
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
        _historyItem(l10n.autoBackup, '${l10n.today} 10:00', '2.4 MB', true, isDark),
        _historyItem(l10n.manualBackup, '${l10n.yesterday} 14:30', '2.3 MB', true, isDark),
        _historyItem(l10n.autoBackup, '${l10n.yesterday} 10:00', '2.3 MB', true, isDark),
      ], isDark),
    ]);
  }

  Widget _buildGroup(String title, List<Widget> children, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 8),
          child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface))),
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
      title: Text(title, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle, style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)) : null,
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
      title: Text(type, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w500)),
      subtitle: Text('$date \u2022 $size', style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
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
