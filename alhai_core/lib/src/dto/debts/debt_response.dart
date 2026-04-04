import 'package:json_annotation/json_annotation.dart';
import '../../models/debt.dart';

part 'debt_response.g.dart';

/// Response DTO for debt from API
@JsonSerializable()
class DebtResponse {
  final String id;
  final String storeId;
  final String type;
  final String partyId;
  final String partyName;
  final String? partyPhone;
  final double originalAmount;
  final double remainingAmount;
  final String? orderId;
  final String? notes;
  final String? dueDate;
  final String createdAt;
  final String? updatedAt;

  const DebtResponse({
    required this.id,
    required this.storeId,
    required this.type,
    required this.partyId,
    required this.partyName,
    this.partyPhone,
    required this.originalAmount,
    required this.remainingAmount,
    this.orderId,
    this.notes,
    this.dueDate,
    required this.createdAt,
    this.updatedAt,
  });

  factory DebtResponse.fromJson(Map<String, dynamic> json) =>
      _$DebtResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DebtResponseToJson(this);

  /// Converts to domain model
  Debt toDomain() {
    return Debt(
      id: id,
      storeId: storeId,
      type: type == 'customer' || type == 'customerDebt'
          ? DebtType.customerDebt
          : DebtType.supplierDebt,
      partyId: partyId,
      partyName: partyName,
      partyPhone: partyPhone,
      originalAmount: originalAmount,
      remainingAmount: remainingAmount,
      orderId: orderId,
      notes: notes,
      dueDate: dueDate != null ? DateTime.tryParse(dueDate!) : null,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
      updatedAt: updatedAt != null ? DateTime.tryParse(updatedAt!) : null,
    );
  }
}
