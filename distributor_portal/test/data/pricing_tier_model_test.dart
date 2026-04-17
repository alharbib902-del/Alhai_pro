import 'package:flutter_test/flutter_test.dart';

import 'package:distributor_portal/data/models.dart';

void main() {
  group('PricingTier', () {
    test('fromJson parses all fields correctly', () {
      final json = <String, dynamic>{
        'id': 'tier-1',
        'org_id': 'org-1',
        'name': 'Gold',
        'name_ar': 'ذهبي',
        'discount_percent': 15.5,
        'is_default': true,
        'sort_order': 1,
        'created_at': '2026-01-01T00:00:00Z',
        'updated_at': '2026-04-01T00:00:00Z',
      };

      final tier = PricingTier.fromJson(json);

      expect(tier.id, 'tier-1');
      expect(tier.orgId, 'org-1');
      expect(tier.name, 'Gold');
      expect(tier.nameAr, 'ذهبي');
      expect(tier.discountPercent, 15.5);
      expect(tier.isDefault, true);
      expect(tier.sortOrder, 1);
      expect(tier.createdAt, DateTime.utc(2026, 1, 1));
      expect(tier.updatedAt, DateTime.utc(2026, 4, 1));
    });

    test('fromJson handles missing optional fields', () {
      final json = <String, dynamic>{
        'id': 'tier-2',
        'org_id': 'org-1',
        'name': 'Regular',
        'created_at': '2026-01-01T00:00:00Z',
      };

      final tier = PricingTier.fromJson(json);

      expect(tier.nameAr, isNull);
      expect(tier.discountPercent, 0);
      expect(tier.isDefault, false);
      expect(tier.sortOrder, 0);
      expect(tier.updatedAt, isNull);
    });

    test('displayName prefers Arabic name', () {
      final tier = PricingTier(
        id: 't1',
        orgId: 'o1',
        name: 'Gold',
        nameAr: 'ذهبي',
        discountPercent: 10,
        createdAt: DateTime.now(),
      );
      expect(tier.displayName, 'ذهبي');
    });

    test('displayName falls back to English name', () {
      final tier = PricingTier(
        id: 't1',
        orgId: 'o1',
        name: 'Gold',
        discountPercent: 10,
        createdAt: DateTime.now(),
      );
      expect(tier.displayName, 'Gold');
    });

    test('discountDisplay formats integer correctly', () {
      final tier = PricingTier(
        id: 't1',
        orgId: 'o1',
        name: 'Gold',
        discountPercent: 15,
        createdAt: DateTime.now(),
      );
      expect(tier.discountDisplay, '15%');
    });

    test('discountDisplay formats decimal correctly', () {
      final tier = PricingTier(
        id: 't1',
        orgId: 'o1',
        name: 'Gold',
        discountPercent: 7.5,
        createdAt: DateTime.now(),
      );
      expect(tier.discountDisplay, '7.5%');
    });

    test('discountDisplay handles zero', () {
      final tier = PricingTier(
        id: 't1',
        orgId: 'o1',
        name: 'Regular',
        discountPercent: 0,
        createdAt: DateTime.now(),
      );
      expect(tier.discountDisplay, '0%');
    });

    test('toInsertJson includes correct fields', () {
      final tier = PricingTier(
        id: 't1',
        orgId: 'o1',
        name: 'Gold',
        nameAr: 'ذهبي',
        discountPercent: 15,
        isDefault: true,
        sortOrder: 1,
        createdAt: DateTime.now(),
      );

      final json = tier.toInsertJson('org-1');
      expect(json['org_id'], 'org-1');
      expect(json['name'], 'Gold');
      expect(json['name_ar'], 'ذهبي');
      expect(json['discount_percent'], 15);
      expect(json['is_default'], true);
      expect(json['sort_order'], 1);
      expect(json.containsKey('id'), false);
      expect(json.containsKey('created_at'), false);
    });

    test('toUpdateJson includes updated_at', () {
      final tier = PricingTier(
        id: 't1',
        orgId: 'o1',
        name: 'Gold',
        discountPercent: 15,
        createdAt: DateTime.now(),
      );

      final json = tier.toUpdateJson();
      expect(json.containsKey('updated_at'), true);
      expect(json['name'], 'Gold');
    });

    test('copyWith creates new instance with changed fields', () {
      final tier = PricingTier(
        id: 't1',
        orgId: 'o1',
        name: 'Gold',
        discountPercent: 15,
        createdAt: DateTime.now(),
      );

      final updated = tier.copyWith(name: 'Platinum', discountPercent: 20);
      expect(updated.name, 'Platinum');
      expect(updated.discountPercent, 20);
      expect(updated.id, 't1');
      expect(updated.orgId, 'o1');
    });

    test('equality works correctly', () {
      final now = DateTime.now();
      final tier1 = PricingTier(
        id: 't1',
        orgId: 'o1',
        name: 'Gold',
        discountPercent: 15,
        createdAt: now,
      );
      final tier2 = PricingTier(
        id: 't1',
        orgId: 'o1',
        name: 'Gold',
        discountPercent: 15,
        createdAt: now,
      );
      final tier3 = PricingTier(
        id: 't2',
        orgId: 'o1',
        name: 'Silver',
        discountPercent: 10,
        createdAt: now,
      );

      expect(tier1, equals(tier2));
      expect(tier1.hashCode, tier2.hashCode);
      expect(tier1, isNot(equals(tier3)));
    });
  });

  group('StoreTierAssignment', () {
    test('fromJson parses flat fields correctly', () {
      final json = <String, dynamic>{
        'org_id': 'org-1',
        'store_id': 'store-1',
        'tier_id': 'tier-1',
        'assigned_at': '2026-04-01T00:00:00Z',
      };

      final assignment = StoreTierAssignment.fromJson(json);

      expect(assignment.orgId, 'org-1');
      expect(assignment.storeId, 'store-1');
      expect(assignment.tierId, 'tier-1');
      expect(assignment.assignedAt, DateTime.utc(2026, 4, 1));
      expect(assignment.storeName, isNull);
      expect(assignment.tierName, isNull);
      expect(assignment.discountPercent, isNull);
    });

    test('fromJson parses joined store and tier data', () {
      final json = <String, dynamic>{
        'org_id': 'org-1',
        'store_id': 'store-1',
        'tier_id': 'tier-1',
        'assigned_at': '2026-04-01T00:00:00Z',
        'stores': {'name': 'متجر الأمل'},
        'pricing_tiers': {'name': 'Gold', 'discount_percent': 15},
      };

      final assignment = StoreTierAssignment.fromJson(json);

      expect(assignment.storeName, 'متجر الأمل');
      expect(assignment.tierName, 'Gold');
      expect(assignment.discountPercent, 15);
    });

    test('equality checks org_id, store_id, tier_id', () {
      final a1 = StoreTierAssignment(
        orgId: 'o1',
        storeId: 's1',
        tierId: 't1',
        assignedAt: DateTime.now(),
      );
      final a2 = StoreTierAssignment(
        orgId: 'o1',
        storeId: 's1',
        tierId: 't1',
        assignedAt: DateTime.now().add(const Duration(days: 1)),
      );
      final a3 = StoreTierAssignment(
        orgId: 'o1',
        storeId: 's2',
        tierId: 't1',
        assignedAt: DateTime.now(),
      );

      expect(a1, equals(a2));
      expect(a1, isNot(equals(a3)));
    });
  });
}
