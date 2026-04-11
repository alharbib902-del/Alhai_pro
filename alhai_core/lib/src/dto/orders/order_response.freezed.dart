// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

OrderResponse _$OrderResponseFromJson(Map<String, dynamic> json) {
  return _OrderResponse.fromJson(json);
}

/// @nodoc
mixin _$OrderResponse {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'order_number')
  String? get orderNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_id')
  String get customerId => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_name')
  String? get customerName => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_phone')
  String? get customerPhone => throw _privateConstructorUsedError;
  @JsonKey(name: 'store_id')
  String get storeId => throw _privateConstructorUsedError;
  @JsonKey(name: 'store_name')
  String? get storeName => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  List<OrderItemResponse> get items => throw _privateConstructorUsedError;
  double get subtotal => throw _privateConstructorUsedError;
  double get discount => throw _privateConstructorUsedError;
  @JsonKey(name: 'delivery_fee')
  double get deliveryFee => throw _privateConstructorUsedError;
  double get tax => throw _privateConstructorUsedError;
  double get total => throw _privateConstructorUsedError;
  @JsonKey(name: 'payment_method')
  String get paymentMethod => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_paid')
  bool get isPaid => throw _privateConstructorUsedError;
  @JsonKey(name: 'address_id')
  String? get addressId => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  @JsonKey(name: 'cancellation_reason')
  String? get cancellationReason => throw _privateConstructorUsedError;
  @JsonKey(name: 'confirmed_at')
  String? get confirmedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'preparing_at')
  String? get preparingAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'ready_at')
  String? get readyAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'delivered_at')
  String? get deliveredAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'cancelled_at')
  String? get cancelledAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  String? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this OrderResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrderResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderResponseCopyWith<OrderResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderResponseCopyWith<$Res> {
  factory $OrderResponseCopyWith(
    OrderResponse value,
    $Res Function(OrderResponse) then,
  ) = _$OrderResponseCopyWithImpl<$Res, OrderResponse>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'order_number') String? orderNumber,
    @JsonKey(name: 'customer_id') String customerId,
    @JsonKey(name: 'customer_name') String? customerName,
    @JsonKey(name: 'customer_phone') String? customerPhone,
    @JsonKey(name: 'store_id') String storeId,
    @JsonKey(name: 'store_name') String? storeName,
    String status,
    List<OrderItemResponse> items,
    double subtotal,
    double discount,
    @JsonKey(name: 'delivery_fee') double deliveryFee,
    double tax,
    double total,
    @JsonKey(name: 'payment_method') String paymentMethod,
    @JsonKey(name: 'is_paid') bool isPaid,
    @JsonKey(name: 'address_id') String? addressId,
    String? notes,
    @JsonKey(name: 'cancellation_reason') String? cancellationReason,
    @JsonKey(name: 'confirmed_at') String? confirmedAt,
    @JsonKey(name: 'preparing_at') String? preparingAt,
    @JsonKey(name: 'ready_at') String? readyAt,
    @JsonKey(name: 'delivered_at') String? deliveredAt,
    @JsonKey(name: 'cancelled_at') String? cancelledAt,
    @JsonKey(name: 'created_at') String createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  });
}

