/// مزود الثيم - Theme Provider
///
/// يدير الوضع المظلم/الفاتح مع حفظ التفضيلات في LocalStorage
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ============================================================================
// THEME STATE
// ============================================================================

/// حالة الثيم
class ThemeState {
  final ThemeMode themeMode;
  final bool isLoading;

  const ThemeState({
    this.themeMode = ThemeMode.system,
    this.isLoading = true,
  });

  ThemeState copyWith({
    ThemeMode? themeMode,
    bool? isLoading,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  /// هل الوضع المظلم مفعّل؟
  bool get isDarkMode => themeMode == ThemeMode.dark;

  /// هل يتبع النظام؟
  bool get isSystemMode => themeMode == ThemeMode.system;
}

// ============================================================================
// THEME NOTIFIER
// ============================================================================

/// مُدير الثيم
class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier([ThemeMode? initialMode])
      : super(ThemeState(
          themeMode: initialMode ?? ThemeMode.system,
          isLoading: initialMode == null,
        )) {
    if (initialMode == null) _loadTheme();
  }

  static const String _themeKey = 'app_theme_mode';

  /// تحميل الثيم المحفوظ
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMode = prefs.getString(_themeKey);

      ThemeMode mode;
      switch (savedMode) {
        case 'dark':
          mode = ThemeMode.dark;
          break;
        case 'light':
          mode = ThemeMode.light;
          break;
        default:
          mode = ThemeMode.system;
      }

      state = state.copyWith(themeMode: mode, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// تغيير الثيم
  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);

    try {
      final prefs = await SharedPreferences.getInstance();
      String modeString;
      switch (mode) {
        case ThemeMode.dark:
          modeString = 'dark';
          break;
        case ThemeMode.light:
          modeString = 'light';
          break;
        case ThemeMode.system:
          modeString = 'system';
          break;
      }
      await prefs.setString(_themeKey, modeString);
    } catch (e) {
      // تجاهل أخطاء الحفظ
    }
  }

  /// تبديل الوضع المظلم
  Future<void> toggleDarkMode() async {
    final newMode = state.isDarkMode ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }

  /// تفعيل الوضع المظلم
  Future<void> enableDarkMode() async {
    await setThemeMode(ThemeMode.dark);
  }

  /// تفعيل الوضع الفاتح
  Future<void> enableLightMode() async {
    await setThemeMode(ThemeMode.light);
  }

  /// تفعيل وضع النظام
  Future<void> enableSystemMode() async {
    await setThemeMode(ThemeMode.system);
  }
}

// ============================================================================
// PROVIDERS
// ============================================================================

/// مزود حالة الثيم
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});

/// مزود وضع الثيم الحالي
final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(themeProvider).themeMode;
});

/// مزود هل الوضع المظلم مفعّل
final isDarkModeProvider = Provider<bool>((ref) {
  return ref.watch(themeProvider).isDarkMode;
});
