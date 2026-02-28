import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:alhai_ai/src/services/ai_customer_recommendations_service.dart';
import '../helpers/ai_test_helpers.dart';

void main() {
  late AiCustomerRecommendationsService service;
  late MockAppDatabase mockDb;

  setUp(() {
    mockDb = createMockDatabase();
    service = AiCustomerRecommendationsService(mockDb);
  });

  group('CustomerSegment', () {
    test('has all values', () {
      expect(CustomerSegment.values.length, 5);
    });
  });

  group('getRecommendations', () {
    test('returns customer recommendations', () async {
      when(() => mockDb.salesDao).thenReturn(MockSalesDao());

      final recs = await service.getRecommendations('store-1');

      expect(recs, isNotEmpty);
      expect(recs.length, 6);
    });

    test('includes all customer segments', () async {
      when(() => mockDb.salesDao).thenReturn(MockSalesDao());

      final recs = await service.getRecommendations('store-1');
      final segments = recs.map((r) => r.segment).toSet();

      expect(segments, contains(CustomerSegment.vip));
      expect(segments, contains(CustomerSegment.regular));
      expect(segments, contains(CustomerSegment.atRisk));
      expect(segments, contains(CustomerSegment.lost));
      expect(segments, contains(CustomerSegment.newCustomer));
    });

    test('each recommendation has products', () async {
      when(() => mockDb.salesDao).thenReturn(MockSalesDao());

      final recs = await service.getRecommendations('store-1');

      for (final rec in recs) {
        expect(rec.products, isNotEmpty);
        expect(rec.customerName, isNotEmpty);
        expect(rec.customerId, isNotEmpty);
      }
    });

    test('VIP customers have higher spending', () async {
      when(() => mockDb.salesDao).thenReturn(MockSalesDao());

      final recs = await service.getRecommendations('store-1');

      final vips = recs.where((r) => r.segment == CustomerSegment.vip).toList();
      final newCustomers =
          recs.where((r) => r.segment == CustomerSegment.newCustomer).toList();

      if (vips.isNotEmpty && newCustomers.isNotEmpty) {
        final avgVipSpend =
            vips.map((v) => v.totalSpent).reduce((a, b) => a + b) / vips.length;
        final avgNewSpend =
            newCustomers.map((v) => v.totalSpent).reduce((a, b) => a + b) /
                newCustomers.length;
        expect(avgVipSpend, greaterThan(avgNewSpend));
      }
    });

    test('product recommendations have confidence scores', () async {
      when(() => mockDb.salesDao).thenReturn(MockSalesDao());

      final recs = await service.getRecommendations('store-1');

      for (final rec in recs) {
        for (final product in rec.products) {
          expect(product.confidence, greaterThan(0));
          expect(product.confidence, lessThanOrEqualTo(1));
        }
      }
    });
  });

  group('getRepurchaseReminders', () {
    test('returns reminders', () async {
      when(() => mockDb.salesDao).thenReturn(MockSalesDao());

      final reminders = await service.getRepurchaseReminders('store-1');

      expect(reminders, isNotEmpty);
      expect(reminders.length, 4);
    });

    test('overdue reminders have correct flag', () async {
      when(() => mockDb.salesDao).thenReturn(MockSalesDao());

      final reminders = await service.getRepurchaseReminders('store-1');

      final overdue = reminders.where((r) => r.isOverdue).toList();
      expect(overdue, isNotEmpty);

      for (final r in overdue) {
        expect(r.daysSinceLastPurchase, greaterThan(r.avgInterval));
      }
    });

    test('each reminder has customer info', () async {
      when(() => mockDb.salesDao).thenReturn(MockSalesDao());

      final reminders = await service.getRepurchaseReminders('store-1');

      for (final r in reminders) {
        expect(r.customerId, isNotEmpty);
        expect(r.customerName, isNotEmpty);
        expect(r.productName, isNotEmpty);
        expect(r.avgInterval, greaterThan(0));
      }
    });
  });

  group('segmentCustomers', () {
    test('returns segment results', () async {
      when(() => mockDb.salesDao).thenReturn(MockSalesDao());

      final segments = await service.segmentCustomers('store-1');

      expect(segments, isNotEmpty);
    });

    test('segments are sorted by total revenue descending', () async {
      when(() => mockDb.salesDao).thenReturn(MockSalesDao());

      final segments = await service.segmentCustomers('store-1');

      for (int i = 0; i < segments.length - 1; i++) {
        expect(segments[i].totalRevenue,
            greaterThanOrEqualTo(segments[i + 1].totalRevenue));
      }
    });

    test('each segment has correct count', () async {
      when(() => mockDb.salesDao).thenReturn(MockSalesDao());

      final segments = await service.segmentCustomers('store-1');

      for (final seg in segments) {
        expect(seg.count, seg.customers.length);
        expect(seg.avgSpend, greaterThan(0));
      }
    });
  });
}
