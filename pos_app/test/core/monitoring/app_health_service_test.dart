import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/monitoring/app_health_service.dart';

void main() {
  setUp(() {
    AppHealthService.clear();
  });

  group('AppHealthService', () {
    group('registerCheck', () {
      test('يسجل فحص صحة جديد', () async {
        AppHealthService.registerCheck('test', () async {
          return ComponentHealth(
            name: 'test',
            status: HealthStatus.healthy,
          );
        });

        final report = await AppHealthService.checkHealth();
        expect(report.components, hasLength(1));
        expect(report.components.first.name, equals('test'));
      });

      test('يسجل فحوصات متعددة', () async {
        AppHealthService.registerCheck('test1', () async {
          return ComponentHealth(name: 'test1', status: HealthStatus.healthy);
        });
        AppHealthService.registerCheck('test2', () async {
          return ComponentHealth(name: 'test2', status: HealthStatus.healthy);
        });

        final report = await AppHealthService.checkHealth();
        expect(report.components, hasLength(2));
      });
    });

    group('unregisterCheck', () {
      test('يزيل فحص صحة مسجل', () async {
        AppHealthService.registerCheck('test', () async {
          return ComponentHealth(name: 'test', status: HealthStatus.healthy);
        });

        AppHealthService.unregisterCheck('test');

        final report = await AppHealthService.checkHealth();
        expect(report.components, isEmpty);
      });
    });

    group('checkHealth', () {
      test('يعيد تقرير صحي عندما كل الفحوصات ناجحة', () async {
        AppHealthService.registerCheck('db', () async {
          return ComponentHealth(name: 'db', status: HealthStatus.healthy);
        });
        AppHealthService.registerCheck('network', () async {
          return ComponentHealth(name: 'network', status: HealthStatus.healthy);
        });

        final report = await AppHealthService.checkHealth();

        expect(report.overallStatus, equals(HealthStatus.healthy));
        expect(report.isAllHealthy, isTrue);
        expect(report.healthyCount, equals(2));
      });

      test('يعيد degraded عندما يوجد فحص متدهور', () async {
        AppHealthService.registerCheck('db', () async {
          return ComponentHealth(name: 'db', status: HealthStatus.healthy);
        });
        AppHealthService.registerCheck('network', () async {
          return ComponentHealth(name: 'network', status: HealthStatus.degraded);
        });

        final report = await AppHealthService.checkHealth();

        expect(report.overallStatus, equals(HealthStatus.degraded));
        expect(report.degradedCount, equals(1));
      });

      test('يعيد unhealthy عندما يوجد فحص غير صحي', () async {
        AppHealthService.registerCheck('db', () async {
          return ComponentHealth(name: 'db', status: HealthStatus.unhealthy);
        });
        AppHealthService.registerCheck('network', () async {
          return ComponentHealth(name: 'network', status: HealthStatus.degraded);
        });

        final report = await AppHealthService.checkHealth();

        expect(report.overallStatus, equals(HealthStatus.unhealthy));
        expect(report.unhealthyCount, equals(1));
      });

      test('يتعامل مع استثناءات الفحص', () async {
        AppHealthService.registerCheck('failing', () async {
          throw Exception('Test error');
        });

        final report = await AppHealthService.checkHealth();

        expect(report.overallStatus, equals(HealthStatus.unhealthy));
        expect(report.components.first.message, contains('failed'));
      });

      test('يحسب مدة الفحص', () async {
        AppHealthService.registerCheck('slow', () async {
          await Future.delayed(const Duration(milliseconds: 50));
          return ComponentHealth(name: 'slow', status: HealthStatus.healthy);
        });

        final report = await AppHealthService.checkHealth();

        expect(report.checkDuration.inMilliseconds, greaterThanOrEqualTo(50));
      });
    });

    group('lastReport', () {
      test('يحفظ آخر تقرير', () async {
        AppHealthService.registerCheck('test', () async {
          return ComponentHealth(name: 'test', status: HealthStatus.healthy);
        });

        await AppHealthService.checkHealth();

        expect(AppHealthService.lastReport, isNotNull);
        expect(AppHealthService.lastReport!.components, hasLength(1));
      });
    });
  });

  group('ComponentHealth', () {
    test('isHealthy يعمل بشكل صحيح', () {
      final healthy = ComponentHealth(name: 'test', status: HealthStatus.healthy);
      final degraded = ComponentHealth(name: 'test', status: HealthStatus.degraded);

      expect(healthy.isHealthy, isTrue);
      expect(degraded.isHealthy, isFalse);
    });

    test('toJson يعيد map صحيح', () {
      final health = ComponentHealth(
        name: 'test',
        status: HealthStatus.healthy,
        message: 'All good',
        details: {'key': 'value'},
      );

      final json = health.toJson();

      expect(json['name'], equals('test'));
      expect(json['status'], equals('healthy'));
      expect(json['message'], equals('All good'));
      expect(json['details'], equals({'key': 'value'}));
    });
  });

  group('AppHealthReport', () {
    test('toJson يعيد ملخص صحيح', () {
      final report = AppHealthReport(
        overallStatus: HealthStatus.healthy,
        components: [
          ComponentHealth(name: 'c1', status: HealthStatus.healthy),
          ComponentHealth(name: 'c2', status: HealthStatus.degraded),
        ],
        checkDuration: const Duration(milliseconds: 100),
      );

      final json = report.toJson();

      expect(json['summary']['healthy'], equals(1));
      expect(json['summary']['degraded'], equals(1));
      expect(json['summary']['total'], equals(2));
    });
  });

  group('HealthChecks', () {
    group('connectivity', () {
      test('يعيد healthy عند الاتصال', () async {
        final check = HealthChecks.connectivity(() async => true);
        final result = await check();

        expect(result.status, equals(HealthStatus.healthy));
        expect(result.details?['isOnline'], isTrue);
      });

      test('يعيد degraded عند عدم الاتصال', () async {
        final check = HealthChecks.connectivity(() async => false);
        final result = await check();

        expect(result.status, equals(HealthStatus.degraded));
        expect(result.details?['isOnline'], isFalse);
      });
    });

    group('database', () {
      test('يعيد healthy عند نجاح الفحص', () async {
        final check = HealthChecks.database(() async => true);
        final result = await check();

        expect(result.status, equals(HealthStatus.healthy));
      });

      test('يعيد unhealthy عند فشل الفحص', () async {
        final check = HealthChecks.database(() async => throw Exception('DB Error'));
        final result = await check();

        expect(result.status, equals(HealthStatus.unhealthy));
        expect(result.message, contains('failed'));
      });
    });

    group('syncQueue', () {
      test('يعيد healthy عند قلة العناصر المعلقة', () async {
        final check = HealthChecks.syncQueue(
          getPendingCount: () async => 10,
          getFailedCount: () async => 0,
        );
        final result = await check();

        expect(result.status, equals(HealthStatus.healthy));
      });

      test('يعيد degraded عند كثرة العناصر المعلقة', () async {
        final check = HealthChecks.syncQueue(
          getPendingCount: () async => 100,
          getFailedCount: () async => 0,
          warningThreshold: 50,
        );
        final result = await check();

        expect(result.status, equals(HealthStatus.degraded));
      });

      test('يعيد unhealthy عند وجود عناصر فاشلة كثيرة', () async {
        final check = HealthChecks.syncQueue(
          getPendingCount: () async => 10,
          getFailedCount: () async => 15,
        );
        final result = await check();

        expect(result.status, equals(HealthStatus.unhealthy));
      });
    });
  });
}
