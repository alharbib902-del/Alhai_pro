import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kDrivingModeKey = 'driving_mode_enabled';

/// Whether driving mode is active.
///
/// Driving mode increases text scale and touch targets for safer in-vehicle
/// use. The setting is persisted in SharedPreferences so it survives restarts.
final drivingModeProvider =
    StateNotifierProvider<DrivingModeNotifier, bool>((ref) {
  return DrivingModeNotifier();
});

class DrivingModeNotifier extends StateNotifier<bool> {
  DrivingModeNotifier() : super(false) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      state = prefs.getBool(_kDrivingModeKey) ?? false;
    } catch (_) {
      // First launch or prefs unavailable — default to off.
    }
  }

  Future<void> toggle() async {
    state = !state;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kDrivingModeKey, state);
    } catch (_) {
      // Persistence failure is non-fatal.
    }
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kDrivingModeKey, enabled);
    } catch (_) {
      // Persistence failure is non-fatal.
    }
  }
}
