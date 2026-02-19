/// أحجام التطبيق الموحدة - App Sizes
///
/// توفر قيم ثابتة للمسافات والأحجام لضمان تناسق التصميم
/// مُحسّن للويب والتابلت
library;

import 'package:flutter/material.dart';
import 'app_colors.dart';

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

  // Breakpoints
  static const double breakpointMobile = 640.0;
  static const double breakpointTablet = 768.0;
  static const double breakpointDesktop = 1024.0;

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
}

// ============================================================================
// BREAKPOINTS - نقاط التوقف للشاشات
// ============================================================================

/// نقاط التوقف للتصميم المتجاوب
class AppBreakpoints {
  AppBreakpoints._();

  /// موبايل صغير
  static const double mobileSmall = 320.0;

  /// موبايل
  static const double mobile = 640.0;

  /// تابلت
  static const double tablet = 768.0;

  /// لابتوب
  static const double laptop = 1024.0;

  /// سطح مكتب
  static const double desktop = 1280.0;

  /// شاشة عريضة
  static const double wide = 1536.0;

  /// التحقق من حجم الشاشة
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < tablet;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= tablet && width < laptop;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= laptop;

  static bool isWide(BuildContext context) =>
      MediaQuery.of(context).size.width >= wide;
}

// ============================================================================
// ICON SIZES - أحجام الأيقونات
// ============================================================================

/// أحجام الأيقونات
class AppIconSize {
  AppIconSize._();

  /// صغيرة جداً (16)
  static const double xs = 16.0;

  /// صغيرة (20)
  static const double sm = 20.0;

  /// متوسطة (24) - الافتراضي
  static const double md = 24.0;

  /// كبيرة (32)
  static const double lg = 32.0;

  /// كبيرة جداً (48)
  static const double xl = 48.0;

  /// ضخمة (64) - للحالات الفارغة
  static const double xxl = 64.0;

  /// ضخمة جداً (80) - للـ illustrations
  static const double huge = 80.0;
}

// ============================================================================
// BUTTON SIZES - أحجام الأزرار
// ============================================================================

/// أحجام الأزرار
class AppButtonSize {
  AppButtonSize._();

  /// ارتفاع صغير (36)
  static const double heightSm = 36.0;

  /// ارتفاع متوسط (44)
  static const double heightMd = 44.0;

  /// ارتفاع كبير (52)
  static const double heightLg = 52.0;

  /// padding أفقي
  static const double paddingHorizontal = 16.0;

  /// padding أفقي كبير
  static const double paddingHorizontalLg = 24.0;

  /// padding رأسي
  static const double paddingVertical = 12.0;

  /// أقل عرض للزر
  static const double minWidth = 80.0;
}

// ============================================================================
// INPUT SIZES - أحجام الحقول
// ============================================================================

/// أحجام حقول الإدخال
class AppInputSize {
  AppInputSize._();

  /// ارتفاع صغير (40)
  static const double heightSm = 40.0;

  /// ارتفاع متوسط (48)
  static const double heightMd = 48.0;

  /// ارتفاع كبير (56)
  static const double heightLg = 56.0;

  /// padding داخلي
  static const double padding = 16.0;

  /// padding داخلي صغير
  static const double paddingSm = 12.0;
}

// ============================================================================
// CARD SIZES - أحجام البطاقات
// ============================================================================

/// أحجام البطاقات
class AppCardSize {
  AppCardSize._();

  /// padding صغير
  static const double paddingSm = 12.0;

  /// padding متوسط
  static const double paddingMd = 16.0;

  /// padding كبير
  static const double paddingLg = 20.0;

  /// padding كبير جداً
  static const double paddingXl = 24.0;

  /// elevation افتراضي
  static const double elevation = 2.0;

  /// elevation مرتفع
  static const double elevationHigh = 4.0;
}

// ============================================================================
// AVATAR SIZES - أحجام الصور الرمزية
// ============================================================================

/// أحجام الصور الرمزية
class AppAvatarSize {
  AppAvatarSize._();

  /// صغيرة جداً (24)
  static const double xs = 24.0;

  /// صغيرة (32)
  static const double sm = 32.0;

  /// متوسطة (40)
  static const double md = 40.0;

  /// كبيرة (56)
  static const double lg = 56.0;

  /// كبيرة جداً (80)
  static const double xl = 80.0;

