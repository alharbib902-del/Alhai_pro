/// مزودات توقع المبيعات - AI Sales Forecasting Providers
///
/// توفر حالة التوقعات والأنماط الموسمية وسيناريوهات "ماذا لو"
/// يدعم: API بعيد (أولوية) + خدمة محلية (احتياط)
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import 'package:alhai_database/alhai_database.dart';
import '../services/ai_api_service.dart';
import '../services/ai_sales_forecasting_service.dart';
import 'package:alhai_auth/alhai_auth.dart';

// ============================================================================
// SERVICE PROVIDER
// ============================================================================

/// مزود خدمة توقع المبيعات
final aiSalesForecastingServiceProvider =
    Provider<AiSalesForecastingService>((ref) {
  return AiSalesForecastingService(GetIt.instance<AppDatabase>());
});

// ============================================================================
// FORECAST STATE
// ============================================================================

/// مزود فترة التوقع المختارة
final selectedForecastPeriodProvider =
    StateProvider<ForecastPeriod>((ref) => ForecastPeriod.daily);

/// مزود نتيجة التوقع
final forecastResultProvider =
    FutureProvider.autoDispose<ForecastResult>((ref) async {
  final service = ref.read(aiSalesForecastingServiceProvider);
  final storeId = ref.read(currentStoreIdProvider)!;
  final period = ref.watch(selectedForecastPeriodProvider);
  return service.generateForecast(storeId, period);
});

/// مزود الأنماط الموسمية
final seasonalPatternsProvider =
    FutureProvider.autoDispose<List<SeasonalPattern>>((ref) async {
  final service = ref.read(aiSalesForecastingServiceProvider);
  final storeId = ref.read(currentStoreIdProvider)!;
  return service.detectSeasonalPatterns(storeId);
});

// ============================================================================
// WHAT-IF STATE
// ============================================================================

/// مزود نسبة الخصم في سيناريو "ماذا لو"
final whatIfDiscountProvider = StateProvider<double>((ref) => 0);

/// مزود نسبة تغيير السعر في سيناريو "ماذا لو"
final whatIfPriceChangeProvider = StateProvider<double>((ref) => 0);

/// مزود نتيجة "ماذا لو"
final whatIfResultProvider =
    FutureProvider.autoDispose<WhatIfResult>((ref) async {
  final service = ref.read(aiSalesForecastingServiceProvider);
  final storeId = ref.read(currentStoreIdProvider)!;
  final discount = ref.watch(whatIfDiscountProvider);
  final priceChange = ref.watch(whatIfPriceChangeProvider);

  return service.simulateWhatIf(
    storeId,
    WhatIfScenario(
      discountPercent: discount,
      priceChangePercent: priceChange,
    ),
  );
});

// ============================================================================
// REMOTE API PROVIDER - مزود API البعيد
// ============================================================================

/// مزود بيانات التوقع من خادم AI (مع احتياط محلي)
final forecastApiProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final api = ref.read(aiApiServiceProvider);
  final storeId = ref.read(currentStoreIdProvider)!;
  final period = ref.watch(selectedForecastPeriodProvider);
  final daysAhead = switch (period) {
    ForecastPeriod.daily => 14,
    ForecastPeriod.weekly => 28,
    ForecastPeriod.monthly => 60,
  };
  return api.getSalesForecast(
    orgId: 'default',
    storeId: storeId,
    daysAhead: daysAhead,
  );
});
