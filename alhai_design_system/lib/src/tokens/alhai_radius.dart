import 'package:flutter/material.dart';

/// Border radius tokens for Alhai Design System
abstract final class AlhaiRadius {
  // ============================================
  // Radius Scale
  // ============================================

  /// 0dp - No radius (sharp corners)
  static const double none = 0.0;

  /// 4dp - Extra small radius
  static const double xs = 4.0;

  /// 8dp - Small radius
  static const double sm = 8.0;

  /// 12dp - Medium radius (default for cards)
  static const double md = 12.0;

  /// 16dp - Large radius
  static const double lg = 16.0;

  /// 20dp - Extra large radius
  static const double xl = 20.0;

  /// 24dp - Extra extra large radius
  static const double xxl = 24.0;

  /// 28dp - Rounded
  static const double rounded = 28.0;

  /// Full circle (use with appropriate width/height)
  static const double full = 999.0;

  // ============================================
  // BorderRadius Helpers
  // ============================================

  /// No border radius
  static const BorderRadius borderNone = BorderRadius.zero;

  /// Extra small border radius (all corners)
  static BorderRadius get borderXs => BorderRadius.circular(xs);

  /// Small border radius (all corners)
  static BorderRadius get borderSm => BorderRadius.circular(sm);

  /// Medium border radius (all corners)
  static BorderRadius get borderMd => BorderRadius.circular(md);

  /// Large border radius (all corners)
  static BorderRadius get borderLg => BorderRadius.circular(lg);

  /// Extra large border radius (all corners)
  static BorderRadius get borderXl => BorderRadius.circular(xl);

  /// Rounded border radius (all corners)
  static BorderRadius get borderRounded => BorderRadius.circular(rounded);

  /// Full circle border radius
  static BorderRadius get borderFull => BorderRadius.circular(full);

  // ============================================
  // Semantic Radii
  // ============================================

  /// Button border radius
  static const double button = 12.0;

  /// Input field border radius
  static const double input = 8.0;

  /// Card border radius
  static const double card = 12.0;

  /// Bottom sheet border radius (top only)
  static const double bottomSheet = 20.0;

  /// Dialog border radius
  static const double dialog = 16.0;

  /// Chip/Tag border radius
  static const double chip = 8.0;

  /// Badge border radius
  static const double badge = 4.0;
}
