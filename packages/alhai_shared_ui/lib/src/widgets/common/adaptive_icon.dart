/// Adaptive directional icon that auto-mirrors in RTL layouts.
///
/// Use this for icons that have an inherent direction (arrows, chevrons, etc.)
/// to ensure they display correctly in both LTR and RTL contexts.
///
/// Usage:
/// ```dart
/// // As a widget (replaces Icon):
/// AdaptiveAdaptiveIcon(Icons.chevron_right, size: 18, color: Theme.of(context).hintColor)
///
/// // Get mirrored IconData for use in icon: properties:
/// icon: AdaptiveIcon.data(context, Icons.arrow_forward)
/// ```
library;

import 'package:flutter/material.dart';

/// Widget that automatically mirrors directional icons in RTL layouts.
class AdaptiveIcon extends StatelessWidget {
  final IconData icon;
  final double? size;
  final Color? color;
  final String? semanticLabel;

  const AdaptiveIcon(
    this.icon, {
    this.size,
    this.color,
    this.semanticLabel,
    super.key,
  });

  // ===========================================================================
  // Directional icon pairs: LTR ↔ RTL
  // ===========================================================================

  static final _mirrorMap = <IconData, IconData>{
    // Chevrons
    Icons.chevron_left: Icons.chevron_right,
    Icons.chevron_right: Icons.chevron_left,
    Icons.chevron_left_rounded: Icons.chevron_right_rounded,
    Icons.chevron_right_rounded: Icons.chevron_left_rounded,

    // Arrows
    Icons.arrow_forward: Icons.arrow_back,
    Icons.arrow_back: Icons.arrow_forward,
    Icons.arrow_forward_rounded: Icons.arrow_back_rounded,
    Icons.arrow_back_rounded: Icons.arrow_forward_rounded,
    Icons.arrow_forward_ios: Icons.arrow_back_ios,
    Icons.arrow_back_ios: Icons.arrow_forward_ios,
    Icons.arrow_forward_ios_rounded: Icons.arrow_back_ios_rounded,
    Icons.arrow_back_ios_rounded: Icons.arrow_forward_ios_rounded,

    // Pagination
    Icons.first_page: Icons.last_page,
    Icons.last_page: Icons.first_page,
    Icons.navigate_before: Icons.navigate_next,
    Icons.navigate_next: Icons.navigate_before,

    // Keyboard arrows
    Icons.keyboard_arrow_left: Icons.keyboard_arrow_right,
    Icons.keyboard_arrow_right: Icons.keyboard_arrow_left,
  };

  /// Icons that should be flipped via Transform (no paired counterpart)
  static final _flipIcons = <IconData>{Icons.send, Icons.send_rounded};

  // ===========================================================================
  // Static helpers
  // ===========================================================================

  /// Returns the directionally-correct [IconData] for the current layout.
  ///
  /// Use this when you need [IconData] rather than a widget, e.g.:
  /// ```dart
  /// IconButton(icon: Icon(AdaptiveIcon.data(context, Icons.arrow_forward)))
  /// ```
  static IconData data(BuildContext context, IconData icon) {
    if (Directionality.of(context) != TextDirection.rtl) return icon;
    return _mirrorMap[icon] ?? icon;
  }

  /// Whether the given icon is directional and needs RTL adaptation.
  static bool isDirectional(IconData icon) =>
      _mirrorMap.containsKey(icon) || _flipIcons.contains(icon);

  // ===========================================================================
  // Build
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    // Paired icons: swap to the mirrored counterpart
    if (isRtl && _mirrorMap.containsKey(icon)) {
      return Icon(
        _mirrorMap[icon],
        size: size,
        color: color,
        semanticLabel: semanticLabel,
      );
    }

    // Flip icons: mirror via Transform
    if (isRtl && _flipIcons.contains(icon)) {
      return Transform.flip(
        flipX: true,
        child: Icon(
          icon,
          size: size,
          color: color,
          semanticLabel: semanticLabel,
        ),
      );
    }

    // Non-directional or LTR: render normally
    return Icon(icon, size: size, color: color, semanticLabel: semanticLabel);
  }
}
