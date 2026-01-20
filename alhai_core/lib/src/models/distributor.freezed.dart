// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'distributor.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Distributor _$DistributorFromJson(Map<String, dynamic> json) {
  return _Distributor.fromJson(json);
}

/// @nodoc
mixin _$Distributor {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get companyName => throw _privateConstructorUsedError;
  String? get companyNameEn => throw _privateConstructorUsedError;
  String get commercialRegister => throw _privateConstructorUsedError;
  String get vatNumber => throw _privateConstructorUsedError;
  String? get logoUrl => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  String? get city => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get website => throw _privateConstructorUsedError;
  DistributorStatus get status => throw _privateConstructorUsedError;
  DistributorTier get tier => throw _privateConstructorUsedError;
  int get totalProducts => throw _privateConstructorUsedError;
  int get totalOrders => throw _privateConstructorUsedError;
  double get totalRevenue => throw _privateConstructorUsedError;
  double get avgRating => throw _privateConstructorUsedError;
  int get ratingCount => throw _privateConstructorUsedError;
  bool get isFeatured => throw _privateConstructorUsedError;
  DateTime? get approvedAt => throw _privateConstructorUsedError;
  String? get approvedBy => throw _privateConstructorUsedError;
  String? get rejectionReason => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Distributor to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Distributor
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DistributorCopyWith<Distributor> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DistributorCopyWith<$Res> {
  factory $DistributorCopyWith(
          Distributor value, $Res Function(Distributor) then) =
      _$DistributorCopyWithImpl<$Res, Distributor>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String companyName,
      String? companyNameEn,
      String commercialRegister,
      String vatNumber,
      String? logoUrl,
      String? address,
      String? city,
      String? phone,
      String? email,
      String? website,
      DistributorStatus status,
      DistributorTier tier,
      int totalProducts,
      int totalOrders,
      double totalRevenue,
      double avgRating,
      int ratingCount,
      bool isFeatured,
      DateTime? approvedAt,
      String? approvedBy,
      String? rejectionReason,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$DistributorCopyWithImpl<$Res, $Val extends Distributor>
    implements $DistributorCopyWith<$Res> {
  _$DistributorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Distributor
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? companyName = null,
    Object? companyNameEn = freezed,
    Object? commercialRegister = null,
    Object? vatNumber = null,
    Object? logoUrl = freezed,
    Object? address = freezed,
    Object? city = freezed,
    Object? phone = freezed,
    Object? email = freezed,
    Object? website = freezed,
    Object? status = null,
    Object? tier = null,
    Object? totalProducts = null,
    Object? totalOrders = null,
    Object? totalRevenue = null,
    Object? avgRating = null,
    Object? ratingCount = null,
    Object? isFeatured = null,
    Object? approvedAt = freezed,
    Object? approvedBy = freezed,
    Object? rejectionReason = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      companyName: null == companyName
          ? _value.companyName
          : companyName // ignore: cast_nullable_to_non_nullable
              as String,
      companyNameEn: freezed == companyNameEn
          ? _value.companyNameEn
          : companyNameEn // ignore: cast_nullable_to_non_nullable
              as String?,
      commercialRegister: null == commercialRegister
          ? _value.commercialRegister
          : commercialRegister // ignore: cast_nullable_to_non_nullable
              as String,
      vatNumber: null == vatNumber
          ? _value.vatNumber
          : vatNumber // ignore: cast_nullable_to_non_nullable
              as String,
      logoUrl: freezed == logoUrl
          ? _value.logoUrl
          : logoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      website: freezed == website
          ? _value.website
          : website // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as DistributorStatus,
      tier: null == tier
          ? _value.tier
          : tier // ignore: cast_nullable_to_non_nullable
              as DistributorTier,
      totalProducts: null == totalProducts
          ? _value.totalProducts
          : totalProducts // ignore: cast_nullable_to_non_nullable
              as int,
      totalOrders: null == totalOrders
          ? _value.totalOrders
          : totalOrders // ignore: cast_nullable_to_non_nullable
              as int,
      totalRevenue: null == totalRevenue
          ? _value.totalRevenue
          : totalRevenue // ignore: cast_nullable_to_non_nullable
              as double,
      avgRating: null == avgRating
          ? _value.avgRating
          : avgRating // ignore: cast_nullable_to_non_nullable
              as double,
      ratingCount: null == ratingCount
          ? _value.ratingCount
          : ratingCount // ignore: cast_nullable_to_non_nullable
              as int,
      isFeatured: null == isFeatured
          ? _value.isFeatured
          : isFeatured // ignore: cast_nullable_to_non_nullable
              as bool,
      approvedAt: freezed == approvedAt
          ? _value.approvedAt
          : approvedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      approvedBy: freezed == approvedBy
          ? _value.approvedBy
          : approvedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      rejectionReason: freezed == rejectionReason
          ? _value.rejectionReason
          : rejectionReason // ignore: cast_nullable_to_non_nullable
              as String?,
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
abstract class _$$DistributorImplCopyWith<$Res>
    implements $DistributorCopyWith<$Res> {
  factory _$$DistributorImplCopyWith(
          _$DistributorImpl value, $Res Function(_$DistributorImpl) then) =
      __$$DistributorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String companyName,
      String? companyNameEn,
      String commercialRegister,
      String vatNumber,
      String? logoUrl,
      String? address,
      String? city,
      String? phone,
      String? email,
      String? website,
      DistributorStatus status,
      DistributorTier tier,
      int totalProducts,
      int totalOrders,
      double totalRevenue,
      double avgRating,
      int ratingCount,
      bool isFeatured,
      DateTime? approvedAt,
      String? approvedBy,
      String? rejectionReason,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$DistributorImplCopyWithImpl<$Res>
    extends _$DistributorCopyWithImpl<$Res, _$DistributorImpl>
    implements _$$DistributorImplCopyWith<$Res> {
  __$$DistributorImplCopyWithImpl(
      _$DistributorImpl _value, $Res Function(_$DistributorImpl) _then)
      : super(_value, _then);

  /// Create a copy of Distributor
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? companyName = null,
    Object? companyNameEn = freezed,
    Object? commercialRegister = null,
    Object? vatNumber = null,
    Object? logoUrl = freezed,
    Object? address = freezed,
    Object? city = freezed,
    Object? phone = freezed,
    Object? email = freezed,
    Object? website = freezed,
    Object? status = null,
    Object? tier = null,
    Object? totalProducts = null,
    Object? totalOrders = null,
    Object? totalRevenue = null,
    Object? avgRating = null,
    Object? ratingCount = null,
    Object? isFeatured = null,
    Object? approvedAt = freezed,
    Object? approvedBy = freezed,
    Object? rejectionReason = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$DistributorImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      companyName: null == companyName
          ? _value.companyName
          : companyName // ignore: cast_nullable_to_non_nullable
              as String,
      companyNameEn: freezed == companyNameEn
          ? _value.companyNameEn
          : companyNameEn // ignore: cast_nullable_to_non_nullable
              as String?,
      commercialRegister: null == commercialRegister
          ? _value.commercialRegister
          : commercialRegister // ignore: cast_nullable_to_non_nullable
              as String,
      vatNumber: null == vatNumber
          ? _value.vatNumber
          : vatNumber // ignore: cast_nullable_to_non_nullable
              as String,
      logoUrl: freezed == logoUrl
          ? _value.logoUrl
          : logoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      website: freezed == website
          ? _value.website
          : website // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as DistributorStatus,
      tier: null == tier
          ? _value.tier
          : tier // ignore: cast_nullable_to_non_nullable
              as DistributorTier,
      totalProducts: null == totalProducts
          ? _value.totalProducts
          : totalProducts // ignore: cast_nullable_to_non_nullable
              as int,
      totalOrders: null == totalOrders
          ? _value.totalOrders
          : totalOrders // ignore: cast_nullable_to_non_nullable
              as int,
      totalRevenue: null == totalRevenue
          ? _value.totalRevenue
          : totalRevenue // ignore: cast_nullable_to_non_nullable
              as double,
      avgRating: null == avgRating
          ? _value.avgRating
          : avgRating // ignore: cast_nullable_to_non_nullable
              as double,
      ratingCount: null == ratingCount
          ? _value.ratingCount
          : ratingCount // ignore: cast_nullable_to_non_nullable
              as int,
      isFeatured: null == isFeatured
          ? _value.isFeatured
          : isFeatured // ignore: cast_nullable_to_non_nullable
              as bool,
      approvedAt: freezed == approvedAt
          ? _value.approvedAt
          : approvedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      approvedBy: freezed == approvedBy
          ? _value.approvedBy
          : approvedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      rejectionReason: freezed == rejectionReason
          ? _value.rejectionReason
          : rejectionReason // ignore: cast_nullable_to_non_nullable
              as String?,
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
class _$DistributorImpl extends _Distributor {
  const _$DistributorImpl(
      {required this.id,
      required this.userId,
      required this.companyName,
      this.companyNameEn,
      required this.commercialRegister,
      required this.vatNumber,
      this.logoUrl,
      this.address,
      this.city,
      this.phone,
      this.email,
      this.website,
      this.status = DistributorStatus.pending,
      this.tier = DistributorTier.free,
      this.totalProducts = 0,
      this.totalOrders = 0,
      this.totalRevenue = 0.0,
      this.avgRating = 0.0,
      this.ratingCount = 0,
      this.isFeatured = false,
      this.approvedAt,
      this.approvedBy,
      this.rejectionReason,
      required this.createdAt,
      this.updatedAt})
      : super._();

  factory _$DistributorImpl.fromJson(Map<String, dynamic> json) =>
      _$$DistributorImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String companyName;
  @override
  final String? companyNameEn;
  @override
  final String commercialRegister;
  @override
  final String vatNumber;
  @override
  final String? logoUrl;
  @override
  final String? address;
  @override
  final String? city;
  @override
  final String? phone;
  @override
  final String? email;
  @override
  final String? website;
  @override
  @JsonKey()
  final DistributorStatus status;
  @override
  @JsonKey()
  final DistributorTier tier;
  @override
  @JsonKey()
  final int totalProducts;
  @override
  @JsonKey()
  final int totalOrders;
  @override
  @JsonKey()
  final double totalRevenue;
  @override
  @JsonKey()
  final double avgRating;
  @override
  @JsonKey()
  final int ratingCount;
  @override
  @JsonKey()
  final bool isFeatured;
  @override
  final DateTime? approvedAt;
  @override
  final String? approvedBy;
  @override
  final String? rejectionReason;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Distributor(id: $id, userId: $userId, companyName: $companyName, companyNameEn: $companyNameEn, commercialRegister: $commercialRegister, vatNumber: $vatNumber, logoUrl: $logoUrl, address: $address, city: $city, phone: $phone, email: $email, website: $website, status: $status, tier: $tier, totalProducts: $totalProducts, totalOrders: $totalOrders, totalRevenue: $totalRevenue, avgRating: $avgRating, ratingCount: $ratingCount, isFeatured: $isFeatured, approvedAt: $approvedAt, approvedBy: $approvedBy, rejectionReason: $rejectionReason, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DistributorImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.companyName, companyName) ||
                other.companyName == companyName) &&
            (identical(other.companyNameEn, companyNameEn) ||
                other.companyNameEn == companyNameEn) &&
            (identical(other.commercialRegister, commercialRegister) ||
                other.commercialRegister == commercialRegister) &&
            (identical(other.vatNumber, vatNumber) ||
                other.vatNumber == vatNumber) &&
            (identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.website, website) || other.website == website) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.tier, tier) || other.tier == tier) &&
            (identical(other.totalProducts, totalProducts) ||
                other.totalProducts == totalProducts) &&
            (identical(other.totalOrders, totalOrders) ||
                other.totalOrders == totalOrders) &&
            (identical(other.totalRevenue, totalRevenue) ||
                other.totalRevenue == totalRevenue) &&
            (identical(other.avgRating, avgRating) ||
                other.avgRating == avgRating) &&
            (identical(other.ratingCount, ratingCount) ||
                other.ratingCount == ratingCount) &&
            (identical(other.isFeatured, isFeatured) ||
                other.isFeatured == isFeatured) &&
            (identical(other.approvedAt, approvedAt) ||
                other.approvedAt == approvedAt) &&
            (identical(other.approvedBy, approvedBy) ||
                other.approvedBy == approvedBy) &&
            (identical(other.rejectionReason, rejectionReason) ||
                other.rejectionReason == rejectionReason) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        userId,
        companyName,
        companyNameEn,
        commercialRegister,
        vatNumber,
        logoUrl,
        address,
        city,
        phone,
        email,
        website,
        status,
        tier,
        totalProducts,
        totalOrders,
        totalRevenue,
        avgRating,
        ratingCount,
        isFeatured,
        approvedAt,
        approvedBy,
        rejectionReason,
        createdAt,
        updatedAt
      ]);

  /// Create a copy of Distributor
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DistributorImplCopyWith<_$DistributorImpl> get copyWith =>
      __$$DistributorImplCopyWithImpl<_$DistributorImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DistributorImplToJson(
      this,
    );
  }
}

