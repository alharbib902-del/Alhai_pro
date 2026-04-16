/// خدمة API الذكاء الاصطناعي - AI API Service
///
/// عميل HTTP للاتصال بخادم FastAPI للذكاء الاصطناعي
/// يدعم: المصادقة، التخزين المؤقت، إعادة المحاولة، العمل بدون اتصال،
/// تثبيت الشهادات، تنظيف البيانات الشخصية
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:alhai_auth/alhai_auth.dart' show SecureStorageService;
import 'package:alhai_core/alhai_core.dart' show AppEndpoints;
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ============================================================================
// CONFIGURATION
// ============================================================================

/// عنوان خادم الذكاء الاصطناعي
// ignore: prefer_const_declarations - kDebugMode is const but ternary prevents const
final String _kAiServerUrl = kDebugMode
    ? AppEndpoints
          .aiDebug // Android emulator -> host
    : AppEndpoints.aiProduction; // Production

/// مهلة الاتصال (ثانية)
const int _kTimeoutSeconds = 30;

/// عدد محاولات إعادة المحاولة
const int _kMaxRetries = 2;

/// مدة التخزين المؤقت (دقيقة)
const int _kCacheDurationMinutes = 15;

// ============================================================================
// CERTIFICATE PINNING CONFIGURATION
// ============================================================================

/// Primary SHA-256 fingerprint for the AI server certificate, injected via
/// `--dart-define=AI_SERVER_CERT_FINGERPRINT=<base64 sha256>`.
const String _kPrimaryFingerprint = String.fromEnvironment(
  'AI_SERVER_CERT_FINGERPRINT',
);

/// Backup fingerprint for certificate rotation windows.
const String _kBackupFingerprint = String.fromEnvironment(
  'AI_SERVER_CERT_FINGERPRINT_BACKUP',
);

/// Active pin list, normalized (trimmed, non-empty).
final List<String> _kPinnedHashes = <String>[
  if (_kPrimaryFingerprint.trim().isNotEmpty) _kPrimaryFingerprint.trim(),
  if (_kBackupFingerprint.trim().isNotEmpty) _kBackupFingerprint.trim(),
];

// ============================================================================
// PII SANITIZATION
// ============================================================================

