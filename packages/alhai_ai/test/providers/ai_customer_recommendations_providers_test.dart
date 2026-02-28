import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_ai/src/services/ai_customer_recommendations_service.dart';
import 'package:alhai_ai/src/providers/ai_customer_recommendations_providers.dart';

void main() {
  group('segmentFilterProvider', () {
    test('initial value is null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(segmentFilterProvider), isNull);
    });

    test('can be set to VIP', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(segmentFilterProvider.notifier).state =
          CustomerSegment.vip;
      expect(container.read(segmentFilterProvider), CustomerSegment.vip);
    });

    test('can be set to atRisk', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(segmentFilterProvider.notifier).state =
          CustomerSegment.atRisk;
      expect(container.read(segmentFilterProvider), CustomerSegment.atRisk);
    });

    test('can be reset to null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(segmentFilterProvider.notifier).state =
          CustomerSegment.vip;
      container.read(segmentFilterProvider.notifier).state = null;
      expect(container.read(segmentFilterProvider), isNull);
    });
  });

  group('selectedCustomerProvider', () {
    test('initial value is null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(selectedCustomerProvider), isNull);
    });
  });

  group('filteredCustomerRecommendationsProvider', () {
    test('returns all recommendations when no filter', () {
      final now = DateTime.now();
      final recs = [
        CustomerRecommendation(
          customerId: 'c1',
          customerName: 'Test VIP',
          segment: CustomerSegment.vip,
          totalSpent: 5000,
          avgSpend: 250,
          visitCount: 20,
          lastVisit: now,
          products: const [],
        ),
        CustomerRecommendation(
          customerId: 'c2',
          customerName: 'Test Regular',
          segment: CustomerSegment.regular,
          totalSpent: 2000,
          avgSpend: 200,
          visitCount: 10,
          lastVisit: now,
          products: const [],
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          customerRecommendationsProvider
              .overrideWith((ref) async => recs),
        ],
      );
      addTearDown(container.dispose);

      container.read(customerRecommendationsProvider);

      final filtered =
          container.read(filteredCustomerRecommendationsProvider);
      filtered.whenData((data) {
        expect(data.length, 2);
      });
    });

    test('filters by segment when set', () {
      final now = DateTime.now();
      final recs = [
        CustomerRecommendation(
          customerId: 'c1',
          customerName: 'Test VIP',
          segment: CustomerSegment.vip,
          totalSpent: 5000,
          avgSpend: 250,
          visitCount: 20,
          lastVisit: now,
          products: const [],
        ),
        CustomerRecommendation(
          customerId: 'c2',
          customerName: 'Test Regular',
          segment: CustomerSegment.regular,
          totalSpent: 2000,
          avgSpend: 200,
          visitCount: 10,
          lastVisit: now,
          products: const [],
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          customerRecommendationsProvider
              .overrideWith((ref) async => recs),
        ],
      );
      addTearDown(container.dispose);

      container.read(segmentFilterProvider.notifier).state =
          CustomerSegment.vip;

      final filtered =
          container.read(filteredCustomerRecommendationsProvider);
      filtered.whenData((data) {
        expect(data.length, 1);
        expect(data.first.segment, CustomerSegment.vip);
      });
    });
  });
}
