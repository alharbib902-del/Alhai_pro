// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stock_adjustment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

StockAdjustment _$StockAdjustmentFromJson(Map<String, dynamic> json) {
  return _StockAdjustment.fromJson(json);
}

/// @nodoc
mixin _$StockAdjustment {
  String get id => throw _privateConstructorUsedError;
  String get productId => throw _privateConstructorUsedError;
  String get storeId => throw _privateConstructorUsedError;
  AdjustmentType get type => throw _privateConstructorUsedError;
  double get quantity => throw _privateConstructorUsedError;
  double get previousQty => throw _privateConstructorUsedError;
  double get newQty => throw _privateConstructorUsedError;
  String? get reason => throw _privateConstructorUsedError;
  String? get referenceId => throw _privateConstructorUsedError;
  String? get createdBy => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this StockAdjustment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StockAdjustment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StockAdjustmentCopyWith<StockAdjustment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StockAdjustmentCopyWith<$Res> {
  factory $StockAdjustmentCopyWith(
          StockAdjustment value, $Res Function(StockAdjustment) then) =
      _$StockAdjustmentCopyWithImpl<$Res, StockAdjustment>;
  @useResult
  $Res call(
      {String id,
      String productId,
      String storeId,
      AdjustmentType type,
      double quantity,
      double previousQty,
      double newQty,
      String? reason,
      String? referenceId,
      String? createdBy,
      DateTime createdAt});
}

/// @nodoc
class _$StockAdjustmentCopyWithImpl<$Res, $Val extends StockAdjustment>
    implements $StockAdjustmentCopyWith<$Res> {
  _$StockAdjustmentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StockAdjustment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? productId = null,
    Object? storeId = null,
    Object? type = null,
    Object? quantity = null,
    Object? previousQty = null,
    Object? newQty = null,
    Object? reason = freezed,
    Object? referenceId = freezed,
    Object? createdBy = freezed,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      storeId: null == storeId
          ? _value.storeId
          : storeId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as AdjustmentType,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as double,
      previousQty: null == previousQty
          ? _value.previousQty
          : previousQty // ignore: cast_nullable_to_non_nullable
              as double,
      newQty: null == newQty
          ? _value.newQty
          : newQty // ignore: cast_nullable_to_non_nullable
              as double,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
      referenceId: freezed == referenceId
          ? _value.referenceId
          : referenceId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdBy: freezed == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StockAdjustmentImplCopyWith<$Res>
    implements $StockAdjustmentCopyWith<$Res> {
  factory _$$StockAdjustmentImplCopyWith(_$StockAdjustmentImpl value,
          $Res Function(_$StockAdjustmentImpl) then) =
      __$$StockAdjustmentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String productId,
      String storeId,
      AdjustmentType type,
      double quantity,
      double previousQty,
      double newQty,
      String? reason,
      String? referenceId,
      String? createdBy,
      DateTime createdAt});
}

/// @nodoc
class __$$StockAdjustmentImplCopyWithImpl<$Res>
    extends _$StockAdjustmentCopyWithImpl<$Res, _$StockAdjustmentImpl>
    implements _$$StockAdjustmentImplCopyWith<$Res> {
  __$$StockAdjustmentImplCopyWithImpl(
      _$StockAdjustmentImpl _value, $Res Function(_$StockAdjustmentImpl) _then)
      : super(_value, _then);

  /// Create a copy of StockAdjustment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? productId = null,
    Object? storeId = null,
    Object? type = null,
    Object? quantity = null,
    Object? previousQty = null,
    Object? newQty = null,
    Object? reason = freezed,
    Object? referenceId = freezed,
    Object? createdBy = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$StockAdjustmentImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      storeId: null == storeId
          ? _value.storeId
          : storeId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as AdjustmentType,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as double,
      previousQty: null == previousQty
          ? _value.previousQty
          : previousQty // ignore: cast_nullable_to_non_nullable
              as double,
      newQty: null == newQty
          ? _value.newQty
          : newQty // ignore: cast_nullable_to_non_nullable
              as double,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
      referenceId: freezed == referenceId
          ? _value.referenceId
          : referenceId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdBy: freezed == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StockAdjustmentImpl implements _StockAdjustment {
  const _$StockAdjustmentImpl(
      {required this.id,
      required this.productId,
      required this.storeId,
      required this.type,
      required this.quantity,
      required this.previousQty,
      required this.newQty,
      this.reason,
      this.referenceId,
      this.createdBy,
      required this.createdAt});

  factory _$StockAdjustmentImpl.fromJson(Map<String, dynamic> json) =>
      _$$StockAdjustmentImplFromJson(json);

  @override
  final String id;
  @override
  final String productId;
  @override
  final String storeId;
  @override
  final AdjustmentType type;
  @override
  final double quantity;
  @override
  final double previousQty;
  @override
  final double newQty;
  @override
  final String? reason;
  @override
  final String? referenceId;
  @override
  final String? createdBy;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'StockAdjustment(id: $id, productId: $productId, storeId: $storeId, type: $type, quantity: $quantity, previousQty: $previousQty, newQty: $newQty, reason: $reason, referenceId: $referenceId, createdBy: $createdBy, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StockAdjustmentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.storeId, storeId) || other.storeId == storeId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.previousQty, previousQty) ||
                other.previousQty == previousQty) &&
            (identical(other.newQty, newQty) || other.newQty == newQty) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.referenceId, referenceId) ||
                other.referenceId == referenceId) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, productId, storeId, type,
      quantity, previousQty, newQty, reason, referenceId, createdBy, createdAt);

  /// Create a copy of StockAdjustment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StockAdjustmentImplCopyWith<_$StockAdjustmentImpl> get copyWith =>
      __$$StockAdjustmentImplCopyWithImpl<_$StockAdjustmentImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StockAdjustmentImplToJson(
      this,
    );
  }
}

abstract class _StockAdjustment implements StockAdjustment {
  const factory _StockAdjustment(
      {required final String id,
      required final String productId,
      required final String storeId,
      required final AdjustmentType type,
      required final double quantity,
      required final double previousQty,
      required final double newQty,
      final String? reason,
      final String? referenceId,
      final String? createdBy,
      required final DateTime createdAt}) = _$StockAdjustmentImpl;

  factory _StockAdjustment.fromJson(Map<String, dynamic> json) =
      _$StockAdjustmentImpl.fromJson;

  @override
  String get id;
  @override
  String get productId;
  @override
  String get storeId;
  @override
  AdjustmentType get type;
  @override
  double get quantity;
  @override
  double get previousQty;
  @override
  double get newQty;
  @override
  String? get reason;
  @override
  String? get referenceId;
  @override
  String? get createdBy;
  @override
  DateTime get createdAt;

  /// Create a copy of StockAdjustment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StockAdjustmentImplCopyWith<_$StockAdjustmentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
