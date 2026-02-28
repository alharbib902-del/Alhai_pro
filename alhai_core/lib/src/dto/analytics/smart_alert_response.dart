import 'package:json_annotation/json_annotation.dart';
import '../../models/analytics.dart';

part 'smart_alert_response.g.dart';

/// Response DTO for smart alert
@JsonSerializable()
class SmartAlertResponse {
  final String id;
  final String type;
  final String title;
  final String message;
  final String? actionLabel;
  final String? actionRoute;
  final Map<String, dynamic>? metadata;
  final bool isRead;
  final String createdAt;

  const SmartAlertResponse({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.actionLabel,
    this.actionRoute,
    this.metadata,
    required this.isRead,
    required this.createdAt,
  });

  factory SmartAlertResponse.fromJson(Map<String, dynamic> json) =>
      _$SmartAlertResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SmartAlertResponseToJson(this);

  /// Converts to domain model
  SmartAlert toDomain() {
    return SmartAlert(
      id: id,
      type: AlertType.values.firstWhere(
        (e) => e.name == type,
        orElse: () => AlertType.lowStock,
      ),
      title: title,
      message: message,
      actionLabel: actionLabel,
      actionRoute: actionRoute,
      metadata: metadata,
      isRead: isRead,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
    );
  }
}
