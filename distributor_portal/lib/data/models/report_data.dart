/// Report data models (report summary, daily sales, top products).
library;

class ReportData {
  final double totalSales;
  final int orderCount;
  final double avgOrderValue;
  final String topProduct;
  final int topProductOrders;
  final List<DailySales> dailySales;
  final List<TopProduct> topProducts;

  const ReportData({
    required this.totalSales,
    required this.orderCount,
    required this.avgOrderValue,
    required this.topProduct,
    required this.topProductOrders,
    required this.dailySales,
    required this.topProducts,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportData &&
          runtimeType == other.runtimeType &&
          totalSales == other.totalSales &&
          orderCount == other.orderCount &&
          avgOrderValue == other.avgOrderValue &&
          topProduct == other.topProduct &&
          topProductOrders == other.topProductOrders;

  @override
  int get hashCode => Object.hash(
    totalSales,
    orderCount,
    avgOrderValue,
    topProduct,
    topProductOrders,
  );
}

class DailySales {
  final String day;
  final double amount;
  const DailySales(this.day, this.amount);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailySales && day == other.day && amount == other.amount;

  @override
  int get hashCode => Object.hash(day, amount);
}

class TopProduct {
  final String name;
  final int orderCount;
  final double revenue;
  const TopProduct(this.name, this.orderCount, this.revenue);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TopProduct &&
          name == other.name &&
          orderCount == other.orderCount &&
          revenue == other.revenue;

  @override
  int get hashCode => Object.hash(name, orderCount, revenue);
}
