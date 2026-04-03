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
  final result = await datasource.getOrders(status: OrderStatus.created);
  final confirmed = await datasource.getOrders(status: OrderStatus.confirmed);
  final preparing = await datasource.getOrders(status: OrderStatus.preparing);
  final ready = await datasource.getOrders(status: OrderStatus.ready);
  final delivering =
      await datasource.getOrders(status: OrderStatus.outForDelivery);

  return [
    ...result.items,
    ...confirmed.items,
    ...preparing.items,
    ...ready.items,
    ...delivering.items,
  ];
});
