// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_supplier_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateSupplierRequest _$CreateSupplierRequestFromJson(
        Map<String, dynamic> json) =>
    CreateSupplierRequest(
      storeId: json['storeId'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$CreateSupplierRequestToJson(
        CreateSupplierRequest instance) =>
    <String, dynamic>{
      'storeId': instance.storeId,
      'name': instance.name,
      'phone': instance.phone,
      'email': instance.email,
      'address': instance.address,
      'notes': instance.notes,
    };
