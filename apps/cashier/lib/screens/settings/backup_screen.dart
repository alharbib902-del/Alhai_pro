/// Backup Screen - Backup and restore management
///
/// Last backup date/time, backup now button, auto-backup toggle,
/// backup frequency selector, restore from backup with confirmation.
/// Supports: RTL Arabic, dark/light theme, responsive layout.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_auth/alhai_auth.dart';
import '../../core/services/sentry_service.dart';
import '../../core/services/backup_manager.dart';
// alhai_design_system is re-exported via alhai_shared_ui

/// Backup management screen
class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  final _db = GetIt.I<AppDatabase>();
  late final BackupManager _backupManager = BackupManager(_db);

  bool _isLoading = true;
  String? _error;
  bool _isBackingUp = false;
  bool _isRestoring = false;
  bool _autoBackup = true;
  String _backupFrequency = 'daily';
  DateTime? _lastBackupDate;
  int _backupCount = 0;
  double _backupSizeMb = 0;

  /// Holds the last backup JSON in memory for quick share/download
  String? _lastBackupJson;

  @override
  void initState() {
    super.initState();
    _loadBackupSettings();
  }

  Future<void> _upsertSetting(String key, String value) async {
    final storeId = ref.read(currentStoreIdProvider)!;
    final id = 'setting_${storeId}_$key';
    await _db.into(_db.settingsTable).insertOnConflictUpdate(
      SettingsTableCompanion.insert(
        id: id,
        storeId: storeId,
        key: key,
        value: value,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> _loadBackupSettings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final storeId = ref.read(currentStoreIdProvider)!;
      final settings = await (
        _db.select(_db.settingsTable)
          ..where((s) => s.storeId.equals(storeId))
      ).get();
      for (final s in settings) {
        switch (s.key) {
          case 'auto_backup':
            _autoBackup = s.value != 'false';
          case 'backup_frequency':
            _backupFrequency = s.value;
          case 'last_backup_date':
            if (s.value.isNotEmpty) {
              _lastBackupDate =
                  DateTime.tryParse(s.value) ?? DateTime.now();
            }
          case 'backup_count':
            _backupCount = int.tryParse(s.value) ?? 0;
          case 'backup_size_mb':
            _backupSizeMb =
                double.tryParse(s.value) ?? 0;
        }
      }
    } catch (_) {
      // Silently use default values if settings cannot be loaded
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _performBackup() async {
    setState(() => _isBackingUp = true);

    try {
      final storeId = ref.read(currentStoreIdProvider)!;
      final bundle = await _backupManager.exportAsJson(storeId);

      final now = bundle.createdAt;
      _lastBackupJson = bundle.jsonString;

      await _upsertSetting('last_backup_date', now.toIso8601String());
      await _upsertSetting('backup_count', (_backupCount + 1).toString());
      await _upsertSetting('backup_size_mb', bundle.sizeMb.toStringAsFixed(2));

      if (mounted) {
        setState(() {
          _lastBackupDate = now;
          _backupCount++;
          _backupSizeMb = bundle.sizeMb;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Backup completed — ${bundle.totalRows} rows, ${bundle.sizeMb.toStringAsFixed(1)} MB',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        // Show share options
        _showBackupDoneDialog(bundle);
      }
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Perform backup');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isBackingUp = false);
    }
  }

  void _showBackupDoneDialog(BackupBundle bundle) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.getSurface(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: AppColors.success, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Backup Complete',
                style: TextStyle(color: AppColors.getTextPrimary(isDark)),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${bundle.totalRows} rows from ${bundle.tableCount} tables\n'
              'Size: ${bundle.sizeMb.toStringAsFixed(1)} MB',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.getTextSecondary(isDark),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Copy the backup data to clipboard to save or share it.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.getTextMuted(isDark),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          FilledButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _lastBackupJson ?? ''));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Backup copied to clipboard'),
                  backgroundColor: AppColors.info,
                ),
              );
            },
            icon: const Icon(Icons.copy_rounded, size: 18),
            label: const Text('Copy to Clipboard'),
          ),
        ],
      ),
    );
  }

  Future<void> _showRestoreDialog(bool isDark, AppLocalizations l10n) async {
    final controller = TextEditingController();
    final confirmed = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.getSurface(isDark),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.warning_rounded,
                  color: AppColors.warning, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.restoreBackup,
                style: TextStyle(
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Paste backup JSON data below, or paste from clipboard.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final data = await Clipboard.getData(Clipboard.kTextPlain);
                        if (data?.text != null) {
                          controller.text = data!.text!;
                        }
                      },
                      icon: const Icon(Icons.paste_rounded, size: 18),
                      label: const Text('Paste from Clipboard'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: TextField(
                  controller: controller,
                  maxLines: 8,
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    color: AppColors.getTextPrimary(isDark),
                  ),
                  decoration: InputDecoration(
                    hintText: '{"version":"1.0.0","storeId":"...","data":{...}}',
                    hintStyle: TextStyle(
                      fontSize: 12,
                      color: AppColors.getTextMuted(isDark),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error
                      .withValues(alpha: isDark ? 0.12 : 0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: AppColors.error, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Current data will be overwritten. This cannot be undone.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.getTextSecondary(isDark),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.warning,
            ),
            child: const Text('Confirm Restore'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (confirmed != null && confirmed.trim().isNotEmpty && mounted) {
      _performRestore(confirmed.trim());
    }
  }

  Future<void> _performRestore(String jsonData) async {
    setState(() => _isRestoring = true);

    try {
      // Validate first
      final info = _backupManager.validateBackup(jsonData);
      if (info == null) {
        throw const FormatException('Invalid backup file format');
      }

      final report = await _backupManager.importFromJson(jsonData);

      if (!report.success) {
        throw Exception(report.error ?? 'Unknown restore error');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Restore completed — ${report.restoredRows} rows, ${report.restoredTables} tables',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        // Refresh the settings display
        _loadBackupSettings();
      }
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Perform restore');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Restore failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isRestoring = false);
    }
  }

  Future<void> _saveAutoBackupSettings() async {
    try {
      await _upsertSetting('auto_backup', _autoBackup.toString());
      await _upsertSetting('backup_frequency', _backupFrequency);
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Save backup settings');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isMediumScreen = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        AppHeader(
          title: l10n.backup,
          subtitle: 'Backup & Restore',
          showSearch: false,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: AppColors.getTextPrimary(isDark),
            ),
            onPressed: () => context.pop(),
          ),
          onNotificationsTap: () => context.push(AppRoutes.notificationsCenter),
          userName:
              ref.watch(currentUserProvider)?.name ?? l10n.cashCustomer,
          userRole: l10n.cashier,
          onUserTap: () => context.push(AppRoutes.profile),
        ),
        Expanded(
          child: _isLoading
              ? const AppLoadingState()
              : _error != null
                  ? AppErrorState.general(message: _error!, onRetry: _loadBackupSettings)
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
    bool isWideScreen,
    bool isMediumScreen,
    bool isDark,
    AppLocalizations l10n,
  ) {
    if (isWideScreen) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                _buildLastBackupCard(isDark, l10n),
                const SizedBox(height: 24),
                _buildBackupNowCard(isDark, l10n),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              children: [
                _buildAutoBackupCard(isDark, l10n),
                const SizedBox(height: 24),
                _buildRestoreCard(isDark, l10n),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildLastBackupCard(isDark, l10n),
        SizedBox(height: isMediumScreen ? 24 : 16),
        _buildBackupNowCard(isDark, l10n),
        SizedBox(height: isMediumScreen ? 24 : 16),
        _buildAutoBackupCard(isDark, l10n),
        SizedBox(height: isMediumScreen ? 24 : 16),
        _buildRestoreCard(isDark, l10n),
      ],
    );
  }

  Widget _buildLastBackupCard(bool isDark, AppLocalizations l10n) {
    final hasBackup = _lastBackupDate != null;
    final timeSince = hasBackup
        ? DateTime.now().difference(_lastBackupDate!)
        : const Duration(days: 999);

    final statusColor = !hasBackup
        ? AppColors.getTextMuted(isDark)
        : timeSince.inHours < 24
            ? AppColors.success
            : timeSince.inHours < 72
                ? AppColors.warning
                : AppColors.error;

    return Container(
      padding: const EdgeInsets.all(20),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  hasBackup ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
                  color: statusColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.lastBackup,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (!hasBackup)
            Text(
              'No backup yet. Create your first backup now.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.getTextSecondary(isDark),
              ),
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: _statusItem(
                    Icons.calendar_today_rounded,
                    l10n.date,
                    '${_lastBackupDate!.day}/${_lastBackupDate!.month}/${_lastBackupDate!.year}',
                    isDark,
                  ),
                ),
                Expanded(
                  child: _statusItem(
                    Icons.access_time_rounded,
                    l10n.time,
                    '${_lastBackupDate!.hour.toString().padLeft(2, '0')}:${_lastBackupDate!.minute.toString().padLeft(2, '0')}',
                    isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _statusItem(
                    Icons.folder_rounded,
                    'Total Backups',
                    '$_backupCount',
                    isDark,
                  ),
                ),
                Expanded(
                  child: _statusItem(
                    Icons.storage_rounded,
                    'Size',
                    '${_backupSizeMb.toStringAsFixed(1)} MB',
                    isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: isDark ? 0.12 : 0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: statusColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: statusColor, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _getBackupStatusText(timeSince),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.getTextSecondary(isDark),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusItem(
    IconData icon,
    String label,
    String value,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppColors.getTextMuted(isDark)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.getTextMuted(isDark),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextPrimary(isDark),
          ),
        ),
      ],
    );
  }

  String _getBackupStatusText(Duration timeSince) {
    if (timeSince.inHours < 1) {
      return 'Backup is recent (less than an hour ago)';
    } else if (timeSince.inHours < 24) {
      return 'Last backup was ${timeSince.inHours} hours ago';
    } else {
      return 'Last backup was ${timeSince.inDays} days ago';
    }
  }

  Widget _buildBackupNowCard(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: _isBackingUp
            ? null
            : LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.06),
                  AppColors.primary.withValues(alpha: isDark ? 0.08 : 0.02),
                ],
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
              ),
        color: _isBackingUp ? AppColors.getSurface(isDark) : null,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          if (_isBackingUp) ...[
            const SizedBox(height: 10),
            const CircularProgressIndicator(
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Exporting database...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.getTextPrimary(isDark),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.pleaseWait,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.getTextMuted(isDark),
              ),
            ),
            const SizedBox(height: 10),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _performBackup,
                icon: const Icon(Icons.backup_rounded, size: 22),
                label: const Text(
                  'Backup Now',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAutoBackupCard(bool isDark, AppLocalizations l10n) {
    final frequencies = {
      'hourly': l10n.everyHour,
      'daily': l10n.daily,
      'weekly': l10n.weekly,
      'monthly': l10n.monthly,
    };

    return Container(
      padding: const EdgeInsets.all(20),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.schedule_rounded,
                    color: AppColors.info, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.autoBackup,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
              ),
              Switch(
                value: _autoBackup,
                onChanged: (v) {
                  setState(() => _autoBackup = v);
                  _saveAutoBackupSettings();
                },
                activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
                activeThumbColor: AppColors.primary,
              ),
            ],
          ),
          if (_autoBackup) ...[
            const SizedBox(height: 20),
            Text(
              l10n.backupFrequency,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.getTextSecondary(isDark),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: frequencies.entries.map((entry) {
                final isSelected = _backupFrequency == entry.key;
                return GestureDetector(
                  onTap: () {
                    setState(() => _backupFrequency = entry.key);
                    _saveAutoBackupSettings();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.info.withValues(alpha: 0.1)
                          : AppColors.getSurfaceVariant(isDark),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.info
                            : AppColors.getBorder(isDark),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppColors.info
                            : AppColors.getTextSecondary(isDark),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRestoreCard(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.restore_rounded,
                    color: AppColors.warning, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.restoreFromBackup,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Restore your data from a previous backup. This will replace all current data.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.getTextSecondary(isDark),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: _isRestoring
                ? Center(
                    child: Column(
                      children: [
                        const CircularProgressIndicator(
                          color: AppColors.warning,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Restoring...',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.getTextSecondary(isDark),
                          ),
                        ),
                      ],
                    ),
                  )
                : OutlinedButton.icon(
                    onPressed: () => _showRestoreDialog(isDark, l10n),
                    icon: const Icon(Icons.restore_rounded, size: 20),
                    label: const Text(
                      'Restore Now',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.warning,
                      side: BorderSide(
                          color: AppColors.warning.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
