// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'promotion.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Promotion _$PromotionFromJson(Map<String, dynamic> json) {
  return _Promotion.fromJson(json);
}

/// @nodoc
mixin _$Promotion {
  String get id => throw _privateConstructorUsedError;
  String get storeId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get code => throw _privateConstructorUsedError;
  PromoType get type => throw _privateConstructorUsedError;
  double get value => throw _privateConstructorUsedError;
  double? get minOrderAmount => throw _privateConstructorUsedError;
  double? get maxDiscount => throw _privateConstructorUsedError;
  int? get usageLimit => throw _privateConstructorUsedError;
  int get usageCount => throw _privateConstructorUsedError;
  DateTime get startDate => throw _privateConstructorUsedError;
  DateTime get endDate => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Promotion to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Promotion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PromotionCopyWith<Promotion> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PromotionCopyWith<$Res> {
  factory $PromotionCopyWith(Promotion value, $Res Function(Promotion) then) =
      _$PromotionCopyWithImpl<$Res, Promotion>;
  @useResult
  $Res call({
    String id,
    String storeId,
    String name,
    String? code,
    PromoType type,
    double value,
    double? minOrderAmount,
    double? maxDiscount,
    int? usageLimit,
    int usageCount,
    DateTime startDate,
    DateTime endDate,
    bool isActive,
    DateTime createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$PromotionCopyWithImpl<$Res, $Val extends Promotion>
    implements $PromotionCopyWith<$Res> {
  _$PromotionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Promotion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? storeId = null,
    Object? name = null,
    Object? code = freezed,
    Object? type = null,
    Object? value = null,
    Object? minOrderAmount = freezed,
    Object? maxDiscount = freezed,
    Object? usageLimit = freezed,
    Object? usageCount = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            storeId: null == storeId
                ? _value.storeId
                : storeId // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            code: freezed == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String?,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as PromoType,
            value: null == value
                ? _value.value
                : value // ignore: cast_nullable_to_non_nullable
                      as double,
            minOrderAmount: freezed == minOrderAmount
                ? _value.minOrderAmount
                : minOrderAmount // ignore: cast_nullable_to_non_nullable
                      as double?,
            maxDiscount: freezed == maxDiscount
                ? _value.maxDiscount
                : maxDiscount // ignore: cast_nullable_to_non_nullable
                      as double?,
            usageLimit: freezed == usageLimit
                ? _value.usageLimit
                : usageLimit // ignore: cast_nullable_to_non_nullable
                      as int?,
            usageCount: null == usageCount
                ? _value.usageCount
                : usageCount // ignore: cast_nullable_to_non_nullable
                      as int,
            startDate: null == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            endDate: null == endDate
                ? _value.endDate
                : endDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PromotionImplCopyWith<$Res>
    implements $PromotionCopyWith<$Res> {
  factory _$$PromotionImplCopyWith(
    _$PromotionImpl value,
    $Res Function(_$PromotionImpl) then,
  ) = __$$PromotionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String storeId,
    String name,
    String? code,
    PromoType type,
    double value,
    double? minOrderAmount,
    double? maxDiscount,
    int? usageLimit,
    int usageCount,
    DateTime startDate,
    DateTime endDate,
    bool isActive,
    DateTime createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$PromotionImplCopyWithImpl<$Res>
    extends _$PromotionCopyWithImpl<$Res, _$PromotionImpl>
    implements _$$PromotionImplCopyWith<$Res> {
  __$$PromotionImplCopyWithImpl(
    _$PromotionImpl _value,
    $Res Function(_$PromotionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Promotion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? storeId = null,
    Object? name = null,
    Object? code = freezed,
    Object? type = null,
    Object? value = null,
    Object? minOrderAmount = freezed,
    Object? maxDiscount = freezed,
    Object? usageLimit = freezed,
    Object? usageCount = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$PromotionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        storeId: null == storeId
            ? _value.storeId
            : storeId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        code: freezed == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String?,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as PromoType,
        value: null == value
            ? _value.value
            : value // ignore: cast_nullable_to_non_nullable
                  as double,
        minOrderAmount: freezed == minOrderAmount
            ? _value.minOrderAmount
            : minOrderAmount // ignore: cast_nullable_to_non_nullable
                  as double?,
        maxDiscount: freezed == maxDiscount
            ? _value.maxDiscount
            : maxDiscount // ignore: cast_nullable_to_non_nullable
                  as double?,
        usageLimit: freezed == usageLimit
            ? _value.usageLimit
            : usageLimit // ignore: cast_nullable_to_non_nullable
                  as int?,
        usageCount: null == usageCount
            ? _value.usageCount
            : usageCount // ignore: cast_nullable_to_non_nullable
                  as int,
        startDate: null == startDate
            ? _value.startDate
            : startDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        endDate: null == endDate
            ? _value.endDate
            : endDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PromotionImpl extends _Promotion {
  const _$PromotionImpl({
    required this.id,
    required this.storeId,
    required this.name,
    this.code,
    required this.type,
    required this.value,
    this.minOrderAmount,
    this.maxDiscount,
    this.usageLimit,
    this.usageCount = 0,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  }) : super._();

  factory _$PromotionImpl.fromJson(Map<String, dynamic> json) =>
      _$$PromotionImplFromJson(json);

  @override
  final String id;
  @override
  final String storeId;
  @override
  final String name;
  @override
  final String? code;
  @override
  final PromoType type;
  @override
  final double value;
  @override
  final double? minOrderAmount;
  @override
  final double? maxDiscount;
  @override
  final int? usageLimit;
  @override
  @JsonKey()
  final int usageCount;
  @override
  final DateTime startDate;
  @override
  final DateTime endDate;
  @override
  @JsonKey()
  final bool isActive;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Promotion(id: $id, storeId: $storeId, name: $name, code: $code, type: $type, value: $value, minOrderAmount: $minOrderAmount, maxDiscount: $maxDiscount, usageLimit: $usageLimit, usageCount: $usageCount, startDate: $startDate, endDate: $endDate, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PromotionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.storeId, storeId) || other.storeId == storeId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.minOrderAmount, minOrderAmount) ||
                other.minOrderAmount == minOrderAmount) &&
            (identical(other.maxDiscount, maxDiscount) ||
                other.maxDiscount == maxDiscount) &&
            (identical(other.usageLimit, usageLimit) ||
                other.usageLimit == usageLimit) &&
            (identical(other.usageCount, usageCount) ||
                other.usageCount == usageCount) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
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
    storeId,
    name,
    code,
    type,
    value,
    minOrderAmount,
    maxDiscount,
    usageLimit,
    usageCount,
    startDate,
    endDate,
    isActive,
    createdAt,
    updatedAt,
  );

  /// Create a copy of Promotion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PromotionImplCopyWith<_$PromotionImpl> get copyWith =>
      __$$PromotionImplCopyWithImpl<_$PromotionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PromotionImplToJson(this);
  }
}

abstract class _Promotion extends Promotion {
  const factory _Promotion({
    required final String id,
    required final String storeId,
    required final String name,
    final String? code,
    required final PromoType type,
    required final double value,
    final double? minOrderAmount,
    final double? maxDiscount,
    final int? usageLimit,
    final int usageCount,
    required final DateTime startDate,
    required final DateTime endDate,
    final bool isActive,
    required final DateTime createdAt,
    final DateTime? updatedAt,
  }) = _$PromotionImpl;
  const _Promotion._() : super._();

  factory _Promotion.fromJson(Map<String, dynamic> json) =
      _$PromotionImpl.fromJson;

  @override
  String get id;
  @override
  String get storeId;
  @override
  String get name;
  @override
  String? get code;
  @override
  PromoType get type;
  @override
  double get value;
  @override
  double? get minOrderAmount;
  @override
  double? get maxDiscount;
  @override
  int? get usageLimit;
  @override
  int get usageCount;
  @override
  DateTime get startDate;
  @override
  DateTime get endDate;
  @override
  bool get isActive;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of Promotion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PromotionImplCopyWith<_$PromotionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
