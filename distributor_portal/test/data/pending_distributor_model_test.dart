import 'package:flutter_test/flutter_test.dart';

import 'package:distributor_portal/data/models/pending_distributor.dart';
import 'package:distributor_portal/data/models/distributor_account_status.dart';

void main() {
  final sampleJson = <String, dynamic>{
    'id': 'org-001',
    'name': 'شركة الابتكار',
    'name_en': 'Innovation Co',
    'phone': '+966501234567',
    'email': 'info@innovation.sa',
    'city': 'الرياض',
    'address': 'حي العليا، شارع التحلية',
    'commercial_reg': '1010123456',
    'tax_number': '310123456789003',
    'status': 'pending_review',
    'owner_id': 'user-001',
    'company_type': 'distributor',
    'terms_accepted_at': '2026-04-15T10:30:00.000Z',
    'created_at': '2026-04-15T10:00:00.000Z',
  };

  // ─── fromJson ──────────────────────────────────────────────────

  group('PendingDistributor.fromJson', () {
    test('parses all fields correctly', () {
      final d = PendingDistributor.fromJson(sampleJson);

      expect(d.id, 'org-001');
      expect(d.name, 'شركة الابتكار');
      expect(d.nameEn, 'Innovation Co');
      expect(d.phone, '+966501234567');
      expect(d.email, 'info@innovation.sa');
      expect(d.city, 'الرياض');
      expect(d.address, 'حي العليا، شارع التحلية');
      expect(d.commercialReg, '1010123456');
      expect(d.taxNumber, '310123456789003');
      expect(d.status, DistributorAccountStatus.pendingReview);
      expect(d.ownerId, 'user-001');
      expect(d.companyType, 'distributor');
      expect(d.termsAcceptedAt, isNotNull);
      expect(d.createdAt.year, 2026);
    });

    test('handles null optional fields', () {
      final minJson = <String, dynamic>{
        'id': 'org-002',
        'name': 'شركة بسيطة',
        'created_at': '2026-04-16T08:00:00.000Z',
      };

      final d = PendingDistributor.fromJson(minJson);

      expect(d.id, 'org-002');
      expect(d.name, 'شركة بسيطة');
      expect(d.nameEn, isNull);
      expect(d.phone, isNull);
      expect(d.email, isNull);
      expect(d.city, isNull);
      expect(d.commercialReg, isNull);
      expect(d.taxNumber, isNull);
      expect(d.ownerId, isNull);
      expect(d.termsAcceptedAt, isNull);
    });

    test('handles missing name — defaults to empty string', () {
      final noNameJson = <String, dynamic>{
        'id': 'org-003',
        'created_at': '2026-04-16T08:00:00.000Z',
      };

      final d = PendingDistributor.fromJson(noNameJson);
      expect(d.name, '');
    });

    test('handles unknown status — defaults to pendingReview', () {
      final unknownJson = Map<String, dynamic>.from(sampleJson)
        ..['status'] = 'unknown_status';

      final d = PendingDistributor.fromJson(unknownJson);
      // fromDbValue falls back to pendingEmailVerification for truly unknown
      expect(d.status, isNotNull);
    });

    test('handles missing status — defaults to pending_review', () {
      final noStatusJson = Map<String, dynamic>.from(sampleJson)
        ..remove('status');

      final d = PendingDistributor.fromJson(noStatusJson);
      expect(d.status, DistributorAccountStatus.pendingReview);
    });
  });

  // ─── displayName ──────────────────────────────────────────────

  group('displayName', () {
    test('shows Arabic + English when both present', () {
      final d = PendingDistributor.fromJson(sampleJson);
      expect(d.displayName, 'شركة الابتكار (Innovation Co)');
    });

    test('shows Arabic only when no English name', () {
      final noEnJson = Map<String, dynamic>.from(sampleJson)..remove('name_en');
      final d = PendingDistributor.fromJson(noEnJson);
      expect(d.displayName, 'شركة الابتكار');
    });

    test('shows Arabic only when English is empty', () {
      final emptyEnJson = Map<String, dynamic>.from(sampleJson)
        ..['name_en'] = '';
      final d = PendingDistributor.fromJson(emptyEnJson);
      expect(d.displayName, 'شركة الابتكار');
    });

    test('shows Arabic only when English equals Arabic', () {
      final sameJson = Map<String, dynamic>.from(sampleJson)
        ..['name_en'] = 'شركة الابتكار';
      final d = PendingDistributor.fromJson(sameJson);
      expect(d.displayName, 'شركة الابتكار');
    });
  });

  // ─── timeAgo ──────────────────────────────────────────────────

  group('timeAgo', () {
    test('returns Arabic time description', () {
      final d = PendingDistributor.fromJson(sampleJson);
      // createdAt is in the past, so timeAgo should contain "منذ"
      expect(d.timeAgo, contains('منذ'));
    });

    test('returns الآن for very recent', () {
      final nowJson = Map<String, dynamic>.from(sampleJson)
        ..['created_at'] = DateTime.now().toIso8601String();
      final d = PendingDistributor.fromJson(nowJson);
      expect(d.timeAgo, 'الآن');
    });
  });

  // ─── Equality ─────────────────────────────────────────────────

  group('equality', () {
    test('same id and status are equal', () {
      final d1 = PendingDistributor.fromJson(sampleJson);
      final d2 = PendingDistributor.fromJson(sampleJson);
      expect(d1, equals(d2));
      expect(d1.hashCode, equals(d2.hashCode));
    });

    test('different status makes unequal', () {
      final d1 = PendingDistributor.fromJson(sampleJson);
      final activeJson = Map<String, dynamic>.from(sampleJson)
        ..['status'] = 'active';
      final d2 = PendingDistributor.fromJson(activeJson);
      expect(d1, isNot(equals(d2)));
    });

    test('different id makes unequal', () {
      final d1 = PendingDistributor.fromJson(sampleJson);
      final otherJson = Map<String, dynamic>.from(sampleJson)
        ..['id'] = 'org-999';
      final d2 = PendingDistributor.fromJson(otherJson);
      expect(d1, isNot(equals(d2)));
    });
  });
}
