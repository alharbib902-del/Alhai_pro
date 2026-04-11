import 'package:flutter_test/flutter_test.dart';
import 'package:super_admin/data/models/sa_analytics_model.dart';

void main() {
  group('SADashboardKPIs', () {
    test('fromJson parses complete data', () {
      // Arrange
      final json = {
        'active_stores': 42,
        'active_subscriptions': 38,
        'trial_subscriptions': 5,
        'new_signups': 12,
        'mrr': 15000.50,
        'arr': 180006.0,
      };

      // Act
      final kpis = SADashboardKPIs.fromJson(json);

      // Assert
      expect(kpis.activeStores, equals(42));
      expect(kpis.activeSubscriptions, equals(38));
      expect(kpis.trialSubscriptions, equals(5));
      expect(kpis.newSignups, equals(12));
      expect(kpis.mrr, equals(15000.50));
      expect(kpis.arr, equals(180006.0));
    });

    test('fromJson defaults missing fields to 0', () {
      // Arrange
      final json = <String, dynamic>{};

      // Act
      final kpis = SADashboardKPIs.fromJson(json);

      // Assert
      expect(kpis.activeStores, equals(0));
      expect(kpis.activeSubscriptions, equals(0));
      expect(kpis.trialSubscriptions, equals(0));
      expect(kpis.newSignups, equals(0));
      expect(kpis.mrr, equals(0));
      expect(kpis.arr, equals(0));
    });

    test('fromJson computes ARR from MRR when ARR is not provided', () {
      // Arrange
      final json = {
        'mrr': 1000.0,
        // no 'arr' key
      };

      // Act
      final kpis = SADashboardKPIs.fromJson(json);

      // Assert
      expect(kpis.mrr, equals(1000.0));
      expect(kpis.arr, equals(12000.0)); // mrr * 12
    });

    test('fromJson uses explicit ARR when provided', () {
      // Arrange
      final json = {
        'mrr': 1000.0,
        'arr': 11000.0, // explicit, not mrr*12
      };

      // Act
      final kpis = SADashboardKPIs.fromJson(json);

      // Assert
      expect(kpis.arr, equals(11000.0));
    });

    test('toJson round-trip preserves values', () {
      const original = SADashboardKPIs(
        activeStores: 10,
        activeSubscriptions: 8,
        trialSubscriptions: 2,
        newSignups: 3,
        mrr: 5000.0,
        arr: 60000.0,
      );

      final json = original.toJson();
      final restored = SADashboardKPIs.fromJson(json);

      expect(restored.activeStores, equals(original.activeStores));
      expect(restored.mrr, equals(original.mrr));
      expect(restored.arr, equals(original.arr));
    });
  });

  group('SARevenueData', () {
    test('fromJson parses complete data', () {
      // Arrange
      final json = {'month': '2024-06', 'revenue': 25000.75};

      // Act
      final data = SARevenueData.fromJson(json);

      // Assert
      expect(data.month, equals('2024-06'));
      expect(data.revenue, equals(25000.75));
    });

    test('fromJson defaults missing fields', () {
      final data = SARevenueData.fromJson(<String, dynamic>{});
      expect(data.month, equals(''));
      expect(data.revenue, equals(0));
    });

    test('toJson serializes correctly', () {
      const data = SARevenueData(month: '2024-01', revenue: 1500.0);
      final json = data.toJson();

      expect(json['month'], equals('2024-01'));
      expect(json['revenue'], equals(1500.0));
    });
  });

  group('SAPlatformSettings', () {
    test('fromJson parses complete data', () {
      // Arrange
      final json = {
        'zatca_enabled': false,
        'zatca_environment': 'sandbox',
        'vat_rate': 5.0,
        'default_language': 'en',
        'default_currency': 'USD',
        'trial_period_days': 30,
        'moyasar_enabled': false,
        'hyperpay_enabled': true,
        'tabby_enabled': false,
        'tamara_enabled': true,
      };

      // Act
      final settings = SAPlatformSettings.fromJson(json);

      // Assert
      expect(settings.zatcaEnabled, isFalse);
      expect(settings.zatcaEnvironment, equals('sandbox'));
      expect(settings.vatRate, equals(5.0));
      expect(settings.defaultLanguage, equals('en'));
      expect(settings.defaultCurrency, equals('USD'));
      expect(settings.trialPeriodDays, equals(30));
      expect(settings.moyasarEnabled, isFalse);
      expect(settings.hyperpayEnabled, isTrue);
      expect(settings.tabbyEnabled, isFalse);
      expect(settings.tamaraEnabled, isTrue);
    });

    test('fromJson applies Saudi defaults for empty JSON', () {
      // Arrange
      final json = <String, dynamic>{};

      // Act
      final settings = SAPlatformSettings.fromJson(json);

      // Assert
      expect(settings.zatcaEnabled, isTrue);
      expect(settings.zatcaEnvironment, equals('production'));
      expect(settings.vatRate, equals(15.0));
      expect(settings.defaultLanguage, equals('ar'));
      expect(settings.defaultCurrency, equals('SAR'));
      expect(settings.trialPeriodDays, equals(14));
      expect(settings.moyasarEnabled, isTrue);
      expect(settings.hyperpayEnabled, isFalse);
      expect(settings.tabbyEnabled, isTrue);
      expect(settings.tamaraEnabled, isFalse);
    });

    test('toJson round-trip preserves all fields', () {
      const original = SAPlatformSettings(
        zatcaEnabled: false,
        zatcaEnvironment: 'sandbox',
        vatRate: 10.0,
        defaultLanguage: 'en',
        defaultCurrency: 'USD',
        trialPeriodDays: 7,
        moyasarEnabled: false,
        hyperpayEnabled: true,
        tabbyEnabled: false,
        tamaraEnabled: true,
      );

      final json = original.toJson();
      final restored = SAPlatformSettings.fromJson(json);

      expect(restored.zatcaEnabled, equals(original.zatcaEnabled));
      expect(restored.zatcaEnvironment, equals(original.zatcaEnvironment));
      expect(restored.vatRate, equals(original.vatRate));
      expect(restored.defaultLanguage, equals(original.defaultLanguage));
      expect(restored.defaultCurrency, equals(original.defaultCurrency));
      expect(restored.trialPeriodDays, equals(original.trialPeriodDays));
      expect(restored.moyasarEnabled, equals(original.moyasarEnabled));
      expect(restored.hyperpayEnabled, equals(original.hyperpayEnabled));
      expect(restored.tabbyEnabled, equals(original.tabbyEnabled));
      expect(restored.tamaraEnabled, equals(original.tamaraEnabled));
    });
  });

  group('SARevenueByPlan', () {
    test('fromJson parses correctly', () {
      final json = {
        'name': 'Premium',
        'slug': 'premium',
        'subscribers': 25,
        'revenue': 4975.0,
      };

      final data = SARevenueByPlan.fromJson(json);

      expect(data.name, equals('Premium'));
      expect(data.slug, equals('premium'));
      expect(data.subscribers, equals(25));
      expect(data.revenue, equals(4975.0));
    });

    test('fromJson defaults missing fields', () {
      final data = SARevenueByPlan.fromJson(<String, dynamic>{});
      expect(data.name, equals(''));
      expect(data.slug, equals(''));
      expect(data.subscribers, equals(0));
      expect(data.revenue, equals(0));
    });
  });

  group('SASystemHealth', () {
    test('fromJson parses healthy status', () {
      final json = {
        'status': 'healthy',
        'db_response_ms': 12,
        'timestamp': '2024-06-01T12:00:00Z',
      };

      final health = SASystemHealth.fromJson(json);

      expect(health.status, equals('healthy'));
      expect(health.isHealthy, isTrue);
      expect(health.dbResponseMs, equals(12));
      expect(health.error, isNull);
    });

    test('fromJson defaults status to unknown', () {
      final health = SASystemHealth.fromJson(<String, dynamic>{});

      expect(health.status, equals('unknown'));
      expect(health.isHealthy, isFalse);
      expect(health.timestamp, isNotEmpty);
    });

    test('isHealthy returns false for non-healthy status', () {
      final health = SASystemHealth.fromJson({
        'status': 'degraded',
        'error': 'High latency',
        'timestamp': '2024-06-01T12:00:00Z',
      });

      expect(health.isHealthy, isFalse);
      expect(health.error, equals('High latency'));
    });
  });

  group('SATopStoreRevenue', () {
    test('fromJson parses correctly', () {
      final data = SATopStoreRevenue.fromJson({
        'store_id': 's1',
        'store_name': 'Top Store',
        'revenue': 50000.0,
      });

      expect(data.storeId, equals('s1'));
      expect(data.storeName, equals('Top Store'));
      expect(data.revenue, equals(50000.0));
    });
  });

  group('SATopStoreTransactions', () {
    test('fromJson parses correctly', () {
      final data = SATopStoreTransactions.fromJson({
        'store_id': 's1',
        'store_name': 'Busy Store',
        'transactions': 1200,
        'avg_per_day': 40,
        'products': 350,
      });

      expect(data.transactions, equals(1200));
      expect(data.avgPerDay, equals(40));
      expect(data.products, equals(350));
    });
  });

  group('SAActiveUsersPerStore', () {
    test('fromJson parses correctly', () {
      final data = SAActiveUsersPerStore.fromJson({
        'store_id': 's1',
        'store_name': 'Active Store',
        'active_users': 8,
      });

      expect(data.storeId, equals('s1'));
      expect(data.activeUsers, equals(8));
    });
  });
}
