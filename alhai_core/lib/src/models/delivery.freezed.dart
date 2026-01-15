// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'delivery.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Delivery _$DeliveryFromJson(Map<String, dynamic> json) {
  return _Delivery.fromJson(json);
}

/// @nodoc
mixin _$Delivery {
  String get id => throw _privateConstructorUsedError;
  String get orderId => throw _privateConstructorUsedError;
  String get driverId => throw _privateConstructorUsedError;
  DeliveryStatus get status => throw _privateConstructorUsedError;
  Address get pickupAddress => throw _privateConstructorUsedError;
  Address get deliveryAddress => throw _privateConstructorUsedError;
  String? get driverName => throw _privateConstructorUsedError;
  String? get driverPhone => throw _privateConstructorUsedError;
  double? get driverLat => throw _privateConstructorUsedError;
  double? get driverLng => throw _privateConstructorUsedError;
  DateTime? get estimatedArrival => throw _privateConstructorUsedError;
  DateTime? get pickedUpAt => throw _privateConstructorUsedError;
  DateTime? get deliveredAt => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Delivery to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Delivery
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DeliveryCopyWith<Delivery> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeliveryCopyWith<$Res> {
  factory $DeliveryCopyWith(Delivery value, $Res Function(Delivery) then) =
      _$DeliveryCopyWithImpl<$Res, Delivery>;
  @useResult
  $Res call(
      {String id,
      String orderId,
      String driverId,
      DeliveryStatus status,
      Address pickupAddress,
      Address deliveryAddress,
      String? driverName,
      String? driverPhone,
      double? driverLat,
      double? driverLng,
      DateTime? estimatedArrival,
      DateTime? pickedUpAt,
      DateTime? deliveredAt,
      String? notes,
      DateTime createdAt});

  $AddressCopyWith<$Res> get pickupAddress;
  $AddressCopyWith<$Res> get deliveryAddress;
}

/// @nodoc
class _$DeliveryCopyWithImpl<$Res, $Val extends Delivery>
    implements $DeliveryCopyWith<$Res> {
  _$DeliveryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Delivery
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? driverId = null,
    Object? status = null,
    Object? pickupAddress = null,
    Object? deliveryAddress = null,
    Object? driverName = freezed,
    Object? driverPhone = freezed,
    Object? driverLat = freezed,
    Object? driverLng = freezed,
    Object? estimatedArrival = freezed,
    Object? pickedUpAt = freezed,
    Object? deliveredAt = freezed,
    Object? notes = freezed,
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
      driverId: null == driverId
          ? _value.driverId
          : driverId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as DeliveryStatus,
      pickupAddress: null == pickupAddress
          ? _value.pickupAddress
          : pickupAddress // ignore: cast_nullable_to_non_nullable
              as Address,
      deliveryAddress: null == deliveryAddress
          ? _value.deliveryAddress
          : deliveryAddress // ignore: cast_nullable_to_non_nullable
              as Address,
      driverName: freezed == driverName
          ? _value.driverName
          : driverName // ignore: cast_nullable_to_non_nullable
              as String?,
      driverPhone: freezed == driverPhone
          ? _value.driverPhone
          : driverPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      driverLat: freezed == driverLat
          ? _value.driverLat
          : driverLat // ignore: cast_nullable_to_non_nullable
              as double?,
      driverLng: freezed == driverLng
          ? _value.driverLng
          : driverLng // ignore: cast_nullable_to_non_nullable
              as double?,
      estimatedArrival: freezed == estimatedArrival
          ? _value.estimatedArrival
          : estimatedArrival // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      pickedUpAt: freezed == pickedUpAt
          ? _value.pickedUpAt
          : pickedUpAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      deliveredAt: freezed == deliveredAt
          ? _value.deliveredAt
          : deliveredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }

  /// Create a copy of Delivery
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AddressCopyWith<$Res> get pickupAddress {
    return $AddressCopyWith<$Res>(_value.pickupAddress, (value) {
      return _then(_value.copyWith(pickupAddress: value) as $Val);
    });
  }

  /// Create a copy of Delivery
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AddressCopyWith<$Res> get deliveryAddress {
    return $AddressCopyWith<$Res>(_value.deliveryAddress, (value) {
      return _then(_value.copyWith(deliveryAddress: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DeliveryImplCopyWith<$Res>
    implements $DeliveryCopyWith<$Res> {
  factory _$$DeliveryImplCopyWith(
          _$DeliveryImpl value, $Res Function(_$DeliveryImpl) then) =
      __$$DeliveryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String orderId,
      String driverId,
      DeliveryStatus status,
      Address pickupAddress,
      Address deliveryAddress,
      String? driverName,
      String? driverPhone,
      double? driverLat,
      double? driverLng,
      DateTime? estimatedArrival,
      DateTime? pickedUpAt,
      DateTime? deliveredAt,
      String? notes,
      DateTime createdAt});

  @override
  $AddressCopyWith<$Res> get pickupAddress;
  @override
  $AddressCopyWith<$Res> get deliveryAddress;
}

/// @nodoc
class __$$DeliveryImplCopyWithImpl<$Res>
    extends _$DeliveryCopyWithImpl<$Res, _$DeliveryImpl>
    implements _$$DeliveryImplCopyWith<$Res> {
  __$$DeliveryImplCopyWithImpl(
      _$DeliveryImpl _value, $Res Function(_$DeliveryImpl) _then)
      : super(_value, _then);

  /// Create a copy of Delivery
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? driverId = null,
    Object? status = null,
    Object? pickupAddress = null,
    Object? deliveryAddress = null,
    Object? driverName = freezed,
    Object? driverPhone = freezed,
    Object? driverLat = freezed,
    Object? driverLng = freezed,
    Object? estimatedArrival = freezed,
    Object? pickedUpAt = freezed,
    Object? deliveredAt = freezed,
    Object? notes = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$DeliveryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      orderId: null == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String,
      driverId: null == driverId
          ? _value.driverId
          : driverId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as DeliveryStatus,
      pickupAddress: null == pickupAddress
          ? _value.pickupAddress
          : pickupAddress // ignore: cast_nullable_to_non_nullable
              as Address,
      deliveryAddress: null == deliveryAddress
          ? _value.deliveryAddress
          : deliveryAddress // ignore: cast_nullable_to_non_nullable
              as Address,
      driverName: freezed == driverName
          ? _value.driverName
          : driverName // ignore: cast_nullable_to_non_nullable
              as String?,
      driverPhone: freezed == driverPhone
          ? _value.driverPhone
          : driverPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      driverLat: freezed == driverLat
          ? _value.driverLat
          : driverLat // ignore: cast_nullable_to_non_nullable
              as double?,
      driverLng: freezed == driverLng
          ? _value.driverLng
          : driverLng // ignore: cast_nullable_to_non_nullable
              as double?,
      estimatedArrival: freezed == estimatedArrival
          ? _value.estimatedArrival
          : estimatedArrival // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      pickedUpAt: freezed == pickedUpAt
          ? _value.pickedUpAt
          : pickedUpAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      deliveredAt: freezed == deliveredAt
          ? _value.deliveredAt
          : deliveredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
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
class _$DeliveryImpl implements _Delivery {
  const _$DeliveryImpl(
      {required this.id,
      required this.orderId,
      required this.driverId,
      required this.status,
      required this.pickupAddress,
      required this.deliveryAddress,
      this.driverName,
      this.driverPhone,
      this.driverLat,
      this.driverLng,
      this.estimatedArrival,
      this.pickedUpAt,
      this.deliveredAt,
      this.notes,
      required this.createdAt});

  factory _$DeliveryImpl.fromJson(Map<String, dynamic> json) =>
      _$$DeliveryImplFromJson(json);

  @override
  final String id;
  @override
  final String orderId;
  @override
  final String driverId;
  @override
  final DeliveryStatus status;
  @override
  final Address pickupAddress;
  @override
  final Address deliveryAddress;
  @override
  final String? driverName;
  @override
  final String? driverPhone;
  @override
  final double? driverLat;
  @override
  final double? driverLng;
  @override
  final DateTime? estimatedArrival;
  @override
  final DateTime? pickedUpAt;
  @override
  final DateTime? deliveredAt;
  @override
  final String? notes;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'Delivery(id: $id, orderId: $orderId, driverId: $driverId, status: $status, pickupAddress: $pickupAddress, deliveryAddress: $deliveryAddress, driverName: $driverName, driverPhone: $driverPhone, driverLat: $driverLat, driverLng: $driverLng, estimatedArrival: $estimatedArrival, pickedUpAt: $pickedUpAt, deliveredAt: $deliveredAt, notes: $notes, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeliveryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.driverId, driverId) ||
                other.driverId == driverId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.pickupAddress, pickupAddress) ||
                other.pickupAddress == pickupAddress) &&
            (identical(other.deliveryAddress, deliveryAddress) ||
                other.deliveryAddress == deliveryAddress) &&
            (identical(other.driverName, driverName) ||
                other.driverName == driverName) &&
            (identical(other.driverPhone, driverPhone) ||
                other.driverPhone == driverPhone) &&
            (identical(other.driverLat, driverLat) ||
                other.driverLat == driverLat) &&
            (identical(other.driverLng, driverLng) ||
                other.driverLng == driverLng) &&
            (identical(other.estimatedArrival, estimatedArrival) ||
                other.estimatedArrival == estimatedArrival) &&
            (identical(other.pickedUpAt, pickedUpAt) ||
                other.pickedUpAt == pickedUpAt) &&
            (identical(other.deliveredAt, deliveredAt) ||
                other.deliveredAt == deliveredAt) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      orderId,
      driverId,
      status,
      pickupAddress,
      deliveryAddress,
      driverName,
      driverPhone,
      driverLat,
      driverLng,
      estimatedArrival,
      pickedUpAt,
      deliveredAt,
      notes,
      createdAt);

  /// Create a copy of Delivery
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeliveryImplCopyWith<_$DeliveryImpl> get copyWith =>
      __$$DeliveryImplCopyWithImpl<_$DeliveryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DeliveryImplToJson(
      this,
    );
  }
}

abstract class _Delivery implements Delivery {
  const factory _Delivery(
      {required final String id,
      required final String orderId,
      required final String driverId,
      required final DeliveryStatus status,
      required final Address pickupAddress,
      required final Address deliveryAddress,
      final String? driverName,
      final String? driverPhone,
      final double? driverLat,
      final double? driverLng,
      final DateTime? estimatedArrival,
      final DateTime? pickedUpAt,
      final DateTime? deliveredAt,
      final String? notes,
      required final DateTime createdAt}) = _$DeliveryImpl;

  factory _Delivery.fromJson(Map<String, dynamic> json) =
      _$DeliveryImpl.fromJson;

  @override
  String get id;
  @override
  String get orderId;
  @override
  String get driverId;
  @override
  DeliveryStatus get status;
  @override
  Address get pickupAddress;
  @override
  Address get deliveryAddress;
  @override
  String? get driverName;
  @override
  String? get driverPhone;
  @override
  double? get driverLat;
  @override
  double? get driverLng;
  @override
  DateTime? get estimatedArrival;
  @override
  DateTime? get pickedUpAt;
  @override
  DateTime? get deliveredAt;
  @override
  String? get notes;
  @override
  DateTime get createdAt;

  /// Create a copy of Delivery
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeliveryImplCopyWith<_$DeliveryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
