import 'package:json_annotation/json_annotation.dart';
import '../../models/analytics.dart';

part 'sales_forecast_response.g.dart';

/// Response DTO for sales forecast
@JsonSerializable()
class SalesForecastResponse {
  final String date;
  final double predictedRevenue;
  final int predictedOrders;
  final double confidence;

  const SalesForecastResponse({
    required this.date,
    required this.predictedRevenue,
    required this.predictedOrders,
    required this.confidence,
  });

  factory SalesForecastResponse.fromJson(Map<String, dynamic> json) =>
      _$SalesForecastResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SalesForecastResponseToJson(this);

  /// Converts to domain model
  SalesForecast toDomain() {
    return SalesForecast(
      date: DateTime.tryParse(date) ?? DateTime.now(),
      predictedRevenue: predictedRevenue,
      predictedOrders: predictedOrders,
      confidence: confidence,
    );
  }
}
