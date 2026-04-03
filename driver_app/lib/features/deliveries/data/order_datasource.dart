import 'package:supabase_flutter/supabase_flutter.dart';

/// Datasource for fetching order details.
class OrderDatasource {
  final SupabaseClient _client;

  OrderDatasource(this._client);

  /// Get order with items by ID.
  Future<Map<String, dynamic>?> getOrder(String orderId) async {
    return await _client
        .from('orders')
        .select('*, order_items:order_items(*)')
        .eq('id', orderId)
        .maybeSingle();
  }

  /// Get order items for an order.
  Future<List<Map<String, dynamic>>> getOrderItems(String orderId) async {
    return await _client
        .from('order_items')
        .select()
        .eq('order_id', orderId);
  }
}
