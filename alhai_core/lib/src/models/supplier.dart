import 'package:freezed_annotation/freezed_annotation.dart';

part 'supplier.freezed.dart';
part 'supplier.g.dart';

/// Supplier domain model
@freezed
class Supplier with _$Supplier {
  const Supplier._();

  const factory Supplier({
    required String id,
    required String storeId,
    required String name,
    String? phone,
    String? email,
    String? address,
    String? notes,
    @Default(0) double balance,
    @Default(true) bool isActive,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Supplier;

  factory Supplier.fromJson(Map<String, dynamic> json) =>
      _$SupplierFromJson(json);

  /// Check if supplier has outstanding balance
  bool get hasBalance => balance != 0;

  /// Check if supplier is owed money (positive balance)
  bool get isOwed => balance > 0;
}
