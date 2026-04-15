// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'loyalty_points.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LoyaltyPoints _$LoyaltyPointsFromJson(Map<String, dynamic> json) {
  return _LoyaltyPoints.fromJson(json);
}

/// @nodoc
mixin _$LoyaltyPoints {
  String get id => throw _privateConstructorUsedError;
  String get customerId => throw _privateConstructorUsedError;
  int get balance => throw _privateConstructorUsedError;
  LoyaltyTier get tier => throw _privateConstructorUsedError;
  int get earnedThisMonth => throw _privateConstructorUsedError;
  int get redeemedThisMonth => throw _privateConstructorUsedError;
  int get expiringPoints => throw _privateConstructorUsedError;
  DateTime? get expiryDate => throw _privateConstructorUsedError;
  int get currentStreak =>
      throw _privateConstructorUsedError; // Days ordering consecutively
  int get longestStreak => throw _privateConstructorUsedError;
  DateTime? get lastEarnedAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this LoyaltyPoints to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LoyaltyPoints
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LoyaltyPointsCopyWith<LoyaltyPoints> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoyaltyPointsCopyWith<$Res> {
  factory $LoyaltyPointsCopyWith(
          LoyaltyPoints value, $Res Function(LoyaltyPoints) then) =
      _$LoyaltyPointsCopyWithImpl<$Res, LoyaltyPoints>;
  @useResult
  $Res call(
      {String id,
      String customerId,
      int balance,
      LoyaltyTier tier,
      int earnedThisMonth,
      int redeemedThisMonth,
      int expiringPoints,
      DateTime? expiryDate,
      int currentStreak,
      int longestStreak,
      DateTime? lastEarnedAt,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$LoyaltyPointsCopyWithImpl<$Res, $Val extends LoyaltyPoints>
    implements $LoyaltyPointsCopyWith<$Res> {
  _$LoyaltyPointsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LoyaltyPoints
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? customerId = null,
    Object? balance = null,
    Object? tier = null,
    Object? earnedThisMonth = null,
    Object? redeemedThisMonth = null,
    Object? expiringPoints = null,
    Object? expiryDate = freezed,
    Object? currentStreak = null,
    Object? longestStreak = null,
    Object? lastEarnedAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      customerId: null == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String,
      balance: null == balance
          ? _value.balance
          : balance // ignore: cast_nullable_to_non_nullable
              as int,
      tier: null == tier
          ? _value.tier
          : tier // ignore: cast_nullable_to_non_nullable
              as LoyaltyTier,
      earnedThisMonth: null == earnedThisMonth
          ? _value.earnedThisMonth
          : earnedThisMonth // ignore: cast_nullable_to_non_nullable
              as int,
      redeemedThisMonth: null == redeemedThisMonth
          ? _value.redeemedThisMonth
          : redeemedThisMonth // ignore: cast_nullable_to_non_nullable
              as int,
      expiringPoints: null == expiringPoints
          ? _value.expiringPoints
          : expiringPoints // ignore: cast_nullable_to_non_nullable
              as int,
      expiryDate: freezed == expiryDate
          ? _value.expiryDate
          : expiryDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      longestStreak: null == longestStreak
          ? _value.longestStreak
          : longestStreak // ignore: cast_nullable_to_non_nullable
              as int,
      lastEarnedAt: freezed == lastEarnedAt
          ? _value.lastEarnedAt
          : lastEarnedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LoyaltyPointsImplCopyWith<$Res>
    implements $LoyaltyPointsCopyWith<$Res> {
  factory _$$LoyaltyPointsImplCopyWith(
          _$LoyaltyPointsImpl value, $Res Function(_$LoyaltyPointsImpl) then) =
      __$$LoyaltyPointsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String customerId,
      int balance,
      LoyaltyTier tier,
      int earnedThisMonth,
      int redeemedThisMonth,
      int expiringPoints,
      DateTime? expiryDate,
      int currentStreak,
      int longestStreak,
      DateTime? lastEarnedAt,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$LoyaltyPointsImplCopyWithImpl<$Res>
    extends _$LoyaltyPointsCopyWithImpl<$Res, _$LoyaltyPointsImpl>
    implements _$$LoyaltyPointsImplCopyWith<$Res> {
  __$$LoyaltyPointsImplCopyWithImpl(
      _$LoyaltyPointsImpl _value, $Res Function(_$LoyaltyPointsImpl) _then)
      : super(_value, _then);

  /// Create a copy of LoyaltyPoints
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? customerId = null,
    Object? balance = null,
    Object? tier = null,
    Object? earnedThisMonth = null,
    Object? redeemedThisMonth = null,
    Object? expiringPoints = null,
    Object? expiryDate = freezed,
    Object? currentStreak = null,
    Object? longestStreak = null,
    Object? lastEarnedAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$LoyaltyPointsImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      customerId: null == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String,
      balance: null == balance
          ? _value.balance
          : balance // ignore: cast_nullable_to_non_nullable
              as int,
      tier: null == tier
          ? _value.tier
          : tier // ignore: cast_nullable_to_non_nullable
              as LoyaltyTier,
      earnedThisMonth: null == earnedThisMonth
          ? _value.earnedThisMonth
          : earnedThisMonth // ignore: cast_nullable_to_non_nullable
              as int,
      redeemedThisMonth: null == redeemedThisMonth
          ? _value.redeemedThisMonth
          : redeemedThisMonth // ignore: cast_nullable_to_non_nullable
              as int,
      expiringPoints: null == expiringPoints
          ? _value.expiringPoints
          : expiringPoints // ignore: cast_nullable_to_non_nullable
              as int,
      expiryDate: freezed == expiryDate
          ? _value.expiryDate
          : expiryDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      longestStreak: null == longestStreak
          ? _value.longestStreak
          : longestStreak // ignore: cast_nullable_to_non_nullable
              as int,
      lastEarnedAt: freezed == lastEarnedAt
          ? _value.lastEarnedAt
          : lastEarnedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LoyaltyPointsImpl extends _LoyaltyPoints {
  const _$LoyaltyPointsImpl(
      {required this.id,
      required this.customerId,
      this.balance = 0,
      this.tier = LoyaltyTier.bronze,
      this.earnedThisMonth = 0,
      this.redeemedThisMonth = 0,
      this.expiringPoints = 0,
      this.expiryDate,
      this.currentStreak = 0,
      this.longestStreak = 0,
      this.lastEarnedAt,
      required this.createdAt,
      this.updatedAt})
      : super._();

  factory _$LoyaltyPointsImpl.fromJson(Map<String, dynamic> json) =>
      _$$LoyaltyPointsImplFromJson(json);

  @override
  final String id;
  @override
  final String customerId;
  @override
  @JsonKey()
  final int balance;
  @override
  @JsonKey()
  final LoyaltyTier tier;
  @override
  @JsonKey()
  final int earnedThisMonth;
  @override
  @JsonKey()
  final int redeemedThisMonth;
  @override
  @JsonKey()
  final int expiringPoints;
  @override
  final DateTime? expiryDate;
  @override
  @JsonKey()
  final int currentStreak;
// Days ordering consecutively
  @override
  @JsonKey()
  final int longestStreak;
  @override
  final DateTime? lastEarnedAt;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'LoyaltyPoints(id: $id, customerId: $customerId, balance: $balance, tier: $tier, earnedThisMonth: $earnedThisMonth, redeemedThisMonth: $redeemedThisMonth, expiringPoints: $expiringPoints, expiryDate: $expiryDate, currentStreak: $currentStreak, longestStreak: $longestStreak, lastEarnedAt: $lastEarnedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoyaltyPointsImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.balance, balance) || other.balance == balance) &&
            (identical(other.tier, tier) || other.tier == tier) &&
            (identical(other.earnedThisMonth, earnedThisMonth) ||
                other.earnedThisMonth == earnedThisMonth) &&
            (identical(other.redeemedThisMonth, redeemedThisMonth) ||
                other.redeemedThisMonth == redeemedThisMonth) &&
            (identical(other.expiringPoints, expiringPoints) ||
                other.expiringPoints == expiringPoints) &&
            (identical(other.expiryDate, expiryDate) ||
                other.expiryDate == expiryDate) &&
            (identical(other.currentStreak, currentStreak) ||
                other.currentStreak == currentStreak) &&
            (identical(other.longestStreak, longestStreak) ||
                other.longestStreak == longestStreak) &&
            (identical(other.lastEarnedAt, lastEarnedAt) ||
                other.lastEarnedAt == lastEarnedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      customerId,
      balance,
      tier,
      earnedThisMonth,
      redeemedThisMonth,
      expiringPoints,
      expiryDate,
      currentStreak,
      longestStreak,
      lastEarnedAt,
      createdAt,
      updatedAt);

  /// Create a copy of LoyaltyPoints
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoyaltyPointsImplCopyWith<_$LoyaltyPointsImpl> get copyWith =>
      __$$LoyaltyPointsImplCopyWithImpl<_$LoyaltyPointsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LoyaltyPointsImplToJson(
      this,
    );
  }
}

abstract class _LoyaltyPoints extends LoyaltyPoints {
  const factory _LoyaltyPoints(
      {required final String id,
      required final String customerId,
      final int balance,
      final LoyaltyTier tier,
      final int earnedThisMonth,
      final int redeemedThisMonth,
      final int expiringPoints,
      final DateTime? expiryDate,
      final int currentStreak,
      final int longestStreak,
      final DateTime? lastEarnedAt,
      required final DateTime createdAt,
      final DateTime? updatedAt}) = _$LoyaltyPointsImpl;
  const _LoyaltyPoints._() : super._();

  factory _LoyaltyPoints.fromJson(Map<String, dynamic> json) =
      _$LoyaltyPointsImpl.fromJson;

  @override
  String get id;
  @override
  String get customerId;
  @override
  int get balance;
  @override
  LoyaltyTier get tier;
  @override
  int get earnedThisMonth;
  @override
  int get redeemedThisMonth;
  @override
  int get expiringPoints;
  @override
  DateTime? get expiryDate;
  @override
  int get currentStreak; // Days ordering consecutively
  @override
  int get longestStreak;
  @override
  DateTime? get lastEarnedAt;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of LoyaltyPoints
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoyaltyPointsImplCopyWith<_$LoyaltyPointsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
