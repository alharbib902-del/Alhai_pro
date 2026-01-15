// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loyalty_points.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LoyaltyPointsImpl _$$LoyaltyPointsImplFromJson(Map<String, dynamic> json) =>
    _$LoyaltyPointsImpl(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      balance: (json['balance'] as num?)?.toInt() ?? 0,
      tier: $enumDecodeNullable(_$LoyaltyTierEnumMap, json['tier']) ??
          LoyaltyTier.bronze,
      earnedThisMonth: (json['earnedThisMonth'] as num?)?.toInt() ?? 0,
      redeemedThisMonth: (json['redeemedThisMonth'] as num?)?.toInt() ?? 0,
      expiringPoints: (json['expiringPoints'] as num?)?.toInt() ?? 0,
      expiryDate: json['expiryDate'] == null
          ? null
          : DateTime.parse(json['expiryDate'] as String),
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
      lastEarnedAt: json['lastEarnedAt'] == null
          ? null
          : DateTime.parse(json['lastEarnedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$LoyaltyPointsImplToJson(_$LoyaltyPointsImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customerId': instance.customerId,
      'balance': instance.balance,
      'tier': _$LoyaltyTierEnumMap[instance.tier]!,
      'earnedThisMonth': instance.earnedThisMonth,
      'redeemedThisMonth': instance.redeemedThisMonth,
      'expiringPoints': instance.expiringPoints,
      'expiryDate': instance.expiryDate?.toIso8601String(),
      'currentStreak': instance.currentStreak,
      'longestStreak': instance.longestStreak,
      'lastEarnedAt': instance.lastEarnedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$LoyaltyTierEnumMap = {
  LoyaltyTier.bronze: 'bronze',
  LoyaltyTier.silver: 'silver',
  LoyaltyTier.gold: 'gold',
  LoyaltyTier.platinum: 'platinum',
};
