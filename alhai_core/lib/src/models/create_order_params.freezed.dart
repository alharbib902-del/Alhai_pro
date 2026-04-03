// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_order_params.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CreateOrderParams _$CreateOrderParamsFromJson(Map<String, dynamic> json) {
  return _CreateOrderParams.fromJson(json);
}

/// @nodoc
mixin _$CreateOrderParams {
  String get clientOrderId => throw _privateConstructorUsedError;
  String get storeId => throw _privateConstructorUsedError;
  List<OrderItem> get items => throw _privateConstructorUsedError;
  String? get addressId => throw _privateConstructorUsedError;
  String? get deliveryAddress => throw _privateConstructorUsedError;
  PaymentMethod get paymentMethod => throw _privateConstructorUsedError;

  /// Serializes this CreateOrderParams to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateOrderParams
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateOrderParamsCopyWith<CreateOrderParams> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateOrderParamsCopyWith<$Res> {
  factory $CreateOrderParamsCopyWith(
          CreateOrderParams value, $Res Function(CreateOrderParams) then) =
      _$CreateOrderParamsCopyWithImpl<$Res, CreateOrderParams>;
  @useResult
  $Res call(
      {String clientOrderId,
      String storeId,
      List<OrderItem> items,
      String? addressId,
      String? deliveryAddress,
      PaymentMethod paymentMethod});
}

/// @nodoc
class _$CreateOrderParamsCopyWithImpl<$Res, $Val extends CreateOrderParams>
    implements $CreateOrderParamsCopyWith<$Res> {
  _$CreateOrderParamsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateOrderParams
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? clientOrderId = null,
    Object? storeId = null,
    Object? items = null,
    Object? addressId = freezed,
    Object? deliveryAddress = freezed,
    Object? paymentMethod = null,
  }) {
    return _then(_value.copyWith(
      clientOrderId: null == clientOrderId
          ? _value.clientOrderId
          : clientOrderId // ignore: cast_nullable_to_non_nullable
              as String,
      storeId: null == storeId
          ? _value.storeId
          : storeId // ignore: cast_nullable_to_non_nullable
              as String,
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<OrderItem>,
      addressId: freezed == addressId
          ? _value.addressId
          : addressId // ignore: cast_nullable_to_non_nullable
              as String?,
      deliveryAddress: freezed == deliveryAddress
          ? _value.deliveryAddress
          : deliveryAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      paymentMethod: null == paymentMethod
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as PaymentMethod,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreateOrderParamsImplCopyWith<$Res>
    implements $CreateOrderParamsCopyWith<$Res> {
  factory _$$CreateOrderParamsImplCopyWith(_$CreateOrderParamsImpl value,
          $Res Function(_$CreateOrderParamsImpl) then) =
      __$$CreateOrderParamsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String clientOrderId,
      String storeId,
      List<OrderItem> items,
      String? addressId,
      String? deliveryAddress,
      PaymentMethod paymentMethod});
}

/// @nodoc
class __$$CreateOrderParamsImplCopyWithImpl<$Res>
    extends _$CreateOrderParamsCopyWithImpl<$Res, _$CreateOrderParamsImpl>
    implements _$$CreateOrderParamsImplCopyWith<$Res> {
  __$$CreateOrderParamsImplCopyWithImpl(_$CreateOrderParamsImpl _value,
      $Res Function(_$CreateOrderParamsImpl) _then)
      : super(_value, _then);

  /// Create a copy of CreateOrderParams
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? clientOrderId = null,
    Object? storeId = null,
    Object? items = null,
    Object? addressId = freezed,
    Object? deliveryAddress = freezed,
    Object? paymentMethod = null,
  }) {
    return _then(_$CreateOrderParamsImpl(
      clientOrderId: null == clientOrderId
          ? _value.clientOrderId
          : clientOrderId // ignore: cast_nullable_to_non_nullable
              as String,
      storeId: null == storeId
          ? _value.storeId
          : storeId // ignore: cast_nullable_to_non_nullable
              as String,
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<OrderItem>,
      addressId: freezed == addressId
          ? _value.addressId
          : addressId // ignore: cast_nullable_to_non_nullable
              as String?,
      deliveryAddress: freezed == deliveryAddress
          ? _value.deliveryAddress
          : deliveryAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      paymentMethod: null == paymentMethod
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as PaymentMethod,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateOrderParamsImpl implements _CreateOrderParams {
  const _$CreateOrderParamsImpl(
      {required this.clientOrderId,
      required this.storeId,
      required final List<OrderItem> items,
      this.addressId,
      this.deliveryAddress,
      required this.paymentMethod})
      : _items = items;

  factory _$CreateOrderParamsImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateOrderParamsImplFromJson(json);

  @override
  final String clientOrderId;
  @override
  final String storeId;
  final List<OrderItem> _items;
  @override
  List<OrderItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final String? addressId;
  @override
  final String? deliveryAddress;
  @override
  final PaymentMethod paymentMethod;

  @override
  String toString() {
    return 'CreateOrderParams(clientOrderId: $clientOrderId, storeId: $storeId, items: $items, addressId: $addressId, deliveryAddress: $deliveryAddress, paymentMethod: $paymentMethod)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateOrderParamsImpl &&
            (identical(other.clientOrderId, clientOrderId) ||
                other.clientOrderId == clientOrderId) &&
            (identical(other.storeId, storeId) || other.storeId == storeId) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.addressId, addressId) ||
                other.addressId == addressId) &&
            (identical(other.deliveryAddress, deliveryAddress) ||
                other.deliveryAddress == deliveryAddress) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      clientOrderId,
      storeId,
      const DeepCollectionEquality().hash(_items),
      addressId,
      deliveryAddress,
      paymentMethod);

  /// Create a copy of CreateOrderParams
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateOrderParamsImplCopyWith<_$CreateOrderParamsImpl> get copyWith =>
      __$$CreateOrderParamsImplCopyWithImpl<_$CreateOrderParamsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateOrderParamsImplToJson(
      this,
    );
  }
}

abstract class _CreateOrderParams implements CreateOrderParams {
  const factory _CreateOrderParams(
      {required final String clientOrderId,
      required final String storeId,
      required final List<OrderItem> items,
      final String? addressId,
      final String? deliveryAddress,
      required final PaymentMethod paymentMethod}) = _$CreateOrderParamsImpl;

  factory _CreateOrderParams.fromJson(Map<String, dynamic> json) =
      _$CreateOrderParamsImpl.fromJson;

  @override
  String get clientOrderId;
  @override
  String get storeId;
  @override
  List<OrderItem> get items;
  @override
  String? get addressId;
  @override
  String? get deliveryAddress;
  @override
  PaymentMethod get paymentMethod;

  /// Create a copy of CreateOrderParams
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateOrderParamsImplCopyWith<_$CreateOrderParamsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
