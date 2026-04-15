import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/local_cache_service.dart';
import '../../../core/services/offline_queue_service.dart';
import '../../../core/services/sentry_service.dart';

/// Column sets used in select queries.
///
/// Keeping them as constants makes it easy to adjust the payload in one place
/// without hunting through query chains.
class _DeliveryColumns {
  /// Light projection for list views – avoids fetching large blobs.
  static const String list =
      'id, status, created_at, fee, '
      'orders:order_id(id, order_number, customer_name, customer_phone, delivery_address)';

  /// Full projection for list views that need driver location fields.
  // ignore: unused_field
  static const String listWithLocation =
      'id, status, created_at, fee, driver_lat, driver_lng, '
      'orders:order_id(id, order_number, customer_name, customer_phone, delivery_address)';

  /// Lightweight active-delivery projection (home screen card).
  static const String active =
      'id, status, created_at, fee, driver_lat, driver_lng, '
      'orders:order_id(id, order_number, customer_name, customer_phone, delivery_address)';

  /// Full projection for detail / proof screens – includes order items.
  static const String detail =
      '*, orders:order_id(*, order_items:order_items(*))';
}

/// Datasource for driver delivery operations using Supabase directly.
///
/// Every network read is written-through to [LocalCacheService] so that
/// subsequent reads succeed when the device is offline.  Mutations use an
/// optimistic-update / rollback pattern:
///
///   1. Patch the local cache immediately (UI feels instant).
///   2. Send the mutation to Supabase.
///   3a. On success → replace the optimistic patch with the authoritative
///       server response.
///   3b. On network failure → revert the cache (or keep the optimistic patch
///       for location updates) and enqueue in [OfflineQueueService].
class DeliveryDatasource {
  final SupabaseClient _client;
  final LocalCacheService _cache;

  DeliveryDatasource(this._client, this._cache);

  String get _driverId {
    final user = _client.auth.currentUser;
    if (user == null) throw StateError('المستخدم غير مسجّل الدخول');
    return user.id;
  }

  // ─── Client-side rate limiting ───────────────────────────────────────────

  /// Tracks the last time [updateStatus] was called to prevent rapid-fire
  /// status mutations (e.g., accidental double-tap on action buttons).
  DateTime? _lastStatusUpdate;
  static const _minStatusUpdateInterval = Duration(seconds: 2);

  // ─── Queries ─────────────────────────────────────────────────────────────

  /// Get all deliveries for the current driver.
  ///
  /// Uses the light [_DeliveryColumns.list] projection for list performance.
  /// Pass [statusFilter] to narrow results server-side.
  /// Falls back to the local cache when Supabase is unreachable.
  Future<List<Map<String, dynamic>>> getMyDeliveries({
    String? statusFilter,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      var query = _client
          .from('deliveries')
          .select(_DeliveryColumns.list)
          .eq('driver_id', _driverId);

      if (statusFilter != null) {
        query = query.eq('status', statusFilter);
      }

      final result = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      // Write-through: cache the unfiltered list so all views benefit.
      if (statusFilter == null) {
        await _cache.cacheDeliveries(result);
      }

      return result;
    } on PostgrestException catch (e) {
      if (_isNetworkError(e)) {
        final cached = await _cache.getCachedDeliveries();
        if (cached != null) {
          return statusFilter == null
              ? cached
              : cached.where((d) => d['status'] == statusFilter).toList();
        }
      }
      throw _classifyDatasourceError(e, 'getMyDeliveries');
    } catch (e, st) {
      reportError(e, stackTrace: st, hint: 'getMyDeliveries fallback');
      final cached = await _cache.getCachedDeliveries();
      if (cached != null) {
        return statusFilter == null
            ? cached
            : cached.where((d) => d['status'] == statusFilter).toList();
      }
      rethrow;
    }
  }