/// @nodoc
class _$OrderResponseCopyWithImpl<$Res, $Val extends OrderResponse>
    implements $OrderResponseCopyWith<$Res> {
  _$OrderResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderNumber = freezed,
    Object? customerId = null,
    Object? customerName = freezed,
    Object? customerPhone = freezed,
    Object? storeId = null,
    Object? storeName = freezed,
    Object? status = null,
    Object? items = null,
    Object? subtotal = null,
    Object? discount = null,
    Object? deliveryFee = null,
    Object? tax = null,
    Object? total = null,
    Object? paymentMethod = null,
    Object? isPaid = null,
    Object? addressId = freezed,
    Object? notes = freezed,
    Object? cancellationReason = freezed,
    Object? confirmedAt = freezed,
    Object? preparingAt = freezed,
    Object? readyAt = freezed,
    Object? deliveredAt = freezed,
    Object? cancelledAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            orderNumber: freezed == orderNumber
                ? _value.orderNumber
                : orderNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            customerId: null == customerId
                ? _value.customerId
                : customerId // ignore: cast_nullable_to_non_nullable
                      as String,
            customerName: freezed == customerName
                ? _value.customerName
                : customerName // ignore: cast_nullable_to_non_nullable
                      as String?,
            customerPhone: freezed == customerPhone
                ? _value.customerPhone
                : customerPhone // ignore: cast_nullable_to_non_nullable
                      as String?,
            storeId: null == storeId
                ? _value.storeId
                : storeId // ignore: cast_nullable_to_non_nullable
                      as String,
            storeName: freezed == storeName
                ? _value.storeName
                : storeName // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<OrderItemResponse>,
            subtotal: null == subtotal
                ? _value.subtotal
                : subtotal // ignore: cast_nullable_to_non_nullable
                      as double,
            discount: null == discount
                ? _value.discount
                : discount // ignore: cast_nullable_to_non_nullable
                      as double,
            deliveryFee: null == deliveryFee
                ? _value.deliveryFee
                : deliveryFee // ignore: cast_nullable_to_non_nullable
                      as double,
            tax: null == tax
                ? _value.tax
                : tax // ignore: cast_nullable_to_non_nullable
                      as double,
            total: null == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                      as double,
            paymentMethod: null == paymentMethod
                ? _value.paymentMethod
                : paymentMethod // ignore: cast_nullable_to_non_nullable
                      as String,
            isPaid: null == isPaid
                ? _value.isPaid
                : isPaid // ignore: cast_nullable_to_non_nullable
                      as bool,
            addressId: freezed == addressId
                ? _value.addressId
                : addressId // ignore: cast_nullable_to_non_nullable
                      as String?,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            cancellationReason: freezed == cancellationReason
                ? _value.cancellationReason
                : cancellationReason // ignore: cast_nullable_to_non_nullable
                      as String?,
            confirmedAt: freezed == confirmedAt
                ? _value.confirmedAt
                : confirmedAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            preparingAt: freezed == preparingAt
                ? _value.preparingAt
                : preparingAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            readyAt: freezed == readyAt
                ? _value.readyAt
                : readyAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            deliveredAt: freezed == deliveredAt
                ? _value.deliveredAt
                : deliveredAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            cancelledAt: freezed == cancelledAt
                ? _value.cancelledAt
                : cancelledAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OrderResponseImplCopyWith<$Res>
    implements $OrderResponseCopyWith<$Res> {
  factory _$$OrderResponseImplCopyWith(
    _$OrderResponseImpl value,
    $Res Function(_$OrderResponseImpl) then,
  ) = __$$OrderResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'order_number') String? orderNumber,
    @JsonKey(name: 'customer_id') String customerId,
    @JsonKey(name: 'customer_name') String? customerName,
    @JsonKey(name: 'customer_phone') String? customerPhone,
    @JsonKey(name: 'store_id') String storeId,
    @JsonKey(name: 'store_name') String? storeName,
    String status,
    List<OrderItemResponse> items,
    double subtotal,
    double discount,
    @JsonKey(name: 'delivery_fee') double deliveryFee,
    double tax,
    double total,
    @JsonKey(name: 'payment_method') String paymentMethod,
    @JsonKey(name: 'is_paid') bool isPaid,
    @JsonKey(name: 'address_id') String? addressId,
    String? notes,
    @JsonKey(name: 'cancellation_reason') String? cancellationReason,
    @JsonKey(name: 'confirmed_at') String? confirmedAt,
    @JsonKey(name: 'preparing_at') String? preparingAt,
    @JsonKey(name: 'ready_at') String? readyAt,
    @JsonKey(name: 'delivered_at') String? deliveredAt,
    @JsonKey(name: 'cancelled_at') String? cancelledAt,
    @JsonKey(name: 'created_at') String createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  });
}

