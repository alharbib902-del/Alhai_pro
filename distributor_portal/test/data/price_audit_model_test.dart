import 'package:flutter_test/flutter_test.dart';
import 'package:distributor_portal/data/models/price_audit_entry.dart';

void main() {
  group('PriceAuditEntry', () {
    test('fromJson creates valid entry with all fields', () {
      final entry = PriceAuditEntry.fromJson({
        'id': 'audit-1',
        'product_id': 'prod-1',
        'product_name': 'منتج تجريبي',
        'old_price': 10.0,
        'new_price': 15.0,
        'changed_by': 'user-1',
        'changed_at': '2026-04-16T12:00:00Z',
        'reason': 'زيادة التكلفة',
      });

      expect(entry.id, 'audit-1');
      expect(entry.productId, 'prod-1');
      expect(entry.productName, 'منتج تجريبي');
      expect(entry.oldPrice, 10.0);
      expect(entry.newPrice, 15.0);
      expect(entry.changedBy, 'user-1');
      expect(entry.reason, 'زيادة التكلفة');
    });

    test('fromJson handles missing old_price (first-time pricing)', () {
      final entry = PriceAuditEntry.fromJson({
        'id': 'audit-2',
        'product_id': 'prod-2',
        'product_name': 'منتج جديد',
        'old_price': null,
        'new_price': 20.0,
        'changed_by': 'user-1',
        'changed_at': '2026-04-16T12:00:00Z',
      });

      expect(entry.oldPrice, isNull);
      expect(entry.newPrice, 20.0);
      expect(entry.reason, isNull);
    });

    test('fromJson handles missing fields with defaults', () {
      final entry = PriceAuditEntry.fromJson({});

      expect(entry.id, '');
      expect(entry.productId, '');
      expect(entry.productName, '');
      expect(entry.newPrice, 0);
      expect(entry.changedBy, '');
    });

    test('priceDifference calculates correctly', () {
      final increase = PriceAuditEntry(
        id: '1',
        productId: 'p1',
        productName: 'Test',
        oldPrice: 10.0,
        newPrice: 15.0,
        changedBy: 'u1',
        changedAt: DateTime(2026),
      );
      expect(increase.priceDifference, 5.0);

      final decrease = PriceAuditEntry(
        id: '2',
        productId: 'p2',
        productName: 'Test',
        oldPrice: 20.0,
        newPrice: 15.0,
        changedBy: 'u1',
        changedAt: DateTime(2026),
      );
      expect(decrease.priceDifference, -5.0);
    });

    test('priceDifference is null when no old price', () {
      final entry = PriceAuditEntry(
        id: '1',
        productId: 'p1',
        productName: 'Test',
        newPrice: 15.0,
        changedBy: 'u1',
        changedAt: DateTime(2026),
      );
      expect(entry.priceDifference, isNull);
    });

    test('percentChange calculates correctly', () {
      final entry = PriceAuditEntry(
        id: '1',
        productId: 'p1',
        productName: 'Test',
        oldPrice: 100.0,
        newPrice: 115.0,
        changedBy: 'u1',
        changedAt: DateTime(2026),
      );
      expect(entry.percentChange, 15.0);
    });

    test('percentChange is null when no old price', () {
      final entry = PriceAuditEntry(
        id: '1',
        productId: 'p1',
        productName: 'Test',
        newPrice: 100.0,
        changedBy: 'u1',
        changedAt: DateTime(2026),
      );
      expect(entry.percentChange, isNull);
    });

    test('toJson produces correct map', () {
      final entry = PriceAuditEntry(
        id: '1',
        productId: 'p1',
        productName: 'Test',
        oldPrice: 10.0,
        newPrice: 15.0,
        changedBy: 'u1',
        changedAt: DateTime.utc(2026, 4, 16),
        reason: 'test',
      );

      final json = entry.toJson();
      expect(json['product_id'], 'p1');
      expect(json['product_name'], 'Test');
      expect(json['old_price'], 10.0);
      expect(json['new_price'], 15.0);
      expect(json['changed_by'], 'u1');
      expect(json['reason'], 'test');
    });

    test('equality is based on id', () {
      final a = PriceAuditEntry(
        id: 'same-id',
        productId: 'p1',
        productName: 'A',
        newPrice: 10.0,
        changedBy: 'u1',
        changedAt: DateTime(2026),
      );
      final b = PriceAuditEntry(
        id: 'same-id',
        productId: 'p2',
        productName: 'B',
        newPrice: 20.0,
        changedBy: 'u2',
        changedAt: DateTime(2026),
      );
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });
  });
}
