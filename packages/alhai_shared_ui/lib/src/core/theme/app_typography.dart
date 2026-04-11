/// نظام الخطوط - App Typography
///
/// يوفر أنماط نصية موحدة للتطبيق
library;

import 'package:flutter/material.dart';

// ============================================================================
// APP TYPOGRAPHY - نظام الخطوط
// ============================================================================

/// أنماط الخطوط
class AppTypography {
  AppTypography._();

  /// الخط الأساسي
  static const String fontFamily = 'Tajawal';

  /// خط الأرقام (يمكن تغييره لـ IBM Plex Sans Arabic)
  static const String fontFamilyNumbers = 'Tajawal';

  // ==========================================================================
  // DISPLAY - للأرقام الكبيرة (المجموع)
  // ==========================================================================

  /// Display Large - للأرقام الضخمة
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
  );

  /// Display Medium - للأرقام الكبيرة
  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.25,
  );

  /// Display Small
  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  // ==========================================================================
  // HEADLINE - للعناوين الرئيسية
  // ==========================================================================

  /// Headline Large
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  /// Headline Medium
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  /// Headline Small
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  // ==========================================================================
  // TITLE - للعناوين الفرعية
  // ==========================================================================

  /// Title Large
  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  /// Title Medium
  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  /// Title Small
  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // ==========================================================================
  // BODY - للنصوص
  // ==========================================================================

  /// Body Large
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  /// Body Medium
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  /// Body Small
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  // ==========================================================================
  // LABEL - للأزرار والتسميات
  // ==========================================================================

  /// Label Large
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.1,
  );

  /// Label Medium
  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  /// Label Small
  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  // ==========================================================================
  // PRICE - للأسعار
  // ==========================================================================

  /// Price Large - للمجموع الكبير
  static const TextStyle priceLarge = TextStyle(
    fontFamily: fontFamilyNumbers,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  /// Price Medium - للأسعار العادية
  static const TextStyle priceMedium = TextStyle(
    fontFamily: fontFamilyNumbers,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  /// Price Small - للأسعار الصغيرة
  static const TextStyle priceSmall = TextStyle(
    fontFamily: fontFamilyNumbers,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  // ==========================================================================
  // BADGE - للعلامات والشارات
  // ==========================================================================

  /// Badge Text
  static const TextStyle badge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  // ==========================================================================
  // BUTTON - للأزرار
  // ==========================================================================

  /// Button Large
  static const TextStyle buttonLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  /// Button Medium
  static const TextStyle buttonMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  /// Button Small
  static const TextStyle buttonSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // ==========================================================================
  // INPUT - لحقول الإدخال
  // ==========================================================================

  /// Input Text
  static const TextStyle inputText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  /// Input Label
  static const TextStyle inputLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  /// Input Hint
  static const TextStyle inputHint = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  /// Input Error
  static const TextStyle inputError = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  // ==========================================================================
  // TEXT THEME - للاستخدام في ThemeData
  // ==========================================================================

  /// إنشاء TextTheme للتطبيق
  static TextTheme get textTheme => const TextTheme(
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
