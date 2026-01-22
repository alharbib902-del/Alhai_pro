import 'package:alhai_core/alhai_core.dart';

/// خدمة التقارير والتحليلات
/// متوافقة مع ReportsRepository من alhai_core
class ReportService {
  final ReportsRepository _reportsRepo;

  ReportService(this._reportsRepo);

  /// الحصول على ملخص المبيعات اليومية
  Future<SalesSummary> getDailySummary(String storeId, DateTime date) async {
    return await _reportsRepo.getDailySummary(storeId, date);
  }

  /// الحصول على ملخص المبيعات لفترة
  Future<List<SalesSummary>> getSalesSummaries(
    String storeId, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return await _reportsRepo.getSalesSummaries(
      storeId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// الحصول على المنتجات الأكثر مبيعاً
  Future<List<ProductSales>> getTopProducts(
    String storeId, {
    required DateTime startDate,
    required DateTime endDate,
    int limit = 10,
  }) async {
    return await _reportsRepo.getTopProducts(
      storeId,
      startDate: startDate,
      endDate: endDate,
      limit: limit,
    );
  }

  /// الحصول على المبيعات حسب الفئات
  Future<List<CategorySales>> getCategorySales(
    String storeId, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return await _reportsRepo.getCategorySales(
      storeId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// الحصول على قيمة المخزون
  Future<InventoryValue> getInventoryValue(String storeId) async {
    return await _reportsRepo.getInventoryValue(storeId);
  }

  /// الحصول على توزيع المبيعات على الساعات
  Future<Map<int, double>> getHourlySales(String storeId, DateTime date) async {
    return await _reportsRepo.getHourlySales(storeId, date);
  }

  /// الحصول على مقارنة شهرية
  Future<MonthlyComparison> getMonthlyComparison(
    String storeId, {
    required int year,
    required int month,
  }) async {
    return await _reportsRepo.getMonthlyComparison(
      storeId,
      year: year,
      month: month,
    );
  }

  /// الحصول على ملخص اليوم الحالي
  Future<SalesSummary> getTodaySummary(String storeId) async {
    return await getDailySummary(storeId, DateTime.now());
  }

  /// الحصول على ملخص الأسبوع الحالي
  Future<List<SalesSummary>> getWeeklySummary(String storeId) async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return await getSalesSummaries(
      storeId,
      startDate: startOfWeek,
      endDate: now,
    );
  }

  /// الحصول على ملخص الشهر الحالي
  Future<List<SalesSummary>> getMonthlySummary(String storeId) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    return await getSalesSummaries(
      storeId,
      startDate: startOfMonth,
      endDate: now,
    );
  }
}
