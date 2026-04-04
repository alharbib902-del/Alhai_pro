/// Supabase datasource for the Distributor Portal.
///
/// All queries are scoped to the current distributor's organization.
/// Tables used: orders, order_items, products, stores, organizations, categories.
library;

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/supabase/supabase_client.dart';
import 'models.dart';

class DistributorDatasource {
  DistributorDatasource();

  SupabaseClient get _client => AppSupabase.client;

  // ─── Orders ─────────────────────────────────────────────────────

  /// Fetch orders for this distributor's organization, with optional status filter.
  Future<List<DistributorOrder>> getOrders({String? status}) async {
    try {
      var query = _client
          .from('orders')
          .select('*, stores(name)')
          .eq('type', 'purchase')
          .order('created_at', ascending: false);

      if (status != null && status.isNotEmpty) {
        query = query.eq('status', status);
      }

      final data = await query;
      return (data as List)
          .map((json) => DistributorOrder.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) debugPrint('getOrders error: $e');
      return [];
    }
  }

  /// Fetch a single order by ID with its items.
  Future<DistributorOrder?> getOrderById(String orderId) async {
    try {
      final data = await _client
          .from('orders')
          .select('*, stores(name)')
          .eq('id', orderId)
          .maybeSingle();

      if (data == null) return null;
      return DistributorOrder.fromJson(data);
    } catch (e) {
      if (kDebugMode) debugPrint('getOrderById error: $e');
      return null;
    }
  }

  /// Fetch order items for a given order.
  Future<List<DistributorOrderItem>> getOrderItems(String orderId) async {
    try {
      final data = await _client
          .from('order_items')
          .select('*, products(name, barcode)')
          .eq('order_id', orderId);

      return (data as List)
          .map((json) => DistributorOrderItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) debugPrint('getOrderItems error: $e');
      return [];
    }
  }

