// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shift.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Shift _$ShiftFromJson(Map<String, dynamic> json) {
  return _Shift.fromJson(json);
}

/// @nodoc
mixin _$Shift {
  String get id => throw _privateConstructorUsedError;
  String get storeId => throw _privateConstructorUsedError;
  String get cashierId => throw _privateConstructorUsedError;
  double get openingCash => throw _privateConstructorUsedError;
  double? get closingCash => throw _privateConstructorUsedError;
  double? get expectedCash => throw _privateConstructorUsedError;
  double? get cashDifference => throw _privateConstructorUsedError;
  ShiftStatus get status => throw _privateConstructorUsedError;
  DateTime get openedAt => throw _privateConstructorUsedError;
  DateTime? get closedAt => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this Shift to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Shift
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ShiftCopyWith<Shift> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShiftCopyWith<$Res> {
  factory $ShiftCopyWith(Shift value, $Res Function(Shift) then) =
      _$ShiftCopyWithImpl<$Res, Shift>;
  @useResult
  $Res call(
      {String id,
      String storeId,
      String cashierId,
      double openingCash,
      double? closingCash,
      double? expectedCash,
      double? cashDifference,
      ShiftStatus status,
      DateTime openedAt,
      DateTime? closedAt,
      String? notes});
}

/// @nodoc
class _$ShiftCopyWithImpl<$Res, $Val extends Shift>
    implements $ShiftCopyWith<$Res> {
  _$ShiftCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Shift
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? storeId = null,
    Object? cashierId = null,
    Object? openingCash = null,
    Object? closingCash = freezed,
    Object? expectedCash = freezed,
    Object? cashDifference = freezed,
    Object? status = null,
    Object? openedAt = null,
    Object? closedAt = freezed,
    Object? notes = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      storeId: null == storeId
          ? _value.storeId
          : storeId // ignore: cast_nullable_to_non_nullable
              as String,
      cashierId: null == cashierId
          ? _value.cashierId
          : cashierId // ignore: cast_nullable_to_non_nullable
              as String,
      openingCash: null == openingCash
          ? _value.openingCash
          : openingCash // ignore: cast_nullable_to_non_nullable
              as double,
      closingCash: freezed == closingCash
          ? _value.closingCash
          : closingCash // ignore: cast_nullable_to_non_nullable
              as double?,
      expectedCash: freezed == expectedCash
          ? _value.expectedCash
          : expectedCash // ignore: cast_nullable_to_non_nullable
              as double?,
      cashDifference: freezed == cashDifference
          ? _value.cashDifference
          : cashDifference // ignore: cast_nullable_to_non_nullable
              as double?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ShiftStatus,
      openedAt: null == openedAt
          ? _value.openedAt
          : openedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      closedAt: freezed == closedAt
          ? _value.closedAt
          : closedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ShiftImplCopyWith<$Res> implements $ShiftCopyWith<$Res> {
  factory _$$ShiftImplCopyWith(
          _$ShiftImpl value, $Res Function(_$ShiftImpl) then) =
      __$$ShiftImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String storeId,
      String cashierId,
      double openingCash,
      double? closingCash,
      double? expectedCash,
      double? cashDifference,
      ShiftStatus status,
      DateTime openedAt,
      DateTime? closedAt,
      String? notes});
}

