/// Supabase datasource for the Distributor Portal.
///
/// All queries are scoped to the current distributor's organization via org_id.
/// Tables used: orders, order_items, products, stores, organizations, categories.
library;

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/supabase/supabase_client.dart';
import 'models.dart';

// ─── Error Types ──────────────────────────────────────────────────

/// Categorized error types for meaningful error handling.
enum DatasourceErrorType {
  network,
  auth,
  notFound,
  validation,
  unknown,
}

/// A categorized error from datasource operations.
class DatasourceError implements Exception {
  final DatasourceErrorType type;
  final String message;
  final Object? originalError;

  const DatasourceError({
    required this.type,
    required this.message,
    this.originalError,
  });

  @override
  String toString() => 'DatasourceError($type): $message';
}

/// Categorize an exception into a [DatasourceErrorType].
DatasourceError _categorizeError(Object error, String operation) {
  if (error is AuthException) {
    return DatasourceError(
      type: DatasourceErrorType.auth,
      message: 'Authentication error during $operation',
      originalError: error,
    );
  }
  if (error is PostgrestException) {
    if (error.code == 'PGRST116' || error.code == '404') {
      return DatasourceError(
        type: DatasourceErrorType.notFound,
        message: 'Resource not found during $operation',
        originalError: error,
      );
    }
    if (error.code == '23505' ||
        error.code == '23503' ||
        error.code == '23502') {
      return DatasourceError(
        type: DatasourceErrorType.validation,
        message: 'Validation error during $operation',
        originalError: error,
      );
    }
    return DatasourceError(
      type: DatasourceErrorType.unknown,
      message: 'Database error during $operation',
      originalError: error,
    );
  }
  // Network-related errors (SocketException, TimeoutException, etc.)
  final errorStr = error.toString().toLowerCase();
  if (errorStr.contains('socket') ||
      errorStr.contains('timeout') ||
      errorStr.contains('connection') ||
      errorStr.contains('network') ||
      errorStr.contains('host lookup')) {
    return DatasourceError(
      type: DatasourceErrorType.network,
      message: 'Network error during $operation',
      originalError: error,
    );
  }
  return DatasourceError(
    type: DatasourceErrorType.unknown,
    message: 'Unknown error during $operation',
    originalError: error,
  );
}

// ─── Validation helpers ──────────────────────────────────────────

/// Price bounds: min 0.01, max 999999.99
const double minPrice = 0.01;
const double maxPrice = 999999.99;

/// Max lengths for text fields.
const int maxNotesLength = 500;
const int maxDeliveryZonesLength = 200;

/// Valid order status transitions for distributor actions.
const Map<String, Set<String>> validStatusTransitions = {
  'sent': {'approved', 'rejected'},
  'pending': {'approved', 'rejected'},
  'draft': {'sent'},
  'approved': {'received'},
};

/// Validate a price value is within bounds.
String? validatePrice(double price) {
  if (price < minPrice) return 'Price must be at least $minPrice';
  if (price > maxPrice) return 'Price must be at most $maxPrice';
  return null;
}

/// Validate a status transition is allowed.
String? validateStatusTransition(String currentStatus, String newStatus) {
  final allowed = validStatusTransitions[currentStatus];
  if (allowed == null || !allowed.contains(newStatus)) {
    return 'Cannot transition from "$currentStatus" to "$newStatus"';
  }
  return null;
}

/// Validate text length.
String? validateTextLength(String text, int maxLength, String fieldName) {
  if (text.length > maxLength) {
    return '$fieldName must be at most $maxLength characters';
  }
  return null;
}

/// Validate email format.
bool isValidEmail(String email) {
  return RegExp(r'^[\w\-\.+]+@([\w\-]+\.)+[\w\-]{2,}$').hasMatch(email);
}

/// Validate phone number format (digits, +, spaces, dashes).
bool isValidPhone(String phone) {
  return RegExp(r'^[\d\s\-\+\(\)]{7,20}$').hasMatch(phone);
}

// ─── Cache Entry ────────────────────────────────────────────────

