import 'package:mocktail/mocktail.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_reports/alhai_reports.dart';

// =============================================================================
// MOCK CLASSES
// =============================================================================

class MockSalesDao extends Mock implements SalesDao {}

class MockProductsDao extends Mock implements ProductsDao {}

class MockInventoryDao extends Mock implements InventoryDao {}

class MockLoyaltyDao extends Mock implements LoyaltyDao {}

class MockReportsService extends Mock implements ReportsService {}

// =============================================================================
// FALLBACK VALUES
// =============================================================================

void registerReportsFallbackValues() {
  registerFallbackValue(DateTime(2026, 1, 1));
  registerFallbackValue(ReportPeriod.today);
}

// =============================================================================
// FACTORY HELPERS
// =============================================================================

/// Create a test SalesStats
SalesStats createTestSalesStats({
  int count = 10,
  double total = 1000.0,
  double average = 100.0,
  double maxSale = 250.0,
  double minSale = 50.0,
}) {
  return SalesStats(
    count: count,
    total: total,
    average: average,
    maxSale: maxSale,
    minSale: minSale,
  );
}

/// Create a test SalesReport
SalesReport createTestSalesReport({
  DateRange? period,
  SalesStats? stats,
}) {
  return SalesReport(
    period: period ?? DateRange(DateTime(2026, 1, 1), DateTime(2026, 1, 2)),
    stats: stats ?? createTestSalesStats(),
  );
}

/// Create a test InventoryReport
InventoryReport createTestInventoryReport({
  int totalProducts = 100,
  int lowStockCount = 5,
  int outOfStockCount = 2,
  double totalValue = 50000.0,
}) {
  return InventoryReport(
    totalProducts: totalProducts,
    lowStockCount: lowStockCount,
    outOfStockCount: outOfStockCount,
    totalValue: totalValue,
  );
}

/// Create a test DashboardSummary
DashboardSummary createTestDashboardSummary({
  double todaySales = 5000.0,
  int todayTransactions = 50,
  double yesterdaySales = 4000.0,
  int lowStockCount = 3,
  int outOfStockCount = 1,
  int newCustomersToday = 5,
  int pointsEarnedToday = 100,
}) {
  return DashboardSummary(
    todaySales: todaySales,
    todayTransactions: todayTransactions,
    yesterdaySales: yesterdaySales,
    lowStockCount: lowStockCount,
    outOfStockCount: outOfStockCount,
    newCustomersToday: newCustomersToday,
    pointsEarnedToday: pointsEarnedToday,
  );
}
