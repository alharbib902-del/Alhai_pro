import 'package:json_annotation/json_annotation.dart';
import '../../repositories/suppliers_repository.dart';

part 'create_supplier_request.g.dart';

/// Request DTO for creating a supplier
@JsonSerializable()
class CreateSupplierRequest {
  final String storeId;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final String? notes;

  const CreateSupplierRequest({
    required this.storeId,
    required this.name,
    this.phone,
    this.email,
    this.address,
    this.notes,
  });

  factory CreateSupplierRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateSupplierRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateSupplierRequestToJson(this);

  /// Creates from domain params
  factory CreateSupplierRequest.fromDomain(CreateSupplierParams params) {
    return CreateSupplierRequest(
      storeId: params.storeId,
      name: params.name,
      phone: params.phone,
      email: params.email,
      address: params.address,
      notes: params.notes,
    );
  }
}
