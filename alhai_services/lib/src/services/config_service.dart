/// خدمة الإعدادات
/// تستخدم من: جميع التطبيقات
/// 
/// ملاحظة: تحتاج تنفيذ مع SharedPreferences
class ConfigService {
  final Map<String, dynamic> _config = {};
  final Map<String, dynamic> _defaults = {};

  /// تهيئة الإعدادات مع القيم الافتراضية
  void setDefaults(Map<String, dynamic> defaults) {
    _defaults.addAll(defaults);
  }

  /// الحصول على قيمة
  T get<T>(String key, {T? defaultValue}) {
    return _config[key] ?? _defaults[key] ?? defaultValue;
  }

  /// تعيين قيمة
  void set<T>(String key, T value) {
    _config[key] = value;
  }

  /// إزالة قيمة
  void remove(String key) {
    _config.remove(key);
  }

  /// مسح جميع الإعدادات
  void clear() {
    _config.clear();
  }

  /// التحقق من وجود مفتاح
  bool containsKey(String key) {
    return _config.containsKey(key) || _defaults.containsKey(key);
  }

  /// الحصول على جميع الإعدادات
  Map<String, dynamic> getAll() {
    return {..._defaults, ..._config};
  }

  // ==================== مفاتيح التطبيق ====================

  /// اللغة
  String get language => get<String>(ConfigKeys.language, defaultValue: 'ar');
  set language(String value) => set(ConfigKeys.language, value);

  /// الوضع الداكن
  bool get isDarkMode => get<bool>(ConfigKeys.darkMode, defaultValue: false);
  set isDarkMode(bool value) => set(ConfigKeys.darkMode, value);

  /// الإشعارات
  bool get notificationsEnabled => get<bool>(ConfigKeys.notifications, defaultValue: true);
  set notificationsEnabled(bool value) => set(ConfigKeys.notifications, value);

  /// الصوت
  bool get soundEnabled => get<bool>(ConfigKeys.sound, defaultValue: true);
  set soundEnabled(bool value) => set(ConfigKeys.sound, value);

  /// الاهتزاز
  bool get vibrationEnabled => get<bool>(ConfigKeys.vibration, defaultValue: true);
  set vibrationEnabled(bool value) => set(ConfigKeys.vibration, value);

  /// الطباعة التلقائية
  bool get autoPrint => get<bool>(ConfigKeys.autoPrint, defaultValue: false);
  set autoPrint(bool value) => set(ConfigKeys.autoPrint, value);

  /// فتح درج النقود تلقائياً
  bool get autoOpenCashDrawer => get<bool>(ConfigKeys.autoOpenCashDrawer, defaultValue: true);
  set autoOpenCashDrawer(bool value) => set(ConfigKeys.autoOpenCashDrawer, value);

  /// حجم الخط
  double get fontSize => get<double>(ConfigKeys.fontSize, defaultValue: 1.0);
  set fontSize(double value) => set(ConfigKeys.fontSize, value);

  /// مهلة الشاشة (بالدقائق)
  int get screenTimeout => get<int>(ConfigKeys.screenTimeout, defaultValue: 5);
  set screenTimeout(int value) => set(ConfigKeys.screenTimeout, value);

  /// آخر متجر مستخدم
  String? get lastStoreId => get<String?>(ConfigKeys.lastStoreId, defaultValue: null);
  set lastStoreId(String? value) => set(ConfigKeys.lastStoreId, value);

  /// وضع الـ Demo
  bool get isDemoMode => get<bool>(ConfigKeys.demoMode, defaultValue: false);
  set isDemoMode(bool value) => set(ConfigKeys.demoMode, value);
}

/// مفاتيح الإعدادات
class ConfigKeys {
  static const String language = 'config.language';
  static const String darkMode = 'config.dark_mode';
  static const String notifications = 'config.notifications';
  static const String sound = 'config.sound';
  static const String vibration = 'config.vibration';
  static const String autoPrint = 'config.auto_print';
  static const String autoOpenCashDrawer = 'config.auto_open_cash_drawer';
  static const String fontSize = 'config.font_size';
  static const String screenTimeout = 'config.screen_timeout';
  static const String lastStoreId = 'config.last_store_id';
  static const String demoMode = 'config.demo_mode';
}
