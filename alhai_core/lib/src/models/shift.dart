import 'package:freezed_annotation/freezed_annotation.dart';

part 'shift.freezed.dart';
part 'shift.g.dart';

/// Shift status enum (v2.4.0)
enum ShiftStatus {
  open,
  closed,
}

/// Extension for ShiftStatus
extension ShiftStatusExt on ShiftStatus {
  String get displayNameAr {
    switch (this) {
      case ShiftStatus.open:
        return 'مفتوحة';
      case ShiftStatus.closed:
        return 'مغلقة';
    }
  }

  String get dbValue {
    switch (this) {
      case ShiftStatus.open:
        return 'open';
      case ShiftStatus.closed:
        return 'closed';
    }
  }

  static ShiftStatus fromDbValue(String value) {
    switch (value) {
      case 'open':
        return ShiftStatus.open;
      case 'closed':
        return ShiftStatus.closed;
      default:
        return ShiftStatus.open;
    }
  }
}

/// Shift domain model (v2.4.0)
/// Cashier shift management for POS
@freezed
class Shift with _$Shift {
  const Shift._();

  const factory Shift({
    required String id,
    required String storeId,
    required String cashierId,
    required double openingCash,
    double? closingCash,
    double? expectedCash,
    double? cashDifference,
    @Default(ShiftStatus.open) ShiftStatus status,
    required DateTime openedAt,
    DateTime? closedAt,
    String? notes,
  }) = _Shift;

  factory Shift.fromJson(Map<String, dynamic> json) => _$ShiftFromJson(json);

  /// Check if shift is open
  bool get isOpen => status == ShiftStatus.open;

  /// Check if shift is closed
  bool get isClosed => status == ShiftStatus.closed;

  /// Get shift duration
  Duration get duration {
    final endTime = closedAt ?? DateTime.now();
    return endTime.difference(openedAt);
  }

  /// Get formatted duration string
  String get durationFormatted {
    final d = duration;
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    return '$hoursس $minutesد';
  }

  /// Check if there's a cash shortage
  bool get hasShortage => cashDifference != null && cashDifference! < 0;

  /// Check if there's cash overage
  bool get hasOverage => cashDifference != null && cashDifference! > 0;

  /// Get cash status display in Arabic
  String get cashStatusAr {
    if (cashDifference == null) return '-';
    if (cashDifference == 0) return 'متطابق';
    if (cashDifference! > 0)
      return 'زيادة ${cashDifference!.abs().toStringAsFixed(2)}';
    return 'نقص ${cashDifference!.abs().toStringAsFixed(2)}';
  }
}
