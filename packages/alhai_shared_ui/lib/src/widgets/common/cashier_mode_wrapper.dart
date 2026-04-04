import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alhai_design_system/alhai_design_system.dart'
    show AlhaiColors, AlhaiSpacing;
import '../../providers/cashier_mode_provider.dart';

// ============================================================================
// ACCESSIBILITY TEXT SCALE (L79)
// ============================================================================

/// مزود إعداد حجم النص العام لجميع التطبيقات
///
/// L79: Extracted from CashierModeWrapper so any app (not just cashier)
/// can offer text scaling to users via settings.
///
/// Usage in any app's MaterialApp builder:
/// ```dart
/// MaterialApp(
///   builder: (context, child) {
///     return AccessibilityScaleWrapper(child: child ?? const SizedBox());
///   },
/// )
/// ```
final accessibilityTextScaleProvider =
    StateNotifierProvider<AccessibilityTextScaleNotifier, double>(
  (ref) => AccessibilityTextScaleNotifier(),
);

/// مدير حجم النص للوصول
class AccessibilityTextScaleNotifier extends StateNotifier<double> {
  AccessibilityTextScaleNotifier() : super(1.0) {
    _loadScale();
  }

  static const String _prefKey = 'accessibility_text_scale';

  /// القيم المسموح بها لحجم النص
  static const List<double> allowedScales = [0.85, 1.0, 1.15, 1.3, 1.5];

  /// الحد الأدنى لحجم النص
  static const double minScale = 0.85;

  /// الحد الأقصى لحجم النص
  static const double maxScale = 1.5;

  Future<void> _loadScale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getDouble(_prefKey);
      if (saved != null && saved >= minScale && saved <= maxScale) {
        state = saved;
      }
    } catch (_) {}
  }

  /// تعيين حجم النص
  Future<void> setScale(double scale) async {
    final clamped = scale.clamp(minScale, maxScale);
    state = clamped;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_prefKey, clamped);
    } catch (_) {}
  }

  /// إعادة تعيين حجم النص الافتراضي
  Future<void> resetScale() async => setScale(1.0);

  /// تكبير خطوة واحدة
  Future<void> increaseScale() async {
    final currentIndex = allowedScales.indexOf(
      allowedScales.firstWhere((s) => s >= state, orElse: () => state),
    );
    if (currentIndex < allowedScales.length - 1) {
      await setScale(allowedScales[currentIndex + 1]);
    }
  }

  /// تصغير خطوة واحدة
  Future<void> decreaseScale() async {
    final currentIndex = allowedScales.indexOf(
      allowedScales.lastWhere((s) => s <= state, orElse: () => state),
    );
    if (currentIndex > 0) {
      await setScale(allowedScales[currentIndex - 1]);
    }
  }
}

/// Wrapper لتطبيق حجم النص العام على أي تطبيق.
///
/// يلف الـ child بـ [MediaQuery] محدّث بحجم النص المختار.
/// يمكن استخدامه مع أي تطبيق، ليس فقط الكاشير.
///
/// ```dart
/// MaterialApp(
///   builder: (context, child) {
///     return AccessibilityScaleWrapper(child: child ?? const SizedBox());
///   },
/// )
/// ```
class AccessibilityScaleWrapper extends ConsumerWidget {
  final Widget child;

  const AccessibilityScaleWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textScale = ref.watch(accessibilityTextScaleProvider);

    // إذا كان الحجم الافتراضي، لا حاجة لتغيير MediaQuery
    if (textScale == 1.0) return child;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(textScale),
      ),
      child: child,
    );
  }
}

// ============================================================================
// CASHIER MODE WRAPPER (original)
// ============================================================================

/// Wrapper لتطبيق تأثيرات وضع الكاشير
///
/// يحيط بالـ MaterialApp أو بالـ body لتطبيق:
/// - تكبير النص
/// - تباين عالي
/// - تعطيل الأنيميشن
///
/// L79: For text scaling only (without high contrast / reduced animations),
/// use [AccessibilityScaleWrapper] instead. This wrapper is cashier-specific.
class CashierModeWrapper extends ConsumerWidget {
  final Widget child;

  const CashierModeWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cashierMode = ref.watch(cashierModeProvider);

    if (!cashierMode.isEnabled) {
      return child;
    }

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        // تكبير النص
        textScaler: TextScaler.linear(cashierMode.textScale),
        // تقليل الأنيميشن
        disableAnimations: cashierMode.reducedAnimations,
      ),
      child: Theme(
        data: _buildCashierTheme(context, cashierMode),
        child: child,
      ),
    );
  }

  ThemeData _buildCashierTheme(BuildContext context, CashierModeState mode) {
    final baseTheme = Theme.of(context);

    if (!mode.highContrast) return baseTheme;

    // تطبيق تباين عالي WCAG AAA
    return baseTheme.copyWith(
      colorScheme: baseTheme.colorScheme.copyWith(
        // ألوان عالية التباين
        primary: AlhaiColors.infoDark,
        onPrimary: Colors.white,
        secondary: AlhaiColors.warningDark,
        onSecondary: Colors.white,
        surface: Colors.white,
        onSurface: Colors.black,
        error: AlhaiColors.error,
        onError: Colors.white,
      ),
      // أزرار أكبر
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(88, 56), // أكبر من الافتراضي
          textStyle: baseTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(88, 56),
          textStyle: baseTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      // Cards بحدود واضحة
      cardTheme: baseTheme.cardTheme.copyWith(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.black26, width: 1),
        ),
      ),
      // IconButtons أكبر
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(56, 56),
          iconSize: 28,
        ),
      ),
      // نص أكثر وضوحاً
      textTheme: baseTheme.textTheme.apply(
        bodyColor: Colors.black,
        displayColor: Colors.black,
      ),
    );
  }
}

/// Widget لعرض مؤشر وضع الكاشير
class CashierModeBadge extends ConsumerWidget {
  const CashierModeBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEnabled = ref.watch(isCashierModeEnabled);

    if (!isEnabled) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AlhaiSpacing.xs, vertical: AlhaiSpacing.xxs),
      decoration: BoxDecoration(
        color: AlhaiColors.warning.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AlhaiColors.warning),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.speed, size: 16, color: AlhaiColors.warningDark),
          SizedBox(width: AlhaiSpacing.xxs),
          Text(
            'وضع الكاشير',
            style: TextStyle(
              color: AlhaiColors.warningDark,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
