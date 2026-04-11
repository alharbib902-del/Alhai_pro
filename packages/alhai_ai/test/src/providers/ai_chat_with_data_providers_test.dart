import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_ai/src/providers/ai_chat_with_data_providers.dart';
import 'package:alhai_ai/src/services/ai_chat_with_data_service.dart';
import 'package:alhai_auth/alhai_auth.dart';

void main() {
  group('currentQueryResultProvider', () {
    test('initial value is null', () {
      final container = ProviderContainer(
        overrides: [currentStoreIdProvider.overrideWith((ref) => 'test-store')],
      );
      addTearDown(container.dispose);

      expect(container.read(currentQueryResultProvider), isNull);
    });

    test('can be updated with a query result', () {
      final container = ProviderContainer(
        overrides: [currentStoreIdProvider.overrideWith((ref) => 'test-store')],
      );
      addTearDown(container.dispose);

      final result = QueryResult(
        query: DataQuery(
          id: 'Q-test',
          query: 'test query',
          timestamp: DateTime.now(),
          resultType: QueryResultType.number,
        ),
        resultType: QueryResultType.number,
        title: 'test title',
        singleValue: '42',
        executionTimeMs: 50,
      );
      container.read(currentQueryResultProvider.notifier).state = result;
      expect(container.read(currentQueryResultProvider), equals(result));
    });
  });

  group('isQueryLoadingProvider', () {
    test('initial value is false', () {
      final container = ProviderContainer(
        overrides: [currentStoreIdProvider.overrideWith((ref) => 'test-store')],
      );
      addTearDown(container.dispose);

      expect(container.read(isQueryLoadingProvider), isFalse);
    });

    test('can be updated to true', () {
      final container = ProviderContainer(
        overrides: [currentStoreIdProvider.overrideWith((ref) => 'test-store')],
      );
      addTearDown(container.dispose);

      container.read(isQueryLoadingProvider.notifier).state = true;
      expect(container.read(isQueryLoadingProvider), isTrue);
    });
  });

  group('queryHistoryProvider', () {
    test('initial value is empty list', () {
      final container = ProviderContainer(
        overrides: [currentStoreIdProvider.overrideWith((ref) => 'test-store')],
      );
      addTearDown(container.dispose);

      expect(container.read(queryHistoryProvider), isEmpty);
    });
  });

  group('suggestedQueriesProvider', () {
    test('returns non-empty list of suggestions', () {
      final container = ProviderContainer(
        overrides: [currentStoreIdProvider.overrideWith((ref) => 'test-store')],
      );
      addTearDown(container.dispose);

      final suggestions = container.read(suggestedQueriesProvider);
      expect(suggestions, isNotEmpty);
      expect(suggestions, isA<List<String>>());
    });
  });

  group('queryTextProvider', () {
    test('initial value is empty string', () {
      final container = ProviderContainer(
        overrides: [currentStoreIdProvider.overrideWith((ref) => 'test-store')],
      );
      addTearDown(container.dispose);

      expect(container.read(queryTextProvider), isEmpty);
    });

    test('can be updated', () {
      final container = ProviderContainer(
        overrides: [currentStoreIdProvider.overrideWith((ref) => 'test-store')],
      );
      addTearDown(container.dispose);

      container.read(queryTextProvider.notifier).state = 'sales today';
      expect(container.read(queryTextProvider), 'sales today');
    });
  });

  group('clearHistoryActionProvider', () {
    test('clears history and current result', () {
      final container = ProviderContainer(
        overrides: [currentStoreIdProvider.overrideWith((ref) => 'test-store')],
      );
      addTearDown(container.dispose);

      // Add some history
      final result = QueryResult(
        query: DataQuery(
          id: 'Q-test',
          query: 'test',
          timestamp: DateTime.now(),
          resultType: QueryResultType.number,
        ),
        resultType: QueryResultType.number,
        title: 'test title',
        executionTimeMs: 30,
      );
      container.read(queryHistoryProvider.notifier).state = [result];
      container.read(currentQueryResultProvider.notifier).state = result;

      // Clear
      container.read(clearHistoryActionProvider)();

      expect(container.read(queryHistoryProvider), isEmpty);
      expect(container.read(currentQueryResultProvider), isNull);
    });
  });
}
