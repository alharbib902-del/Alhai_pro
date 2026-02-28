/// Reports Providers - مزودات التقارير
///
/// يوفر:
/// - تقارير المبيعات
/// - ملخص لوحة التحكم
/// - تقارير المخزون
/// - تقارير الولاء
library reports_providers;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/reports_service.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_auth/alhai_auth.dart';

// ============================================================================
// SERVICE PROVIDER
// ============================================================================

/// مزود خدمة التقارير
final reportsServiceProvider = Provider<ReportsService>((ref) {
  throw UnimplementedError('يجب تهيئة reportsServiceProvider في main.dart');
});

// ============================================================================
// PERIOD SELECTION
// ============================================================================

/// الفترة المحددة للتقارير
final selectedReportPeriodProvider = StateProvider<ReportPeriod>((ref) {
  return ReportPeriod.today;
});

/// فترة مخصصة
final customDateRangeProvider = StateProvider<DateRange?>((ref) {
  return null;
});

// ============================================================================
// SALES REPORTS
// ============================================================================

/// تقرير المبيعات للفترة المحددة
final salesReportProvider = FutureProvider<SalesReport?>((ref) async {
  final service = ref.watch(reportsServiceProvider);
  final user = ref.watch(currentUserProvider);
  final period = ref.watch(selectedReportPeriodProvider);
  final customRange = ref.watch(customDateRangeProvider);

  if (user?.storeId == null) return null;

  return service.getSalesReport(
    user!.storeId!,
    period: period,
    customRange: customRange,
  );
});

/// إحصائيات اليوم السريعة
final todayStatsProvider = FutureProvider<SalesStats?>((ref) async {
  final service = ref.watch(reportsServiceProvider);
  final user = ref.watch(currentUserProvider);

  if (user?.storeId == null) return null;

  return service.getTodayStats(user!.storeId!);
});

/// إحصائيات الكاشير اليوم
final cashierTodayStatsProvider = FutureProvider<SalesStats?>((ref) async {
  final service = ref.watch(reportsServiceProvider);
  final user = ref.watch(currentUserProvider);

  if (user?.storeId == null || user?.id == null) return null;

  return service.getTodayStats(user!.storeId!, cashierId: user.id);
});

// ============================================================================
// DASHBOARD
// ============================================================================

/// ملخص لوحة التحكم
final dashboardSummaryProvider = FutureProvider<DashboardSummary?>((ref) async {
  final service = ref.watch(reportsServiceProvider);
  final user = ref.watch(currentUserProvider);

  if (user?.storeId == null) return null;

  return service.getDashboardSummary(user!.storeId!);
});

/// مراقبة ملخص لوحة التحكم (تحديث كل 5 دقائق)
final dashboardAutoRefreshProvider = StreamProvider<DashboardSummary?>((ref) async* {
  final service = ref.watch(reportsServiceProvider);
  final user = ref.watch(currentUserProvider);

  if (user?.storeId == null) {
    yield null;
    return;
  }

  // تحديث فوري
  yield await service.getDashboardSummary(user!.storeId!);

  // تحديث كل 5 دقائق
  await for (final _ in Stream.periodic(const Duration(minutes: 5))) {
    yield await service.getDashboardSummary(user.storeId!);
  }
});

// ============================================================================
// INVENTORY REPORTS
// ============================================================================

/// تقرير المخزون
final inventoryReportProvider = FutureProvider<InventoryReport?>((ref) async {
  final service = ref.watch(reportsServiceProvider);
  final user = ref.watch(currentUserProvider);

  if (user?.storeId == null) return null;

  return service.getInventoryReport(user!.storeId!);
});

/// المنتجات منخفضة المخزون
final lowStockItemsProvider = FutureProvider<List<LowStockItem>>((ref) async {
  final report = await ref.watch(inventoryReportProvider.future);
  return report?.lowStockItems ?? [];
});

/// عدد المنتجات منخفضة المخزون
final lowStockCountProvider = Provider<int>((ref) {
  final report = ref.watch(inventoryReportProvider);
  return report.valueOrNull?.lowStockCount ?? 0;
});

/// عدد المنتجات النافدة
final outOfStockCountProvider = Provider<int>((ref) {
  final report = ref.watch(inventoryReportProvider);
  return report.valueOrNull?.outOfStockCount ?? 0;
});

// ============================================================================
// COMPARISON
// ============================================================================

/// مقارنة فترتين
final salesComparisonProvider = Provider<SalesComparison?>((ref) {
  final report = ref.watch(salesReportProvider);
  return report.valueOrNull?.comparison;
});

/// هل المبيعات تتحسن؟
final isSalesImprovingProvider = Provider<bool>((ref) {
  final comparison = ref.watch(salesComparisonProvider);
  return comparison?.isImproved ?? false;
});

// ============================================================================
// CHARTS DATA
// ============================================================================

/// بيانات الرسم البياني للمبيعات بالساعة
final hourlySalesChartProvider = Provider<List<HourlySales>>((ref) {
  final report = ref.watch(salesReportProvider);
  return report.valueOrNull?.hourlySales ?? [];
});

/// بيانات الرسم البياني للمبيعات اليومية
final dailySalesChartProvider = Provider<List<DailySales>>((ref) {
  final report = ref.watch(salesReportProvider);
  return report.valueOrNull?.dailySales ?? [];
});

/// بيانات طرق الدفع
final paymentMethodsChartProvider = Provider<List<PaymentMethodStats>>((ref) {
  final report = ref.watch(salesReportProvider);
  return report.valueOrNull?.paymentMethods ?? [];
});

/// أفضل المنتجات
final topProductsProvider = Provider<List<TopProduct>>((ref) {
  final report = ref.watch(salesReportProvider);
  return report.valueOrNull?.topProducts ?? [];
});

// ============================================================================
// EXPORT
// ============================================================================

/// حالة التصدير
class ReportExportState {
  final bool isExporting;
  final String? error;
  final String? exportPath;

  const ReportExportState({
    this.isExporting = false,
    this.error,
    this.exportPath,
  });

  ReportExportState copyWith({
    bool? isExporting,
    String? error,
    String? exportPath,
  }) {
    return ReportExportState(
      isExporting: isExporting ?? this.isExporting,
      error: error,
      exportPath: exportPath,
    );
  }
}

/// مزود حالة التصدير
final reportExportStateProvider = StateProvider<ReportExportState>((ref) {
  return const ReportExportState();
});
