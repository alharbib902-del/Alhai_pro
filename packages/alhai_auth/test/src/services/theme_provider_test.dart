import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_auth/alhai_auth.dart';

void main() {
  // ignore: deprecated_member_use_from_same_package
  group('ThemeState', () {
    test('default state is system mode and loading', () {
      // ignore: deprecated_member_use_from_same_package
      const state = ThemeState();
      expect(state.themeMode, ThemeMode.system);
      expect(state.isLoading, isTrue);
    });

    test('isDarkMode returns true for dark mode', () {
      // ignore: deprecated_member_use_from_same_package
      const state = ThemeState(themeMode: ThemeMode.dark, isLoading: false);
      expect(state.isDarkMode, isTrue);
    });

    test('isDarkMode returns false for light mode', () {
      // ignore: deprecated_member_use_from_same_package
      const state = ThemeState(themeMode: ThemeMode.light, isLoading: false);
      expect(state.isDarkMode, isFalse);
    });

    test('isDarkMode returns false for system mode', () {
      // ignore: deprecated_member_use_from_same_package
      const state = ThemeState(themeMode: ThemeMode.system, isLoading: false);
      expect(state.isDarkMode, isFalse);
    });

    test('isSystemMode returns true for system mode', () {
      // ignore: deprecated_member_use_from_same_package
      const state = ThemeState(themeMode: ThemeMode.system);
      expect(state.isSystemMode, isTrue);
    });

    test('isSystemMode returns false for dark mode', () {
      // ignore: deprecated_member_use_from_same_package
      const state = ThemeState(themeMode: ThemeMode.dark);
      expect(state.isSystemMode, isFalse);
    });

    test('copyWith preserves unmodified fields', () {
      // ignore: deprecated_member_use_from_same_package
      const original = ThemeState(themeMode: ThemeMode.dark, isLoading: false);
      final copy = original.copyWith(isLoading: true);

      expect(copy.themeMode, ThemeMode.dark);
      expect(copy.isLoading, isTrue);
    });

    test('copyWith changes specified fields', () {
      // ignore: deprecated_member_use_from_same_package
      const original = ThemeState(themeMode: ThemeMode.system, isLoading: true);
      final copy = original.copyWith(themeMode: ThemeMode.light);

      expect(copy.themeMode, ThemeMode.light);
      expect(copy.isLoading, isTrue);
    });
  });

  group('ThemeNotifier', () {
    test('initializes with provided mode immediately', () {
      final notifier = ThemeNotifier(ThemeMode.dark);

      expect(notifier.state.themeMode, ThemeMode.dark);
      expect(notifier.state.isLoading, isFalse);

      notifier.dispose();
    });

    test('initializes with system mode when no argument', () async {
      final notifier = ThemeNotifier();

      // When no initial mode, defaults to system and starts loading
      expect(notifier.state.themeMode, ThemeMode.system);

      // Let the async _loadTheme complete before disposing to avoid
      // "Tried to use ThemeNotifier after dispose" error.
      await Future<void>.delayed(Duration.zero);
      notifier.dispose();
    });

    test('setThemeMode changes the theme', () async {
      final notifier = ThemeNotifier(ThemeMode.light);

      await notifier.setThemeMode(ThemeMode.dark);

      expect(notifier.state.themeMode, ThemeMode.dark);

      notifier.dispose();
    });

    test('toggleDarkMode switches from dark to light', () async {
      final notifier = ThemeNotifier(ThemeMode.dark);

      await notifier.toggleDarkMode();

      expect(notifier.state.themeMode, ThemeMode.light);

      notifier.dispose();
    });

    test('toggleDarkMode switches from light to dark', () async {
      final notifier = ThemeNotifier(ThemeMode.light);

      await notifier.toggleDarkMode();

      expect(notifier.state.themeMode, ThemeMode.dark);

      notifier.dispose();
    });

    test('toggleDarkMode switches from system to dark', () async {
      final notifier = ThemeNotifier(ThemeMode.system);

      await notifier.toggleDarkMode();

      expect(notifier.state.themeMode, ThemeMode.dark);

      notifier.dispose();
    });

    test('enableDarkMode sets dark mode', () async {
      final notifier = ThemeNotifier(ThemeMode.light);

      await notifier.enableDarkMode();

      expect(notifier.state.themeMode, ThemeMode.dark);

      notifier.dispose();
    });

    test('enableLightMode sets light mode', () async {
      final notifier = ThemeNotifier(ThemeMode.dark);

      await notifier.enableLightMode();

      expect(notifier.state.themeMode, ThemeMode.light);

      notifier.dispose();
    });

    test('enableSystemMode sets system mode', () async {
      final notifier = ThemeNotifier(ThemeMode.dark);

      await notifier.enableSystemMode();

      expect(notifier.state.themeMode, ThemeMode.system);

      notifier.dispose();
    });
  });
}