/// Simple in-memory cache entry with TTL-based expiry.
class _CacheEntry<T> {
  final T data;
  final DateTime expiry;
  _CacheEntry(this.data, this.expiry);
  bool get isExpired => DateTime.now().isAfter(expiry);
}

// ─── Rate Limiter ────────────────────────────────────────────────

/// Simple client-side rate limiter to prevent rapid-fire API mutations.
class _RateLimiter {
  _RateLimiter();

  final Map<String, DateTime> _lastCalls = {};

  /// Minimum interval between same operations.
  static const Duration _minInterval = Duration(seconds: 2);

  /// Check if the operation is allowed. Throws if rate limited.
  void check(String operationKey) {
    final now = DateTime.now();
    final lastCall = _lastCalls[operationKey];
    if (lastCall != null && now.difference(lastCall) < _minInterval) {
      throw DatasourceError(
        type: DatasourceErrorType.validation,
        message:
            'Too many requests. Please wait before retrying this operation.',
      );
    }
    _lastCalls[operationKey] = now;
  }

  /// Clear rate limit state (e.g. on logout).
  void clear() => _lastCalls.clear();
}

// ─── Datasource ───────────────────────────────────────────────────

class DistributorDatasource {
  DistributorDatasource();

  SupabaseClient get _client => AppSupabase.client;

  /// Rate limiter for mutation operations.
  final _rateLimiter = _RateLimiter();

  /// Cached org_id for the current session.
  String? _cachedOrgId;

  /// Cache of store IDs belonging to the org.
  List<String>? _cachedStoreIds;

  // ─── TTL Cache for read-heavy queries ─────────────────────────
  _CacheEntry<List<String>>? _categoriesCache;
  _CacheEntry<List<DistributorProduct>>? _productsCache;
  _CacheEntry<OrgSettings?>? _orgSettingsCache;

  static const Duration _categoriesTtl = Duration(minutes: 5);
  static const Duration _productsTtl = Duration(minutes: 2);
  static const Duration _orgSettingsTtl = Duration(minutes: 5);

  /// Get the current user's org_id from their profile.
  /// Caches the result for the session to avoid repeated queries.
  Future<String?> getOrgId() async {
    if (_cachedOrgId != null) return _cachedOrgId;

    final userId = AppSupabase.currentUserId;
    if (userId == null) return null;

    try {
      final profile = await _client
          .from('profiles')
          .select('org_id')
          .eq('id', userId)
          .maybeSingle();

      if (profile != null) {
        _cachedOrgId = profile['org_id'] as String?;
      }
      return _cachedOrgId;
    } catch (e) {
      if (kDebugMode) debugPrint('getOrgId error: $e');
      return null;
    }
  }

  /// Clear cached org_id, store IDs, TTL caches, and rate limiter (e.g. on logout).
  void clearCache() {
    _cachedOrgId = null;
    _cachedStoreIds = null;
    _categoriesCache = null;
    _productsCache = null;
    _orgSettingsCache = null;
    _rateLimiter.clear();
  }

  /// Invalidate product and category caches after mutations.
  void invalidateProductCaches() {
    _productsCache = null;
    _categoriesCache = null;
  }

  /// Get store IDs that belong to the given organization.
  Future<List<String>> _getOrgStoreIds(String orgId) async {
    if (_cachedStoreIds != null) return _cachedStoreIds!;

    try {
      final stores = await _client
          .from('stores')
          .select('id')
          .eq('org_id', orgId);

      _cachedStoreIds = (stores as List)
          .map((s) => (s as Map<String, dynamic>)['id'] as String)
          .toList();
      return _cachedStoreIds!;
    } catch (e) {
      if (kDebugMode) debugPrint('_getOrgStoreIds error: $e');
      return [];
    }
  }

  /// Require org_id or throw auth error.
  Future<String> _requireOrgId(String operation) async {
    final orgId = await getOrgId();
    if (orgId == null) {
      throw const DatasourceError(
        type: DatasourceErrorType.auth,
        message: 'No organization found for current user.',
      );
    }
    return orgId;
  }

  // ─── Orders ─────────────────────────────────────────────────────

