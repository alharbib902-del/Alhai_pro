import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_core/src/models/activity_log.dart';

void main() {
  group('ActivityLog Model', () {
    ActivityLog createLog({
      String id = 'log-1',
      String action = 'login',
      String? entityType,
      String? entityId,
    }) {
      return ActivityLog(
        id: id,
        storeId: 'store-1',
        userId: 'user-1',
        action: action,
        entityType: entityType,
        entityId: entityId,
        createdAt: DateTime(2026, 1, 15),
      );
    }

    group('actionDisplayAr', () {
      test('should return Arabic for login', () {
        final log = createLog(action: 'login');
        expect(log.actionDisplayAr, equals('تسجيل دخول'));
      });

      test('should return Arabic for logout', () {
        final log = createLog(action: 'logout');
        expect(log.actionDisplayAr, equals('تسجيل خروج'));
      });

      test('should return Arabic for create_order', () {
        final log = createLog(action: 'create_order');
        expect(log.actionDisplayAr, equals('إنشاء طلب'));
      });

      test('should return Arabic for update_order', () {
        final log = createLog(action: 'update_order');
        expect(log.actionDisplayAr, equals('تحديث طلب'));
      });

      test('should return Arabic for cancel_order', () {
        final log = createLog(action: 'cancel_order');
        expect(log.actionDisplayAr, equals('إلغاء طلب'));
      });

      test('should return Arabic for create_product', () {
        final log = createLog(action: 'create_product');
        expect(log.actionDisplayAr, equals('إضافة منتج'));
      });

      test('should return Arabic for update_product', () {
        final log = createLog(action: 'update_product');
        expect(log.actionDisplayAr, equals('تعديل منتج'));
      });

      test('should return Arabic for delete_product', () {
        final log = createLog(action: 'delete_product');
        expect(log.actionDisplayAr, equals('حذف منتج'));
      });

      test('should return Arabic for stock_adjustment', () {
        final log = createLog(action: 'stock_adjustment');
        expect(log.actionDisplayAr, equals('تعديل مخزون'));
      });

      test('should return Arabic for open_shift', () {
        final log = createLog(action: 'open_shift');
        expect(log.actionDisplayAr, equals('فتح وردية'));
      });

      test('should return Arabic for close_shift', () {
        final log = createLog(action: 'close_shift');
        expect(log.actionDisplayAr, equals('إغلاق وردية'));
      });

      test('should return Arabic for add_payment', () {
        final log = createLog(action: 'add_payment');
        expect(log.actionDisplayAr, equals('إضافة دفعة'));
      });

      test('should return Arabic for refund', () {
        final log = createLog(action: 'refund');
        expect(log.actionDisplayAr, equals('استرداد'));
      });

      test('should return raw action for unknown actions', () {
        final log = createLog(action: 'custom_action');
        expect(log.actionDisplayAr, equals('custom_action'));
      });
    });

    group('entityTypeDisplayAr', () {
      test('should return Arabic for order', () {
        final log = createLog(entityType: 'order');
        expect(log.entityTypeDisplayAr, equals('طلب'));
      });

      test('should return Arabic for product', () {
        final log = createLog(entityType: 'product');
        expect(log.entityTypeDisplayAr, equals('منتج'));
      });

      test('should return Arabic for user', () {
        final log = createLog(entityType: 'user');
        expect(log.entityTypeDisplayAr, equals('مستخدم'));
      });

      test('should return Arabic for store', () {
        final log = createLog(entityType: 'store');
        expect(log.entityTypeDisplayAr, equals('متجر'));
      });

      test('should return Arabic for shift', () {
        final log = createLog(entityType: 'shift');
        expect(log.entityTypeDisplayAr, equals('وردية'));
      });

      test('should return Arabic for payment', () {
        final log = createLog(entityType: 'payment');
        expect(log.entityTypeDisplayAr, equals('دفعة'));
      });

      test('should return raw type for unknown', () {
        final log = createLog(entityType: 'custom');
        expect(log.entityTypeDisplayAr, equals('custom'));
      });

      test('should return null when entityType is null', () {
        final log = createLog(entityType: null);
        expect(log.entityTypeDisplayAr, isNull);
      });
    });

    group('serialization', () {
      test('should create ActivityLog from JSON', () {
        final json = {
          'id': 'log-1',
          'storeId': 'store-1',
          'userId': 'user-1',
          'action': 'create_order',
          'entityType': 'order',
          'entityId': 'order-1',
          'details': {'orderTotal': 150.0},
          'ipAddress': '192.168.1.1',
          'createdAt': '2026-01-15T10:00:00.000',
        };

        final log = ActivityLog.fromJson(json);

        expect(log.id, equals('log-1'));
        expect(log.action, equals('create_order'));
        expect(log.entityType, equals('order'));
        expect(log.entityId, equals('order-1'));
        expect(log.details, isNotNull);
        expect(log.details!['orderTotal'], equals(150.0));
        expect(log.ipAddress, equals('192.168.1.1'));
      });

      test('should serialize to JSON and back', () {
        final log = createLog(
          action: 'login',
          entityType: 'user',
          entityId: 'user-1',
        );
        final json = log.toJson();
        final restored = ActivityLog.fromJson(json);

        expect(restored.id, equals(log.id));
        expect(restored.action, equals('login'));
        expect(restored.entityType, equals('user'));
      });
    });
  });
}
