import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_core/src/models/refund.dart';

void main() {
  group('Refund Model', () {
    Refund createRefund({
      String id = 'refund-1',
      RefundStatus status = RefundStatus.pending,
      RefundReason reason = RefundReason.customerRequest,
      RefundMethod method = RefundMethod.cash,
      double totalAmount = 50.0,
      List<RefundItem>? items,
    }) {
      return Refund(
        id: id,
        originalSaleId: 'sale-1',
        storeId: 'store-1',
        cashierId: 'cashier-1',
        status: status,
        reason: reason,
        method: method,
        totalAmount: totalAmount,
        items: items ??
            [
              const RefundItem(
                productId: 'p1',
                productName: 'Product 1',
                quantity: 2,
                unitPrice: 25.0,
                totalAmount: 50.0,
              ),
            ],
        createdAt: DateTime(2026, 1, 15),
      );
    }

    group('isPending', () {
      test('should be true for pending status', () {
        final refund = createRefund(status: RefundStatus.pending);
        expect(refund.isPending, isTrue);
      });

      test('should be false for completed status', () {
        final refund = createRefund(status: RefundStatus.completed);
        expect(refund.isPending, isFalse);
      });
    });

    group('isCompleted', () {
      test('should be true for completed status', () {
        final refund = createRefund(status: RefundStatus.completed);
        expect(refund.isCompleted, isTrue);
      });

      test('should be false for pending status', () {
        final refund = createRefund(status: RefundStatus.pending);
        expect(refund.isCompleted, isFalse);
      });
    });

    group('totalItems', () {
      test('should calculate total items from all refund items', () {
        final refund = createRefund(
          items: [
            const RefundItem(
              productId: 'p1',
              productName: 'A',
              quantity: 3,
              unitPrice: 10.0,
              totalAmount: 30.0,
            ),
            const RefundItem(
              productId: 'p2',
              productName: 'B',
              quantity: 2,
              unitPrice: 20.0,
              totalAmount: 40.0,
            ),
          ],
        );

        expect(refund.totalItems, equals(5));
      });

      test('should return 0 for empty items', () {
        final refund = createRefund(items: []);
        expect(refund.totalItems, equals(0));
      });
    });

    group('requiresSupervisor', () {
      test('should require supervisor for amounts > 50', () {
        final refund = createRefund(totalAmount: 100.0);
        expect(refund.requiresSupervisor, isTrue);
      });

      test('should require supervisor for price error reason', () {
        final refund = createRefund(
          totalAmount: 10.0,
          reason: RefundReason.priceError,
        );
        expect(refund.requiresSupervisor, isTrue);
      });

      test('should not require supervisor for small customer request', () {
        final refund = createRefund(
          totalAmount: 30.0,
          reason: RefundReason.customerRequest,
        );
        expect(refund.requiresSupervisor, isFalse);
      });

      test('should not require supervisor for exactly 50', () {
        final refund = createRefund(
          totalAmount: 50.0,
          reason: RefundReason.defectiveProduct,
        );
        expect(refund.requiresSupervisor, isFalse);
      });
    });

    group('serialization', () {
      test('should create Refund from JSON', () {
        final json = {
          'id': 'refund-1',
          'originalSaleId': 'sale-1',
          'storeId': 'store-1',
          'cashierId': 'cashier-1',
          'status': 'PENDING',
          'reason': 'CUSTOMER_REQUEST',
          'method': 'CASH',
          'totalAmount': 75.0,
          'items': [
            {
              'productId': 'p1',
              'productName': 'Product 1',
              'quantity': 3,
              'unitPrice': 25.0,
              'totalAmount': 75.0,
            },
          ],
          'createdAt': '2026-01-15T00:00:00.000',
        };

        final refund = Refund.fromJson(json);

        expect(refund.id, equals('refund-1'));
        expect(refund.status, equals(RefundStatus.pending));
        expect(refund.reason, equals(RefundReason.customerRequest));
        expect(refund.method, equals(RefundMethod.cash));
        expect(refund.totalAmount, equals(75.0));
        expect(refund.items, hasLength(1));
      });

      test('should serialize to JSON and back', () {
        final refund = createRefund();
        final jsonStr = jsonEncode(refund.toJson());
        final restored = Refund.fromJson(
          jsonDecode(jsonStr) as Map<String, dynamic>,
        );

        expect(restored.id, equals(refund.id));
        expect(restored.status, equals(refund.status));
        expect(restored.totalAmount, equals(refund.totalAmount));
      });
    });
  });

  group('RefundStatus Extensions', () {
    test('displayNameAr should return Arabic names', () {
      expect(RefundStatus.pending.displayNameAr, equals('معلق'));
      expect(RefundStatus.approved.displayNameAr, equals('موافق عليه'));
      expect(RefundStatus.completed.displayNameAr, equals('مكتمل'));
      expect(RefundStatus.rejected.displayNameAr, equals('مرفوض'));
    });

    test('isActive should be true for pending and approved', () {
      expect(RefundStatus.pending.isActive, isTrue);
      expect(RefundStatus.approved.isActive, isTrue);
      expect(RefundStatus.completed.isActive, isFalse);
      expect(RefundStatus.rejected.isActive, isFalse);
    });
  });

  group('RefundReason Extensions', () {
    test('displayNameAr should return Arabic names', () {
      expect(RefundReason.customerRequest.displayNameAr, equals('طلب العميل'));
      expect(RefundReason.defectiveProduct.displayNameAr, equals('منتج معيب'));
      expect(RefundReason.wrongItem.displayNameAr, equals('منتج خاطئ'));
      expect(RefundReason.expiredProduct.displayNameAr, equals('منتج منتهي'));
      expect(RefundReason.priceError.displayNameAr, equals('خطأ في السعر'));
      expect(RefundReason.other.displayNameAr, equals('أخرى'));
    });
  });

  group('RefundMethod Extensions', () {
    test('displayNameAr should return Arabic names', () {
      expect(RefundMethod.cash.displayNameAr, equals('نقداً'));
      expect(RefundMethod.card.displayNameAr, equals('بطاقة'));
      expect(RefundMethod.credit.displayNameAr, equals('رصيد'));
    });
  });
}
