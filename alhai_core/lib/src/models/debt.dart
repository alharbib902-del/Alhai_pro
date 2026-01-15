import 'package:freezed_annotation/freezed_annotation.dart';

part 'debt.freezed.dart';
part 'debt.g.dart';

/// Debt type
enum DebtType {
  /// Customer owes store (sale on credit)
  customerDebt,
  /// Store owes supplier
  supplierDebt,
}

/// Debt domain model
@freezed
class Debt with _$Debt {
  const Debt._();

  const factory Debt({
    required String id,
    required String storeId,
    required DebtType type,
    required String partyId,
    required String partyName,
    String? partyPhone,
    required double originalAmount,
    required double remainingAmount,
    String? orderId,
    String? notes,
    DateTime? dueDate,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Debt;

  factory Debt.fromJson(Map<String, dynamic> json) =>
      _$DebtFromJson(json);

  /// Amount paid so far
  double get paidAmount => originalAmount - remainingAmount;

  /// Check if fully paid
  bool get isFullyPaid => remainingAmount <= 0;

  /// Check if overdue
  bool get isOverdue =>
      dueDate != null && DateTime.now().isAfter(dueDate!) && !isFullyPaid;

  /// Payment progress (0.0 to 1.0)
  double get paymentProgress =>
      originalAmount > 0 ? paidAmount / originalAmount : 0;
}

/// Debt payment record
@freezed
class DebtPayment with _$DebtPayment {
  const factory DebtPayment({
    required String id,
    required String debtId,
    required double amount,
    String? notes,
    String? paymentMethod,
    required DateTime createdAt,
  }) = _DebtPayment;

  factory DebtPayment.fromJson(Map<String, dynamic> json) =>
      _$DebtPaymentFromJson(json);
}