/// @nodoc
class __$$OrderResponseImplCopyWithImpl<$Res>
    extends _$OrderResponseCopyWithImpl<$Res, _$OrderResponseImpl>
    implements _$$OrderResponseImplCopyWith<$Res> {
  __$$OrderResponseImplCopyWithImpl(
    _$OrderResponseImpl _value,
    $Res Function(_$OrderResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OrderResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderNumber = freezed,
    Object? customerId = null,
    Object? customerName = freezed,
    Object? customerPhone = freezed,
    Object? storeId = null,
    Object? storeName = freezed,
    Object? status = null,
    Object? items = null,
    Object? subtotal = null,
    Object? discount = null,
    Object? deliveryFee = null,
    Object? tax = null,
    Object? total = null,
    Object? paymentMethod = null,
    Object? isPaid = null,
    Object? addressId = freezed,
    Object? notes = freezed,
    Object? cancellationReason = freezed,
    Object? confirmedAt = freezed,
    Object? preparingAt = freezed,
    Object? readyAt = freezed,
    Object? deliveredAt = freezed,
    Object? cancelledAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$OrderResponseImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        orderNumber: freezed == orderNumber
            ? _value.orderNumber
            : orderNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        customerId: null == customerId
            ? _value.customerId
            : customerId // ignore: cast_nullable_to_non_nullable
                  as String,
        customerName: freezed == customerName
            ? _value.customerName
            : customerName // ignore: cast_nullable_to_non_nullable
                  as String?,
        customerPhone: freezed == customerPhone
            ? _value.customerPhone
            : customerPhone // ignore: cast_nullable_to_non_nullable
                  as String?,
        storeId: null == storeId
            ? _value.storeId
            : storeId // ignore: cast_nullable_to_non_nullable
                  as String,
        storeName: freezed == storeName
            ? _value.storeName
            : storeName // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<OrderItemResponse>,
        subtotal: null == subtotal
            ? _value.subtotal
            : subtotal // ignore: cast_nullable_to_non_nullable
                  as double,
        discount: null == discount
            ? _value.discount
            : discount // ignore: cast_nullable_to_non_nullable
                  as double,
        deliveryFee: null == deliveryFee
            ? _value.deliveryFee
            : deliveryFee // ignore: cast_nullable_to_non_nullable
                  as double,
        tax: null == tax
            ? _value.tax
            : tax // ignore: cast_nullable_to_non_nullable
                  as double,
        total: null == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as double,
        paymentMethod: null == paymentMethod
            ? _value.paymentMethod
            : paymentMethod // ignore: cast_nullable_to_non_nullable
                  as String,
        isPaid: null == isPaid
            ? _value.isPaid
            : isPaid // ignore: cast_nullable_to_non_nullable
                  as bool,
        addressId: freezed == addressId
            ? _value.addressId
            : addressId // ignore: cast_nullable_to_non_nullable
                  as String?,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        cancellationReason: freezed == cancellationReason
            ? _value.cancellationReason
            : cancellationReason // ignore: cast_nullable_to_non_nullable
                  as String?,
        confirmedAt: freezed == confirmedAt
            ? _value.confirmedAt
            : confirmedAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        preparingAt: freezed == preparingAt
            ? _value.preparingAt
            : preparingAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        readyAt: freezed == readyAt
            ? _value.readyAt
            : readyAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        deliveredAt: freezed == deliveredAt
            ? _value.deliveredAt
            : deliveredAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        cancelledAt: freezed == cancelledAt
            ? _value.cancelledAt
            : cancelledAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderResponseImpl extends _OrderResponse {
  const _$OrderResponseImpl({
    required this.id,
    @JsonKey(name: 'order_number') this.orderNumber,
    @JsonKey(name: 'customer_id') required this.customerId,
    @JsonKey(name: 'customer_name') this.customerName,
    @JsonKey(name: 'customer_phone') this.customerPhone,
    @JsonKey(name: 'store_id') required this.storeId,
    @JsonKey(name: 'store_name') this.storeName,
    required this.status,
    required final List<OrderItemResponse> items,
    required this.subtotal,
    this.discount = 0,
    @JsonKey(name: 'delivery_fee') this.deliveryFee = 0,
    this.tax = 0,
    required this.total,
    @JsonKey(name: 'payment_method') required this.paymentMethod,
    @JsonKey(name: 'is_paid') this.isPaid = false,
    @JsonKey(name: 'address_id') this.addressId,
    this.notes,
    @JsonKey(name: 'cancellation_reason') this.cancellationReason,
    @JsonKey(name: 'confirmed_at') this.confirmedAt,
    @JsonKey(name: 'preparing_at') this.preparingAt,
    @JsonKey(name: 'ready_at') this.readyAt,
    @JsonKey(name: 'delivered_at') this.deliveredAt,
    @JsonKey(name: 'cancelled_at') this.cancelledAt,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'updated_at') this.updatedAt,
  }) : _items = items,
       super._();

  factory _$OrderResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderResponseImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'order_number')
  final String? orderNumber;
  @override
  @JsonKey(name: 'customer_id')
  final String customerId;
  @override
  @JsonKey(name: 'customer_name')
  final String? customerName;
  @override
  @JsonKey(name: 'customer_phone')
  final String? customerPhone;
  @override
  @JsonKey(name: 'store_id')
  final String storeId;
  @override
  @JsonKey(name: 'store_name')
  final String? storeName;
  @override
  final String status;
  final List<OrderItemResponse> _items;
  @override
  List<OrderItemResponse> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final double subtotal;
  @override
  @JsonKey()
  final double discount;
  @override
  @JsonKey(name: 'delivery_fee')
  final double deliveryFee;
  @override
  @JsonKey()
  final double tax;
  @override
  final double total;
  @override
  @JsonKey(name: 'payment_method')
  final String paymentMethod;
  @override
  @JsonKey(name: 'is_paid')
  final bool isPaid;
  @override
  @JsonKey(name: 'address_id')
  final String? addressId;
  @override
  final String? notes;
  @override
  @JsonKey(name: 'cancellation_reason')
  final String? cancellationReason;
  @override
  @JsonKey(name: 'confirmed_at')
  final String? confirmedAt;
  @override
  @JsonKey(name: 'preparing_at')
  final String? preparingAt;
  @override
  @JsonKey(name: 'ready_at')
  final String? readyAt;
  @override
  @JsonKey(name: 'delivered_at')
  final String? deliveredAt;
  @override
  @JsonKey(name: 'cancelled_at')
  final String? cancelledAt;
  @override
  @JsonKey(name: 'created_at')
  final String createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  @override
  String toString() {
    return 'OrderResponse(id: $id, orderNumber: $orderNumber, customerId: $customerId, customerName: $customerName, customerPhone: $customerPhone, storeId: $storeId, storeName: $storeName, status: $status, items: $items, subtotal: $subtotal, discount: $discount, deliveryFee: $deliveryFee, tax: $tax, total: $total, paymentMethod: $paymentMethod, isPaid: $isPaid, addressId: $addressId, notes: $notes, cancellationReason: $cancellationReason, confirmedAt: $confirmedAt, preparingAt: $preparingAt, readyAt: $readyAt, deliveredAt: $deliveredAt, cancelledAt: $cancelledAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderResponseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orderNumber, orderNumber) ||
                other.orderNumber == orderNumber) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.customerPhone, customerPhone) ||
                other.customerPhone == customerPhone) &&
            (identical(other.storeId, storeId) || other.storeId == storeId) &&
            (identical(other.storeName, storeName) ||
                other.storeName == storeName) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.subtotal, subtotal) ||
                other.subtotal == subtotal) &&
            (identical(other.discount, discount) ||
                other.discount == discount) &&
            (identical(other.deliveryFee, deliveryFee) ||
                other.deliveryFee == deliveryFee) &&
            (identical(other.tax, tax) || other.tax == tax) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod) &&
            (identical(other.isPaid, isPaid) || other.isPaid == isPaid) &&
            (identical(other.addressId, addressId) ||
                other.addressId == addressId) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.cancellationReason, cancellationReason) ||
                other.cancellationReason == cancellationReason) &&
            (identical(other.confirmedAt, confirmedAt) ||
                other.confirmedAt == confirmedAt) &&
            (identical(other.preparingAt, preparingAt) ||
                other.preparingAt == preparingAt) &&
            (identical(other.readyAt, readyAt) || other.readyAt == readyAt) &&
            (identical(other.deliveredAt, deliveredAt) ||
                other.deliveredAt == deliveredAt) &&
            (identical(other.cancelledAt, cancelledAt) ||
                other.cancelledAt == cancelledAt) &&
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
    orderNumber,
    customerId,
    customerName,
    customerPhone,
    storeId,
    storeName,
    status,
    const DeepCollectionEquality().hash(_items),
    subtotal,
    discount,
    deliveryFee,
    tax,
    total,
    paymentMethod,
    isPaid,
    addressId,
    notes,
    cancellationReason,
    confirmedAt,
    preparingAt,
    readyAt,
    deliveredAt,
    cancelledAt,
    createdAt,
    updatedAt,
  ]);

  /// Create a copy of OrderResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderResponseImplCopyWith<_$OrderResponseImpl> get copyWith =>
      __$$OrderResponseImplCopyWithImpl<_$OrderResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderResponseImplToJson(this);
  }
}

