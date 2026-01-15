import 'package:alhai_core/alhai_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OrderStatus Extension', () {
    test('should return correct Arabic display names', () {
      expect(OrderStatus.created.displayNameAr, 'جديد');
      expect(OrderStatus.confirmed.displayNameAr, 'مؤكد');
      expect(OrderStatus.preparing.displayNameAr, 'قيد التحضير');
      expect(OrderStatus.ready.displayNameAr, 'جاهز');
      expect(OrderStatus.delivered.displayNameAr, 'تم التوصيل');
      expect(OrderStatus.cancelled.displayNameAr, 'ملغي');
    });

    test('should detect final states correctly', () {
      expect(OrderStatus.created.isFinal, isFalse);
      expect(OrderStatus.delivered.isFinal, isTrue);
      expect(OrderStatus.cancelled.isFinal, isTrue);
      expect(OrderStatus.completed.isFinal, isTrue);
    });

    test('should detect cancellable orders correctly', () {
      expect(OrderStatus.created.canCancel, isTrue);
      expect(OrderStatus.confirmed.canCancel, isTrue);
      expect(OrderStatus.preparing.canCancel, isFalse);
      expect(OrderStatus.delivered.canCancel, isFalse);
    });
  });

  group('DeliveryStatus Extension', () {
    test('should return correct Arabic display names', () {
      expect(DeliveryStatus.assigned.displayNameAr, 'تم التعيين');
      expect(DeliveryStatus.accepted.displayNameAr, 'تم القبول');
      expect(DeliveryStatus.pickedUp.displayNameAr, 'تم الاستلام');
      expect(DeliveryStatus.delivered.displayNameAr, 'تم التوصيل');
    });

    test('should parse from API correctly', () {
      expect(DeliveryStatusX.fromApi('delivered'), DeliveryStatus.delivered);
      expect(DeliveryStatusX.fromApi('pickedUp'), DeliveryStatus.pickedUp);
      expect(DeliveryStatusX.fromApi('invalid'), DeliveryStatus.assigned);
    });
  });
}
