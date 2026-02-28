import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_core/src/models/order_payment.dart';
import 'package:alhai_core/src/models/enums/payment_method.dart';

void main() {
  group('OrderPayment Model', () {
    OrderPayment createPayment({
      String id = 'payment-1',
      PaymentMethod method = PaymentMethod.cash,
      double amount = 50.0,
      String status = 'completed',
    }) {
      return OrderPayment(
        id: id,
        orderId: 'order-1',
        method: method,
        amount: amount,
        status: status,
        createdAt: DateTime(2026, 1, 15),
      );
    }

    group('isCompleted', () {
      test('should return true for completed status', () {
        final payment = createPayment(status: 'completed');
        expect(payment.isCompleted, isTrue);
      });

      test('should return false for pending status', () {
        final payment = createPayment(status: 'pending');
        expect(payment.isCompleted, isFalse);
      });
    });

    group('isPending', () {
      test('should return true for pending status', () {
        final payment = createPayment(status: 'pending');
        expect(payment.isPending, isTrue);
      });

      test('should return false for completed status', () {
        final payment = createPayment(status: 'completed');
        expect(payment.isPending, isFalse);
      });
    });

    group('isFailed', () {
      test('should return true for failed status', () {
        final payment = createPayment(status: 'failed');
        expect(payment.isFailed, isTrue);
      });

      test('should return false for completed status', () {
        final payment = createPayment(status: 'completed');
        expect(payment.isFailed, isFalse);
      });
    });

    group('statusDisplayAr', () {
      test('should return Arabic for completed', () {
        final payment = createPayment(status: 'completed');
        expect(payment.statusDisplayAr, equals('مكتمل'));
      });

      test('should return Arabic for pending', () {
        final payment = createPayment(status: 'pending');
        expect(payment.statusDisplayAr, equals('معلق'));
      });

      test('should return Arabic for failed', () {
        final payment = createPayment(status: 'failed');
        expect(payment.statusDisplayAr, equals('فاشل'));
      });

      test('should return Arabic for refunded', () {
        final payment = createPayment(status: 'refunded');
        expect(payment.statusDisplayAr, equals('مسترد'));
      });

      test('should return raw status for unknown', () {
        final payment = createPayment(status: 'unknown_status');
        expect(payment.statusDisplayAr, equals('unknown_status'));
      });
    });

    group('serialization', () {
      test('should create OrderPayment from JSON', () {
        final json = {
          'id': 'payment-1',
          'orderId': 'order-1',
          'method': 'cash',
          'amount': 100.0,
          'referenceNo': 'REF-001',
          'status': 'completed',
          'createdAt': '2026-01-15T10:00:00.000',
        };

        final payment = OrderPayment.fromJson(json);

        expect(payment.id, equals('payment-1'));
        expect(payment.method, equals(PaymentMethod.cash));
        expect(payment.amount, equals(100.0));
        expect(payment.referenceNo, equals('REF-001'));
        expect(payment.isCompleted, isTrue);
      });

      test('should serialize to JSON and back', () {
        final payment = createPayment(
          method: PaymentMethod.card,
          amount: 75.0,
        );
        final json = payment.toJson();
        final restored = OrderPayment.fromJson(json);

        expect(restored.id, equals(payment.id));
        expect(restored.method, equals(PaymentMethod.card));
        expect(restored.amount, equals(75.0));
      });
    });
  });
}
