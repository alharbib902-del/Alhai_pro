import 'package:alhai_zatca/alhai_zatca.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alhai_core/alhai_core.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/sentry_service.dart';

class OrdersDatasource {
  final SupabaseClient _client;

  OrdersDatasource(this._client);

  Future<Order> createOrder(CreateOrderParams params) async {
    // 1. Reserve stock for all items at once (atomic)
    final itemsJson = params.items
        .map((item) => {'product_id': item.productId, 'qty': item.qty})
        .toList();

    final stockResult = await _client
        .rpc(
          'reserve_online_stock',
          params: {'p_store_id': params.storeId, 'p_items': itemsJson},
        )
        .timeout(AppConstants.networkTimeout);

    // Check if any items failed
    if (stockResult is Map<String, dynamic> &&
        stockResult['success'] == false) {
      final failures = stockResult['failures'];
      final count = failures is List ? failures.length : 0;
      throw Exception('بعض المنتجات غير متوفرة: $count منتجات');
    }

    // 2. Calculate totals with VAT
    double subtotal = 0;
    for (final item in params.items) {
      subtotal += item.lineTotal;
    }
    final taxAmount = VatCalculator.vatFromNet(netAmount: subtotal);
    final total = subtotal + taxAmount + params.deliveryFee;

    // 3. Insert order
    final orderMap = <String, dynamic>{
      'customer_id':
          _client.auth.currentUser?.id ??
          (throw StateError('User not authenticated')),
      'store_id': params.storeId,
      'status': 'created',
      'subtotal': subtotal,
      'tax_amount': taxAmount,
      'delivery_fee': params.deliveryFee,
      'total': total,
      'payment_method': params.paymentMethod.name,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    };
    if (params.addressId != null) {
      orderMap['address_id'] = params.addressId;
    }
    if (params.deliveryAddress != null) {
      orderMap['notes'] = params.deliveryAddress;
    }

    final orderData = await _client
        .from('orders')
        .insert(orderMap)
        .select()
        .single()
        .timeout(AppConstants.networkTimeout);

    final orderId = orderData['id'] as String;

    // 4. Insert order items (batch)
    try {
      await _client
          .from('order_items')
          .insert(
            params.items
                .map(
                  (item) => {
                    'order_id': orderId,
                    'product_id': item.productId,
                    'product_name': item.name,
                    'unit_price': item.unitPrice,
                    'qty': item.qty,
                    'total_price': item.lineTotal,
                  },
                )
                .toList(),
          )
          .timeout(AppConstants.networkTimeout);
    } catch (e, stack) {
      reportError(
        e,
        stackTrace: stack,
        hint: 'createOrder: insert order_items failed',
      );
      // Attempt to release reserved stock and clean up the order
      try {
        await _client.rpc(
          'release_reserved_stock',
          params: {'p_order_id': orderId},
        );
      } catch (releaseError, releaseStack) {
        reportError(
          releaseError,
          stackTrace: releaseStack,
          hint: 'createOrder: stock release failed for order $orderId',
        );
      }
      await _client.from('orders').delete().eq('id', orderId);
      rethrow;
    }

    return _orderFromRow(orderData, params.items);
  }

  Future<Order> getOrder(String id) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw StateError('Not authenticated');

    final data = await _client
        .from('orders')
        .select('*, order_items(*), stores(name, tax_number)')
        .eq('id', id)
        .eq('customer_id', userId)
        .maybeSingle()
        .timeout(AppConstants.networkTimeout);

    if (data == null) {
      throw Exception('Order not found or access denied');
    }

    final items = ((data['order_items'] as List?) ?? [])
        .map(
          (row) => OrderItem(
            productId: (row['product_id'] as String?) ?? '',
            name: (row['product_name'] as String?) ?? '',
            unitPrice: (row['unit_price'] as num).toDouble(),
            qty: (row['qty'] as num).toInt(),
            lineTotal: (row['total_price'] as num).toDouble(),
          ),
        )
        .toList();

