import 'package:flutter/material.dart';

/// Motion/Curves tokens for Alhai Design System
/// Material 3 compliant easing curves
abstract final class AlhaiMotion {
  // ============================================
  // Standard Curves (Material 3)
  // ============================================

  /// Standard easing - Most common, for elements that move
  static const Curve standard = Curves.easeInOutCubic;

  /// Standard accelerate - Elements leaving the screen
  static const Curve standardAccelerate = Curves.easeInCubic;

  /// Standard decelerate - Elements entering the screen
  static const Curve standardDecelerate = Curves.easeOutCubic;

  // ============================================
  // Emphasized Curves
  // ============================================

  /// Emphasized - For important/large transitions
  static const Curve emphasized = Curves.easeInOutCubicEmphasized;

  /// Emphasized accelerate
  static const Curve emphasizedAccelerate = Curves.easeInExpo;

  /// Emphasized decelerate
  static const Curve emphasizedDecelerate = Curves.easeOutExpo;

  // ============================================
  // Semantic Curves
  // ============================================

  /// Button press feedback
  static const Curve buttonPress = Curves.easeOut;

  /// Page transition forward
  static const Curve pageEnter = standardDecelerate;

  /// Page transition back
  static const Curve pageExit = standardAccelerate;

  /// Modal/Dialog enter
  static const Curve modalEnter = emphasizedDecelerate;

  /// Modal/Dialog exit
  static const Curve modalExit = emphasizedAccelerate;

  /// Scale up (grow)
  static const Curve scaleUp = Curves.easeOutBack;

  /// Scale down (shrink)
  static const Curve scaleDown = Curves.easeIn;

  /// Bounce effect
  static const Curve bounce = Curves.bounceOut;

  /// Spring effect
  static const Curve spring = Curves.elasticOut;

  /// Fade in
  static const Curve fadeIn = Curves.easeIn;

  /// Fade out
  static const Curve fadeOut = Curves.easeOut;

  // ============================================
  // Combined Animation Helpers
  // ============================================

  /// Interval for staggered animations (0.0 to 1.0)
  static Curve interval(double begin, double end, {Curve curve = standard}) {
    return Interval(begin, end, curve: curve);
  }

  /// Reverse a curve
  static Curve reverse(Curve curve) => curve.flipped;
}
