import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tokens/alhai_radius.dart';
import '../tokens/alhai_spacing.dart';
import '../tokens/alhai_typography.dart';
import 'alhai_color_scheme.dart';
import 'theme_extensions.dart';

/// Main theme builder for Alhai Design System
/// Material 3 compliant with RTL-first support
abstract final class AlhaiTheme {
  // ============================================
  // Light Theme
  // ============================================

  static ThemeData get light => _buildTheme(
        colorScheme: AlhaiColorScheme.light,
        statusColors: AlhaiStatusColors.light,
        brightness: Brightness.light,
      );

  // ============================================
  // Dark Theme
  // ============================================

  static ThemeData get dark => _buildTheme(
        colorScheme: AlhaiColorScheme.dark,
        statusColors: AlhaiStatusColors.dark,
        brightness: Brightness.dark,
      );

  // ============================================
  // Theme Builder
  // ============================================

  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required AlhaiStatusColors statusColors,
    required Brightness brightness,
  }) {
    // تطبيق الألوان فقط على body/display، الأزرار تأخذ ألوانها من ColorScheme
    final textTheme = AlhaiTypography.textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      brightness: brightness,
      visualDensity: VisualDensity.adaptivePlatformDensity,

      // تثبيت الخط عالميًا
      // Note: ThemeData.fontFamily does not support fontFamilyFallback.
      // Multi-script fallback (Hindi, Bengali) is applied via the textTheme
      // where each TextStyle includes AlhaiTypography.fontFamilyFallback.
      fontFamily: AlhaiTypography.fontFamily,

      // Ripple/Splash موحّد
      splashFactory: InkSparkle.splashFactory,

      // Extensions
      extensions: [statusColors],

      // أيقونات موحدة
      iconTheme: IconThemeData(color: colorScheme.onSurface),
      primaryIconTheme: IconThemeData(color: colorScheme.onSurface),

      // materialTapTargetSize: يُفرض في cashier فقط (MaterialTapTargetSize.padded)

      // Text Selection (Cursor/Selection موحّد)
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colorScheme.primary,
        selectionColor: colorScheme.primary.withValues(alpha: 0.25),
        selectionHandleColor: colorScheme.primary,
      ),

      // Scrollbar (افتراضي - فعّل thumbVisibility في cashier فقط)
      scrollbarTheme: ScrollbarThemeData(
        thickness: const WidgetStatePropertyAll(6),
        radius: const Radius.circular(999),
        thumbColor: WidgetStatePropertyAll(colorScheme.onSurface
            .withValues(alpha: brightness == Brightness.dark ? 0.45 : 0.35)),
      ),

      // pageTransitionsTheme: يُفرض في كل تطبيق حسب احتياجه
      // cashier يستخدم FadeUpwards، consumer/delivery يتركون iOS الافتراضي

      // App Bar
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent, // منع tint تلقائي مع scroll
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        systemOverlayStyle: brightness == Brightness.light
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
        ),
      ),

      // Scaffold
      scaffoldBackgroundColor: colorScheme.surface,

      // Card
      cardTheme: CardThemeData(
        surfaceTintColor: Colors.transparent, // منع tint تلقائي
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AlhaiRadius.card),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        color: colorScheme.surface,
        margin: const EdgeInsets.all(AlhaiSpacing.xs),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          foregroundColor: colorScheme.onPrimary,
          backgroundColor: colorScheme.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AlhaiSpacing.buttonPaddingHorizontal,
            vertical: AlhaiSpacing.buttonPaddingVertical,
          ),
          minimumSize: const Size(88, AlhaiSpacing.minTouchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AlhaiRadius.button),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),

      // Filled Button
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          foregroundColor: colorScheme.onPrimary,
          backgroundColor: colorScheme.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AlhaiSpacing.buttonPaddingHorizontal,
            vertical: AlhaiSpacing.buttonPaddingVertical,
          ),
          minimumSize: const Size(88, AlhaiSpacing.minTouchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AlhaiRadius.button),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AlhaiSpacing.buttonPaddingHorizontal,
            vertical: AlhaiSpacing.buttonPaddingVertical,
          ),
          minimumSize: const Size(88, AlhaiSpacing.minTouchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AlhaiRadius.button),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary, // اتساق مع Outlined
          padding: const EdgeInsets.symmetric(
            horizontal: AlhaiSpacing.md,
            vertical: AlhaiSpacing.sm,
          ),
          minimumSize: const Size(64, AlhaiSpacing.minTouchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AlhaiRadius.button),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),

      // Icon Button
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(
              AlhaiSpacing.minTouchTarget, AlhaiSpacing.minTouchTarget),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AlhaiSpacing.md,
          vertical: AlhaiSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AlhaiRadius.input),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AlhaiRadius.input),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AlhaiRadius.input),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AlhaiRadius.input),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AlhaiRadius.input),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AlhaiRadius.input),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        helperStyle: textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        errorStyle: textTheme.bodySmall?.copyWith(
          color: colorScheme.error,
        ),
        errorMaxLines: 3,
        helperMaxLines: 2,
      ),

      // Chip
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AlhaiRadius.chip),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AlhaiSpacing.sm,
          vertical: AlhaiSpacing.xxs,
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        elevation: 0,
      ),

      // Navigation Bar (Material 3)
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelMedium?.copyWith(
              color: colorScheme.primary,
            );
          }
          return textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          );
        }),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        surfaceTintColor: Colors.transparent, // منع tint تلقائي
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AlhaiRadius.dialog),
        ),
        backgroundColor: colorScheme.surface,
      ),

      // Bottom Sheet
      bottomSheetTheme: BottomSheetThemeData(
        surfaceTintColor: Colors.transparent, // منع tint تلقائي
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AlhaiRadius.bottomSheet),
          ),
        ),
        backgroundColor: colorScheme.surface,
        dragHandleColor: colorScheme.outline,
        dragHandleSize: const Size(32, 4),
        showDragHandle: true,
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AlhaiRadius.sm),
        ),
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onInverseSurface,
        ),
        actionTextColor: colorScheme.inversePrimary,
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      // List Tile
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AlhaiSpacing.md,
        ),
        minVerticalPadding: AlhaiSpacing.sm,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AlhaiRadius.sm),
        ),
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primaryContainer;
          }
          return colorScheme.surfaceContainerHighest;
        }),
      ),

      // Checkbox
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // Radio
      radioTheme: const RadioThemeData(),

      // Progress Indicator
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.primaryContainer,
        circularTrackColor: colorScheme.primaryContainer,
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 2,
        highlightElevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AlhaiRadius.lg),
        ),
      ),

      // Tooltip
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: colorScheme.inverseSurface,
          borderRadius: BorderRadius.circular(AlhaiRadius.xs),
        ),
        textStyle: textTheme.bodySmall?.copyWith(
          color: colorScheme.onInverseSurface,
        ),
      ),
    );
  }
}
