import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

void main() {
  group('SupportedLocales.isRtl', () {
    test('Arabic (ar) is RTL', () {
      expect(SupportedLocales.isRtl(const Locale('ar')), isTrue);
      expect(SupportedLocales.isRtl(const Locale('ar', 'SA')), isTrue);
    });

    test('Urdu (ur) is RTL', () {
      expect(SupportedLocales.isRtl(const Locale('ur')), isTrue);
      expect(SupportedLocales.isRtl(const Locale('ur', 'PK')), isTrue);
    });

    test('English (en) is LTR', () {
      expect(SupportedLocales.isRtl(const Locale('en')), isFalse);
      expect(SupportedLocales.isRtl(const Locale('en', 'US')), isFalse);
    });

    test('Hindi (hi) is LTR', () {
      expect(SupportedLocales.isRtl(const Locale('hi')), isFalse);
    });

    test('Filipino (fil) is LTR', () {
      expect(SupportedLocales.isRtl(const Locale('fil')), isFalse);
    });

    test('Bengali (bn) is LTR', () {
      expect(SupportedLocales.isRtl(const Locale('bn')), isFalse);
    });

    test('Indonesian (id) is LTR', () {
      expect(SupportedLocales.isRtl(const Locale('id')), isFalse);
    });

    test('unknown locale is LTR', () {
      expect(SupportedLocales.isRtl(const Locale('de')), isFalse);
    });
  });

  group('SupportedLocales.getTextDirection', () {
    test('Arabic (ar) returns TextDirection.rtl', () {
      expect(
        SupportedLocales.getTextDirection(const Locale('ar')),
        TextDirection.rtl,
      );
    });

    test('Urdu (ur) returns TextDirection.rtl', () {
      expect(
        SupportedLocales.getTextDirection(const Locale('ur')),
        TextDirection.rtl,
      );
    });

    test('English (en) returns TextDirection.ltr', () {
      expect(
        SupportedLocales.getTextDirection(const Locale('en')),
        TextDirection.ltr,
      );
    });

    test('Hindi (hi) returns TextDirection.ltr', () {
      expect(
        SupportedLocales.getTextDirection(const Locale('hi')),
        TextDirection.ltr,
      );
    });

    test('Filipino (fil) returns TextDirection.ltr', () {
      expect(
        SupportedLocales.getTextDirection(const Locale('fil')),
        TextDirection.ltr,
      );
    });

    test('Bengali (bn) returns TextDirection.ltr', () {
      expect(
        SupportedLocales.getTextDirection(const Locale('bn')),
        TextDirection.ltr,
      );
    });

    test('Indonesian (id) returns TextDirection.ltr', () {
      expect(
        SupportedLocales.getTextDirection(const Locale('id')),
        TextDirection.ltr,
      );
    });

    test('unknown locale returns TextDirection.ltr', () {
      expect(
        SupportedLocales.getTextDirection(const Locale('fr')),
        TextDirection.ltr,
      );
    });
  });
}
