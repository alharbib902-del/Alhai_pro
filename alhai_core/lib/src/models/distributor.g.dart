// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'distributor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DistributorImpl _$$DistributorImplFromJson(Map<String, dynamic> json) =>
    _$DistributorImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      companyName: json['companyName'] as String,
      companyNameEn: json['companyNameEn'] as String?,
      commercialRegister: json['commercialRegister'] as String,
      vatNumber: json['vatNumber'] as String,
      logoUrl: json['logoUrl'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      website: json['website'] as String?,
      status: $enumDecodeNullable(_$DistributorStatusEnumMap, json['status']) ??
          DistributorStatus.pending,
      tier: $enumDecodeNullable(_$DistributorTierEnumMap, json['tier']) ??
          DistributorTier.free,
      totalProducts: (json['totalProducts'] as num?)?.toInt() ?? 0,
      totalOrders: (json['totalOrders'] as num?)?.toInt() ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      avgRating: (json['avgRating'] as num?)?.toDouble() ?? 0.0,
      ratingCount: (json['ratingCount'] as num?)?.toInt() ?? 0,
      isFeatured: json['isFeatured'] as bool? ?? false,
      approvedAt: json['approvedAt'] == null
          ? null
          : DateTime.parse(json['approvedAt'] as String),
      approvedBy: json['approvedBy'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$DistributorImplToJson(_$DistributorImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'companyName': instance.companyName,
      'companyNameEn': instance.companyNameEn,
      'commercialRegister': instance.commercialRegister,
      'vatNumber': instance.vatNumber,
      'logoUrl': instance.logoUrl,
      'address': instance.address,
      'city': instance.city,
      'phone': instance.phone,
      'email': instance.email,
      'website': instance.website,
      'status': _$DistributorStatusEnumMap[instance.status]!,
      'tier': _$DistributorTierEnumMap[instance.tier]!,
      'totalProducts': instance.totalProducts,
      'totalOrders': instance.totalOrders,
      'totalRevenue': instance.totalRevenue,
      'avgRating': instance.avgRating,
      'ratingCount': instance.ratingCount,
      'isFeatured': instance.isFeatured,
      'approvedAt': instance.approvedAt?.toIso8601String(),
      'approvedBy': instance.approvedBy,
      'rejectionReason': instance.rejectionReason,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$DistributorStatusEnumMap = {
  DistributorStatus.pending: 'PENDING',
  DistributorStatus.approved: 'APPROVED',
  DistributorStatus.suspended: 'SUSPENDED',
  DistributorStatus.rejected: 'REJECTED',
};

const _$DistributorTierEnumMap = {
  DistributorTier.free: 'FREE',
  DistributorTier.pro: 'PRO',
  DistributorTier.enterprise: 'ENTERPRISE',
};
