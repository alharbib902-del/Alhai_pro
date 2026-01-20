// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplier_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SupplierResponse _$SupplierResponseFromJson(Map<String, dynamic> json) =>
    SupplierResponse(
      id: json['id'] as String,
      storeId: json['storeId'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      notes: json['notes'] as String?,
      isActive: json['isActive'] as bool,
      balance: (json['balance'] as num).toDouble(),
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String?,
    );

Map<String, dynamic> _$SupplierResponseToJson(SupplierResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'storeId': instance.storeId,
      'name': instance.name,
      'phone': instance.phone,
      'email': instance.email,
      'address': instance.address,
      'notes': instance.notes,
      'isActive': instance.isActive,
      'balance': instance.balance,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
