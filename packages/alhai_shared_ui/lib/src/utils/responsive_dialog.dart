import 'dart:math' show min;
import 'package:flutter/material.dart';

class ResponsiveDialog {
  /// Get max width for dialogs based on screen size
  static double maxWidth(BuildContext context, {double maxDesktop = 560}) {
    final screenWidth = MediaQuery.of(context).size.width;
    return min(screenWidth * 0.9, maxDesktop);
  }

  /// Get max height for bottom sheets
  static double maxHeight(BuildContext context, {double fraction = 0.7}) {
    return MediaQuery.of(context).size.height * fraction;
  }

  /// Show a responsive dialog
  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    double maxDesktop = 560,
  }) {
    return showDialog<T>(
      context: context,
      builder: (ctx) => Dialog(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth(ctx, maxDesktop: maxDesktop),
            maxHeight: MediaQuery.of(ctx).size.height * 0.85,
          ),
          child: child,
        ),
      ),
    );
  }
}
