import 'package:flutter/material.dart';

/// Semantic color tokens for Alhai Design System
/// Use these tokens instead of raw colors in UI code
abstract final class AlhaiColors {
  // ============================================
  // Brand Colors
  // ============================================

  /// Primary brand color (Alhai teal/green)
  static const Color primary = Color(0xFF00897B);
  static const Color primaryLight = Color(0xFF4DB6AC);
  static const Color primaryDark = Color(0xFF00695C);

  /// Secondary accent color
  static const Color secondary = Color(0xFF5C6BC0);
  static const Color secondaryLight = Color(0xFF8E99F3);
  static const Color secondaryDark = Color(0xFF26418F);

  // ============================================
  // Semantic Colors
  // ============================================

  /// Success states
  static const Color success = Color(0xFF43A047);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color successDark = Color(0xFF2E7D32);

  /// Warning states
  static const Color warning = Color(0xFFFFA726);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color warningDark = Color(0xFFEF6C00);

  /// Error states
  static const Color error = Color(0xFFE53935);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color errorDark = Color(0xFFC62828);

  /// Info states
  static const Color info = Color(0xFF29B6F6);
  static const Color infoLight = Color(0xFFE1F5FE);
  static const Color infoDark = Color(0xFF0288D1);

  // ============================================
  // Neutral Colors (Light Theme)
  // ============================================

  /// Background colors
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF5F5F5);

  /// Text colors
  static const Color onBackgroundLight = Color(0xFF212121);
  static const Color onSurfaceLight = Color(0xFF212121);
  static const Color onSurfaceVariantLight = Color(0xFF757575);

  /// Border/Divider
  static const Color outlineLight = Color(0xFFE0E0E0);
  static const Color outlineVariantLight = Color(0xFFEEEEEE);

  // ============================================
  // Neutral Colors (Dark Theme)
  // ============================================

  /// Background colors
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color surfaceVariantDark = Color(0xFF2C2C2C);

  /// Text colors
  static const Color onBackgroundDark = Color(0xFFE0E0E0);
  static const Color onSurfaceDark = Color(0xFFE0E0E0);
  static const Color onSurfaceVariantDark = Color(0xFF9E9E9E);

  /// Border/Divider
  static const Color outlineDark = Color(0xFF424242);
  static const Color outlineVariantDark = Color(0xFF444444); // محسّن للتباين

  // ============================================
  // On-Colors (for text/icons on colored backgrounds)
  // ============================================

  static const Color onPrimary = Color(0xFFFFFFFF);
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

  /// Transparent (استثناء تقني لـ surfaceTint وغيرها)
  static const Color transparent = Color(0x00000000);

  /// Disabled opacity (Material standard: 0.38)
  static const double disabledOpacity = 0.38;
}
