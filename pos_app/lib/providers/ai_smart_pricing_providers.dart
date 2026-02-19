/// مزودات التسعير الذكي - AI Smart Pricing Providers
///
/// توفر حالة اقتراحات الأسعار وحاسبة التأثير ومرونة الطلب
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../data/local/app_database.dart';
import '../services/ai_smart_pricing_service.dart';
import 'products_providers.dart';

// ============================================================================
// SERVICE PROVIDER
// ============================================================================

/// مزود خدمة التسعير الذكي
final aiSmartPricingServiceProvider = Provider<AiSmartPricingService>((ref) {
  return AiSmartPricingService(GetIt.instance<AppDatabase>());
});

// ============================================================================
// PRICING STATE
// ============================================================================

/// مزود فلتر الأسعار
final priceFilterProvider =
    StateProvider<PriceFilterType>((ref) => PriceFilterType.all);

/// مزود اقتراحات الأسعار
final priceSuggestionsProvider =
    FutureProvider.autoDispose<List<PriceSuggestion>>((ref) async {
  final service = ref.read(aiSmartPricingServiceProvider);
  final storeId = ref.read(currentStoreIdProvider) ?? 'store_demo_001';
  final filter = ref.watch(priceFilterProvider);
  final suggestions = await service.getPriceSuggestions(storeId);

  switch (filter) {
    case PriceFilterType.all:
      return suggestions;
    case PriceFilterType.canIncrease:
      return suggestions.where((s) => s.isIncrease).toList();
    case PriceFilterType.shouldDecrease:
      return suggestions.where((s) => s.isDecrease).toList();
  }
});

/// مزود المنتج المحدد لعرض التفاصيل
final selectedPriceSuggestionProvider =
    StateProvider<PriceSuggestion?>((ref) => null);

/// مزود سعر الحاسبة (الـ slider)
final calculatorPriceProvider = StateProvider<double>((ref) {
  final selected = ref.watch(selectedPriceSuggestionProvider);
  return selected?.suggestedPrice ?? 0;
});

/// مزود حساب التأثير
final priceImpactProvider =
    FutureProvider.autoDispose<PriceImpact?>((ref) async {
  final selected = ref.watch(selectedPriceSuggestionProvider);
  if (selected == null) return null;

  final service = ref.read(aiSmartPricingServiceProvider);
  final newPrice = ref.watch(calculatorPriceProvider);

  return service.calculateImpact(selected.productId, newPrice);
});

/// مزود مرونة الطلب
final demandElasticityProvider =
    FutureProvider.autoDispose<DemandElasticity?>((ref) async {
  final selected = ref.watch(selectedPriceSuggestionProvider);
  if (selected == null) return null;

  final service = ref.read(aiSmartPricingServiceProvider);
  return service.getElasticity(selected.productId);
});

/// مزود خيارات التسعير الجماعي
final bulkPricingOptionsProvider =
    FutureProvider.autoDispose<List<BulkPricingOption>>((ref) async {
  final service = ref.read(aiSmartPricingServiceProvider);
  final storeId = ref.read(currentStoreIdProvider) ?? 'store_demo_001';
  return service.getBulkPricingOptions(storeId);
});
