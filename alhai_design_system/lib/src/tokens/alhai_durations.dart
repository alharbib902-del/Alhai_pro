/// Animation duration tokens for Alhai Design System
/// Optimized for smooth UX without jank
abstract final class AlhaiDurations {
  // ============================================
  // Duration Scale
  // ============================================

  /// 0ms - Instant (no animation)
  static const Duration zero = Duration.zero;

  /// 50ms - Ultra fast (micro-interactions)
  static const Duration ultraFast = Duration(milliseconds: 50);

  /// 100ms - Fast (subtle feedback)
  static const Duration fast = Duration(milliseconds: 100);

  /// 150ms - Quick (button press, ripples)
  static const Duration quick = Duration(milliseconds: 150);

  /// 200ms - Standard (default transitions)
  static const Duration standard = Duration(milliseconds: 200);

  /// 250ms - Medium (modal open)
  static const Duration medium = Duration(milliseconds: 250);

  /// 300ms - Slow (page transitions)
  static const Duration slow = Duration(milliseconds: 300);

  /// 400ms - Very slow (complex animations)
  static const Duration verySlow = Duration(milliseconds: 400);

  /// 500ms - Extra slow (emphasis animations)
  static const Duration extraSlow = Duration(milliseconds: 500);

  // ============================================
  // Semantic Durations
  // ============================================

  /// Button press feedback
  static const Duration buttonPress = quick;

  /// Ripple effect
  static const Duration ripple = standard;

  /// Focus indicator
  static const Duration focus = fast;

  /// Hover effect
  static const Duration hover = fast;

  /// Page transition
  static const Duration pageTransition = slow;

  /// Modal/Dialog open
  static const Duration modalOpen = medium;

  /// Modal/Dialog close
  static const Duration modalClose = standard;

  /// Snackbar show
  static const Duration snackbarShow = medium;

  /// Snackbar visible duration
  static const Duration snackbarVisible = Duration(seconds: 4);

  /// Loading indicator cycle
  static const Duration loadingCycle = Duration(milliseconds: 1200);

  /// Skeleton shimmer
  static const Duration shimmer = Duration(milliseconds: 1500);
}
