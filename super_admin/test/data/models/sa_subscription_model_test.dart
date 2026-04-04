import 'package:flutter_test/flutter_test.dart';
import 'package:super_admin/data/models/sa_subscription_model.dart';

void main() {
  group('SASubscription.fromJson', () {
    test('parses complete data with nested stores/plans', () {
      // Arrange
      final json = {
        'id': 'sub-001',
        'status': 'active',
        'start_date': '2024-01-01',
        'end_date': '2024-12-31',
        'store_id': 'store-001',
        'amount': 199.0,
        'currency': 'SAR',
        'billing_cycle': 'monthly',
        'stores': {
          'id': 'store-001',
          'name': 'Grocery Plus',
        },
        'plans': {
          'slug': 'premium',
        },
      };

      // Act
      final sub = SASubscription.fromJson(json);

      // Assert
      expect(sub.id, equals('sub-001'));
      expect(sub.status, equals('active'));
      expect(sub.startDate, equals('2024-01-01'));
      expect(sub.endDate, equals('2024-12-31'));
      expect(sub.orgId, equals('store-001'));
      expect(sub.amount, equals(199.0));
      expect(sub.currency, equals('SAR'));
      expect(sub.billingCycle, equals('monthly'));
      expect(sub.store, isNotNull);
      expect(sub.store!.id, equals('store-001'));
      expect(sub.store!.name, equals('Grocery Plus'));
      expect(sub.planSlug, equals('premium'));
    });

    test('prefers start_date/end_date over current_period fields', () {
      final json = {
        'id': 'sub-002',
        'start_date': '2024-01-01',
        'end_date': '2024-12-31',
        'current_period_start': '2024-06-01',
        'current_period_end': '2024-06-30',
      };

      final sub = SASubscription.fromJson(json);

      expect(sub.startDate, equals('2024-01-01'));
      expect(sub.endDate, equals('2024-12-31'));
    });

    test('falls back to current_period_start/end when start_date missing', () {
      final json = {
        'id': 'sub-003',
        'current_period_start': '2024-06-01',
        'current_period_end': '2024-06-30',
      };

      final sub = SASubscription.fromJson(json);

      expect(sub.startDate, equals('2024-06-01'));
      expect(sub.endDate, equals('2024-06-30'));
    });

    test('prefers org_id over store_id', () {
      final json = {
        'id': 'sub-004',
        'org_id': 'org-001',
        'store_id': 'store-001',
      };

      final sub = SASubscription.fromJson(json);

      expect(sub.orgId, equals('org-001'));
    });

    test('falls back to store_id when org_id missing', () {
      final json = {
        'id': 'sub-005',
        'store_id': 'store-001',
      };

      final sub = SASubscription.fromJson(json);

      expect(sub.orgId, equals('store-001'));
    });

    test('prefers plan TEXT field over nested plans slug', () {
      final json = {
        'id': 'sub-006',
        'plan': 'enterprise',
        'plans': {'slug': 'basic'},
      };

      final sub = SASubscription.fromJson(json);

      expect(sub.planSlug, equals('enterprise'));
    });

    test('falls back to nested plans slug when plan field missing', () {
      final json = {
        'id': 'sub-007',
        'plans': {'slug': 'basic'},
      };

      final sub = SASubscription.fromJson(json);

      expect(sub.planSlug, equals('basic'));
    });

    test('handles missing/null fields gracefully', () {
      final json = <String, dynamic>{
        'id': null,
      };

      final sub = SASubscription.fromJson(json);

      expect(sub.id, equals(''));
      expect(sub.status, isNull);
      expect(sub.startDate, isNull);
      expect(sub.endDate, isNull);
      expect(sub.orgId, isNull);
      expect(sub.amount, isNull);
      expect(sub.currency, isNull);
      expect(sub.billingCycle, isNull);
      expect(sub.store, isNull);
      expect(sub.planSlug, isNull);
    });

    test('ignores stores when not a Map', () {
      final json = {
        'id': 'sub-008',
        'stores': 'not-a-map',
      };

      final sub = SASubscription.fromJson(json);

      expect(sub.store, isNull);
    });

    test('ignores plans when not a Map and no plan field', () {
      final json = {
        'id': 'sub-009',
        'plans': 42,
      };

      final sub = SASubscription.fromJson(json);

      expect(sub.planSlug, isNull);
    });

    test('parses amount from int (num coercion)', () {
      final json = {
        'id': 'sub-010',
        'amount': 100,
      };

      final sub = SASubscription.fromJson(json);

      expect(sub.amount, equals(100.0));
      expect(sub.amount, isA<double>());
    });
  });

  group('SASubscription.fromSupabase', () {
    test('parses actual Supabase schema fields', () {
      // Arrange
      final json = {
        'id': 'sub-sup-001',
        'status': 'active',
        'current_period_start': '2024-06-01T00:00:00Z',
        'current_period_end': '2024-06-30T23:59:59Z',
        'org_id': 'org-001',
        'amount': 299.0,
        'currency': 'SAR',
        'billing_cycle': 'monthly',
        'plan': 'premium_plus',
      };

      // Act
      final sub = SASubscription.fromSupabase(json);

      // Assert
      expect(sub.id, equals('sub-sup-001'));
      expect(sub.status, equals('active'));
      expect(sub.startDate, equals('2024-06-01T00:00:00Z'));
      expect(sub.endDate, equals('2024-06-30T23:59:59Z'));
      expect(sub.orgId, equals('org-001'));
      expect(sub.amount, equals(299.0));
      expect(sub.currency, equals('SAR'));
      expect(sub.billingCycle, equals('monthly'));
      expect(sub.planSlug, equals('premium_plus'));
      expect(sub.store, isNull);
    });

    test('creates store when storeName is provided', () {
      final json = {
        'id': 'sub-sup-002',
        'org_id': 'org-002',
        'plan': 'basic',
      };

      final sub = SASubscription.fromSupabase(json, storeName: 'My Store');

      expect(sub.store, isNotNull);
      expect(sub.store!.id, equals('org-002'));
      expect(sub.store!.name, equals('My Store'));
    });

    test('does not create store when storeName is null', () {
      final json = {
        'id': 'sub-sup-003',
        'org_id': 'org-003',
      };

      final sub = SASubscription.fromSupabase(json);

      expect(sub.store, isNull);
    });

    test('handles missing fields gracefully', () {
      final json = <String, dynamic>{
        'id': null,
      };

      final sub = SASubscription.fromSupabase(json);

      expect(sub.id, equals(''));
      expect(sub.status, isNull);
      expect(sub.startDate, isNull);
      expect(sub.endDate, isNull);
      expect(sub.orgId, isNull);
      expect(sub.amount, isNull);
      expect(sub.planSlug, isNull);
    });

    test(
        'store id defaults to empty string when org_id is null and storeName provided',
        () {
      final json = <String, dynamic>{
        'id': 'sub-sup-004',
        'org_id': null,
      };

      final sub = SASubscription.fromSupabase(json, storeName: 'Fallback');

      expect(sub.store, isNotNull);
      expect(sub.store!.id, equals(''));
      expect(sub.store!.name, equals('Fallback'));
    });
  });

  group('SASubscription.toJson', () {
    test('serializes all fields correctly', () {
      const sub = SASubscription(
        id: 'sub-json-001',
        status: 'active',
        startDate: '2024-01-01',
        endDate: '2024-12-31',
        orgId: 'org-001',
        planSlug: 'premium',
        amount: 199.0,
        currency: 'SAR',
        billingCycle: 'monthly',
      );

      final json = sub.toJson();

      expect(json['id'], equals('sub-json-001'));
      expect(json['status'], equals('active'));
      expect(json['current_period_start'], equals('2024-01-01'));
      expect(json['current_period_end'], equals('2024-12-31'));
      expect(json['org_id'], equals('org-001'));
      expect(json['plan'], equals('premium'));
      expect(json['amount'], equals(199.0));
      expect(json['currency'], equals('SAR'));
      expect(json['billing_cycle'], equals('monthly'));
    });

    test('serializes null fields as null', () {
      const sub = SASubscription(id: 'sub-json-002');

      final json = sub.toJson();

      expect(json['id'], equals('sub-json-002'));
      expect(json['status'], isNull);
      expect(json['current_period_start'], isNull);
      expect(json['current_period_end'], isNull);
      expect(json['org_id'], isNull);
      expect(json['plan'], isNull);
      expect(json['amount'], isNull);
      expect(json['currency'], isNull);
      expect(json['billing_cycle'], isNull);
    });

    test('round-trip: fromSupabase -> toJson -> fromJson preserves data', () {
      final original = SASubscription.fromSupabase({
        'id': 'sub-rt',
        'status': 'active',
        'current_period_start': '2024-06-01',
        'current_period_end': '2024-06-30',
        'org_id': 'org-rt',
        'plan': 'premium',
        'amount': 199.0,
        'currency': 'SAR',
        'billing_cycle': 'yearly',
      });

      final json = original.toJson();
      final restored = SASubscription.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.status, equals(original.status));
      expect(restored.startDate, equals(original.startDate));
      expect(restored.endDate, equals(original.endDate));
      expect(restored.orgId, equals(original.orgId));
      expect(restored.planSlug, equals(original.planSlug));
      expect(restored.amount, equals(original.amount));
      expect(restored.currency, equals(original.currency));
      expect(restored.billingCycle, equals(original.billingCycle));
    });
  });

  group('SASubscription convenience getters', () {
    test('storeName returns store name when available', () {
      const sub = SASubscription(
        id: 's1',
        store: SASubscriptionStore(id: 'store-1', name: 'My Store'),
      );
      expect(sub.storeName, equals('My Store'));
    });

    test('storeName returns "Unknown" when store is null', () {
      const sub = SASubscription(id: 's2');
      expect(sub.storeName, equals('Unknown'));
    });

    test('storeName returns "Unknown" when store name is null', () {
      const sub = SASubscription(
        id: 's3',
        store: SASubscriptionStore(id: 'store-3'),
      );
      expect(sub.storeName, equals('Unknown'));
    });

    test('planName replaces underscores with spaces', () {
      const sub = SASubscription(id: 'p1', planSlug: 'premium_plus');
      expect(sub.planName, equals('premium plus'));
    });

    test('planName returns "Unknown" when planSlug is null', () {
      const sub = SASubscription(id: 'p2');
      expect(sub.planName, equals('Unknown'));
    });

    test('planName handles slug with no underscores', () {
      const sub = SASubscription(id: 'p3', planSlug: 'basic');
      expect(sub.planName, equals('basic'));
    });

    test('monthlyPrice returns amount directly for monthly billing', () {
      const sub = SASubscription(
        id: 'mp1',
        amount: 199.0,
        billingCycle: 'monthly',
      );
      expect(sub.monthlyPrice, equals(199.0));
    });

    test('monthlyPrice divides by 12 for yearly billing', () {
      const sub = SASubscription(
        id: 'mp2',
        amount: 1200.0,
        billingCycle: 'yearly',
      );
      expect(sub.monthlyPrice, equals(100.0));
    });

    test('monthlyPrice returns amount when billingCycle is null', () {
      const sub = SASubscription(id: 'mp3', amount: 50.0);
      expect(sub.monthlyPrice, equals(50.0));
    });

    test('monthlyPrice returns 0 when amount is null', () {
      const sub = SASubscription(id: 'mp4', billingCycle: 'yearly');
      expect(sub.monthlyPrice, equals(0.0));
    });

    test('monthlyPrice returns amount for unknown billing cycle', () {
      const sub = SASubscription(
        id: 'mp5',
        amount: 75.0,
        billingCycle: 'quarterly',
      );
      expect(sub.monthlyPrice, equals(75.0));
    });
  });

  group('SASubscriptionStore', () {
    test('fromJson parses complete data', () {
      final json = {
        'id': 'store-001',
        'name': 'Grocery Plus',
      };

      final store = SASubscriptionStore.fromJson(json);

      expect(store.id, equals('store-001'));
      expect(store.name, equals('Grocery Plus'));
    });

    test('fromJson handles missing/null fields', () {
      final json = <String, dynamic>{
        'id': null,
      };

      final store = SASubscriptionStore.fromJson(json);

      expect(store.id, equals(''));
      expect(store.name, isNull);
    });

    test('toJson serializes all fields', () {
      const store = SASubscriptionStore(id: 'store-rt', name: 'RT Store');

      final json = store.toJson();

      expect(json['id'], equals('store-rt'));
      expect(json['name'], equals('RT Store'));
    });

    test('toJson round-trip preserves data', () {
      const original = SASubscriptionStore(id: 'store-rt', name: 'RT Store');

      final json = original.toJson();
      final restored = SASubscriptionStore.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.name, equals(original.name));
    });
  });

  group('SAPlan', () {
    test('fromJson parses complete data', () {
      final json = {
        'id': 'plan-001',
        'name': 'Premium',
        'slug': 'premium',
        'monthly_price': 199.0,
        'yearly_price': 1999.0,
        'max_branches': 5,
        'max_products': 10000,
        'max_users': 20,
        'features': ['pos', 'inventory', 'reports'],
        'created_at': '2024-01-01T00:00:00Z',
      };

      final plan = SAPlan.fromJson(json);

      expect(plan.id, equals('plan-001'));
      expect(plan.name, equals('Premium'));
      expect(plan.slug, equals('premium'));
      expect(plan.monthlyPrice, equals(199.0));
      expect(plan.yearlyPrice, equals(1999.0));
      expect(plan.maxBranches, equals(5));
      expect(plan.maxProducts, equals(10000));
      expect(plan.maxUsers, equals(20));
      expect(plan.features, equals(['pos', 'inventory', 'reports']));
      expect(plan.createdAt, equals('2024-01-01T00:00:00Z'));
    });

    test('fromJson handles missing/null fields', () {
      final json = <String, dynamic>{
        'id': null,
      };

      final plan = SAPlan.fromJson(json);

      expect(plan.id, equals(''));
      expect(plan.name, isNull);
      expect(plan.slug, isNull);
      expect(plan.monthlyPrice, isNull);
      expect(plan.yearlyPrice, isNull);
      expect(plan.maxBranches, isNull);
      expect(plan.maxProducts, isNull);
      expect(plan.maxUsers, isNull);
      expect(plan.features, isNull);
      expect(plan.createdAt, isNull);
    });

    test('fromJson coerces int prices to double', () {
      final json = {
        'id': 'plan-002',
        'monthly_price': 100,
        'yearly_price': 1000,
      };

      final plan = SAPlan.fromJson(json);

      expect(plan.monthlyPrice, equals(100.0));
      expect(plan.monthlyPrice, isA<double>());
      expect(plan.yearlyPrice, equals(1000.0));
      expect(plan.yearlyPrice, isA<double>());
    });

    test('fromJson converts non-string features to strings', () {
      final json = {
        'id': 'plan-003',
        'features': [1, true, 'text', null],
      };

      final plan = SAPlan.fromJson(json);

      expect(plan.features, equals(['1', 'true', 'text', 'null']));
    });

    test('toJson serializes all fields', () {
      const plan = SAPlan(
        id: 'plan-rt',
        name: 'Trial',
        slug: 'trial',
        monthlyPrice: 0.0,
        yearlyPrice: 0.0,
        maxBranches: 1,
        maxProducts: 100,
        maxUsers: 2,
        features: ['pos'],
        createdAt: '2024-03-01T00:00:00Z',
      );

      final json = plan.toJson();

      expect(json['id'], equals('plan-rt'));
      expect(json['name'], equals('Trial'));
      expect(json['slug'], equals('trial'));
      expect(json['monthly_price'], equals(0.0));
      expect(json['yearly_price'], equals(0.0));
      expect(json['max_branches'], equals(1));
      expect(json['max_products'], equals(100));
      expect(json['max_users'], equals(2));
      expect(json['features'], equals(['pos']));
      expect(json['created_at'], equals('2024-03-01T00:00:00Z'));
    });

    test('toJson round-trip preserves data', () {
      const original = SAPlan(
        id: 'plan-rt',
        name: 'Gold',
        slug: 'gold',
        monthlyPrice: 299.0,
        yearlyPrice: 2999.0,
        maxBranches: 10,
        maxProducts: 50000,
        maxUsers: 50,
        features: ['pos', 'inventory', 'analytics'],
        createdAt: '2024-01-01T00:00:00Z',
      );

      final json = original.toJson();
      final restored = SAPlan.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.name, equals(original.name));
      expect(restored.slug, equals(original.slug));
      expect(restored.monthlyPrice, equals(original.monthlyPrice));
      expect(restored.yearlyPrice, equals(original.yearlyPrice));
      expect(restored.maxBranches, equals(original.maxBranches));
      expect(restored.maxProducts, equals(original.maxProducts));
      expect(restored.maxUsers, equals(original.maxUsers));
      expect(restored.features, equals(original.features));
      expect(restored.createdAt, equals(original.createdAt));
    });
  });

  group('SABillingInvoice', () {
    test('fromJson parses complete data with nested stores/plans', () {
      final json = {
        'id': 'inv-001',
        'invoice_number': 'INV-2024-001',
        'amount': 199.0,
        'status': 'paid',
        'issued_at': '2024-06-01T00:00:00Z',
        'due_at': '2024-06-15T00:00:00Z',
        'stores': {
          'id': 'store-001',
          'name': 'Grocery Plus',
        },
        'plans': {
          'name': 'Premium',
          'slug': 'premium',
          'monthly_price': 199.0,
        },
      };

      final invoice = SABillingInvoice.fromJson(json);

      expect(invoice.id, equals('inv-001'));
      expect(invoice.invoiceNumber, equals('INV-2024-001'));
      expect(invoice.amount, equals(199.0));
      expect(invoice.status, equals('paid'));
      expect(invoice.issuedAt, equals('2024-06-01T00:00:00Z'));
      expect(invoice.dueAt, equals('2024-06-15T00:00:00Z'));
      expect(invoice.store, isNotNull);
      expect(invoice.store!.id, equals('store-001'));
      expect(invoice.store!.name, equals('Grocery Plus'));
      expect(invoice.plan, isNotNull);
      expect(invoice.plan!.name, equals('Premium'));
    });

    test('fromJson handles missing/null fields', () {
      final json = <String, dynamic>{
        'id': null,
      };

      final invoice = SABillingInvoice.fromJson(json);

      expect(invoice.id, equals(''));
      expect(invoice.invoiceNumber, isNull);
      expect(invoice.amount, isNull);
      expect(invoice.status, isNull);
      expect(invoice.issuedAt, isNull);
      expect(invoice.dueAt, isNull);
      expect(invoice.store, isNull);
      expect(invoice.plan, isNull);
    });

    test('fromJson ignores stores/plans when not a Map', () {
      final json = {
        'id': 'inv-002',
        'stores': 'not-a-map',
        'plans': 42,
      };

      final invoice = SABillingInvoice.fromJson(json);

      expect(invoice.store, isNull);
      expect(invoice.plan, isNull);
    });

    test('fromJson coerces int amount to double', () {
      final json = {
        'id': 'inv-003',
        'amount': 250,
      };

      final invoice = SABillingInvoice.fromJson(json);

      expect(invoice.amount, equals(250.0));
      expect(invoice.amount, isA<double>());
    });

    test('toJson serializes all fields including nested objects', () {
      final invoice = SABillingInvoice.fromJson({
        'id': 'inv-rt',
        'invoice_number': 'INV-RT-001',
        'amount': 99.0,
        'status': 'pending',
        'issued_at': '2024-07-01T00:00:00Z',
        'due_at': '2024-07-15T00:00:00Z',
        'stores': {'id': 'store-rt', 'name': 'RT Store'},
        'plans': {'name': 'Basic', 'slug': 'basic'},
      });

      final json = invoice.toJson();

      expect(json['id'], equals('inv-rt'));
      expect(json['invoice_number'], equals('INV-RT-001'));
      expect(json['amount'], equals(99.0));
      expect(json['status'], equals('pending'));
      expect(json['issued_at'], equals('2024-07-01T00:00:00Z'));
      expect(json['due_at'], equals('2024-07-15T00:00:00Z'));
      expect(json['stores'], isA<Map<String, dynamic>>());
      expect(json['stores']['name'], equals('RT Store'));
      expect(json['plans'], isA<Map<String, dynamic>>());
      expect(json['plans']['name'], equals('Basic'));
    });

    test('toJson serializes null nested objects as null', () {
      const invoice = SABillingInvoice(id: 'inv-null');

      final json = invoice.toJson();

      expect(json['stores'], isNull);
      expect(json['plans'], isNull);
    });

    test('storeName returns store name when available', () {
      final invoice = SABillingInvoice.fromJson({
        'id': 'inv-sn',
        'stores': {'id': 'store-sn', 'name': 'Named Store'},
      });
      expect(invoice.storeName, equals('Named Store'));
    });

    test('storeName returns "Unknown" when store is null', () {
      const invoice = SABillingInvoice(id: 'inv-sn2');
      expect(invoice.storeName, equals('Unknown'));
    });

    test('planName returns plan name when available', () {
      final invoice = SABillingInvoice.fromJson({
        'id': 'inv-pn',
        'plans': {'name': 'Gold', 'slug': 'gold'},
      });
      expect(invoice.planName, equals('Gold'));
    });

    test('planName returns "Unknown" when plan is null', () {
      const invoice = SABillingInvoice(id: 'inv-pn2');
      expect(invoice.planName, equals('Unknown'));
    });
  });
}
