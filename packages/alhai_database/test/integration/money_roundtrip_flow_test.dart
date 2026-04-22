/// Integration test for the C-4 Money pipeline (§B4).
///
/// Covers the high-value round-trip that the C-4 plan calls out as the
/// one indispensable artifact of Session 1 — "user types SAR double →
/// store int cents → read back int cents → wrap Money → display/compute
/// → byte-exact SAR value at the far end." Any drift between these
/// stages is the whole class of IEEE 754 bug the migration was designed
/// to eliminate.
///
/// Tests exercise `Money` from `alhai_core` through `ProductsDao` in
/// `alhai_database`. The far end (display formatting) is covered in
/// `packages/alhai_shared_ui` widget tests and is not re-tested here to
/// keep this suite focused on the DB boundary.
library;

import 'package:alhai_core/alhai_core.dart' show Money;
import 'package:alhai_database/alhai_database.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/database_test_helpers.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = createTestDatabase();
    await seedTestData(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('C-4 Money round-trip through ProductsDao', () {
    test('exact value — 37.80 SAR survives double→cents→Money→double', () async {
      // Arrange: user-typed SAR (the kind of value IEEE 754 can't
      // represent exactly). Without Money, floating-point arithmetic
      // makes this drift to 37.799999... after one sum.
      const userTypedSar = 37.80;
      final stored = Money.fromDouble(userTypedSar);
      expect(stored.cents, 3780, reason: 'ROUND_HALF_UP of 3780.0 is 3780');

      await db.productsDao.insertProduct(
        ProductsTableCompanion.insert(
          id: 'p-1',
          storeId: 'store-1',
          name: 'Cola',
          price: stored.cents,
          createdAt: DateTime(2026, 1, 1),
        ),
      );

      // Act: read back.
      final row = await db.productsDao.getProductById('p-1');

      // Assert: byte-exact.
      expect(row, isNotNull);
      expect(row!.price, 3780);
      final restored = Money.fromCents(row.price);
      expect(restored, stored);
      expect(restored.toDouble(), userTypedSar);
      expect(restored.toDouble().toStringAsFixed(2), '37.80');
    });

    test('arithmetic precision — 37.80 × 3 = 113.40 exactly', () async {
      // Pure IEEE 754 path: 37.8 * 3 = 113.39999999999999. Money path:
      // Money(3780) * 3 = Money(11340) = 113.40 exactly.
      final money = Money.fromDouble(37.80);
      final triple = money * 3;
      expect(triple.cents, 11340);
      expect(triple.toDouble(), 113.40);

      // Sanity: the raw double path would fail byte-exact.
      expect(37.8 * 3, isNot(113.40));
      // (actual value: 113.39999999999999)
    });

    test('ROUND_HALF_UP semantics — 99.995 rounds up to 100.00', () async {
      // Edge case that round-half-to-even (Dart's default) would send
      // to 99.99 for this input. Money uses HALF_UP per ZATCA
      // convention.
      final money = Money.fromDouble(99.995);
      expect(money.cents, 10000);
      expect(money.toDouble(), 100.00);
    });

    test(
      'multi-product total — summing three Money values stays exact',
      () async {
        // Arrange three products with pathological doubles.
        final products = [
          (id: 'p-a', sar: 37.80),
          (id: 'p-b', sar: 12.15),
          (id: 'p-c', sar: 50.05),
        ];
        for (final p in products) {
          await db.productsDao.insertProduct(
            ProductsTableCompanion.insert(
              id: p.id,
              storeId: 'store-1',
              name: p.id,
              price: Money.fromDouble(p.sar).cents,
              createdAt: DateTime(2026, 1, 1),
            ),
          );
        }

        // Act: sum via Money addition.
        var total = const Money.sar(0);
        for (final p in products) {
          final row = await db.productsDao.getProductById(p.id);
          total = total + Money.fromCents(row!.price);
        }

        // Assert: 37.80 + 12.15 + 50.05 = 100.00 exactly.
        expect(total.cents, 10000);
        expect(total.toDouble(), 100.00);
      },
    );

    test(
      'costPrice nullable round-trip — null stored stays null, set value'
      ' survives',
      () async {
        await db.productsDao.insertProduct(
          ProductsTableCompanion.insert(
            id: 'p-null',
            storeId: 'store-1',
            name: 'NoCost',
            price: Money.fromDouble(50.0).cents,
            // costPrice omitted — defaults to null
            createdAt: DateTime(2026, 1, 1),
          ),
        );
        await db.productsDao.insertProduct(
          ProductsTableCompanion.insert(
            id: 'p-set',
            storeId: 'store-1',
            name: 'WithCost',
            price: Money.fromDouble(50.0).cents,
            costPrice: Value(Money.fromDouble(32.50).cents),
            createdAt: DateTime(2026, 1, 1),
          ),
        );

        final nullRow = await db.productsDao.getProductById('p-null');
        final setRow = await db.productsDao.getProductById('p-set');

        expect(nullRow!.costPrice, isNull);
        expect(setRow!.costPrice, 3250);
        expect(Money.fromCents(setRow.costPrice!).toDouble(), 32.50);
      },
    );

    test('JSON codec round-trip — Money.toJson → fromJson is stable', () {
      // The wire format survives storage in any JSON-shaped column
      // (audit_log.old_value, sync payloads, etc.) without precision
      // loss because it serializes as {cents: int, currency: String}.
      final original = Money.fromDouble(37.80);
      final json = original.toJson();
      expect(json['cents'], 3780);
      expect(json['currency'], 'SAR');

      final restored = Money.fromJson(json);
      expect(restored, original);
    });
  });
}
