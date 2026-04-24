import 'dart:math' show min, max;
import 'package:flutter/material.dart';

/// Responsive dialog helpers — cap dialog width on tablets/desktops and
/// pick sensible defaults for heights.
///
/// Phase 2, task 2.4: expanded with `showAlert` to make it a one-liner
/// replacement for `showDialog(context: ctx, builder: (_) => AlertDialog(...))`
/// so the 11+ audit sites (apply_interest:695, split receipt confirms, etc.)
/// get responsive behaviour for free.
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
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
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

  /// Show a responsive [AlertDialog] — drop-in replacement for the common
  /// `showDialog(builder: (_) => AlertDialog(...))` pattern.
  ///
  /// Wraps the AlertDialog's `insetPadding` so width is capped at [maxDesktop]
  /// or 90% of the screen (whichever is smaller). Use this for confirmation
  /// dialogs, error dialogs, and other short-form prompts.
  ///
  /// Usage:
  /// ```dart
  /// final confirmed = await ResponsiveDialog.showAlert<bool>(
  ///   context,
  ///   title: Text(l10n.confirmInterest),
  ///   content: Text(l10n.confirmInterestMessage(...)),
  ///   actions: [
  ///     TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
  ///     FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.confirm)),
  ///   ],
  /// );
  /// ```
  static Future<T?> showAlert<T>(
    BuildContext context, {
    Widget? icon,
    Widget? title,
    Widget? content,
    List<Widget>? actions,
    MainAxisAlignment actionsAlignment = MainAxisAlignment.end,
    double maxDesktop = 560,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (ctx) {
        final screenWidth = MediaQuery.of(ctx).size.width;
        final cap = min(maxDesktop, screenWidth * 0.9);
        final horizontalInset = max(0.0, (screenWidth - cap) / 2);
        return AlertDialog(
          icon: icon,
          title: title,
          content: content,
          actions: actions,
          actionsAlignment: actionsAlignment,
          insetPadding: EdgeInsets.symmetric(
            horizontal: horizontalInset,
            vertical: 24,
          ),
        );
      },
    );
  }
}
