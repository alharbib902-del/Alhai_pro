/// Lite Orders Providers
///
/// Riverpod providers for Admin Lite order screens:
/// active orders, order detail, order status, delivery tracking,
/// and order history.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_auth/alhai_auth.dart';

// =============================================================================
// ORDERS PROVIDERS
// =============================================================================

/// Provider: Active/pending orders
final liteActiveOrdersProvider =
    FutureProvider.autoDispose<List<OrderWithCustomer>>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return [];

  final db = GetIt.I<AppDatabase>();
  // Fetch all pending orders with customer names
  try {
    final results = await Future.wait([
      db.ordersDao
          .getOrdersWithCustomer(storeId, status: 'confirmed', limit: 50),
      db.ordersDao
          .getOrdersWithCustomer(storeId, status: 'preparing', limit: 50),
      db.ordersDao.getOrdersWithCustomer(storeId, status: 'ready', limit: 50),
      db.ordersDao.getOrdersWithCustomer(storeId,
          status: 'out_for_delivery', limit: 50),
    ]);

    final all = <OrderWithCustomer>[];
    for (final list in results) {
      all.addAll(list);
    }
    all.sort((a, b) => b.orderDate.compareTo(a.orderDate));
    return all;
  } catch (_) {
    return [];
  }
});

/// Provider: Single order with items
final liteOrderDetailProvider = FutureProvider.autoDispose
    .family<OrderWithItems?, String>((ref, orderId) async {
  final db = GetIt.I<AppDatabase>();
  return db.ordersDao.getOrderWithItems(orderId);
});

/// Provider: Orders filtered by a specific status
final liteOrdersByStatusProvider = FutureProvider.autoDispose
    .family<List<OrderWithCustomer>, String?>((ref, status) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return [];

  final db = GetIt.I<AppDatabase>();
  return db.ordersDao
      .getOrdersWithCustomer(storeId, status: status, limit: 100);
});

/// Provider: Delivery orders (out_for_delivery)
final liteDeliveryOrdersProvider =
    FutureProvider.autoDispose<List<OrderWithCustomer>>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return [];

  final db = GetIt.I<AppDatabase>();
  try {
    final results = await Future.wait([
      db.ordersDao.getOrdersWithCustomer(storeId,
          status: 'out_for_delivery', limit: 50),
      db.ordersDao
          .getOrdersWithCustomer(storeId, status: 'delivered', limit: 20),
    ]);
    final all = <OrderWithCustomer>[];
    for (final list in results) {
      all.addAll(list);
    }
    all.sort((a, b) => b.orderDate.compareTo(a.orderDate));
    return all;
  } catch (_) {
    return [];
  }
});

/// Provider: Order history (completed + cancelled) with pagination
final liteOrderHistoryProvider =
    FutureProvider.autoDispose<List<OrderWithCustomer>>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return [];

  final db = GetIt.I<AppDatabase>();
  try {
    final results = await Future.wait([
      db.ordersDao
          .getOrdersWithCustomer(storeId, status: 'delivered', limit: 50),
      db.ordersDao
          .getOrdersWithCustomer(storeId, status: 'cancelled', limit: 50),
    ]);
    final all = <OrderWithCustomer>[];
    for (final list in results) {
      all.addAll(list);
    }
    all.sort((a, b) => b.orderDate.compareTo(a.orderDate));
    return all;
  } catch (_) {
    return [];
  }
});
