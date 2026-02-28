import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

void main() {
  group('LocaleState', () {
    test('initial state uses Arabic locale', () {
      final state = LocaleState.initial();
      expect(state.locale.languageCode, 'ar');
    });

    test('initial state is RTL', () {
      final state = LocaleState.initial();
      expect(state.isRtl, isTrue);
    });

    test('initial state has RTL text direction', () {
      final state = LocaleState.initial();
      expect(state.textDirection, TextDirection.rtl);
    });

    test('fromLocale with Arabic locale is RTL', () {
      final state = LocaleState.fromLocale(SupportedLocales.arabic);
      expect(state.locale, SupportedLocales.arabic);
      expect(state.isRtl, isTrue);
      expect(state.textDirection, TextDirection.rtl);
    });

    test('fromLocale with English locale is LTR', () {
      final state = LocaleState.fromLocale(SupportedLocales.english);
      expect(state.locale, SupportedLocales.english);
      expect(state.isRtl, isFalse);
      expect(state.textDirection, TextDirection.ltr);
    });

    test('fromLocale with Urdu locale is RTL', () {
      final state = LocaleState.fromLocale(SupportedLocales.urdu);
      expect(state.locale, SupportedLocales.urdu);
      expect(state.isRtl, isTrue);
      expect(state.textDirection, TextDirection.rtl);
    });

    test('fromLocale with Hindi locale is LTR', () {
      final state = LocaleState.fromLocale(SupportedLocales.hindi);
      expect(state.locale, SupportedLocales.hindi);
      expect(state.isRtl, isFalse);
      expect(state.textDirection, TextDirection.ltr);
    });

    test('fromLocale with Filipino locale is LTR', () {
      final state = LocaleState.fromLocale(SupportedLocales.filipino);
      expect(state.locale, SupportedLocales.filipino);
      expect(state.isRtl, isFalse);
      expect(state.textDirection, TextDirection.ltr);
    });

    test('fromLocale with Bengali locale is LTR', () {
      final state = LocaleState.fromLocale(SupportedLocales.bengali);
      expect(state.locale, SupportedLocales.bengali);
      expect(state.isRtl, isFalse);
      expect(state.textDirection, TextDirection.ltr);
    });

    test('fromLocale with Indonesian locale is LTR', () {
      final state = LocaleState.fromLocale(SupportedLocales.indonesian);
      expect(state.locale, SupportedLocales.indonesian);
      expect(state.isRtl, isFalse);
      expect(state.textDirection, TextDirection.ltr);
    });
  });

  group('LocaleNotifier', () {
    test('initial state is Arabic', () {
      final notifier = LocaleNotifier();
      expect(notifier.state.locale.languageCode, 'ar');
      expect(notifier.state.isRtl, isTrue);
      addTearDown(notifier.dispose);
    });

    test('setLocale changes the state to English', () async {
      final notifier = LocaleNotifier();
      await notifier.setLocale(SupportedLocales.english);
      expect(notifier.state.locale, SupportedLocales.english);
      expect(notifier.state.isRtl, isFalse);
      expect(notifier.state.textDirection, TextDirection.ltr);
      addTearDown(notifier.dispose);
    });

    test('setLocale changes the state to Urdu', () async {
      final notifier = LocaleNotifier();
      await notifier.setLocale(SupportedLocales.urdu);
      expect(notifier.state.locale, SupportedLocales.urdu);
      expect(notifier.state.isRtl, isTrue);
      expect(notifier.state.textDirection, TextDirection.rtl);
      addTearDown(notifier.dispose);
    });

    test('setLocale ignores unsupported locale', () async {
      final notifier = LocaleNotifier();
      // Set to English first
      await notifier.setLocale(SupportedLocales.english);
      expect(notifier.state.locale, SupportedLocales.english);

      // Try to set to unsupported locale - should be ignored
      await notifier.setLocale(const Locale('de', 'DE'));
      expect(notifier.state.locale, SupportedLocales.english);
      addTearDown(notifier.dispose);
    });

    test('setLocaleByCode changes locale using language code', () async {
      final notifier = LocaleNotifier();
      await notifier.setLocaleByCode('en');
      expect(notifier.state.locale.languageCode, 'en');
      addTearDown(notifier.dispose);
    });

    test('setLocaleByCode falls back to Arabic for unknown code', () async {
      final notifier = LocaleNotifier();
      await notifier.setLocaleByCode('en');
      expect(notifier.state.locale.languageCode, 'en');

      await notifier.setLocaleByCode('xx');
      expect(notifier.state.locale.languageCode, 'ar');
      addTearDown(notifier.dispose);
    });

    test('setLocale updates all state fields consistently', () async {
      final notifier = LocaleNotifier();

      // Check each supported locale sets consistent state
      for (final locale in SupportedLocales.all) {
        await notifier.setLocale(locale);
        final state = notifier.state;
        expect(state.locale, locale);
        expect(state.isRtl, SupportedLocales.isRtl(locale));
        expect(state.textDirection, SupportedLocales.getTextDirection(locale));
      }
      addTearDown(notifier.dispose);
    });
  });
}