  /// Fetch orders for this distributor's organization, with optional status filter.
  /// Supports pagination with [limit] and [offset].
  Future<List<DistributorOrder>> getOrders({
    String? status,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final orgId = await _requireOrgId('getOrders');
      final storeIds = await _getOrgStoreIds(orgId);
      if (storeIds.isEmpty) return [];

      var query = _client
          .from('orders')
          .select('*, stores(name)')
          .eq('type', 'purchase')
          .filter('store_id', 'in', storeIds);

      if (status != null && status.isNotEmpty) {
        query = query.eq('status', status);
      }

      final data = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
      return (data as List)
          .map((json) =>
              DistributorOrder.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is DatasourceError) rethrow;
      final error = _categorizeError(e, 'getOrders');
      if (kDebugMode) debugPrint('$error');
      throw error;
    }
  }

  /// Fetch a single order by ID, scoped to the org's stores.
  Future<DistributorOrder?> getOrderById(String orderId) async {
    try {
      final orgId = await _requireOrgId('getOrderById');
      final storeIds = await _getOrgStoreIds(orgId);
      if (storeIds.isEmpty) return null;

      final data = await _client
          .from('orders')
          .select('*, stores(name)')
          .eq('id', orderId)
          .filter('store_id', 'in', storeIds)
          .maybeSingle();

      if (data == null) return null;
      return DistributorOrder.fromJson(data);
    } catch (e) {
      if (e is DatasourceError) rethrow;
      final error = _categorizeError(e, 'getOrderById');
      if (kDebugMode) debugPrint('$error');
      throw error;
    }
  }

  /// Fetch order items for a given order (verified to belong to org).
  Future<List<DistributorOrderItem>> getOrderItems(String orderId) async {
    try {
      // Verify order belongs to this org first
      final order = await getOrderById(orderId);
      if (order == null) {
        throw const DatasourceError(
          type: DatasourceErrorType.notFound,
          message: 'Order not found or does not belong to your organization.',
        );
      }

      final data = await _client
          .from('order_items')
          .select('*, products(name, barcode)')
          .eq('order_id', orderId);

      return (data as List)
          .map((json) =>
              DistributorOrderItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is DatasourceError) rethrow;
      final error = _categorizeError(e, 'getOrderItems');
      if (kDebugMode) debugPrint('$error');
      throw error;
    }
  }

  /// Update an order's status (approve/reject) with validation.
  /// Item price updates run in parallel via Future.wait.
  Future<bool> updateOrderStatus(
    String orderId,
    String newStatus, {
    String? notes,
    Map<String, double>? itemPrices,
  }) async {
    try {
      _rateLimiter.check('updateOrderStatus');

      // Validate notes length
      if (notes != null && notes.isNotEmpty) {
        final notesError = validateTextLength(notes, maxNotesLength, 'Notes');
        if (notesError != null) {
          throw DatasourceError(
            type: DatasourceErrorType.validation,
            message: notesError,
          );
        }
      }

      // Validate item prices bounds
      if (itemPrices != null) {
        for (final entry in itemPrices.entries) {
          final priceError = validatePrice(entry.value);
          if (priceError != null) {
            throw DatasourceError(
              type: DatasourceErrorType.validation,
              message: priceError,
            );
          }
        }
      }

      // Verify the order belongs to the org and check status transition
      final order = await getOrderById(orderId);
      if (order == null) {
        throw const DatasourceError(
          type: DatasourceErrorType.notFound,
          message: 'Order not found or does not belong to your organization.',
        );
      }

      final transitionError = validateStatusTransition(order.status, newStatus);
      if (transitionError != null) {
        throw DatasourceError(
          type: DatasourceErrorType.validation,
          message: transitionError,
        );
      }

      // Use RPC for atomic transaction: order status + item prices
      final pricesJsonb = itemPrices != null && itemPrices.isNotEmpty
          ? Map<String, dynamic>.fromEntries(
              itemPrices.entries.map((e) => MapEntry(e.key, e.value)))
          : null;

      await _client.rpc('update_order_with_items', params: {
        'p_order_id': orderId,
        'p_status': newStatus,
        'p_notes': notes,
        'p_item_prices': pricesJsonb,
      });

      return true;
    } catch (e) {
      if (e is DatasourceError) {
        if (kDebugMode) debugPrint('updateOrderStatus: $e');
        return false;
      }
      final error = _categorizeError(e, 'updateOrderStatus');
      if (kDebugMode) debugPrint('$error');
      return false;
    }
  }

