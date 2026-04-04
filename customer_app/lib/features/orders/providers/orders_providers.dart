import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_core/alhai_core.dart';

import '../../../di/injection.dart';
import '../../checkout/data/orders_datasource.dart';

/// Orders list with optional status filter.
final ordersListProvider =
    FutureProvider.family<Paginated<Order>, OrderStatus?>(
  (ref, status) async {
    final datasource = locator<OrdersDatasource>();
    return datasource.getOrders(status: status);
  },
);

/// Single order detail.
final orderDetailProvider =
    FutureProvider.family<Order, String>((ref, orderId) async {
  final datasource = locator<OrdersDatasource>();
  return datasource.getOrder(orderId);
});

/// Active orders (for home screen banner).
final activeOrdersProvider = FutureProvider<List<Order>>((ref) async {
  final datasource = locator<OrdersDatasource>();
  final results = await Future.wait([
    datasource.getOrders(status: OrderStatus.created),
    datasource.getOrders(status: OrderStatus.confirmed),
    datasource.getOrders(status: OrderStatus.preparing),
    datasource.getOrders(status: OrderStatus.ready),
    datasource.getOrders(status: OrderStatus.outForDelivery),
  ]);
  return results.expand((p) => p.items).toList();
});
