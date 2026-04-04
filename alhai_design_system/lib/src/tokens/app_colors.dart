/// ألوان التطبيق - App Colors
///
/// نظام ألوان Fresh Grocery للبقالة
/// اللون الرئيسي: أخضر طازج (#10B981)
library;

import 'package:flutter/material.dart';

// ============================================================================
// APP COLORS - نظام الألوان
// ============================================================================

/// ألوان التطبيق
class AppColors {
  AppColors._();

  // ==========================================================================
  // PRIMARY - الأخضر الطازج (Fresh Green)
  // ==========================================================================

  /// اللون الأساسي - Emerald 500
  static const Color primary = Color(0xFF10B981);

  /// اللون الأساسي الفاتح - Emerald 400
  static const Color primaryLight = Color(0xFF34D399);

  /// اللون الأساسي الداكن - Emerald 600
  static const Color primaryDark = Color(0xFF059669);

  /// سطح اللون الأساسي - Emerald 50
  static const Color primarySurface = Color(0xFFECFDF5);

  /// حدود اللون الأساسي - Emerald 200
  static const Color primaryBorder = Color(0xFFA7F3D0);

  // ==========================================================================
  // SECONDARY - البرتقالي الدافئ (Warm Orange)
  // ==========================================================================

  /// اللون الثانوي - Orange 500
  static const Color secondary = Color(0xFFF97316);

  /// اللون الثانوي الفاتح - Orange 400
  static const Color secondaryLight = Color(0xFFFB923C);

  /// اللون الثانوي الداكن - Orange 600
  static const Color secondaryDark = Color(0xFFEA580C);

  /// سطح اللون الثانوي - Orange 50
  static const Color secondarySurface = Color(0xFFFFF7ED);

  // ==========================================================================
  // SEMANTIC - ألوان المعاني
  // ==========================================================================

  /// نجاح - Green 500
  static const Color success = Color(0xFF22C55E);

  /// سطح النجاح - Green 100
  static const Color successSurface = Color(0xFFDCFCE7);

  /// نجاح فاتح (للتوافق)
  static const Color successLight = Color(0xFFDCFCE7);

  /// تحذير - Amber 500
  static const Color warning = Color(0xFFF59E0B);

  /// سطح التحذير - Amber 100
  static const Color warningSurface = Color(0xFFFEF3C7);

  /// تحذير فاتح (للتوافق)
  static const Color warningLight = Color(0xFFFEF3C7);

  /// خطأ - Red 500
  static const Color error = Color(0xFFEF4444);

  /// سطح الخطأ - Red 100
  static const Color errorSurface = Color(0xFFFEE2E2);

  /// خطأ فاتح (للتوافق)
  static const Color errorLight = Color(0xFFFEE2E2);

  /// معلومات - Blue 500
  static const Color info = Color(0xFF3B82F6);

  /// سطح المعلومات - Blue 100
  static const Color infoSurface = Color(0xFFDBEAFE);

  /// معلومات فاتح (للتوافق)
  static const Color infoLight = Color(0xFFDBEAFE);

  // ==========================================================================
  // BRAND COLORS - ألوان العلامات التجارية
  // ==========================================================================

  /// واتساب - اللون الأخضر الرسمي
  static const Color whatsappGreen = Color(0xFF25D366);

  // ==========================================================================
  // MONEY - ألوان المال
  // ==========================================================================

  /// نقد - أخضر
  static const Color cash = Color(0xFF22C55E);

  /// سطح النقد
  static const Color cashSurface = Color(0xFFDCFCE7);

  /// بطاقة - أزرق
  static const Color card = Color(0xFF3B82F6);

  /// سطح البطاقة
  static const Color cardSurface = Color(0xFFDBEAFE);

  /// دين - أحمر
  static const Color debt = Color(0xFFEF4444);

  /// سطح الدين
  static const Color debtSurface = Color(0xFFFEE2E2);

  /// رصيد - تركواز
  static const Color credit = Color(0xFF14B8A6);

  /// سطح الرصيد
  static const Color creditSurface = Color(0xFFCCFBF1);

  // ==========================================================================
  // STOCK - ألوان المخزون
  // ==========================================================================

  /// متوفر
  static const Color stockAvailable = Color(0xFF22C55E);

  /// منخفض
  static const Color stockLow = Color(0xFFF59E0B);

  /// نفذ
  static const Color stockOut = Color(0xFFEF4444);

  // ==========================================================================
  // NEUTRAL COLORS
  // ==========================================================================

  /// أبيض
  static const Color white = Color(0xFFFFFFFF);

  /// أسود
  static const Color black = Color(0xFF000000);

