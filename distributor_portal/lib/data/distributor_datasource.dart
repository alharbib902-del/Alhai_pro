/// Supabase datasource for the Distributor Portal.
///
/// All queries are scoped to the current distributor's organization via org_id.
/// Tables used: orders, order_items, products, stores, organizations, categories.
library;

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../core/services/distributor_audit_service.dart';
import '../core/services/sentry_service.dart';
import '../core/supabase/supabase_client.dart';
import 'models.dart';

// ─── Error Types ──────────────────────────────────────────────────

/// Categorized error types for meaningful error handling.
enum DatasourceErrorType { network, auth, notFound, validation, unknown }

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
/// Includes post-approval workflow: approved → preparing → packed → shipped → delivered.
const Map<String, Set<String>> validStatusTransitions = {
  'sent': {'approved', 'rejected'},
  'pending': {'approved', 'rejected'},
  'draft': {'sent'},
  'approved': {'received', 'preparing'},
  'preparing': {'packed'},
  'packed': {'shipped'},
  'shipped': {'delivered'},
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

// ─── RPC Response Validation ────────────────────────────────────

/// Validate that required fields exist and are non-null in an RPC response map.
/// Throws [DatasourceError] with type [DatasourceErrorType.validation]
/// if any required field is missing or null.
void _validateResponseFields(
  Map<String, dynamic> data,
  List<String> requiredFields,
  String operation,
) {
  for (final field in requiredFields) {
    if (!data.containsKey(field) || data[field] == null) {
      throw DatasourceError(
        type: DatasourceErrorType.validation,
        message: 'Missing required field "$field" in $operation response',
      );
    }
  }
}

/// Return a user-friendly error message for a [DatasourceError].
String userFriendlyMessage(DatasourceError error) {
  switch (error.type) {
    case DatasourceErrorType.network:
      return 'Unable to connect. Please check your internet connection and try again.';
    case DatasourceErrorType.auth:
      return 'Your session has expired. Please log in again.';
    case DatasourceErrorType.notFound:
      return 'The requested data was not found.';
    case DatasourceErrorType.validation:
      return 'Invalid data. Please check your input and try again.';
    case DatasourceErrorType.unknown:
      return 'An unexpected error occurred. Please try again later.';
  }
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

  /// Maximum number of tracked operations to prevent unbounded memory growth.
  static const int _maxEntries = 100;

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
    _evictIfNeeded();
  }

  /// Evict oldest entries if cache exceeds max size.
  void _evictIfNeeded() {
    if (_lastCalls.length <= _maxEntries) return;
    final sorted = _lastCalls.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    final toRemove = sorted.length - _maxEntries;
    for (var i = 0; i < toRemove; i++) {
      _lastCalls.remove(sorted[i].key);
    }
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
      return (data as List).map((json) {
        final map = json as Map<String, dynamic>;
        _validateResponseFields(map, [
          'id',
          'status',
          'created_at',
        ], 'getOrders');
        return DistributorOrder.fromJson(map);
      }).toList();
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
      _validateResponseFields(data, [
        'id',
        'status',
        'created_at',
      ], 'getOrderById');
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

      return (data as List).map((json) {
        final map = json as Map<String, dynamic>;
        _validateResponseFields(map, [
          'product_id',
          'quantity',
          'unit_price',
        ], 'getOrderItems');
        return DistributorOrderItem.fromJson(map);
      }).toList();
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
              itemPrices.entries.map((e) => MapEntry(e.key, e.value)),
            )
          : null;

      await _client.rpc(
        'update_order_with_items',
        params: {
          'p_order_id': orderId,
          'p_status': newStatus,
          'p_notes': notes,
          'p_item_prices': pricesJsonb,
        },
      );

      await DistributorAuditService.instance.log(
        action: 'order.status.update',
        targetType: 'order',
        targetId: orderId,
        after: {'status': newStatus},
        metadata: {
          if (notes != null && notes.isNotEmpty) 'notes': notes,
          'item_price_changes': itemPrices?.length ?? 0,
        },
      );

      return true;
    } catch (e) {
      if (e is DatasourceError) {
        if (kDebugMode) debugPrint('updateOrderStatus: $e');
        rethrow;
      }
      final error = _categorizeError(e, 'updateOrderStatus');
      if (kDebugMode) debugPrint('$error');
      throw error;
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
      if (offset == 0 &&
          limit == 50 &&
          _productsCache != null &&
          !_productsCache!.isExpired) {
        return _productsCache!.data;
      }

      final orgId = await _requireOrgId('getProducts');

      final data = await _client
          .from('products')
          .select('*, categories(name)')
          .eq('org_id', orgId)
          .order('name')
          .range(offset, offset + limit - 1);

      final results = (data as List).map((json) {
        final map = json as Map<String, dynamic>;
        _validateResponseFields(map, ['id', 'name'], 'getProducts');
        return DistributorProduct.fromJson(map);
      }).toList();

      // Cache default pagination results
      if (offset == 0 && limit == 50) {
        _productsCache = _CacheEntry(results, DateTime.now().add(_productsTtl));
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

      // Fetch current price for audit trail before updating
      final existing = await _client
          .from('products')
          .select('price, name')
          .eq('id', productId)
          .eq('org_id', orgId)
          .maybeSingle();
      final oldPrice = (existing?['price'] as num?)?.toDouble();
      final productName = existing?['name'] as String? ?? productId;

      await _client
          .from('products')
          .update({
            'price': newPrice,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', productId)
          .eq('org_id', orgId);

      // Log price change for audit (non-blocking)
      _logPriceChange(
        productId: productId,
        productName: productName,
        oldPrice: oldPrice,
        newPrice: newPrice,
      );

      return true;
    } catch (e) {
      if (e is DatasourceError) {
        if (kDebugMode) debugPrint('updateProductPrice: $e');
        rethrow;
      }
      final error = _categorizeError(e, 'updateProductPrice');
      if (kDebugMode) debugPrint('$error');
      throw error;
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
        prices.entries.map((e) => MapEntry(e.key, e.value)),
      );

      await _client.rpc(
        'batch_update_product_prices',
        params: {'p_org_id': orgId, 'p_prices': pricesJsonb},
      );

      // Aggregated audit: one entry for the batch rather than per-product,
      // since individual-price updates already go through _logPriceChange.
      await DistributorAuditService.instance.log(
        action: 'price.batch_update',
        targetType: 'product_batch',
        targetId: orgId,
        metadata: {'count': prices.length},
      );

      // Invalidate product cache after mutation
      invalidateProductCaches();

      return true;
    } catch (e) {
      if (e is DatasourceError) {
        if (kDebugMode) debugPrint('updateProductPrices: $e');
        rethrow;
      }
      final error = _categorizeError(e, 'updateProductPrices');
      if (kDebugMode) debugPrint('$error');
      throw error;
    }
  }

  // ─── Price Audit Log ────────────────────────────────────────────

  /// Fetch price audit log entries, optionally filtered by product.
  /// Returns empty list gracefully if the table does not exist (42P01).
  Future<List<PriceAuditEntry>> getPriceAuditLog({
    String? productId,
    DateTime? fromDate,
    DateTime? toDate,
    int limit = 100,
  }) async {
    try {
      final orgId = await _requireOrgId('getPriceAuditLog');

      var query = _client.from('price_audit_log').select().eq('org_id', orgId);

      if (productId != null) {
        query = query.eq('product_id', productId);
      }
      if (fromDate != null) {
        query = query.gte('changed_at', fromDate.toIso8601String());
      }
      if (toDate != null) {
        query = query.lte('changed_at', toDate.toIso8601String());
      }

      final data = await query
          .order('changed_at', ascending: false)
          .limit(limit);
      return (data as List)
          .map((e) => PriceAuditEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // 42P01 = table does not exist → graceful empty return
      if (e is PostgrestException && e.code == '42P01') {
        if (kDebugMode)
          debugPrint('price_audit_log table not found, returning empty');
        return [];
      }
      if (e is DatasourceError) rethrow;
      final error = _categorizeError(e, 'getPriceAuditLog');
      if (kDebugMode) debugPrint('$error');
      throw error;
    }
  }

  /// Insert an audit entry for a price change.
  /// Fails silently if the audit table does not exist (42P01).
  Future<void> _logPriceChange({
    required String productId,
    required String productName,
    double? oldPrice,
    required double newPrice,
    String? reason,
  }) async {
    try {
      final orgId = await _requireOrgId('_logPriceChange');
      final userId = _client.auth.currentUser?.id ?? 'unknown';

      await _client.from('price_audit_log').insert({
        'org_id': orgId,
        'product_id': productId,
        'product_name': productName,
        'old_price': oldPrice,
        'new_price': newPrice,
        'changed_by': userId,
        'reason': reason,
      });
    } catch (e) {
      // 42P01 = table does not exist → skip silently
      if (e is PostgrestException && e.code == '42P01') {
        if (kDebugMode)
          debugPrint('price_audit_log table not found, skipping audit');
        return;
      }
      // Non-critical: log but don't fail the price update
      if (kDebugMode) debugPrint('Failed to log price change: $e');
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

      final sixMonthsAgo = DateTime.now().subtract(const Duration(days: 180));

      final data = await _client
          .from('orders')
          .select('*, stores(name)')
          .eq('type', 'purchase')
          .filter('store_id', 'in', storeIds)
          .gte('created_at', sixMonthsAgo.toIso8601String())
          .order('created_at', ascending: false)
          .range(0, 499);

      final allOrders = (data as List)
          .map(
            (json) => DistributorOrder.fromJson(json as Map<String, dynamic>),
          )
          .toList();

      final totalOrders = allOrders.length;
      final pendingOrders = allOrders
          .where((o) => o.status == 'sent' || o.status == 'draft')
          .length;
      final approvedOrders = allOrders
          .where((o) => o.status == 'approved')
          .length;
      final totalRevenue = allOrders.fold<double>(0, (sum, o) => sum + o.total);

      // Group by month for chart
      final monthMap = <int, double>{};
      for (final order in allOrders) {
        final month = order.createdAt.month;
        monthMap[month] = (monthMap[month] ?? 0) + order.total;
      }

      // Use intl DateFormat for locale-aware month names
      final monthFormatter = DateFormat.MMM('ar');
      final sortedMonthKeys = monthMap.keys.toList()..sort();

      final monthlySales = sortedMonthKeys.map((monthNum) {
        final date = DateTime(DateTime.now().year, monthNum);
        final monthName = monthFormatter.format(date);
        return MonthlySales(monthName, monthMap[monthNum]!);
      }).toList();

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
    } catch (e, stack) {
      final error = e is DatasourceError
          ? e
          : _categorizeError(e, 'getDashboardKpis');
      if (kDebugMode) debugPrint('getDashboardKpis: $error');
      reportError(
        error.originalError ?? error,
        stackTrace: stack,
        hint: 'getDashboardKpis: ${error.message}',
      );
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
          .map(
            (json) => DistributorOrder.fromJson(json as Map<String, dynamic>),
          )
          .toList();

      final totalSales = orderList.fold<double>(0, (sum, o) => sum + o.total);
      final orderCount = orderList.length;
      final avgOrderValue = orderCount > 0 ? totalSales / orderCount : 0.0;

      // Daily sales aggregation using intl for locale-aware day names
      final dayFormatter = DateFormat.E('ar');
      // Build ordered day names for the week (Sat-Fri) using intl
      final orderedDayNames = List.generate(7, (i) {
        // i=0 -> Saturday (weekday 6), i=1 -> Sunday (weekday 7), etc.
        final date = DateTime(2024, 1, 6 + i); // 2024-01-06 is Saturday
        return dayFormatter.format(date);
      });
      final dailyMap = <String, double>{};
      for (final order in orderList) {
        final dayName = dayFormatter.format(order.createdAt);
        dailyMap[dayName] = (dailyMap[dayName] ?? 0) + order.total;
      }
      final dailySales = orderedDayNames
          .map((d) => DailySales(d, dailyMap[d] ?? 0))
          .toList();

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

      final topProducts =
          productStats.values.map((e) => TopProduct(e.$1, e.$2, e.$3)).toList()
            ..sort((a, b) => b.revenue.compareTo(a.revenue));

      return ReportData(
        totalSales: totalSales,
        orderCount: orderCount,
        avgOrderValue: avgOrderValue,
        topProduct: topProducts.isNotEmpty ? topProducts.first.name : '-',
        topProductOrders: topProducts.isNotEmpty
            ? topProducts.first.orderCount
            : 0,
        dailySales: dailySales,
        topProducts: topProducts.take(5).toList(),
      );
    } catch (e, stack) {
      final error = e is DatasourceError
          ? e
          : _categorizeError(e, 'getReportData');
      if (kDebugMode) debugPrint('getReportData: $error');
      reportError(
        error.originalError ?? error,
        stackTrace: stack,
        hint: 'getReportData: ${error.message}',
      );
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
      _validateResponseFields(orgData, ['id', 'name'], 'getOrgSettings');
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
          settings.deliveryZones!,
          maxDeliveryZonesLength,
          'Delivery zones',
        );
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

      await DistributorAuditService.instance.log(
        action: 'settings.update',
        targetType: 'organization',
        targetId: orgId,
        after: settings.toJson(),
      );

      // Invalidate org settings cache after mutation
      _orgSettingsCache = null;

      return true;
    } catch (e) {
      if (e is DatasourceError) {
        if (kDebugMode) debugPrint('updateOrgSettings: $e');
        rethrow;
      }
      final error = _categorizeError(e, 'updateOrgSettings');
      if (kDebugMode) debugPrint('$error');
      throw error;
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
          .map(
            (json) => (json as Map<String, dynamic>)['name'] as String? ?? '',
          )
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

  /// Fetch categories with their IDs for product creation forms.
  Future<List<({String id, String name})>> getCategoriesWithIds({
    int limit = 100,
  }) async {
    try {
      final orgId = await _requireOrgId('getCategoriesWithIds');

      final data = await _client
          .from('categories')
          .select('id, name')
          .eq('org_id', orgId)
          .order('name')
          .range(0, limit - 1);

      return (data as List)
          .map((json) {
            final map = json as Map<String, dynamic>;
            return (
              id: map['id'] as String? ?? '',
              name: map['name'] as String? ?? '',
            );
          })
          .where((c) => c.id.isNotEmpty && c.name.isNotEmpty)
          .toList();
    } catch (e) {
      if (e is DatasourceError) rethrow;
      final error = _categorizeError(e, 'getCategoriesWithIds');
      if (kDebugMode) debugPrint('$error');
      throw error;
    }
  }

  // ─── Create Product ──────────────────────────────────────────

  /// Storage bucket for product images.
  static const String _productImagesBucket = 'product-images';

  /// Create a new product with image upload.
  ///
  /// Uploads the image to Supabase Storage, then inserts the product row
  /// into the `products` table. Requires a valid org with at least one store.
  Future<DistributorProduct> createProduct({
    required String name,
    required double price,
    required String categoryId,
    required Uint8List imageBytes,
    required String imageFilename,
    String? description,
    String? barcode,
    String? sku,
    int? stockQty,
  }) async {
    try {
      _rateLimiter.check('createProduct');

      // Validate price
      final priceError = validatePrice(price);
      if (priceError != null) {
        throw DatasourceError(
          type: DatasourceErrorType.validation,
          message: priceError,
        );
      }

      // Validate name length
      if (name.trim().isEmpty || name.trim().length < 3) {
        throw const DatasourceError(
          type: DatasourceErrorType.validation,
          message: 'Product name must be at least 3 characters.',
        );
      }

      final orgId = await _requireOrgId('createProduct');

      // Get first store_id for this org (required by schema)
      final storeIds = await _getOrgStoreIds(orgId);
      if (storeIds.isEmpty) {
        throw const DatasourceError(
          type: DatasourceErrorType.validation,
          message: 'No store found for this organization.',
        );
      }
      final storeId = storeIds.first;

      // Generate product ID
      final productId = const Uuid().v4();

      // Upload image to Supabase Storage
      final ext = imageFilename.split('.').last.toLowerCase();
      final imagePath = '$storeId/$productId.$ext';

      await _client.storage
          .from(_productImagesBucket)
          .uploadBinary(
            imagePath,
            imageBytes,
            fileOptions: FileOptions(contentType: 'image/$ext', upsert: false),
          );

      final imageUrl = _client.storage
          .from(_productImagesBucket)
          .getPublicUrl(imagePath);

      // Insert product row
      final response = await _client
          .from('products')
          .insert({
            'id': productId,
            'store_id': storeId,
            'org_id': orgId,
            'name': name.trim(),
            'price': price,
            'category_id': categoryId,
            'image_thumbnail': imageUrl,
            'description': description?.trim(),
            'barcode': barcode?.trim(),
            'sku': sku?.trim(),
            'stock_qty': stockQty ?? 0,
            'is_active': true,
          })
          .select('*, categories(name)')
          .single();

      await DistributorAuditService.instance.log(
        action: 'product.create',
        targetType: 'product',
        targetId: productId,
        after: {
          'name': name.trim(),
          'price': price,
          'store_id': storeId,
          'category_id': categoryId,
        },
      );

      // Invalidate caches after mutation
      invalidateProductCaches();

      return DistributorProduct.fromJson(response);
    } on StorageException catch (e) {
      throw DatasourceError(
        type: DatasourceErrorType.unknown,
        message: 'فشل رفع الصورة: ${e.message}',
        originalError: e,
      );
    } catch (e) {
      if (e is DatasourceError) {
        if (kDebugMode) debugPrint('createProduct: $e');
        rethrow;
      }
      final error = _categorizeError(e, 'createProduct');
      if (kDebugMode) debugPrint('$error');
      throw error;
    }
  }

  // ─── Invoices ─────────────────────────────────────────────────

  /// Generate the next sequential invoice number for this organization.
  ///
  /// Format: `INV-{year}-{sequence}` (e.g. INV-2026-0001).
  /// The unique index on (store_id, invoice_number) protects against races.
  Future<String> getNextInvoiceNumber() async {
    try {
      final orgId = await _requireOrgId('getNextInvoiceNumber');
      final storeIds = await _getOrgStoreIds(orgId);
      if (storeIds.isEmpty) {
        throw const DatasourceError(
          type: DatasourceErrorType.validation,
          message: 'No store found for this organization.',
        );
      }

      final year = DateTime.now().year;
      final prefix = 'INV-$year-';

      // Get highest existing invoice number for this year across org stores
      final data = await _client
          .from('invoices')
          .select('invoice_number')
          .inFilter('store_id', storeIds)
          .like('invoice_number', '$prefix%')
          .order('invoice_number', ascending: false)
          .limit(1);

      int nextSeq = 1;
      final dataList = data as List;
      if (dataList.isNotEmpty) {
        final lastNumber =
            (dataList[0] as Map<String, dynamic>)['invoice_number'] as String;
        final seqPart = lastNumber.replaceFirst(prefix, '');
        nextSeq = (int.tryParse(seqPart) ?? 0) + 1;
      }

      return '$prefix${nextSeq.toString().padLeft(4, '0')}';
    } catch (e) {
      if (e is DatasourceError) rethrow;
      final error = _categorizeError(e, 'getNextInvoiceNumber');
      if (kDebugMode) debugPrint('$error');
      throw error;
    }
  }

  /// Insert a new invoice into the `invoices` table.
  Future<DistributorInvoice> createInvoice(DistributorInvoice invoice) async {
    try {
      _rateLimiter.check('createInvoice');

      final orgId = await _requireOrgId('createInvoice');

      final json = invoice.toInsertJson();
      json['org_id'] = orgId;

      final response = await _client
          .from('invoices')
          .insert(json)
          .select()
          .single();

      final created = DistributorInvoice.fromJson(response);
      await DistributorAuditService.instance.log(
        action: 'invoice.create',
        targetType: 'invoice',
        targetId: created.id,
        metadata: {
          'invoice_number': response['invoice_number'],
          'total': response['total'],
        },
      );
      return created;
    } catch (e) {
      if (e is DatasourceError) rethrow;
      final error = _categorizeError(e, 'createInvoice');
      if (kDebugMode) debugPrint('$error');
      throw error;
    }
  }

  /// Fetch invoices for this org, optionally filtered by status.
  Future<List<DistributorInvoice>> getInvoices({
    String? status,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final orgId = await _requireOrgId('getInvoices');
      final storeIds = await _getOrgStoreIds(orgId);
      if (storeIds.isEmpty) return [];

      var query = _client
          .from('invoices')
          .select()
          .inFilter('store_id', storeIds);

      if (status != null && status.isNotEmpty) {
        query = query.eq('status', status);
      }

      final data = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (data as List)
          .map(
            (json) => DistributorInvoice.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      if (e is DatasourceError) rethrow;
      final error = _categorizeError(e, 'getInvoices');
      if (kDebugMode) debugPrint('$error');
      throw error;
    }
  }

  /// Fetch a single invoice by its ID.
  Future<DistributorInvoice?> getInvoiceById(String invoiceId) async {
    try {
      await _requireOrgId('getInvoiceById');

      final data = await _client
          .from('invoices')
          .select()
          .eq('id', invoiceId)
          .maybeSingle();

      if (data == null) return null;
      return DistributorInvoice.fromJson(data);
    } catch (e) {
      if (e is DatasourceError) rethrow;
      final error = _categorizeError(e, 'getInvoiceById');
      if (kDebugMode) debugPrint('$error');
      throw error;
    }
  }

  /// Check if an order already has a linked invoice.
  Future<DistributorInvoice?> getInvoiceByOrderId(String orderId) async {
    try {
      await _requireOrgId('getInvoiceByOrderId');

      final data = await _client
          .from('invoices')
          .select()
          .eq('sale_id', orderId)
          .maybeSingle();

      if (data == null) return null;
      return DistributorInvoice.fromJson(data);
    } catch (e) {
      if (e is DatasourceError) rethrow;
      final error = _categorizeError(e, 'getInvoiceByOrderId');
      if (kDebugMode) debugPrint('$error');
      throw error;
    }
  }

  /// Update ZATCA fields after processing.
  Future<bool> updateInvoiceZatca(
    String invoiceId, {
    String? zatcaHash,
    String? zatcaQr,
    String? zatcaUuid,
    String? status,
  }) async {
    try {
      _rateLimiter.check('updateInvoiceZatca');
      await _requireOrgId('updateInvoiceZatca');

      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (zatcaHash != null) updates['zatca_hash'] = zatcaHash;
      if (zatcaQr != null) updates['zatca_qr'] = zatcaQr;
      if (zatcaUuid != null) updates['zatca_uuid'] = zatcaUuid;
      if (status != null) updates['status'] = status;

      await _client.from('invoices').update(updates).eq('id', invoiceId);
      await DistributorAuditService.instance.log(
        action: 'invoice.zatca_update',
        targetType: 'invoice',
        targetId: invoiceId,
        after: {
          if (zatcaHash != null) 'zatca_hash': '<set>',
          if (zatcaQr != null) 'zatca_qr': '<set>',
          if (zatcaUuid != null) 'zatca_uuid': zatcaUuid,
          if (status != null) 'status': status,
        },
      );
      return true;
    } catch (e) {
      if (e is DatasourceError) rethrow;
      final error = _categorizeError(e, 'updateInvoiceZatca');
      if (kDebugMode) debugPrint('$error');
      throw error;
    }
  }

  // ─── Pricing Tiers ──────────────────────────────────────────────

  /// Whether the pricing_tiers table exists. Cached after first check.
  bool? _pricingTiersAvailable;

  /// Check if pricing_tiers table is available (graceful 42P01 handling).
  bool _isPricingTableError(Object error) {
    if (error is PostgrestException) {
      // 42P01 = undefined_table
      return error.code == '42P01' ||
          (error.message.contains('relation') &&
              error.message.contains('does not exist'));
    }
    return false;
  }

  /// Get all pricing tiers for the current org, sorted by sort_order.
  Future<List<PricingTier>> getPricingTiers() async {
    if (_pricingTiersAvailable == false) return [];
    try {
      final orgId = await _requireOrgId('getPricingTiers');
      final data = await _client
          .from('pricing_tiers')
          .select()
          .eq('org_id', orgId)
          .order('sort_order', ascending: true)
          .order('created_at', ascending: true);

      _pricingTiersAvailable = true;
      return (data as List)
          .map((e) => PricingTier.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (_isPricingTableError(e)) {
        _pricingTiersAvailable = false;
        return [];
      }
      if (e is DatasourceError) rethrow;
      throw _categorizeError(e, 'getPricingTiers');
    }
  }

  /// Create a new pricing tier.
  Future<PricingTier> createPricingTier({
    required String name,
    String? nameAr,
    required double discountPercent,
    bool isDefault = false,
    int sortOrder = 0,
  }) async {
    try {
      _rateLimiter.check('createPricingTier');
      final orgId = await _requireOrgId('createPricingTier');

      // If setting as default, unset existing default first
      if (isDefault) {
        await _client
            .from('pricing_tiers')
            .update({'is_default': false})
            .eq('org_id', orgId)
            .eq('is_default', true);
      }

      final data = await _client
          .from('pricing_tiers')
          .insert({
            'org_id': orgId,
            'name': name,
            'name_ar': nameAr,
            'discount_percent': discountPercent,
            'is_default': isDefault,
            'sort_order': sortOrder,
          })
          .select()
          .single();

      _pricingTiersAvailable = true;
      final tier = PricingTier.fromJson(data);
      await DistributorAuditService.instance.log(
        action: 'pricing_tier.create',
        targetType: 'pricing_tier',
        targetId: tier.id,
        after: {
          'name': name,
          'discount_percent': discountPercent,
          'is_default': isDefault,
        },
      );
      return tier;
    } catch (e) {
      if (e is DatasourceError) rethrow;
      throw _categorizeError(e, 'createPricingTier');
    }
  }

  /// Update an existing pricing tier.
  Future<PricingTier> updatePricingTier({
    required String tierId,
    String? name,
    String? nameAr,
    double? discountPercent,
    bool? isDefault,
    int? sortOrder,
  }) async {
    try {
      _rateLimiter.check('updatePricingTier');
      final orgId = await _requireOrgId('updatePricingTier');

      // If setting as default, unset existing default first
      if (isDefault == true) {
        await _client
            .from('pricing_tiers')
            .update({'is_default': false})
            .eq('org_id', orgId)
            .eq('is_default', true);
      }

      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (name != null) updates['name'] = name;
      if (nameAr != null) updates['name_ar'] = nameAr;
      if (discountPercent != null) {
        updates['discount_percent'] = discountPercent;
      }
      if (isDefault != null) updates['is_default'] = isDefault;
      if (sortOrder != null) updates['sort_order'] = sortOrder;

      final data = await _client
          .from('pricing_tiers')
          .update(updates)
          .eq('id', tierId)
          .eq('org_id', orgId)
          .select()
          .single();

      await DistributorAuditService.instance.log(
        action: 'pricing_tier.update',
        targetType: 'pricing_tier',
        targetId: tierId,
        after: updates,
      );

      return PricingTier.fromJson(data);
    } catch (e) {
      if (e is DatasourceError) rethrow;
      throw _categorizeError(e, 'updatePricingTier');
    }
  }

  /// Delete a pricing tier. Also removes any store assignments for it.
  Future<void> deletePricingTier(String tierId) async {
    try {
      _rateLimiter.check('deletePricingTier');
      final orgId = await _requireOrgId('deletePricingTier');

      // Remove store assignments first
      await _client
          .from('distributor_store_tiers')
          .delete()
          .eq('tier_id', tierId)
          .eq('org_id', orgId);

      // Delete the tier
      await _client
          .from('pricing_tiers')
          .delete()
          .eq('id', tierId)
          .eq('org_id', orgId);

      await DistributorAuditService.instance.log(
        action: 'pricing_tier.delete',
        targetType: 'pricing_tier',
        targetId: tierId,
      );
    } catch (e) {
      if (e is DatasourceError) rethrow;
      throw _categorizeError(e, 'deletePricingTier');
    }
  }

  // ─── Store Tier Assignments ─────────────────────────────────────

  /// Get all store-tier assignments for the current org.
  Future<List<StoreTierAssignment>> getStoreTierAssignments() async {
    if (_pricingTiersAvailable == false) return [];
    try {
      final orgId = await _requireOrgId('getStoreTierAssignments');
      final data = await _client
          .from('distributor_store_tiers')
          .select('*, stores(name), pricing_tiers(name, discount_percent)')
          .eq('org_id', orgId);

      _pricingTiersAvailable = true;
      return (data as List)
          .map((e) => StoreTierAssignment.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (_isPricingTableError(e)) {
        _pricingTiersAvailable = false;
        return [];
      }
      if (e is DatasourceError) rethrow;
      throw _categorizeError(e, 'getStoreTierAssignments');
    }
  }

  /// Get stores belonging to the org (for assignment UI).
  Future<List<({String id, String name})>> getOrgStores() async {
    try {
      final orgId = await _requireOrgId('getOrgStores');
      final data = await _client
          .from('stores')
          .select('id, name')
          .eq('org_id', orgId)
          .order('name', ascending: true);

      return (data as List)
          .map(
            (e) => (
              id: (e as Map<String, dynamic>)['id'] as String,
              name: e['name'] as String? ?? '',
            ),
          )
          .toList();
    } catch (e) {
      if (e is DatasourceError) rethrow;
      throw _categorizeError(e, 'getOrgStores');
    }
  }

  /// Assign a store to a pricing tier.
  Future<void> assignStoreToTier({
    required String storeId,
    required String tierId,
  }) async {
    try {
      _rateLimiter.check('assignStoreToTier');
      final orgId = await _requireOrgId('assignStoreToTier');

      await _client.from('distributor_store_tiers').upsert({
        'org_id': orgId,
        'store_id': storeId,
        'tier_id': tierId,
        'assigned_at': DateTime.now().toIso8601String(),
      }, onConflict: 'org_id, store_id');

      await DistributorAuditService.instance.log(
        action: 'store_tier.assign',
        targetType: 'store',
        targetId: storeId,
        metadata: {'tier_id': tierId},
      );
    } catch (e) {
      if (e is DatasourceError) rethrow;
      throw _categorizeError(e, 'assignStoreToTier');
    }
  }

  /// Remove a store's tier assignment.
  Future<void> removeStoreFromTier(String storeId) async {
    try {
      _rateLimiter.check('removeStoreFromTier');
      final orgId = await _requireOrgId('removeStoreFromTier');

      await _client
          .from('distributor_store_tiers')
          .delete()
          .eq('org_id', orgId)
          .eq('store_id', storeId);

      await DistributorAuditService.instance.log(
        action: 'store_tier.remove',
        targetType: 'store',
        targetId: storeId,
      );
    } catch (e) {
      if (e is DatasourceError) rethrow;
      throw _categorizeError(e, 'removeStoreFromTier');
    }
  }

  /// Get the discount percentage for a store based on its tier assignment.
  /// Returns 0 if the store has no tier or the feature is not available.
  Future<double> getStoreDiscountPercent(String storeId) async {
    if (_pricingTiersAvailable == false) return 0;
    try {
      final orgId = await _requireOrgId('getStoreDiscountPercent');
      final data = await _client
          .from('distributor_store_tiers')
          .select('pricing_tiers(discount_percent)')
          .eq('org_id', orgId)
          .eq('store_id', storeId)
          .maybeSingle();

      if (data == null) return 0;
      _pricingTiersAvailable = true;
      final tierData = data['pricing_tiers'] as Map<String, dynamic>?;
      return (tierData?['discount_percent'] as num?)?.toDouble() ?? 0;
    } catch (e) {
      if (_isPricingTableError(e)) {
        _pricingTiersAvailable = false;
        return 0;
      }
      if (kDebugMode) debugPrint('getStoreDiscountPercent: $e');
      return 0;
    }
  }

  // ─── Documents ──────────────────────────────────────────────────

  /// Storage bucket for distributor legal documents (private).
  static const String _documentsBucket = 'distributor-documents';

  /// Max document file size: 10 MB.
  static const int _maxDocumentSize = 10 * 1024 * 1024;

  /// Allowed MIME types for document uploads.
  static const List<String> _allowedDocumentMimes = [
    'application/pdf',
    'image/jpeg',
    'image/png',
  ];

  /// Whether the distributor_documents table is available.
  /// Set to false on first 42P01 error to avoid repeated failures.
  bool _documentsTableAvailable = true;

  /// Check if an error indicates the documents table doesn't exist.
  bool _isDocumentsTableError(Object e) {
    if (e is PostgrestException) {
      return e.code == '42P01' || (e.message.contains('distributor_documents'));
    }
    return false;
  }

  /// Upload a legal document to private storage.
  Future<DistributorDocument> uploadDocument({
    required DocumentType type,
    required Uint8List fileBytes,
    required String fileName,
    required String mimeType,
    DateTime? expiryDate,
  }) async {
    try {
      _rateLimiter.check('uploadDocument');

      // 1. Validate size
      if (fileBytes.length > _maxDocumentSize) {
        throw const DatasourceError(
          type: DatasourceErrorType.validation,
          message: 'حجم الملف يجب أن يكون أقل من 10 ميجابايت',
        );
      }

      // 2. Validate MIME type
      if (!_allowedDocumentMimes.contains(mimeType)) {
        throw const DatasourceError(
          type: DatasourceErrorType.validation,
          message: 'نوع الملف غير مدعوم (PDF, JPG, PNG فقط)',
        );
      }

      final orgId = await _requireOrgId('uploadDocument');

      // 3. Check for existing active document of same type
      try {
        final existing = await _client
            .from('distributor_documents')
            .select('id, status')
            .eq('org_id', orgId)
            .eq('document_type', type.dbValue)
            .inFilter('status', ['under_review', 'approved'])
            .maybeSingle();

        if (existing != null) {
          final status = existing['status'] as String;
          if (status == 'approved') {
            throw const DatasourceError(
              type: DatasourceErrorType.validation,
              message: 'هذه الوثيقة موافق عليها بالفعل',
            );
          }
          if (status == 'under_review') {
            throw const DatasourceError(
              type: DatasourceErrorType.validation,
              message: 'هذه الوثيقة قيد المراجعة بالفعل',
            );
          }
        }
      } on PostgrestException catch (e) {
        if (_isDocumentsTableError(e)) {
          _documentsTableAvailable = false;
          throw const DatasourceError(
            type: DatasourceErrorType.unknown,
            message: 'جدول الوثائق غير منشأ بعد. راجع الدعم.',
          );
        }
        rethrow;
      }

      // 4. Upload to private storage
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storagePath = '$orgId/${type.dbValue}/${timestamp}_$fileName';

      try {
        await _client.storage
            .from(_documentsBucket)
            .uploadBinary(
              storagePath,
              fileBytes,
              fileOptions: FileOptions(contentType: mimeType, upsert: false),
            );
      } on StorageException catch (e) {
        throw DatasourceError(
          type: DatasourceErrorType.unknown,
          message: 'فشل رفع الملف: ${e.message}',
          originalError: e,
        );
      }

      // 5. Insert record in DB
      final docId = const Uuid().v4();
      try {
        final response = await _client
            .from('distributor_documents')
            .insert({
              'id': docId,
              'org_id': orgId,
              'document_type': type.dbValue,
              'file_url': storagePath,
              'file_name': fileName,
              'file_size': fileBytes.length,
              'mime_type': mimeType,
              'status': 'under_review',
              'expiry_date': expiryDate?.toIso8601String().split('T')[0],
              'uploaded_at': DateTime.now().toIso8601String(),
            })
            .select()
            .single();

        await DistributorAuditService.instance.log(
          action: 'document.upload',
          targetType: 'distributor_document',
          targetId: docId,
          metadata: {
            'document_type': type.dbValue,
            'file_name': fileName,
            'file_size': fileBytes.length,
          },
        );

        return DistributorDocument.fromJson(response);
      } on PostgrestException catch (e) {
        // Cleanup orphan file on DB insert failure
        try {
          await _client.storage.from(_documentsBucket).remove([storagePath]);
        } catch (_) {}

        if (_isDocumentsTableError(e)) {
          _documentsTableAvailable = false;
          throw const DatasourceError(
            type: DatasourceErrorType.unknown,
            message: 'جدول الوثائق غير منشأ بعد. راجع الدعم.',
          );
        }
        rethrow;
      }
    } catch (e) {
      if (e is DatasourceError) rethrow;
      final error = _categorizeError(e, 'uploadDocument');
      if (kDebugMode) debugPrint('$error');
      throw error;
    }
  }

  /// List all documents for the current org.
  Future<List<DistributorDocument>> getDocuments() async {
    if (!_documentsTableAvailable) return [];
    try {
      final orgId = await _requireOrgId('getDocuments');

      final response = await _client
          .from('distributor_documents')
          .select()
          .eq('org_id', orgId)
          .order('uploaded_at', ascending: false);

      return (response as List)
          .map(
            (json) =>
                DistributorDocument.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } on PostgrestException catch (e) {
      if (_isDocumentsTableError(e)) {
        _documentsTableAvailable = false;
        return []; // Graceful degradation
      }
      final error = _categorizeError(e, 'getDocuments');
      if (kDebugMode) debugPrint('$error');
      throw error;
    } catch (e) {
      if (e is DatasourceError) rethrow;
      final error = _categorizeError(e, 'getDocuments');
      if (kDebugMode) debugPrint('$error');
      throw error;
    }
  }

  /// Get a signed URL for viewing a document (expires in 1 hour).
  Future<String> getDocumentSignedUrl(String storagePath) async {
    try {
      final url = await _client.storage
          .from(_documentsBucket)
          .createSignedUrl(storagePath, 3600);
      return url;
    } on StorageException catch (e) {
      throw DatasourceError(
        type: DatasourceErrorType.unknown,
        message: 'فشل تحضير رابط الملف: ${e.message}',
        originalError: e,
      );
    }
  }

  /// Delete a document (only if not approved).
  Future<void> deleteDocument(String documentId) async {
    try {
      _rateLimiter.check('deleteDocument');

      // Get document first for storage cleanup & status check
      final doc = await _client
          .from('distributor_documents')
          .select('file_url, status')
          .eq('id', documentId)
          .single();

      if (doc['status'] == 'approved') {
        throw const DatasourceError(
          type: DatasourceErrorType.validation,
          message: 'لا يمكن حذف وثيقة موافق عليها',
        );
      }

      // Delete from storage (best effort)
      try {
        await _client.storage.from(_documentsBucket).remove([
          doc['file_url'] as String,
        ]);
      } catch (_) {
        // Don't block DB delete on storage failure
      }

      // Delete from DB (RLS enforces ownership + non-approved)
      await _client.from('distributor_documents').delete().eq('id', documentId);

      await DistributorAuditService.instance.log(
        action: 'document.delete',
        targetType: 'distributor_document',
        targetId: documentId,
      );
    } catch (e) {
      if (e is DatasourceError) rethrow;
      final error = _categorizeError(e, 'deleteDocument');
      if (kDebugMode) debugPrint('$error');
      throw error;
    }
  }

  // ─── Onboarding / Signup ────────────────────────────────────────

  /// Sign up a new distributor (self-service registration).
  ///
  /// 1. Creates auth user via Supabase Auth (sends verification email)
  /// 2. Inserts distributor record with status = pending_email_verification
  /// Returns [DistributorSignupResult] on success.
  Future<DistributorSignupResult> signUpDistributor(SignupParams params) async {
    if (!params.acceptedTerms) {
      throw const DatasourceError(
        type: DatasourceErrorType.validation,
        message: 'يجب الموافقة على الشروط والأحكام',
      );
    }

    // 1. Sign up via Supabase Auth (sends verification email)
    final AuthResponse authResponse;
    try {
      authResponse = await _client.auth.signUp(
        email: params.email,
        password: params.password,
        data: {
          'company_name': params.companyName,
          'phone': params.phoneNumber,
          'role': 'distributor',
        },
      );
    } on AuthException catch (e) {
      if (e.message.toLowerCase().contains('already registered') ||
          e.message.toLowerCase().contains('user already')) {
        throw const DatasourceError(
          type: DatasourceErrorType.validation,
          message: 'هذا البريد مسجّل بالفعل',
        );
      }
      throw DatasourceError(
        type: DatasourceErrorType.auth,
        message: 'فشل التسجيل: ${e.message}',
        originalError: e,
      );
    }

    final user = authResponse.user;
    if (user == null) {
      throw const DatasourceError(
        type: DatasourceErrorType.auth,
        message: 'فشل إنشاء الحساب',
      );
    }

    // 2. Insert distributor record
    final distributorId = const Uuid().v4();
    try {
      await _client.from('distributors').insert({
        'id': distributorId,
        'user_id': user.id,
        'company_name': params.companyName,
        'company_name_en': params.companyNameEn,
        'phone': params.phoneNumber,
        'email': params.email,
        'commercial_register': params.commercialRegister,
        'vat_number': params.vatNumber,
        'city': params.city,
        'address': params.address,
        'status': DistributorAccountStatus.pendingEmailVerification.dbValue,
        'terms_accepted_at': DateTime.now().toUtc().toIso8601String(),
        'terms_version': '1.0',
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });

      addBreadcrumb(
        message: 'Distributor signup: $distributorId',
        category: 'onboarding',
      );

      await DistributorAuditService.instance.log(
        action: 'distributor.signup',
        targetType: 'distributor',
        targetId: distributorId,
        metadata: {
          'company_name': params.companyName,
          'email': params.email,
          'city': params.city,
        },
      );

      return DistributorSignupResult(
        distributorId: distributorId,
        email: params.email,
        requiresEmailVerification: true,
      );
    } on PostgrestException catch (e) {
      // User created in Auth but distributor INSERT failed
      if (e.code == '23505') {
        throw const DatasourceError(
          type: DatasourceErrorType.validation,
          message: 'شركة بهذا الاسم أو الرقم موجودة مسبقاً',
        );
      }
      throw DatasourceError(
        type: DatasourceErrorType.unknown,
        message: 'فشل حفظ بيانات الشركة: ${e.message}',
        originalError: e,
      );
    }
  }

  /// Get the current distributor's account status.
  ///
  /// Returns null if no distributor record exists for the current user.
  Future<DistributorAccountStatus?> getCurrentDistributorStatus() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    try {
      final response = await _client
          .from('distributors')
          .select('status')
          .eq('user_id', user.id)
          .maybeSingle();

      if (response == null) return null;

      return DistributorAccountStatus.fromDbValue(response['status'] as String);
    } catch (e) {
      if (e is DatasourceError) rethrow;
      final error = _categorizeError(e, 'getCurrentDistributorStatus');
      if (kDebugMode) debugPrint('$error');
      throw error;
    }
  }

  /// Update status from pending_email_verification → pending_review
  /// after email confirmation.
  Future<void> markEmailVerified() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const DatasourceError(
        type: DatasourceErrorType.auth,
        message: 'غير مسجّل دخول',
      );
    }

    try {
      await _client
          .from('distributors')
          .update({'status': DistributorAccountStatus.pendingReview.dbValue})
          .eq('user_id', user.id)
          .eq(
            'status',
            DistributorAccountStatus.pendingEmailVerification.dbValue,
          );

      addBreadcrumb(
        message: 'Email verified, status → pending_review',
        category: 'onboarding',
      );

      await DistributorAuditService.instance.log(
        action: 'distributor.email_verified',
        targetType: 'distributor',
        targetId: user.id,
        after: {'status': DistributorAccountStatus.pendingReview.dbValue},
      );
    } catch (e) {
      if (e is DatasourceError) rethrow;
      final error = _categorizeError(e, 'markEmailVerified');
      if (kDebugMode) debugPrint('$error');
      throw error;
    }
  }

  /// Resend verification email via Supabase Auth.
  Future<void> resendVerificationEmail(String email) async {
    try {
      await _client.auth.resend(type: OtpType.signup, email: email);
    } on AuthException catch (e) {
      throw DatasourceError(
        type: DatasourceErrorType.auth,
        message: 'فشل إعادة إرسال البريد: ${e.message}',
        originalError: e,
      );
    }
  }
}