/// @nodoc
class __$$ShiftImplCopyWithImpl<$Res>
    extends _$ShiftCopyWithImpl<$Res, _$ShiftImpl>
    implements _$$ShiftImplCopyWith<$Res> {
  __$$ShiftImplCopyWithImpl(
      _$ShiftImpl _value, $Res Function(_$ShiftImpl) _then)
      : super(_value, _then);

  /// Create a copy of Shift
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? storeId = null,
    Object? cashierId = null,
    Object? openingCash = null,
    Object? closingCash = freezed,
    Object? expectedCash = freezed,
    Object? cashDifference = freezed,
    Object? status = null,
    Object? openedAt = null,
    Object? closedAt = freezed,
    Object? notes = freezed,
  }) {
    return _then(_$ShiftImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      storeId: null == storeId
          ? _value.storeId
          : storeId // ignore: cast_nullable_to_non_nullable
              as String,
      cashierId: null == cashierId
          ? _value.cashierId
          : cashierId // ignore: cast_nullable_to_non_nullable
              as String,
      openingCash: null == openingCash
          ? _value.openingCash
          : openingCash // ignore: cast_nullable_to_non_nullable
              as double,
      closingCash: freezed == closingCash
          ? _value.closingCash
          : closingCash // ignore: cast_nullable_to_non_nullable
              as double?,
      expectedCash: freezed == expectedCash
          ? _value.expectedCash
          : expectedCash // ignore: cast_nullable_to_non_nullable
              as double?,
      cashDifference: freezed == cashDifference
          ? _value.cashDifference
          : cashDifference // ignore: cast_nullable_to_non_nullable
              as double?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ShiftStatus,
      openedAt: null == openedAt
          ? _value.openedAt
          : openedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      closedAt: freezed == closedAt
          ? _value.closedAt
          : closedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ShiftImpl extends _Shift {
  const _$ShiftImpl(
      {required this.id,
      required this.storeId,
      required this.cashierId,
      required this.openingCash,
      this.closingCash,
      this.expectedCash,
      this.cashDifference,
      this.status = ShiftStatus.open,
      required this.openedAt,
      this.closedAt,
      this.notes})
      : super._();

  factory _$ShiftImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShiftImplFromJson(json);

  @override
  final String id;
  @override
  final String storeId;
  @override
  final String cashierId;
  @override
  final double openingCash;
  @override
  final double? closingCash;
  @override
  final double? expectedCash;
  @override
  final double? cashDifference;
  @override
  @JsonKey()
  final ShiftStatus status;
  @override
  final DateTime openedAt;
  @override
  final DateTime? closedAt;
  @override
  final String? notes;

  @override
  String toString() {
    return 'Shift(id: $id, storeId: $storeId, cashierId: $cashierId, openingCash: $openingCash, closingCash: $closingCash, expectedCash: $expectedCash, cashDifference: $cashDifference, status: $status, openedAt: $openedAt, closedAt: $closedAt, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShiftImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.storeId, storeId) || other.storeId == storeId) &&
            (identical(other.cashierId, cashierId) ||
                other.cashierId == cashierId) &&
            (identical(other.openingCash, openingCash) ||
                other.openingCash == openingCash) &&
            (identical(other.closingCash, closingCash) ||
                other.closingCash == closingCash) &&
            (identical(other.expectedCash, expectedCash) ||
                other.expectedCash == expectedCash) &&
            (identical(other.cashDifference, cashDifference) ||
                other.cashDifference == cashDifference) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.openedAt, openedAt) ||
                other.openedAt == openedAt) &&
            (identical(other.closedAt, closedAt) ||
                other.closedAt == closedAt) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      storeId,
      cashierId,
      openingCash,
      closingCash,
      expectedCash,
      cashDifference,
      status,
      openedAt,
      closedAt,
      notes);

  /// Create a copy of Shift
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShiftImplCopyWith<_$ShiftImpl> get copyWith =>
      __$$ShiftImplCopyWithImpl<_$ShiftImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ShiftImplToJson(
      this,
    );
  }
}

abstract class _Shift extends Shift {
  const factory _Shift(
      {required final String id,
      required final String storeId,
      required final String cashierId,
      required final double openingCash,
      final double? closingCash,
      final double? expectedCash,
      final double? cashDifference,
      final ShiftStatus status,
      required final DateTime openedAt,
      final DateTime? closedAt,
      final String? notes}) = _$ShiftImpl;
  const _Shift._() : super._();

  factory _Shift.fromJson(Map<String, dynamic> json) = _$ShiftImpl.fromJson;

  @override
  String get id;
  @override
  String get storeId;
  @override
  String get cashierId;
  @override
  double get openingCash;
  @override
  double? get closingCash;
  @override
  double? get expectedCash;
  @override
  double? get cashDifference;
  @override
  ShiftStatus get status;
  @override
  DateTime get openedAt;
  @override
  DateTime? get closedAt;
  @override
  String? get notes;

  /// Create a copy of Shift
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShiftImplCopyWith<_$ShiftImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
