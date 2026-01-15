import 'package:flutter/material.dart';

import '../tokens/alhai_colors.dart';

/// Theme extensions for Alhai Design System
/// Additional semantic colors and custom properties

/// Extension for semantic status colors
class AlhaiStatusColors extends ThemeExtension<AlhaiStatusColors> {
  final Color success;
  final Color successLight;
  final Color onSuccess;
  final Color warning;
  final Color warningLight;
  final Color onWarning;
  final Color info;
  final Color infoLight;
  final Color onInfo;
  final Color error;
  final Color errorLight;
  final Color onError;

  const AlhaiStatusColors({
    required this.success,
    required this.successLight,
    required this.onSuccess,
    required this.warning,
    required this.warningLight,
    required this.onWarning,
    required this.info,
    required this.infoLight,
    required this.onInfo,
    required this.error,
    required this.errorLight,
    required this.onError,
  });

  /// Light theme status colors
  static const light = AlhaiStatusColors(
    success: AlhaiColors.success,
    successLight: AlhaiColors.successLight,
    onSuccess: AlhaiColors.onSuccess,
    warning: AlhaiColors.warning,
    warningLight: AlhaiColors.warningLight,
    onWarning: AlhaiColors.onWarning,
    info: AlhaiColors.info,
    infoLight: AlhaiColors.infoLight,
    onInfo: AlhaiColors.onInfo,
    error: AlhaiColors.error,
    errorLight: AlhaiColors.errorLight,
    onError: AlhaiColors.onError,
  );

  /// Dark theme status colors (white text on status backgrounds for contrast)
  static const dark = AlhaiStatusColors(
    success: AlhaiColors.successLight,
    successLight: AlhaiColors.successDark,
    onSuccess: Color(0xFFFFFFFF), // White text on success
    warning: AlhaiColors.warningLight,
    warningLight: AlhaiColors.warningDark,
    onWarning: Color(0xFF121212), // Dark text on warning (yellow is bright)
    info: AlhaiColors.infoLight,
    infoLight: AlhaiColors.infoDark,
    onInfo: Color(0xFFFFFFFF), // White text on info
    error: AlhaiColors.errorLight,
    errorLight: AlhaiColors.errorDark,
    onError: Color(0xFFFFFFFF), // White text on error
  );

  @override
  AlhaiStatusColors copyWith({
    Color? success,
    Color? successLight,
    Color? onSuccess,
    Color? warning,
    Color? warningLight,
    Color? onWarning,
    Color? info,
    Color? infoLight,
    Color? onInfo,
    Color? error,
    Color? errorLight,
    Color? onError,
  }) {
    return AlhaiStatusColors(
      success: success ?? this.success,
      successLight: successLight ?? this.successLight,
      onSuccess: onSuccess ?? this.onSuccess,
      warning: warning ?? this.warning,
      warningLight: warningLight ?? this.warningLight,
      onWarning: onWarning ?? this.onWarning,
      info: info ?? this.info,
      infoLight: infoLight ?? this.infoLight,
      onInfo: onInfo ?? this.onInfo,
      error: error ?? this.error,
      errorLight: errorLight ?? this.errorLight,
      onError: onError ?? this.onError,
    );
  }

  @override
  AlhaiStatusColors lerp(ThemeExtension<AlhaiStatusColors>? other, double t) {
    if (other is! AlhaiStatusColors) return this;
    return AlhaiStatusColors(
      success: Color.lerp(success, other.success, t)!,
      successLight: Color.lerp(successLight, other.successLight, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningLight: Color.lerp(warningLight, other.warningLight, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoLight: Color.lerp(infoLight, other.infoLight, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
      error: Color.lerp(error, other.error, t)!,
      errorLight: Color.lerp(errorLight, other.errorLight, t)!,
      onError: Color.lerp(onError, other.onError, t)!,
    );
  }
}

/// Extension helper to access status colors from context
extension AlhaiStatusColorsExtension on BuildContext {
  /// Get status colors from current theme
  AlhaiStatusColors get statusColors =>
      Theme.of(this).extension<AlhaiStatusColors>() ?? AlhaiStatusColors.light;
}
