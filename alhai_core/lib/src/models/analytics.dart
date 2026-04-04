import 'package:freezed_annotation/freezed_annotation.dart';

part 'analytics.freezed.dart';
part 'analytics.g.dart';

/// Alert type for smart notifications
enum AlertType {
  /// Product stock is low
  lowStock,

  /// Product hasn't sold in a while
  slowMoving,

  /// Product expiring soon
  expiringSoon,

  /// Product has high demand
  highDemand,

  /// Customer debt overdue
  debtOverdue,

  /// Market price changed
  priceChange,

  /// Suggested reorder
  reorderSuggestion,
}

/// Extension for AlertType
extension AlertTypeExt on AlertType {
  String get displayNameAr {
    switch (this) {
      case AlertType.lowStock:
        return 'مخزون منخفض';
      case AlertType.slowMoving:
        return 'صنف راكد';
      case AlertType.expiringSoon:
        return 'قرب انتهاء الصلاحية';
      case AlertType.highDemand:
        return 'طلب عالي';
      case AlertType.debtOverdue:
        return 'دين متأخر';
      case AlertType.priceChange:
        return 'تغير سعر';
      case AlertType.reorderSuggestion:
        return 'اقتراح إعادة طلب';
    }
  }

  /// Priority level (1-5, 5 being highest)
  int get priority {
    switch (this) {
      case AlertType.expiringSoon:
        return 5;
      case AlertType.lowStock:
        return 4;
      case AlertType.highDemand:
        return 4;
      case AlertType.debtOverdue:
        return 3;
      case AlertType.slowMoving:
        return 2;
      case AlertType.priceChange:
        return 2;
      case AlertType.reorderSuggestion:
        return 1;
    }
  }
}

/// Slow moving product analysis
@freezed
class SlowMovingProduct with _$SlowMovingProduct {
  const SlowMovingProduct._();

  const factory SlowMovingProduct({
    required String productId,
    required String productName,
    String? categoryName,
    required int daysSinceLastSale,
    required double stockQty,
    required double stockValue,
    @Default(0) double suggestedDiscount,
    DateTime? lastSaleDate,
  }) = _SlowMovingProduct;

  factory SlowMovingProduct.fromJson(Map<String, dynamic> json) =>
      _$SlowMovingProductFromJson(json);

  /// Risk level based on days without sale
  String get riskLevel {
    if (daysSinceLastSale > 90) return 'عالي جداً';
    if (daysSinceLastSale > 60) return 'عالي';
    if (daysSinceLastSale > 30) return 'متوسط';
    return 'منخفض';
  }
}

/// Sales forecast using AI/ML predictions
@freezed
class SalesForecast with _$SalesForecast {
  const SalesForecast._();

  const factory SalesForecast({
    required DateTime date,
    required double predictedRevenue,
    required int predictedOrders,
    required double confidence,
    double? lowerBound,
    double? upperBound,
  }) = _SalesForecast;

  factory SalesForecast.fromJson(Map<String, dynamic> json) =>
      _$SalesForecastFromJson(json);

  /// Confidence level as text
  String get confidenceLevel {
    if (confidence >= 0.8) return 'عالي';
    if (confidence >= 0.6) return 'متوسط';
    return 'منخفض';
  }
}

/// Smart alert for proactive notifications
@freezed
class SmartAlert with _$SmartAlert {
  const SmartAlert._();

  const factory SmartAlert({
    required String id,
    required AlertType type,
    required String title,
    required String message,
    String? actionLabel,
    String? actionRoute,
    Map<String, dynamic>? metadata,
    @Default(false) bool isRead,
    required DateTime createdAt,
  }) = _SmartAlert;

  factory SmartAlert.fromJson(Map<String, dynamic> json) =>
      _$SmartAlertFromJson(json);

  /// Priority from type
  int get priority => type.priority;
}

/// Reorder suggestion for inventory management
@freezed
class ReorderSuggestion with _$ReorderSuggestion {
  const ReorderSuggestion._();

  const factory ReorderSuggestion({
    required String productId,
    required String productName,
    required int currentStock,
    required int suggestedQuantity,
    required double averageDailySales,
    required int daysUntilStockout,
    String? preferredSupplierId,
    String? preferredSupplierName,
  }) = _ReorderSuggestion;

  factory ReorderSuggestion.fromJson(Map<String, dynamic> json) =>
      _$ReorderSuggestionFromJson(json);

  /// Urgency level
  String get urgency {
    if (daysUntilStockout <= 3) return 'عاجل';
    if (daysUntilStockout <= 7) return 'مهم';
    return 'عادي';
  }
}

/// Peak hours analysis
@freezed
class PeakHoursAnalysis with _$PeakHoursAnalysis {
  const factory PeakHoursAnalysis({
    required Map<int, double> hourlyRevenue,
    required Map<int, int> hourlyOrders,
    required int peakHour,
    required int slowestHour,
    required double peakHourRevenue,
  }) = _PeakHoursAnalysis;

  factory PeakHoursAnalysis.fromJson(Map<String, dynamic> json) =>
      _$PeakHoursAnalysisFromJson(json);
}

/// Customer buying pattern
@freezed
class CustomerPattern with _$CustomerPattern {
  const factory CustomerPattern({
    required String customerId,
    required String customerName,
    required int totalOrders,
    required double totalSpent,
    required double averageOrderValue,
    required List<String> frequentProducts,
    required int daysSinceLastOrder,
    DateTime? lastOrderDate,
  }) = _CustomerPattern;

  factory CustomerPattern.fromJson(Map<String, dynamic> json) =>
      _$CustomerPatternFromJson(json);
}
