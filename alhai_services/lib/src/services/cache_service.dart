/// خدمة التخزين المؤقت
/// تستخدم من: جميع التطبيقات
class CacheService {
  final Map<String, _CacheEntry> _cache = {};

  /// الحصول على قيمة من الكاش
  T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;

    if (entry.isExpired) {
      _cache.remove(key);
      return null;
    }

    return entry.value as T?;
  }

  /// تخزين قيمة في الكاش
  void set<T>(String key, T value, {Duration? expiry}) {
    _cache[key] = _CacheEntry(
      value: value,
      expiry: expiry != null ? DateTime.now().add(expiry) : null,
    );
  }

  /// إزالة قيمة من الكاش
  void remove(String key) {
    _cache.remove(key);
  }

  /// إزالة جميع القيم بادئة معينة
  void removeByPrefix(String prefix) {
    _cache.removeWhere((key, _) => key.startsWith(prefix));
  }

  /// مسح الكاش بالكامل
  void clear() {
    _cache.clear();
  }

  /// التحقق من وجود مفتاح
  bool containsKey(String key) {
    final entry = _cache[key];
    if (entry == null) return false;

    if (entry.isExpired) {
      _cache.remove(key);
      return false;
    }

    return true;
  }

  /// الحصول على قيمة أو تحميلها
  Future<T> getOrLoad<T>(
    String key,
    Future<T> Function() loader, {
    Duration? expiry,
  }) async {
    final cached = get<T>(key);
    if (cached != null) return cached;

    final value = await loader();
    set(key, value, expiry: expiry);
    return value;
  }

  /// تنظيف المدخلات المنتهية
  void cleanup() {
    _cache.removeWhere((_, entry) => entry.isExpired);
  }

  /// عدد المدخلات
  int get length => _cache.length;

  /// المفاتيح المخزنة
  Iterable<String> get keys => _cache.keys;

  // ==================== مفاتيح محددة مسبقاً ====================

  /// مفتاح المتجر الحالي
  static String storeKey(String storeId) => 'store:$storeId';

  /// مفتاح المنتجات
  static String productsKey(String storeId) => 'products:$storeId';

  /// مفتاح الفئات
  static String categoriesKey(String storeId) => 'categories:$storeId';

  /// مفتاح الإعدادات
  static String settingsKey(String storeId) => 'settings:$storeId';

  /// مفتاح المستخدم
  static String userKey(String userId) => 'user:$userId';
}

/// مدخل الكاش
class _CacheEntry {
  final dynamic value;
  final DateTime? expiry;
  final DateTime createdAt;

  _CacheEntry({required this.value, this.expiry}) : createdAt = DateTime.now();

  bool get isExpired => expiry != null && DateTime.now().isAfter(expiry!);
}
