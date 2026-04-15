// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'peak_hours_analysis_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PeakHoursAnalysisResponse _$PeakHoursAnalysisResponseFromJson(
        Map<String, dynamic> json) =>
    PeakHoursAnalysisResponse(
      hourlyRevenue: (json['hourlyRevenue'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      hourlyOrders: Map<String, int>.from(json['hourlyOrders'] as Map),
      peakHour: (json['peakHour'] as num).toInt(),
      slowestHour: (json['slowestHour'] as num).toInt(),
      peakHourRevenue: (json['peakHourRevenue'] as num).toDouble(),
    );

Map<String, dynamic> _$PeakHoursAnalysisResponseToJson(
        PeakHoursAnalysisResponse instance) =>
    <String, dynamic>{
      'hourlyRevenue': instance.hourlyRevenue,
      'hourlyOrders': instance.hourlyOrders,
      'peakHour': instance.peakHour,
      'slowestHour': instance.slowestHour,
      'peakHourRevenue': instance.peakHourRevenue,
    };