abstract class _OrderResponse extends OrderResponse {
  const factory _OrderResponse({
    required final String id,
    @JsonKey(name: 'order_number') final String? orderNumber,
    @JsonKey(name: 'customer_id') required final String customerId,
    @JsonKey(name: 'customer_name') final String? customerName,
    @JsonKey(name: 'customer_phone') final String? customerPhone,
    @JsonKey(name: 'store_id') required final String storeId,
    @JsonKey(name: 'store_name') final String? storeName,
    required final String status,
    required final List<OrderItemResponse> items,
    required final double subtotal,
    final double discount,
    @JsonKey(name: 'delivery_fee') final double deliveryFee,
    final double tax,
    required final double total,
    @JsonKey(name: 'payment_method') required final String paymentMethod,
    @JsonKey(name: 'is_paid') final bool isPaid,
    @JsonKey(name: 'address_id') final String? addressId,
    final String? notes,
    @JsonKey(name: 'cancellation_reason') final String? cancellationReason,
    @JsonKey(name: 'confirmed_at') final String? confirmedAt,
    @JsonKey(name: 'preparing_at') final String? preparingAt,
    @JsonKey(name: 'ready_at') final String? readyAt,
    @JsonKey(name: 'delivered_at') final String? deliveredAt,
    @JsonKey(name: 'cancelled_at') final String? cancelledAt,
    @JsonKey(name: 'created_at') required final String createdAt,
    @JsonKey(name: 'updated_at') final String? updatedAt,
  }) = _$OrderResponseImpl;
  const _OrderResponse._() : super._();

