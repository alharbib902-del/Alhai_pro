import 'package:json_annotation/json_annotation.dart';
import '../../models/debt.dart';
import '../../repositories/debts_repository.dart';

part 'create_debt_request.g.dart';

/// Request DTO for creating a debt
@JsonSerializable()
class CreateDebtRequest {
  final String storeId;
  final String type;
  final String partyId;
  final String partyName;
  final String? partyPhone;
  final double amount;
  final String? orderId;
  final String? notes;
  final String? dueDate;

  const CreateDebtRequest({
    required this.storeId,
    required this.type,
    required this.partyId,
    required this.partyName,
    this.partyPhone,
    required this.amount,
    this.orderId,
    this.notes,
    this.dueDate,
  });

  factory CreateDebtRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateDebtRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateDebtRequestToJson(this);

  /// Creates from domain params
  factory CreateDebtRequest.fromDomain(CreateDebtParams params) {
    return CreateDebtRequest(
      storeId: params.storeId,
      type: params.type == DebtType.customerDebt ? 'customer' : 'supplier',
      partyId: params.partyId,
      partyName: params.partyName,
      partyPhone: params.partyPhone,
      amount: params.amount,
      orderId: params.orderId,
      notes: params.notes,
      dueDate: params.dueDate?.toIso8601String(),
    );
  }
}
