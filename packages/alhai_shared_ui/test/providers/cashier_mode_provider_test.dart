/// Unit tests for cashier mode provider
///
/// Tests: CashierModeState model, CashierModeNotifier behavior
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:alhai_shared_ui/alhai_shared_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  group('CashierModeState', () {
    test('has correct default values', () {
      const state = CashierModeState();
      expect(state.isEnabled, isFalse);
      expect(state.textScale, 1.0);
      expect(state.highContrast, isFalse);
      expect(state.reducedAnimations, isFalse);
    });

    test('cashierDefaults has correct values', () {
      const state = CashierModeState.cashierDefaults;
      expect(state.isEnabled, isTrue);
      expect(state.textScale, 1.3);
      expect(state.highContrast, isTrue);
      expect(state.reducedAnimations, isTrue);
    });

    test('copyWith updates isEnabled', () {
      const state = CashierModeState();
      final updated = state.copyWith(isEnabled: true);
      expect(updated.isEnabled, isTrue);
      expect(updated.textScale, 1.0); // unchanged
    });

    test('copyWith updates textScale', () {
      const state = CashierModeState();
      final updated = state.copyWith(textScale: 1.5);
      expect(updated.textScale, 1.5);
    });

    test('copyWith updates highContrast', () {
      const state = CashierModeState();
      final updated = state.copyWith(highContrast: true);
      expect(updated.highContrast, isTrue);
    });

    test('copyWith updates reducedAnimations', () {
      const state = CashierModeState();
      final updated = state.copyWith(reducedAnimations: true);
      expect(updated.reducedAnimations, isTrue);
    });

    test('copyWith with no args preserves state', () {
      const state = CashierModeState(
        isEnabled: true,
        textScale: 1.3,
        highContrast: true,
        reducedAnimations: true,
      );
      final copied = state.copyWith();
      expect(copied.isEnabled, state.isEnabled);
      expect(copied.textScale, state.textScale);
      expect(copied.highContrast, state.highContrast);
      expect(copied.reducedAnimations, state.reducedAnimations);
    });
  });

  group('CashierModeNotifier', () {
    test('initializes with default disabled state', () {
      final notifier = CashierModeNotifier();
      expect(notifier.state.isEnabled, isFalse);
      expect(notifier.state.textScale, 1.0);
    });

    test('setTextScale updates text scale', () {
      final notifier = CashierModeNotifier();
      notifier.setTextScale(1.5);
      expect(notifier.state.textScale, 1.5);
    });

    test('setHighContrast updates high contrast', () {
      final notifier = CashierModeNotifier();
      notifier.setHighContrast(true);
      expect(notifier.state.highContrast, isTrue);
    });

    test('setReducedAnimations updates reduced animations', () {
      final notifier = CashierModeNotifier();
      notifier.setReducedAnimations(true);
      expect(notifier.state.reducedAnimations, isTrue);
    });
  });
}
