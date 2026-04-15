import 'package:flutter/foundation.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Manages screen wake lock during active deliveries.
///
/// Keeps the screen on while the driver has an active (non-terminal) delivery
/// to prevent dangerous phone-unlock cycles while driving.
class WakelockService {
  WakelockService._();
  static final WakelockService instance = WakelockService._();

  bool _enabled = false;

  /// Whether the wake lock is currently enabled.
  bool get isEnabled => _enabled;

  /// Enables the wake lock (screen stays on).
  ///
  /// No-op if already enabled.
  Future<void> enable() async {
    if (_enabled) return;
    try {
      await WakelockPlus.enable();
      _enabled = true;
      if (kDebugMode) debugPrint('WakeLock: enabled');
    } catch (e) {
      if (kDebugMode) debugPrint('WakeLock: failed to enable — $e');
    }
  }

  /// Disables the wake lock (screen can dim/lock normally).
  ///
  /// No-op if already disabled.
  Future<void> disable() async {
    if (!_enabled) return;
    try {
      await WakelockPlus.disable();
      _enabled = false;
      if (kDebugMode) debugPrint('WakeLock: disabled');
    } catch (e) {
      if (kDebugMode) debugPrint('WakeLock: failed to disable — $e');
    }
  }
}