  /// رمادي فاتح جداً
  static const Color grey50 = Color(0xFFF9FAFB);

  /// رمادي فاتح
  static const Color grey100 = Color(0xFFF3F4F6);

  /// رمادي
  static const Color grey200 = Color(0xFFE5E7EB);

  /// رمادي متوسط
  static const Color grey300 = Color(0xFFD1D5DB);

  /// رمادي
  static const Color grey400 = Color(0xFF9CA3AF);

  /// رمادي داكن
  static const Color grey500 = Color(0xFF6B7280);

  /// رمادي داكن جداً
  static const Color grey600 = Color(0xFF4B5563);

  /// رمادي داكن جداً
  static const Color grey700 = Color(0xFF374151);

  /// رمادي داكن جداً
  static const Color grey800 = Color(0xFF1F2937);

  /// رمادي داكن جداً
  static const Color grey900 = Color(0xFF111827);

  // ==========================================================================
  // BACKGROUND & SURFACE - Light Mode
  // ==========================================================================

  /// خلفية الصفحة - Gray 50
  static const Color background = Color(0xFFF9FAFB);

  /// خلفية الصفحة (فاتح) - للتوافق
  static const Color backgroundLight = Color(0xFFF9FAFB);

  /// السطح - White
  static const Color surface = Color(0xFFFFFFFF);

  /// خلفية السطح (فاتح) - للتوافق
  static const Color surfaceLight = Color(0xFFFFFFFF);

  /// سطح متغير - Gray 100
  static const Color surfaceVariant = Color(0xFFF3F4F6);

  /// خلفية ثانوية - Gray 100
  static const Color backgroundSecondary = Color(0xFFF3F4F6);

  /// الحدود - Gray 200
  static const Color border = Color(0xFFE5E7EB);

  /// لون الحدود (فاتح) - للتوافق
  static const Color borderLight = Color(0xFFE5E7EB);

  /// الفاصل - Gray 100
  static const Color divider = Color(0xFFF3F4F6);

  // ==========================================================================
  // TEXT - Light Mode
  // ==========================================================================

  /// نص أساسي - Gray 900
  static const Color textPrimary = Color(0xFF111827);

  /// نص أساسي (فاتح) - للتوافق
  static const Color textPrimaryLight = Color(0xFF111827);

  /// نص ثانوي - Gray 500
  static const Color textSecondary = Color(0xFF6B7280);

  /// نص ثانوي (فاتح) - للتوافق
  static const Color textSecondaryLight = Color(0xFF6B7280);

  /// نص خافت - Gray 400
  static const Color textMuted = Color(0xFF9CA3AF);

  /// نص ثالثي - Gray 400 (alias for textMuted)
  static const Color textTertiary = Color(0xFF9CA3AF);

  /// نص معطل - للتوافق
  static const Color textDisabled = Color(0xFF9CA3AF);

  /// نص على اللون الأساسي
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ==========================================================================
  // BACKGROUND & SURFACE - Dark Mode
  // ==========================================================================

  /// خلفية الصفحة (داكن) - Gray 900
  static const Color backgroundDark = Color(0xFF111827);

  /// السطح (داكن) - Gray 800
  static const Color surfaceDark = Color(0xFF1F2937);

  /// سطح متغير (داكن) - Gray 700
  static const Color surfaceVariantDark = Color(0xFF374151);

  /// الحدود (داكن) - Gray 600
  static const Color borderDark = Color(0xFF4B5563);

  // ==========================================================================
  // TEXT - Dark Mode
  // ==========================================================================

  /// نص أساسي (داكن) - Gray 50
  static const Color textPrimaryDark = Color(0xFFF9FAFB);

  /// نص ثانوي (داكن) - Gray 300
  static const Color textSecondaryDark = Color(0xFFD1D5DB);

  /// نص خافت (داكن) - Gray 400
  static const Color textMutedDark = Color(0xFF9CA3AF);

  // ==========================================================================
  // SPECIAL COLORS
  // ==========================================================================

  /// لون الـ Shimmer الأساسي
  static const Color shimmerBase = Color(0xFFE5E7EB);

  /// لون الـ Shimmer المضيء
  static const Color shimmerHighlight = Color(0xFFF3F4F6);

  /// لون التراكب الشفاف
  static const Color overlay = Color(0x80000000);

  // ==========================================================================
  // GRADIENTS
  // ==========================================================================

  // ---------- Light mode gradients ----------

