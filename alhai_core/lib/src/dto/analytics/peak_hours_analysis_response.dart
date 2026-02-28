import 'package:json_annotation/json_annotation.dart';
import '../../models/analytics.dart';

part 'peak_hours_analysis_response.g.dart';

/// Response DTO for peak hours analysis
@JsonSerializable()
class PeakHoursAnalysisResponse {
  final Map<String, double> hourlyRevenue;
  final Map<String, int> hourlyOrders;
  final int peakHour;
  final int slowestHour;
  final double peakHourRevenue;

  const PeakHoursAnalysisResponse({
    required this.hourlyRevenue,
    required this.hourlyOrders,
    required this.peakHour,
    required this.slowestHour,
    required this.peakHourRevenue,
  });

  factory PeakHoursAnalysisResponse.fromJson(Map<String, dynamic> json) =>
      _$PeakHoursAnalysisResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PeakHoursAnalysisResponseToJson(this);

  /// Converts to domain model
  PeakHoursAnalysis toDomain() {
    return PeakHoursAnalysis(
      hourlyRevenue: hourlyRevenue.map((k, v) => MapEntry(int.tryParse(k) ?? 0, v)),
      hourlyOrders: hourlyOrders.map((k, v) => MapEntry(int.tryParse(k) ?? 0, v)),
      peakHour: peakHour,
      slowestHour: slowestHour,
      peakHourRevenue: peakHourRevenue,
    );
  }
}
