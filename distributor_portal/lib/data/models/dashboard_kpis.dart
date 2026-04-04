/// Dashboard KPI and monthly sales models.
library;

import 'distributor_order.dart';

class DashboardKpis {
  final int totalOrders;
  final int pendingOrders;
  final int approvedOrders;
  final double totalRevenue;
  final List<MonthlySales> monthlySales;
  final List<DistributorOrder> recentOrders;

  const DashboardKpis({
    required this.totalOrders,
    required this.pendingOrders,
    required this.approvedOrders,
    required this.totalRevenue,
    required this.monthlySales,
    required this.recentOrders,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DashboardKpis &&
          runtimeType == other.runtimeType &&
          totalOrders == other.totalOrders &&
          pendingOrders == other.pendingOrders &&
          approvedOrders == other.approvedOrders &&
          totalRevenue == other.totalRevenue;

  @override
  int get hashCode =>
      Object.hash(totalOrders, pendingOrders, approvedOrders, totalRevenue);
}

class MonthlySales {
  final String month;
  final double amount;
  const MonthlySales(this.month, this.amount);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonthlySales &&
          month == other.month &&
          amount == other.amount;

  @override
  int get hashCode => Object.hash(month, amount);
}
