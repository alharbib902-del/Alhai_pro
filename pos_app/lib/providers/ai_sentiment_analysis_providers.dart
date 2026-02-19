/// مزودات تحليل المشاعر - AI Sentiment Analysis Providers
///
/// إدارة حالة تحليل المشاعر والملاحظات والاتجاهات
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ai_sentiment_analysis_service.dart';

// ============================================================================
// PROVIDERS
// ============================================================================

/// مزود نتيجة التحليل
final sentimentResultProvider = Provider<SentimentResult>((ref) {
  return AiSentimentAnalysisService.getAnalysisResult();
});

/// مزود ملاحظات العملاء
final customerFeedbackProvider = StateNotifierProvider<FeedbackNotifier, List<CustomerFeedback>>((ref) {
  return FeedbackNotifier();
});

/// مزود الكلمات المفتاحية
final sentimentKeywordsProvider = Provider<List<KeywordData>>((ref) {
  return AiSentimentAnalysisService.getKeywords();
});

/// مزود الاتجاه
final sentimentTrendProvider = Provider<List<SentimentTrend>>((ref) {
  return AiSentimentAnalysisService.getTrend();
});

/// مزود فلتر المشاعر
final sentimentFilterProvider = StateProvider<SentimentScore?>((ref) => null);

/// مزود الفترة
final sentimentPeriodProvider = StateProvider<String>((ref) => 'هذا الشهر');

// ============================================================================
// NOTIFIERS
// ============================================================================

/// إدارة ملاحظات العملاء
class FeedbackNotifier extends StateNotifier<List<CustomerFeedback>> {
  FeedbackNotifier() : super(AiSentimentAnalysisService.getFeedback());

  List<CustomerFeedback> filterBySentiment(SentimentScore? sentiment) {
    if (sentiment == null) return state;
    return state.where((f) => f.sentiment == sentiment).toList();
  }

  void sortByDate() {
    state = [...state]..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  void sortByRating() {
    state = [...state]..sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
  }

  void sortBySentiment() {
    state = [...state]..sort((a, b) => b.sentimentValue.compareTo(a.sentimentValue));
  }
}
