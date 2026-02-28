/// ثيم التطبيق - App Theme
///
/// يوفر تصميم موحد للتطبيق مع دعم الوضع الفاتح والداكن
/// مُحسّن لنظام البقالة (Fresh Grocery)
///
/// تم دمج الثيمين (الفاتح والداكن) في دالة مشتركة `_buildTheme`
/// لتجنب تكرار ~95% من الكود.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_sizes.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'app_typography.dart';

// ============================================================================
// APP THEME
// ============================================================================

/// ثيم التطبيق
class AppTheme {
  AppTheme._();

  // ==========================================================================
  // COLOR SCHEMES
  // ==========================================================================

  static const _lightColorScheme = ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: AppColors.textOnPrimary,
    primaryContainer: AppColors.primarySurface,
    onPrimaryContainer: AppColors.primaryDark,
    secondary: AppColors.secondary,
    onSecondary: AppColors.textOnPrimary,
    secondaryContainer: AppColors.secondarySurface,
    onSecondaryContainer: AppColors.secondaryDark,
    error: AppColors.error,
    onError: AppColors.textOnPrimary,
    errorContainer: AppColors.errorSurface,
    onErrorContainer: AppColors.error,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    surfaceContainerHighest: AppColors.surfaceVariant,
    onSurfaceVariant: AppColors.textSecondary,
    outline: AppColors.border,
    outlineVariant: AppColors.divider,
  );

  static const _darkColorScheme = ColorScheme.dark(
    primary: AppColors.primaryLight,
    onPrimary: AppColors.textOnPrimary,
    primaryContainer: AppColors.primaryDark,
    onPrimaryContainer: AppColors.primaryLight,
    secondary: AppColors.secondary,
    onSecondary: AppColors.textOnPrimary,
    secondaryContainer: AppColors.secondaryDark,
    onSecondaryContainer: AppColors.secondaryLight,
    error: AppColors.error,
    onError: AppColors.textOnPrimary,
    errorContainer: AppColors.errorSurface,
    onErrorContainer: AppColors.error,
    surface: AppColors.surfaceDark,
    onSurface: AppColors.textPrimaryDark,
    surfaceContainerHighest: AppColors.surfaceVariantDark,
    onSurfaceVariant: AppColors.textSecondaryDark,
    outline: AppColors.borderDark,
    outlineVariant: AppColors.grey700,
  );

  // ==========================================================================
  // PUBLIC GETTERS
  // ==========================================================================

  /// الثيم الفاتح
  static ThemeData get light => _buildTheme(isDark: false);

  /// الثيم الداكن
  static ThemeData get dark => _buildTheme(isDark: true);

  // ==========================================================================
  // SHARED THEME BUILDER
  // ==========================================================================

  static ThemeData _buildTheme({required bool isDark}) {
    // --- Color palette based on mode ---
    final colorScheme = isDark ? _darkColorScheme : _lightColorScheme;
    final brightness = isDark ? Brightness.dark : Brightness.light;
    final scaffoldBg = isDark ? AppColors.backgroundDark : AppColors.background;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final surfaceVariant = isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final textMuted = isDark ? AppColors.textMutedDark : AppColors.textMuted;
    final border = isDark ? AppColors.borderDark : AppColors.border;
    final disabledBg = isDark ? AppColors.grey700 : AppColors.grey200;
    final disabledFg = isDark ? AppColors.textMutedDark : AppColors.textMuted;

    final textTheme = isDark
        ? AppTypography.textTheme.apply(
            bodyColor: textPrimary,
            displayColor: textPrimary,
          )
        : AppTypography.textTheme;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      fontFamily: AppTypography.fontFamily,
      scaffoldBackgroundColor: scaffoldBg,
      textTheme: textTheme,

      // ====================================================================
      // AppBar
      // ====================================================================
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: surface,
        foregroundColor: textPrimary,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: brightness,
        ),
        titleTextStyle: AppTypography.titleLarge.copyWith(color: textPrimary),
      ),

      // ====================================================================
      // Cards
      // ====================================================================
      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // ====================================================================
      // Elevated Button
      // ====================================================================
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          disabledBackgroundColor: disabledBg,
          disabledForegroundColor: disabledFg,
          minimumSize: const Size(AppButtonSize.minWidth, AppButtonSize.heightMd),
          padding: const EdgeInsets.symmetric(
            horizontal: AppButtonSize.paddingHorizontal,
            vertical: AppButtonSize.paddingVertical,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: AppTypography.buttonMedium,
        ),
      ),

      // ====================================================================
      // Filled Button
      // ====================================================================
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          disabledBackgroundColor: disabledBg,
          disabledForegroundColor: disabledFg,
          minimumSize: const Size(AppButtonSize.minWidth, AppButtonSize.heightMd),
          padding: const EdgeInsets.symmetric(
            horizontal: AppButtonSize.paddingHorizontal,
            vertical: AppButtonSize.paddingVertical,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: AppTypography.buttonMedium,
        ),
      ),

      // ====================================================================
      // Outlined Button
      // ====================================================================
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: disabledFg,
          minimumSize: const Size(AppButtonSize.minWidth, AppButtonSize.heightMd),
          padding: const EdgeInsets.symmetric(
            horizontal: AppButtonSize.paddingHorizontal,
            vertical: AppButtonSize.paddingVertical,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          side: BorderSide(color: border, width: 1),
          textStyle: AppTypography.buttonMedium,
        ),
      ),

      // ====================================================================
      // Text Button
      // ====================================================================
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          textStyle: AppTypography.buttonMedium,
        ),
      ),

      // ====================================================================
      // Icon Button
      // ====================================================================
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: textSecondary,
          hoverColor: isDark ? AppColors.primary.withValues(alpha: 0.15) : AppColors.primarySurface,
          highlightColor: isDark ? AppColors.primary.withValues(alpha: 0.2) : AppColors.primarySurface,
        ),
      ),

      // ====================================================================
      // Input Decoration
      // ====================================================================
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppInputSize.padding,
          vertical: AppSpacing.md,
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(color: textMuted),
        labelStyle: AppTypography.bodyMedium.copyWith(color: textSecondary),
        errorStyle: AppTypography.bodySmall.copyWith(color: AppColors.error),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
      ),

      // ====================================================================
      // Floating Action Button
      // ====================================================================
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),

      // ====================================================================
      // Bottom Navigation Bar
      // ====================================================================
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: textMuted,
        showUnselectedLabels: true,
        elevation: 8,
      ),

      // ====================================================================
      // Navigation Rail (for web)
      // ====================================================================
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: surface,
        selectedIconTheme: const IconThemeData(color: AppColors.primary),
        unselectedIconTheme: IconThemeData(color: textSecondary),
        selectedLabelTextStyle: AppTypography.labelMedium.copyWith(
          color: AppColors.primary,
        ),
        unselectedLabelTextStyle: AppTypography.labelMedium.copyWith(
          color: textSecondary,
        ),
        indicatorColor: AppColors.primarySurface,
      ),

      // ====================================================================
      // Navigation Drawer
      // ====================================================================
      drawerTheme: DrawerThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(left: Radius.circular(0)),
        ),
      ),

      // ====================================================================
      // Dialog
      // ====================================================================
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDialogSize.radius),
        ),
        titleTextStyle: AppTypography.titleLarge.copyWith(color: textPrimary),
        contentTextStyle: AppTypography.bodyMedium.copyWith(color: textSecondary),
      ),

      // ====================================================================
      // Bottom Sheet
      // ====================================================================
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppBottomSheetSize.topRadius),
          ),
        ),
        dragHandleColor: isDark ? AppColors.grey400 : AppColors.grey300,
        dragHandleSize: const Size(
          AppBottomSheetSize.handleWidth,
          AppBottomSheetSize.handleHeight,
        ),
      ),

      // ====================================================================
      // Snackbar
      // ====================================================================
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? AppColors.grey100 : AppColors.grey900,
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: isDark ? AppColors.textPrimary : AppColors.textPrimaryDark,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        elevation: 4,
      ),

      // ====================================================================
      // Chip
      // ====================================================================
      chipTheme: ChipThemeData(
        backgroundColor: surfaceVariant,
        selectedColor: isDark ? AppColors.primary.withValues(alpha: 0.2) : AppColors.primarySurface,
        secondarySelectedColor: isDark ? AppColors.primary.withValues(alpha: 0.2) : AppColors.primarySurface,
        labelStyle: AppTypography.labelMedium,
        secondaryLabelStyle: AppTypography.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        side: BorderSide.none,
      ),

      // ====================================================================
      // Divider
      // ====================================================================
      dividerTheme: DividerThemeData(
        color: border,
        space: 1,
        thickness: 1,
      ),

      // ====================================================================
      // List Tile
      // ====================================================================
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        titleTextStyle: AppTypography.bodyLarge.copyWith(color: textPrimary),
        subtitleTextStyle: AppTypography.bodySmall.copyWith(color: textSecondary),
        leadingAndTrailingTextStyle: AppTypography.labelMedium.copyWith(
          color: textSecondary,
        ),
      ),

      // ====================================================================
      // Tab Bar
      // ====================================================================
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: textSecondary,
        labelStyle: AppTypography.labelLarge,
        unselectedLabelStyle: AppTypography.labelLarge,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
      ),

      // ====================================================================
      // Progress Indicator
      // ====================================================================
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: isDark ? AppColors.grey700 : AppColors.primarySurface,
        circularTrackColor: isDark ? AppColors.grey700 : AppColors.primarySurface,
      ),

      // ====================================================================
      // Switch
      // ====================================================================
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return AppColors.grey400;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primarySurface;
          return AppColors.grey200;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      // ====================================================================
      // Checkbox
      // ====================================================================
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.textOnPrimary),
        side: const BorderSide(color: AppColors.grey400, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xs),
        ),
      ),

      // ====================================================================
      // Radio
      // ====================================================================
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return AppColors.grey400;
        }),
      ),

      // ====================================================================
      // Slider
      // ====================================================================
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.primarySurface,
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primary.withValues(alpha: 0.1),
      ),

      // ====================================================================
      // Data Table
      // ====================================================================
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(surfaceVariant),
        dataRowColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primarySurface;
          if (states.contains(WidgetState.hovered)) return surfaceVariant;
          return surface;
        }),
        headingTextStyle: AppTypography.labelLarge.copyWith(color: textPrimary),
        dataTextStyle: AppTypography.bodyMedium.copyWith(color: textPrimary),
        dividerThickness: 1,
      ),

      // ====================================================================
      // Tooltip
      // ====================================================================
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark ? AppColors.grey100 : AppColors.grey800,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        textStyle: AppTypography.bodySmall.copyWith(
          color: isDark ? AppColors.textPrimary : AppColors.textPrimaryDark,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),

      // ====================================================================
      // Popup Menu
      // ====================================================================
      popupMenuTheme: PopupMenuThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: AppTypography.bodyMedium,
      ),

      // ====================================================================
      // Dropdown Menu
      // ====================================================================
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: AppTypography.bodyMedium,
        menuStyle: MenuStyle(
          backgroundColor: WidgetStateProperty.all(surface),
          surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
          elevation: WidgetStateProperty.all(4),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        ),
      ),

      // ====================================================================
      // Badge
      // ====================================================================
      badgeTheme: const BadgeThemeData(
        backgroundColor: AppColors.error,
        textColor: AppColors.textOnPrimary,
        textStyle: AppTypography.badge,
      ),

      // ====================================================================
      // Expansion Tile
      // ====================================================================
      expansionTileTheme: ExpansionTileThemeData(
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        iconColor: textSecondary,
        collapsedIconColor: textSecondary,
        textColor: textPrimary,
        collapsedTextColor: textPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }
}
