import 'package:alhai_core/alhai_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CertificatePinningService', () {
    test('constantTimeEquals returns true for identical strings', () {
      expect(
        CertificatePinningService.constantTimeEquals('abc123', 'abc123'),
        isTrue,
      );
    });

    test('constantTimeEquals returns false for different strings', () {
      expect(
        CertificatePinningService.constantTimeEquals('abc123', 'abc124'),
        isFalse,
      );
    });

    test('constantTimeEquals returns false for different lengths', () {
      expect(
        CertificatePinningService.constantTimeEquals('abc', 'abcd'),
        isFalse,
      );
    });

    test('constantTimeEquals handles empty strings', () {
      expect(CertificatePinningService.constantTimeEquals('', ''), isTrue);
    });

    test('diagnosticStatus reports debug mode', () {
      final status = CertificatePinningService.diagnosticStatus;
      expect(status, contains('debug mode'));
    });

    test('isEnabled is false in debug mode', () {
      expect(CertificatePinningService.isEnabled, isFalse);
    });

    test('createPinnedClient returns a client in debug mode', () {
      final client = CertificatePinningService.createPinnedClient();
      expect(client, isNotNull);
      client.close();
    });

    group('resolvePins', () {
      test('uses numbered pins when present, ignores legacy vars', () {
        final pins = CertificatePinningService.resolvePins(
          numbered: const ['pinA', 'pinB', '', '', '', '', '', '', '', ''],
          legacyPrimary: 'legacyPrimary',
          legacyBackup: 'legacyBackup',
        );
        expect(pins, <String>['pinA', 'pinB']);
        expect(pins, isNot(contains('legacyPrimary')));
        expect(pins, isNot(contains('legacyBackup')));
      });

      test('falls back to legacy vars when numbered pins are all empty', () {
        final pins = CertificatePinningService.resolvePins(
          numbered: const ['', '', '', '', '', '', '', '', '', ''],
          legacyPrimary: 'legacyPrimary',
          legacyBackup: 'legacyBackup',
        );
        expect(pins, <String>['legacyPrimary', 'legacyBackup']);
      });

      test('deduplicates identical pins', () {
        final pins = CertificatePinningService.resolvePins(
          numbered: const [
            'samePin',
            'samePin',
            'otherPin',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
          ],
        );
        expect(pins, <String>['samePin', 'otherPin']);
        expect(pins.length, 2);
      });

      test('trims whitespace and drops empty slots', () {
        final pins = CertificatePinningService.resolvePins(
          numbered: const [
            '  pinA  ',
            '',
            '\tpinB\n',
            '   ',
            '',
            '',
            '',
            '',
            '',
            '',
          ],
        );
        expect(pins, <String>['pinA', 'pinB']);
      });

      test('returns empty list when all sources empty (fail-closed input)', () {
        final pins = CertificatePinningService.resolvePins(
          numbered: const ['', '', '', '', '', '', '', '', '', ''],
        );
        expect(pins, isEmpty);
      });

      test('caps at 10 numbered slots even if caller passes more', () {
        final pins = CertificatePinningService.resolvePins(
          numbered: const [
            'p1',
            'p2',
            'p3',
            'p4',
            'p5',
            'p6',
            'p7',
            'p8',
            'p9',
            'p10',
            'p11',
            'p12',
          ],
        );
        expect(pins.length, 10);
        expect(pins.last, 'p10');
        expect(pins, isNot(contains('p11')));
      });
    });

    test('pinCount getter is non-negative integer', () {
      expect(CertificatePinningService.pinCount, isA<int>());
      expect(CertificatePinningService.pinCount, greaterThanOrEqualTo(0));
    });
  });
}