  /// Get active deliveries (not completed/failed/cancelled).
  /// Falls back to the local cache when Supabase is unreachable.
  Future<List<Map<String, dynamic>>> getActiveDeliveries() async {
    try {
      final result = await _client
          .from('deliveries')
          .select(_DeliveryColumns.active)
          .eq('driver_id', _driverId)
          .not('status', 'in', '(delivered,failed,cancelled)')
          .order('created_at', ascending: false);

      await _cache.cacheDeliveries(result);
      return result;
    } on PostgrestException catch (e) {
      if (_isNetworkError(e)) {
        final cached = await _cache.getCachedDeliveries();
        if (cached != null) {
          return cached
              .where((d) => !_terminalStatuses.contains(d['status']))
              .toList();
        }
      }
      throw _classifyDatasourceError(e, 'getActiveDeliveries');
    } catch (e, st) {
      reportError(e, stackTrace: st, hint: 'getActiveDeliveries fallback');
      final cached = await _cache.getCachedDeliveries();
      if (cached != null) {
        return cached
            .where((d) => !_terminalStatuses.contains(d['status']))
            .toList();
      }
      rethrow;
    }
  }

  /// Get completed deliveries (delivered / failed / cancelled).
  ///
  /// Uses light [_DeliveryColumns.list] projection; full details are only
  /// fetched on the detail screen.
  Future<List<Map<String, dynamic>>> getCompletedDeliveries({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      return await _client
          .from('deliveries')
          .select(_DeliveryColumns.list)
          .eq('driver_id', _driverId)
          .inFilter('status', ['delivered', 'failed', 'cancelled'])
          .order('delivered_at', ascending: false)
          .range(offset, offset + limit - 1);
    } on PostgrestException catch (e) {
      if (_isNetworkError(e)) {
        final cached = await _cache.getCachedDeliveries();
        if (cached != null) {
          return cached
              .where((d) => _terminalStatuses.contains(d['status']))
              .take(limit)
              .toList();
        }
      }
      throw _classifyDatasourceError(e, 'getCompletedDeliveries');
    } catch (e, st) {
      reportError(e, stackTrace: st, hint: 'getCompletedDeliveries fallback');
      final cached = await _cache.getCachedDeliveries();
      if (cached != null) {
        return cached
            .where((d) => _terminalStatuses.contains(d['status']))
            .take(limit)
            .toList();
      }
      rethrow;
    }
  }

  /// Get a single delivery by ID – full detail projection.
  /// Caches the result for offline access; serves stale cache on failure.
  Future<Map<String, dynamic>?> getDelivery(String id) async {
    try {
      final result = await _client
          .from('deliveries')
          .select(_DeliveryColumns.detail)
          .eq('id', id)
          .maybeSingle();

      if (result != null) {
        await _cache.cacheDeliveryDetail(id, result);
      }
      return result;
    } on PostgrestException catch (e) {
      if (_isNetworkError(e)) {
        return _cache.getCachedDeliveryDetail(id);
      }
      throw _classifyDatasourceError(e, 'getDelivery($id)');
    } catch (e, st) {
      reportError(e, stackTrace: st, hint: 'getDelivery($id) fallback');
      return _cache.getCachedDeliveryDetail(id);
    }
  }

  // ─── Streams ─────────────────────────────────────────────────────────────

  /// Stream deliveries assigned to this driver (Realtime).
  ///
  /// NOTE: Supabase Realtime `.stream()` does not support column projection;
  /// it always returns the full row. The light projection is applied in the
  /// provider layer via `select()` so that the stream payload stays small
  /// for the common list view.
  ///
  /// Each emission is written-through to the local cache so that subsequent
  /// offline sessions start with fresh data.
  Stream<List<Map<String, dynamic>>> streamMyDeliveries() {
    return _client
        .from('deliveries')
        .stream(primaryKey: ['id'])
        .eq('driver_id', _driverId)
        .order('created_at', ascending: false)
        .asyncMap((rows) async {
          await _cache.cacheDeliveries(rows);
          return rows;
        });
  }

