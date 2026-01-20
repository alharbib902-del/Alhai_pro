// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_forecast_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SalesForecastResponse _$SalesForecastResponseFromJson(
        Map<String, dynamic> json) =>
    SalesForecastResponse(
      date: json['date'] as String,
      predictedRevenue: (json['predictedRevenue'] as num).toDouble(),
      predictedOrders: (json['predictedOrders'] as num).toInt(),
      confidence: (json['confidence'] as num).toDouble(),
    );

Map<String, dynamic> _$SalesForecastResponseToJson(
        SalesForecastResponse instance) =>
    <String, dynamic>{
      'date': instance.date,
      'predictedRevenue': instance.predictedRevenue,
      'predictedOrders': instance.predictedOrders,
      'confidence': instance.confidence,
    };
