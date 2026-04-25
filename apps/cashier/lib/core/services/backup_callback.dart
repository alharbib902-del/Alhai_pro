/// Top-level workmanager callback for auto-backup (Wave 5 / P0-09).
///
/// workmanager invokes this in a fresh Dart isolate, with no GetIt /
/// Riverpod / Sentry state available — the main app's wiring doesn't
/// cross the isolate boundary. Doing a full database export from here
/// is brittle (requires re-initialising sqlite, secure storage, secrets,
/// store-resolution chain) and would silently fail on any device
/// where the cashier hasn't set a backup passphrase yet.
///
/// Pragmatic compromise: this callback records *that the OS fired the
/// task* in shared_preferences. The next time the app opens (or the
/// user lands on backup_screen), `BackupManager.runPendingAutoBackup`
/// notices the marker, runs the real export+encrypt+save inside the
/// app's normal isolate, and clears the marker. From the cashier's
/// perspective the auto-backup happens "shortly after the scheduled
/// time" — exactly what cron-style schedulers actually deliver on
/// mobile platforms anyway.
///
/// Trade-off: if the device is rebooted and the app is never opened
/// before the next scheduled fire, we stack up multiple "pending" marks
/// — the catch-up runs once when the app opens. We log the count so
/// telemetry can spot devices where auto-backup keeps stacking
/// (suggests the cashier has lost the habit of opening the app).
library;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

/// SharedPreferences keys — exposed so the catch-up code in
/// backup_manager / backup_screen can read them.
const String prefsKeyPendingAutoBackupAt = 'backup.pending_auto_backup_at_iso';
const String prefsKeyPendingAutoBackupCount = 'backup.pending_auto_backup_count';

/// Top-level workmanager dispatcher. Must be top-level (not a method)
/// because workmanager spawns it in a separate isolate via tear-off.
@pragma('vm:entry-point')
void backupCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (kDebugMode) {
      debugPrint('[BackupScheduler] Task fired: $task');
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        prefsKeyPendingAutoBackupAt,
        DateTime.now().toUtc().toIso8601String(),
      );
      final count = (prefs.getInt(prefsKeyPendingAutoBackupCount) ?? 0) + 1;
      await prefs.setInt(prefsKeyPendingAutoBackupCount, count);
      return true;
    } catch (e, stack) {
      // No Sentry in this isolate — the only signal a maintainer gets
      // is the debug print, which is fine because the worst-case
      // outcome is "the catch-up doesn't happen this cycle".
      if (kDebugMode) {
        debugPrint('[BackupScheduler] Failed to mark pending: $e\n$stack');
      }
      return false;
    }
  });
}