/// Strips personally identifiable information from user input before sending
/// to the AI server. Removes:
/// - Email addresses
/// - Phone numbers (international and Saudi formats)
/// - Saudi national IDs (10 digits starting with 1 or 2)
String sanitizePii(String input) {
  // Email addresses
  var result = input.replaceAll(
    RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'),
    '[EMAIL]',
  );

  // Saudi national IDs: exactly 10 digits starting with 1 or 2
  // Must check BEFORE phone numbers since NID could match phone patterns.
  // Use word-boundary to avoid matching inside longer digit sequences.
  result = result.replaceAll(
    RegExp(r'\b[12]\d{9}\b'),
    '[NATIONAL_ID]',
  );

  // Phone numbers: +966…, 05…, or generic international format
  result = result.replaceAll(
    RegExp(r'(?:\+?\d{1,3}[-.\s]?)?\(?\d{2,4}\)?[-.\s]?\d{3,4}[-.\s]?\d{3,4}'),
    '[PHONE]',
  );

  return result;
}

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

  /// Rate limiter: track API call timestamps (max 10 per minute)
  final List<DateTime> _apiCallTimestamps = [];
  static const int _kMaxRequestsPerMinute = 10;
  static const Duration _kRateLimitWindow = Duration(minutes: 1);

  /// Secure cache key prefix in SecureStorageService
  static const String _kCacheKeyPrefix = 'ai_cache_';

  AiApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _kAiServerUrl,
        connectTimeout: const Duration(seconds: _kTimeoutSeconds),
        receiveTimeout: const Duration(seconds: _kTimeoutSeconds),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Configure certificate pinning (release builds only)
    _configureCertificatePinning();

    // Add auth interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token =
              Supabase.instance.client.auth.currentSession?.accessToken;
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
      ),
    );
  }

  // ==========================================================================
  // CERTIFICATE PINNING
  // ==========================================================================

  /// Configures TLS certificate pinning on the Dio HTTP adapter.
  ///
  /// In **release** builds, rejects connections whose certificate SHA-256
  /// fingerprint does not match any pin supplied via `--dart-define`.
  /// Throws [StateError] if no pins are configured in release mode (fail-closed).
  ///
  /// In **debug** builds, pinning is disabled so proxy/inspection tools work.
  void _configureCertificatePinning() {
    if (kDebugMode) {
      if (_kPinnedHashes.isEmpty) {
        debugPrint(
          '[AI-CertPin] Debug build has no pinned fingerprints — '
          'certificate pinning DISABLED.',
        );
      } else {
        debugPrint(
          '[AI-CertPin] Debug mode: pinning disabled for dev tools '
          '(${_kPinnedHashes.length} pin(s) configured)',
        );
      }
      return;
    }

    // Release mode: fail-closed when no pins are configured.
    if (_kPinnedHashes.isEmpty) {
      throw StateError(
        '[AI-CertPin] No pinned fingerprints configured for a release build. '
        'Rebuild with --dart-define=AI_SERVER_CERT_FINGERPRINT=<base64 sha256> '
        '(and optionally AI_SERVER_CERT_FINGERPRINT_BACKUP). '
        'Refusing to initialize an unpinned HTTP client.',
      );
    }

    final adapter = _dio.httpClientAdapter;
    if (adapter is IOHttpClientAdapter) {
      adapter.createHttpClient = () {
        final client = HttpClient()
          ..connectionTimeout = const Duration(seconds: _kTimeoutSeconds);
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          final derBytes = cert.der;
          final digest = sha256.convert(derBytes);
          final actual = base64.encode(digest.bytes);
          for (final pin in _kPinnedHashes) {
            if (_constantTimeEquals(actual, pin)) {
              return true;
            }
          }
          debugPrint(
            '[AI-CertPin] REJECTED certificate for $host:$port '
            '(fingerprint mismatch)',
          );
          return false;
        };
        return client;
      };
    }
  }

  /// Constant-time string comparison to avoid timing oracles.
  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }

  // ==========================================================================
  // CORE REQUEST METHOD
  // ==========================================================================

  /// إرسال طلب POST مع إعادة المحاولة والتخزين المؤقت وRate Limiting
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

    // Check rate limit (10 requests per minute)
    if (_isRateLimited()) {
      if (kDebugMode) {
        debugPrint(
          '[AI-API] Rate limited: ${_apiCallTimestamps.length} calls in last minute. '
          'Max allowed: $_kMaxRequestsPerMinute',
        );
      }
      throw AiApiException(
        message:
            'تم تجاوز الحد الأقصى للطلبات. يرجى الانتظار دقيقة ثم المحاولة مرة أخرى.',
        endpoint: endpoint,
      );
    }

    // Record this API call
    _recordApiCall();

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
    _cache[key] = _CacheEntry(data: data, timestamp: DateTime.now());
  }

  /// Persists cache entry using [SecureStorageService] (native keychain /
  /// encrypted SharedPreferences). Replaces the old XOR+SharedPreferences
  /// approach which was NOT real encryption.
  Future<void> _persistCache(String key, Map<String, dynamic> data) async {
    try {
      final cacheData = jsonEncode({
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
      });
      await SecureStorageService.write(
        '$_kCacheKeyPrefix$key',
        cacheData,
      );
    } catch (_) {
      // Silently fail - caching is best-effort
    }
  }

  /// Retrieves a persisted cache entry from secure storage.
  Future<Map<String, dynamic>?> _getPersistedCache(String key) async {
    try {
      final raw = await SecureStorageService.read(
        '$_kCacheKeyPrefix$key',
      );
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
  // RATE LIMITING (10 requests per minute)
  // ==========================================================================

  /// تنظيف الطلبات القديمة خارج نافذة الـ Rate Limit
  void _cleanupOldTimestamps() {
    final cutoff = DateTime.now().subtract(_kRateLimitWindow);
    _apiCallTimestamps.removeWhere((t) => t.isBefore(cutoff));
  }

  /// هل تم تجاوز حد الطلبات؟
  bool _isRateLimited() {
    _cleanupOldTimestamps();
    return _apiCallTimestamps.length >= _kMaxRequestsPerMinute;
  }

  /// تسجيل طلب API جديد
  void _recordApiCall() {
    _apiCallTimestamps.add(DateTime.now());
    _cleanupOldTimestamps();
  }

  /// عدد الطلبات المتبقية قبل Rate Limit
  int get remainingRequests {
    _cleanupOldTimestamps();
    return (_kMaxRequestsPerMinute - _apiCallTimestamps.length).clamp(
      0,
      _kMaxRequestsPerMinute,
    );
  }

  /// هل الخدمة قابلة للاستخدام (غير محدودة)؟
  bool get isAvailable => !_isRateLimited();

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
      'message': sanitizePii(message),
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
      'query': sanitizePii(query),
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

  /// هل الخطأ بسبب تجاوز حد الطلبات (Rate Limited)؟
  bool get isRateLimited =>
      originalError == null && message.contains('الحد الأقصى للطلبات');
}
