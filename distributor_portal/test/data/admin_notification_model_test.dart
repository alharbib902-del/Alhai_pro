import 'package:flutter_test/flutter_test.dart';

import 'package:distributor_portal/data/models/admin_notification.dart';

void main() {
  final sampleJson = <String, dynamic>{
    'id': 'notif-001',
    'type': 'new_distributor',
    'title': 'موزع جديد سجّل',
    'message': 'شركة الابتكار سجّلت للمراجعة',
    'related_id': 'org-001',
    'related_type': 'organization',
    'is_read': false,
    'read_by': null,
    'read_at': null,
    'created_at': '2026-04-15T12:00:00.000Z',
  };

  // ─── AdminNotificationType enum ────────────────────────────────

  group('AdminNotificationType', () {
    test('dbValue returns correct snake_case values', () {
      expect(AdminNotificationType.newDistributor.dbValue, 'new_distributor');
      expect(
        AdminNotificationType.documentUploaded.dbValue,
        'document_uploaded',
      );
      expect(
        AdminNotificationType.distributorApproved.dbValue,
        'distributor_approved',
      );
      expect(
        AdminNotificationType.distributorRejected.dbValue,
        'distributor_rejected',
      );
      expect(
        AdminNotificationType.distributorSuspended.dbValue,
        'distributor_suspended',
      );
      expect(AdminNotificationType.general.dbValue, 'general');
    });

    test('arabicLabel returns Arabic labels', () {
      expect(AdminNotificationType.newDistributor.arabicLabel, 'موزع جديد');
      expect(AdminNotificationType.documentUploaded.arabicLabel, 'مستند مرفوع');
      expect(
        AdminNotificationType.distributorApproved.arabicLabel,
        'تم اعتماد موزع',
      );
      expect(
        AdminNotificationType.distributorRejected.arabicLabel,
        'تم رفض موزع',
      );
      expect(
        AdminNotificationType.distributorSuspended.arabicLabel,
        'تم إيقاف موزع',
      );
      expect(AdminNotificationType.general.arabicLabel, 'عام');
    });

    test('fromDbValue round-trips all values', () {
      for (final type in AdminNotificationType.values) {
        expect(AdminNotificationType.fromDbValue(type.dbValue), type);
      }
    });

    test('fromDbValue defaults to general for unknown value', () {
      expect(
        AdminNotificationType.fromDbValue('unknown'),
        AdminNotificationType.general,
      );
    });

    test('has exactly 6 values', () {
      expect(AdminNotificationType.values.length, 6);
    });
  });

  // ─── AdminNotification.fromJson ─────────────────────────────────

  group('AdminNotification.fromJson', () {
    test('parses all fields correctly', () {
      final n = AdminNotification.fromJson(sampleJson);

      expect(n.id, 'notif-001');
      expect(n.type, AdminNotificationType.newDistributor);
      expect(n.title, 'موزع جديد سجّل');
      expect(n.message, 'شركة الابتكار سجّلت للمراجعة');
      expect(n.relatedId, 'org-001');
      expect(n.relatedType, 'organization');
      expect(n.isRead, isFalse);
      expect(n.readBy, isNull);
      expect(n.readAt, isNull);
      expect(n.createdAt.year, 2026);
    });

    test('handles read notification', () {
      final readJson = Map<String, dynamic>.from(sampleJson)
        ..['is_read'] = true
        ..['read_by'] = 'admin-001'
        ..['read_at'] = '2026-04-15T13:00:00.000Z';

      final n = AdminNotification.fromJson(readJson);

      expect(n.isRead, isTrue);
      expect(n.readBy, 'admin-001');
      expect(n.readAt, isNotNull);
    });

    test('handles null optional fields', () {
      final minJson = <String, dynamic>{
        'id': 'notif-002',
        'created_at': '2026-04-16T08:00:00.000Z',
      };

      final n = AdminNotification.fromJson(minJson);

      expect(n.id, 'notif-002');
      expect(n.type, AdminNotificationType.general);
      expect(n.title, '');
      expect(n.message, isNull);
      expect(n.relatedId, isNull);
      expect(n.relatedType, isNull);
      expect(n.isRead, isFalse);
    });

    test('handles missing type — defaults to general', () {
      final noTypeJson = Map<String, dynamic>.from(sampleJson)..remove('type');

      final n = AdminNotification.fromJson(noTypeJson);
      expect(n.type, AdminNotificationType.general);
    });
  });

  // ─── timeAgo ──────────────────────────────────────────────────

  group('timeAgo', () {
    test('returns Arabic time description', () {
      final n = AdminNotification.fromJson(sampleJson);
      expect(n.timeAgo, contains('منذ'));
    });

    test('returns الآن for recent notification', () {
      final nowJson = Map<String, dynamic>.from(sampleJson)
        ..['created_at'] = DateTime.now().toIso8601String();
      final n = AdminNotification.fromJson(nowJson);
      expect(n.timeAgo, 'الآن');
    });
  });

  // ─── Equality ─────────────────────────────────────────────────

  group('equality', () {
    test('same id and read status are equal', () {
      final n1 = AdminNotification.fromJson(sampleJson);
      final n2 = AdminNotification.fromJson(sampleJson);
      expect(n1, equals(n2));
      expect(n1.hashCode, equals(n2.hashCode));
    });

    test('different read status makes unequal', () {
      final n1 = AdminNotification.fromJson(sampleJson);
      final readJson = Map<String, dynamic>.from(sampleJson)
        ..['is_read'] = true;
      final n2 = AdminNotification.fromJson(readJson);
      expect(n1, isNot(equals(n2)));
    });
  });
}
