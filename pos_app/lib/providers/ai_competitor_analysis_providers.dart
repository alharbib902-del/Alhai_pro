/// مزودات تحليل المنافسين - AI Competitor Analysis Providers
///
/// إدارة حالة بيانات المنافسين والمقارنات والتنبيهات
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ai_api_service.dart';
import '../services/ai_competitor_analysis_service.dart';
import 'products_providers.dart';

// ============================================================================
// PROVIDERS
// ============================================================================

/// مزود قائمة المنافسين
final competitorsProvider = Provider<List<Competitor>>((ref) {
  return AiCompetitorAnalysisService.mockCompetitors;
});

/// مزود مقارنات الأسعار
final priceComparisonsProvider = StateNotifierProvider<PriceComparisonsNotifier, AsyncValue<List<PriceComparison>>>((ref) {
  return PriceComparisonsNotifier();
});

/// مزود الموقع السوقي
final marketPositionProvider = Provider<MarketPosition>((ref) {
  return AiCompetitorAnalysisService.getMarketPosition();
});

/// مزود التنبيهات
final competitorAlertsProvider = StateNotifierProvider<CompetitorAlertsNotifier, List<CompetitorAlert>>((ref) {
  return CompetitorAlertsNotifier();
});

/// مزود ملخص التحليل
final competitorSummaryProvider = Provider<CompetitorAnalysisSummary>((ref) {
  return AiCompetitorAnalysisService.getSummary();
});

/// مزود الفلتر المحدد
final competitorFilterProvider = StateProvider<String>((ref) => 'الكل');

/// مزود ترتيب الجدول
final competitorSortProvider = StateProvider<CompetitorSortType>((ref) => CompetitorSortType.name);

/// نوع الترتيب
enum CompetitorSortType {
  name,
  priceDiff,
  ourPrice,
  category,
}

// ============================================================================
// NOTIFIERS
// ============================================================================

/// إدارة مقارنات الأسعار
class PriceComparisonsNotifier extends StateNotifier<AsyncValue<List<PriceComparison>>> {
  PriceComparisonsNotifier() : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    state = const AsyncValue.loading();
    await Future.delayed(const Duration(milliseconds: 500));
    state = AsyncValue.data(AiCompetitorAnalysisService.getPriceComparisons());
  }

  Future<void> refresh() async {
    await _load();
  }

  List<PriceComparison> filterByCategory(String category) {
    final data = state.valueOrNull ?? [];
    if (category == 'الكل') return data;
    return data.where((c) => c.category == category).toList();
  }

  List<PriceComparison> sortComparisons(List<PriceComparison> list, CompetitorSortType sort) {
    final sorted = List<PriceComparison>.from(list);
    switch (sort) {
      case CompetitorSortType.name:
        sorted.sort((a, b) => a.productName.compareTo(b.productName));
      case CompetitorSortType.priceDiff:
        sorted.sort((a, b) => a.priceDifferencePercent.compareTo(b.priceDifferencePercent));
      case CompetitorSortType.ourPrice:
        sorted.sort((a, b) => a.ourPrice.compareTo(b.ourPrice));
      case CompetitorSortType.category:
        sorted.sort((a, b) => a.category.compareTo(b.category));
    }
    return sorted;
  }
}

/// إدارة التنبيهات
class CompetitorAlertsNotifier extends StateNotifier<List<CompetitorAlert>> {
  CompetitorAlertsNotifier() : super(AiCompetitorAnalysisService.getAlerts());

  void markAsRead(String alertId) {
    state = state.map((a) {
      if (a.id == alertId) {
        return CompetitorAlert(
          id: a.id,
          competitorName: a.competitorName,
          productName: a.productName,
          alertType: a.alertType,
          message: a.message,
          oldPrice: a.oldPrice,
          newPrice: a.newPrice,
          changePercent: a.changePercent,
          timestamp: a.timestamp,
          isRead: true,
        );
      }
      return a;
    }).toList();
  }

  void markAllAsRead() {
    state = state.map((a) => CompetitorAlert(
      id: a.id,
      competitorName: a.competitorName,
      productName: a.productName,
      alertType: a.alertType,
      message: a.message,
      oldPrice: a.oldPrice,
      newPrice: a.newPrice,
      changePercent: a.changePercent,
      timestamp: a.timestamp,
      isRead: true,
    )).toList();
  }

  int get unreadCount => state.where((a) => !a.isRead).length;
}

// ============================================================================
// REMOTE API PROVIDER - مزود API البعيد
// ============================================================================

/// مزود بيانات تحليل المنافسين من خادم AI
final competitorApiProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final api = ref.read(aiApiServiceProvider);
  final storeId = ref.read(currentStoreIdProvider) ?? 'store_demo_001';
  return api.analyzeCompetitors(orgId: 'default', storeId: storeId);
});
