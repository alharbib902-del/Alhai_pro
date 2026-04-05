import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local cache service for offline-first data access.
///
/// Caches delivery, earnings, and profile data locally so drivers can view
/// orders and history even without a network connection.
///
/// Strategy:
///   - Write-through: every network response is cached immediately.
///   - Read-through: callers check the cache when the network is unavailable.
///   - TTL: each entry expires after [_maxCacheAge] (24 h by default).
///   - In-memory layer: deserialized objects are kept in memory so that
///     repeated reads within a session avoid JSON parsing overhead.
class LocalCacheService {
  // ─── Storage keys ─────────────────────────────────────────────────────────

  static const _deliveriesKey = 'cache_deliveries';
  static const _profileKey = 'cache_driver_profile';
  static const _earningsKey = 'cache_earnings';
  static const _cacheTimestampPrefix = 'cache_ts_';

  static const _maxCacheAge = Duration(hours: 24);

  // ─── In-memory layer ──────────────────────────────────────────────────────

  List<Map<String, dynamic>>? _deliveriesCache;
  Map<String, dynamic>? _profileCache;

  // ─── Deliveries ───────────────────────────────────────────────────────────

  /// Persist a full delivery list and update the in-memory copy.
  Future<void> cacheDeliveries(List<Map<String, dynamic>> deliveries) async {
    _deliveriesCache = List.unmodifiable(deliveries);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_deliveriesKey, jsonEncode(deliveries));
    await _setTimestamp(prefs, 'deliveries');
    if (kDebugMode) {
      debugPrint('LocalCache: cached ${deliveries.length} deliveries');
    }
  }

  /// Return cached delivery list, or `null` if absent / expired.
  Future<List<Map<String, dynamic>>?> getCachedDeliveries() async {
    if (_deliveriesCache != null) return _deliveriesCache;
    final prefs = await SharedPreferences.getInstance();
    if (!_isValid(prefs, 'deliveries')) return null;
    final raw = prefs.getString(_deliveriesKey);
    if (raw == null) return null;
    try {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      _deliveriesCache = List.unmodifiable(list);
      return _deliveriesCache;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('LocalCache: failed to decode deliveries – $e');
      }
      return null;
    }
  }

  // ─── Single delivery detail ───────────────────────────────────────────────

  /// Persist a single delivery's full detail (includes order items).
  Future<void> cacheDeliveryDetail(
      String id, Map<String, dynamic> delivery) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cache_delivery_$id', jsonEncode(delivery));
    await _setTimestamp(prefs, 'delivery_$id');
    if (kDebugMode) debugPrint('LocalCache: cached detail for delivery $id');
  }

  /// Return a cached delivery detail, or `null` if absent / expired.
  Future<Map<String, dynamic>?> getCachedDeliveryDetail(String id) async {
    final prefs = await SharedPreferences.getInstance();
    if (!_isValid(prefs, 'delivery_$id')) return null;
    final raw = prefs.getString('cache_delivery_$id');
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('LocalCache: failed to decode delivery $id – $e');
      }
      return null;
    }
  }

  /// Apply an optimistic patch to a cached delivery detail.
  ///
  /// Merges [patch] into the stored JSON without a round-trip to the server.
  /// Call before sending the mutation; revert by calling [cacheDeliveryDetail]
  /// with the original map if the server rejects the change.
  Future<void> patchCachedDelivery(
      String id, Map<String, dynamic> patch) async {
    final existing = await getCachedDeliveryDetail(id) ?? {};
    final merged = {...existing, ...patch};
    await cacheDeliveryDetail(id, merged);

    // Also patch within the list cache (avoids staleness in list view).
    if (_deliveriesCache != null) {
      _deliveriesCache = List.unmodifiable([
        for (final item in _deliveriesCache!)
          (item['id'] == id) ? {...item, ...patch} : item,
      ]);
      // Persist the updated list.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_deliveriesKey, jsonEncode(_deliveriesCache));
    }
  }

  // ─── Driver profile ───────────────────────────────────────────────────────

  /// Persist driver profile data.
  Future<void> cacheProfile(Map<String, dynamic> profile) async {
    _profileCache = Map.unmodifiable(profile);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(profile));
    await _setTimestamp(prefs, 'profile');
  }

  /// Return cached profile, or `null` if absent / expired.
  Future<Map<String, dynamic>?> getCachedProfile() async {
    if (_profileCache != null) return _profileCache;
    final prefs = await SharedPreferences.getInstance();
    if (!_isValid(prefs, 'profile')) return null;
    final raw = prefs.getString(_profileKey);
    if (raw == null) return null;
    try {
      _profileCache = Map.unmodifiable(jsonDecode(raw) as Map<String, dynamic>);
      return _profileCache;
    } catch (e) {
      if (kDebugMode) debugPrint('LocalCache: failed to decode profile – $e');
      return null;
    }
  }

  // ─── Earnings ─────────────────────────────────────────────────────────────

  /// Persist earnings summary for a named [period] (e.g. "daily", "weekly").
  Future<void> cacheEarnings(String period, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_earningsKey}_$period', jsonEncode(data));
    await _setTimestamp(prefs, 'earnings_$period');
    if (kDebugMode) debugPrint('LocalCache: cached earnings for $period');
  }

  /// Return cached earnings summary, or `null` if absent / expired.
  Future<Map<String, dynamic>?> getCachedEarnings(String period) async {
    final prefs = await SharedPreferences.getInstance();
    if (!_isValid(prefs, 'earnings_$period')) return null;
    final raw = prefs.getString('${_earningsKey}_$period');
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('LocalCache: failed to decode earnings ($period) – $e');
      }
      return null;
    }
  }

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  /// Wipe all cached data (call on logout or cache invalidation).
  Future<void> clearAll() async {
    _deliveriesCache = null;
    _profileCache = null;
    final prefs = await SharedPreferences.getInstance();
    final toRemove =
        prefs.getKeys().where((k) => k.startsWith('cache_')).toList();
    for (final key in toRemove) {
      await prefs.remove(key);
    }
    if (kDebugMode) {
      debugPrint('LocalCache: cleared ${toRemove.length} entries');
    }
  }

  // ─── Private helpers ──────────────────────────────────────────────────────

  /// Record the current time as the write timestamp for [key].
  Future<void> _setTimestamp(SharedPreferences prefs, String key) async {
    await prefs.setString(
      '$_cacheTimestampPrefix$key',
      DateTime.now().toIso8601String(),
    );
  }

  /// Return `true` when the cache entry for [key] is present and within TTL.
  bool _isValid(SharedPreferences prefs, String key) {
    final raw = prefs.getString('$_cacheTimestampPrefix$key');
    if (raw == null) return false;
    final ts = DateTime.tryParse(raw);
    if (ts == null) return false;
    return DateTime.now().difference(ts) < _maxCacheAge;
  }
}
