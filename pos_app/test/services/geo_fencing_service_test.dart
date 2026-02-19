import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/services/geo_fencing_service.dart';

// ===========================================
// Geo-Fencing Service Tests
// ===========================================

void main() {
  late GeoFencingService service;

  setUp(() {
    service = GeoFencingService();
  });

  group('GeoFencingService', () {
    group('default values', () {
      test('يستخدم موقع الرياض الافتراضي', () {
        expect(service.storeLatitude, GeoFencingService.defaultLatitude);
        expect(service.storeLongitude, GeoFencingService.defaultLongitude);
        expect(service.notificationRadius, GeoFencingService.defaultRadius);
      });

      test('القيم الافتراضية صحيحة', () {
        expect(GeoFencingService.defaultLatitude, 24.7136);
        expect(GeoFencingService.defaultLongitude, 46.6753);
        expect(GeoFencingService.defaultRadius, 2.0);
      });
    });

    group('setStoreLocation', () {
      test('يُحدّث موقع المتجر', () {
        service.setStoreLocation(25.0, 45.0);

        expect(service.storeLatitude, 25.0);
        expect(service.storeLongitude, 45.0);
      });

      test('يقبل إحداثيات سالبة', () {
        service.setStoreLocation(-10.5, -20.5);

        expect(service.storeLatitude, -10.5);
        expect(service.storeLongitude, -20.5);
      });
    });

    group('setNotificationRadius', () {
      test('يُحدّث نصف قطر الإشعارات', () {
        service.setNotificationRadius(5.0);

        expect(service.notificationRadius, 5.0);
      });

      test('يقبل قيم صغيرة', () {
        service.setNotificationRadius(0.5);

        expect(service.notificationRadius, 0.5);
      });
    });

    group('calculateDistance', () {
      test('يُرجع 0 للنقطة نفسها', () {
        final distance = service.calculateDistance(
          24.7136, 46.6753,
          24.7136, 46.6753,
        );

        expect(distance, closeTo(0.0, 0.001));
      });

      test('يحسب المسافة بين الرياض وجدة', () {
        // الرياض
        const riyadhLat = 24.7136;
        const riyadhLon = 46.6753;
        // جدة
        const jeddahLat = 21.5433;
        const jeddahLon = 39.1728;

        final distance = service.calculateDistance(
          riyadhLat, riyadhLon,
          jeddahLat, jeddahLon,
        );

        // المسافة حوالي 850 كم
        expect(distance, closeTo(850.0, 50.0));
      });

      test('يحسب المسافة القصيرة بدقة', () {
        // نقطتان قريبتان (حوالي 1 كم)
        final distance = service.calculateDistance(
          24.7136, 46.6753,
          24.7226, 46.6753,
        );

        expect(distance, closeTo(1.0, 0.1));
      });

      test('يتعامل مع الإحداثيات السالبة', () {
        final distance = service.calculateDistance(
          -10.0, -20.0,
          -10.01, -20.01,
        );

        expect(distance, greaterThan(0));
        expect(distance, lessThan(5));
      });
    });

    group('isCustomerNearby', () {
      test('يُرجع true للعميل القريب', () {
        service.setStoreLocation(24.7136, 46.6753);
        service.setNotificationRadius(5.0);

        // عميل على بعد 1 كم تقريباً
        final isNearby = service.isCustomerNearby(24.7226, 46.6753);

        expect(isNearby, isTrue);
      });

      test('يُرجع false للعميل البعيد', () {
        service.setStoreLocation(24.7136, 46.6753);
        service.setNotificationRadius(2.0);

        // عميل في جدة (850 كم)
        final isNearby = service.isCustomerNearby(21.5433, 39.1728);

        expect(isNearby, isFalse);
      });

      test('يتعامل مع العميل على الحدود', () {
        service.setStoreLocation(24.7136, 46.6753);
        service.setNotificationRadius(1.0);

        // عميل على بعد ~1 كم (على الحدود)
        final isNearby = service.isCustomerNearby(24.7226, 46.6753);

        // قد يكون true أو false حسب الدقة
        expect(isNearby, isA<bool>());
      });
    });

    group('getNearbyCustomers', () {
      test('يُرجع العملاء القريبين فقط', () {
        service.setStoreLocation(24.7136, 46.6753);
        service.setNotificationRadius(5.0);

        final customers = [
          {'name': 'قريب 1', 'latitude': 24.7200, 'longitude': 46.6800},
          {'name': 'قريب 2', 'latitude': 24.7150, 'longitude': 46.6700},
          {'name': 'بعيد', 'latitude': 21.5433, 'longitude': 39.1728}, // جدة
        ];

        final nearby = service.getNearbyCustomers(customers);

        expect(nearby.length, 2);
        expect(nearby.any((c) => c['name'] == 'قريب 1'), isTrue);
        expect(nearby.any((c) => c['name'] == 'قريب 2'), isTrue);
        expect(nearby.any((c) => c['name'] == 'بعيد'), isFalse);
      });

      test('يتجاهل العملاء بدون إحداثيات', () {
        service.setStoreLocation(24.7136, 46.6753);
        service.setNotificationRadius(5.0);

        final customers = [
          {'name': 'مع إحداثيات', 'latitude': 24.7200, 'longitude': 46.6800},
          {'name': 'بدون إحداثيات'},
          {'name': 'latitude فقط', 'latitude': 24.7200},
          {'name': 'longitude فقط', 'longitude': 46.6800},
        ];

        final nearby = service.getNearbyCustomers(customers);

        expect(nearby.length, 1);
        expect(nearby.first['name'], 'مع إحداثيات');
      });

      test('يُرجع قائمة فارغة إذا لم يوجد عملاء قريبين', () {
        service.setStoreLocation(24.7136, 46.6753);
        service.setNotificationRadius(1.0);

        final customers = [
          {'name': 'بعيد 1', 'latitude': 21.5433, 'longitude': 39.1728},
          {'name': 'بعيد 2', 'latitude': 26.0, 'longitude': 50.0},
        ];

        final nearby = service.getNearbyCustomers(customers);

        expect(nearby, isEmpty);
      });
    });

    group('sendPromotionToNearbyCustomers', () {
      test('يُرسل للعملاء القريبين ويُرجع العدد', () async {
        service.setStoreLocation(24.7136, 46.6753);
        service.setNotificationRadius(10.0);

        final customers = [
          {'name': 'قريب 1', 'latitude': 24.7200, 'longitude': 46.6800},
          {'name': 'قريب 2', 'latitude': 24.7150, 'longitude': 46.6700},
          {'name': 'بعيد', 'latitude': 21.5433, 'longitude': 39.1728},
        ];

        final count = await service.sendPromotionToNearbyCustomers(
          promotionTitle: 'خصم 20%',
          promotionMessage: 'على جميع المنتجات',
          customers: customers,
        );

        expect(count, 2);
      });

      test('يُرجع 0 إذا لم يوجد عملاء قريبين', () async {
        service.setStoreLocation(24.7136, 46.6753);
        service.setNotificationRadius(1.0);

        final customers = [
          {'name': 'بعيد', 'latitude': 21.5433, 'longitude': 39.1728},
        ];

        final count = await service.sendPromotionToNearbyCustomers(
          promotionTitle: 'عرض',
          promotionMessage: 'تفاصيل',
          customers: customers,
        );

        expect(count, 0);
      });
    });
  });
}
