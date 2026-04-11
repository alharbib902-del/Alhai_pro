import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_ai/src/services/ai_sentiment_analysis_service.dart';

void main() {
  group('SentimentScore', () {
    test('has all values', () {
      expect(SentimentScore.values.length, 5);
    });
  });

  group('getKeywords', () {
    test('returns non-empty keyword list', () {
      final keywords = AiSentimentAnalysisService.getKeywords();
      expect(keywords, isNotEmpty);
    });

    test('keywords contain positive, negative and neutral', () {
      final keywords = AiSentimentAnalysisService.getKeywords();

      final positive = keywords
          .where((k) => k.sentiment == SentimentScore.positive)
          .toList();
      final negative = keywords
          .where((k) => k.sentiment == SentimentScore.negative)
          .toList();
      final neutral = keywords
          .where((k) => k.sentiment == SentimentScore.neutral)
          .toList();

      expect(positive, isNotEmpty);
      expect(negative, isNotEmpty);
      expect(neutral, isNotEmpty);
    });

    test('positive keywords have positive sentiment values', () {
      final keywords = AiSentimentAnalysisService.getKeywords();
      final positive = keywords
          .where((k) => k.sentiment == SentimentScore.positive)
          .toList();

      for (final k in positive) {
        expect(k.sentimentValue, greaterThan(0));
      }
    });

    test('negative keywords have negative sentiment values', () {
      final keywords = AiSentimentAnalysisService.getKeywords();
      final negative = keywords
          .where((k) => k.sentiment == SentimentScore.negative)
          .toList();

      for (final k in negative) {
        expect(k.sentimentValue, lessThan(0));
      }
    });

    test('keywords are sorted by count descending', () {
      final keywords = AiSentimentAnalysisService.getKeywords();

      for (int i = 0; i < keywords.length - 1; i++) {
        expect(keywords[i].count, greaterThanOrEqualTo(keywords[i + 1].count));
      }
    });

    test('each keyword has a non-empty word and positive count', () {
      final keywords = AiSentimentAnalysisService.getKeywords();

      for (final k in keywords) {
        expect(k.word, isNotEmpty);
        expect(k.count, greaterThan(0));
      }
    });
  });

  group('getFeedback', () {
    test('returns feedback list', () {
      final feedback = AiSentimentAnalysisService.getFeedback();
      expect(feedback, isNotEmpty);
      expect(feedback.length, 8);
    });

    test('each feedback has required fields', () {
      final feedback = AiSentimentAnalysisService.getFeedback();

      for (final f in feedback) {
        expect(f.id, isNotEmpty);
        expect(f.customerName, isNotEmpty);
        expect(f.text, isNotEmpty);
        expect(f.keywords, isNotEmpty);
      }
    });

    test('feedback contains all sentiment scores', () {
      final feedback = AiSentimentAnalysisService.getFeedback();
      final sentiments = feedback.map((f) => f.sentiment).toSet();

      expect(sentiments, contains(SentimentScore.veryPositive));
      expect(sentiments, contains(SentimentScore.positive));
      expect(sentiments, contains(SentimentScore.neutral));
      expect(sentiments, contains(SentimentScore.negative));
      expect(sentiments, contains(SentimentScore.veryNegative));
    });

    test('positive feedback has positive sentiment values', () {
      final feedback = AiSentimentAnalysisService.getFeedback();
      final positive = feedback
          .where(
            (f) =>
                f.sentiment == SentimentScore.positive ||
                f.sentiment == SentimentScore.veryPositive,
          )
          .toList();

      for (final f in positive) {
        expect(f.sentimentValue, greaterThan(0));
      }
    });

    test('negative feedback has negative sentiment values', () {
      final feedback = AiSentimentAnalysisService.getFeedback();
      final negative = feedback
          .where(
            (f) =>
                f.sentiment == SentimentScore.negative ||
                f.sentiment == SentimentScore.veryNegative,
          )
          .toList();

      for (final f in negative) {
        expect(f.sentimentValue, lessThan(0));
      }
    });

    test('ratings are between 1 and 5', () {
      final feedback = AiSentimentAnalysisService.getFeedback();

      for (final f in feedback) {
        if (f.rating != null) {
          expect(f.rating, greaterThanOrEqualTo(1));
          expect(f.rating, lessThanOrEqualTo(5));
        }
      }
    });
  });

  group('getTrend', () {
    test('returns trend data', () {
      final trend = AiSentimentAnalysisService.getTrend();
      expect(trend, isNotEmpty);
      expect(trend.length, 6);
    });

    test('percentages sum to approximately 100', () {
      final trend = AiSentimentAnalysisService.getTrend();

      for (final t in trend) {
        final total = t.positivePercent + t.neutralPercent + t.negativePercent;
        expect(total, closeTo(100, 1));
      }
    });

    test('each trend has positive total reviews', () {
      final trend = AiSentimentAnalysisService.getTrend();

      for (final t in trend) {
        expect(t.totalReviews, greaterThan(0));
        expect(t.period, isNotEmpty);
      }
    });
  });

  group('getAnalysisResult', () {
    test('returns complete analysis result', () {
      final result = AiSentimentAnalysisService.getAnalysisResult();

      expect(result.totalReviews, greaterThan(0));
      expect(result.keywords, isNotEmpty);
      expect(result.trend, isNotEmpty);
      expect(result.distribution, isNotEmpty);
    });

    test('distribution sums to total reviews', () {
      final result = AiSentimentAnalysisService.getAnalysisResult();

      final totalFromDist = result.distribution.values.fold<int>(
        0,
        (sum, c) => sum + c,
      );
      expect(totalFromDist, result.totalReviews);
    });

    test('satisfaction rate is between 0 and 100', () {
      final result = AiSentimentAnalysisService.getAnalysisResult();
      expect(result.satisfactionRate, greaterThanOrEqualTo(0));
      expect(result.satisfactionRate, lessThanOrEqualTo(100));
    });

    test('overall value is within sentiment range', () {
      final result = AiSentimentAnalysisService.getAnalysisResult();
      expect(result.overallValue, greaterThanOrEqualTo(-1));
      expect(result.overallValue, lessThanOrEqualTo(1));
    });
  });

  group('getSentimentLabel', () {
    test('returns correct label for each score', () {
      expect(
        AiSentimentAnalysisService.getSentimentLabel(
          SentimentScore.veryPositive,
        ),
        isNotEmpty,
      );
      expect(
        AiSentimentAnalysisService.getSentimentLabel(SentimentScore.positive),
        isNotEmpty,
      );
      expect(
        AiSentimentAnalysisService.getSentimentLabel(SentimentScore.neutral),
        isNotEmpty,
      );
      expect(
        AiSentimentAnalysisService.getSentimentLabel(SentimentScore.negative),
        isNotEmpty,
      );
      expect(
        AiSentimentAnalysisService.getSentimentLabel(
          SentimentScore.veryNegative,
        ),
        isNotEmpty,
      );
    });

    test('returns unique labels for different scores', () {
      final labels = SentimentScore.values
          .map((s) => AiSentimentAnalysisService.getSentimentLabel(s))
          .toSet();
      expect(labels.length, SentimentScore.values.length);
    });
  });

  group('positiveWords and negativeWords', () {
    test('positive words list is not empty', () {
      expect(AiSentimentAnalysisService.positiveWords, isNotEmpty);
    });

    test('negative words list is not empty', () {
      expect(AiSentimentAnalysisService.negativeWords, isNotEmpty);
    });

    test('no overlap between positive and negative words', () {
      final overlap = AiSentimentAnalysisService.positiveWords
          .where((w) => AiSentimentAnalysisService.negativeWords.contains(w))
          .toList();
      expect(overlap, isEmpty);
    });
  });
}
