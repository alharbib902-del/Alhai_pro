import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/deliveries/providers/driving_mode_provider.dart';

/// Wraps a subtree and increases [MediaQuery.textScaler] when driving mode
/// is active.
///
/// Use this around delivery-flow screens so that text and touch targets
/// automatically grow to a glance-safe size while driving.
class DrivingModeScale extends ConsumerWidget {
  final Widget child;

  /// Text scale when driving mode is OFF.
  final double normalScale;

  /// Text scale when driving mode is ON.
  final double drivingScale;

  const DrivingModeScale({
    super.key,
    required this.child,
    this.normalScale = 1.0,
    this.drivingScale = 1.4,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDriving = ref.watch(drivingModeProvider);
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(isDriving ? drivingScale : normalScale),
      ),
      child: child,
    );
  }
}
