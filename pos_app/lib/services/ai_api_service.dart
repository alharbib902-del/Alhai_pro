/// خدمة API الذكاء الاصطناعي - AI API Service
///
/// عميل HTTP للاتصال بخادم FastAPI للذكاء الاصطناعي
/// يدعم: المصادقة، التخزين المؤقت، إعادة المحاولة، العمل بدون اتصال
library;

import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ============================================================================
// CONFIGURATION
// ============================================================================

/// عنوان خادم الذكاء الاصطناعي
const String _kAiServerUrl = kDebugMode
    ? 'http://10.0.2.2:8000' // Android emulator -> host
    : 'https://ai.alhai.app'; // Production

/// مهلة الاتصال (ثانية)
const int _kTimeoutSeconds = 30;

/// عدد محاولات إعادة المحاولة
const int _kMaxRetries = 2;

/// مدة التخزين المؤقت (دقيقة)
const int _kCacheDurationMinutes = 15;

// ============================================================================
// PROVIDER
// ============================================================================

/// مزود خدمة AI API
final aiApiServiceProvider = Provider<AiApiService>((ref) {
  return AiApiService();
});

// ============================================================================
// AI API SERVICE
// ============================================================================

/// خدمة الاتصال بخادم الذكاء الاصطناعي
class AiApiService {
  late final Dio _dio;
  final Map<String, _CacheEntry> _cache = {};

  AiApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: _kAiServerUrl,
      connectTimeout: const Duration(seconds: _kTimeoutSeconds),
      receiveTimeout: const Duration(seconds: _kTimeoutSeconds),
      headers: {'Content-Type': 'application/json'},
    ));

    // Add auth interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = Supabase.instance.client.auth.currentSession?.accessToken;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        if (kDebugMode) {
          debugPrint('AI API Error: ${error.message}');
        }
        handler.next(error);
      },
    ));
  }

  // ==========================================================================
  // CORE REQUEST METHOD
  // ==========================================================================

  /// إرسال طلب POST مع إعادة المحاولة والتخزين المؤقت
  Future<Map<String, dynamic>> _post(
    String endpoint,
    Map<String, dynamic> body, {
    bool useCache = true,
  }) async {
    final cacheKey = '$endpoint:${jsonEncode(body)}';

    // Check cache first
    if (useCache) {
      final cached = _getFromCache(cacheKey);
      if (cached != null) return cached;
    }

    // Try network request with retries
    Exception? lastError;
    for (var attempt = 0; attempt <= _kMaxRetries; attempt++) {
      try {
        final response = await _dio.post(endpoint, data: body);
        final data = response.data as Map<String, dynamic>;

        // Cache successful response
        if (useCache) {
          _putInCache(cacheKey, data);
          _persistCache(cacheKey, data);
        }

        return data;
      } on DioException catch (e) {
        lastError = e;
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          // Retry on timeout
          if (attempt < _kMaxRetries) {
            await Future.delayed(Duration(seconds: (attempt + 1) * 2));
            continue;
          }
        }
        if (e.type == DioExceptionType.connectionError) {
          // Offline - try persistent cache
          final persisted = await _getPersistedCache(cacheKey);
          if (persisted != null) return persisted;
        }
        break;
      } catch (e) {
        lastError = Exception(e.toString());
        break;
      }
    }

    // Last resort: try persistent cache
    final persisted = await _getPersistedCache(cacheKey);
    if (persisted != null) return persisted;

    throw AiApiException(
      message: 'فشل الاتصال بخادم الذكاء الاصطناعي',
      endpoint: endpoint,
      originalError: lastError,
    );
  }

  // ==========================================================================
  // CACHE MANAGEMENT
  // ==========================================================================

  Map<String, dynamic>? _getFromCache(String key) {
    final entry = _cache[key];
    if (entry != null && !entry.isExpired) return entry.data;
    if (entry != null) _cache.remove(key);
    return null;
  }

  void _putInCache(String key, Map<String, dynamic> data) {
    _cache[key] = _CacheEntry(
      data: data,
      timestamp: DateTime.now(),
    );
  }

  Future<void> _persistCache(String key, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = jsonEncode({
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
      });
      await prefs.setString('ai_cache_$key', cacheData);
    } catch (_) {
      // Silently fail - caching is best-effort
    }
  }

  Future<Map<String, dynamic>?> _getPersistedCache(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('ai_cache_$key');
      if (raw == null) return null;
      final parsed = jsonDecode(raw) as Map<String, dynamic>;
      return parsed['data'] as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// مسح التخزين المؤقت
  void clearCache() => _cache.clear();

  // ==========================================================================
  // HEALTH CHECK
  // ==========================================================================

  /// فحص صحة الخادم
  Future<bool> healthCheck() async {
    try {
      final response = await _dio.get('/health');
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ==========================================================================
  // 1. SALES FORECAST - التنبؤ بالمبيعات
  // ==========================================================================

  Future<Map<String, dynamic>> getSalesForecast({
    required String orgId,
    required String storeId,
    int daysAhead = 7,
    List<String>? productIds,
    String? categoryId,
  }) async {
    return _post('/ai/forecast', {
      'org_id': orgId,
      'store_id': storeId,
      'days_ahead': daysAhead,
      if (productIds != null) 'product_ids': productIds,
      if (categoryId != null) 'category_id': categoryId,
    });
  }

  // ==========================================================================
  // 2. SMART PRICING - التسعير الذكي
  // ==========================================================================

  Future<Map<String, dynamic>> getSmartPricing({
    required String orgId,
    required String storeId,
    List<String>? productIds,
    String strategy = 'optimal',
  }) async {
    return _post('/ai/pricing', {
      'org_id': orgId,
      'store_id': storeId,
      'strategy': strategy,
      if (productIds != null) 'product_ids': productIds,
    });
  }

  // ==========================================================================
  // 3. FRAUD DETECTION - كشف الاحتيال
  // ==========================================================================

  Future<Map<String, dynamic>> detectFraud({
    required String orgId,
    required String storeId,
    String? saleId,
  }) async {
    return _post('/ai/fraud', {
      'org_id': orgId,
      'store_id': storeId,
      if (saleId != null) 'sale_id': saleId,
    }, useCache: false);
  }

  // ==========================================================================
  // 4. BASKET ANALYSIS - تحليل سلة المشتريات
  // ==========================================================================

  Future<Map<String, dynamic>> analyzeBasket({
    required String orgId,
    required String storeId,
    int topN = 20,
  }) async {
    return _post('/ai/basket', {
      'org_id': orgId,
      'store_id': storeId,
      'top_n': topN,
    });
  }

  // ==========================================================================
  // 5. CUSTOMER RECOMMENDATIONS - توصيات العملاء
  // ==========================================================================

  Future<Map<String, dynamic>> getRecommendations({
    required String orgId,
    required String storeId,
    String? customerId,
    int topN = 10,
    String context = 'general',
  }) async {
    return _post('/ai/recommendations', {
      'org_id': orgId,
      'store_id': storeId,
      'top_n': topN,
      'context': context,
      if (customerId != null) 'customer_id': customerId,
    });
  }

  // ==========================================================================
  // 6. SMART INVENTORY - المخزون الذكي
  // ==========================================================================

  Future<Map<String, dynamic>> analyzeInventory({
    required String orgId,
    required String storeId,
    bool includeReorder = true,
  }) async {
    return _post('/ai/inventory', {
      'org_id': orgId,
      'store_id': storeId,
      'include_reorder': includeReorder,
    });
  }

  // ==========================================================================
  // 7. COMPETITOR ANALYSIS - تحليل المنافسين
  // ==========================================================================

  Future<Map<String, dynamic>> analyzeCompetitors({
    required String orgId,
    required String storeId,
    double radiusKm = 5.0,
  }) async {
    return _post('/ai/competitor', {
      'org_id': orgId,
      'store_id': storeId,
      'radius_km': radiusKm,
    });
  }

  // ==========================================================================
  // 8. SMART REPORTS - التقارير الذكية
  // ==========================================================================

  Future<Map<String, dynamic>> getSmartReport({
    required String orgId,
    required String storeId,
    String reportType = 'daily_summary',
  }) async {
    return _post('/ai/reports', {
      'org_id': orgId,
      'store_id': storeId,
      'report_type': reportType,
    });
  }

  // ==========================================================================
  // 9. STAFF ANALYTICS - تحليل الموظفين
  // ==========================================================================

  Future<Map<String, dynamic>> analyzeStaff({
    required String orgId,
    required String storeId,
    String? employeeId,
  }) async {
    return _post('/ai/staff', {
      'org_id': orgId,
      'store_id': storeId,
      if (employeeId != null) 'employee_id': employeeId,
    });
  }

  // ==========================================================================
  // 10. PRODUCT RECOGNITION - التعرف على المنتجات
  // ==========================================================================

  Future<Map<String, dynamic>> recognizeProduct({
    required String orgId,
    required String storeId,
    String? imageBase64,
    String? barcode,
    String? description,
  }) async {
    return _post('/ai/recognize', {
      'org_id': orgId,
      'store_id': storeId,
      if (imageBase64 != null) 'image_base64': imageBase64,
      if (barcode != null) 'barcode': barcode,
      if (description != null) 'description': description,
    }, useCache: false);
  }

  // ==========================================================================
  // 11. SENTIMENT ANALYSIS - تحليل المشاعر
  // ==========================================================================

  Future<Map<String, dynamic>> analyzeSentiment({
    required String orgId,
    required String storeId,
    String? text,
    String source = 'reviews',
  }) async {
    return _post('/ai/sentiment', {
      'org_id': orgId,
      'store_id': storeId,
      'source': source,
      if (text != null) 'text': text,
    });
  }

  // ==========================================================================
  // 12. RETURN PREDICTION - التنبؤ بالمرتجعات
  // ==========================================================================

  Future<Map<String, dynamic>> predictReturns({
    required String orgId,
    required String storeId,
    int daysAhead = 30,
  }) async {
    return _post('/ai/returns', {
      'org_id': orgId,
      'store_id': storeId,
      'days_ahead': daysAhead,
    });
  }

  // ==========================================================================
  // 13. PROMOTION DESIGNER - تصميم العروض
  // ==========================================================================

  Future<Map<String, dynamic>> designPromotions({
    required String orgId,
    required String storeId,
    String goal = 'increase_sales',
    int durationDays = 7,
    double? budget,
  }) async {
    return _post('/ai/promotions', {
      'org_id': orgId,
      'store_id': storeId,
      'goal': goal,
      'duration_days': durationDays,
      if (budget != null) 'budget': budget,
    });
  }

  // ==========================================================================
  // 14. CHAT WITH DATA - الدردشة مع البيانات
  // ==========================================================================

  Future<Map<String, dynamic>> chatWithData({
    required String orgId,
    required String storeId,
    required String message,
    String? conversationId,
    String language = 'ar',
  }) async {
    return _post('/ai/chat', {
      'org_id': orgId,
      'store_id': storeId,
      'message': message,
      'language': language,
      if (conversationId != null) 'conversation_id': conversationId,
    }, useCache: false);
  }

  // ==========================================================================
  // 15. ASSISTANT - المساعد الذكي
  // ==========================================================================

  Future<Map<String, dynamic>> askAssistant({
    required String orgId,
    required String storeId,
    required String query,
    String context = 'general',
  }) async {
    return _post('/ai/assistant', {
      'org_id': orgId,
      'store_id': storeId,
      'query': query,
      'context': context,
    }, useCache: false);
  }
}

// ============================================================================
// CACHE ENTRY
// ============================================================================

class _CacheEntry {
  final Map<String, dynamic> data;
  final DateTime timestamp;

  _CacheEntry({required this.data, required this.timestamp});

  bool get isExpired =>
      DateTime.now().difference(timestamp).inMinutes > _kCacheDurationMinutes;
}

// ============================================================================
// EXCEPTION
// ============================================================================

/// استثناء خاص بخدمة AI API
class AiApiException implements Exception {
  final String message;
  final String endpoint;
  final Exception? originalError;

  AiApiException({
    required this.message,
    required this.endpoint,
    this.originalError,
  });

  @override
  String toString() => 'AiApiException($endpoint): $message';

  /// هل الخطأ بسبب عدم الاتصال؟
  bool get isOffline =>
      originalError is DioException &&
      (originalError as DioException).type == DioExceptionType.connectionError;

  /// هل الخطأ بسبب انتهاء المهلة؟
  bool get isTimeout =>
      originalError is DioException &&
      ((originalError as DioException).type ==
              DioExceptionType.connectionTimeout ||
          (originalError as DioException).type ==
              DioExceptionType.receiveTimeout);
}
