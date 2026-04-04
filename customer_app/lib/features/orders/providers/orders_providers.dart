import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

/// Real-time order status updates via Supabase Realtime.
final orderRealtimeProvider =
    StreamProvider.family<Map<String, dynamic>?, String>((ref, orderId) {
  final client = Supabase.instance.client;
  return client
      .from('orders')
      .stream(primaryKey: ['id'])
      .eq('id', orderId)
      .map((data) => data.isNotEmpty ? data.first : null);
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