  /// ضخمة (120)
  static const double xxl = 120.0;
}

// ============================================================================
// SIDEBAR SIZES - أحجام الشريط الجانبي (للويب)
// ============================================================================

/// أحجام الشريط الجانبي
class AppSidebarSize {
  AppSidebarSize._();

  /// عرض الشريط الجانبي
  static const double width = 260.0;

  /// عرض الشريط الجانبي المطوي
  static const double collapsedWidth = 72.0;

  /// ارتفاع عنصر القائمة
  static const double itemHeight = 48.0;

  /// padding العنصر
  static const double itemPadding = 12.0;
}

// ============================================================================
// TOP BAR SIZES - أحجام الشريط العلوي (للويب)
// ============================================================================

/// أحجام الشريط العلوي
class AppTopBarSize {
  AppTopBarSize._();

  /// ارتفاع الشريط العلوي
  static const double height = 64.0;

  /// padding أفقي
  static const double paddingHorizontal = 24.0;
}

// ============================================================================
// BOTTOM SHEET SIZES
// ============================================================================

/// أحجام الـ Bottom Sheet
class AppBottomSheetSize {
  AppBottomSheetSize._();

  /// نصف قطر الحافة العلوية
  static const double topRadius = 20.0;

  /// ارتفاع المقبض
  static const double handleHeight = 4.0;

  /// عرض المقبض
  static const double handleWidth = 40.0;

  /// padding
  static const double padding = 24.0;

  /// الحد الأقصى للعرض (للويب)
  static const double maxWidth = 500.0;
}

// ============================================================================
// DIALOG SIZES - أحجام الـ Dialog (للويب)
// ============================================================================

/// أحجام الـ Dialog
class AppDialogSize {
  AppDialogSize._();

  /// عرض صغير
  static const double widthSm = 400.0;

  /// عرض متوسط
  static const double widthMd = 500.0;

  /// عرض كبير
  static const double widthLg = 600.0;

  /// عرض كبير جداً
  static const double widthXl = 800.0;

  /// padding
  static const double padding = 24.0;

  /// نصف قطر الحافة
  static const double radius = 16.0;
}

// ============================================================================
// TABLE SIZES - أحجام الجداول (للويب)
// ============================================================================

/// أحجام الجداول
class AppTableSize {
  AppTableSize._();

  /// ارتفاع الصف
  static const double rowHeight = 52.0;

  /// ارتفاع رأس الجدول
  static const double headerHeight = 48.0;

  /// padding الخلية
  static const double cellPadding = 16.0;

  /// padding أفقي للخلية
  static const double cellPaddingH = 16.0;

  /// padding رأسي للخلية
  static const double cellPaddingV = 12.0;
}

// ============================================================================
// APP BAR SIZES
// ============================================================================

/// أحجام شريط التطبيق
class AppBarSize {
  AppBarSize._();

  /// ارتفاع عادي
  static const double height = 56.0;

  /// ارتفاع كبير
  static const double heightLarge = 64.0;

  /// ارتفاع مع search
  static const double heightWithSearch = 120.0;
}

// ============================================================================
// ANIMATION DURATIONS - مدد الحركة
// ============================================================================

/// مدد الحركة
class AppDurations {
  AppDurations._();

  /// فوري (100ms)
  static const Duration instant = Duration(milliseconds: 100);

  /// سريع (200ms)
  static const Duration fast = Duration(milliseconds: 200);

  /// عادي (300ms)
  static const Duration normal = Duration(milliseconds: 300);

  /// بطيء (400ms)
  static const Duration slow = Duration(milliseconds: 400);

  /// بطيء جداً (500ms)
  static const Duration slower = Duration(milliseconds: 500);

  /// طويل (600ms)
  static const Duration long = Duration(milliseconds: 600);
}

// ============================================================================
// ANIMATION CURVES - منحنيات الحركة
// ============================================================================

/// منحنيات الحركة
class AppCurves {
  AppCurves._();

  /// منحنى افتراضي
  static const Curve defaultCurve = Curves.easeOutCubic;

  /// منحنى الدخول
  static const Curve enter = Curves.easeOut;

  /// منحنى الخروج
  static const Curve exit = Curves.easeIn;

  /// منحنى النطاط
  static const Curve bounce = Curves.elasticOut;

  /// منحنى سريع
  static const Curve fast = Curves.easeOutQuart;
}
