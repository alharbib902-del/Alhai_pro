import 'package:flutter/material.dart';

/// Responsive text scale factor based on screen width.
///
/// Named [ResponsiveTextScale] to avoid collision with the
/// [ResponsiveText] widget in responsive_utils.dart.
class ResponsiveTextScale {
  static double scaleFactor(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return 0.85;
    if (width < 600) return 1.0;
    if (width < 905) return 1.05;
    return 1.1;
  }

  /// Get responsive font size
  static double fontSize(BuildContext context, double baseSize) {
    return baseSize * scaleFactor(context);
  }
}
