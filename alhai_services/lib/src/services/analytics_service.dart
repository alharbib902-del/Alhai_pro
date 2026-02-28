import 'package:alhai_core/alhai_core.dart';

/// خدمة التحليلات والذكاء الاصطناعي
/// تستخدم من: cashier, admin_pos
class AnalyticsService {
  final AnalyticsRepository _analyticsRepo;

  AnalyticsService(this._analyticsRepo);

  // ==================== المنتجات ====================

  /// الحصول على المنتجات بطيئة الحركة
  Future<List<SlowMovingProduct>> getSlowMovingProducts(
    String storeId, {
    int daysThreshold = 30,
    int limit = 20,
  }) async {
    return await _analyticsRepo.getSlowMovingProducts(
      storeId,
      daysThreshold: daysThreshold,
      limit: limit,
    );
  }

  /// الحصول على اقتراحات إعادة الطلب
  Future<List<ReorderSuggestion>> getReorderSuggestions(
    String storeId, {
    int daysAhead = 7,
  }) async {
    return await _analyticsRepo.getReorderSuggestions(
      storeId,
      daysAhead: daysAhead,
    );
  }

  // ==================== التوقعات ====================

  /// توقعات المبيعات
  Future<List<SalesForecast>> getSalesForecast(
    String storeId, {
    int days = 7,
  }) async {
    return await _analyticsRepo.getSalesForecast(storeId, days: days);
  }

  /// تحليل ساعات الذروة
  Future<PeakHoursAnalysis> getPeakHoursAnalysis(
    String storeId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _analyticsRepo.getPeakHoursAnalysis(
      storeId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  // ==================== العملاء ====================

  /// أنماط شراء العملاء
  Future<List<CustomerPattern>> getCustomerPatterns(
    String storeId, {
    int limit = 20,
  }) async {
    return await _analyticsRepo.getCustomerPatterns(storeId, limit: limit);
  }

  // ==================== التنبيهات الذكية ====================

  /// الحصول على التنبيهات الذكية
  Future<List<SmartAlert>> getSmartAlerts(
    String storeId, {
    bool unreadOnly = false,
    int limit = 50,
  }) async {
    return await _analyticsRepo.getSmartAlerts(
      storeId,
      unreadOnly: unreadOnly,
      limit: limit,
    );
  }

  /// تحديد تنبيه كمقروء
  Future<void> markAlertRead(String alertId) async {
    await _analyticsRepo.markAlertRead(alertId);
  }

  /// تحديد جميع التنبيهات كمقروءة
  Future<void> markAllAlertsRead(String storeId) async {
    await _analyticsRepo.markAllAlertsRead(storeId);
  }

  // ==================== لوحة التحكم ====================

  /// ملخص لوحة التحكم
  Future<DashboardSummary> getDashboardSummary(String storeId) async {
    return await _analyticsRepo.getDashboardSummary(storeId);
  }
}