    return _orderFromRow(data, items);
  }

  Future<Paginated<Order>> getOrders({
    OrderStatus? status,
    int page = 1,
    int limit = 20,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw StateError('User not authenticated');
    var query = _client
        .from('orders')
        .select('*, order_items(*), stores(name, tax_number)')
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

    final orders = (data as List<dynamic>).map((row) {
      if (row is! Map<String, dynamic>) {
        throw FormatException('Unexpected order row type: ${row.runtimeType}');
      }
      final rawItems = row['order_items'];
      final itemsList = rawItems is List ? rawItems : <dynamic>[];
      final items = itemsList
          .map(
            (r) => OrderItem(
              productId: (r['product_id'] as String?) ?? '',
              name: (r['product_name'] as String?) ?? '',
              unitPrice: (r['unit_price'] as num).toDouble(),
              qty: (r['qty'] as num).toInt(),
              lineTotal: (r['total_price'] as num).toDouble(),
            ),
          )
          .toList();

      return _orderFromRow(row, items);
    }).toList();

    return Paginated(
      items: orders,
      page: page,
      limit: limit,
      total: null,
      hasMore: orders.length == limit,
    );
  }

  /// Fetch active orders (single query with inFilter).
  Future<List<Order>> getActiveOrders() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw StateError('User not authenticated');

    final data = await _client
        .from('orders')
        .select('*, order_items(*), stores(name, tax_number)')
        .eq('customer_id', userId)
        .inFilter('status', [
          'created',
          'confirmed',
          'preparing',
          'ready',
          'out_for_delivery',
        ])
        .order('created_at', ascending: false)
        .timeout(AppConstants.networkTimeout);

    return (data as List<dynamic>).map((row) {
      if (row is! Map<String, dynamic>) {
        throw FormatException('Unexpected order row type: ${row.runtimeType}');
      }
      final rawItems = row['order_items'];
      final itemsList = rawItems is List ? rawItems : <dynamic>[];
      final items = itemsList
          .map(
            (r) => OrderItem(
              productId: (r['product_id'] as String?) ?? '',
              name: (r['product_name'] as String?) ?? '',
              unitPrice: (r['unit_price'] as num).toDouble(),
              qty: (r['qty'] as num).toInt(),
              lineTotal: (r['total_price'] as num).toDouble(),
            ),
          )
          .toList();
      return _orderFromRow(row, items);
    }).toList();
  }

  /// Fetch orders filtered by multiple statuses (single query).
  Future<Paginated<Order>> getOrdersByStatuses(
    List<String> statuses, {
    int page = 1,
    int limit = 20,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw StateError('User not authenticated');

    final from = (page - 1) * limit;
    final to = from + limit - 1;

    final data = await _client
        .from('orders')
        .select('*, order_items(*), stores(name, tax_number)')
        .eq('customer_id', userId)
        .inFilter('status', statuses)
        .order('created_at', ascending: false)
        .range(from, to)
        .timeout(AppConstants.networkTimeout);

    final orders = (data as List<dynamic>).map((row) {
      if (row is! Map<String, dynamic>) {
        throw FormatException('Unexpected order row type: ${row.runtimeType}');
      }
      final rawItems = row['order_items'];
      final itemsList = rawItems is List ? rawItems : <dynamic>[];
      final items = itemsList
          .map(
            (r) => OrderItem(
              productId: (r['product_id'] as String?) ?? '',
              name: (r['product_name'] as String?) ?? '',
              unitPrice: (r['unit_price'] as num).toDouble(),
              qty: (r['qty'] as num).toInt(),
              lineTotal: (r['total_price'] as num).toDouble(),
            ),
          )
          .toList();
      return _orderFromRow(row, items);
    }).toList();

    return Paginated(
      items: orders,
      page: page,
      limit: limit,
      total: null,
      hasMore: orders.length == limit,
    );
  }

  // ============================================================
  // BACKEND REQUIREMENT (DEFERRED):
  // Create RPC: cancel_order_by_customer(p_order_id UUID, p_reason TEXT)
  // RETURNS BOOLEAN
  // SECURITY DEFINER
  //
  // Logic:
  //   1. Verify order belongs to auth.uid()
  //   2. Check current status is cancellable (created, confirmed, preparing)
  //   3. Call release_reserved_stock(p_order_id)
  //   4. UPDATE orders SET status='cancelled', cancelled_at=NOW(), ...
  //   5. Notify merchant via realtime
  //   6. RETURN true on success, false if status not cancellable
  //
  // See: customer_app/docs/BACKEND_RPC_REQUIRED.md
  // ============================================================
  Future<void> cancelOrder(String id, {String? reason}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw StateError('Not authenticated');

    // 1. Verify ownership and check status before cancelling
    final existing = await _client
        .from('orders')
        .select('id, customer_id, status')
        .eq('id', id)
        .eq('customer_id', userId)
        .maybeSingle()
        .timeout(AppConstants.networkTimeout);

    if (existing == null) {
      throw Exception('Order not found or access denied');
    }

    final status = existing['status'] as String?;

    // Terminal statuses: cancellation not allowed
    if (status == 'delivered' || status == 'cancelled') {
      throw Exception('Cannot cancel order in status: $status');
    }

    // For status='created': direct UPDATE path (RLS allows this)
    if (status == 'created') {
      await _client
          .rpc('release_reserved_stock', params: {'p_order_id': id})
          .timeout(AppConstants.networkTimeout);

      await _client
          .from('orders')
          .update({
            'status': 'cancelled',
            'cancellation_reason': reason,
            'cancelled_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', id)
          .eq('customer_id', userId)
          .timeout(AppConstants.networkTimeout);
      return;
    }

    // For other statuses (confirmed, preparing, ready, out_for_delivery):
    // RLS policy orders_customer_update_created blocks direct UPDATE.
    // Must use backend RPC that runs with SECURITY DEFINER.
    try {
      await _client
          .rpc(
            'cancel_order_by_customer',
            params: {'p_order_id': id, 'p_reason': reason},
          )
          .timeout(AppConstants.networkTimeout);
    } on PostgrestException catch (e) {
      // RPC not yet deployed: inform user clearly
      if (e.code == '42883' || e.message.contains('function')) {
        throw Exception(
          'لا يمكن إلغاء الطلب في حالته الحالية. يرجى التواصل مع المتجر.',
        );
      }
      rethrow;
    }
  }

  Order _orderFromRow(Map<String, dynamic> row, List<OrderItem> items) {
    // Extract store data from joined stores table
    final store = row['stores'] as Map<String, dynamic>?;
    final storeName = store?['name'] as String?;
    final storeVatNumber = store?['tax_number'] as String?;

    return Order(
      id: row['id'] as String,
      orderNumber: row['order_number'] as String?,
      customerId: row['customer_id'] as String? ?? '',
      customerName: row['customer_name'] as String?,
      customerPhone: row['customer_phone'] as String?,
      storeId: row['store_id'] as String? ?? '',
      storeName: storeName,
      storeVatNumber: storeVatNumber,
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
