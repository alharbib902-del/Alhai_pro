// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reorder_suggestion_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReorderSuggestionResponse _$ReorderSuggestionResponseFromJson(
        Map<String, dynamic> json) =>
    ReorderSuggestionResponse(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      currentStock: (json['currentStock'] as num).toInt(),
      suggestedQuantity: (json['suggestedQuantity'] as num).toInt(),
      averageDailySales: (json['averageDailySales'] as num).toDouble(),
      daysUntilStockout: (json['daysUntilStockout'] as num).toInt(),
      preferredSupplierId: json['preferredSupplierId'] as String?,
      preferredSupplierName: json['preferredSupplierName'] as String?,
    );

Map<String, dynamic> _$ReorderSuggestionResponseToJson(
        ReorderSuggestionResponse instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'productName': instance.productName,
      'currentStock': instance.currentStock,
      'suggestedQuantity': instance.suggestedQuantity,
      'averageDailySales': instance.averageDailySales,
      'daysUntilStockout': instance.daysUntilStockout,
      'preferredSupplierId': instance.preferredSupplierId,
      'preferredSupplierName': instance.preferredSupplierName,
    };
