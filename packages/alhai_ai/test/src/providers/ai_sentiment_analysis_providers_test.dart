import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_ai/src/providers/ai_sentiment_analysis_providers.dart';
import 'package:alhai_ai/src/services/ai_sentiment_analysis_service.dart';

void main() {
  group('sentimentFilterProvider', () {
    test('initial value is null (show all)', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(sentimentFilterProvider), isNull);
    });

    test('can be updated to positive', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(sentimentFilterProvider.notifier).state =
          SentimentScore.positive;
      expect(
        container.read(sentimentFilterProvider),
        SentimentScore.positive,
      );
    });
  });

  group('sentimentPeriodProvider', () {
    test('initial value is this month in Arabic', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(sentimentPeriodProvider), 'هذا الشهر');
    });

    test('can be updated', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(sentimentPeriodProvider.notifier).state = 'هذا الأسبوع';
      expect(container.read(sentimentPeriodProvider), 'هذا الأسبوع');
    });
  });

  group('sentimentResultProvider', () {
    test('returns analysis result', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final result = container.read(sentimentResultProvider);
      expect(result, isA<SentimentResult>());
    });
  });

  group('sentimentKeywordsProvider', () {
    test('returns non-empty list of keywords', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final keywords = container.read(sentimentKeywordsProvider);
      expect(keywords, isNotEmpty);
      expect(keywords, isA<List<KeywordData>>());
    });
  });

  group('sentimentTrendProvider', () {
    test('returns trend data', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final trend = container.read(sentimentTrendProvider);
      expect(trend, isA<List<SentimentTrend>>());
    });
  });

  group('FeedbackNotifier', () {
    test('initial state has feedback entries', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final feedback = container.read(customerFeedbackProvider);
      expect(feedback, isNotEmpty);
    });

    test('filterBySentiment returns filtered list', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(customerFeedbackProvider.notifier);
      final positives = notifier.filterBySentiment(SentimentScore.positive);
      for (final item in positives) {
        expect(item.sentiment, SentimentScore.positive);
      }
    });

    test('filterBySentiment with null returns all', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(customerFeedbackProvider.notifier);
      final all = notifier.filterBySentiment(null);
      expect(all.length, container.read(customerFeedbackProvider).length);
    });

    test('sortByDate sorts descending by timestamp', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(customerFeedbackProvider.notifier);
      notifier.sortByDate();

      final feedback = container.read(customerFeedbackProvider);
      for (int i = 0; i < feedback.length - 1; i++) {
        expect(
          feedback[i].timestamp.isAfter(feedback[i + 1].timestamp) ||
              feedback[i].timestamp.isAtSameMomentAs(feedback[i + 1].timestamp),
          isTrue,
        );
      }
    });
  });
}
