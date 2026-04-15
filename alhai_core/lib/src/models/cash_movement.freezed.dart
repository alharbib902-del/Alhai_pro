// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cash_movement.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CashMovement _$CashMovementFromJson(Map<String, dynamic> json) {
  return _CashMovement.fromJson(json);
}

/// @nodoc
mixin _$CashMovement {
  String get id => throw _privateConstructorUsedError;
  String get shiftId => throw _privateConstructorUsedError;
  String get storeId => throw _privateConstructorUsedError;
  String get cashierId => throw _privateConstructorUsedError;
  CashMovementType get type => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  CashMovementReason get reason => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get supervisorId => throw _privateConstructorUsedError;
  String? get supervisorPin => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this CashMovement to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CashMovement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CashMovementCopyWith<CashMovement> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CashMovementCopyWith<$Res> {
  factory $CashMovementCopyWith(
          CashMovement value, $Res Function(CashMovement) then) =
      _$CashMovementCopyWithImpl<$Res, CashMovement>;
  @useResult
  $Res call(
      {String id,
      String shiftId,
      String storeId,
      String cashierId,
      CashMovementType type,
      double amount,
      CashMovementReason reason,
      String? notes,
      String? supervisorId,
      String? supervisorPin,
      DateTime createdAt});
}

/// @nodoc
class _$CashMovementCopyWithImpl<$Res, $Val extends CashMovement>
    implements $CashMovementCopyWith<$Res> {
  _$CashMovementCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CashMovement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? shiftId = null,
    Object? storeId = null,
    Object? cashierId = null,
    Object? type = null,
    Object? amount = null,
    Object? reason = null,
    Object? notes = freezed,
    Object? supervisorId = freezed,
    Object? supervisorPin = freezed,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      shiftId: null == shiftId
          ? _value.shiftId
          : shiftId // ignore: cast_nullable_to_non_nullable
              as String,
      storeId: null == storeId
          ? _value.storeId
          : storeId // ignore: cast_nullable_to_non_nullable
              as String,
      cashierId: null == cashierId
          ? _value.cashierId
          : cashierId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as CashMovementType,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as CashMovementReason,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      supervisorId: freezed == supervisorId
          ? _value.supervisorId
          : supervisorId // ignore: cast_nullable_to_non_nullable
              as String?,
      supervisorPin: freezed == supervisorPin
          ? _value.supervisorPin
          : supervisorPin // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CashMovementImplCopyWith<$Res>
    implements $CashMovementCopyWith<$Res> {
  factory _$$CashMovementImplCopyWith(
          _$CashMovementImpl value, $Res Function(_$CashMovementImpl) then) =
      __$$CashMovementImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String shiftId,
      String storeId,
      String cashierId,
      CashMovementType type,
      double amount,
      CashMovementReason reason,
      String? notes,
      String? supervisorId,
      String? supervisorPin,
      DateTime createdAt});
}

/// @nodoc
class __$$CashMovementImplCopyWithImpl<$Res>
    extends _$CashMovementCopyWithImpl<$Res, _$CashMovementImpl>
    implements _$$CashMovementImplCopyWith<$Res> {
  __$$CashMovementImplCopyWithImpl(
      _$CashMovementImpl _value, $Res Function(_$CashMovementImpl) _then)
      : super(_value, _then);

  /// Create a copy of CashMovement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? shiftId = null,
    Object? storeId = null,
    Object? cashierId = null,
    Object? type = null,
    Object? amount = null,
    Object? reason = null,
    Object? notes = freezed,
    Object? supervisorId = freezed,
    Object? supervisorPin = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$CashMovementImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      shiftId: null == shiftId
          ? _value.shiftId
          : shiftId // ignore: cast_nullable_to_non_nullable
              as String,
      storeId: null == storeId
          ? _value.storeId
          : storeId // ignore: cast_nullable_to_non_nullable
              as String,
      cashierId: null == cashierId
          ? _value.cashierId
          : cashierId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as CashMovementType,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as CashMovementReason,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      supervisorId: freezed == supervisorId
          ? _value.supervisorId
          : supervisorId // ignore: cast_nullable_to_non_nullable
              as String?,
      supervisorPin: freezed == supervisorPin
          ? _value.supervisorPin
          : supervisorPin // ignore: cast_nullable_to_non_nullable
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
class _$CashMovementImpl extends _CashMovement {
  const _$CashMovementImpl(
      {required this.id,
      required this.shiftId,
      required this.storeId,
      required this.cashierId,
      required this.type,
      required this.amount,
      required this.reason,
      this.notes,
      this.supervisorId,
      this.supervisorPin,
      required this.createdAt})
      : super._();

  factory _$CashMovementImpl.fromJson(Map<String, dynamic> json) =>
      _$$CashMovementImplFromJson(json);

  @override
  final String id;
  @override
  final String shiftId;
  @override
  final String storeId;
  @override
  final String cashierId;
  @override
  final CashMovementType type;
  @override
  final double amount;
  @override
  final CashMovementReason reason;
  @override
  final String? notes;
  @override
  final String? supervisorId;
  @override
  final String? supervisorPin;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'CashMovement(id: $id, shiftId: $shiftId, storeId: $storeId, cashierId: $cashierId, type: $type, amount: $amount, reason: $reason, notes: $notes, supervisorId: $supervisorId, supervisorPin: $supervisorPin, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CashMovementImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.shiftId, shiftId) || other.shiftId == shiftId) &&
            (identical(other.storeId, storeId) || other.storeId == storeId) &&
            (identical(other.cashierId, cashierId) ||
                other.cashierId == cashierId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.supervisorId, supervisorId) ||
                other.supervisorId == supervisorId) &&
            (identical(other.supervisorPin, supervisorPin) ||
                other.supervisorPin == supervisorPin) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, shiftId, storeId, cashierId,
      type, amount, reason, notes, supervisorId, supervisorPin, createdAt);

  /// Create a copy of CashMovement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CashMovementImplCopyWith<_$CashMovementImpl> get copyWith =>
      __$$CashMovementImplCopyWithImpl<_$CashMovementImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CashMovementImplToJson(
      this,
    );
  }
}

abstract class _CashMovement extends CashMovement {
  const factory _CashMovement(
      {required final String id,
      required final String shiftId,
      required final String storeId,
      required final String cashierId,
      required final CashMovementType type,
      required final double amount,
      required final CashMovementReason reason,
      final String? notes,
      final String? supervisorId,
      final String? supervisorPin,
      required final DateTime createdAt}) = _$CashMovementImpl;
  const _CashMovement._() : super._();

  factory _CashMovement.fromJson(Map<String, dynamic> json) =
      _$CashMovementImpl.fromJson;

  @override
  String get id;
  @override
  String get shiftId;
  @override
  String get storeId;
  @override
  String get cashierId;
  @override
  CashMovementType get type;
  @override
  double get amount;
  @override
  CashMovementReason get reason;
  @override
  String? get notes;
  @override
  String? get supervisorId;
  @override
  String? get supervisorPin;
  @override
  DateTime get createdAt;

  /// Create a copy of CashMovement
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CashMovementImplCopyWith<_$CashMovementImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
