// L105: Automated ARB key-matching tests → see arb_keys_test.dart
// L106: RTL layout tests → see rtl_layout_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

void main() {
  group('SupportedLocales', () {
    group('all list', () {
      test('contains exactly 7 locales', () {
        expect(SupportedLocales.all.length, 7);
      });

      test('contains Arabic locale', () {
        expect(SupportedLocales.all.any((l) => l.languageCode == 'ar'), isTrue);
      });

      test('contains English locale', () {
        expect(SupportedLocales.all.any((l) => l.languageCode == 'en'), isTrue);
      });

      test('contains Urdu locale', () {
        expect(SupportedLocales.all.any((l) => l.languageCode == 'ur'), isTrue);
      });

      test('contains Hindi locale', () {
        expect(SupportedLocales.all.any((l) => l.languageCode == 'hi'), isTrue);
      });

      test('contains Filipino locale', () {
        expect(
          SupportedLocales.all.any((l) => l.languageCode == 'fil'),
          isTrue,
        );
      });

      test('contains Bengali locale', () {
        expect(SupportedLocales.all.any((l) => l.languageCode == 'bn'), isTrue);
      });

      test('contains Indonesian locale', () {
        expect(SupportedLocales.all.any((l) => l.languageCode == 'id'), isTrue);
      });

      test('first locale is Arabic (default)', () {
        expect(SupportedLocales.all.first, SupportedLocales.arabic);
        expect(SupportedLocales.all.first.languageCode, 'ar');
      });
    });

    group('named locale constants', () {
      test('arabic has language code ar and country SA', () {
        expect(SupportedLocales.arabic.languageCode, 'ar');
        expect(SupportedLocales.arabic.countryCode, 'SA');
      });

      test('english has language code en and country US', () {
        expect(SupportedLocales.english.languageCode, 'en');
        expect(SupportedLocales.english.countryCode, 'US');
      });

      test('urdu has language code ur and country PK', () {
        expect(SupportedLocales.urdu.languageCode, 'ur');
        expect(SupportedLocales.urdu.countryCode, 'PK');
      });

      test('hindi has language code hi and country IN', () {
        expect(SupportedLocales.hindi.languageCode, 'hi');
        expect(SupportedLocales.hindi.countryCode, 'IN');
      });

      test('filipino has language code fil and country PH', () {
        expect(SupportedLocales.filipino.languageCode, 'fil');
        expect(SupportedLocales.filipino.countryCode, 'PH');
      });

      test('bengali has language code bn and country BD', () {
        expect(SupportedLocales.bengali.languageCode, 'bn');
        expect(SupportedLocales.bengali.countryCode, 'BD');
      });

      test('indonesian has language code id and country ID', () {
        expect(SupportedLocales.indonesian.languageCode, 'id');
        expect(SupportedLocales.indonesian.countryCode, 'ID');
      });
    });

    group('RTL languages list', () {
      test('contains exactly 2 RTL languages', () {
        expect(SupportedLocales.rtlLanguages.length, 2);
      });

      test('contains Arabic', () {
        expect(SupportedLocales.rtlLanguages, contains('ar'));
      });

      test('contains Urdu', () {
        expect(SupportedLocales.rtlLanguages, contains('ur'));
      });

      test('does not contain English', () {
        expect(SupportedLocales.rtlLanguages, isNot(contains('en')));
      });
    });

    group('getNativeName', () {
      test('returns correct native name for Arabic', () {
        expect(
          SupportedLocales.getNativeName(const Locale('ar')),
          equals('العربية'),
        );
      });

      test('returns correct native name for English', () {
        expect(
          SupportedLocales.getNativeName(const Locale('en')),
          equals('English'),
        );
      });

      test('returns correct native name for Urdu', () {
        expect(
          SupportedLocales.getNativeName(const Locale('ur')),
          equals('اردو'),
        );
      });

      test('returns correct native name for Hindi', () {
        expect(
          SupportedLocales.getNativeName(const Locale('hi')),
          equals('हिन्दी'),
        );
      });

      test('returns correct native name for Filipino', () {
        expect(
          SupportedLocales.getNativeName(const Locale('fil')),
          equals('Filipino'),
        );
      });

      test('returns correct native name for Bengali', () {
        expect(
          SupportedLocales.getNativeName(const Locale('bn')),
          equals('বাংলা'),
        );
      });

      test('returns correct native name for Indonesian', () {
        expect(
          SupportedLocales.getNativeName(const Locale('id')),
          equals('Bahasa Indonesia'),
        );
      });

      test('returns language code for unknown locale', () {
        expect(
          SupportedLocales.getNativeName(const Locale('de')),
          equals('de'),
        );
      });
    });

    group('getFlag', () {
      test('returns Saudi flag for Arabic', () {
        expect(SupportedLocales.getFlag(const Locale('ar')), isNotEmpty);
      });

      test('returns globe for unknown locale', () {
        expect(SupportedLocales.getFlag(const Locale('de')), isNotEmpty);
      });

      test('returns different flags for different locales', () {
        final arFlag = SupportedLocales.getFlag(const Locale('ar'));
        final enFlag = SupportedLocales.getFlag(const Locale('en'));
        expect(arFlag, isNot(equals(enFlag)));
      });
    });
  });
}
