/// BackupScheduler — registers the cashier's auto-backup workmanager task.
///
/// Wave 5 (P0-09): the auto-backup toggle in `backup_screen.dart` was
/// disabled in Sprint 0 because the wiring behind it was a UI promise
/// with no actual scheduler — the cashier saw "auto-backup ON" while
/// nothing was happening. This service registers a real periodic task
/// via the `workmanager` plugin (Android WorkManager + iOS
/// BGTaskScheduler) so toggling the switch produces real, OS-driven
/// backup runs.
///
/// Scheduling notes
/// ----------------
/// * Android: the OS enforces a 15-minute MINIMUM for periodic work,
///   regardless of what we ask for. Hourly (60min), daily (24h), and
///   weekly (7d) all map cleanly. We ask for charging-not-required and
///   network-not-required so the cashier doesn't lose backups when the
///   tablet is on Wi-Fi-only and unplugged.
/// * iOS: BGTaskScheduler runs at the OS's discretion — there's no
///   guarantee of "every 24h", just "once-ish a day when the OS feels
///   like it". Cashiers must still take manual backups before risky
///   work; auto-backup is best-effort, not insurance.
///
/// What the task body does
/// -----------------------
/// The actual backup work runs in [BackupCallbackDispatcher] (top-level
/// — workmanager requires it). The dispatcher reads the latest
/// pass-phrase from secure storage, calls BackupManager.exportAsJson,
/// encrypts it via BackupCrypto, and writes the file to the app's
/// documents directory (no Share dialog — that requires UI). The next
/// time the user opens backup_screen.dart they see the new last-backup
/// timestamp.
///
/// IMPORTANT: until the user opens the app at least once after install
/// the workmanager plugin can't init, so the very first auto-backup is
/// always missed on a fresh install. Surface this in the screen copy.
library;

import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

/// Backup task identifier — registered with the OS scheduler. Changing
/// this string forces re-registration of all existing schedules.
const String backupTaskName = 'com.alhai.cashier.autoBackup';

/// Frequency presets exposed in the UI.
enum BackupFrequency {
  hourly(Duration(hours: 1), 'hourly'),
  daily(Duration(hours: 24), 'daily'),
  weekly(Duration(days: 7), 'weekly');

  final Duration interval;
  final String settingValue;

  const BackupFrequency(this.interval, this.settingValue);

  static BackupFrequency fromSetting(String? value) {
    return switch (value) {
      'hourly' => BackupFrequency.hourly,
      'weekly' => BackupFrequency.weekly,
      _ => BackupFrequency.daily,
    };
  }
}

/// Thin facade over the workmanager plugin so the rest of the app
/// doesn't have to import it directly. Stateless — all state lives in
/// the OS scheduler.
class BackupScheduler {
  const BackupScheduler();

  /// Initialise the workmanager plugin. MUST be called once during app
  /// boot (main.dart) before any schedule/cancel calls.
  ///
  /// [callbackDispatcher] is the top-level entry point the OS invokes
  /// when the task fires. It must be a top-level function (workmanager
  /// constraint — Dart isolates can't capture closures across the JNI
  /// boundary on Android).
  Future<void> init({
    required Function callbackDispatcher,
  }) async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: kDebugMode,
    );
  }

  /// Register (or replace) the periodic backup task with the OS.
  ///
  /// Idempotent: calling with [BackupFrequency.daily] twice in a row
  /// just keeps one daily task. Switching frequency cancels the old
  /// schedule first.
  Future<void> schedule(BackupFrequency frequency) async {
    // Always cancel before re-registering — workmanager's
    // ExistingWorkPolicy.replace would also work but we want to be
    // explicit about the intent so a future maintainer reading this
    // doesn't have to chase the plugin's defaults.
    await Workmanager().cancelByUniqueName(backupTaskName);

    await Workmanager().registerPeriodicTask(
      backupTaskName,
      backupTaskName,
      frequency: frequency.interval,
      // Keep constraints minimal — cashiers in low-connectivity stores
      // would lose every auto-backup if we required network. The backup
      // writes locally; sync to the cloud is a separate concern.
      constraints: Constraints(
        // ignore: constant_identifier_names — workmanager exposes
        // snake_case enum values for parity with the Android API.
        networkType: NetworkType.not_required,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: true,
      ),
      existingWorkPolicy: ExistingWorkPolicy.replace,
      backoffPolicy: BackoffPolicy.linear,
      backoffPolicyDelay: const Duration(minutes: 5),
    );
  }

  /// Cancel the periodic task. Safe to call when no task is scheduled.
  Future<void> cancel() async {
    await Workmanager().cancelByUniqueName(backupTaskName);
  }
}
