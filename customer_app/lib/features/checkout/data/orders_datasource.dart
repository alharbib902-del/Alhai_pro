import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alhai_core/alhai_core.dart';

import '../../../core/constants/app_constants.dart';

class OrdersDatasource {
  final SupabaseClient _client;

  OrdersDatasource(this._client);

  Future<Order> createOrder(CreateOrderParams params) async {
    // 1. Reserve stock for all items at once (atomic)
    final itemsJson = params.items.map((item) => {
      'product_id': item.productId,
      'qty': item.qty,
    }).toList();

    final stockResult = await _client.rpc('reserve_online_stock', params: {
      'p_store_id': params.storeId,
      'p_items': itemsJson,
    });

    // Check if any items failed
    if (stockResult is Map && stockResult['success'] == false) {
      final failures = stockResult['failures'] as List? ?? [];
      throw Exception('بعض المنتجات غير متوفرة: ${failures.length} منتجات');
    }

    // 2. Calculate totals
    double subtotal = 0;
    for (final item in params.items) {
      subtotal += item.lineTotal;
    }

    // 3. Insert order
    final orderMap = <String, dynamic>{
      'customer_id': _client.auth.currentUser!.id,
      'store_id': params.storeId,
      'status': 'created',
      'subtotal': subtotal,
      'total': subtotal,
      'payment_method': params.paymentMethod.name,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    };
    if (params.addressId != null) {
      orderMap['address_id'] = params.addressId;
    }
    if (params.deliveryAddress != null) {
      orderMap['notes'] = params.deliveryAddress;
    }

    final orderData = await _client.from('orders').insert(orderMap).select().single()
        .timeout(AppConstants.networkTimeout);

    final orderId = orderData['id'] as String;

    // 4. Insert order items
    try {
      for (final item in params.items) {
        await _client.from('order_items').insert({
          'order_id': orderId,
          'product_id': item.productId,
          'product_name': item.name,
          'unit_price': item.unitPrice,
          'qty': item.qty,
          'total_price': item.lineTotal,
        });
      }
    } catch (e) {
      // Attempt to release reserved stock and clean up the order
      try {
        await _client.rpc('release_reserved_stock', params: {
          'p_order_id': orderId,
        });
      } catch (_) {
        // Best-effort stock release
      }
      await _client.from('orders').delete().eq('id', orderId);
      rethrow;
    }

    return _orderFromRow(orderData, params.items);
  }

  Future<Order> getOrder(String id) async {
    final data = await _client
        .from('orders')
        .select('*, order_items(*)')
        .eq('id', id)
        .single()
        .timeout(AppConstants.networkTimeout);

    final items = ((data['order_items'] as List?) ?? [])
        .map((row) => OrderItem(
              productId: (row['product_id'] as String?) ?? '',
              name: (row['product_name'] as String?) ?? '',
              unitPrice: (row['unit_price'] as num).toDouble(),
              qty: (row['qty'] as num).toInt(),
              lineTotal: (row['total_price'] as num).toDouble(),
            ))
        .toList();

    return _orderFromRow(data, items);
  }

  Future<Paginated<Order>> getOrders({
    OrderStatus? status,
    int page = 1,
    int limit = 20,
  }) async {
    final userId = _client.auth.currentUser!.id;
    var query = _client
        .from('orders')
        .select('*, order_items(*)')
        .eq('customer_id', userId);

    if (status != null) {
      query = query.eq('status', status.name);
    }

    final from = (page - 1) * limit;
    final to = from + limit - 1;

    final data = await query
        .order('created_at', ascending: false)
        .range(from, to)
        .timeout(AppConstants.networkTimeout);

    final orders = (data as List).map((row) {
      final items = ((row['order_items'] as List?) ?? [])
          .map((r) => OrderItem(
                productId: (r['product_id'] as String?) ?? '',
                name: (r['product_name'] as String?) ?? '',
                unitPrice: (r['unit_price'] as num).toDouble(),
                qty: (r['qty'] as num).toInt(),
                lineTotal: (r['total_price'] as num).toDouble(),
              ))
          .toList();

      return _orderFromRow(row as Map<String, dynamic>, items);
    }).toList();

    return Paginated(
      items: orders,
      page: page,
      limit: limit,
      total: null,
      hasMore: orders.length == limit,
    );
  }

  Future<void> cancelOrder(String id, {String? reason}) async {
    // 1. Release reserved stock
    await _client.rpc('release_reserved_stock', params: {
      'p_order_id': id,
    });

    // 2. Update order status
    await _client.from('orders').update({
      'status': 'cancelled',
      'cancellation_reason': reason,
      'cancelled_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', id);
  }

  Order _orderFromRow(Map<String, dynamic> row, List<OrderItem> items) {
    return Order(
      id: row['id'] as String,
      orderNumber: row['order_number'] as String?,
      customerId: row['customer_id'] as String? ?? '',
      customerName: row['customer_name'] as String?,
      customerPhone: row['customer_phone'] as String?,
      storeId: row['store_id'] as String? ?? '',
      storeName: row['store_name'] as String?,
      status: OrderStatus.values.firstWhere(
        (s) => s.name == (row['status'] as String? ?? 'created'),
        orElse: () => OrderStatus.created,
      ),
      items: items,
      subtotal: (row['subtotal'] as num?)?.toDouble() ?? 0,
      discount: (row['discount_amount'] as num?)?.toDouble() ?? 0,
      deliveryFee: (row['delivery_fee'] as num?)?.toDouble() ?? 0,
      tax: (row['tax_amount'] as num?)?.toDouble() ?? 0,
      total: (row['total'] as num?)?.toDouble() ?? 0,
      paymentMethod: PaymentMethod.values.firstWhere(
        (p) => p.name == (row['payment_method'] as String? ?? 'cash'),
        orElse: () => PaymentMethod.cash,
      ),
      isPaid: row['payment_status'] == 'paid',
      addressId: row['address_id'] as String?,
      notes: row['notes'] as String?,
      cancellationReason: row['cancellation_reason'] as String?,
      confirmedAt: row['confirmed_at'] != null
          ? DateTime.parse(row['confirmed_at'] as String)
          : null,
      deliveredAt: row['completed_at'] != null
          ? DateTime.parse(row['completed_at'] as String)
          : null,
      cancelledAt: row['cancelled_at'] != null
          ? DateTime.parse(row['cancelled_at'] as String)
          : null,
      createdAt: DateTime.parse(
        row['created_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
