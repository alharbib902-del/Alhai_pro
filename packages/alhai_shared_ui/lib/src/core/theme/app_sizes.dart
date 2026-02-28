/// أحجام التطبيق الموحدة - App Sizes
///
/// توفر قيم ثابتة للمسافات والأحجام لضمان تناسق التصميم
/// مُحسّن للويب والتابلت
library;

import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

// Barrel exports so existing `import 'app_sizes.dart'` keeps working
export 'app_component_sizes.dart';
export 'app_layout_sizes.dart';
export 'app_animations.dart';

// ============================================================================
// APP SIZES - الأحجام الموحدة (للتوافق مع الاستخدام القديم)
// ============================================================================

/// الأحجام الموحدة - يجمع المسافات والـ radius
class AppSizes {
  AppSizes._();

  // المسافات
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;

  // الـ Radius
  static const double radiusXs = 4.0;
  static const double radiusSm = 6.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 16.0;
  static const double radiusXxl = 20.0;
  static const double radiusFull = 999.0;

  // Breakpoints — Unified: delegates to AlhaiBreakpoints
  static const double breakpointMobile = AlhaiBreakpoints.tablet; // 600
  static const double breakpointTablet = AlhaiBreakpoints.desktop; // 905
  static const double breakpointDesktop = AlhaiBreakpoints.desktopLarge; // 1240

  // Shadows
  static List<BoxShadow> get shadowSm => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get shadowMd => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get shadowLg => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];
}

// ============================================================================
// SPACING - المسافات
// ============================================================================

/// المسافات الموحدة
class AppSpacing {
  AppSpacing._();

  /// مسافة صغيرة جداً جداً (2)
  static const double xxs = 2.0;

  /// مسافة صغيرة جداً (4)
  static const double xs = 4.0;

  /// مسافة صغيرة (8)
  static const double sm = 8.0;

  /// مسافة متوسطة (12)
  static const double md = 12.0;

  /// مسافة عادية (16)
  static const double lg = 16.0;

  /// مسافة كبيرة (20)
  static const double xl = 20.0;

  /// مسافة كبيرة جداً (24)
  static const double xxl = 24.0;

  /// مسافة ضخمة (32)
  static const double xxxl = 32.0;

  /// مسافة ضخمة جداً (48)
  static const double huge = 48.0;

  /// مسافة للصفحات (24)
  static const double page = 24.0;

  /// مسافة للأقسام (32)
  static const double section = 32.0;
}

// ============================================================================
// RADIUS - الحواف المستديرة
// ============================================================================

/// نصف قطر الحواف المستديرة
class AppRadius {
  AppRadius._();

  /// لا استدارة
  static const double none = 0.0;

  /// استدارة صغيرة جداً (4)
  static const double xs = 4.0;

  /// استدارة صغيرة (6) - للـ Chips
  static const double sm = 6.0;

  /// استدارة متوسطة (8) - للـ Inputs
  static const double md = 8.0;

  /// استدارة عادية (12) - للـ Cards والـ Buttons
  static const double lg = 12.0;

  /// استدارة كبيرة (16) - للـ Large Cards
  static const double xl = 16.0;

  /// استدارة كبيرة جداً (20) - للـ Modals
  static const double xxl = 20.0;

  /// استدارة كاملة (دائرة)
  static const double full = 999.0;
}

// ============================================================================
// SHADOWS - الظلال
// ============================================================================

/// ظلال التطبيق
class AppShadows {
  AppShadows._();

  /// ظل صغير
  static List<BoxShadow> get sm => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  /// ظل متوسط
  static List<BoxShadow> get md => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  /// ظل كبير
  static List<BoxShadow> get lg => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  /// ظل كبير جداً
  static List<BoxShadow> get xl => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.10),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  /// ظل ملون (للأزرار)
  static List<BoxShadow> get primarySm => [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.25),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  /// ظل ملون متوسط
  static List<BoxShadow> get primaryMd => [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.30),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  /// بدون ظل
  static List<BoxShadow> get none => [];

  /// ظلال تتكيف مع الوضع الداكن/الفاتح
  /// في الوضع الداكن: ظل أغمق مع alpha أعلى لأن الخلفية داكنة
  static List<BoxShadow> of(BuildContext context, {ShadowSize size = ShadowSize.md}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (size) {
      case ShadowSize.sm:
        return [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ];
      case ShadowSize.md:
        return [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.4)
                : Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ];
      case ShadowSize.lg:
        return [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.5)
                : Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ];
      case ShadowSize.xl:
        return [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.6)
                : Colors.black.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ];
    }
  }
}

/// أحجام الظل لـ AppShadows.of()
enum ShadowSize { sm, md, lg, xl }

// ============================================================================
// BREAKPOINTS - نقاط التوقف للشاشات
// ============================================================================

/// نقاط التوقف للتصميم المتجاوب
// Unified: delegates to AlhaiBreakpoints
class AppBreakpoints {
  AppBreakpoints._();

  /// موبايل صغير
  static const double mobileSmall = 320.0;

  /// موبايل (threshold: below this = mobile)
  static const double mobile = AlhaiBreakpoints.tablet; // 600

  /// تابلت (threshold: mobile/tablet boundary)
  static const double tablet = AlhaiBreakpoints.tablet; // 600

  /// لابتوب (threshold: tablet/desktop boundary)
  static const double laptop = AlhaiBreakpoints.desktop; // 905

  /// سطح مكتب
  static const double desktop = AlhaiBreakpoints.desktopLarge; // 1240

  /// شاشة عريضة
  static const double wide = 1536.0;

  /// التحقق من حجم الشاشة
  /// H12: محسّن - يستخدم sizeOf بدلاً من of لأداء أفضل (يعيد البناء عند تغيير الحجم فقط)
  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < tablet;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= tablet && width < laptop;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= laptop;

  static bool isWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= wide;
}
