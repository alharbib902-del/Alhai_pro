import 'package:flutter/material.dart';

import '../tokens/alhai_breakpoints.dart';
import '../tokens/alhai_spacing.dart';

/// BuildContext extensions for responsive utilities
extension AlhaiContextExtensions on BuildContext {
  // ============================================
  // Size Helpers
  // ============================================

  /// Screen width
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// Screen height
  double get screenHeight => MediaQuery.sizeOf(this).height;

  /// Screen size
  Size get screenSize => MediaQuery.sizeOf(this);

  // ============================================
  // Breakpoint Helpers
  // ============================================

  /// Is mobile size
  bool get isMobile => AlhaiBreakpoints.isMobile(screenWidth);

  /// Is tablet size
  bool get isTablet => AlhaiBreakpoints.isTablet(screenWidth);

  /// Is desktop size
  bool get isDesktop => AlhaiBreakpoints.isDesktop(screenWidth);

  /// Is wide screen (>= 1536)
  bool get isWide => screenWidth >= 1536;

  /// Current column count
  int get columns => AlhaiBreakpoints.getColumns(screenWidth);

  // ============================================
  // Orientation Helpers
  // ============================================

  /// Is portrait orientation
  bool get isPortrait =>
      MediaQuery.orientationOf(this) == Orientation.portrait;

  /// Is landscape orientation
  bool get isLandscape =>
      MediaQuery.orientationOf(this) == Orientation.landscape;

  // ============================================
  // Safe Area Helpers
  // ============================================

  /// Top safe area padding
  double get safeTop => MediaQuery.paddingOf(this).top;

  /// Bottom safe area padding
  double get safeBottom => MediaQuery.paddingOf(this).bottom;

  /// Left safe area padding
  double get safeLeft => MediaQuery.paddingOf(this).left;

  /// Right safe area padding
  double get safeRight => MediaQuery.paddingOf(this).right;

  /// All safe area padding
  EdgeInsets get safePadding => MediaQuery.paddingOf(this);

  /// Keyboard view insets (bottom keyboard height)
  EdgeInsets get viewInsets => MediaQuery.viewInsetsOf(this);

  /// Whether user prefers reduced motion (accessibility)
  bool get prefersReducedMotion => MediaQuery.disableAnimationsOf(this);
  
  /// Keyboard-aware page insets (safe area + keyboard)
  EdgeInsets get pageInsets =>
      EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(this).bottom) + safePadding;
  
  /// Alias for pageInsets (clearer naming)
  EdgeInsets get safeKeyboardInsets => pageInsets;
  
  /// Standard page padding preset
  EdgeInsets get pagePadding => const EdgeInsets.symmetric(
    horizontal: AlhaiSpacing.pagePaddingHorizontal,
    vertical: AlhaiSpacing.pagePaddingVertical,
  );

  // ============================================
  // Theme Helpers
  // ============================================

  /// Current theme
  ThemeData get theme => Theme.of(this);

  /// Current color scheme
  ColorScheme get colorScheme => theme.colorScheme;

  /// Current text theme
  TextTheme get textTheme => theme.textTheme;

  /// Is dark mode
  bool get isDarkMode => theme.brightness == Brightness.dark;

  // ============================================
  // RTL Helpers
  // ============================================

  /// Is RTL direction
  bool get isRtl => Directionality.of(this) == TextDirection.rtl;

  /// Is LTR direction
  bool get isLtr => Directionality.of(this) == TextDirection.ltr;

  // ============================================
  // Responsive Value Selection
  // ============================================

  /// Select a value based on screen size
  T responsive<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }

  /// Select padding based on screen size
  EdgeInsets responsivePadding({
    EdgeInsets mobile = const EdgeInsets.all(AlhaiSpacing.md),
    EdgeInsets? tablet,
    EdgeInsets? desktop,
  }) {
    return responsive(mobile: mobile, tablet: tablet, desktop: desktop);
  }

  /// Select spacing based on screen size
  double responsiveSpacing({
    double mobile = AlhaiSpacing.md,
    double? tablet,
    double? desktop,
  }) {
    return responsive(mobile: mobile, tablet: tablet, desktop: desktop);
  }

  // ============================================
  // Padding Helpers
  // ============================================

  /// Resolve EdgeInsetsGeometry to EdgeInsets based on current direction
  EdgeInsets resolvePadding(EdgeInsetsGeometry padding) {
    return padding.resolve(Directionality.of(this));
  }

  /// Current text direction
  TextDirection get textDirection => Directionality.of(this);
}