  /// Update an order's status (approve/reject) and optionally set distributor prices.
  Future<bool> updateOrderStatus(
    String orderId,
    String newStatus, {
    String? notes,
    Map<String, double>? itemPrices,
  }) async {
    try {
      await _client.from('orders').update({
        'status': newStatus,
        if (notes != null) 'notes': notes,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', orderId);

      // Update individual item prices if provided
      if (itemPrices != null) {
        for (final entry in itemPrices.entries) {
          await _client.from('order_items').update({
            'distributor_price': entry.value,
          }).eq('id', entry.key);
        }
      }

      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('updateOrderStatus error: $e');
      return false;
    }
  }

  // ─── Products ───────────────────────────────────────────────────

  /// Fetch all products for this distributor.
  Future<List<DistributorProduct>> getProducts() async {
    try {
      final data = await _client
          .from('products')
          .select('*, categories(name)')
          .order('name');

      return (data as List)
          .map((json) => DistributorProduct.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) debugPrint('getProducts error: $e');
      return [];
    }
  }

  /// Update product price.
  Future<bool> updateProductPrice(String productId, double newPrice) async {
    try {
      await _client.from('products').update({
        'price': newPrice,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', productId);
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('updateProductPrice error: $e');
      return false;
    }
  }

  /// Batch update product prices.
  Future<bool> updateProductPrices(Map<String, double> prices) async {
    try {
      for (final entry in prices.entries) {
        await _client.from('products').update({
          'price': entry.value,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', entry.key);
      }
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('updateProductPrices error: $e');
      return false;
    }
  }

  // ─── Dashboard / KPIs ─────────────────────────────────────────

  /// Build dashboard data from orders.
  Future<DashboardKpis> getDashboardKpis() async {
    try {
      final allOrders = await getOrders();

      final totalOrders = allOrders.length;
      final pendingOrders =
          allOrders.where((o) => o.status == 'sent' || o.status == 'draft').length;
      final approvedOrders =
          allOrders.where((o) => o.status == 'approved').length;
      final totalRevenue =
          allOrders.fold<double>(0, (sum, o) => sum + o.total);

      // Group by month for chart
      final monthMap = <int, double>{};
      for (final order in allOrders) {
        final month = order.createdAt.month;
        monthMap[month] = (monthMap[month] ?? 0) + order.total;
      }

      const monthNames = [
        '', 'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
        'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
      ];

      final monthlySales = monthMap.entries
          .map((e) => MonthlySales(monthNames[e.key], e.value))
          .toList()
        ..sort((a, b) =>
            monthNames.indexOf(a.month).compareTo(monthNames.indexOf(b.month)));

      // Recent 5 orders
      final recentOrders = allOrders.take(5).toList();

      return DashboardKpis(
        totalOrders: totalOrders,
        pendingOrders: pendingOrders,
        approvedOrders: approvedOrders,
        totalRevenue: totalRevenue,
        monthlySales: monthlySales,
        recentOrders: recentOrders,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('getDashboardKpis error: $e');
      return const DashboardKpis(
        totalOrders: 0,
        pendingOrders: 0,
        approvedOrders: 0,
        totalRevenue: 0,
        monthlySales: [],
        recentOrders: [],
      );
    }
  }

  // ─── Reports ──────────────────────────────────────────────────

  /// Fetch report data for a given period.
  Future<ReportData> getReportData({required String period}) async {
    try {
      final now = DateTime.now();
      DateTime startDate;

      switch (period) {
        case 'day':
          startDate = DateTime(now.year, now.month, now.day);
          break;
        case 'week':
          startDate = now.subtract(const Duration(days: 7));
          break;
        case 'month':
          startDate = DateTime(now.year, now.month, 1);
          break;
        case 'year':
          startDate = DateTime(now.year, 1, 1);
          break;
        default:
          startDate = now.subtract(const Duration(days: 7));
      }

      final orders = await _client
          .from('orders')
          .select('*, stores(name)')
          .eq('type', 'purchase')
          .gte('created_at', startDate.toIso8601String())
          .order('created_at', ascending: false);

      final orderList = (orders as List)
          .map((json) => DistributorOrder.fromJson(json as Map<String, dynamic>))
          .toList();

      final totalSales = orderList.fold<double>(0, (sum, o) => sum + o.total);
      final orderCount = orderList.length;
      final avgOrderValue = orderCount > 0 ? totalSales / orderCount : 0.0;

      // Daily sales aggregation
      final dailyMap = <String, double>{};
      const dayNames = ['سبت', 'أحد', 'اثن', 'ثلا', 'أربع', 'خمي', 'جمع'];
      for (final order in orderList) {
        // Saturday = 6 in Dart, we want it at index 0
        final dayIndex = (order.createdAt.weekday % 7);
        final dayName = dayNames[dayIndex];
        dailyMap[dayName] = (dailyMap[dayName] ?? 0) + order.total;
      }
      final dailySales = dayNames
          .map((d) => DailySales(d, dailyMap[d] ?? 0))
          .toList();

      // Top products from order_items in this period
      final itemsData = await _client
          .from('order_items')
          .select('product_id, quantity, unit_price, products(name)')
          .filter('order_id', 'in',
              orderList.map((o) => o.id).toList());

      final productStats = <String, (String name, int count, double revenue)>{};
      for (final item in (itemsData as List)) {
        final productId = item['product_id'] as String? ?? '';
        final name = item['products'] is Map
            ? (item['products']['name'] as String? ?? '')
            : '';
        final qty = (item['quantity'] as num?)?.toInt() ?? 0;
        final price = (item['unit_price'] as num?)?.toDouble() ?? 0;
        final existing = productStats[productId];
        if (existing != null) {
          productStats[productId] = (
            name.isNotEmpty ? name : existing.$1,
            existing.$2 + qty,
            existing.$3 + (qty * price),
          );
        } else {
          productStats[productId] = (name, qty, qty * price);
        }
      }

      final topProducts = productStats.values
          .map((e) => TopProduct(e.$1, e.$2, e.$3))
          .toList()
        ..sort((a, b) => b.revenue.compareTo(a.revenue));

      return ReportData(
        totalSales: totalSales,
        orderCount: orderCount,
        avgOrderValue: avgOrderValue,
        topProduct: topProducts.isNotEmpty ? topProducts.first.name : '-',
        topProductOrders:
            topProducts.isNotEmpty ? topProducts.first.orderCount : 0,
        dailySales: dailySales,
        topProducts: topProducts.take(5).toList(),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('getReportData error: $e');
      return const ReportData(
        totalSales: 0,
        orderCount: 0,
        avgOrderValue: 0,
        topProduct: '-',
        topProductOrders: 0,
        dailySales: [],
        topProducts: [],
      );
    }
  }

  // ─── Settings ─────────────────────────────────────────────────

  /// Fetch organization settings for the current distributor.
  Future<OrgSettings?> getOrgSettings() async {
    try {
      final userId = AppSupabase.currentUserId;
      if (userId == null) return null;

      // Get org_id from user profile, then fetch org
      final profile = await _client
          .from('profiles')
          .select('org_id')
          .eq('id', userId)
          .maybeSingle();

      if (profile == null) return null;

      final orgId = profile['org_id'] as String?;
      if (orgId == null) return null;

      final orgData = await _client
          .from('organizations')
          .select()
          .eq('id', orgId)
          .maybeSingle();

      if (orgData == null) return null;
      return OrgSettings.fromJson(orgData);
    } catch (e) {
      if (kDebugMode) debugPrint('getOrgSettings error: $e');
      return null;
    }
  }

  /// Update organization settings.
  Future<bool> updateOrgSettings(OrgSettings settings) async {
    try {
      await _client
          .from('organizations')
          .update(settings.toJson())
          .eq('id', settings.id);
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('updateOrgSettings error: $e');
      return false;
    }
  }

  // ─── Categories (for product filtering) ───────────────────────

  /// Fetch distinct product categories.
  Future<List<String>> getCategories() async {
    try {
      final data = await _client
          .from('categories')
          .select('name')
          .order('name');

      return (data as List)
          .map((json) => (json as Map<String, dynamic>)['name'] as String? ?? '')
          .where((name) => name.isNotEmpty)
          .toList();
    } catch (e) {
      if (kDebugMode) debugPrint('getCategories error: $e');
      return [];
    }
  }
}