  /// Stream new assignments (status = assigned).
  ///
  /// Shares the same stream as [streamMyDeliveries]; callers should filter
  /// client-side to avoid opening a second Realtime channel.
  Stream<List<Map<String, dynamic>>> streamNewAssignments() {
    return _client
        .from('deliveries')
        .stream(primaryKey: ['id'])
        .eq('driver_id', _driverId)
        .order('created_at', ascending: false);
  }

  // ─── Mutations ───────────────────────────────────────────────────────────

  /// Update delivery status via RPC (with server-side validation).
  ///
  /// Uses an optimistic-update / rollback pattern:
  ///   1. Patch the local cache immediately (UI feels instant).
  ///   2. Send to Supabase.
  ///   3a. Success → confirm patch with authoritative data.
  ///   3b. Network failure → keep optimistic patch, enqueue in
  ///       [OfflineQueueService].  Returns `{'success': true, 'offline': true}`.
  ///   3c. Validation / conflict → revert patch and rethrow.
  ///
  /// A client-side rate limit of [_minStatusUpdateInterval] prevents
  /// accidental rapid-fire calls (double-tap protection).
  Future<Map<String, dynamic>> updateStatus(
    String deliveryId,
    String newStatus, {
    String? notes,
  }) async {
    // Rate-limit guard – protects against double-tap and runaway retries.
    final now = DateTime.now();
    if (_lastStatusUpdate != null &&
        now.difference(_lastStatusUpdate!) < _minStatusUpdateInterval) {
      throw DatasourceException(
        message: 'يرجى الانتظار قبل تحديث الحالة مرة أخرى',
        context: 'updateStatus($deliveryId, $newStatus)',
        type: DatasourceErrorType.validation,
      );
    }
    _lastStatusUpdate = now;

    // 1. Optimistic patch.
    final optimisticPatch = {
      'status': newStatus,
      'updated_at': now.toIso8601String(),
    };
    final original = await _cache.getCachedDeliveryDetail(deliveryId);
    await _cache.patchCachedDelivery(deliveryId, optimisticPatch);

    try {
      // 2. Send to server.
      final result = await _client.rpc(
        'update_delivery_status',
        params: {
          'p_delivery_id': deliveryId,
          'p_new_status': newStatus,
          'p_notes': notes,
        },
      );
      final resultMap = result as Map<String, dynamic>;

      // 3a. Confirm the patch with authoritative data.
      if (resultMap['success'] == true && original != null) {
        await _cache.cacheDeliveryDetail(deliveryId, {
          ...original,
          ...optimisticPatch,
        });
      }

      return resultMap;
    } on PostgrestException catch (e) {
      final classified = _classifyDatasourceError(
        e,
        'updateStatus($deliveryId, $newStatus)',
      );

      if (classified.isNetwork) {
        // 3b. Network error: queue for later, keep the optimistic state.
        await OfflineQueueService.instance.enqueue(
          deliveryId: deliveryId,
          status: newStatus,
          notes: notes,
        );
        return {'success': true, 'offline': true};
      }

      // 3c. Validation / conflict: revert optimistic patch.
      if (original != null) {
        await _cache.cacheDeliveryDetail(deliveryId, original);
      } else {
        await _cache.patchCachedDelivery(deliveryId, {'status': 'unknown'});
      }
      throw classified;
    } catch (e, st) {
      // Unexpected error treated as network failure: queue and keep patch.
      reportError(
        e,
        stackTrace: st,
        hint: 'updateStatus($deliveryId, $newStatus) fallback',
      );
      await OfflineQueueService.instance.enqueue(
        deliveryId: deliveryId,
        status: newStatus,
        notes: notes,
      );
      return {'success': true, 'offline': true};
    }
  }

  /// Accept a delivery assignment.
  Future<Map<String, dynamic>> acceptDelivery(String deliveryId) async {
    return updateStatus(deliveryId, 'accepted');
  }

