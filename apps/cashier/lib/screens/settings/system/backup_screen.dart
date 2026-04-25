/// Backup Screen - Backup and restore management
///
/// Last backup date/time, backup now button, auto-backup toggle,
/// backup frequency selector, restore from backup with confirmation.
/// Supports: RTL Arabic, dark/light theme, responsive layout.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_auth/alhai_auth.dart';
import '../../../core/services/sentry_service.dart';
import '../../../core/services/backup_manager.dart';
import '../../../core/services/backup_callback.dart';
import '../../../core/services/backup_file_io.dart';
import '../../../core/services/backup_scheduler.dart';
import 'package:alhai_design_system/alhai_design_system.dart'
    show AlhaiBreakpoints, AlhaiSnackbar, AlhaiSpacing;
// alhai_design_system is re-exported via alhai_shared_ui

/// Wave 5 (P0-08): clipboard auto-clear delay. After this much time the
/// screen wipes whatever encrypted backup it copied to the clipboard,
/// so it doesn't sit there indefinitely for any other app to read.
const Duration _kClipboardMaskDelay = Duration(seconds: 60);

/// Backup management screen
class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  final _db = GetIt.I<AppDatabase>();
  late final BackupManager _backupManager = BackupManager(_db);
  final _crypto = BackupCrypto();
  final _fileIo = const BackupFileIO();
  final _scheduler = const BackupScheduler();

  bool _isLoading = true;
  String? _error;
  bool _isBackingUp = false;
  bool _isRestoring = false;
  bool _autoBackup = false;
  String _backupFrequency = 'daily';
  DateTime? _lastBackupDate;
  int _backupCount = 0;
  double _backupSizeMb = 0;

  /// Wave 5 (P0-09): timestamp of the most recent OS-fired auto-backup
  /// task (read from shared_preferences via the workmanager callback).
  /// Lets the cashier see the scheduler is alive even between manual
  /// runs.
  DateTime? _lastAutoBackupAt;

  /// Active clipboard-mask timer, if any. Cancelled in dispose so we
  /// don't wipe the clipboard after the user has navigated away.
  Timer? _clipboardMaskTimer;

  @override
  void initState() {
    super.initState();
    _loadBackupSettings();
  }

  @override
  void dispose() {
    _clipboardMaskTimer?.cancel();
    super.dispose();
  }

  Future<void> _upsertSetting(String key, String value) async {
    final storeId = ref.read(currentStoreIdProvider);
    if (storeId == null) return;
    final id = 'setting_${storeId}_$key';
    await _db
        .into(_db.settingsTable)
        .insertOnConflictUpdate(
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
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;
      final settings = await (_db.select(
        _db.settingsTable,
      )..where((s) => s.storeId.equals(storeId))).get();
      for (final s in settings) {
        switch (s.key) {
          case 'auto_backup':
            _autoBackup = s.value != 'false';
          case 'backup_frequency':
            _backupFrequency = s.value;
          case 'last_backup_date':
            if (s.value.isNotEmpty) {
              _lastBackupDate = DateTime.tryParse(s.value) ?? DateTime.now();
            }
          case 'backup_count':
            _backupCount = int.tryParse(s.value) ?? 0;
          case 'backup_size_mb':
            _backupSizeMb = double.tryParse(s.value) ?? 0;
        }
      }
      // Wave 5 (P0-09): the Sprint 0 hotfix forced this off because the
      // scheduler was vapor. The scheduler is now real (BackupScheduler
      // wraps the workmanager plugin), so the stored value is honoured
      // again. The catch-up for OS-fired tasks runs lazily — see
      // [_loadAutoBackupTelemetry] below.

      // Wave 5 (P0-09): pull the OS-fire telemetry from
      // shared_preferences. The workmanager callback writes a
      // timestamp every time the OS triggers the backup task; reading
      // it here lets the cashier see "the scheduler IS firing — last
      // fire was X minutes ago" even when no actual backup ran.
      try {
        final prefs = await SharedPreferences.getInstance();
        final lastIso = prefs.getString(prefsKeyPendingAutoBackupAt);
        if (lastIso != null && lastIso.isNotEmpty) {
          _lastAutoBackupAt = DateTime.tryParse(lastIso);
        }
      } catch (_) {
        // No telemetry available — leave the fields null/zero.
      }
    } catch (e, stack) {
      // Use default values if settings cannot be loaded. Surface to
      // Sentry so release builds aren't silent; the UI carries on with
      // defaults regardless.
      reportError(e, stackTrace: stack, hint: 'Load backup settings');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _performBackup() async {
    // Wave 5 (P0-08): prompt for the encryption passphrase BEFORE we
    // run the export — if the cashier cancels we save the device the
    // cost of a multi-MB query for nothing.
    final passphrase = await _promptPassphrase(
      title: AppLocalizations.of(context).backupPassphraseTitle,
      requireConfirm: true,
    );
    if (passphrase == null || passphrase.isEmpty) return;

    setState(() => _isBackingUp = true);

    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;
      final bundle = await _backupManager.exportAsJson(storeId);

      // Wave 5 (P0-08): wrap the plaintext JSON in an AES-256-GCM
      // envelope keyed by the cashier's passphrase before any of it
      // touches the clipboard, share sheet, or filesystem.
      final encrypted = _crypto.encryptString(bundle.jsonString, passphrase);

      final now = bundle.createdAt;

      await _upsertSetting('last_backup_date', now.toIso8601String());
      await _upsertSetting('backup_count', (_backupCount + 1).toString());
      await _upsertSetting('backup_size_mb', bundle.sizeMb.toStringAsFixed(2));

      if (mounted) {
        setState(() {
          _lastBackupDate = now;
          _backupCount++;
          _backupSizeMb = bundle.sizeMb;
        });
        AlhaiSnackbar.success(
          context,
          AppLocalizations.of(context).backupCompletedBody(
            bundle.totalRows,
            bundle.sizeMb.toStringAsFixed(1),
          ),
        );
        _showBackupDoneDialog(bundle, encrypted);
      }
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Perform backup');
      if (mounted) {
        AlhaiSnackbar.error(
          context,
          AppLocalizations.of(context).backupFailedMsg('$e'),
        );
      }
    } finally {
      if (mounted) setState(() => _isBackingUp = false);
    }
  }

  /// Pop a passphrase prompt and return the trimmed entry, or null if
  /// the cashier cancels. When [requireConfirm] is true (export path),
  /// shows two fields and refuses mismatch — restore only needs one
  /// field because the entered passphrase is verified by AES-GCM at
  /// decrypt time anyway.
  Future<String?> _promptPassphrase({
    required String title,
    bool requireConfirm = false,
  }) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    final confirmController = TextEditingController();
    String? errorText;
    bool obscure = true;

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(title),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.backupPassphraseHelper,
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: AlhaiSpacing.md),
                TextField(
                  controller: controller,
                  autofocus: true,
                  obscureText: obscure,
                  decoration: InputDecoration(
                    labelText: l10n.backupPassphraseLabel,
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () => setLocal(() => obscure = !obscure),
                    ),
                  ),
                ),
                if (requireConfirm) ...[
                  const SizedBox(height: AlhaiSpacing.sm),
                  TextField(
                    controller: confirmController,
                    obscureText: obscure,
                    decoration: InputDecoration(
                      labelText: l10n.backupPassphraseConfirmLabel,
                      border: const OutlineInputBorder(),
                      errorText: errorText,
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                final v = controller.text.trim();
                if (v.length < 8) {
                  setLocal(
                    () => errorText = l10n.backupPassphraseTooShort,
                  );
                  return;
                }
                if (requireConfirm && v != confirmController.text.trim()) {
                  setLocal(
                    () => errorText = l10n.backupPassphraseMismatch,
                  );
                  return;
                }
                Navigator.pop(ctx, v);
              },
              child: Text(l10n.confirm),
            ),
          ],
        ),
      ),
    );

    controller.dispose();
    confirmController.dispose();
    return result;
  }

  void _showBackupDoneDialog(BackupBundle bundle, String encrypted) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.getSurface(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AlhaiSpacing.xs),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 22,
              ),
            ),
            const SizedBox(width: AlhaiSpacing.sm),
            Expanded(
              child: Text(
                l10n.backupCompletedTitle,
                style: TextStyle(color: AppColors.getTextPrimary(isDark)),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${bundle.totalRows} rows from ${bundle.tableCount} tables\n'
              'Size: ${bundle.sizeMb.toStringAsFixed(1)} MB '
              '• schema v${_backupManager.currentSchemaVersion}',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.getTextSecondary(isDark),
              ),
            ),
            const SizedBox(height: AlhaiSpacing.md),
            // Wave 5 (P0-08): the envelope is now AES-256-GCM encrypted,
            // so the warning shifts from "clipboard exposure" (handled by
            // the auto-clear timer + file-save default) to "passphrase
            // loss". A backup whose passphrase is forgotten is effectively
            // gone forever — no recovery path by design.
            Container(
              padding: const EdgeInsets.all(AlhaiSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.info.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.lock_outline_rounded,
                    color: AppColors.info,
                    size: 18,
                  ),
                  const SizedBox(width: AlhaiSpacing.xs),
                  Expanded(
                    child: Text(
                      l10n.backupEncryptedNotice,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.getTextPrimary(isDark),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.closeBtn),
          ),
          // Wave 5 (P0-08): clipboard path stays for cashiers without
          // file-share access on locked-down devices, but it auto-wipes
          // after `_kClipboardMaskDelay`.
          OutlinedButton.icon(
            onPressed: () => _copyEncryptedToClipboardWithMask(ctx, encrypted),
            icon: const Icon(Icons.copy_rounded, size: 18),
            label: Text(l10n.copyToClipboardBtn),
          ),
          FilledButton.icon(
            onPressed: () => _saveBackupToFile(ctx, encrypted, bundle),
            icon: const Icon(Icons.save_alt_rounded, size: 18),
            label: Text(l10n.saveBackupFile),
          ),
        ],
      ),
    );
  }

  /// Save the encrypted envelope as a file via share_plus + the OS share
  /// sheet. The cashier picks Files / Drive / iCloud / AirDrop from the
  /// sheet — no other app sees the bytes in transit.
  Future<void> _saveBackupToFile(
    BuildContext dialogCtx,
    String encrypted,
    BackupBundle bundle,
  ) async {
    final l10n = AppLocalizations.of(context);
    try {
      await _fileIo.shareEncryptedBackup(
        base64Envelope: encrypted,
        createdAt: bundle.createdAt,
        subject: l10n.backupShareSubject,
      );
      if (!dialogCtx.mounted) return;
      Navigator.pop(dialogCtx);
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Save backup file');
      if (!mounted) return;
      AlhaiSnackbar.error(context, l10n.backupFailedMsg('$e'));
    }
  }

  /// Copy the encrypted envelope to the system clipboard, then schedule
  /// a 60s auto-clear. AES-GCM means the bytes are useless without the
  /// passphrase — but we still wipe to avoid leaking the envelope's
  /// existence to clipboard observers (e.g. clipboard managers).
  Future<void> _copyEncryptedToClipboardWithMask(
    BuildContext dialogCtx,
    String encrypted,
  ) async {
    final l10n = AppLocalizations.of(context);
    await Clipboard.setData(ClipboardData(text: encrypted));
    _clipboardMaskTimer?.cancel();
    _clipboardMaskTimer = Timer(_kClipboardMaskDelay, () async {
      // Only wipe if the clipboard still holds OUR encrypted blob —
      // don't stomp on whatever the cashier has copied since.
      try {
        final current = await Clipboard.getData(Clipboard.kTextPlain);
        if (current?.text == encrypted) {
          await Clipboard.setData(const ClipboardData(text: ''));
        }
      } catch (_) {
        // Clipboard read can fail on some platforms; swallow.
      }
    });
    if (!dialogCtx.mounted) return;
    Navigator.pop(dialogCtx);
    if (!mounted) return;
    AlhaiSnackbar.info(context, l10n.backupCopiedToClipboardMasked);
  }

  Future<void> _showRestoreDialog(bool isDark, AppLocalizations l10n) async {
    final controller = TextEditingController();
    final confirmed = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          backgroundColor: AppColors.getSurface(isDark),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: AppColors.warning,
                  size: 22,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Expanded(
                child: Text(
                  l10n.restoreBackup,
                  style: TextStyle(color: AppColors.getTextPrimary(isDark)),
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
                  l10n.restoreSourcePrompt,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () async {
                          // Wave 5 (P0-08): primary path — open the OS
                          // file picker. Avoids the clipboard entirely.
                          final picked = await _fileIo
                              .pickEncryptedBackup();
                          if (picked != null) {
                            setLocal(() => controller.text = picked);
                          }
                        },
                        icon: const Icon(Icons.folder_open_rounded, size: 18),
                        label: Text(l10n.openBackupFile),
                      ),
                    ),
                    const SizedBox(width: AlhaiSpacing.sm),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final data = await Clipboard.getData(
                            Clipboard.kTextPlain,
                          );
                          if (data?.text != null) {
                            setLocal(() => controller.text = data!.text!);
                          }
                        },
                        icon: const Icon(Icons.paste_rounded, size: 18),
                        label: Text(l10n.pasteFromClipboard),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AlhaiSpacing.sm),
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
                      hintText: 'ALHAIB01...',
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
                const SizedBox(height: AlhaiSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AlhaiSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(
                      alpha: isDark ? 0.12 : 0.06,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: AppColors.error,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l10n.restoreOverwriteWarning,
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
              style: FilledButton.styleFrom(backgroundColor: AppColors.warning),
              child: Text(l10n.confirmRestore),
            ),
          ],
        ),
      ),
    );

    controller.dispose();

    if (confirmed != null && confirmed.trim().isNotEmpty && mounted) {
      _performRestore(confirmed.trim());
    }
  }

  Future<void> _performRestore(String rawData) async {
    setState(() => _isRestoring = true);

    try {
      String jsonData = rawData;

      // Wave 5 (P0-08): if the input has the AES envelope magic, prompt
      // for the passphrase and decrypt before validating. Plain-JSON
      // backups (legacy v1.0.0) skip the passphrase prompt entirely.
      if (BackupCrypto.isEncryptedEnvelope(rawData)) {
        final passphrase = await _promptPassphrase(
          title: AppLocalizations.of(context).restorePassphraseTitle,
        );
        if (passphrase == null) {
          if (mounted) setState(() => _isRestoring = false);
          return;
        }
        try {
          jsonData = _crypto.decryptToString(rawData, passphrase);
        } on BackupCryptoException catch (e) {
          if (mounted) {
            AlhaiSnackbar.error(
              context,
              e.kind == BackupCryptoFailure.badPassphrase
                  ? AppLocalizations.of(context).restoreBadPassphrase
                  : AppLocalizations.of(context).restoreCorruptBackup,
            );
            setState(() => _isRestoring = false);
          }
          return;
        }
      }

      // Validate first
      final info = _backupManager.validateBackup(jsonData);
      if (info == null) {
        throw const FormatException('Invalid backup file format');
      }

      // Wave 5 (P0-08): pre-flight schema check so the user sees the
      // mismatch in this dialog instead of as an error after the
      // restore transaction starts. Older v1.0.0 backups don't carry
      // schemaVersion; we let those through with a warning.
      if (info.schemaVersion != null &&
          info.schemaVersion != _backupManager.currentSchemaVersion) {
        if (mounted) {
          await showDialog<void>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(AppLocalizations.of(ctx).restoreSchemaMismatchTitle),
              content: Text(
                AppLocalizations.of(ctx).restoreSchemaMismatchBody(
                  info.schemaVersion!,
                  _backupManager.currentSchemaVersion,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(AppLocalizations.of(ctx).closeBtn),
                ),
              ],
            ),
          );
          setState(() => _isRestoring = false);
        }
        return;
      }

      // Cross-store guard: refuse to silently clobber the active store's
      // data with rows belonging to a different store. Without this
      // check, an admin who pasted the wrong JSON could irreversibly
      // overwrite customers, sales, inventory, etc.
      final currentStoreId = ref.read(currentStoreIdProvider);
      if (currentStoreId == null || currentStoreId.isEmpty) {
        throw const FormatException('No active store — cannot restore');
      }
      if (info.storeId != currentStoreId) {
        if (!mounted) return;
        final proceed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.error,
                  size: 24,
                ),
                SizedBox(width: AlhaiSpacing.sm),
                Expanded(child: Text('بيانات من متجر آخر')),
              ],
            ),
            content: Text(
              'هذه النسخة الاحتياطية مأخوذة من متجر آخر '
              '(${info.storeId}).\n'
              'استعادتها هنا ستحل محل بيانات المتجر الحالي '
              '($currentStoreId) وقد يؤدي ذلك إلى فقدان البيانات. '
              'هل تريد المتابعة؟',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(AppLocalizations.of(ctx).cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                child: const Text('نعم، استبدل البيانات'),
              ),
            ],
          ),
        );
        if (proceed != true) {
          return; // aborted in the finally below via the early return path
        }
      }

      final report = await _backupManager.importFromJson(jsonData);

      if (!report.success) {
        throw Exception(report.error ?? 'Unknown restore error');
      }

      if (mounted) {
        AlhaiSnackbar.success(
          context,
          'Restore completed — ${report.restoredRows} rows, ${report.restoredTables} tables',
        );
        // Refresh the settings display
        _loadBackupSettings();
      }
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Perform restore');
      if (mounted) {
        AlhaiSnackbar.error(
          context,
          AppLocalizations.of(context).restoreFailed('$e'),
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

      // Wave 5 (P0-09): wire the toggle to the OS scheduler. Switching
      // off → cancel the registered task. Switching on (or changing
      // frequency while on) → re-register with the new interval.
      // Errors here are non-fatal: the setting persists either way and
      // the next app open re-attempts the schedule.
      if (_autoBackup) {
        await _scheduler.schedule(
          BackupFrequency.fromSetting(_backupFrequency),
        );
      } else {
        await _scheduler.cancel();
      }
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Save backup settings');
    }
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
          title: l10n.backup,
          subtitle: l10n.backupSettings,
          showSearch: false,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: AppColors.getTextPrimary(isDark),
            ),
            onPressed: () => context.pop(),
            tooltip: l10n.back,
          ),
          onNotificationsTap: () => context.push(AppRoutes.notificationsCenter),
          userName: ref.watch(currentUserProvider)?.name ?? l10n.cashCustomer,
          userRole: l10n.cashier,
          onUserTap: () => context.push(AppRoutes.profile),
        ),
        Expanded(
          child: _isLoading
              ? const AppLoadingState()
              : _error != null
              ? AppErrorState.general(
                  context,
                  message: _error!,
                  onRetry: _loadBackupSettings,
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(
                    isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md,
                  ),
                  child: _buildContent(
                    isWideScreen,
                    isMediumScreen,
                    isDark,
                    l10n,
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
    if (isWideScreen) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                _buildLastBackupCard(isDark, l10n),
                const SizedBox(height: AlhaiSpacing.lg),
                _buildBackupNowCard(isDark, l10n),
              ],
            ),
          ),
          const SizedBox(width: AlhaiSpacing.lg),
          Expanded(
            child: Column(
              children: [
                _buildAutoBackupCard(isDark, l10n),
                const SizedBox(height: AlhaiSpacing.lg),
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
        SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
        _buildBackupNowCard(isDark, l10n),
        SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
        _buildAutoBackupCard(isDark, l10n),
        SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
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
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  hasBackup
                      ? Icons.cloud_done_rounded
                      : Icons.cloud_off_rounded,
                  color: statusColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
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
          const SizedBox(height: AlhaiSpacing.mdl),
          if (!hasBackup)
            Text(
              'لا توجد نسخة احتياطية بعد. قم بإنشاء أول نسخة الآن.',
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
            const SizedBox(height: AlhaiSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _statusItem(
                    Icons.folder_rounded,
                    'إجمالي النسخ',
                    '$_backupCount',
                    isDark,
                  ),
                ),
                Expanded(
                  child: _statusItem(
                    Icons.storage_rounded,
                    'الحجم',
                    '${_backupSizeMb.toStringAsFixed(1)} م.ب',
                    isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AlhaiSpacing.md),
            Container(
              padding: const EdgeInsets.all(AlhaiSpacing.sm),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: isDark ? 0.12 : 0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: statusColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: statusColor,
                    size: 18,
                  ),
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

  Widget _statusItem(IconData icon, String label, String value, bool isDark) {
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
        const SizedBox(height: AlhaiSpacing.xxs),
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
      return 'النسخة الاحتياطية حديثة (منذ أقل من ساعة)';
    } else if (timeSince.inHours < 24) {
      return 'آخر نسخة منذ ${timeSince.inHours} ساعة';
    } else {
      return 'آخر نسخة منذ ${timeSince.inDays} يوم';
    }
  }

  /// Render a Duration as a short relative-time string. Used by the
  /// auto-backup card to show "scheduler fired N min ago".
  String _formatRelativeTime(Duration d) {
    if (d.inMinutes < 1) return 'قبل لحظات';
    if (d.inHours < 1) return 'قبل ${d.inMinutes} دقيقة';
    if (d.inDays < 1) return 'قبل ${d.inHours} ساعة';
    return 'قبل ${d.inDays} يوم';
  }

  Widget _buildBackupNowCard(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
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
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          if (_isBackingUp) ...[
            const SizedBox(height: 10),
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: AlhaiSpacing.md),
            Text(
              'جارٍ تصدير قاعدة البيانات...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.getTextPrimary(isDark),
              ),
            ),
            const SizedBox(height: AlhaiSpacing.xs),
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
                  'نسخ احتياطي الآن',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  padding: const EdgeInsets.symmetric(
                    vertical: AlhaiSpacing.md,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.schedule_rounded,
                  color: AppColors.info,
                  size: 20,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.autoBackup,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.getTextPrimary(isDark),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      // Wave 5 (P0-09): the switch is real now (workmanager
                      // scheduler). Surface the OS-fire telemetry so the
                      // cashier sees that scheduled wakes are actually
                      // happening even when no manual backup runs.
                      _lastAutoBackupAt != null
                          ? l10n.autoBackupLastFiredAt(_formatRelativeTime(
                              DateTime.now().difference(_lastAutoBackupAt!),
                            ))
                          : l10n.autoBackupHelper,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.getTextSecondary(isDark),
                      ),
                    ),
                  ],
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
            const SizedBox(height: AlhaiSpacing.mdl),
            Text(
              l10n.backupFrequency,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.getTextSecondary(isDark),
              ),
            ),
            const SizedBox(height: AlhaiSpacing.sm),
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
                      horizontal: AlhaiSpacing.md,
                      vertical: 10,
                    ),
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
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.restore_rounded,
                  color: AppColors.warning,
                  size: 20,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
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
          const SizedBox(height: AlhaiSpacing.md),
          Text(
            'استعد بياناتك من نسخة احتياطية سابقة. سيؤدي ذلك إلى استبدال البيانات الحالية.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.getTextSecondary(isDark),
              height: 1.5,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.mdl),
          SizedBox(
            width: double.infinity,
            child: _isRestoring
                ? Center(
                    child: Column(
                      children: [
                        const CircularProgressIndicator(
                          color: AppColors.warning,
                        ),
                        const SizedBox(height: AlhaiSpacing.sm),
                        Text(
                          'جارٍ الاستعادة...',
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
                      'استعادة الآن',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.warning,
                      side: BorderSide(
                        color: AppColors.warning.withValues(alpha: 0.5),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
