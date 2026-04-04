import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_ai/src/services/ai_chat_with_data_service.dart';

void main() {
  late AiChatWithDataService service;

  setUp(() {
    service = AiChatWithDataService();
  });

  group('QueryResultType', () {
    test('has all values', () {
      expect(QueryResultType.values.length, 5);
    });
  });

  group('executeQuery', () {
    test('matches today sales query', () async {
      final result = await service.executeQuery('مبيعات اليوم', 'store-1');

      expect(result.resultType, QueryResultType.number);
      expect(result.singleValue, isNotNull);
      expect(result.singleUnit, isNotNull);
      expect(result.title, isNotEmpty);
    });

    test('matches top 10 products query', () async {
      final result = await service.executeQuery('أفضل 10 منتجات', 'store-1');

      expect(result.resultType, QueryResultType.table);
      expect(result.tableHeaders, isNotNull);
      expect(result.tableRows, isNotNull);
      expect(result.tableRows!.length, 10);
    });

    test('matches weekly sales query', () async {
      final result = await service.executeQuery('مبيعات الأسبوع', 'store-1');

      expect(result.resultType, QueryResultType.lineChart);
      expect(result.chartData, isNotNull);
      expect(result.chartData, isNotEmpty);
    });

    test('matches payment methods query', () async {
      final result = await service.executeQuery('توزيع طرق الدفع', 'store-1');

      expect(result.resultType, QueryResultType.pieChart);
      expect(result.chartData, isNotNull);
    });

    test('matches category comparison query', () async {
      final result = await service.executeQuery('مقارنة الأقسام', 'store-1');

      expect(result.resultType, QueryResultType.barChart);
      expect(result.chartData, isNotNull);
    });

    test('matches customer count query', () async {
      final result = await service.executeQuery('عدد العملاء', 'store-1');

      expect(result.resultType, QueryResultType.number);
    });

    test('matches average ticket query', () async {
      final result = await service.executeQuery('متوسط الفاتورة', 'store-1');

      expect(result.resultType, QueryResultType.number);
    });

    test('matches low stock query', () async {
      final result = await service.executeQuery('المخزون المنخفض', 'store-1');

      expect(result.resultType, QueryResultType.table);
      expect(result.tableHeaders, isNotNull);
      expect(result.tableRows, isNotNull);
    });

    test('matches monthly sales query', () async {
      final result = await service.executeQuery('مبيعات الشهر', 'store-1');

      expect(result.resultType, QueryResultType.lineChart);
    });

    test('matches peak hours query', () async {
      final result = await service.executeQuery('ساعات الذروة', 'store-1');

      expect(result.resultType, QueryResultType.barChart);
    });

    test('unrecognized query returns default number result', () async {
      final result = await service.executeQuery('xyz random query', 'store-1');

      expect(result.resultType, QueryResultType.number);
      expect(result.singleValue, '0');
    });

    test('each result has execution time', () async {
      final result = await service.executeQuery('مبيعات اليوم', 'store-1');
      expect(result.executionTimeMs, greaterThan(0));
    });

    test('each result has a DataQuery', () async {
      final result = await service.executeQuery('مبيعات اليوم', 'store-1');
      expect(result.query.id, isNotEmpty);
      expect(result.query.query, 'مبيعات اليوم');
      expect(result.query.timestamp, isNotNull);
    });
  });

  group('getQueryHistory', () {
    test('starts empty', () {
      expect(service.getQueryHistory(), isEmpty);
    });

    test('records queries', () async {
      await service.executeQuery('مبيعات اليوم', 'store-1');
      await service.executeQuery('عدد العملاء', 'store-1');

      final history = service.getQueryHistory();
      expect(history.length, 2);
    });

    test('most recent query is first', () async {
      await service.executeQuery('مبيعات اليوم', 'store-1');
      await service.executeQuery('عدد العملاء', 'store-1');

      final history = service.getQueryHistory();
      expect(history.first.query.query, 'عدد العملاء');
    });

    test('returned list is unmodifiable', () {
      final history = service.getQueryHistory();
      expect(
          () => history.add(
                QueryResult(
                  query: DataQuery(
                    id: 'test',
                    query: 'test',
                    timestamp: DateTime.now(),
                    resultType: QueryResultType.number,
                  ),
                  resultType: QueryResultType.number,
                  title: 'test',
                  executionTimeMs: 0,
                ),
              ),
          throwsUnsupportedError);
    });
  });

  group('clearHistory', () {
    test('clears all history', () async {
      await service.executeQuery('مبيعات اليوم', 'store-1');
      await service.executeQuery('عدد العملاء', 'store-1');

      service.clearHistory();
      expect(service.getQueryHistory(), isEmpty);
    });
  });

  group('getSuggestedQueries', () {
    test('returns suggestions', () {
      final suggestions = service.getSuggestedQueries();
      expect(suggestions, isNotEmpty);
      expect(suggestions.length, 10);
    });

    test('suggestions are non-empty strings', () {
      final suggestions = service.getSuggestedQueries();
      for (final s in suggestions) {
        expect(s, isNotEmpty);
      }
    });
  });
}