  /// Reject a delivery assignment.
  Future<Map<String, dynamic>> rejectDelivery(
    String deliveryId, {
    String? reason,
  }) async {
    return updateStatus(deliveryId, 'cancelled', notes: reason);
  }

  /// Update driver location on active delivery.
  ///
  /// Applies an optimistic local patch immediately so the navigation screen
  /// reflects movement without waiting for the server round-trip.
  ///
  /// Location updates are best-effort and are NOT queued for offline replay –
  /// stale coordinates mislead the customer more than no coordinates.
  Future<void> updateDriverLocation(
    String deliveryId,
    double lat,
    double lng,
  ) async {
    // Optimistic patch so the navigation screen reflects movement instantly.
    await _cache.patchCachedDelivery(deliveryId, {
      'driver_lat': lat,
      'driver_lng': lng,
      'updated_at': DateTime.now().toIso8601String(),
    });

    try {
      await _client
          .from('deliveries')
          .update({
            'driver_lat': lat,
            'driver_lng': lng,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', deliveryId);

      // Also upsert to driver_locations for real-time tracking
      await _client.from('driver_locations').upsert({
        'driver_id': _driverId,
        'lat': lat,
        'lng': lng,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } on PostgrestException catch (e) {
      // Location failure is non-fatal for network errors; the optimistic
      // patch stays (GPS noise means it is likely more accurate anyway).
      if (!_isNetworkError(e)) {
        throw _classifyDatasourceError(e, 'updateDriverLocation($deliveryId)');
      }
    }
    // Non-Postgrest network errors are silently swallowed for location updates.
  }

  // ─── Audit ─────────────────────────────────────────────────────────────

  /// Log a mock GPS detection event to the audit_log table.
  ///
  /// Best-effort: a logging failure must never prevent the fraud-blocking
  /// logic from executing, so errors are swallowed and reported to Sentry.
  Future<void> logMockGpsDetected({
    required double lat,
    required double lng,
  }) async {
    try {
      await _client.from('audit_log').insert({
        'user_id': _driverId,
        'action': 'mock_gps_detected',
        'details': {
          'lat': lat,
          'lng': lng,
          'is_mocked': true,
        },
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e, st) {
      reportError(e, stackTrace: st, hint: 'logMockGpsDetected');
    }
  }

  // ─── Error classification ────────────────────────────────────────────────

  DatasourceException _classifyDatasourceError(
    PostgrestException e,
    String context,
  ) {
    final code = int.tryParse(e.code ?? '') ?? 0;
    final DatasourceErrorType type;

    if (code == 409) {
      type = DatasourceErrorType.conflict;
    } else if (code >= 400 && code < 500) {
      type = DatasourceErrorType.validation;
    } else {
      type = DatasourceErrorType.network;
    }

    return DatasourceException(
      message: e.message,
      context: context,
      type: type,
      original: e,
    );
  }

  /// Returns `true` for errors that indicate the server was unreachable
  /// (code 0 = no response, 5xx = server-side failure).
  bool _isNetworkError(PostgrestException e) {
    final code = int.tryParse(e.code ?? '') ?? 0;
    return code == 0 || code >= 500;
  }
}

// ─── Constants ───────────────────────────────────────────────────────────────

const _terminalStatuses = {'delivered', 'failed', 'cancelled'};

// ─── Error types ─────────────────────────────────────────────────────────────

enum DatasourceErrorType { network, validation, conflict }

/// Typed exception from [DeliveryDatasource].
class DatasourceException implements Exception {
  final String message;
  final String context;
  final DatasourceErrorType type;
  final Object? original;

  const DatasourceException({
    required this.message,
    required this.context,
    required this.type,
    this.original,
  });

  bool get isConflict => type == DatasourceErrorType.conflict;
  bool get isValidation => type == DatasourceErrorType.validation;
  bool get isNetwork => type == DatasourceErrorType.network;

  @override
  String toString() => 'DatasourceException[$type] in $context: $message';
}
