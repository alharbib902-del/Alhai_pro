// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'debt.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Debt _$DebtFromJson(Map<String, dynamic> json) {
  return _Debt.fromJson(json);
}

/// @nodoc
mixin _$Debt {
  String get id => throw _privateConstructorUsedError;
  String get storeId => throw _privateConstructorUsedError;
  DebtType get type => throw _privateConstructorUsedError;
  String get partyId => throw _privateConstructorUsedError;
  String get partyName => throw _privateConstructorUsedError;
  String? get partyPhone => throw _privateConstructorUsedError;
  double get originalAmount => throw _privateConstructorUsedError;
  double get remainingAmount => throw _privateConstructorUsedError;
  String? get orderId => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime? get dueDate => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Debt to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Debt
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DebtCopyWith<Debt> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DebtCopyWith<$Res> {
  factory $DebtCopyWith(Debt value, $Res Function(Debt) then) =
      _$DebtCopyWithImpl<$Res, Debt>;
  @useResult
  $Res call(
      {String id,
      String storeId,
      DebtType type,
      String partyId,
      String partyName,
      String? partyPhone,
      double originalAmount,
      double remainingAmount,
      String? orderId,
      String? notes,
      DateTime? dueDate,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$DebtCopyWithImpl<$Res, $Val extends Debt>
    implements $DebtCopyWith<$Res> {
  _$DebtCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Debt
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? storeId = null,
    Object? type = null,
    Object? partyId = null,
    Object? partyName = null,
    Object? partyPhone = freezed,
    Object? originalAmount = null,
    Object? remainingAmount = null,
    Object? orderId = freezed,
    Object? notes = freezed,
    Object? dueDate = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
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
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as DebtType,
      partyId: null == partyId
          ? _value.partyId
          : partyId // ignore: cast_nullable_to_non_nullable
              as String,
      partyName: null == partyName
          ? _value.partyName
          : partyName // ignore: cast_nullable_to_non_nullable
              as String,
      partyPhone: freezed == partyPhone
          ? _value.partyPhone
          : partyPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      originalAmount: null == originalAmount
          ? _value.originalAmount
          : originalAmount // ignore: cast_nullable_to_non_nullable
              as double,
      remainingAmount: null == remainingAmount
          ? _value.remainingAmount
          : remainingAmount // ignore: cast_nullable_to_non_nullable
              as double,
      orderId: freezed == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      dueDate: freezed == dueDate
          ? _value.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
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
abstract class _$$DebtImplCopyWith<$Res> implements $DebtCopyWith<$Res> {
  factory _$$DebtImplCopyWith(
          _$DebtImpl value, $Res Function(_$DebtImpl) then) =
      __$$DebtImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String storeId,
      DebtType type,
      String partyId,
      String partyName,
      String? partyPhone,
      double originalAmount,
      double remainingAmount,
      String? orderId,
      String? notes,
      DateTime? dueDate,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$DebtImplCopyWithImpl<$Res>
    extends _$DebtCopyWithImpl<$Res, _$DebtImpl>
    implements _$$DebtImplCopyWith<$Res> {
  __$$DebtImplCopyWithImpl(_$DebtImpl _value, $Res Function(_$DebtImpl) _then)
      : super(_value, _then);

  /// Create a copy of Debt
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? storeId = null,
    Object? type = null,
    Object? partyId = null,
    Object? partyName = null,
    Object? partyPhone = freezed,
    Object? originalAmount = null,
    Object? remainingAmount = null,
    Object? orderId = freezed,
    Object? notes = freezed,
    Object? dueDate = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$DebtImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      storeId: null == storeId
          ? _value.storeId
          : storeId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as DebtType,
      partyId: null == partyId
          ? _value.partyId
          : partyId // ignore: cast_nullable_to_non_nullable
              as String,
      partyName: null == partyName
          ? _value.partyName
          : partyName // ignore: cast_nullable_to_non_nullable
              as String,
      partyPhone: freezed == partyPhone
          ? _value.partyPhone
          : partyPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      originalAmount: null == originalAmount
          ? _value.originalAmount
          : originalAmount // ignore: cast_nullable_to_non_nullable
              as double,
      remainingAmount: null == remainingAmount
          ? _value.remainingAmount
          : remainingAmount // ignore: cast_nullable_to_non_nullable
              as double,
      orderId: freezed == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      dueDate: freezed == dueDate
          ? _value.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
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
class _$DebtImpl extends _Debt {
  const _$DebtImpl(
      {required this.id,
      required this.storeId,
      required this.type,
      required this.partyId,
      required this.partyName,
      this.partyPhone,
      required this.originalAmount,
      required this.remainingAmount,
      this.orderId,
      this.notes,
      this.dueDate,
      required this.createdAt,
      this.updatedAt})
      : super._();

  factory _$DebtImpl.fromJson(Map<String, dynamic> json) =>
      _$$DebtImplFromJson(json);

  @override
  final String id;
  @override
  final String storeId;
  @override
  final DebtType type;
  @override
  final String partyId;
  @override
  final String partyName;
  @override
  final String? partyPhone;
  @override
  final double originalAmount;
  @override
  final double remainingAmount;
  @override
  final String? orderId;
  @override
  final String? notes;
  @override
  final DateTime? dueDate;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Debt(id: $id, storeId: $storeId, type: $type, partyId: $partyId, partyName: $partyName, partyPhone: $partyPhone, originalAmount: $originalAmount, remainingAmount: $remainingAmount, orderId: $orderId, notes: $notes, dueDate: $dueDate, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DebtImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.storeId, storeId) || other.storeId == storeId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.partyId, partyId) || other.partyId == partyId) &&
            (identical(other.partyName, partyName) ||
                other.partyName == partyName) &&
            (identical(other.partyPhone, partyPhone) ||
                other.partyPhone == partyPhone) &&
            (identical(other.originalAmount, originalAmount) ||
                other.originalAmount == originalAmount) &&
            (identical(other.remainingAmount, remainingAmount) ||
                other.remainingAmount == remainingAmount) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
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
      type,
      partyId,
      partyName,
      partyPhone,
      originalAmount,
      remainingAmount,
      orderId,
      notes,
      dueDate,
      createdAt,
      updatedAt);

  /// Create a copy of Debt
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DebtImplCopyWith<_$DebtImpl> get copyWith =>
      __$$DebtImplCopyWithImpl<_$DebtImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DebtImplToJson(
      this,
    );
  }
}

abstract class _Debt extends Debt {
  const factory _Debt(
      {required final String id,
      required final String storeId,
      required final DebtType type,
      required final String partyId,
      required final String partyName,
      final String? partyPhone,
      required final double originalAmount,
      required final double remainingAmount,
      final String? orderId,
      final String? notes,
      final DateTime? dueDate,
      required final DateTime createdAt,
      final DateTime? updatedAt}) = _$DebtImpl;
  const _Debt._() : super._();

  factory _Debt.fromJson(Map<String, dynamic> json) = _$DebtImpl.fromJson;

  @override
  String get id;
  @override
  String get storeId;
  @override
  DebtType get type;
  @override
  String get partyId;
  @override
  String get partyName;
  @override
  String? get partyPhone;
  @override
  double get originalAmount;
  @override
  double get remainingAmount;
  @override
  String? get orderId;
  @override
  String? get notes;
  @override
  DateTime? get dueDate;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of Debt
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DebtImplCopyWith<_$DebtImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DebtPayment _$DebtPaymentFromJson(Map<String, dynamic> json) {
  return _DebtPayment.fromJson(json);
}

/// @nodoc
mixin _$DebtPayment {
  String get id => throw _privateConstructorUsedError;
  String get debtId => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get paymentMethod => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this DebtPayment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DebtPayment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DebtPaymentCopyWith<DebtPayment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DebtPaymentCopyWith<$Res> {
  factory $DebtPaymentCopyWith(
          DebtPayment value, $Res Function(DebtPayment) then) =
      _$DebtPaymentCopyWithImpl<$Res, DebtPayment>;
  @useResult
  $Res call(
      {String id,
      String debtId,
      double amount,
      String? notes,
      String? paymentMethod,
      DateTime createdAt});
}

/// @nodoc
class _$DebtPaymentCopyWithImpl<$Res, $Val extends DebtPayment>
    implements $DebtPaymentCopyWith<$Res> {
  _$DebtPaymentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DebtPayment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? debtId = null,
    Object? amount = null,
    Object? notes = freezed,
    Object? paymentMethod = freezed,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      debtId: null == debtId
          ? _value.debtId
          : debtId // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      paymentMethod: freezed == paymentMethod
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DebtPaymentImplCopyWith<$Res>
    implements $DebtPaymentCopyWith<$Res> {
  factory _$$DebtPaymentImplCopyWith(
          _$DebtPaymentImpl value, $Res Function(_$DebtPaymentImpl) then) =
      __$$DebtPaymentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String debtId,
      double amount,
      String? notes,
      String? paymentMethod,
      DateTime createdAt});
}

/// @nodoc
class __$$DebtPaymentImplCopyWithImpl<$Res>
    extends _$DebtPaymentCopyWithImpl<$Res, _$DebtPaymentImpl>
    implements _$$DebtPaymentImplCopyWith<$Res> {
  __$$DebtPaymentImplCopyWithImpl(
      _$DebtPaymentImpl _value, $Res Function(_$DebtPaymentImpl) _then)
      : super(_value, _then);

  /// Create a copy of DebtPayment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? debtId = null,
    Object? amount = null,
    Object? notes = freezed,
    Object? paymentMethod = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$DebtPaymentImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      debtId: null == debtId
          ? _value.debtId
          : debtId // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      paymentMethod: freezed == paymentMethod
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
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
class _$DebtPaymentImpl implements _DebtPayment {
  const _$DebtPaymentImpl(
      {required this.id,
      required this.debtId,
      required this.amount,
      this.notes,
      this.paymentMethod,
      required this.createdAt});

  factory _$DebtPaymentImpl.fromJson(Map<String, dynamic> json) =>
      _$$DebtPaymentImplFromJson(json);

  @override
  final String id;
  @override
  final String debtId;
  @override
  final double amount;
  @override
  final String? notes;
  @override
  final String? paymentMethod;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'DebtPayment(id: $id, debtId: $debtId, amount: $amount, notes: $notes, paymentMethod: $paymentMethod, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DebtPaymentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.debtId, debtId) || other.debtId == debtId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, debtId, amount, notes, paymentMethod, createdAt);

  /// Create a copy of DebtPayment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DebtPaymentImplCopyWith<_$DebtPaymentImpl> get copyWith =>
      __$$DebtPaymentImplCopyWithImpl<_$DebtPaymentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DebtPaymentImplToJson(
      this,
    );
  }
}

abstract class _DebtPayment implements DebtPayment {
  const factory _DebtPayment(
      {required final String id,
      required final String debtId,
      required final double amount,
      final String? notes,
      final String? paymentMethod,
      required final DateTime createdAt}) = _$DebtPaymentImpl;

  factory _DebtPayment.fromJson(Map<String, dynamic> json) =
      _$DebtPaymentImpl.fromJson;

  @override
  String get id;
  @override
  String get debtId;
  @override
  double get amount;
  @override
  String? get notes;
  @override
  String? get paymentMethod;
  @override
  DateTime get createdAt;

  /// Create a copy of DebtPayment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DebtPaymentImplCopyWith<_$DebtPaymentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
