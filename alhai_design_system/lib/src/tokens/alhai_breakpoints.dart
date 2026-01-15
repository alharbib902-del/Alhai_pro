/// Responsive breakpoints for Alhai Design System
/// Mobile-first approach
abstract final class AlhaiBreakpoints {
  // ============================================
  // Breakpoint Values
  // ============================================

  /// Mobile: 0 - 599
  static const double mobile = 0.0;

  /// Mobile max width
  static const double mobileMax = 599.0;

  /// Tablet: 600 - 904
  static const double tablet = 600.0;

  /// Tablet max width
  static const double tabletMax = 904.0;

  /// Desktop: 905+
  static const double desktop = 905.0;

  /// Large desktop: 1240+
  static const double desktopLarge = 1240.0;

  // ============================================
  // Content Width Constraints
  // ============================================

  /// Maximum content width for readability
  static const double maxContentWidth = 1200.0;

  /// Maximum form width
  static const double maxFormWidth = 480.0;

  /// Maximum card width
  static const double maxCardWidth = 400.0;

  /// Maximum dialog width
  static const double maxDialogWidth = 560.0;

  // ============================================
  // Grid Columns
  // ============================================

  /// Mobile grid columns
  static const int mobileColumns = 4;

  /// Tablet grid columns
  static const int tabletColumns = 8;

  /// Desktop grid columns
  static const int desktopColumns = 12;

  // ============================================
  // Helpers
  // ============================================

  /// Check if width is mobile
  static bool isMobile(double width) => width < tablet;

  /// Check if width is tablet
  static bool isTablet(double width) => width >= tablet && width < desktop;

  /// Check if width is desktop
  static bool isDesktop(double width) => width >= desktop;

  /// Get number of columns for width
  static int getColumns(double width) {
    if (width < tablet) return mobileColumns;
    if (width < desktop) return tabletColumns;
    return desktopColumns;
  }
}
