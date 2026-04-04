import 'package:flutter_test/flutter_test.dart';
import 'package:super_admin/data/models/sa_store_model.dart';

void main() {
  group('SAStore.fromJson', () {
    test('parses complete data correctly', () {
      // Arrange
      final json = {
        'id': 'store-001',
        'name': 'Grocery Plus',
        'address': '123 Main St',
        'phone': '+966500000000',
        'email': 'info@groceryplus.sa',
        'is_active': true,
        'owner_id': 'owner-001',
        'business_type': 'grocery',
        'created_at': '2024-01-15T10:00:00.000Z',
        'logo': 'https://example.com/logo.png',
        'subscriptions': [
          {
            'id': 'sub-001',
            'plan_id': 'plan-001',
            'status': 'active',
            'start_date': '2024-01-01',
            'end_date': '2024-12-31',
            'store_id': 'store-001',
            'plans': {
              'id': 'plan-001',
              'name': 'Premium',
              'slug': 'premium',
              'monthly_price': 199.0,
              'yearly_price': 1999.0,
              'max_branches': 5,
              'max_products': 10000,
              'max_users': 20,
              'features': ['pos', 'inventory', 'reports'],
            },
          },
        ],
      };

      // Act
      final store = SAStore.fromJson(json);

      // Assert
      expect(store.id, equals('store-001'));
      expect(store.name, equals('Grocery Plus'));
      expect(store.address, equals('123 Main St'));
      expect(store.phone, equals('+966500000000'));
      expect(store.email, equals('info@groceryplus.sa'));
      expect(store.isActive, isTrue);
      expect(store.ownerId, equals('owner-001'));
      expect(store.businessType, equals('grocery'));
      expect(store.createdAt, equals('2024-01-15T10:00:00.000Z'));
      expect(store.logo, equals('https://example.com/logo.png'));
      expect(store.subscriptions, hasLength(1));
      expect(store.subscriptions.first.status, equals('active'));
      expect(store.subscriptions.first.plan?.name, equals('Premium'));
      expect(store.subscriptions.first.plan?.features, contains('pos'));
    });

    test('uses defaults for missing/null fields', () {
      // Arrange
      final json = <String, dynamic>{
        'id': null,
        'name': null,
      };

      // Act
      final store = SAStore.fromJson(json);

      // Assert
      expect(store.id, equals(''));
      expect(store.name, equals(''));
      expect(store.address, isNull);
      expect(store.phone, isNull);
      expect(store.email, isNull);
      expect(store.isActive, isTrue); // default
      expect(store.ownerId, isNull);
      expect(store.businessType, isNull);
      expect(store.createdAt, isNull);
      expect(store.logo, isNull);
      expect(store.subscriptions, isEmpty);
    });

    test('handles subscriptions that are not a List', () {
      // Arrange
      final json = {
        'id': 'store-002',
        'name': 'Test Store',
        'subscriptions': 'not-a-list',
      };

      // Act
      final store = SAStore.fromJson(json);

      // Assert
      expect(store.subscriptions, isEmpty);
    });
  });

  group('SAStore.toJson round-trip', () {
    test('toJson produces JSON that fromJson can reconstruct', () {
      // Arrange
      const original = SAStore(
        id: 'store-rt',
        name: 'Round Trip Store',
        address: '456 Oak Ave',
        phone: '+966511111111',
        email: 'rt@test.com',
        isActive: false,
        ownerId: 'owner-rt',
        businessType: 'pharmacy',
        createdAt: '2024-03-01T08:00:00.000Z',
        logo: 'https://example.com/rt.png',
        subscriptions: [
          SAStoreSubscription(
            id: 'sub-rt',
            planId: 'plan-rt',
            status: 'trial',
            startDate: '2024-03-01',
            endDate: '2024-03-14',
            storeId: 'store-rt',
            plan: SAStorePlan(
              id: 'plan-rt',
              name: 'Trial',
              slug: 'trial',
              monthlyPrice: 0.0,
              yearlyPrice: 0.0,
              maxBranches: 1,
              maxProducts: 100,
              maxUsers: 2,
              features: ['pos'],
            ),
          ),
        ],
      );

      // Act
      final json = original.toJson();
      final restored = SAStore.fromJson(json);

      // Assert
      expect(restored.id, equals(original.id));
      expect(restored.name, equals(original.name));
      expect(restored.address, equals(original.address));
      expect(restored.isActive, equals(original.isActive));
      expect(restored.businessType, equals(original.businessType));
      expect(restored.subscriptions, hasLength(1));
      expect(restored.subscriptions.first.status, equals('trial'));
      expect(restored.subscriptions.first.plan?.name, equals('Trial'));
    });
  });

  group('SAStore convenience getters', () {
    test('planName returns first subscription plan name', () {
      const store = SAStore(
        id: 's1',
        name: 'S1',
        subscriptions: [
          SAStoreSubscription(
            plan: SAStorePlan(name: 'Gold'),
          ),
        ],
      );
      expect(store.planName, equals('Gold'));
    });

    test('planName returns "No plan" when no subscriptions', () {
      const store = SAStore(id: 's2', name: 'S2');
      expect(store.planName, equals('No plan'));
    });

    test('subscriptionStatus returns "none" when no subscriptions', () {
      const store = SAStore(id: 's3', name: 'S3');
      expect(store.subscriptionStatus, equals('none'));
    });

    test('subscriptionStatus returns first subscription status', () {
      const store = SAStore(
        id: 's4',
        name: 'S4',
        subscriptions: [
          SAStoreSubscription(status: 'active'),
        ],
      );
      expect(store.subscriptionStatus, equals('active'));
    });
  });

  group('SAStoreSubscription.fromJson', () {
    test('parses plan from "plans" key (join query format)', () {
      final json = {
        'id': 'sub-1',
        'plan_id': 'plan-1',
        'status': 'active',
        'plans': {'id': 'plan-1', 'name': 'Basic', 'slug': 'basic'},
      };

      final sub = SAStoreSubscription.fromJson(json);
      expect(sub.plan?.name, equals('Basic'));
    });

    test('parses plan from "plan" key (alternative format)', () {
      final json = {
        'id': 'sub-2',
        'plan_id': 'plan-2',
        'status': 'trial',
        'plan': {'id': 'plan-2', 'name': 'Pro', 'slug': 'pro'},
      };

      final sub = SAStoreSubscription.fromJson(json);
      expect(sub.plan?.name, equals('Pro'));
    });
  });

  group('SAStoreUsageStats', () {
    test('fromJson with complete data', () {
      final stats = SAStoreUsageStats.fromJson({
        'transactions': 150,
        'products': 42,
        'employees': 5,
        'branches': 2,
      });

      expect(stats.transactions, equals(150));
      expect(stats.products, equals(42));
      expect(stats.employees, equals(5));
      expect(stats.branches, equals(2));
    });

    test('fromJson defaults missing keys to 0', () {
      final stats = SAStoreUsageStats.fromJson({});
      expect(stats.transactions, equals(0));
      expect(stats.products, equals(0));
    });
  });
}
