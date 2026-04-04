/// AnimatedContentSwitcher - smooth fade+slide transition for state changes
///
/// Wraps content with [AnimatedSwitcher] to animate between
/// loading / error / data states with a subtle vertical slide.
library;

import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

/// Wraps content with a smooth fade+slide transition for state changes
class AnimatedContentSwitcher extends StatelessWidget {
  final Widget child;
  final Duration duration;

  const AnimatedContentSwitcher({
    super.key,
    required this.child,
    this.duration = AlhaiMotion.durationMedium,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: AlhaiMotion.standardDecelerate,
      switchOutCurve: AlhaiMotion.standardAccelerate,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.02),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
