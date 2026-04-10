import 'package:supabase_flutter/supabase_flutter.dart';

/// Simple feature flag service backed by a Supabase `feature_flags` table.
///
/// Schema:
/// ```sql
/// CREATE TABLE feature_flags (
///   key TEXT PRIMARY KEY,
///   enabled BOOLEAN DEFAULT false,
///   rollout_percent INT DEFAULT 0 CHECK (rollout_percent BETWEEN 0 AND 100),
///   updated_at TIMESTAMPTZ DEFAULT NOW()
/// );
/// ```
class FeatureFlags {
  FeatureFlags(this._client);

  final SupabaseClient _client;
  final Map<String, bool> _cache = {};
  DateTime? _lastFetch;
  static const _cacheDuration = Duration(minutes: 5);

  /// Check if a feature flag is enabled.
  /// Returns [defaultValue] if flag doesn't exist or on error.
  Future<bool> isEnabled(String key, {bool defaultValue = false}) async {
    await _refreshIfNeeded();
    return _cache[key] ?? defaultValue;
  }

  /// Kill switch — returns false if a critical feature should be disabled.
  /// Named method for clarity at call sites.
  Future<bool> isKillSwitched(String feature) async {
    return !(await isEnabled(feature, defaultValue: true));
  }

  Future<void> _refreshIfNeeded() async {
    final now = DateTime.now();
    if (_lastFetch != null && now.difference(_lastFetch!) < _cacheDuration) {
      return;
    }

    try {
      final response = await _client
          .from('feature_flags')
          .select('key, enabled, rollout_percent');

      _cache.clear();
      for (final row in response as List) {
        _cache[row['key'] as String] = row['enabled'] as bool;
      }
      _lastFetch = now;
    } catch (e) {
      // Silent fail — keep old cache. Never block UI on flag fetch.
    }
  }

  /// Force cache refresh on next read.
  void invalidate() {
    _lastFetch = null;
  }
}
