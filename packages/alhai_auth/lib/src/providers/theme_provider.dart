/// مزود الثيم - Theme Provider
///
/// يدير الوضع المظلم/الفاتح مع حفظ التفضيلات في LocalStorage
///
/// **L81 - DUPLICATION NOTICE:**
///
/// This file is an intentional duplicate of
/// `packages/alhai_shared_ui/lib/src/providers/theme_provider.dart`.
///
/// **Why it exists:**
/// `alhai_auth` cannot depend on `alhai_shared_ui` because that would create
/// a circular dependency (`alhai_shared_ui` -> `alhai_auth` -> `alhai_shared_ui`).
/// The auth package needs theme state for the login and splash screens.
///
/// **Planned fix:**
/// Extract [ThemeState], [ThemeNotifier], and the three providers into a new
/// lightweight package `packages/alhai_theme` with zero UI dependencies. Then:
/// - `alhai_auth/pubspec.yaml`:      add `alhai_theme: {path: ../alhai_theme}`
/// - `alhai_shared_ui/pubspec.yaml`: add `alhai_theme: {path: ../alhai_theme}`
/// - Both files become: `export 'package:alhai_theme/theme_provider.dart';`
///
/// **Until then:** keep both copies in sync. Any change here MUST be mirrored
/// in `packages/alhai_shared_ui/lib/src/providers/theme_provider.dart`.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ============================================================================
// THEME STATE
// ============================================================================

/// حالة الثيم
///
/// L81: This class is duplicated in alhai_shared_ui. See library-level docs.
@Deprecated(
  'L81: This is a temporary duplicate. '
  'The canonical theme provider will move to packages/alhai_theme. '
  'Until then, keep this in sync with '
  'packages/alhai_shared_ui/lib/src/providers/theme_provider.dart.',
)
class ThemeState {
  final ThemeMode themeMode;
  final bool isLoading;

  const ThemeState({this.themeMode = ThemeMode.system, this.isLoading = true});

  ThemeState copyWith({ThemeMode? themeMode, bool? isLoading}) {
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
///
/// L81: Duplicate - see library-level docs for dedup plan.
// ignore: deprecated_member_use_from_same_package
class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier([ThemeMode? initialMode])
    : super(
        ThemeState(
          themeMode: initialMode ?? ThemeMode.system,
          isLoading: initialMode == null,
        ),
      ) {
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
///
/// L81: Duplicate provider - canonical version in alhai_shared_ui.
// ignore: deprecated_member_use_from_same_package
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});

/// مزود وضع الثيم الحالي
///
/// L81: Duplicate provider - canonical version in alhai_shared_ui.
final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(themeProvider).themeMode;
});

/// مزود هل الوضع المظلم مفعّل
///
/// L81: Duplicate provider - canonical version in alhai_shared_ui.
final isDarkModeProvider = Provider<bool>((ref) {
  return ref.watch(themeProvider).isDarkMode;
});
