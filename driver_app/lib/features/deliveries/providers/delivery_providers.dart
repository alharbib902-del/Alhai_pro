import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../data/delivery_datasource.dart';

// ─── Terminal status set (used in multiple places) ───────────────────────────

const _terminalStatuses = {'delivered', 'failed', 'cancelled'};

bool _isTerminal(Map<String, dynamic> d) =>
    _terminalStatuses.contains(d['status']);

// ─── Sync-time tracking ──────────────────────────────────────────────────────

/// The last time the deliveries stream emitted a fresh batch from the server.
///
/// Set to `null` until the first successful emission; the UI can display a
/// "Last synced: X minutes ago" indicator and warn when the value is stale.
final lastSyncTimeProvider = StateProvider<DateTime?>((ref) => null);

// ─── Raw stream ──────────────────────────────────────────────────────────────

/// Stream of ALL driver deliveries from Realtime.
///
/// This is the single source of truth. Filtered providers derive from it
/// so only one Realtime channel is opened per session.
///
/// Each successful emission updates [lastSyncTimeProvider] so the UI can
/// display an offline / freshness indicator.
final myDeliveriesStreamProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  final ds = GetIt.instance<DeliveryDatasource>();
  return ds.streamMyDeliveries().map((rows) {
    // Record the time of the latest live update from the server.
    // Using `Future.microtask` avoids mutating state during a build.
    Future.microtask(
      () => ref.read(lastSyncTimeProvider.notifier).state = DateTime.now(),
    );
    return rows;
  });
});

// ─── One-time fetch providers ────────────────────────────────────────────────

/// Active deliveries (not terminal) – fetched once on demand.
final activeDeliveriesProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final ds = GetIt.instance<DeliveryDatasource>();
  return ds.getActiveDeliveries();
});

/// Completed deliveries – fetched once on demand.
final completedDeliveriesProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final ds = GetIt.instance<DeliveryDatasource>();
  return ds.getCompletedDeliveries();
});

/// Single delivery by ID – full detail projection.
final deliveryByIdProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, id) async {
  final ds = GetIt.instance<DeliveryDatasource>();
  return ds.getDelivery(id);
});

// ─── Filter state ────────────────────────────────────────────────────────────

enum DeliveryFilter { active, completed, all }

final deliveryFilterProvider = StateProvider<DeliveryFilter>(
  (ref) => DeliveryFilter.active,
);

// ─── Derived / filtered streams ──────────────────────────────────────────────

/// Active deliveries derived from the live stream.
///
/// Uses Riverpod `select()` so this provider only notifies its listeners when
/// the *active* subset actually changes, not on every stream emission.
final activeDeliveriesStreamProvider =
    Provider<AsyncValue<List<Map<String, dynamic>>>>((ref) {
  // select() compares the mapped value and skips rebuilds when unchanged.
  return ref.watch(
    myDeliveriesStreamProvider.select(
      (async) => async.whenData(
        (list) => list.where((d) => !_isTerminal(d)).toList(),
      ),
    ),
  );
});

/// Completed deliveries derived from the live stream.
final completedDeliveriesStreamProvider =
    Provider<AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return ref.watch(
    myDeliveriesStreamProvider.select(
      (async) => async.whenData(
        (list) => list.where(_isTerminal).toList(),
      ),
    ),
  );
});

/// Filtered deliveries based on [deliveryFilterProvider].
///
/// Routes to the appropriate pre-filtered provider instead of re-filtering
/// the full list on every rebuild.
final filteredDeliveriesProvider =
    Provider<AsyncValue<List<Map<String, dynamic>>>>((ref) {
  final filter = ref.watch(deliveryFilterProvider);

  switch (filter) {
    case DeliveryFilter.active:
      return ref.watch(activeDeliveriesStreamProvider);
    case DeliveryFilter.completed:
      return ref.watch(completedDeliveriesStreamProvider);
    case DeliveryFilter.all:
      return ref.watch(myDeliveriesStreamProvider);
  }
});

// ─── Actions ─────────────────────────────────────────────────────────────────

/// Update delivery status action.
///
/// Returns `{'success': true, 'offline': true}` when the device is offline
/// and the update has been queued; throws on non-retriable failure.
final updateDeliveryStatusProvider = FutureProvider.family<Map<String, dynamic>,
    ({String id, String status, String? notes})>((ref, params) async {
  final ds = GetIt.instance<DeliveryDatasource>();
  final result = await ds.updateStatus(
    params.id,
    params.status,
    notes: params.notes,
  );

  if (result['success'] != true) {
    throw Exception(result['error'] ?? 'فشل تحديث الحالة');
  }

  // Invalidate the one-shot fetch cache so detail screens stay fresh.
  ref.invalidate(activeDeliveriesProvider);
  return result;
});
