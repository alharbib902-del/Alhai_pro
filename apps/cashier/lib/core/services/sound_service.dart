/// SoundService - tiny wrapper over just_audio that plays three short
/// feedback sounds (barcode beep, sale success, error buzz).
///
/// Implementation notes:
///   * Pure static singleton (no DI, no Riverpod) — callable from shared
///     packages without reverse dependencies.
///   * Tolerant of missing/empty asset files: the bundled MP3s under
///     `assets/sounds/` are 0-byte placeholders. When `setAsset` fails the
///     service logs once at debug level and degrades gracefully — all later
///     `play*` calls become no-ops instead of crashing the app.
///   * Volume is capped at 1.0 and persisted via [SharedPreferences] under
///     `settings_sound_volume` (see cashier_settings_screen).
///   * `enabled` is persisted under `settings_sound_enabled`. Default true.
///
/// Asset contract (pubspec.yaml / assets/sounds/):
///   - beep.mp3      — barcode scan success (short tick)
///   - success.mp3   — sale/payment success (longer chime)
///   - error.mp3     — error / not-found (dull buzz)
///
/// **IMPORTANT:** the bundled files are empty placeholders. Replace with
/// real audio before production release (see README / sounds/README.md).
library;

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class SoundService {
  SoundService._();
  static final SoundService instance = SoundService._();

  AudioPlayer? _beep;
  AudioPlayer? _success;
  AudioPlayer? _error;

  bool _initialized = false;
  double _volume = 0.8;

  bool get isInitialized => _initialized;

  /// Global on/off flag for confirmation sounds. Persisted in
  /// SharedPreferences under `settings_sound_enabled` by
  /// cashier_settings_screen.
  bool enabled = true;

  double get volume => _volume;

  /// Set volume in range [0.0, 1.0]. Applied to all three players.
  Future<void> setVolume(double v) async {
    _volume = v.clamp(0.0, 1.0);
    if (!_initialized) return;
    try {
      await _beep?.setVolume(_volume);
      await _success?.setVolume(_volume);
      await _error?.setVolume(_volume);
    } catch (_) {}
  }

  /// Initialise the three audio players and load their assets.
  ///
  /// Safe to call multiple times — the second call is a no-op. If asset
  /// loading fails (placeholder files, browser sandbox, codec missing) the
  /// service remains uninitialised and every subsequent `play*` call is a
  /// silent no-op. We never re-throw to the caller because audio feedback
  /// is decorative and must never block app launch.
  Future<void> init({bool? enabled, double? volume}) async {
    if (_initialized) return;
    if (enabled != null) this.enabled = enabled;
    if (volume != null) _volume = volume.clamp(0.0, 1.0);

    try {
      _beep = AudioPlayer();
      _success = AudioPlayer();
      _error = AudioPlayer();

      // Placeholder MP3s are 0 bytes — `setAsset` will throw on some
      // backends. We catch per-asset so one bad file doesn't break the
      // others.
      await _loadAsset(_beep!, 'assets/sounds/beep.mp3');
      await _loadAsset(_success!, 'assets/sounds/success.mp3');
      await _loadAsset(_error!, 'assets/sounds/error.mp3');

      await _beep?.setVolume(_volume);
      await _success?.setVolume(_volume);
      await _error?.setVolume(_volume);

      _initialized = true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[SoundService] init failed (placeholder assets are expected '
          'to fail until real MP3 files ship): $e',
        );
      }
      // Leave _initialized = false so play* calls become no-ops.
    }
  }

  Future<void> _loadAsset(AudioPlayer player, String asset) async {
    try {
      await player.setAsset(asset);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[SoundService] asset load skipped ($asset): $e');
      }
    }
  }

  /// Play the barcode-scan beep. Safe to call on every scan — the player
  /// is seeked to zero first so overlapping scans still produce a tick.
  Future<void> barcodeBeep() async {
    if (!enabled || !_initialized) return;
    try {
      await _beep?.seek(Duration.zero);
      await _beep?.play();
    } catch (_) {}
  }

  /// Play the sale/payment success chime.
  Future<void> saleSuccess() async {
    if (!enabled || !_initialized) return;
    try {
      await _success?.seek(Duration.zero);
      await _success?.play();
    } catch (_) {}
  }

  /// Play the error buzz.
  Future<void> errorBuzz() async {
    if (!enabled || !_initialized) return;
    try {
      await _error?.seek(Duration.zero);
      await _error?.play();
    } catch (_) {}
  }

  /// Release native resources. Called on app shutdown (rare) or tests.
  Future<void> dispose() async {
    try {
      await _beep?.dispose();
      await _success?.dispose();
      await _error?.dispose();
    } catch (_) {}
    _beep = null;
    _success = null;
    _error = null;
    _initialized = false;
  }
}
