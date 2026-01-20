// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_payment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

OrderPayment _$OrderPaymentFromJson(Map<String, dynamic> json) {
  return _OrderPayment.fromJson(json);
}

/// @nodoc
mixin _$OrderPayment {
  String get id => throw _privateConstructorUsedError;
  String get orderId => throw _privateConstructorUsedError;
  PaymentMethod get method => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String? get referenceNo => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this OrderPayment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrderPayment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderPaymentCopyWith<OrderPayment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderPaymentCopyWith<$Res> {
  factory $OrderPaymentCopyWith(
          OrderPayment value, $Res Function(OrderPayment) then) =
      _$OrderPaymentCopyWithImpl<$Res, OrderPayment>;
  @useResult
  $Res call(
      {String id,
      String orderId,
      PaymentMethod method,
      double amount,
      String? referenceNo,
      String status,
      DateTime createdAt});
}

/// @nodoc
class _$OrderPaymentCopyWithImpl<$Res, $Val extends OrderPayment>
    implements $OrderPaymentCopyWith<$Res> {
  _$OrderPaymentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderPayment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? method = null,
    Object? amount = null,
    Object? referenceNo = freezed,
    Object? status = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      orderId: null == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String,
      method: null == method
          ? _value.method
          : method // ignore: cast_nullable_to_non_nullable
              as PaymentMethod,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      referenceNo: freezed == referenceNo
          ? _value.referenceNo
          : referenceNo // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OrderPaymentImplCopyWith<$Res>
    implements $OrderPaymentCopyWith<$Res> {
  factory _$$OrderPaymentImplCopyWith(
          _$OrderPaymentImpl value, $Res Function(_$OrderPaymentImpl) then) =
      __$$OrderPaymentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String orderId,
      PaymentMethod method,
      double amount,
      String? referenceNo,
      String status,
      DateTime createdAt});
}

/// @nodoc
class __$$OrderPaymentImplCopyWithImpl<$Res>
    extends _$OrderPaymentCopyWithImpl<$Res, _$OrderPaymentImpl>
    implements _$$OrderPaymentImplCopyWith<$Res> {
  __$$OrderPaymentImplCopyWithImpl(
      _$OrderPaymentImpl _value, $Res Function(_$OrderPaymentImpl) _then)
      : super(_value, _then);

  /// Create a copy of OrderPayment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? method = null,
    Object? amount = null,
    Object? referenceNo = freezed,
    Object? status = null,
    Object? createdAt = null,
  }) {
    return _then(_$OrderPaymentImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      orderId: null == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String,
      method: null == method
          ? _value.method
          : method // ignore: cast_nullable_to_non_nullable
              as PaymentMethod,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      referenceNo: freezed == referenceNo
          ? _value.referenceNo
          : referenceNo // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderPaymentImpl extends _OrderPayment {
  const _$OrderPaymentImpl(
      {required this.id,
      required this.orderId,
      required this.method,
      required this.amount,
      this.referenceNo,
      this.status = 'completed',
      required this.createdAt})
      : super._();

  factory _$OrderPaymentImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderPaymentImplFromJson(json);

  @override
  final String id;
  @override
  final String orderId;
  @override
  final PaymentMethod method;
  @override
  final double amount;
  @override
  final String? referenceNo;
  @override
  @JsonKey()
  final String status;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'OrderPayment(id: $id, orderId: $orderId, method: $method, amount: $amount, referenceNo: $referenceNo, status: $status, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderPaymentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.method, method) || other.method == method) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.referenceNo, referenceNo) ||
                other.referenceNo == referenceNo) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, orderId, method, amount, referenceNo, status, createdAt);

  /// Create a copy of OrderPayment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderPaymentImplCopyWith<_$OrderPaymentImpl> get copyWith =>
      __$$OrderPaymentImplCopyWithImpl<_$OrderPaymentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderPaymentImplToJson(
      this,
    );
  }
}

abstract class _OrderPayment extends OrderPayment {
  const factory _OrderPayment(
      {required final String id,
      required final String orderId,
      required final PaymentMethod method,
      required final double amount,
      final String? referenceNo,
      final String status,
      required final DateTime createdAt}) = _$OrderPaymentImpl;
  const _OrderPayment._() : super._();

  factory _OrderPayment.fromJson(Map<String, dynamic> json) =
      _$OrderPaymentImpl.fromJson;

  @override
  String get id;
  @override
  String get orderId;
  @override
  PaymentMethod get method;
  @override
  double get amount;
  @override
  String? get referenceNo;
  @override
  String get status;
  @override
  DateTime get createdAt;

  /// Create a copy of OrderPayment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderPaymentImplCopyWith<_$OrderPaymentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
