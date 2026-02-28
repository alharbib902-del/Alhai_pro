import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Semantic color tokens for Alhai Design System
///
/// Delegates to [AppColors] for overlapping values to avoid duplicate color
/// definitions (see H10). [AppColors] is the canonical, comprehensive color
/// system. This class adds design-system-specific tokens (on-colors, outlines,
/// scrim, shadow, disabled states) that [AppColors] does not provide.
///
/// Use these tokens instead of raw colors in UI code.
abstract final class AlhaiColors {
  // ============================================
  // Brand Colors  (delegated to AppColors)
  // ============================================

  /// Primary brand color
  static const Color primary = AppColors.primary;
  static const Color primaryLight = AppColors.primaryLight;
  static const Color primaryDark = AppColors.primaryDark;

  /// Secondary accent color
  static const Color secondary = AppColors.secondary;
  static const Color secondaryLight = AppColors.secondaryLight;
  static const Color secondaryDark = AppColors.secondaryDark;

  // ============================================
  // Semantic Colors  (delegated to AppColors)
  // ============================================

  /// Success states
  static const Color success = AppColors.success;
  static const Color successLight = AppColors.successLight;
  static const Color successDark = Color(0xFF16A34A);

  /// Warning states
  static const Color warning = AppColors.warning;
  static const Color warningLight = AppColors.warningLight;
  static const Color warningDark = Color(0xFFD97706);

  /// Error states
  static const Color error = AppColors.error;
  static const Color errorLight = AppColors.errorLight;
  static const Color errorDark = Color(0xFFDC2626);

  /// Info states
  static const Color info = AppColors.info;
  static const Color infoLight = AppColors.infoLight;
  static const Color infoDark = Color(0xFF2563EB);

  // ============================================
  // Neutral Colors (Light Theme)  (delegated to AppColors)
  // ============================================

  /// Background colors
  static const Color backgroundLight = AppColors.backgroundLight;
  static const Color surfaceLight = AppColors.surfaceLight;
  static const Color surfaceVariantLight = AppColors.surfaceVariant;

  /// Text colors
  static const Color onBackgroundLight = AppColors.textPrimaryLight;
  static const Color onSurfaceLight = AppColors.textPrimaryLight;
  static const Color onSurfaceVariantLight = AppColors.textSecondaryLight;

  /// Border/Divider
  static const Color outlineLight = AppColors.borderLight;
  static const Color outlineVariantLight = AppColors.divider;

  // ============================================
  // Neutral Colors (Dark Theme)  (delegated to AppColors)
  // ============================================

  /// Background colors
  static const Color backgroundDark = AppColors.backgroundDark;
  static const Color surfaceDark = AppColors.surfaceDark;
  static const Color surfaceVariantDark = AppColors.surfaceVariantDark;

  /// Text colors
  static const Color onBackgroundDark = AppColors.textPrimaryDark;
  static const Color onSurfaceDark = AppColors.textPrimaryDark;
  static const Color onSurfaceVariantDark = AppColors.textSecondaryDark;

  /// Border/Divider
  static const Color outlineDark = AppColors.borderDark;
  static const Color outlineVariantDark = Color(0xFF616161);

  // ============================================
  // On-Colors (for text/icons on colored backgrounds)
  // ============================================

  static const Color onPrimary = AppColors.textOnPrimary;
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color onWarning = Color(0xFF212121);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onInfo = Color(0xFFFFFFFF);

  // ============================================
  // Special Purpose
  // ============================================

  /// Disabled state
  static const Color disabled = Color(0xFFBDBDBD);
  static const Color disabledDark = Color(0xFF616161);

  /// Overlay/Scrim
  static const Color scrim = Color(0x52000000);
  static const Color scrimDark = Color(0x99000000);

  /// Shadow
  static const Color shadow = Color(0x1A000000);
  static const Color shadowDark = Color(0x33000000);

  // ============================================
  // Technical/Utility
  // ============================================

  /// Transparent
  static const Color transparent = Color(0x00000000);

  /// Disabled opacity (Material standard: 0.38)
  static const double disabledOpacity = 0.38;
}