  // ─── Products ───────────────────────────────────────────────────

  /// Fetch products for this distributor's org with pagination.
  /// Results are cached with a 2-minute TTL for default queries.
  Future<List<DistributorProduct>> getProducts({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      // Return cached data for default pagination if available
      if (offset == 0 && limit == 50 &&
          _productsCache != null && !_productsCache!.isExpired) {
        return _productsCache!.data;
      }

      final orgId = await _requireOrgId('getProducts');

      final data = await _client
          .from('products')
          .select('*, categories(name)')
          .eq('org_id', orgId)
          .order('name')
          .range(offset, offset + limit - 1);

      final results = (data as List)
          .map((json) =>
              DistributorProduct.fromJson(json as Map<String, dynamic>))
          .toList();

      // Cache default pagination results
      if (offset == 0 && limit == 50) {
        _productsCache = _CacheEntry(
          results,
          DateTime.now().add(_productsTtl),
        );
      }

      return results;
    } catch (e) {
      if (e is DatasourceError) rethrow;
      final error = _categorizeError(e, 'getProducts');
      if (kDebugMode) debugPrint('$error');
      throw error;
    }
  }

  /// Update product price with bounds validation and org_id scoping.
  Future<bool> updateProductPrice(String productId, double newPrice) async {
    try {
      _rateLimiter.check('updateProductPrice');

      final priceError = validatePrice(newPrice);
      if (priceError != null) {
        throw DatasourceError(
          type: DatasourceErrorType.validation,
          message: priceError,
        );
      }

      final orgId = await _requireOrgId('updateProductPrice');

      await _client.from('products').update({
        'price': newPrice,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', productId).eq('org_id', orgId);

      return true;
    } catch (e) {
      if (e is DatasourceError) {
        if (kDebugMode) debugPrint('updateProductPrice: $e');
        return false;
      }
      final error = _categorizeError(e, 'updateProductPrice');
      if (kDebugMode) debugPrint('$error');
      return false;
    }
  }

  /// Batch update product prices with validation and org_id scoping.
  Future<bool> updateProductPrices(Map<String, double> prices) async {
    try {
      _rateLimiter.check('updateProductPrices');

      // Validate all prices first
      for (final entry in prices.entries) {
        final priceError = validatePrice(entry.value);
        if (priceError != null) {
          throw DatasourceError(
            type: DatasourceErrorType.validation,
            message: 'Invalid price for product: $priceError',
          );
        }
      }

      final orgId = await _requireOrgId('updateProductPrices');

      // Use RPC for atomic batch update in a single transaction
      final pricesJsonb = Map<String, dynamic>.fromEntries(
          prices.entries.map((e) => MapEntry(e.key, e.value)));

      await _client.rpc('batch_update_product_prices', params: {
        'p_org_id': orgId,
        'p_prices': pricesJsonb,
      });

      // Invalidate product cache after mutation
      invalidateProductCaches();

      return true;
    } catch (e) {
      if (e is DatasourceError) {
        if (kDebugMode) debugPrint('updateProductPrices: $e');
        return false;
      }
      final error = _categorizeError(e, 'updateProductPrices');
      if (kDebugMode) debugPrint('$error');
      return false;
    }
  }

  // ─── Dashboard / KPIs ─────────────────────────────────────────

  /// Build dashboard data from recent orders (last 6 months), scoped to org.
  Future<DashboardKpis> getDashboardKpis() async {
    try {
      final orgId = await _requireOrgId('getDashboardKpis');
      final storeIds = await _getOrgStoreIds(orgId);
      if (storeIds.isEmpty) {
        return const DashboardKpis(
          totalOrders: 0,
          pendingOrders: 0,
          approvedOrders: 0,
          totalRevenue: 0,
          monthlySales: [],
          recentOrders: [],
        );
      }

      final sixMonthsAgo =
          DateTime.now().subtract(const Duration(days: 180));

      final data = await _client
          .from('orders')
          .select('*, stores(name)')
          .eq('type', 'purchase')
          .filter('store_id', 'in', storeIds)
          .gte('created_at', sixMonthsAgo.toIso8601String())
          .order('created_at', ascending: false)
          .range(0, 499);

      final allOrders = (data as List)
          .map((json) =>
              DistributorOrder.fromJson(json as Map<String, dynamic>))
          .toList();

      final totalOrders = allOrders.length;
      final pendingOrders = allOrders
          .where((o) => o.status == 'sent' || o.status == 'draft')
          .length;
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
        '',
        'يناير',
        'فبراير',
        'مارس',
        'أبريل',
        'مايو',
        'يونيو',
        'يوليو',
        'أغسطس',
        'سبتمبر',
        'أكتوبر',
        'نوفمبر',
        'ديسمبر',
      ];

      final monthlySales = monthMap.entries
          .map((e) => MonthlySales(monthNames[e.key], e.value))
          .toList()
        ..sort((a, b) => monthNames
            .indexOf(a.month)
            .compareTo(monthNames.indexOf(b.month)));

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
      if (e is DatasourceError) {
        if (kDebugMode) debugPrint('getDashboardKpis: $e');
      } else {
        final error = _categorizeError(e, 'getDashboardKpis');
        if (kDebugMode) debugPrint('$error');
      }
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

  /// Fetch report data for a given period, scoped to org.
  Future<ReportData> getReportData({
    required String period,
    int limit = 200,
    int offset = 0,
  }) async {
    try {
      final orgId = await _requireOrgId('getReportData');
      final storeIds = await _getOrgStoreIds(orgId);
      if (storeIds.isEmpty) {
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
          .filter('store_id', 'in', storeIds)
          .gte('created_at', startDate.toIso8601String())
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final orderList = (orders as List)
          .map((json) =>
              DistributorOrder.fromJson(json as Map<String, dynamic>))
          .toList();

      final totalSales =
          orderList.fold<double>(0, (sum, o) => sum + o.total);
      final orderCount = orderList.length;
      final avgOrderValue =
          orderCount > 0 ? totalSales / orderCount : 0.0;

      // Daily sales aggregation
      final dailyMap = <String, double>{};
      const dayNames = ['سبت', 'أحد', 'اثن', 'ثلا', 'أربع', 'خمي', 'جمع'];
      for (final order in orderList) {
        final dayIndex = (order.createdAt.weekday % 7);
        final dayName = dayNames[dayIndex];
        dailyMap[dayName] = (dailyMap[dayName] ?? 0) + order.total;
      }
      final dailySales =
          dayNames.map((d) => DailySales(d, dailyMap[d] ?? 0)).toList();

      // Top products from order_items in this period
      final orderIds = orderList.map((o) => o.id).toList();
      if (orderIds.isEmpty) {
        return ReportData(
          totalSales: totalSales,
          orderCount: orderCount,
          avgOrderValue: avgOrderValue,
          topProduct: '-',
          topProductOrders: 0,
          dailySales: dailySales,
          topProducts: const [],
        );
      }

      final itemsData = await _client
          .from('order_items')
          .select('product_id, quantity, unit_price, products(name)')
          .filter('order_id', 'in', orderIds);

      final productStats =
          <String, (String name, int count, double revenue)>{};
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
        topProduct:
            topProducts.isNotEmpty ? topProducts.first.name : '-',
        topProductOrders:
            topProducts.isNotEmpty ? topProducts.first.orderCount : 0,
        dailySales: dailySales,
        topProducts: topProducts.take(5).toList(),
      );
    } catch (e) {
      if (e is DatasourceError) {
        if (kDebugMode) debugPrint('getReportData: $e');
      } else {
        final error = _categorizeError(e, 'getReportData');
        if (kDebugMode) debugPrint('$error');
      }
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
  /// Results are cached with a 5-minute TTL.
  Future<OrgSettings?> getOrgSettings() async {
    try {
      if (_orgSettingsCache != null && !_orgSettingsCache!.isExpired) {
        return _orgSettingsCache!.data;
      }

      final orgId = await _requireOrgId('getOrgSettings');

      final orgData = await _client
          .from('organizations')
          .select()
          .eq('id', orgId)
          .maybeSingle();

      if (orgData == null) return null;
      final settings = OrgSettings.fromJson(orgData);

      _orgSettingsCache = _CacheEntry(
        settings,
        DateTime.now().add(_orgSettingsTtl),
      );

      return settings;
    } catch (e) {
      if (e is DatasourceError) rethrow;
      final error = _categorizeError(e, 'getOrgSettings');
      if (kDebugMode) debugPrint('$error');
      throw error;
    }
  }

  /// Update organization settings with validation.
  Future<bool> updateOrgSettings(OrgSettings settings) async {
    try {
      _rateLimiter.check('updateOrgSettings');

      final orgId = await _requireOrgId('updateOrgSettings');

      // Ensure user can only update their own org
      if (settings.id != orgId) {
        throw const DatasourceError(
          type: DatasourceErrorType.auth,
          message: 'Cannot update settings for another organization.',
        );
      }

      // Validate email if provided
      if (settings.email != null && settings.email!.isNotEmpty) {
        if (!isValidEmail(settings.email!)) {
          throw const DatasourceError(
            type: DatasourceErrorType.validation,
            message: 'Invalid email format.',
          );
        }
      }

      // Validate phone if provided
      if (settings.phone != null && settings.phone!.isNotEmpty) {
        if (!isValidPhone(settings.phone!)) {
          throw const DatasourceError(
            type: DatasourceErrorType.validation,
            message: 'Invalid phone number format.',
          );
        }
      }

      // Validate delivery zones length
      if (settings.deliveryZones != null) {
        final zonesError = validateTextLength(
            settings.deliveryZones!, maxDeliveryZonesLength, 'Delivery zones');
        if (zonesError != null) {
          throw DatasourceError(
            type: DatasourceErrorType.validation,
            message: zonesError,
          );
        }
      }

      // Validate price fields
      if (settings.minOrderAmount != null) {
        final err = validatePrice(settings.minOrderAmount!);
        if (err != null) {
          throw DatasourceError(
            type: DatasourceErrorType.validation,
            message: 'Min order amount: $err',
          );
        }
      }
      if (settings.deliveryFee != null) {
        final err = validatePrice(settings.deliveryFee!);
        if (err != null) {
          throw DatasourceError(
            type: DatasourceErrorType.validation,
            message: 'Delivery fee: $err',
          );
        }
      }
      if (settings.freeDeliveryMin != null) {
        final err = validatePrice(settings.freeDeliveryMin!);
        if (err != null) {
          throw DatasourceError(
            type: DatasourceErrorType.validation,
            message: 'Free delivery minimum: $err',
          );
        }
      }

      await _client
          .from('organizations')
          .update(settings.toJson())
          .eq('id', orgId);

      // Invalidate org settings cache after mutation
      _orgSettingsCache = null;

      return true;
    } catch (e) {
      if (e is DatasourceError) {
        if (kDebugMode) debugPrint('updateOrgSettings: $e');
        return false;
      }
      final error = _categorizeError(e, 'updateOrgSettings');
      if (kDebugMode) debugPrint('$error');
      return false;
    }
  }

  // ─── Categories (for product filtering) ───────────────────────

  /// Fetch distinct product categories for this org.
  /// Results are cached with a 5-minute TTL.
  Future<List<String>> getCategories({int limit = 100}) async {
    try {
      if (_categoriesCache != null && !_categoriesCache!.isExpired) {
        return _categoriesCache!.data;
      }

      final orgId = await _requireOrgId('getCategories');

      final data = await _client
          .from('categories')
          .select('name')
          .eq('org_id', orgId)
          .order('name')
          .range(0, limit - 1);

      final results = (data as List)
          .map((json) =>
              (json as Map<String, dynamic>)['name'] as String? ?? '')
          .where((name) => name.isNotEmpty)
          .toList();

      _categoriesCache = _CacheEntry(
        results,
        DateTime.now().add(_categoriesTtl),
      );

      return results;
    } catch (e) {
      if (e is DatasourceError) rethrow;
      final error = _categorizeError(e, 'getCategories');
      if (kDebugMode) debugPrint('$error');
      throw error;
    }
  }
}
