import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../data/delivery_datasource.dart';

/// Stream of all driver's deliveries (real-time).
final myDeliveriesStreamProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  final ds = GetIt.instance<DeliveryDatasource>();
  return ds.streamMyDeliveries();
});

/// Active deliveries (not completed).
final activeDeliveriesProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final ds = GetIt.instance<DeliveryDatasource>();
  return ds.getActiveDeliveries();
});

/// Completed deliveries.
final completedDeliveriesProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final ds = GetIt.instance<DeliveryDatasource>();
  return ds.getCompletedDeliveries();
});

/// Single delivery by ID.
final deliveryByIdProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, id) async {
  final ds = GetIt.instance<DeliveryDatasource>();
  return ds.getDelivery(id);
});

/// Filter state for deliveries list.
enum DeliveryFilter { active, completed, all }

final deliveryFilterProvider = StateProvider<DeliveryFilter>(
  (ref) => DeliveryFilter.active,
);

/// Filtered deliveries based on current filter.
final filteredDeliveriesProvider =
    Provider<AsyncValue<List<Map<String, dynamic>>>>((ref) {
  final filter = ref.watch(deliveryFilterProvider);
  final allDeliveries = ref.watch(myDeliveriesStreamProvider);

  return allDeliveries.whenData((deliveries) {
    switch (filter) {
      case DeliveryFilter.active:
        return deliveries
            .where((d) => !['delivered', 'failed', 'cancelled']
                .contains(d['status']))
            .toList();
      case DeliveryFilter.completed:
        return deliveries
            .where((d) =>
                ['delivered', 'failed', 'cancelled'].contains(d['status']))
            .toList();
      case DeliveryFilter.all:
        return deliveries;
    }
  });
});

/// Update delivery status action.
final updateDeliveryStatusProvider =
    FutureProvider.family<Map<String, dynamic>, ({String id, String status, String? notes})>(
        (ref, params) async {
  final ds = GetIt.instance<DeliveryDatasource>();
  final result = await ds.updateStatus(
    params.id,
    params.status,
    notes: params.notes,
  );

  if (result['success'] != true) {
    throw Exception(result['error'] ?? 'فشل تحديث الحالة');
  }

  // Refresh active deliveries
  ref.invalidate(activeDeliveriesProvider);
  return result;
});
