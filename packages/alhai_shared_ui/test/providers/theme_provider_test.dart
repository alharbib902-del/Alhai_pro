import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_shared_ui/src/providers/theme_provider.dart';

void main() {
  group('ThemeState', () {
    test('should have default values', () {
      const state = ThemeState();
      expect(state.themeMode, ThemeMode.system);
      expect(state.isLoading, isTrue);
    });

    test('isDarkMode should be true when themeMode is dark', () {
      const state = ThemeState(themeMode: ThemeMode.dark);
      expect(state.isDarkMode, isTrue);
    });

    test('isDarkMode should be false when themeMode is light', () {
      const state = ThemeState(themeMode: ThemeMode.light);
      expect(state.isDarkMode, isFalse);
    });

    test('isDarkMode should be false when themeMode is system', () {
      const state = ThemeState(themeMode: ThemeMode.system);
      expect(state.isDarkMode, isFalse);
    });

    test('isSystemMode should be true when themeMode is system', () {
      const state = ThemeState(themeMode: ThemeMode.system);
      expect(state.isSystemMode, isTrue);
    });

    test('isSystemMode should be false when themeMode is dark', () {
      const state = ThemeState(themeMode: ThemeMode.dark);
      expect(state.isSystemMode, isFalse);
    });

    test('copyWith should create new state with updated themeMode', () {
      const original = ThemeState(themeMode: ThemeMode.light);
      final copied = original.copyWith(themeMode: ThemeMode.dark);
      expect(copied.themeMode, ThemeMode.dark);
      expect(copied.isLoading, original.isLoading);
    });

    test('copyWith should create new state with updated isLoading', () {
      const original = ThemeState(isLoading: true);
      final copied = original.copyWith(isLoading: false);
      expect(copied.isLoading, isFalse);
      expect(copied.themeMode, original.themeMode);
    });

    test('copyWith with no args should return equivalent state', () {
      const original = ThemeState(
        themeMode: ThemeMode.dark,
        isLoading: false,
      );
      final copied = original.copyWith();
      expect(copied.themeMode, original.themeMode);
      expect(copied.isLoading, original.isLoading);
    });
  });

  group('ThemeNotifier', () {
    test('should initialize with given themeMode', () {
      final notifier = ThemeNotifier(ThemeMode.dark);
      expect(notifier.state.themeMode, ThemeMode.dark);
      expect(notifier.state.isLoading, isFalse);
    });

    test('should initialize with light mode', () {
      final notifier = ThemeNotifier(ThemeMode.light);
      expect(notifier.state.themeMode, ThemeMode.light);
      expect(notifier.state.isLoading, isFalse);
    });

    test('should initialize with system mode', () {
      final notifier = ThemeNotifier(ThemeMode.system);
      expect(notifier.state.themeMode, ThemeMode.system);
      expect(notifier.state.isLoading, isFalse);
    });

    test('setThemeMode should update state', () async {
      final notifier = ThemeNotifier(ThemeMode.light);
      await notifier.setThemeMode(ThemeMode.dark);
      expect(notifier.state.themeMode, ThemeMode.dark);
    });

    test('toggleDarkMode should switch from dark to light', () async {
      final notifier = ThemeNotifier(ThemeMode.dark);
      await notifier.toggleDarkMode();
      expect(notifier.state.themeMode, ThemeMode.light);
    });

    test('toggleDarkMode should switch from light to dark', () async {
      final notifier = ThemeNotifier(ThemeMode.light);
      await notifier.toggleDarkMode();
      expect(notifier.state.themeMode, ThemeMode.dark);
    });

    test('toggleDarkMode should switch from system to dark', () async {
      final notifier = ThemeNotifier(ThemeMode.system);
      await notifier.toggleDarkMode();
      expect(notifier.state.themeMode, ThemeMode.dark);
    });

    test('enableDarkMode should set dark mode', () async {
      final notifier = ThemeNotifier(ThemeMode.light);
      await notifier.enableDarkMode();
      expect(notifier.state.themeMode, ThemeMode.dark);
    });

    test('enableLightMode should set light mode', () async {
      final notifier = ThemeNotifier(ThemeMode.dark);
      await notifier.enableLightMode();
      expect(notifier.state.themeMode, ThemeMode.light);
    });

    test('enableSystemMode should set system mode', () async {
      final notifier = ThemeNotifier(ThemeMode.dark);
      await notifier.enableSystemMode();
      expect(notifier.state.themeMode, ThemeMode.system);
    });
  });
}
