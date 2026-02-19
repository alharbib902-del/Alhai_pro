/// مزود اللغات - Locale Provider
///
/// يدير تغيير اللغة وحفظ التفضيلات
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// مفتاح تخزين اللغة
const String _kLocaleKey = 'app_locale';

/// اللغات المدعومة
class SupportedLocales {
  SupportedLocales._();

  /// العربية (اللغة الأساسية)
  static const Locale arabic = Locale('ar', 'SA');

  /// الإنجليزية
  static const Locale english = Locale('en', 'US');

  /// الأردية
  static const Locale urdu = Locale('ur', 'PK');

  /// الهندية
  static const Locale hindi = Locale('hi', 'IN');

  /// الفلبينية
  static const Locale filipino = Locale('fil', 'PH');

  /// البنغالية
  static const Locale bengali = Locale('bn', 'BD');

  /// الإندونيسية
  static const Locale indonesian = Locale('id', 'ID');

  /// قائمة جميع اللغات المدعومة
  static const List<Locale> all = [
    arabic,
    english,
    urdu,
    hindi,
    filipino,
    bengali,
    indonesian,
  ];

  /// اللغات RTL
  static const List<String> rtlLanguages = ['ar', 'ur'];

  /// هل اللغة RTL؟
  static bool isRtl(Locale locale) {
    return rtlLanguages.contains(locale.languageCode);
  }

  /// الحصول على اتجاه النص
  static TextDirection getTextDirection(Locale locale) {
    return isRtl(locale) ? TextDirection.rtl : TextDirection.ltr;
  }

  /// الحصول على اسم اللغة الأصلي
  static String getNativeName(Locale locale) {
    switch (locale.languageCode) {
      case 'ar':
        return 'العربية';
      case 'en':
        return 'English';
      case 'ur':
        return 'اردو';
      case 'hi':
        return 'हिन्दी';
      case 'fil':
        return 'Filipino';
      case 'bn':
        return 'বাংলা';
      case 'id':
        return 'Bahasa Indonesia';
      default:
        return locale.languageCode;
    }
  }

  /// الحصول على علم الدولة
  static String getFlag(Locale locale) {
    switch (locale.languageCode) {
      case 'ar':
        return '🇸🇦';
      case 'en':
        return '🇺🇸';
      case 'ur':
        return '🇵🇰';
      case 'hi':
        return '🇮🇳';
      case 'fil':
        return '🇵🇭';
      case 'bn':
        return '🇧🇩';
      case 'id':
        return '🇮🇩';
      default:
        return '🌐';
    }
  }
}

/// حالة اللغة
class LocaleState {
  final Locale locale;
  final bool isRtl;
  final TextDirection textDirection;

  const LocaleState({
    required this.locale,
    required this.isRtl,
    required this.textDirection,
  });

  factory LocaleState.fromLocale(Locale locale) {
    return LocaleState(
      locale: locale,
      isRtl: SupportedLocales.isRtl(locale),
      textDirection: SupportedLocales.getTextDirection(locale),
    );
  }

  /// الحالة الافتراضية (العربية)
  factory LocaleState.initial() {
    return LocaleState.fromLocale(SupportedLocales.arabic);
  }
}

/// مزود حالة اللغة
class LocaleNotifier extends StateNotifier<LocaleState> {
  LocaleNotifier() : super(LocaleState.initial()) {
    _loadSavedLocale();
  }

  /// تحميل اللغة المحفوظة
  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLocale = prefs.getString(_kLocaleKey);

      if (savedLocale != null) {
        final parts = savedLocale.split('_');
        final locale = Locale(
          parts[0],
          parts.length > 1 ? parts[1] : null,
        );

        if (_isSupported(locale)) {
          state = LocaleState.fromLocale(locale);
        }
      }
    } catch (e) {
      // استخدام اللغة الافتراضية في حالة الخطأ
    }
  }

  /// تغيير اللغة
  Future<void> setLocale(Locale locale) async {
    if (!_isSupported(locale)) return;

    state = LocaleState.fromLocale(locale);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _kLocaleKey,
        '${locale.languageCode}_${locale.countryCode ?? ''}',
      );
    } catch (e) {
      // تجاهل أخطاء الحفظ
    }
  }

  /// تغيير اللغة باستخدام كود اللغة
  Future<void> setLocaleByCode(String languageCode) async {
    final locale = SupportedLocales.all.firstWhere(
      (l) => l.languageCode == languageCode,
      orElse: () => SupportedLocales.arabic,
    );
    await setLocale(locale);
  }

  /// هل اللغة مدعومة؟
  bool _isSupported(Locale locale) {
    return SupportedLocales.all.any(
      (l) => l.languageCode == locale.languageCode,
    );
  }
}

/// Provider للغة
final localeProvider = StateNotifierProvider<LocaleNotifier, LocaleState>(
  (ref) => LocaleNotifier(),
);

/// Provider للـ Locale فقط
final currentLocaleProvider = Provider<Locale>((ref) {
  return ref.watch(localeProvider).locale;
});

/// Provider لاتجاه النص
final textDirectionProvider = Provider<TextDirection>((ref) {
  return ref.watch(localeProvider).textDirection;
});

/// Provider لـ RTL
final isRtlProvider = Provider<bool>((ref) {
  return ref.watch(localeProvider).isRtl;
});
