// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pricing_tier.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PricingTier _$PricingTierFromJson(Map<String, dynamic> json) {
  return _PricingTier.fromJson(json);
}

/// @nodoc
mixin _$PricingTier {
  String get id => throw _privateConstructorUsedError;
  String get distributorId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  PricingTierType get type => throw _privateConstructorUsedError;
  int? get minQuantity => throw _privateConstructorUsedError;
  int? get maxQuantity => throw _privateConstructorUsedError;
  double? get discountPercent => throw _privateConstructorUsedError;
  double? get discountAmount => throw _privateConstructorUsedError;
  List<String>? get applicableStoreIds => throw _privateConstructorUsedError;
  List<String>? get applicableProductIds => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  DateTime? get startDate => throw _privateConstructorUsedError;
  DateTime? get endDate => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this PricingTier to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PricingTier
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PricingTierCopyWith<PricingTier> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PricingTierCopyWith<$Res> {
  factory $PricingTierCopyWith(
          PricingTier value, $Res Function(PricingTier) then) =
      _$PricingTierCopyWithImpl<$Res, PricingTier>;
  @useResult
  $Res call(
      {String id,
      String distributorId,
      String name,
      String? description,
      PricingTierType type,
      int? minQuantity,
      int? maxQuantity,
      double? discountPercent,
      double? discountAmount,
      List<String>? applicableStoreIds,
      List<String>? applicableProductIds,
      bool isActive,
      DateTime? startDate,
      DateTime? endDate,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$PricingTierCopyWithImpl<$Res, $Val extends PricingTier>
    implements $PricingTierCopyWith<$Res> {
  _$PricingTierCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PricingTier
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? distributorId = null,
    Object? name = null,
    Object? description = freezed,
    Object? type = null,
    Object? minQuantity = freezed,
    Object? maxQuantity = freezed,
    Object? discountPercent = freezed,
    Object? discountAmount = freezed,
    Object? applicableStoreIds = freezed,
    Object? applicableProductIds = freezed,
    Object? isActive = null,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      distributorId: null == distributorId
          ? _value.distributorId
          : distributorId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as PricingTierType,
      minQuantity: freezed == minQuantity
          ? _value.minQuantity
          : minQuantity // ignore: cast_nullable_to_non_nullable
              as int?,
      maxQuantity: freezed == maxQuantity
          ? _value.maxQuantity
          : maxQuantity // ignore: cast_nullable_to_non_nullable
              as int?,
      discountPercent: freezed == discountPercent
          ? _value.discountPercent
          : discountPercent // ignore: cast_nullable_to_non_nullable
              as double?,
      discountAmount: freezed == discountAmount
          ? _value.discountAmount
          : discountAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      applicableStoreIds: freezed == applicableStoreIds
          ? _value.applicableStoreIds
          : applicableStoreIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      applicableProductIds: freezed == applicableProductIds
          ? _value.applicableProductIds
          : applicableProductIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
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
abstract class _$$PricingTierImplCopyWith<$Res>
    implements $PricingTierCopyWith<$Res> {
  factory _$$PricingTierImplCopyWith(
          _$PricingTierImpl value, $Res Function(_$PricingTierImpl) then) =
      __$$PricingTierImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String distributorId,
      String name,
      String? description,
      PricingTierType type,
      int? minQuantity,
      int? maxQuantity,
      double? discountPercent,
      double? discountAmount,
      List<String>? applicableStoreIds,
      List<String>? applicableProductIds,
      bool isActive,
      DateTime? startDate,
      DateTime? endDate,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$PricingTierImplCopyWithImpl<$Res>
    extends _$PricingTierCopyWithImpl<$Res, _$PricingTierImpl>
    implements _$$PricingTierImplCopyWith<$Res> {
  __$$PricingTierImplCopyWithImpl(
      _$PricingTierImpl _value, $Res Function(_$PricingTierImpl) _then)
      : super(_value, _then);

  /// Create a copy of PricingTier
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? distributorId = null,
    Object? name = null,
    Object? description = freezed,
    Object? type = null,
    Object? minQuantity = freezed,
    Object? maxQuantity = freezed,
    Object? discountPercent = freezed,
    Object? discountAmount = freezed,
    Object? applicableStoreIds = freezed,
    Object? applicableProductIds = freezed,
    Object? isActive = null,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$PricingTierImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      distributorId: null == distributorId
          ? _value.distributorId
          : distributorId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as PricingTierType,
      minQuantity: freezed == minQuantity
          ? _value.minQuantity
          : minQuantity // ignore: cast_nullable_to_non_nullable
              as int?,
      maxQuantity: freezed == maxQuantity
          ? _value.maxQuantity
          : maxQuantity // ignore: cast_nullable_to_non_nullable
              as int?,
      discountPercent: freezed == discountPercent
          ? _value.discountPercent
          : discountPercent // ignore: cast_nullable_to_non_nullable
              as double?,
      discountAmount: freezed == discountAmount
          ? _value.discountAmount
          : discountAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      applicableStoreIds: freezed == applicableStoreIds
          ? _value._applicableStoreIds
          : applicableStoreIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      applicableProductIds: freezed == applicableProductIds
          ? _value._applicableProductIds
          : applicableProductIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
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
class _$PricingTierImpl extends _PricingTier {
  const _$PricingTierImpl(
      {required this.id,
      required this.distributorId,
      required this.name,
      this.description,
      required this.type,
      this.minQuantity,
      this.maxQuantity,
      this.discountPercent,
      this.discountAmount,
      final List<String>? applicableStoreIds,
      final List<String>? applicableProductIds,
      this.isActive = true,
      this.startDate,
      this.endDate,
      required this.createdAt,
      this.updatedAt})
      : _applicableStoreIds = applicableStoreIds,
        _applicableProductIds = applicableProductIds,
        super._();

  factory _$PricingTierImpl.fromJson(Map<String, dynamic> json) =>
      _$$PricingTierImplFromJson(json);

  @override
  final String id;
  @override
  final String distributorId;
  @override
  final String name;
  @override
  final String? description;
  @override
  final PricingTierType type;
  @override
  final int? minQuantity;
  @override
  final int? maxQuantity;
  @override
  final double? discountPercent;
  @override
  final double? discountAmount;
  final List<String>? _applicableStoreIds;
  @override
  List<String>? get applicableStoreIds {
    final value = _applicableStoreIds;
    if (value == null) return null;
    if (_applicableStoreIds is EqualUnmodifiableListView)
      return _applicableStoreIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _applicableProductIds;
  @override
  List<String>? get applicableProductIds {
    final value = _applicableProductIds;
    if (value == null) return null;
    if (_applicableProductIds is EqualUnmodifiableListView)
      return _applicableProductIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey()
  final bool isActive;
  @override
  final DateTime? startDate;
  @override
  final DateTime? endDate;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'PricingTier(id: $id, distributorId: $distributorId, name: $name, description: $description, type: $type, minQuantity: $minQuantity, maxQuantity: $maxQuantity, discountPercent: $discountPercent, discountAmount: $discountAmount, applicableStoreIds: $applicableStoreIds, applicableProductIds: $applicableProductIds, isActive: $isActive, startDate: $startDate, endDate: $endDate, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PricingTierImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.distributorId, distributorId) ||
                other.distributorId == distributorId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.minQuantity, minQuantity) ||
                other.minQuantity == minQuantity) &&
            (identical(other.maxQuantity, maxQuantity) ||
                other.maxQuantity == maxQuantity) &&
            (identical(other.discountPercent, discountPercent) ||
                other.discountPercent == discountPercent) &&
            (identical(other.discountAmount, discountAmount) ||
                other.discountAmount == discountAmount) &&
            const DeepCollectionEquality()
                .equals(other._applicableStoreIds, _applicableStoreIds) &&
            const DeepCollectionEquality()
                .equals(other._applicableProductIds, _applicableProductIds) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
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
      distributorId,
      name,
      description,
      type,
      minQuantity,
      maxQuantity,
      discountPercent,
      discountAmount,
      const DeepCollectionEquality().hash(_applicableStoreIds),
      const DeepCollectionEquality().hash(_applicableProductIds),
      isActive,
      startDate,
      endDate,
      createdAt,
      updatedAt);

  /// Create a copy of PricingTier
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PricingTierImplCopyWith<_$PricingTierImpl> get copyWith =>
      __$$PricingTierImplCopyWithImpl<_$PricingTierImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PricingTierImplToJson(
      this,
    );
  }
}

abstract class _PricingTier extends PricingTier {
  const factory _PricingTier(
      {required final String id,
      required final String distributorId,
      required final String name,
      final String? description,
      required final PricingTierType type,
      final int? minQuantity,
      final int? maxQuantity,
      final double? discountPercent,
      final double? discountAmount,
      final List<String>? applicableStoreIds,
      final List<String>? applicableProductIds,
      final bool isActive,
      final DateTime? startDate,
      final DateTime? endDate,
      required final DateTime createdAt,
      final DateTime? updatedAt}) = _$PricingTierImpl;
  const _PricingTier._() : super._();

  factory _PricingTier.fromJson(Map<String, dynamic> json) =
      _$PricingTierImpl.fromJson;

  @override
  String get id;
  @override
  String get distributorId;
  @override
  String get name;
  @override
  String? get description;
  @override
  PricingTierType get type;
  @override
  int? get minQuantity;
  @override
  int? get maxQuantity;
  @override
  double? get discountPercent;
  @override
  double? get discountAmount;
  @override
  List<String>? get applicableStoreIds;
  @override
  List<String>? get applicableProductIds;
  @override
  bool get isActive;
  @override
  DateTime? get startDate;
  @override
  DateTime? get endDate;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of PricingTier
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PricingTierImplCopyWith<_$PricingTierImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DistributorProduct _$DistributorProductFromJson(Map<String, dynamic> json) {
  return _DistributorProduct.fromJson(json);
}

/// @nodoc
mixin _$DistributorProduct {
  String get id => throw _privateConstructorUsedError;
  String get distributorId => throw _privateConstructorUsedError;
  String get productId => throw _privateConstructorUsedError;
  String get productName => throw _privateConstructorUsedError;
  String? get productSku => throw _privateConstructorUsedError;
  String? get barcode => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  double get wholesalePrice => throw _privateConstructorUsedError;
  double? get retailPrice => throw _privateConstructorUsedError;
  int get stockQuantity => throw _privateConstructorUsedError;
  int? get minOrderQuantity => throw _privateConstructorUsedError;
  String? get unit => throw _privateConstructorUsedError;
  bool get isAvailable => throw _privateConstructorUsedError;
  List<PricingTier>? get pricingTiers => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this DistributorProduct to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DistributorProduct
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DistributorProductCopyWith<DistributorProduct> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DistributorProductCopyWith<$Res> {
  factory $DistributorProductCopyWith(
          DistributorProduct value, $Res Function(DistributorProduct) then) =
      _$DistributorProductCopyWithImpl<$Res, DistributorProduct>;
  @useResult
  $Res call(
      {String id,
      String distributorId,
      String productId,
      String productName,
      String? productSku,
      String? barcode,
      String? imageUrl,
      String? category,
      double wholesalePrice,
      double? retailPrice,
      int stockQuantity,
      int? minOrderQuantity,
      String? unit,
      bool isAvailable,
      List<PricingTier>? pricingTiers,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$DistributorProductCopyWithImpl<$Res, $Val extends DistributorProduct>
    implements $DistributorProductCopyWith<$Res> {
  _$DistributorProductCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DistributorProduct
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? distributorId = null,
    Object? productId = null,
    Object? productName = null,
    Object? productSku = freezed,
    Object? barcode = freezed,
    Object? imageUrl = freezed,
    Object? category = freezed,
    Object? wholesalePrice = null,
    Object? retailPrice = freezed,
    Object? stockQuantity = null,
    Object? minOrderQuantity = freezed,
    Object? unit = freezed,
    Object? isAvailable = null,
    Object? pricingTiers = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      distributorId: null == distributorId
          ? _value.distributorId
          : distributorId // ignore: cast_nullable_to_non_nullable
              as String,
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      productName: null == productName
          ? _value.productName
          : productName // ignore: cast_nullable_to_non_nullable
              as String,
      productSku: freezed == productSku
          ? _value.productSku
          : productSku // ignore: cast_nullable_to_non_nullable
              as String?,
      barcode: freezed == barcode
          ? _value.barcode
          : barcode // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      wholesalePrice: null == wholesalePrice
          ? _value.wholesalePrice
          : wholesalePrice // ignore: cast_nullable_to_non_nullable
              as double,
      retailPrice: freezed == retailPrice
          ? _value.retailPrice
          : retailPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      stockQuantity: null == stockQuantity
          ? _value.stockQuantity
          : stockQuantity // ignore: cast_nullable_to_non_nullable
              as int,
      minOrderQuantity: freezed == minOrderQuantity
          ? _value.minOrderQuantity
          : minOrderQuantity // ignore: cast_nullable_to_non_nullable
              as int?,
      unit: freezed == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String?,
      isAvailable: null == isAvailable
          ? _value.isAvailable
          : isAvailable // ignore: cast_nullable_to_non_nullable
              as bool,
      pricingTiers: freezed == pricingTiers
          ? _value.pricingTiers
          : pricingTiers // ignore: cast_nullable_to_non_nullable
              as List<PricingTier>?,
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
abstract class _$$DistributorProductImplCopyWith<$Res>
    implements $DistributorProductCopyWith<$Res> {
  factory _$$DistributorProductImplCopyWith(_$DistributorProductImpl value,
          $Res Function(_$DistributorProductImpl) then) =
      __$$DistributorProductImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String distributorId,
      String productId,
      String productName,
      String? productSku,
      String? barcode,
      String? imageUrl,
      String? category,
      double wholesalePrice,
      double? retailPrice,
      int stockQuantity,
      int? minOrderQuantity,
      String? unit,
      bool isAvailable,
      List<PricingTier>? pricingTiers,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$DistributorProductImplCopyWithImpl<$Res>
    extends _$DistributorProductCopyWithImpl<$Res, _$DistributorProductImpl>
    implements _$$DistributorProductImplCopyWith<$Res> {
  __$$DistributorProductImplCopyWithImpl(_$DistributorProductImpl _value,
      $Res Function(_$DistributorProductImpl) _then)
      : super(_value, _then);

  /// Create a copy of DistributorProduct
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? distributorId = null,
    Object? productId = null,
    Object? productName = null,
    Object? productSku = freezed,
    Object? barcode = freezed,
    Object? imageUrl = freezed,
    Object? category = freezed,
    Object? wholesalePrice = null,
    Object? retailPrice = freezed,
    Object? stockQuantity = null,
    Object? minOrderQuantity = freezed,
    Object? unit = freezed,
    Object? isAvailable = null,
    Object? pricingTiers = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$DistributorProductImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      distributorId: null == distributorId
          ? _value.distributorId
          : distributorId // ignore: cast_nullable_to_non_nullable
              as String,
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      productName: null == productName
          ? _value.productName
          : productName // ignore: cast_nullable_to_non_nullable
              as String,
      productSku: freezed == productSku
          ? _value.productSku
          : productSku // ignore: cast_nullable_to_non_nullable
              as String?,
      barcode: freezed == barcode
          ? _value.barcode
          : barcode // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      wholesalePrice: null == wholesalePrice
          ? _value.wholesalePrice
          : wholesalePrice // ignore: cast_nullable_to_non_nullable
              as double,
      retailPrice: freezed == retailPrice
          ? _value.retailPrice
          : retailPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      stockQuantity: null == stockQuantity
          ? _value.stockQuantity
          : stockQuantity // ignore: cast_nullable_to_non_nullable
              as int,
      minOrderQuantity: freezed == minOrderQuantity
          ? _value.minOrderQuantity
          : minOrderQuantity // ignore: cast_nullable_to_non_nullable
              as int?,
      unit: freezed == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String?,
      isAvailable: null == isAvailable
          ? _value.isAvailable
          : isAvailable // ignore: cast_nullable_to_non_nullable
              as bool,
      pricingTiers: freezed == pricingTiers
          ? _value._pricingTiers
          : pricingTiers // ignore: cast_nullable_to_non_nullable
              as List<PricingTier>?,
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
class _$DistributorProductImpl extends _DistributorProduct {
  const _$DistributorProductImpl(
      {required this.id,
      required this.distributorId,
      required this.productId,
      required this.productName,
      this.productSku,
      this.barcode,
      this.imageUrl,
      this.category,
      required this.wholesalePrice,
      this.retailPrice,
      this.stockQuantity = 0,
      this.minOrderQuantity,
      this.unit,
      this.isAvailable = true,
      final List<PricingTier>? pricingTiers,
      required this.createdAt,
      this.updatedAt})
      : _pricingTiers = pricingTiers,
        super._();

  factory _$DistributorProductImpl.fromJson(Map<String, dynamic> json) =>
      _$$DistributorProductImplFromJson(json);

  @override
  final String id;
  @override
  final String distributorId;
  @override
  final String productId;
  @override
  final String productName;
  @override
  final String? productSku;
  @override
  final String? barcode;
  @override
  final String? imageUrl;
  @override
  final String? category;
  @override
  final double wholesalePrice;
  @override
  final double? retailPrice;
  @override
  @JsonKey()
  final int stockQuantity;
  @override
  final int? minOrderQuantity;
  @override
  final String? unit;
  @override
  @JsonKey()
  final bool isAvailable;
  final List<PricingTier>? _pricingTiers;
  @override
  List<PricingTier>? get pricingTiers {
    final value = _pricingTiers;
    if (value == null) return null;
    if (_pricingTiers is EqualUnmodifiableListView) return _pricingTiers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'DistributorProduct(id: $id, distributorId: $distributorId, productId: $productId, productName: $productName, productSku: $productSku, barcode: $barcode, imageUrl: $imageUrl, category: $category, wholesalePrice: $wholesalePrice, retailPrice: $retailPrice, stockQuantity: $stockQuantity, minOrderQuantity: $minOrderQuantity, unit: $unit, isAvailable: $isAvailable, pricingTiers: $pricingTiers, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DistributorProductImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.distributorId, distributorId) ||
                other.distributorId == distributorId) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.productName, productName) ||
                other.productName == productName) &&
            (identical(other.productSku, productSku) ||
                other.productSku == productSku) &&
            (identical(other.barcode, barcode) || other.barcode == barcode) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.wholesalePrice, wholesalePrice) ||
                other.wholesalePrice == wholesalePrice) &&
            (identical(other.retailPrice, retailPrice) ||
                other.retailPrice == retailPrice) &&
            (identical(other.stockQuantity, stockQuantity) ||
                other.stockQuantity == stockQuantity) &&
            (identical(other.minOrderQuantity, minOrderQuantity) ||
                other.minOrderQuantity == minOrderQuantity) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.isAvailable, isAvailable) ||
                other.isAvailable == isAvailable) &&
            const DeepCollectionEquality()
                .equals(other._pricingTiers, _pricingTiers) &&
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
      distributorId,
      productId,
      productName,
      productSku,
      barcode,
      imageUrl,
      category,
      wholesalePrice,
      retailPrice,
      stockQuantity,
      minOrderQuantity,
      unit,
      isAvailable,
      const DeepCollectionEquality().hash(_pricingTiers),
      createdAt,
      updatedAt);

  /// Create a copy of DistributorProduct
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DistributorProductImplCopyWith<_$DistributorProductImpl> get copyWith =>
      __$$DistributorProductImplCopyWithImpl<_$DistributorProductImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DistributorProductImplToJson(
      this,
    );
  }
}

abstract class _DistributorProduct extends DistributorProduct {
  const factory _DistributorProduct(
      {required final String id,
      required final String distributorId,
      required final String productId,
      required final String productName,
      final String? productSku,
      final String? barcode,
      final String? imageUrl,
      final String? category,
      required final double wholesalePrice,
      final double? retailPrice,
      final int stockQuantity,
      final int? minOrderQuantity,
      final String? unit,
      final bool isAvailable,
      final List<PricingTier>? pricingTiers,
      required final DateTime createdAt,
      final DateTime? updatedAt}) = _$DistributorProductImpl;
  const _DistributorProduct._() : super._();

  factory _DistributorProduct.fromJson(Map<String, dynamic> json) =
      _$DistributorProductImpl.fromJson;

  @override
  String get id;
  @override
  String get distributorId;
  @override
  String get productId;
  @override
  String get productName;
  @override
  String? get productSku;
  @override
  String? get barcode;
  @override
  String? get imageUrl;
  @override
  String? get category;
  @override
  double get wholesalePrice;
  @override
  double? get retailPrice;
  @override
  int get stockQuantity;
  @override
  int? get minOrderQuantity;
  @override
  String? get unit;
  @override
  bool get isAvailable;
  @override
  List<PricingTier>? get pricingTiers;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of DistributorProduct
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DistributorProductImplCopyWith<_$DistributorProductImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
