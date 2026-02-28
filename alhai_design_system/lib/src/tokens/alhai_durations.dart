// Unified: delegates to AlhaiMotion for overlapping duration values.
// AlhaiMotion is the canonical source for durations and curves.

import 'alhai_motion.dart';

/// Animation duration tokens for Alhai Design System.
/// Optimized for smooth UX without jank.
///
/// ## Usage Guide
/// Instead of hardcoded `Duration(milliseconds: 300)`, use these tokens:
///
/// | Use case               | Token                        | Duration |
/// |------------------------|------------------------------|----------|
/// | Instant                | `AlhaiDurations.zero`        | 0ms      |
/// | Micro-interactions     | `AlhaiDurations.ultraFast`   | 50ms     |
/// | Subtle feedback        | `AlhaiDurations.fast`        | 100ms    |
/// | Button press, ripples  | `AlhaiDurations.quick`       | 150ms    |
/// | Default transitions    | `AlhaiDurations.standard`    | 200ms    |
/// | Modal/dialog open      | `AlhaiDurations.medium`      | 250ms    |
/// | Page transitions       | `AlhaiDurations.slow`        | 300ms    |
/// | Complex animations     | `AlhaiDurations.verySlow`    | 400ms    |
/// | Emphasis animations    | `AlhaiDurations.extraSlow`   | 500ms    |
/// | Page route transitions | `AlhaiDurations.page`        | 800ms    |
/// | Mascot animations      | `AlhaiDurations.mascot`      | 1000ms   |
///
/// Semantic aliases are also available: `buttonPress`, `ripple`, `hover`,
/// `pageTransition`, `modalOpen`, `modalClose`, `snackbarShow`, etc.
abstract final class AlhaiDurations {
  // ============================================
  // Duration Scale
  // ============================================

  /// 0ms - Instant (no animation)
  static const Duration zero = Duration.zero;

  /// 50ms - Ultra fast (micro-interactions)
  // Unified: delegates to AlhaiMotion
  static const Duration ultraFast = AlhaiMotion.durationExtraShort;

  /// 100ms - Fast (subtle feedback)
  // Unified: delegates to AlhaiMotion
  static const Duration fast = AlhaiMotion.durationShort;

  /// 150ms - Quick (button press, ripples)
  // Unified: delegates to AlhaiMotion
  static const Duration quick = AlhaiMotion.durationFast;

  /// 200ms - Standard (default transitions)
  static const Duration standard = Duration(milliseconds: 200);

  /// 250ms - Medium (modal open)
  // Unified: delegates to AlhaiMotion
  static const Duration medium = AlhaiMotion.durationMedium;

  /// 300ms - Slow (page transitions)
  static const Duration slow = Duration(milliseconds: 300);

  /// 400ms - Very slow (complex animations)
  // Unified: delegates to AlhaiMotion
  static const Duration verySlow = AlhaiMotion.durationLong;

  /// 500ms - Extra slow (emphasis animations)
  static const Duration extraSlow = Duration(milliseconds: 500);

  /// 800ms - Page route transition (full page enter/exit)
  static const Duration page = Duration(milliseconds: 800);

  /// 1000ms - Mascot animation (reduced from 2-3s for snappier feel)
  static const Duration mascot = Duration(milliseconds: 1000);

  /// 1200ms - Long mascot loop (floating, breathing)
  static const Duration mascotLoop = Duration(milliseconds: 1200);

  // ============================================
  // Common Hardcoded Duration Replacements
  // ============================================

  /// 150ms alias - Use instead of `Duration(milliseconds: 150)`
  static const Duration ms150 = quick;

  /// 300ms alias - Use instead of `Duration(milliseconds: 300)`
  static const Duration ms300 = slow;

  /// 500ms alias - Use instead of `Duration(milliseconds: 500)`
  static const Duration ms500 = extraSlow;

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
