import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_l10n/l10n/generated/app_localizations.dart';
import 'package:alhai_l10n/l10n/generated/app_localizations_ar.dart';
import 'package:alhai_l10n/l10n/generated/app_localizations_en.dart';
import 'package:alhai_l10n/l10n/generated/app_localizations_ur.dart';
import 'package:alhai_l10n/l10n/generated/app_localizations_hi.dart';
import 'package:alhai_l10n/l10n/generated/app_localizations_fil.dart';
import 'package:alhai_l10n/l10n/generated/app_localizations_bn.dart';
import 'package:alhai_l10n/l10n/generated/app_localizations_id.dart';

void main() {
  // ─── Supported locales ────────────────────────────────────────────

  group('SupportedLocales', () {
    test('has exactly 7 supported locales', () {
      expect(SupportedLocales.all.length, 7);
    });

    test('contains all expected language codes', () {
      final codes = SupportedLocales.all.map((l) => l.languageCode).toSet();
      expect(codes, containsAll(['ar', 'en', 'ur', 'hi', 'fil', 'bn', 'id']));
    });

    test('Arabic is the first locale (primary)', () {
      expect(SupportedLocales.all.first.languageCode, 'ar');
    });

    test('Arabic locale has SA country code', () {
      expect(SupportedLocales.arabic.countryCode, 'SA');
    });

    test('English locale has US country code', () {
      expect(SupportedLocales.english.countryCode, 'US');
    });
  });

  // ─── RTL detection ────────────────────────────────────────────────

  group('RTL detection', () {
    test('Arabic is RTL', () {
      expect(SupportedLocales.isRtl(SupportedLocales.arabic), isTrue);
    });

    test('Urdu is RTL', () {
      expect(SupportedLocales.isRtl(SupportedLocales.urdu), isTrue);
    });

    test('English is not RTL', () {
      expect(SupportedLocales.isRtl(SupportedLocales.english), isFalse);
    });

    test('Hindi is not RTL', () {
      expect(SupportedLocales.isRtl(SupportedLocales.hindi), isFalse);
    });

    test('Filipino is not RTL', () {
      expect(SupportedLocales.isRtl(SupportedLocales.filipino), isFalse);
    });

    test('Bengali is not RTL', () {
      expect(SupportedLocales.isRtl(SupportedLocales.bengali), isFalse);
    });

    test('Indonesian is not RTL', () {
      expect(SupportedLocales.isRtl(SupportedLocales.indonesian), isFalse);
    });

    test('rtlLanguages list contains ar and ur', () {
      expect(SupportedLocales.rtlLanguages, containsAll(['ar', 'ur']));
      expect(SupportedLocales.rtlLanguages.length, 2);
    });
  });

  // ─── Text direction ───────────────────────────────────────────────

  group('Text direction', () {
    test('Arabic text direction is RTL', () {
      expect(
        SupportedLocales.getTextDirection(SupportedLocales.arabic),
        TextDirection.rtl,
      );
    });

    test('Urdu text direction is RTL', () {
      expect(
        SupportedLocales.getTextDirection(SupportedLocales.urdu),
        TextDirection.rtl,
      );
    });

    test('English text direction is LTR', () {
      expect(
        SupportedLocales.getTextDirection(SupportedLocales.english),
        TextDirection.ltr,
      );
    });

    test('all non-RTL locales return LTR', () {
      final ltrLocales = [
        SupportedLocales.english,
        SupportedLocales.hindi,
        SupportedLocales.filipino,
        SupportedLocales.bengali,
        SupportedLocales.indonesian,
      ];
      for (final locale in ltrLocales) {
        expect(
          SupportedLocales.getTextDirection(locale),
          TextDirection.ltr,
          reason: '${locale.languageCode} should be LTR',
        );
      }
    });
  });

  // ─── Native names ─────────────────────────────────────────────────

  group('Native names', () {
    test('every supported locale has a native name', () {
      for (final locale in SupportedLocales.all) {
        final name = SupportedLocales.getNativeName(locale);
        expect(name, isNotEmpty,
            reason: '${locale.languageCode} missing native name');
      }
    });

    test('Arabic native name is correct', () {
      expect(SupportedLocales.getNativeName(SupportedLocales.arabic),
          '\u0627\u0644\u0639\u0631\u0628\u064a\u0629');
    });

    test('English native name is correct', () {
      expect(
          SupportedLocales.getNativeName(SupportedLocales.english), 'English');
    });

    test('unknown locale returns language code', () {
      final unknown = const Locale('xx');
      expect(SupportedLocales.getNativeName(unknown), 'xx');
    });
  });

  // ─── Flags ────────────────────────────────────────────────────────

  group('Flags', () {
    test('every supported locale has a flag', () {
      for (final locale in SupportedLocales.all) {
        final flag = SupportedLocales.getFlag(locale);
        expect(flag, isNotEmpty, reason: '${locale.languageCode} missing flag');
      }
    });

    test('unknown locale returns globe emoji', () {
      final unknown = const Locale('zz');
      expect(SupportedLocales.getFlag(unknown), '\u{1f310}');
    });
  });

  // ─── AppLocalizations supported locales ───────────────────────────

  group('AppLocalizations supported locales', () {
    test('has exactly 7 supported locales', () {
      expect(AppLocalizations.supportedLocales.length, 7);
    });

    test('supported locale codes match SupportedLocales', () {
      final generatedCodes =
          AppLocalizations.supportedLocales.map((l) => l.languageCode).toSet();
      final providerCodes =
          SupportedLocales.all.map((l) => l.languageCode).toSet();
      expect(generatedCodes, providerCodes);
    });

    test('localizationsDelegates is non-empty', () {
      expect(AppLocalizations.localizationsDelegates, isNotEmpty);
    });

    test('localizationsDelegates includes AppLocalizations delegate', () {
      expect(
        AppLocalizations.localizationsDelegates,
        contains(AppLocalizations.delegate),
      );
    });
  });

  // ─── Arabic localization class ────────────────────────────────────

  group('Arabic locale loads correctly', () {
    test('AppLocalizationsAr can be instantiated', () {
      final ar = AppLocalizationsAr();
      expect(ar.localeName, 'ar');
    });

    test('Arabic appTitle is non-empty', () {
      final ar = AppLocalizationsAr();
      expect(ar.appTitle, isNotEmpty);
    });

    test('Arabic login is non-empty', () {
      final ar = AppLocalizationsAr();
      expect(ar.login, isNotEmpty);
    });

    test('Arabic welcome is non-empty', () {
      final ar = AppLocalizationsAr();
      expect(ar.welcome, isNotEmpty);
    });
  });

  // ─── All locale classes have key translations ─────────────────────

  group('All 7 languages have translations', () {
    final allLocalizations = <String, AppLocalizations>{
      'ar': AppLocalizationsAr(),
      'en': AppLocalizationsEn(),
      'ur': AppLocalizationsUr(),
      'hi': AppLocalizationsHi(),
      'fil': AppLocalizationsFil(),
      'bn': AppLocalizationsBn(),
      'id': AppLocalizationsId(),
    };

    test('all 7 language classes exist', () {
      expect(allLocalizations.length, 7);
    });

    test('all languages have non-empty appTitle', () {
      for (final entry in allLocalizations.entries) {
        expect(
          entry.value.appTitle,
          isNotEmpty,
          reason: '${entry.key} appTitle is empty',
        );
      }
    });

    test('all languages have non-empty login', () {
      for (final entry in allLocalizations.entries) {
        expect(
          entry.value.login,
          isNotEmpty,
          reason: '${entry.key} login is empty',
        );
      }
    });

    test('all languages have non-empty logout', () {
      for (final entry in allLocalizations.entries) {
        expect(
          entry.value.logout,
          isNotEmpty,
          reason: '${entry.key} logout is empty',
        );
      }
    });

    test('all languages have non-empty welcome', () {
      for (final entry in allLocalizations.entries) {
        expect(
          entry.value.welcome,
          isNotEmpty,
          reason: '${entry.key} welcome is empty',
        );
      }
    });

    test('all languages have non-empty phone label', () {
      for (final entry in allLocalizations.entries) {
        expect(
          entry.value.phone,
          isNotEmpty,
          reason: '${entry.key} phone is empty',
        );
      }
    });
  });

  // ─── LocaleState ──────────────────────────────────────────────────

  group('LocaleState', () {
    test('initial state defaults to Arabic', () {
      final state = LocaleState.initial();
      expect(state.locale.languageCode, 'ar');
      expect(state.isRtl, isTrue);
      expect(state.textDirection, TextDirection.rtl);
    });

    test('fromLocale creates correct state for English', () {
      final state = LocaleState.fromLocale(SupportedLocales.english);
      expect(state.locale.languageCode, 'en');
      expect(state.isRtl, isFalse);
      expect(state.textDirection, TextDirection.ltr);
    });

    test('fromLocale creates correct state for Urdu (RTL)', () {
      final state = LocaleState.fromLocale(SupportedLocales.urdu);
      expect(state.locale.languageCode, 'ur');
      expect(state.isRtl, isTrue);
      expect(state.textDirection, TextDirection.rtl);
    });

    test('fromLocale creates correct state for each supported locale', () {
      for (final locale in SupportedLocales.all) {
        final state = LocaleState.fromLocale(locale);
        expect(state.locale, locale);
        expect(
          state.isRtl,
          SupportedLocales.isRtl(locale),
          reason: '${locale.languageCode} RTL mismatch',
        );
      }
    });
  });
}
