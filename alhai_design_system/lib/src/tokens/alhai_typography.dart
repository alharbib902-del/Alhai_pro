import 'package:flutter/material.dart';

/// Typography tokens for Alhai Design System
/// Arabic-first with Tajawal font family (Asset fonts for production stability)
abstract final class AlhaiTypography {
  // ============================================
  // Font Family
  // ============================================

  /// Primary font family (Arabic-optimized)
  /// Uses asset fonts for production stability
  static const String fontFamily = 'Tajawal';

  /// Get base text style with Tajawal
  static TextStyle _tajawal({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    double? height,
    double? letterSpacing,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  // ============================================
  // Display Styles (Large Headlines)
  // ============================================

  static TextStyle get displayLarge => _tajawal(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        height: 1.12,
        letterSpacing: -0.25,
      );

  static TextStyle get displayMedium => _tajawal(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        height: 1.16,
      );

  static TextStyle get displaySmall => _tajawal(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        height: 1.22,
      );

  // ============================================
  // Headline Styles
  // ============================================

  static TextStyle get headlineLarge => _tajawal(
        fontSize: 32,
        fontWeight: FontWeight.w500,
        height: 1.25,
      );

  static TextStyle get headlineMedium => _tajawal(
        fontSize: 28,
        fontWeight: FontWeight.w500,
        height: 1.29,
      );

  static TextStyle get headlineSmall => _tajawal(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        height: 1.33,
      );

  // ============================================
  // Title Styles
  // ============================================

  static TextStyle get titleLarge => _tajawal(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        height: 1.27,
      );

  static TextStyle get titleMedium => _tajawal(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.5,
        letterSpacing: 0.15,
      );

  static TextStyle get titleSmall => _tajawal(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.43,
        letterSpacing: 0.1,
      );

  // ============================================
  // Body Styles (Primary Reading)
  // ============================================

  static TextStyle get bodyLarge => _tajawal(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0.5,
      );

  static TextStyle get bodyMedium => _tajawal(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.55,
        letterSpacing: 0.25,
      );

  static TextStyle get bodySmall => _tajawal(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.33,
        letterSpacing: 0.4,
      );

  // ============================================
  // Label Styles (Buttons, Captions)
  // ============================================

  static TextStyle get labelLarge => _tajawal(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.43,
        letterSpacing: 0.1,
      );

  static TextStyle get labelMedium => _tajawal(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.33,
        letterSpacing: 0.5,
      );

  static TextStyle get labelSmall => _tajawal(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.45,
        letterSpacing: 0.5,
      );

  // ============================================
  // Text Theme Builder
  // ============================================

  /// Creates a complete TextTheme with Tajawal
  static TextTheme get textTheme => TextTheme(
        displayLarge: displayLarge,
        displayMedium: displayMedium,
        displaySmall: displaySmall,
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        headlineSmall: headlineSmall,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        titleSmall: titleSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
      );
}
