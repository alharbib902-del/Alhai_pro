/// Centralized timing constants for the Cashier app.
///
/// Using named constants instead of magic numbers improves readability,
/// makes it easy to tune timings globally, and avoids inconsistencies
/// across screens.
library;

/// Animation and transition durations.
abstract final class AnimationDurations {
  /// Standard widget animation (expand/collapse, fade, slide).
  static const standard = Duration(milliseconds: 200);

  /// Slightly longer animation for search debounce.
  static const debounce = Duration(milliseconds: 300);
}

/// Network and I/O timeout durations.
abstract final class Timeouts {
  /// Connectivity check timeout.
  static const connectivityCheck = Duration(seconds: 5);

  /// Offline queue flush timeout.
  static const queueFlush = Duration(seconds: 30);

  /// Quick Supabase session check on web.
  static const sessionCheck = Duration(milliseconds: 500);

  /// Post-operation delay (e.g. after save, before navigation).
  static const postOperationDelay = Duration(seconds: 1);

  /// Device discovery / scan timeout.
  static const deviceDiscovery = Duration(seconds: 10);

  /// Printer probe timeout.
  static const printerProbe = Duration(seconds: 2);

  /// Double-back-to-exit window.
  static const doubleBackExit = Duration(seconds: 2);

  /// Cache clear reload delay.
  static const reloadDelay = Duration(milliseconds: 500);

  /// Snackbar display duration.
  static const snackbarDuration = Duration(seconds: 3);
}
