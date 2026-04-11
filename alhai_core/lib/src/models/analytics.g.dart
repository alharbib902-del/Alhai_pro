// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SlowMovingProductImpl _$$SlowMovingProductImplFromJson(
  Map<String, dynamic> json,
) => _$SlowMovingProductImpl(
  productId: json['productId'] as String,
  productName: json['productName'] as String,
  categoryName: json['categoryName'] as String?,
  daysSinceLastSale: (json['daysSinceLastSale'] as num).toInt(),
  stockQty: (json['stockQty'] as num).toDouble(),
  stockValue: (json['stockValue'] as num).toDouble(),
  suggestedDiscount: (json['suggestedDiscount'] as num?)?.toDouble() ?? 0,
  lastSaleDate: json['lastSaleDate'] == null
      ? null
      : DateTime.parse(json['lastSaleDate'] as String),
);

Map<String, dynamic> _$$SlowMovingProductImplToJson(
  _$SlowMovingProductImpl instance,
) => <String, dynamic>{
  'productId': instance.productId,
  'productName': instance.productName,
  'categoryName': instance.categoryName,
  'daysSinceLastSale': instance.daysSinceLastSale,
  'stockQty': instance.stockQty,
  'stockValue': instance.stockValue,
  'suggestedDiscount': instance.suggestedDiscount,
  'lastSaleDate': instance.lastSaleDate?.toIso8601String(),
};

_$SalesForecastImpl _$$SalesForecastImplFromJson(Map<String, dynamic> json) =>
    _$SalesForecastImpl(
      date: DateTime.parse(json['date'] as String),
      predictedRevenue: (json['predictedRevenue'] as num).toDouble(),
      predictedOrders: (json['predictedOrders'] as num).toInt(),
      confidence: (json['confidence'] as num).toDouble(),
      lowerBound: (json['lowerBound'] as num?)?.toDouble(),
      upperBound: (json['upperBound'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$SalesForecastImplToJson(_$SalesForecastImpl instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'predictedRevenue': instance.predictedRevenue,
      'predictedOrders': instance.predictedOrders,
      'confidence': instance.confidence,
      'lowerBound': instance.lowerBound,
      'upperBound': instance.upperBound,
    };

_$SmartAlertImpl _$$SmartAlertImplFromJson(Map<String, dynamic> json) =>
    _$SmartAlertImpl(
      id: json['id'] as String,
      type: $enumDecode(_$AlertTypeEnumMap, json['type']),
      title: json['title'] as String,
      message: json['message'] as String,
      actionLabel: json['actionLabel'] as String?,
      actionRoute: json['actionRoute'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$SmartAlertImplToJson(_$SmartAlertImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$AlertTypeEnumMap[instance.type]!,
      'title': instance.title,
      'message': instance.message,
      'actionLabel': instance.actionLabel,
      'actionRoute': instance.actionRoute,
      'metadata': instance.metadata,
      'isRead': instance.isRead,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$AlertTypeEnumMap = {
  AlertType.lowStock: 'lowStock',
  AlertType.slowMoving: 'slowMoving',
  AlertType.expiringSoon: 'expiringSoon',
  AlertType.highDemand: 'highDemand',
  AlertType.debtOverdue: 'debtOverdue',
  AlertType.priceChange: 'priceChange',
  AlertType.reorderSuggestion: 'reorderSuggestion',
};

_$ReorderSuggestionImpl _$$ReorderSuggestionImplFromJson(
  Map<String, dynamic> json,
) => _$ReorderSuggestionImpl(
  productId: json['productId'] as String,
  productName: json['productName'] as String,
  currentStock: (json['currentStock'] as num).toInt(),
  suggestedQuantity: (json['suggestedQuantity'] as num).toInt(),
  averageDailySales: (json['averageDailySales'] as num).toDouble(),
  daysUntilStockout: (json['daysUntilStockout'] as num).toInt(),
  preferredSupplierId: json['preferredSupplierId'] as String?,
  preferredSupplierName: json['preferredSupplierName'] as String?,
);

Map<String, dynamic> _$$ReorderSuggestionImplToJson(
  _$ReorderSuggestionImpl instance,
) => <String, dynamic>{
  'productId': instance.productId,
  'productName': instance.productName,
  'currentStock': instance.currentStock,
  'suggestedQuantity': instance.suggestedQuantity,
  'averageDailySales': instance.averageDailySales,
  'daysUntilStockout': instance.daysUntilStockout,
  'preferredSupplierId': instance.preferredSupplierId,
  'preferredSupplierName': instance.preferredSupplierName,
};

_$PeakHoursAnalysisImpl _$$PeakHoursAnalysisImplFromJson(
  Map<String, dynamic> json,
) => _$PeakHoursAnalysisImpl(
  hourlyRevenue: (json['hourlyRevenue'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(int.parse(k), (e as num).toDouble()),
  ),
  hourlyOrders: (json['hourlyOrders'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(int.parse(k), (e as num).toInt()),
  ),
  peakHour: (json['peakHour'] as num).toInt(),
  slowestHour: (json['slowestHour'] as num).toInt(),
  peakHourRevenue: (json['peakHourRevenue'] as num).toDouble(),
);

Map<String, dynamic> _$$PeakHoursAnalysisImplToJson(
  _$PeakHoursAnalysisImpl instance,
) => <String, dynamic>{
  'hourlyRevenue': instance.hourlyRevenue.map(
    (k, e) => MapEntry(k.toString(), e),
  ),
  'hourlyOrders': instance.hourlyOrders.map(
    (k, e) => MapEntry(k.toString(), e),
  ),
  'peakHour': instance.peakHour,
  'slowestHour': instance.slowestHour,
  'peakHourRevenue': instance.peakHourRevenue,
};

_$CustomerPatternImpl _$$CustomerPatternImplFromJson(
  Map<String, dynamic> json,
) => _$CustomerPatternImpl(
  customerId: json['customerId'] as String,
  customerName: json['customerName'] as String,
  totalOrders: (json['totalOrders'] as num).toInt(),
  totalSpent: (json['totalSpent'] as num).toDouble(),
  averageOrderValue: (json['averageOrderValue'] as num).toDouble(),
  frequentProducts: (json['frequentProducts'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  daysSinceLastOrder: (json['daysSinceLastOrder'] as num).toInt(),
  lastOrderDate: json['lastOrderDate'] == null
      ? null
      : DateTime.parse(json['lastOrderDate'] as String),
);

Map<String, dynamic> _$$CustomerPatternImplToJson(
  _$CustomerPatternImpl instance,
) => <String, dynamic>{
  'customerId': instance.customerId,
  'customerName': instance.customerName,
  'totalOrders': instance.totalOrders,
  'totalSpent': instance.totalSpent,
  'averageOrderValue': instance.averageOrderValue,
  'frequentProducts': instance.frequentProducts,
  'daysSinceLastOrder': instance.daysSinceLastOrder,
  'lastOrderDate': instance.lastOrderDate?.toIso8601String(),
};
