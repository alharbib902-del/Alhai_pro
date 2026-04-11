/// أدوات التجاوب - Responsive Utils
///
/// دوال مساعدة للتصميم المتجاوب مع دعم تلقائي للجوال والتابلت وسطح المكتب
library;

import 'package:flutter/material.dart';
import '../constants/breakpoints.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

// ============================================================================
// RESPONSIVE VALUE HELPER
// ============================================================================

/// دالة للحصول على قيمة متجاوبة حسب نوع الجهاز
T getResponsiveValue<T>(
  BuildContext context, {
  required T mobile,
  T? tablet,
  required T desktop,
}) {
  final width = MediaQuery.sizeOf(context).width;
  final deviceType = getDeviceType(width);

  switch (deviceType) {
    case DeviceType.mobile:
      return mobile;
    case DeviceType.tablet:
      return tablet ?? desktop;
    case DeviceType.desktop:
      return desktop;
  }
}

/// دالة للحصول على قيمة متجاوبة من قائمة نقاط التوقف
T getBreakpointValue<T>(
  BuildContext context, {
  required T defaultValue,
  T? sm, // < 600px
  T? md, // < 900px
  T? lg, // < 1200px
  T? xl, // >= 1200px
}) {
  final width = MediaQuery.sizeOf(context).width;

  if (width >= 1200 && xl != null) return xl;
  if (width >= 900 && lg != null) return lg;
  if (width >= 600 && md != null) return md;
  if (width < 600 && sm != null) return sm;

  return defaultValue;
}

// ============================================================================
// RESPONSIVE PADDING
// ============================================================================

/// Padding متجاوب للصفحات
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? customMobile;
  final EdgeInsetsGeometry? customTablet;
  final EdgeInsetsGeometry? customDesktop;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.customMobile,
    this.customTablet,
    this.customDesktop,
  });

  @override
  Widget build(BuildContext context) {
    final padding = getResponsiveValue<EdgeInsetsGeometry>(
      context,
      mobile: customMobile ?? const EdgeInsets.all(AlhaiSpacing.sm),
      tablet: customTablet ?? const EdgeInsets.all(AlhaiSpacing.md),
      desktop: customDesktop ?? const EdgeInsets.all(AlhaiSpacing.lg),
    );

    return Padding(padding: padding, child: child);
  }
}

// ============================================================================
// RESPONSIVE TEXT
// ============================================================================

