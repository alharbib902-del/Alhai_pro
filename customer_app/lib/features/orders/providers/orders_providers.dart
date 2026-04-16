import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alhai_core/alhai_core.dart';

import '../../../di/injection.dart';
import '../../checkout/data/orders_datasource.dart';

/// Orders list with optional status filter.
final ordersListProvider =
    FutureProvider.family<Paginated<Order>, OrderStatus?>((ref, status) async {
      final datasource = locator<OrdersDatasource>();
      return datasource.getOrders(status: status);
    });

/// Orders list filtered by multiple statuses (server-side).
final ordersListByStatusesProvider =
    FutureProvider.family<Paginated<Order>, List<String>>((
      ref,
      statuses,
    ) async {
      final datasource = locator<OrdersDatasource>();
      return datasource.getOrdersByStatuses(statuses);
    });

/// Single order detail.
final orderDetailProvider = FutureProvider.family<Order, String>((
  ref,
  orderId,
) async {
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

/// Active orders (for home screen banner) — single query with inFilter.
final activeOrdersProvider = FutureProvider<List<Order>>((ref) async {
  final datasource = locator<OrdersDatasource>();
  return datasource.getActiveOrders();
});
