/// اختبارات DAO الخصومات والكوبونات
///
/// اختبارات تكامل تستخدم قاعدة بيانات SQLite في الذاكرة
library;

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pos_app/data/local/app_database.dart';

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

Future<int> _insertTestDiscount(
  AppDatabase db, {
  required String id,
  required String storeId,
  String name = 'خصم اختبار',
  String type = 'percentage',
  double value = 10.0,
  bool isActive = true,
  DateTime? createdAt,
}) async {
  return db.discountsDao.insertDiscount(DiscountsTableCompanion.insert(
    id: id,
    storeId: storeId,
    name: name,
    type: type,
    value: value,
    isActive: Value(isActive),
    createdAt: createdAt ?? DateTime.now(),
  ));
}

Future<int> _insertTestCoupon(
  AppDatabase db, {
  required String id,
  required String storeId,
  required String code,
  String type = 'percentage',
  double value = 15.0,
  bool isActive = true,
  DateTime? createdAt,
}) async {
  return db.discountsDao.insertCoupon(CouponsTableCompanion.insert(
    id: id,
    storeId: storeId,
    code: code,
    type: type,
    value: value,
    isActive: Value(isActive),
    createdAt: createdAt ?? DateTime.now(),
  ));
}

// ============================================================================
// TESTS
// ============================================================================

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('DiscountsDao', () {
    group('insertDiscount', () {
      test('يُضيف خصم جديد', () async {
        // Act
        final result = await db.discountsDao.insertDiscount(
          DiscountsTableCompanion.insert(
            id: 'disc-1',
            storeId: 'store-1',
            name: 'خصم 10%',
            type: 'percentage',
            value: 10.0,
            createdAt: DateTime.now(),
          ),
        );

        // Assert
        expect(result, 1);
      });

      test('يُضيف خصم ثابت المبلغ', () async {
        // Act
        final result = await db.discountsDao.insertDiscount(
          DiscountsTableCompanion.insert(
            id: 'disc-2',
            storeId: 'store-1',
            name: 'خصم 50 ريال',
            type: 'fixed',
            value: 50.0,
            createdAt: DateTime.now(),
          ),
        );

        // Assert
        expect(result, 1);
      });
    });

    group('getAllDiscounts', () {
      test('يُرجع جميع خصومات المتجر', () async {
        // Arrange
        await _insertTestDiscount(db, id: 'disc-1', storeId: 'store-1', name: 'خصم أ');
        await _insertTestDiscount(db, id: 'disc-2', storeId: 'store-1', name: 'خصم ب');
        await _insertTestDiscount(db, id: 'disc-3', storeId: 'store-2', name: 'خصم ج');

        // Act
        final discounts = await db.discountsDao.getAllDiscounts('store-1');

        // Assert
        expect(discounts.length, 2);
      });

      test('يُرجع قائمة فارغة إذا لم توجد خصومات', () async {
        // Act
        final discounts = await db.discountsDao.getAllDiscounts('store-empty');

        // Assert
        expect(discounts, isEmpty);
      });
    });

    group('getActiveDiscounts', () {
      test('يُرجع الخصومات النشطة فقط', () async {
        // Arrange
        await _insertTestDiscount(db, id: 'disc-1', storeId: 'store-1', isActive: true);
        await _insertTestDiscount(db, id: 'disc-2', storeId: 'store-1', isActive: false);
        await _insertTestDiscount(db, id: 'disc-3', storeId: 'store-1', isActive: true);

        // Act
        final activeDiscounts = await db.discountsDao.getActiveDiscounts('store-1');

        // Assert
        expect(activeDiscounts.length, 2);
        for (final d in activeDiscounts) {
          expect(d.isActive, true);
        }
      });
    });

    group('updateDiscount', () {
      test('يُحدّث بيانات الخصم', () async {
        // Arrange
        await _insertTestDiscount(db, id: 'disc-1', storeId: 'store-1', name: 'اسم قديم', value: 10.0);
        final original = (await db.discountsDao.getAllDiscounts('store-1')).first;

        // Act
        final updated = original.copyWith(name: 'اسم جديد', value: 25.0);
        final result = await db.discountsDao.updateDiscount(updated);

        // Assert
        expect(result, true);
        final fetched = (await db.discountsDao.getAllDiscounts('store-1')).first;
        expect(fetched.name, 'اسم جديد');
        expect(fetched.value, 25.0);
      });
    });

    group('deleteDiscount', () {
      test('يحذف الخصم', () async {
        // Arrange
        await _insertTestDiscount(db, id: 'disc-1', storeId: 'store-1');

        // Act
        final deleted = await db.discountsDao.deleteDiscount('disc-1');

        // Assert
        expect(deleted, 1);
        final discounts = await db.discountsDao.getAllDiscounts('store-1');
        expect(discounts, isEmpty);
      });

      test('يُرجع 0 إذا لم يُوجد الخصم', () async {
        // Act
        final deleted = await db.discountsDao.deleteDiscount('non-existent');

        // Assert
        expect(deleted, 0);
      });
    });

    group('insertCoupon', () {
      test('يُضيف كوبون جديد', () async {
        // Act
        final result = await db.discountsDao.insertCoupon(
          CouponsTableCompanion.insert(
            id: 'coup-1',
            storeId: 'store-1',
            code: 'SAVE20',
            type: 'percentage',
            value: 20.0,
            createdAt: DateTime.now(),
          ),
        );

        // Assert
        expect(result, 1);
      });
    });

    group('getCouponByCode', () {
      test('يجد الكوبون بالرمز', () async {
        // Arrange
        await _insertTestCoupon(db, id: 'coup-1', storeId: 'store-1', code: 'WELCOME10');

        // Act
        final coupon = await db.discountsDao.getCouponByCode('WELCOME10', 'store-1');

        // Assert
        expect(coupon, isNotNull);
        expect(coupon!.code, 'WELCOME10');
        expect(coupon.value, 15.0);
      });

      test('يُرجع null للكوبون غير النشط', () async {
        // Arrange
        await _insertTestCoupon(db, id: 'coup-inactive', storeId: 'store-1', code: 'EXPIRED', isActive: false);

        // Act
        final coupon = await db.discountsDao.getCouponByCode('EXPIRED', 'store-1');

        // Assert
        expect(coupon, isNull);
      });

      test('يُرجع null للكوبون غير الموجود', () async {
        // Act
        final coupon = await db.discountsDao.getCouponByCode('NONEXIST', 'store-1');

        // Assert
        expect(coupon, isNull);
      });
    });

    group('getAllCoupons', () {
      test('يُرجع جميع كوبونات المتجر', () async {
        // Arrange
        await _insertTestCoupon(db, id: 'coup-1', storeId: 'store-1', code: 'CODE1');
        await _insertTestCoupon(db, id: 'coup-2', storeId: 'store-1', code: 'CODE2');
        await _insertTestCoupon(db, id: 'coup-3', storeId: 'store-2', code: 'CODE3');

        // Act
        final coupons = await db.discountsDao.getAllCoupons('store-1');

        // Assert
        expect(coupons.length, 2);
      });
    });
  });
}