  factory _OrderResponse.fromJson(Map<String, dynamic> json) =
      _$OrderResponseImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'order_number')
  String? get orderNumber;
  @override
  @JsonKey(name: 'customer_id')
  String get customerId;
  @override
  @JsonKey(name: 'customer_name')
  String? get customerName;
  @override
  @JsonKey(name: 'customer_phone')
  String? get customerPhone;
  @override
  @JsonKey(name: 'store_id')
  String get storeId;
  @override
  @JsonKey(name: 'store_name')
  String? get storeName;
  @override
  String get status;
  @override
  List<OrderItemResponse> get items;
  @override
  double get subtotal;
  @override
  double get discount;
  @override
  @JsonKey(name: 'delivery_fee')
  double get deliveryFee;
  @override
  double get tax;
  @override
  double get total;
  @override
  @JsonKey(name: 'payment_method')
  String get paymentMethod;
  @override
  @JsonKey(name: 'is_paid')
  bool get isPaid;
  @override
  @JsonKey(name: 'address_id')
  String? get addressId;
  @override
  String? get notes;
  @override
  @JsonKey(name: 'cancellation_reason')
  String? get cancellationReason;
  @override
  @JsonKey(name: 'confirmed_at')
  String? get confirmedAt;
  @override
  @JsonKey(name: 'preparing_at')
  String? get preparingAt;
  @override
  @JsonKey(name: 'ready_at')
  String? get readyAt;
  @override
  @JsonKey(name: 'delivered_at')
  String? get deliveredAt;
  @override
  @JsonKey(name: 'cancelled_at')
  String? get cancelledAt;
  @override
  @JsonKey(name: 'created_at')
  String get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  String? get updatedAt;

  /// Create a copy of OrderResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderResponseImplCopyWith<_$OrderResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
