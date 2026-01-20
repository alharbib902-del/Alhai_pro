import 'package:json_annotation/json_annotation.dart';
import '../../models/debt.dart';
import '../../repositories/debts_repository.dart';

part 'debt_payment_response.g.dart';

/// Response DTO for debt payment
@JsonSerializable()
class DebtPaymentResponse {
  final String id;
  final String debtId;
  final double amount;
  final String? paymentMethod;
  final String? notes;
  final String createdAt;

  const DebtPaymentResponse({
    required this.id,
    required this.debtId,
    required this.amount,
    this.paymentMethod,
    this.notes,
    required this.createdAt,
  });

  factory DebtPaymentResponse.fromJson(Map<String, dynamic> json) =>
      _$DebtPaymentResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DebtPaymentResponseToJson(this);

  /// Converts to domain model
  DebtPayment toDomain() {
    return DebtPayment(
      id: id,
      debtId: debtId,
      amount: amount,
      paymentMethod: paymentMethod,
      notes: notes,
      createdAt: DateTime.parse(createdAt),
    );
  }
}

/// Request DTO for recording a payment
@JsonSerializable()
class RecordPaymentRequest {
  final String debtId;
  final double amount;
  final String? paymentMethod;
  final String? notes;

  const RecordPaymentRequest({
    required this.debtId,
    required this.amount,
    this.paymentMethod,
    this.notes,
  });

  factory RecordPaymentRequest.fromJson(Map<String, dynamic> json) =>
      _$RecordPaymentRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RecordPaymentRequestToJson(this);

  /// Creates from domain params
  factory RecordPaymentRequest.fromDomain(RecordPaymentParams params) {
    return RecordPaymentRequest(
      debtId: params.debtId,
      amount: params.amount,
      paymentMethod: params.paymentMethod,
      notes: params.notes,
    );
  }
}
