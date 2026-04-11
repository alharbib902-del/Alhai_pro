/// Phone Validation Service
///
/// خدمة التحقق من أرقام الهواتف مع فحص التوفر على واتساب.
///
/// توفر:
/// - تنسيق الأرقام السعودية (05x, 5x, +966x) إلى الصيغة الدولية 966xxxxxxxxx
/// - التحقق من صحة صيغة الرقم
/// - فحص توفر الرقم على واتساب عبر WaSenderAPI
/// - تخزين مؤقت للنتائج لمدة 24 ساعة
library;

import '../../core/monitoring/production_logger.dart';
import 'wasender_api_client.dart';

/// نتيجة التحقق المؤقتة
class _CachedValidation {
  final bool isOnWhatsApp;
  final DateTime checkedAt;

  const _CachedValidation({
    required this.isOnWhatsApp,
    required this.checkedAt,
  });

  /// هل انتهت صلاحية الكاش؟
  bool get isExpired =>
      DateTime.now().difference(checkedAt) >
      PhoneValidationService._cacheExpiry;
}

/// خدمة التحقق من أرقام الهواتف والتوفر على واتساب
class PhoneValidationService {
  final WaSenderApiClient _apiClient;

  /// كاش نتائج التحقق مفهرس برقم الهاتف المنسّق
  final Map<String, _CachedValidation> _cache = {};

  /// مدة صلاحية الكاش
  static const Duration _cacheExpiry = Duration(hours: 24);

  static const String _tag = 'PhoneValidation';

  PhoneValidationService({required WaSenderApiClient apiClient})
    : _apiClient = apiClient;

  // ═══════════════════════════════════════════════════════
  // التحقق من التوفر على واتساب
  // ═══════════════════════════════════════════════════════

  /// التحقق هل الرقم مسجّل على واتساب
  ///
  /// يستخدم الكاش أولا إذا كانت النتيجة لم تنته صلاحيتها.
  /// إذا لم يكن في الكاش أو انتهت صلاحيته، يتم الاستعلام من API.
  ///
  /// يرجع false في حالة فشل الاتصال بالـ API.
  Future<bool> isOnWhatsApp(String phone) async {
    // تنسيق الرقم أولا
    final formatted = formatPhone(phone);

    if (!isValidPhone(formatted)) {
      AppLogger.warning(
        'Invalid phone number: $phone (formatted: $formatted)',
        tag: _tag,
      );
      return false;
    }

    // التحقق من الكاش
    final cached = _cache[formatted];
    if (cached != null && !cached.isExpired) {
      AppLogger.debug(
        'Cache hit for $formatted: ${cached.isOnWhatsApp}',
        tag: _tag,
      );
      return cached.isOnWhatsApp;
    }

    // الاستعلام من API
    try {
      AppLogger.debug(
        'Checking WhatsApp availability for $formatted',
        tag: _tag,
      );

      final result = await _apiClient.isOnWhatsApp(phone: formatted);

      // تخزين النتيجة في الكاش
      _cache[formatted] = _CachedValidation(
        isOnWhatsApp: result,
        checkedAt: DateTime.now(),
      );

      AppLogger.debug(
        'WhatsApp check for $formatted: $result (cached)',
        tag: _tag,
      );

      return result;
    } catch (e) {
      AppLogger.error(
        'WhatsApp check failed for $formatted: $e',
        tag: _tag,
        error: e,
      );
      // في حالة الخطأ نرجع false بدون تخزين في الكاش
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════
  // تنسيق الرقم
  // ═══════════════════════════════════════════════════════

  /// تنسيق رقم هاتف سعودي إلى الصيغة الدولية 966xxxxxxxxx
  ///
  /// الصيغ المدعومة:
  /// - 05xxxxxxxx -> 9665xxxxxxxx
  /// - 5xxxxxxxx  -> 9665xxxxxxxx
  /// - +9665xxxxxxxx -> 9665xxxxxxxx
  /// - 009665xxxxxxxx -> 9665xxxxxxxx
  /// - 9665xxxxxxxx -> 9665xxxxxxxx (بدون تغيير)
  ///
  /// أي صيغة أخرى يتم إرجاعها كما هي (بعد إزالة المسافات والأحرف الخاصة).
  static String formatPhone(String phone) {
    // إزالة المسافات والرموز غير الرقمية ما عدا +
    var cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');

    // إزالة + إذا موجودة
    if (cleaned.startsWith('+')) {
      cleaned = cleaned.substring(1);
    }

    // إزالة بادئة 00 الدولية
    if (cleaned.startsWith('00')) {
      cleaned = cleaned.substring(2);
    }

    // إذا يبدأ بـ 05 (صيغة محلية سعودية)
    if (cleaned.startsWith('05') && cleaned.length == 10) {
      return '966${cleaned.substring(1)}';
    }

    // إذا يبدأ بـ 5 فقط (بدون صفر)
    if (cleaned.startsWith('5') && cleaned.length == 9) {
      return '966$cleaned';
    }

    // إذا يبدأ بـ 966 بالفعل
    if (cleaned.startsWith('966') && cleaned.length == 12) {
      return cleaned;
    }

    // إرجاع الرقم كما هو بعد التنظيف
    return cleaned;
  }

  // ═══════════════════════════════════════════════════════
  // التحقق من الصحة
  // ═══════════════════════════════════════════════════════

  /// التحقق من صحة رقم الهاتف
  ///
  /// يقبل:
  /// - الصيغة الدولية: 9665xxxxxxxx (12 رقم)
  /// - الصيغة المحلية: 05xxxxxxxx (10 أرقام)
  /// - بدون صفر: 5xxxxxxxx (9 أرقام)
  /// - مع +: +9665xxxxxxxx
  /// - مع 00: 009665xxxxxxxx
  ///
  /// الرقم يجب أن يبدأ بـ 5 بعد كود الدولة (أرقام الجوال السعودية).
  static bool isValidPhone(String phone) {
    if (phone.trim().isEmpty) return false;

    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length < 9 || cleaned.length > 15) return false;

    // التحقق من الصيغة الدولية السعودية: 9665xxxxxxxx
    final formatted = formatPhone(phone);
    if (RegExp(r'^9665\d{8}$').hasMatch(formatted)) {
      return true;
    }

    // قبول أرقام دولية أخرى (10-15 رقم)
    if (RegExp(r'^\d{10,15}$').hasMatch(formatted)) {
      return true;
    }

    return false;
  }

  /// التحقق من صحة رقم سعودي
  static bool isSaudiPhone(String phone) {
    final formatted = formatPhone(phone);
    return formatted.startsWith('966') &&
        formatted.length == 12 &&
        formatted[3] == '5';
  }

  // ═══════════════════════════════════════════════════════
  // إدارة الكاش
  // ═══════════════════════════════════════════════════════

  /// مسح جميع النتائج المخزنة مؤقتا
  void clearCache() {
    _cache.clear();
    AppLogger.debug('Validation cache cleared', tag: _tag);
  }

  /// عدد العناصر في الكاش
  int get cacheSize => _cache.length;

  /// مسح العناصر المنتهية الصلاحية فقط
  void purgeExpired() {
    _cache.removeWhere((_, value) => value.isExpired);
    AppLogger.debug(
      'Purged expired cache entries. Remaining: ${_cache.length}',
      tag: _tag,
    );
  }
}
