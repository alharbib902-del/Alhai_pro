/// Animation Durations & Curves
///
/// Extracted from app_sizes.dart for cleaner organization
///
// TODO(L88-L91): Animation system improvements planned:
// - L88: Shared page transition builder using AlhaiMotion curves
// - L89: Staggered list/grid entrance animation helpers
// - L90: Hero animation wrappers for product images and cards
// - L91: Spring-physics animations for drag/swipe interactions
// See also: AlhaiMotion tokens in alhai_design_system for the curve definitions.

import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

// ============================================================================
// ANIMATION DURATIONS
// Unified: delegates to AlhaiMotion for overlapping duration values.
// ============================================================================

/// Animation durations
class AppDurations {
  AppDurations._();

  /// Instant (100ms)
  // Unified: delegates to AlhaiMotion
  static const Duration instant = AlhaiMotion.durationShort;

  /// Fast (200ms)
  // Unified: delegates to AlhaiDurations
  static const Duration fast = AlhaiDurations.standard;

  /// Normal (300ms)
  // Unified: delegates to AlhaiDurations
  static const Duration normal = AlhaiDurations.slow;

  /// Slow (400ms)
  // Unified: delegates to AlhaiMotion
  static const Duration slow = AlhaiMotion.durationLong;

  /// Slower (500ms)
  // Unified: delegates to AlhaiDurations
  static const Duration slower = AlhaiDurations.extraSlow;

  /// Long (600ms)
  // Unified: delegates to AlhaiMotion
  static const Duration long = AlhaiMotion.durationExtraLong;
}

// ============================================================================
// ANIMATION CURVES
// Unified: delegates to AlhaiMotion for overlapping curve values.
// ============================================================================

/// Animation curves
class AppCurves {
  AppCurves._();

  /// Default curve
  // Unified: delegates to AlhaiMotion
  static const Curve defaultCurve = AlhaiMotion.standardDecelerate;

  /// Enter curve
  // Unified: delegates to AlhaiMotion
  static const Curve enter = AlhaiMotion.buttonPress;

  /// Exit curve
  // Unified: delegates to AlhaiMotion
  static const Curve exit = AlhaiMotion.scaleDown;

  /// Bounce curve
  // Unified: delegates to AlhaiMotion
  static const Curve bounce = AlhaiMotion.spring;

  /// Fast curve
  // Unified: delegates to AlhaiMotion
  static const Curve fast = AlhaiMotion.standardDecelerate;
}
