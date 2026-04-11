/// Settings and theme providers.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models.dart';
import 'distributor_datasource_provider.dart';

// ─── Settings ───────────────────────────────────────────────────

final orgSettingsProvider = FutureProvider<OrgSettings?>((ref) async {
  final ds = ref.watch(distributorDatasourceProvider);
  return ds.getOrgSettings();
});

// ─── Theme Mode ────────────────────────────────────────────────

const String _kThemeModeKey = 'distributor_theme_mode';

/// ThemeMode notifier with SharedPreferences persistence.
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kThemeModeKey);
    if (saved == 'light') {
      state = ThemeMode.light;
    } else if (saved == 'dark') {
      state = ThemeMode.dark;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    switch (mode) {
      case ThemeMode.light:
        await prefs.setString(_kThemeModeKey, 'light');
      case ThemeMode.dark:
        await prefs.setString(_kThemeModeKey, 'dark');
      case ThemeMode.system:
        await prefs.remove(_kThemeModeKey);
    }
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((
  ref,
) {
  return ThemeModeNotifier();
});
