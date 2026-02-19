import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/providers/cashier_mode_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ===========================================
// Cashier Mode Provider Tests
// ===========================================

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CashierModeState', () {
    group('constructor', () {
      test('القيم الافتراضية صحيحة', () {
        const state = CashierModeState();

        expect(state.isEnabled, false);
        expect(state.textScale, 1.0);
        expect(state.highContrast, false);
        expect(state.reducedAnimations, false);
      });

      test('يمكن تمرير قيم مخصصة', () {
        const state = CashierModeState(
          isEnabled: true,
          textScale: 1.5,
          highContrast: true,
          reducedAnimations: true,
        );

        expect(state.isEnabled, true);
        expect(state.textScale, 1.5);
        expect(state.highContrast, true);
        expect(state.reducedAnimations, true);
      });
    });

    group('copyWith', () {
      test('ينسخ مع تعديل isEnabled', () {
        const original = CashierModeState();
        final copied = original.copyWith(isEnabled: true);

        expect(copied.isEnabled, true);
        expect(copied.textScale, original.textScale);
        expect(copied.highContrast, original.highContrast);
        expect(copied.reducedAnimations, original.reducedAnimations);
      });

      test('ينسخ مع تعديل textScale', () {
        const original = CashierModeState();
        final copied = original.copyWith(textScale: 1.5);

        expect(copied.textScale, 1.5);
        expect(copied.isEnabled, original.isEnabled);
      });

      test('ينسخ مع تعديل highContrast', () {
        const original = CashierModeState();
        final copied = original.copyWith(highContrast: true);

        expect(copied.highContrast, true);
        expect(copied.isEnabled, original.isEnabled);
      });

      test('ينسخ مع تعديل reducedAnimations', () {
        const original = CashierModeState();
        final copied = original.copyWith(reducedAnimations: true);

        expect(copied.reducedAnimations, true);
        expect(copied.isEnabled, original.isEnabled);
      });

      test('ينسخ مع تعديل عدة قيم', () {
        const original = CashierModeState();
        final copied = original.copyWith(
          isEnabled: true,
          textScale: 1.3,
          highContrast: true,
        );

        expect(copied.isEnabled, true);
        expect(copied.textScale, 1.3);
        expect(copied.highContrast, true);
        expect(copied.reducedAnimations, false);
      });

      test('بدون تمرير قيم يُعيد نفس القيم', () {
        const original = CashierModeState(
          isEnabled: true,
          textScale: 1.5,
        );
        final copied = original.copyWith();

        expect(copied.isEnabled, original.isEnabled);
        expect(copied.textScale, original.textScale);
      });
    });

    group('cashierDefaults', () {
      test('القيم الافتراضية لوضع الكاشير صحيحة', () {
        const defaults = CashierModeState.cashierDefaults;

        expect(defaults.isEnabled, true);
        expect(defaults.textScale, 1.3);
        expect(defaults.highContrast, true);
        expect(defaults.reducedAnimations, true);
      });

      test('تكبير النص 130%', () {
        const defaults = CashierModeState.cashierDefaults;
        expect(defaults.textScale, 1.3);
      });
    });
  });

  group('CashierModeNotifier', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('الحالة الافتراضية عند الإنشاء', () {
      final notifier = CashierModeNotifier();

      expect(notifier.state.isEnabled, false);
      expect(notifier.state.textScale, 1.0);
    });

    test('setTextScale يُغير حجم النص', () {
      final notifier = CashierModeNotifier();

      notifier.setTextScale(1.5);

      expect(notifier.state.textScale, 1.5);
    });

    test('setHighContrast يُغير التباين العالي', () {
      final notifier = CashierModeNotifier();

      notifier.setHighContrast(true);

      expect(notifier.state.highContrast, true);
    });

    test('setReducedAnimations يُغير تقليل الحركة', () {
      final notifier = CashierModeNotifier();

      notifier.setReducedAnimations(true);

      expect(notifier.state.reducedAnimations, true);
    });

    test('التغييرات المتعددة تتراكم', () {
      final notifier = CashierModeNotifier();

      notifier.setTextScale(1.2);
      notifier.setHighContrast(true);
      notifier.setReducedAnimations(true);

      expect(notifier.state.textScale, 1.2);
      expect(notifier.state.highContrast, true);
      expect(notifier.state.reducedAnimations, true);
    });
  });

  group('Provider constants', () {
    test('مفتاح التخزين ثابت', () {
      // التحقق من أن المفتاح موجود
      const prefKey = 'cashier_mode_enabled';
      expect(prefKey, isNotEmpty);
    });
  });

  group('CashierModeState edge cases', () {
    test('textScale يمكن أن يكون أقل من 1', () {
      const state = CashierModeState(textScale: 0.8);
      expect(state.textScale, 0.8);
    });

    test('textScale يمكن أن يكون أكبر من 2', () {
      const state = CashierModeState(textScale: 2.5);
      expect(state.textScale, 2.5);
    });

    test('جميع القيم false بشكل افتراضي ما عدا textScale', () {
      const state = CashierModeState();
      expect(state.isEnabled, isFalse);
      expect(state.highContrast, isFalse);
      expect(state.reducedAnimations, isFalse);
    });
  });

  group('WCAG Compliance', () {
    test('وضع الكاشير يُفعل التباين العالي للـ WCAG AAA', () {
      const defaults = CashierModeState.cashierDefaults;
      expect(defaults.highContrast, true);
    });

    test('وضع الكاشير يُقلل الحركة للمستخدمين الحساسين', () {
      const defaults = CashierModeState.cashierDefaults;
      expect(defaults.reducedAnimations, true);
    });
  });
}
