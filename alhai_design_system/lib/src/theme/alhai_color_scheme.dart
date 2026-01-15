import 'package:flutter/material.dart';

import '../tokens/alhai_colors.dart';

/// Color schemes for Alhai Design System
/// Material 3 compliant with light/dark support
abstract final class AlhaiColorScheme {
  // ============================================
  // Light Color Scheme
  // ============================================

  static ColorScheme get light => const ColorScheme(
        brightness: Brightness.light,
        // Primary
        primary: AlhaiColors.primary,
        onPrimary: AlhaiColors.onPrimary,
        primaryContainer: AlhaiColors.primaryLight,
        onPrimaryContainer: AlhaiColors.primaryDark,
        // Secondary
        secondary: AlhaiColors.secondary,
        onSecondary: AlhaiColors.onSecondary,
        secondaryContainer: AlhaiColors.secondaryLight,
        onSecondaryContainer: AlhaiColors.secondaryDark,
        // Tertiary (using info colors)
        tertiary: AlhaiColors.info,
        onTertiary: AlhaiColors.onInfo,
        tertiaryContainer: AlhaiColors.infoLight,
        onTertiaryContainer: AlhaiColors.infoDark,
        // Error
        error: AlhaiColors.error,
        onError: AlhaiColors.onError,
        errorContainer: AlhaiColors.errorLight,
        onErrorContainer: AlhaiColors.errorDark,
        // Surface
        surface: AlhaiColors.surfaceLight,
        onSurface: AlhaiColors.onSurfaceLight,
        surfaceContainerHighest: AlhaiColors.surfaceVariantLight,
        onSurfaceVariant: AlhaiColors.onSurfaceVariantLight,
        // Outline
        outline: AlhaiColors.outlineLight,
        outlineVariant: AlhaiColors.outlineVariantLight,
        // Shadow/Scrim
        shadow: AlhaiColors.shadow,
        scrim: AlhaiColors.scrim,
        // Inverse
        inverseSurface: AlhaiColors.surfaceDark,
        onInverseSurface: AlhaiColors.onSurfaceDark,
        inversePrimary: AlhaiColors.primaryLight,
      );

  // ============================================
  // Dark Color Scheme
  // ============================================

  static ColorScheme get dark => const ColorScheme(
        brightness: Brightness.dark,
        // Primary
        primary: AlhaiColors.primaryLight,
        onPrimary: AlhaiColors.primaryDark,
        primaryContainer: AlhaiColors.primaryDark,
        onPrimaryContainer: AlhaiColors.primaryLight,
        // Secondary
        secondary: AlhaiColors.secondaryLight,
        onSecondary: AlhaiColors.secondaryDark,
        secondaryContainer: AlhaiColors.secondaryDark,
        onSecondaryContainer: AlhaiColors.secondaryLight,
        // Tertiary
        tertiary: AlhaiColors.infoLight,
        onTertiary: AlhaiColors.infoDark,
        tertiaryContainer: AlhaiColors.infoDark,
        onTertiaryContainer: AlhaiColors.infoLight,
        // Error
        error: AlhaiColors.errorLight,
        onError: AlhaiColors.errorDark,
        errorContainer: AlhaiColors.errorDark,
        onErrorContainer: AlhaiColors.errorLight,
        // Surface
        surface: AlhaiColors.surfaceDark,
        onSurface: AlhaiColors.onSurfaceDark,
        surfaceContainerHighest: AlhaiColors.surfaceVariantDark,
        onSurfaceVariant: AlhaiColors.onSurfaceVariantDark,
        // Outline
        outline: AlhaiColors.outlineDark,
        outlineVariant: AlhaiColors.outlineVariantDark,
        // Shadow/Scrim
        shadow: AlhaiColors.shadowDark,
        scrim: AlhaiColors.scrimDark,
        // Inverse
        inverseSurface: AlhaiColors.surfaceLight,
        onInverseSurface: AlhaiColors.onSurfaceLight,
        inversePrimary: AlhaiColors.primary,
      );
}