/// نص متجاوب يتغير حجمه حسب الشاشة
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double? mobileSize;
  final double? tabletSize;
  final double? desktopSize;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.mobileSize,
    this.tabletSize,
    this.desktopSize,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final fontSize = getResponsiveValue<double>(
      context,
      mobile: mobileSize ?? 14,
      tablet: tabletSize ?? 15,
      desktop: desktopSize ?? 16,
    );

    final baseStyle = style ?? Theme.of(context).textTheme.bodyMedium;

    return Text(
      text,
      style: baseStyle?.copyWith(fontSize: fontSize),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

// ============================================================================
// RESPONSIVE SPACING
// ============================================================================

/// مسافة رأسية متجاوبة
class ResponsiveGap extends StatelessWidget {
  final double mobile;
  final double? tablet;
  final double desktop;

  const ResponsiveGap({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  /// مسافة صغيرة
  const ResponsiveGap.sm({super.key}) : mobile = 8, tablet = 12, desktop = 16;

  /// مسافة متوسطة
  const ResponsiveGap.md({super.key}) : mobile = 16, tablet = 20, desktop = 24;

  /// مسافة كبيرة
  const ResponsiveGap.lg({super.key}) : mobile = 24, tablet = 28, desktop = 32;

  @override
  Widget build(BuildContext context) {
    final height = getResponsiveValue<double>(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );

    return SizedBox(height: height);
  }
}

// ============================================================================
// RESPONSIVE ICON SIZE
// ============================================================================

/// حجم الأيقونة المتجاوب
double getResponsiveIconSize(
  BuildContext context, {
  double mobile = 20,
  double? tablet,
  double desktop = 24,
}) {
  return getResponsiveValue(
    context,
    mobile: mobile,
    tablet: tablet,
    desktop: desktop,
  );
}

// ============================================================================
// RESPONSIVE FONT SIZE
// ============================================================================

/// حجم الخط المتجاوب
double getResponsiveFontSize(
  BuildContext context, {
  double mobile = 14,
  double? tablet,
  double desktop = 16,
}) {
  return getResponsiveValue(
    context,
    mobile: mobile,
    tablet: tablet,
    desktop: desktop,
  );
}

// ============================================================================
// RESPONSIVE VISIBILITY
// ============================================================================

/// Widget لإخفاء/إظهار المحتوى حسب نوع الجهاز
class ResponsiveVisibility extends StatelessWidget {
  final Widget child;
  final bool visibleOnMobile;
  final bool visibleOnTablet;
  final bool visibleOnDesktop;
  final Widget? replacement;

  const ResponsiveVisibility({
    super.key,
    required this.child,
    this.visibleOnMobile = true,
    this.visibleOnTablet = true,
    this.visibleOnDesktop = true,
    this.replacement,
  });

  /// يظهر فقط على الجوال
  const ResponsiveVisibility.mobileOnly({
    super.key,
    required this.child,
    this.replacement,
  }) : visibleOnMobile = true,
       visibleOnTablet = false,
       visibleOnDesktop = false;

  /// يظهر فقط على سطح المكتب
  const ResponsiveVisibility.desktopOnly({
    super.key,
    required this.child,
    this.replacement,
  }) : visibleOnMobile = false,
       visibleOnTablet = false,
       visibleOnDesktop = true;

  /// مخفي على الجوال
  const ResponsiveVisibility.hiddenOnMobile({
    super.key,
    required this.child,
    this.replacement,
  }) : visibleOnMobile = false,
       visibleOnTablet = true,
       visibleOnDesktop = true;

  @override
  Widget build(BuildContext context) {
    final visible = getResponsiveValue<bool>(
      context,
      mobile: visibleOnMobile,
      tablet: visibleOnTablet,
      desktop: visibleOnDesktop,
    );

    if (visible) return child;
    return replacement ?? const SizedBox.shrink();
  }
}

// ============================================================================
// RESPONSIVE CONSTRAINTS
// ============================================================================

/// قيود متجاوبة للـ Container
class ResponsiveConstraints extends StatelessWidget {
  final Widget child;
  final double? maxWidthMobile;
  final double? maxWidthTablet;
  final double? maxWidthDesktop;

  const ResponsiveConstraints({
    super.key,
    required this.child,
    this.maxWidthMobile,
    this.maxWidthTablet,
    this.maxWidthDesktop,
  });

  /// قيود لـ Card/Dialog
  const ResponsiveConstraints.card({super.key, required this.child})
    : maxWidthMobile = double.infinity,
      maxWidthTablet = 600,
      maxWidthDesktop = 800;

  @override
  Widget build(BuildContext context) {
    final maxWidth = getResponsiveValue<double>(
      context,
      mobile: maxWidthMobile ?? double.infinity,
      tablet: maxWidthTablet ?? 800,
      desktop: maxWidthDesktop ?? 1200,
    );

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    );
  }
}

// ============================================================================
// RESPONSIVE GRID CROSSAXIS COUNT
// ============================================================================

/// دالة للحصول على عدد الأعمدة المناسب للـ Grid
int getResponsiveGridColumns(
  BuildContext context, {
  int mobile = 2,
  int? tablet,
  int desktop = 4,
  double minItemWidth = 150,
}) {
  final width = MediaQuery.sizeOf(context).width;

  // حساب تلقائي إذا لم يُحدد
  final autoColumns = (width / minItemWidth).floor().clamp(1, 6);

  return getResponsiveValue<int>(
    context,
    mobile: mobile.clamp(1, autoColumns),
    tablet: tablet ?? (desktop - 1).clamp(2, autoColumns),
    desktop: desktop.clamp(2, autoColumns),
  );
}