abstract class _Distributor extends Distributor {
  const factory _Distributor(
      {required final String id,
      required final String userId,
      required final String companyName,
      final String? companyNameEn,
      required final String commercialRegister,
      required final String vatNumber,
      final String? logoUrl,
      final String? address,
      final String? city,
      final String? phone,
      final String? email,
      final String? website,
      final DistributorStatus status,
      final DistributorTier tier,
      final int totalProducts,
      final int totalOrders,
      final double totalRevenue,
      final double avgRating,
      final int ratingCount,
      final bool isFeatured,
      final DateTime? approvedAt,
      final String? approvedBy,
      final String? rejectionReason,
      required final DateTime createdAt,
      final DateTime? updatedAt}) = _$DistributorImpl;
  const _Distributor._() : super._();

  factory _Distributor.fromJson(Map<String, dynamic> json) =
      _$DistributorImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get companyName;
  @override
  String? get companyNameEn;
  @override
  String get commercialRegister;
  @override
  String get vatNumber;
  @override
  String? get logoUrl;
  @override
  String? get address;
  @override
  String? get city;
  @override
  String? get phone;
  @override
  String? get email;
  @override
  String? get website;
  @override
  DistributorStatus get status;
  @override
  DistributorTier get tier;
  @override
  int get totalProducts;
  @override
  int get totalOrders;
  @override
  double get totalRevenue;
  @override
  double get avgRating;
  @override
  int get ratingCount;
  @override
  bool get isFeatured;
  @override
  DateTime? get approvedAt;
  @override
  String? get approvedBy;
  @override
  String? get rejectionReason;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of Distributor
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DistributorImplCopyWith<_$DistributorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
