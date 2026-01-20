import 'package:json_annotation/json_annotation.dart';
import '../../repositories/suppliers_repository.dart';

part 'update_supplier_request.g.dart';

/// Request DTO for updating a supplier
@JsonSerializable(includeIfNull: false)
class UpdateSupplierRequest {
  final String? name;
  final String? phone;
  final String? email;
  final String? address;
  final String? notes;
  final bool? isActive;

  const UpdateSupplierRequest({
    this.name,
    this.phone,
    this.email,
    this.address,
    this.notes,
    this.isActive,
  });

  factory UpdateSupplierRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateSupplierRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateSupplierRequestToJson(this);

  /// Creates from domain params
  factory UpdateSupplierRequest.fromDomain(UpdateSupplierParams params) {
    return UpdateSupplierRequest(
      name: params.name,
      phone: params.phone,
      email: params.email,
      address: params.address,
      notes: params.notes,
      isActive: params.isActive,
    );
  }
}
