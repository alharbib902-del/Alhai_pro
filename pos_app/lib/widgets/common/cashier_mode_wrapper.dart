import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/cashier_mode_provider.dart';

/// Wrapper لتطبيق تأثيرات وضع الكاشير
/// 
/// يحيط بالـ MaterialApp أو بالـ body لتطبيق:
/// - تكبير النص
/// - تباين عالي
/// - تعطيل الأنيميشن
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
        primary: Colors.blue.shade800,
        onPrimary: Colors.white,
        secondary: Colors.orange.shade800,
        onSecondary: Colors.white,
        surface: Colors.white,
        onSurface: Colors.black,
        error: Colors.red.shade900,
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.speed, size: 16, color: Colors.orange.shade800),
          const SizedBox(width: 4),
          Text(
            'وضع الكاشير',
            style: TextStyle(
              color: Colors.orange.shade800,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
