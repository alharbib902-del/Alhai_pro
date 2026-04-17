/// Foreground Lock Service
///
/// Tracks app background duration and decides whether a PIN/biometric
/// re-authentication is required on resume. Intended for shared devices
/// (e.g. cashier POS terminals) where the app may be exposed when the
/// operator steps away.
///
/// The service itself only:
/// 1. Persists a timestamp on background/inactive/hidden lifecycle events.
/// 2. On resume, reads that timestamp and compares against [threshold].
/// 3. Invokes [onLockRequired] when the backgrounded duration crosses the
///    threshold.
///
/// Actual lock-screen rendering and unlock logic live in
/// `ForegroundLockGate` — this service is intentionally headless so it can
/// be unit-tested without Flutter widgets.
library;
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'secure_storage_service.dart';
/// Storage key for the timestamp of when the app was last backgrounded.
/// Stored via [SecureStorageService] so it persists across process restarts
/// on native platforms (keychain / encrypted shared-prefs).
const String kForegroundLockBackgroundAtKey = 'fg_lock_bg_at';
/// Tracks app background duration and decides whether to require a
/// PIN/biometric re-auth on resume.
///
/// Usage:
/// ```dart
/// final service = ForegroundLockService(
///   threshold: const Duration(minutes: 2),
///   onLockRequired: () => showLockOverlay(),
/// );
/// service.attach(); // in initState
/// // ...
/// service.detach(); // in dispose
/// ```
class ForegroundLockService with WidgetsBindingObserver {
  ForegroundLockService({
    this.threshold = const Duration(minutes: 2),
    required this.onLockRequired,
    DateTime Function() clock = _defaultClock,
  }) : _clock = clock;
  /// How long the app can be backgrounded before a re-auth is required.
  /// Defaults to 2 minutes — a reasonable default for a shared POS
  /// terminal. Apps may override this per-deployment.
  final Duration threshold;
  /// Called when a resume event crosses [threshold]. Implementations
  /// should flip a flag / show a blocking overlay.
  final VoidCallback onLockRequired;
  /// Injectable clock for testing. Defaults to `DateTime.now()`.
  final DateTime Function() _clock;
  static DateTime _defaultClock() => DateTime.now();
  bool _attached = false;
  /// Begin observing lifecycle events. Safe to call multiple times.
  void attach() {
    if (_attached) return;
    WidgetsBinding.instance.addObserver(this);
    _attached = true;
  }
  /// Stop observing lifecycle events.
  void detach() {
    if (!_attached) return;
    WidgetsBinding.instance.removeObserver(this);
    _attached = false;
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.inactive:
        // Fire-and-forget: we don't want to block the framework on storage.
        // Errors here are non-fatal; worst case the user gets locked on
        // resume (which is the safe default).
        unawaited(recordBackgroundedAt());
        break;
      case AppLifecycleState.resumed:
        unawaited(_checkOnResume());
        break;
      case AppLifecycleState.detached:
        // App is being killed — no action needed.
        break;
    }
  }
  /// Persist the current time as the "backgrounded at" marker.
  ///
  /// Exposed (non-private) so tests can exercise the storage path without
  /// having to drive real lifecycle events.
  @visibleForTesting
  Future<void> recordBackgroundedAt() async {
    try {
      final now = _clock().toUtc().toIso8601String();
      await SecureStorageService.write(
        kForegroundLockBackgroundAtKey,
        now,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ForegroundLockService] recordBackgroundedAt failed: $e');
      }
    }
  }
  /// Read the stored background-at timestamp; if older than [threshold],
  /// fire [onLockRequired]. If no timestamp exists (cold start), do
  /// nothing — cold-start auth is handled by the existing login flow.
  Future<void> _checkOnResume() async {
    try {
      final stored = await SecureStorageService.read(
        kForegroundLockBackgroundAtKey,
      );
      if (stored == null || stored.isEmpty) return;
      final backgroundedAt = DateTime.tryParse(stored);
      if (backgroundedAt == null) {
        // Corrupted value — clear it and carry on.
        await clearBackgroundTimestamp();
        return;
      }
      final elapsed = _clock().toUtc().difference(backgroundedAt.toUtc());
      if (elapsed >= threshold) {
        onLockRequired();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ForegroundLockService] _checkOnResume failed: $e');
      }
      // Fail safe: if we can't read the timestamp, require unlock.
      onLockRequired();
    }
  }
  /// Clear the background-at marker. Call this after a successful unlock
  /// so the next background→resume cycle starts fresh.
  Future<void> clearBackgroundTimestamp() async {
    try {
      await SecureStorageService.delete(kForegroundLockBackgroundAtKey);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ForegroundLockService] clearBackgroundTimestamp '
            'failed: $e');
      }
    }
  }
  /// Test-only helper: drive a resume check without a real lifecycle event.
  @visibleForTesting
  Future<void> checkOnResumeForTesting() => _checkOnResume();
}