  /// تدرج أساسي
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
  );

  /// تدرج ثانوي
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFFF97316), Color(0xFFEA580C)],
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
  );

  /// تدرج النجاح
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
  );

  /// تدرج للكارد
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF0EA5E9)],
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
  );

  // ---------- Dark mode gradients (L83) ----------
  //
  // Desaturated / deeper variants that look correct on dark surfaces
  // (backgroundDark: #111827, surfaceDark: #1F2937).

  /// تدرج أساسي - وضع داكن
  static const LinearGradient primaryGradientDark = LinearGradient(
    colors: [Color(0xFF065F46), Color(0xFF064E3B)],
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
  );

  /// تدرج ثانوي - وضع داكن
  static const LinearGradient secondaryGradientDark = LinearGradient(
    colors: [Color(0xFFC2410C), Color(0xFF9A3412)],
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
  );

  /// تدرج النجاح - وضع داكن
  static const LinearGradient successGradientDark = LinearGradient(
    colors: [Color(0xFF15803D), Color(0xFF166534)],
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
  );

  /// تدرج للكارد - وضع داكن
  static const LinearGradient cardGradientDark = LinearGradient(
    colors: [Color(0xFF065F46), Color(0xFF0369A1)],
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
  );

  /// تدرج الخطأ
  static const LinearGradient errorGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
  );

  /// تدرج الخطأ - وضع داكن
  static const LinearGradient errorGradientDark = LinearGradient(
    colors: [Color(0xFF991B1B), Color(0xFF7F1D1D)],
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
  );

  /// تدرج المعلومات
  static const LinearGradient infoGradient = LinearGradient(
    colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
  );

  /// تدرج المعلومات - وضع داكن
  static const LinearGradient infoGradientDark = LinearGradient(
    colors: [Color(0xFF1E3A5F), Color(0xFF1E293B)],
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
  );

  // ---------- Theme-aware gradient helpers (L83) ----------

  /// الحصول على التدرج الأساسي حسب الوضع
  static LinearGradient getPrimaryGradient(bool isDark) =>
      isDark ? primaryGradientDark : primaryGradient;

  /// الحصول على التدرج الثانوي حسب الوضع
  static LinearGradient getSecondaryGradient(bool isDark) =>
      isDark ? secondaryGradientDark : secondaryGradient;

  /// الحصول على تدرج النجاح حسب الوضع
  static LinearGradient getSuccessGradient(bool isDark) =>
      isDark ? successGradientDark : successGradient;

  /// الحصول على تدرج الكارد حسب الوضع
  static LinearGradient getCardGradient(bool isDark) =>
      isDark ? cardGradientDark : cardGradient;

  /// الحصول على تدرج الخطأ حسب الوضع
  static LinearGradient getErrorGradient(bool isDark) =>
      isDark ? errorGradientDark : errorGradient;

  /// الحصول على تدرج المعلومات حسب الوضع
  static LinearGradient getInfoGradient(bool isDark) =>
      isDark ? infoGradientDark : infoGradient;

  // ==========================================================================
  // CATEGORY COLORS - ألوان التصنيفات
  // ==========================================================================

  /// فواكه - برتقالي
  static const Color categoryFruits = Color(0xFFF97316);

  /// خضروات - أخضر
  static const Color categoryVegetables = Color(0xFF22C55E);

  /// ألبان - أزرق
  static const Color categoryDairy = Color(0xFF3B82F6);

  /// لحوم - أحمر
  static const Color categoryMeat = Color(0xFFEF4444);

  /// مخبوزات - أصفر
  static const Color categoryBakery = Color(0xFFF59E0B);

  /// مشروبات - سماوي
  static const Color categoryDrinks = Color(0xFF06B6D4);

  /// سناكس - بنفسجي
  static const Color categorySnacks = Color(0xFF8B5CF6);

  /// تنظيف - تركواز
  static const Color categoryCleaning = Color(0xFF14B8A6);

  // ==========================================================================
  // EXTENDED SEMANTIC COLORS - ألوان دلالية إضافية
  // ==========================================================================

  /// بنفسجي - للمبالغ المختلطة والمرتجعات والتحويلات
  static const Color purple = Color(0xFF8B5CF6);

  /// وردي - للتصنيفات المتنوعة
  static const Color pink = Color(0xFFEC4899);

  /// سماوي - لون تمييزي بديل
  static const Color cyan = Color(0xFF06B6D4);

  // ==========================================================================
  // DENOMINATION COUNTER GRADIENT
  // ==========================================================================

  /// تدرج عداد الفئات
  static const LinearGradient denominationGradient = LinearGradient(
    colors: [Color(0xFF1A8FE3), Color(0xFF0EC9C9)],
  );

  /// لون عداد الفئات الأساسي
  static const Color denominationAccent = Color(0xFF1A8FE3);

  // ==========================================================================
  // AVATAR GRADIENT
  // ==========================================================================

  /// تدرج الأحرف الأولى للعميل
  static const LinearGradient avatarGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
  );

  // ==========================================================================
  // HELPER METHODS
  // ==========================================================================

  /// الحصول على لون المخزون حسب الحالة
  static Color getStockColor(double quantity, double minQuantity) {
    if (quantity <= 0) return stockOut;
    if (quantity <= minQuantity) return stockLow;
    return stockAvailable;
  }

  /// الحصول على لون الرصيد حسب القيمة
  /// الرصيد الموجب = مبلغ مستحق (دين) = أحمر
  /// الرصيد السالب = رصيد دائن = تركواز
  static Color getBalanceColor(double balance) {
    if (balance > 0) return debt;
    if (balance < 0) return credit;
    return textMuted;
  }

  /// الحصول على لون طريقة الدفع
  static Color getPaymentMethodColor(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
      case 'نقد':
        return cash;
      case 'card':
      case 'بطاقة':
        return card;
      case 'credit':
      case 'آجل':
        return debt;
      default:
        return primary;
    }
  }

  /// الحصول على لون التصنيف
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'fruits':
      case 'فواكه':
        return categoryFruits;
      case 'vegetables':
      case 'خضروات':
        return categoryVegetables;
      case 'dairy':
      case 'ألبان':
        return categoryDairy;
      case 'meat':
      case 'لحوم':
        return categoryMeat;
      case 'bakery':
      case 'مخبوزات':
        return categoryBakery;
      case 'drinks':
      case 'مشروبات':
        return categoryDrinks;
      case 'snacks':
      case 'سناكس':
        return categorySnacks;
      case 'cleaning':
      case 'تنظيف':
        return categoryCleaning;
      default:
        return primary;
    }
  }

  // ==========================================================================
  // THEME-AWARE HELPERS - دوال مساعدة تراعي الوضع
  // ==========================================================================

  /// الحصول على لون الخلفية حسب الوضع
  static Color getBackground(bool isDark) =>
      isDark ? backgroundDark : background;

  /// الحصول على لون السطح حسب الوضع
  static Color getSurface(bool isDark) => isDark ? surfaceDark : surface;

  /// الحصول على لون سطح متغير حسب الوضع
  static Color getSurfaceVariant(bool isDark) =>
      isDark ? surfaceVariantDark : surfaceVariant;

  /// الحصول على لون الحدود حسب الوضع
  static Color getBorder(bool isDark) => isDark ? borderDark : border;

  /// الحصول على لون النص الأساسي حسب الوضع
  static Color getTextPrimary(bool isDark) =>
      isDark ? textPrimaryDark : textPrimary;

  /// الحصول على لون النص الثانوي حسب الوضع
  static Color getTextSecondary(bool isDark) =>
      isDark ? textSecondaryDark : textSecondary;

  /// الحصول على لون النص الخافت حسب الوضع
  static Color getTextMuted(bool isDark) => isDark ? textMutedDark : textMuted;

  // ==========================================================================
  // DISTRIBUTOR STATUS COLORS - ألوان حالات الموزع
  // ==========================================================================

  /// Get theme-aware status foreground color
  static Color getStatusColor(String status, bool isDark) {
    switch (status) {
      case 'sent':
      case 'draft':
      case 'pending':
        return isDark ? const Color(0xFF60A5FA) : info; // blue
      case 'approved':
        return isDark ? const Color(0xFF4ADE80) : success; // green
      case 'received':
        return isDark ? const Color(0xFF2DD4BF) : credit; // teal
      case 'rejected':
        return isDark ? const Color(0xFFF87171) : error; // red
      default:
        return isDark ? textMutedDark : grey500;
    }
  }

  /// Get theme-aware status background color
  static Color getStatusBackground(String status, bool isDark) {
    final fg = getStatusColor(status, isDark);
    return fg.withValues(alpha: isDark ? 0.2 : 0.1);
  }

  // ==========================================================================
  // SHADOW / ELEVATION TOKENS
  // ==========================================================================

  /// Card shadow for light mode (no shadow in dark mode)
  static List<BoxShadow> getCardShadow(bool isDark) {
    if (isDark) return const [];
    return const [
      BoxShadow(
        color: Color(0x0D000000), // 5% black
        blurRadius: 10,
        offset: Offset(0, 2),
      ),
    ];
  }

  /// Elevated shadow for light mode (e.g. save bars)
  static List<BoxShadow> getElevatedShadow(bool isDark) {
    if (isDark) return const [];
    return const [
      BoxShadow(
        color: Color(0x0D000000),
        blurRadius: 8,
        offset: Offset(0, -2),
      ),
    ];
  }
}
