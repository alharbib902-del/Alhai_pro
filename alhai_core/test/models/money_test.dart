import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_core/alhai_core.dart';

void main() {
  group('Money', () {
    // ── Constructors ──────────────────────────────────────────────────────────

    group('constructors', () {
      test('fromCents defaults to SAR', () {
        const m = Money.fromCents(100);
        expect(m.cents, 100);
        expect(m.currencyCode, 'SAR');
      });

      test('fromCents accepts custom currency', () {
        const m = Money.fromCents(100, currencyCode: 'USD');
        expect(m.cents, 100);
        expect(m.currencyCode, 'USD');
      });

      test('sar is SAR convenience', () {
        const m = Money.sar(2500);
        expect(m.cents, 2500);
        expect(m.currencyCode, 'SAR');
      });

      test('zero is zero with given currency', () {
        const sar = Money.zero();
        expect(sar.cents, 0);
        expect(sar.currencyCode, 'SAR');

        const usd = Money.zero(currencyCode: 'USD');
        expect(usd.cents, 0);
        expect(usd.currencyCode, 'USD');
      });

      test('fromDouble converts SAR to cents', () {
        expect(Money.fromDouble(25.00).cents, 2500);
        expect(Money.fromDouble(25.99).cents, 2599);
        expect(Money.fromDouble(0).cents, 0);
        expect(Money.fromDouble(0.01).cents, 1);
      });

      test('fromDouble handles IEEE 754 representation artifacts (lossless)', () {
        // The stored double for 37.8 is 37.79999999...; naive (37.8*100).floor()
        // would give 3779 (WRONG). Money.fromDouble must return 3780.
        expect(Money.fromDouble(37.8).cents, 3780);
        expect(Money.fromDouble(71.99).cents, 7199);
        expect(Money.fromDouble(32.2).cents, 3220);
        expect(Money.fromDouble(9.3).cents, 930);
        expect(Money.fromDouble(16.4).cents, 1640);
      });

      test('fromDouble ROUND_HALF_UP — positive halves round up', () {
        // These double literals happen to land on / above the half in IEEE 754,
        // so they exercise the HALF_UP branch deterministically.
        expect(Money.fromDouble(0.005).cents, 1); // 0.5c → 1
        expect(Money.fromDouble(0.025).cents, 3); // 2.5c → 3 (NOT banker's 2)
      });

      test('fromDouble ROUND_HALF_UP — negative halves round down (away from 0)', () {
        expect(Money.fromDouble(-0.005).cents, -1);
        expect(Money.fromDouble(-0.025).cents, -3);
      });

      test('fromDouble is subject to FP literal representation', () {
        // Not every "half" double literal is actually a half in IEEE 754.
        // E.g. the literal `1.005` is stored as 1.00499999… → rounds to 100,
        // not 101. Callers needing deterministic half-up behaviour should go
        // through scalar arithmetic on Money (e.g. `Money.sar(1) / 2`), not
        // through fromDouble on half literals.
        //
        // This test pins the current behaviour so any change is intentional.
        expect(Money.fromDouble(1.005).cents, 100);
        expect(Money.fromDouble(-1.005).cents, -100);
      });

      test('fromDouble non-half rounding is standard', () {
        expect(Money.fromDouble(0.004).cents, 0); // 0.4c → 0
        expect(Money.fromDouble(0.006).cents, 1); // 0.6c → 1
        expect(Money.fromDouble(-0.004).cents, 0);
        expect(Money.fromDouble(-0.006).cents, -1);
      });

      test('fromDouble accepts custom currency', () {
        final m = Money.fromDouble(25.00, currencyCode: 'USD');
        expect(m.cents, 2500);
        expect(m.currencyCode, 'USD');
      });
    });

    // ── toDouble ──────────────────────────────────────────────────────────────

    group('toDouble', () {
      test('converts cents to major units', () {
        expect(const Money.sar(2500).toDouble(), 25.0);
        expect(const Money.sar(1).toDouble(), 0.01);
        expect(const Money.sar(0).toDouble(), 0.0);
        expect(const Money.sar(-500).toDouble(), -5.0);
      });

      test('round-trip via fromDouble preserves value for clean decimals', () {
        expect(Money.fromDouble(37.8).toDouble(), 37.8);
        expect(Money.fromDouble(0.01).toDouble(), 0.01);
        expect(Money.fromDouble(99.99).toDouble(), 99.99);
      });
    });

    // ── operator + ────────────────────────────────────────────────────────────

    group('operator +', () {
      test('adds two SAR amounts', () {
        final sum = const Money.sar(1000) + const Money.sar(500);
        expect(sum.cents, 1500);
        expect(sum.currencyCode, 'SAR');
      });

      test('throws on mixed-currency addition', () {
        expect(
          () =>
              const Money.sar(100) +
              const Money.fromCents(100, currencyCode: 'USD'),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    // ── operator - ────────────────────────────────────────────────────────────

    group('operator -', () {
      test('subtracts two SAR amounts', () {
        final diff = const Money.sar(1000) - const Money.sar(300);
        expect(diff.cents, 700);
      });

      test('allows negative results', () {
        final diff = const Money.sar(100) - const Money.sar(500);
        expect(diff.cents, -400);
      });

      test('throws on mixed-currency subtraction', () {
        expect(
          () =>
              const Money.sar(100) -
              const Money.fromCents(100, currencyCode: 'USD'),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    // ── unary - ───────────────────────────────────────────────────────────────

    group('unary -', () {
      test('negates positive', () {
        expect((-const Money.sar(500)).cents, -500);
      });

      test('negates negative', () {
        expect((-const Money.sar(-500)).cents, 500);
      });

      test('negates zero to zero', () {
        expect((-const Money.sar(0)).cents, 0);
      });

      test('preserves currency', () {
        const usd = Money.fromCents(100, currencyCode: 'USD');
        expect((-usd).currencyCode, 'USD');
      });
    });

    // ── operator * ────────────────────────────────────────────────────────────

    group('operator *', () {
      test('multiplies by integer scalar', () {
        expect((const Money.sar(1000) * 3).cents, 3000);
      });

      test('multiplies by fractional scalar', () {
        expect((const Money.sar(1000) * 1.5).cents, 1500);
        expect((const Money.sar(100) * 0.15).cents, 15);
      });

      test('rounds ROUND_HALF_UP on multiplication', () {
        // 33 cents * 3 = 99
        expect((const Money.sar(33) * 3).cents, 99);
        // 10 cents * 1.555 = 15.55 cents → 16 (HALF_UP)
        expect((const Money.sar(10) * 1.555).cents, 16);
      });

      test('multiplies by zero yields zero', () {
        expect((const Money.sar(1000) * 0).cents, 0);
      });

      test('preserves currency', () {
        const usd = Money.fromCents(100, currencyCode: 'USD');
        expect((usd * 5).currencyCode, 'USD');
      });
    });

    // ── operator / ────────────────────────────────────────────────────────────

    group('operator /', () {
      test('divides by integer scalar', () {
        expect((const Money.sar(1000) / 2).cents, 500);
      });

      test('rounds ROUND_HALF_UP on division', () {
        // 100 / 3 = 33.33... → 33 (not half)
        expect((const Money.sar(100) / 3).cents, 33);
        // 1 / 2 = 0.5 → 1 (HALF_UP)
        expect((const Money.sar(1) / 2).cents, 1);
        // 5 / 2 = 2.5 → 3 (HALF_UP, not banker's 2)
        expect((const Money.sar(5) / 2).cents, 3);
      });

      test('throws on divide by zero', () {
        expect(
          () => const Money.sar(100) / 0,
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    // ── Comparison ────────────────────────────────────────────────────────────

    group('comparison', () {
      test('compareTo on same currency', () {
        expect(
          const Money.sar(100).compareTo(const Money.sar(200)),
          lessThan(0),
        );
        expect(
          const Money.sar(200).compareTo(const Money.sar(100)),
          greaterThan(0),
        );
        expect(const Money.sar(100).compareTo(const Money.sar(100)), 0);
      });

      test('<, <=, >, >= work correctly', () {
        expect(const Money.sar(100) < const Money.sar(200), isTrue);
        expect(const Money.sar(100) <= const Money.sar(100), isTrue);
        expect(const Money.sar(200) > const Money.sar(100), isTrue);
        expect(const Money.sar(200) >= const Money.sar(200), isTrue);

        expect(const Money.sar(100) < const Money.sar(100), isFalse);
        expect(const Money.sar(100) > const Money.sar(100), isFalse);
      });

      test('throws on mixed-currency comparison', () {
        expect(
          () =>
              const Money.sar(100) <
              const Money.fromCents(100, currencyCode: 'USD'),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('sorts correctly with compareTo', () {
        final list = [
          const Money.sar(500),
          const Money.sar(100),
          const Money.sar(300),
        ];
        list.sort();
        expect(list.map((m) => m.cents).toList(), [100, 300, 500]);
      });
    });

    // ── Predicates ────────────────────────────────────────────────────────────

    group('predicates', () {
      test('isZero', () {
        expect(const Money.zero().isZero, isTrue);
        expect(const Money.sar(0).isZero, isTrue);
        expect(const Money.sar(1).isZero, isFalse);
        expect(const Money.sar(-1).isZero, isFalse);
      });

      test('isPositive', () {
        expect(const Money.sar(100).isPositive, isTrue);
        expect(const Money.sar(0).isPositive, isFalse);
        expect(const Money.sar(-1).isPositive, isFalse);
      });

      test('isNegative', () {
        expect(const Money.sar(-1).isNegative, isTrue);
        expect(const Money.sar(0).isNegative, isFalse);
        expect(const Money.sar(1).isNegative, isFalse);
      });

      test('abs', () {
        expect(const Money.sar(-500).abs().cents, 500);
        expect(const Money.sar(500).abs().cents, 500);
        expect(const Money.sar(0).abs().cents, 0);
      });

      test('abs preserves currency', () {
        const usd = Money.fromCents(-100, currencyCode: 'USD');
        final a = usd.abs();
        expect(a.cents, 100);
        expect(a.currencyCode, 'USD');
      });
    });

    // ── JSON ──────────────────────────────────────────────────────────────────

    group('JSON', () {
      test('toJson produces {cents, currency} shape', () {
        expect(const Money.sar(9999).toJson(), {
          'cents': 9999,
          'currency': 'SAR',
        });
      });

      test('toJson for non-SAR', () {
        const usd = Money.fromCents(100, currencyCode: 'USD');
        expect(usd.toJson(), {'cents': 100, 'currency': 'USD'});
      });

      test('fromJson round-trips', () {
        const original = Money.sar(9999);
        final json = original.toJson();
        final back = Money.fromJson(json);
        expect(back, original);
      });

      test('fromJson accepts arbitrary currency code', () {
        final m = Money.fromJson({'cents': 100, 'currency': 'AED'});
        expect(m.cents, 100);
        expect(m.currencyCode, 'AED');
      });

      test('fromJson throws on non-int cents', () {
        expect(
          () => Money.fromJson({'cents': '100', 'currency': 'SAR'}),
          throwsA(isA<FormatException>()),
        );
      });

      test('fromJson throws on non-string currency', () {
        expect(
          () => Money.fromJson({'cents': 100, 'currency': 42}),
          throwsA(isA<FormatException>()),
        );
      });

      test('fromJson throws on missing cents', () {
        expect(
          () => Money.fromJson({'currency': 'SAR'}),
          throwsA(isA<FormatException>()),
        );
      });

      test('fromJson throws on missing currency', () {
        expect(
          () => Money.fromJson({'cents': 100}),
          throwsA(isA<FormatException>()),
        );
      });
    });

    // ── Equality / Hash / String ──────────────────────────────────────────────

    group('equality and hash', () {
      test('same cents + same currency are equal', () {
        expect(const Money.sar(100) == const Money.sar(100), isTrue);
        expect(
          const Money.sar(100).hashCode,
          const Money.sar(100).hashCode,
        );
      });

      test('same cents + different currency are NOT equal', () {
        expect(
          const Money.sar(100) ==
              const Money.fromCents(100, currencyCode: 'USD'),
          isFalse,
        );
      });

      test('different cents + same currency are NOT equal', () {
        expect(const Money.sar(100) == const Money.sar(200), isFalse);
      });

      test('hashCode differs for different currencies', () {
        expect(
          const Money.sar(100).hashCode !=
              const Money.fromCents(100, currencyCode: 'USD').hashCode,
          isTrue,
        );
      });

      test('toString shows cents and currency', () {
        expect(const Money.sar(2500).toString(), 'Money(2500 SAR)');
        expect(
          const Money.fromCents(100, currencyCode: 'USD').toString(),
          'Money(100 USD)',
        );
      });
    });

    // ── Integration / scenarios ───────────────────────────────────────────────

    group('scenarios', () {
      test('invoice line: unit * qty - discount', () {
        const unit = Money.sar(1000); // 10 SAR
        final lineNet = unit * 3 - const Money.sar(500); // 3 * 10 - 5 = 25 SAR
        expect(lineNet.cents, 2500);
      });

      test('cart total: sum of lines', () {
        final lines = [
          const Money.sar(1000),
          const Money.sar(500),
          const Money.sar(250),
        ];
        final total = lines.fold<Money>(
          const Money.zero(),
          (acc, line) => acc + line,
        );
        expect(total.cents, 1750);
      });

      test('pre-VAT to post-VAT: subtotal * 1.15', () {
        // 100 SAR + 15% VAT
        const subtotal = Money.sar(10000);
        final total = subtotal * 1.15;
        expect(total.cents, 11500);
      });

      test('split payment: total / 2 ROUND_HALF_UP', () {
        const total = Money.sar(1001);
        final half = total / 2;
        // 1001 / 2 = 500.5 → 501 (HALF_UP)
        expect(half.cents, 501);
      });
    });
  });
}
