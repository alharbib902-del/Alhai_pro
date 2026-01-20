import 'package:json_annotation/json_annotation.dart';
import '../../models/supplier.dart';

part 'supplier_response.g.dart';

/// Response DTO for supplier from API
@JsonSerializable()
class SupplierResponse {
  final String id;
  final String storeId;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final String? notes;
  final bool isActive;
  final double balance;
  final String createdAt;
  final String? updatedAt;

  const SupplierResponse({
    required this.id,
    required this.storeId,
    required this.name,
    this.phone,
    this.email,
    this.address,
    this.notes,
    required this.isActive,
    required this.balance,
    required this.createdAt,
    this.updatedAt,
  });

  factory SupplierResponse.fromJson(Map<String, dynamic> json) =>
      _$SupplierResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SupplierResponseToJson(this);

  /// Converts to domain model
  Supplier toDomain() {
    return Supplier(
      id: id,
      storeId: storeId,
      name: name,
      phone: phone,
      email: email,
      address: address,
      notes: notes,
      isActive: isActive,
      balance: balance,
      createdAt: DateTime.parse(createdAt),
      updatedAt: updatedAt != null ? DateTime.parse(updatedAt!) : null,
    );
  }
}
