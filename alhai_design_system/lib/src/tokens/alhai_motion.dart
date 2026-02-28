import 'package:flutter/material.dart';

/// Motion/Curves tokens for Alhai Design System
/// Material 3 compliant easing curves
///
/// Includes convenience widgets:
/// - [AlhaiFadeIn] / [AlhaiFadeOut] - opacity transitions
/// - [AlhaiScaleIn] - scale entrance animation
/// - [AlhaiSlideUp] - slide-up entrance animation
/// - [AlhaiRotateIn] - rotation entrance animation
/// - [AlhaiPageTransitionsBuilder] - shared page transition builder for GoRouter
abstract final class AlhaiMotion {
  // ============================================
  // Duration Constants (Material 3)
  // ============================================

  /// Extra short duration (50ms) - For micro-interactions
  static const Duration durationExtraShort = Duration(milliseconds: 50);

  /// Short duration (100ms) - For simple state changes
  static const Duration durationShort = Duration(milliseconds: 100);

  /// Fast duration (150ms) - For fade in/out
  static const Duration durationFast = Duration(milliseconds: 150);

  /// Medium duration (250ms) - For most transitions
  static const Duration durationMedium = Duration(milliseconds: 250);

  /// Long duration (400ms) - For complex animations
  static const Duration durationLong = Duration(milliseconds: 400);

  /// Extra long duration (600ms) - For dramatic transitions
  static const Duration durationExtraLong = Duration(milliseconds: 600);

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

  // ============================================
  // Mascot Animation Duration
  // ============================================

  /// Mascot animation duration (1000ms) - reduced from 2-3s for snappier UX.
  /// Use for floating, breathing, idle mascot animations.
  static const Duration mascotDuration = Duration(milliseconds: 1000);

  /// Mascot loop duration (1200ms) - for continuous looping mascot animations.
  static const Duration mascotLoopDuration = Duration(milliseconds: 1200);
}

// ==============================================================================
// CONVENIENCE ANIMATION WIDGETS
// ==============================================================================

/// Fade-in animation widget using AlhaiMotion tokens.
///
/// Wraps a child with an implicit fade-in using [TweenAnimationBuilder].
/// ```dart
/// AlhaiFadeIn(child: Text('Hello'))
/// ```
class AlhaiFadeIn extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const AlhaiFadeIn({
    super.key,
    required this.child,
    this.duration = AlhaiMotion.durationFast,
    this.curve = AlhaiMotion.fadeIn,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Opacity(opacity: value, child: child);
      },
      child: child,
    );
  }
}

/// Fade-out animation widget using AlhaiMotion tokens.
///
/// Animates child from fully visible to transparent.
/// ```dart
/// AlhaiFadeOut(child: Text('Goodbye'))
/// ```
class AlhaiFadeOut extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const AlhaiFadeOut({
    super.key,
    required this.child,
    this.duration = AlhaiMotion.durationFast,
    this.curve = AlhaiMotion.fadeOut,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 0.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Opacity(opacity: value, child: child);
      },
      child: child,
    );
  }
}

/// Scale-in animation widget using AlhaiMotion tokens.
///
/// Scales child from 0 to 1 with a configurable curve.
/// ```dart
/// AlhaiScaleIn(child: Icon(Icons.check))
/// ```
class AlhaiScaleIn extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final double beginScale;

  const AlhaiScaleIn({
    super.key,
    required this.child,
    this.duration = AlhaiMotion.durationMedium,
    this.curve = AlhaiMotion.scaleUp,
    this.beginScale = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: beginScale, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: child,
    );
  }
}

/// Slide-up entrance animation widget.
///
/// Slides child from below into position with fade.
/// ```dart
/// AlhaiSlideUp(child: Card(...))
/// ```
class AlhaiSlideUp extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final double offsetY;

  const AlhaiSlideUp({
    super.key,
    required this.child,
    this.duration = AlhaiMotion.durationMedium,
    this.curve = AlhaiMotion.standardDecelerate,
    this.offsetY = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 0.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, offsetY * value),
          child: Opacity(opacity: 1.0 - value, child: child),
        );
      },
      child: child,
    );
  }
}

/// Rotation entrance animation widget.
///
/// Rotates child from a starting angle to 0 (upright).
/// ```dart
/// AlhaiRotateIn(child: Icon(Icons.refresh))
/// ```
class AlhaiRotateIn extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  /// Starting rotation in turns (1.0 = 360 degrees).
  final double beginTurns;

  const AlhaiRotateIn({
    super.key,
    required this.child,
    this.duration = AlhaiMotion.durationMedium,
    this.curve = AlhaiMotion.standard,
    this.beginTurns = 0.25,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: beginTurns, end: 0.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.rotate(angle: value * 2 * 3.14159265, child: child);
      },
      child: child,
    );
  }
}

/// Shared page transition builder for GoRouter.
///
/// Uses AlhaiMotion curves for consistent page enter/exit animations.
/// ```dart
/// GoRoute(
///   pageBuilder: (context, state) => CustomTransitionPage(
///     transitionsBuilder: AlhaiPageTransitionsBuilder.slideFromEnd,
///     child: MyScreen(),
///   ),
/// )
/// ```
class AlhaiPageTransitionsBuilder {
  AlhaiPageTransitionsBuilder._();

  /// Slide from end (right in LTR, left in RTL) with fade.
  static Widget slideFromEnd(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final begin = Offset(isRtl ? -1.0 : 1.0, 0.0);
    return SlideTransition(
      position: Tween(begin: begin, end: Offset.zero).animate(
        CurvedAnimation(parent: animation, curve: AlhaiMotion.standardDecelerate),
      ),
      child: FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: AlhaiMotion.fadeIn),
        child: child,
      ),
    );
  }

  /// Fade transition only.
  static Widget fade(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: AlhaiMotion.fadeIn),
      child: child,
    );
  }

  /// Scale + fade transition for modal-like pages.
  static Widget scaleUp(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return ScaleTransition(
      scale: Tween(begin: 0.92, end: 1.0).animate(
        CurvedAnimation(parent: animation, curve: AlhaiMotion.emphasizedDecelerate),
      ),
      child: FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: AlhaiMotion.fadeIn),
        child: child,
      ),
    );
  }
}

/// Staggered list animation helper.
///
/// Wraps each item in a list with a delayed slide+fade animation.
/// ```dart
/// ListView.builder(
///   itemBuilder: (ctx, i) => AlhaiStaggeredItem(
///     index: i,
///     child: MyListTile(...),
///   ),
/// )
/// ```
class AlhaiStaggeredItem extends StatelessWidget {
  final int index;
  final Widget child;
  final Duration itemDelay;
  final Duration itemDuration;

  const AlhaiStaggeredItem({
    super.key,
    required this.index,
    required this.child,
    this.itemDelay = const Duration(milliseconds: 50),
    this.itemDuration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    final delay = itemDelay * index;
    final totalDuration = delay + itemDuration;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: totalDuration,
      curve: Interval(
        delay.inMilliseconds / totalDuration.inMilliseconds,
        1.0,
        curve: AlhaiMotion.standardDecelerate,
      ),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 16 * (1.0 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: child,
    );
  }
}
