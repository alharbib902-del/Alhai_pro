// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_supplier_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateSupplierRequest _$UpdateSupplierRequestFromJson(
  Map<String, dynamic> json,
) => UpdateSupplierRequest(
  name: json['name'] as String?,
  phone: json['phone'] as String?,
  email: json['email'] as String?,
  address: json['address'] as String?,
  notes: json['notes'] as String?,
  isActive: json['isActive'] as bool?,
);

Map<String, dynamic> _$UpdateSupplierRequestToJson(
  UpdateSupplierRequest instance,
) => <String, dynamic>{
  if (instance.name case final value?) 'name': value,
  if (instance.phone case final value?) 'phone': value,
  if (instance.email case final value?) 'email': value,
  if (instance.address case final value?) 'address': value,
  if (instance.notes case final value?) 'notes': value,
  if (instance.isActive case final value?) 'isActive': value,
};
