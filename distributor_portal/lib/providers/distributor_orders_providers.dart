/// Order-related providers.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models.dart';
import 'distributor_datasource_provider.dart';

// ─── Orders ─────────────────────────────────────────────────────

/// All orders — pass status filter via family.
final ordersProvider = FutureProvider.family<List<DistributorOrder>, String?>((
  ref,
  status,
) async {
  final ds = ref.watch(distributorDatasourceProvider);
  return ds.getOrders(status: status);
});

/// Single order by ID.
final orderDetailProvider = FutureProvider.family<DistributorOrder?, String>((
  ref,
  orderId,
) async {
  final ds = ref.watch(distributorDatasourceProvider);
  return ds.getOrderById(orderId);
});

/// Order items for a given order.
final orderItemsProvider =
    FutureProvider.family<List<DistributorOrderItem>, String>((
      ref,
      orderId,
    ) async {
      final ds = ref.watch(distributorDatasourceProvider);
      return ds.getOrderItems(orderId);
    });
