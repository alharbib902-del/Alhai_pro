import 'dart:async';
import 'package:flutter/foundation.dart';

/// A simple debouncer that delays execution until [duration] has passed
/// since the last call to [run].
///
/// Usage:
/// ```dart
/// final _debouncer = Debouncer();
///
/// void onSearchChanged(String query) {
///   _debouncer.run(() => performSearch(query));
/// }
///
/// @override
/// void dispose() {
///   _debouncer.dispose();
///   super.dispose();
/// }
/// ```
class Debouncer {
  final Duration duration;
  Timer? _timer;

  Debouncer({this.duration = const Duration(milliseconds: 300)});

  /// Schedule [action] to run after [duration] of inactivity.
  /// Cancels any previously scheduled action.
  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  /// Cancel any pending action and release resources.
  void dispose() {
    _timer?.cancel();
  }
}
