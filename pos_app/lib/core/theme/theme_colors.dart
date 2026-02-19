/// ألوان الثيم الديناميكية - Theme Colors Extension
///
/// يوفر ألوان تتغير تلقائياً حسب الوضع الفاتح/المظلم
library;

import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Extension لتوفير ألوان ديناميكية من context
extension ThemeColorsX on BuildContext {
  /// هل الوضع المظلم مفعّل؟
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// ColorScheme من الثيم
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// ألوان ديناميكية
  ThemeColors get colors => ThemeColors.of(this);
}

/// ألوان ديناميكية حسب الثيم
class ThemeColors {
  final BuildContext _context;

  const ThemeColors._(this._context);

  factory ThemeColors.of(BuildContext context) => ThemeColors._(context);

  bool get _isDark => Theme.of(_context).brightness == Brightness.dark;
  ColorScheme get _scheme => Theme.of(_context).colorScheme;

  // ==========================================================================
  // PRIMARY
  // ==========================================================================

  Color get primary => _scheme.primary;
  Color get onPrimary => _scheme.onPrimary;
  Color get primaryContainer => _scheme.primaryContainer;
  Color get primarySurface => _isDark
      ? AppColors.primaryDark.withValues(alpha: 0.2)
      : AppColors.primarySurface;

  // ==========================================================================
  // SECONDARY
  // ==========================================================================

  Color get secondary => _scheme.secondary;
  Color get onSecondary => _scheme.onSecondary;

  // ==========================================================================
  // SEMANTIC
  // ==========================================================================

  Color get success => AppColors.success;
  Color get successSurface => _isDark
      ? AppColors.success.withValues(alpha: 0.15)
      : AppColors.successSurface;

  Color get warning => AppColors.warning;
  Color get warningSurface => _isDark
      ? AppColors.warning.withValues(alpha: 0.15)
      : AppColors.warningSurface;

  Color get error => _scheme.error;
  Color get errorSurface => _isDark
      ? AppColors.error.withValues(alpha: 0.15)
      : AppColors.errorSurface;

  Color get info => AppColors.info;
  Color get infoSurface => _isDark
      ? AppColors.info.withValues(alpha: 0.15)
      : AppColors.infoSurface;

  // ==========================================================================
  // SURFACE & BACKGROUND
  // ==========================================================================

  Color get background => _scheme.surface;
  Color get surface => _scheme.surface;
  Color get surfaceVariant => _scheme.surfaceContainerHighest;
  Color get surfaceContainer => _isDark
      ? AppColors.surfaceVariantDark
      : AppColors.surfaceVariant;

  // ==========================================================================
  // BORDER & DIVIDER
  // ==========================================================================

  Color get border => _scheme.outline;
  Color get borderVariant => _scheme.outlineVariant;
  Color get divider => _scheme.outlineVariant;

  // ==========================================================================
  // TEXT
  // ==========================================================================

  Color get textPrimary => _scheme.onSurface;
  Color get textSecondary => _scheme.onSurfaceVariant;
  Color get textMuted => _isDark ? AppColors.textMutedDark : AppColors.textMuted;
  Color get textOnPrimary => _scheme.onPrimary;

  // ==========================================================================
  // GREYS
  // ==========================================================================

  Color get grey50 => _isDark ? AppColors.grey800 : AppColors.grey50;
  Color get grey100 => _isDark ? AppColors.grey700 : AppColors.grey100;
  Color get grey200 => _isDark ? AppColors.grey600 : AppColors.grey200;
  Color get grey300 => _isDark ? AppColors.grey500 : AppColors.grey300;
  Color get grey400 => _isDark ? AppColors.grey400 : AppColors.grey400;
  Color get grey600 => _isDark ? AppColors.grey300 : AppColors.grey600;
  Color get grey800 => _isDark ? AppColors.grey100 : AppColors.grey800;

  // ==========================================================================
  // CARD
  // ==========================================================================

  Color get cardBackground => _scheme.surface;
  Color get cardBorder => _scheme.outlineVariant;
}
