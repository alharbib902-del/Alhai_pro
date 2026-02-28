import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// حالة وضع الكاشير
/// 
/// عند تفعيله:
/// - تكبير الأزرار 150%
/// - تباين عالي WCAG AAA
/// - تعطيل الأنيميشن الثقيلة
class CashierModeState {
  final bool isEnabled;
  final double textScale;
  final bool highContrast;
  final bool reducedAnimations;

  const CashierModeState({
    this.isEnabled = false,
    this.textScale = 1.0,
    this.highContrast = false,
    this.reducedAnimations = false,
  });

  CashierModeState copyWith({
    bool? isEnabled,
    double? textScale,
    bool? highContrast,
    bool? reducedAnimations,
  }) {
    return CashierModeState(
      isEnabled: isEnabled ?? this.isEnabled,
      textScale: textScale ?? this.textScale,
      highContrast: highContrast ?? this.highContrast,
      reducedAnimations: reducedAnimations ?? this.reducedAnimations,
    );
  }

  /// إعدادات وضع الكاشير الافتراضية
  static const CashierModeState cashierDefaults = CashierModeState(
    isEnabled: true,
    textScale: 1.3,  // تكبير 130%
    highContrast: true,
    reducedAnimations: true,
  );
}

/// مدير وضع الكاشير
class CashierModeNotifier extends StateNotifier<CashierModeState> {
  CashierModeNotifier() : super(const CashierModeState()) {
    _loadFromPrefs();
  }

  static const _prefKey = 'cashier_mode_enabled';

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool(_prefKey) ?? false;
    if (isEnabled) {
      state = CashierModeState.cashierDefaults;
    }
  }

  Future<void> toggle() async {
    final newEnabled = !state.isEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, newEnabled);
    
    if (newEnabled) {
      state = CashierModeState.cashierDefaults;
    } else {
      state = const CashierModeState();
    }
  }

  void setTextScale(double scale) {
    state = state.copyWith(textScale: scale);
  }

  void setHighContrast(bool enabled) {
    state = state.copyWith(highContrast: enabled);
  }

  void setReducedAnimations(bool enabled) {
    state = state.copyWith(reducedAnimations: enabled);
  }
}

/// مزود وضع الكاشير
final cashierModeProvider = StateNotifierProvider<CashierModeNotifier, CashierModeState>(
  (ref) => CashierModeNotifier(),
);

/// مزود هل وضع الكاشير مفعل
final isCashierModeEnabled = Provider<bool>((ref) {
  return ref.watch(cashierModeProvider).isEnabled;
});

/// مزود حجم النص
final cashierTextScale = Provider<double>((ref) {
  return ref.watch(cashierModeProvider).textScale;
});

/// مزود التباين العالي
final cashierHighContrast = Provider<bool>((ref) {
  return ref.watch(cashierModeProvider).highContrast;
});
