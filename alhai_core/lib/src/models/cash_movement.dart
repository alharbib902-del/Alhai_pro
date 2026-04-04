import 'package:freezed_annotation/freezed_annotation.dart';

part 'cash_movement.freezed.dart';
part 'cash_movement.g.dart';

/// Cash movement type enum (v2.5.0)
/// For tracking cash in/out during shifts
enum CashMovementType {
  @JsonValue('CASH_IN')
  cashIn,
  @JsonValue('CASH_OUT')
  cashOut,
}

/// Extension for CashMovementType
extension CashMovementTypeExt on CashMovementType {
  String get displayNameAr {
    switch (this) {
      case CashMovementType.cashIn:
        return 'إيداع';
      case CashMovementType.cashOut:
        return 'سحب';
    }
  }

  String get dbValue {
    switch (this) {
      case CashMovementType.cashIn:
        return 'CASH_IN';
      case CashMovementType.cashOut:
        return 'CASH_OUT';
    }
  }

  bool get isPositive => this == CashMovementType.cashIn;
}

/// Cash movement reason enum
enum CashMovementReason {
  @JsonValue('BANK_DEPOSIT')
  bankDeposit,
  @JsonValue('CHANGE_FUND')
  changeFund,
  @JsonValue('EXPENSE')
  expense,
  @JsonValue('SUPPLIER_PAYMENT')
  supplierPayment,
  @JsonValue('OTHER')
  other,
}

/// Extension for CashMovementReason
extension CashMovementReasonExt on CashMovementReason {
  String get displayNameAr {
    switch (this) {
      case CashMovementReason.bankDeposit:
        return 'إيداع بنكي';
      case CashMovementReason.changeFund:
        return 'صندوق فكة';
      case CashMovementReason.expense:
        return 'مصروف';
      case CashMovementReason.supplierPayment:
        return 'دفع مورد';
      case CashMovementReason.other:
        return 'أخرى';
    }
  }
}

/// CashMovement domain model (v2.5.0)
/// Tracks cash deposits and withdrawals during shifts
/// Referenced by: US-6.3 (Cash In/Out)
@freezed
class CashMovement with _$CashMovement {
  const CashMovement._();

  const factory CashMovement({
    required String id,
    required String shiftId,
    required String storeId,
    required String cashierId,
    required CashMovementType type,
    required double amount,
    required CashMovementReason reason,
    String? notes,
    String? supervisorId,
    String? supervisorPin,
    required DateTime createdAt,
  }) = _CashMovement;

  factory CashMovement.fromJson(Map<String, dynamic> json) =>
      _$CashMovementFromJson(json);

  /// Signed amount (positive for in, negative for out)
  double get signedAmount => type == CashMovementType.cashIn ? amount : -amount;

  /// Requires supervisor approval for cash out
  bool get requiresSupervisor =>
      type == CashMovementType.cashOut && amount > 100;

  /// Display amount with sign
  String get formattedAmount {
    final sign = type == CashMovementType.cashIn ? '+' : '-';
    return '$sign${amount.toStringAsFixed(2)} ر.س';
  }
}
