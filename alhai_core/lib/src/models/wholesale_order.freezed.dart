// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wholesale_order.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WholesaleOrder _$WholesaleOrderFromJson(Map<String, dynamic> json) {
  return _WholesaleOrder.fromJson(json);
}

/// @nodoc
mixin _$WholesaleOrder {
  String get id => throw _privateConstructorUsedError;
  String get orderNumber => throw _privateConstructorUsedError;
  String get distributorId => throw _privateConstructorUsedError;
  String get storeId => throw _privateConstructorUsedError;
  String get storeName => throw _privateConstructorUsedError;
  WholesaleOrderStatus get status => throw _privateConstructorUsedError;
  WholesalePaymentMethod get paymentMethod =>
      throw _privateConstructorUsedError;
  List<WholesaleOrderItem> get items => throw _privateConstructorUsedError;
  double get subtotal => throw _privateConstructorUsedError;
  double get discount => throw _privateConstructorUsedError;
  double get tax => throw _privateConstructorUsedError;
  double get total => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get deliveryAddress => throw _privateConstructorUsedError;
  DateTime? get expectedDeliveryDate => throw _privateConstructorUsedError;
  DateTime? get confirmedAt => throw _privateConstructorUsedError;
  DateTime? get shippedAt => throw _privateConstructorUsedError;
  DateTime? get deliveredAt => throw _privateConstructorUsedError;
  DateTime? get cancelledAt => throw _privateConstructorUsedError;
  String? get cancellationReason => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this WholesaleOrder to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WholesaleOrder
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WholesaleOrderCopyWith<WholesaleOrder> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WholesaleOrderCopyWith<$Res> {
  factory $WholesaleOrderCopyWith(
          WholesaleOrder value, $Res Function(WholesaleOrder) then) =
      _$WholesaleOrderCopyWithImpl<$Res, WholesaleOrder>;
  @useResult
  $Res call(
      {String id,
      String orderNumber,
      String distributorId,
      String storeId,
      String storeName,
      WholesaleOrderStatus status,
      WholesalePaymentMethod paymentMethod,
      List<WholesaleOrderItem> items,
      double subtotal,
      double discount,
      double tax,
      double total,
      String? notes,
      String? deliveryAddress,
      DateTime? expectedDeliveryDate,
      DateTime? confirmedAt,
      DateTime? shippedAt,
      DateTime? deliveredAt,
      DateTime? cancelledAt,
      String? cancellationReason,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$WholesaleOrderCopyWithImpl<$Res, $Val extends WholesaleOrder>
    implements $WholesaleOrderCopyWith<$Res> {
  _$WholesaleOrderCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WholesaleOrder
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderNumber = null,
    Object? distributorId = null,
    Object? storeId = null,
    Object? storeName = null,
    Object? status = null,
    Object? paymentMethod = null,
    Object? items = null,
    Object? subtotal = null,
    Object? discount = null,
    Object? tax = null,
    Object? total = null,
    Object? notes = freezed,
    Object? deliveryAddress = freezed,
    Object? expectedDeliveryDate = freezed,
    Object? confirmedAt = freezed,
    Object? shippedAt = freezed,
    Object? deliveredAt = freezed,
    Object? cancelledAt = freezed,
    Object? cancellationReason = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      orderNumber: null == orderNumber
          ? _value.orderNumber
          : orderNumber // ignore: cast_nullable_to_non_nullable
              as String,
      distributorId: null == distributorId
          ? _value.distributorId
          : distributorId // ignore: cast_nullable_to_non_nullable
              as String,
      storeId: null == storeId
          ? _value.storeId
          : storeId // ignore: cast_nullable_to_non_nullable
              as String,
      storeName: null == storeName
          ? _value.storeName
          : storeName // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as WholesaleOrderStatus,
      paymentMethod: null == paymentMethod
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as WholesalePaymentMethod,
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<WholesaleOrderItem>,
      subtotal: null == subtotal
          ? _value.subtotal
          : subtotal // ignore: cast_nullable_to_non_nullable
              as double,
      discount: null == discount
          ? _value.discount
          : discount // ignore: cast_nullable_to_non_nullable
              as double,
      tax: null == tax
          ? _value.tax
          : tax // ignore: cast_nullable_to_non_nullable
              as double,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as double,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      deliveryAddress: freezed == deliveryAddress
          ? _value.deliveryAddress
          : deliveryAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      expectedDeliveryDate: freezed == expectedDeliveryDate
          ? _value.expectedDeliveryDate
          : expectedDeliveryDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      confirmedAt: freezed == confirmedAt
          ? _value.confirmedAt
          : confirmedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      shippedAt: freezed == shippedAt
          ? _value.shippedAt
          : shippedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      deliveredAt: freezed == deliveredAt
          ? _value.deliveredAt
          : deliveredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      cancelledAt: freezed == cancelledAt
          ? _value.cancelledAt
          : cancelledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      cancellationReason: freezed == cancellationReason
          ? _value.cancellationReason
          : cancellationReason // ignore: cast_nullable_to_non_nullable
              as String?,
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
abstract class _$$WholesaleOrderImplCopyWith<$Res>
    implements $WholesaleOrderCopyWith<$Res> {
  factory _$$WholesaleOrderImplCopyWith(_$WholesaleOrderImpl value,
          $Res Function(_$WholesaleOrderImpl) then) =
      __$$WholesaleOrderImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String orderNumber,
      String distributorId,
      String storeId,
      String storeName,
      WholesaleOrderStatus status,
      WholesalePaymentMethod paymentMethod,
      List<WholesaleOrderItem> items,
      double subtotal,
      double discount,
      double tax,
      double total,
      String? notes,
      String? deliveryAddress,
      DateTime? expectedDeliveryDate,
      DateTime? confirmedAt,
      DateTime? shippedAt,
      DateTime? deliveredAt,
      DateTime? cancelledAt,
      String? cancellationReason,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$WholesaleOrderImplCopyWithImpl<$Res>
    extends _$WholesaleOrderCopyWithImpl<$Res, _$WholesaleOrderImpl>
    implements _$$WholesaleOrderImplCopyWith<$Res> {
  __$$WholesaleOrderImplCopyWithImpl(
      _$WholesaleOrderImpl _value, $Res Function(_$WholesaleOrderImpl) _then)
      : super(_value, _then);

  /// Create a copy of WholesaleOrder
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderNumber = null,
    Object? distributorId = null,
    Object? storeId = null,
    Object? storeName = null,
    Object? status = null,
    Object? paymentMethod = null,
    Object? items = null,
    Object? subtotal = null,
    Object? discount = null,
    Object? tax = null,
    Object? total = null,
    Object? notes = freezed,
    Object? deliveryAddress = freezed,
    Object? expectedDeliveryDate = freezed,
    Object? confirmedAt = freezed,
    Object? shippedAt = freezed,
    Object? deliveredAt = freezed,
    Object? cancelledAt = freezed,
    Object? cancellationReason = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$WholesaleOrderImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      orderNumber: null == orderNumber
          ? _value.orderNumber
          : orderNumber // ignore: cast_nullable_to_non_nullable
              as String,
      distributorId: null == distributorId
          ? _value.distributorId
          : distributorId // ignore: cast_nullable_to_non_nullable
              as String,
      storeId: null == storeId
          ? _value.storeId
          : storeId // ignore: cast_nullable_to_non_nullable
              as String,
      storeName: null == storeName
          ? _value.storeName
          : storeName // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as WholesaleOrderStatus,
      paymentMethod: null == paymentMethod
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as WholesalePaymentMethod,
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<WholesaleOrderItem>,
      subtotal: null == subtotal
          ? _value.subtotal
          : subtotal // ignore: cast_nullable_to_non_nullable
              as double,
      discount: null == discount
          ? _value.discount
          : discount // ignore: cast_nullable_to_non_nullable
              as double,
      tax: null == tax
          ? _value.tax
          : tax // ignore: cast_nullable_to_non_nullable
              as double,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as double,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      deliveryAddress: freezed == deliveryAddress
          ? _value.deliveryAddress
          : deliveryAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      expectedDeliveryDate: freezed == expectedDeliveryDate
          ? _value.expectedDeliveryDate
          : expectedDeliveryDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      confirmedAt: freezed == confirmedAt
          ? _value.confirmedAt
          : confirmedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      shippedAt: freezed == shippedAt
          ? _value.shippedAt
          : shippedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      deliveredAt: freezed == deliveredAt
          ? _value.deliveredAt
          : deliveredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      cancelledAt: freezed == cancelledAt
          ? _value.cancelledAt
          : cancelledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      cancellationReason: freezed == cancellationReason
          ? _value.cancellationReason
          : cancellationReason // ignore: cast_nullable_to_non_nullable
              as String?,
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
class _$WholesaleOrderImpl extends _WholesaleOrder {
  const _$WholesaleOrderImpl(
      {required this.id,
      required this.orderNumber,
      required this.distributorId,
      required this.storeId,
      required this.storeName,
      required this.status,
      required this.paymentMethod,
      required final List<WholesaleOrderItem> items,
      required this.subtotal,
      this.discount = 0.0,
      this.tax = 0.0,
      required this.total,
      this.notes,
      this.deliveryAddress,
      this.expectedDeliveryDate,
      this.confirmedAt,
      this.shippedAt,
      this.deliveredAt,
      this.cancelledAt,
      this.cancellationReason,
      required this.createdAt,
      this.updatedAt})
      : _items = items,
        super._();

  factory _$WholesaleOrderImpl.fromJson(Map<String, dynamic> json) =>
      _$$WholesaleOrderImplFromJson(json);

  @override
  final String id;
  @override
  final String orderNumber;
  @override
  final String distributorId;
  @override
  final String storeId;
  @override
  final String storeName;
  @override
  final WholesaleOrderStatus status;
  @override
  final WholesalePaymentMethod paymentMethod;
  final List<WholesaleOrderItem> _items;
  @override
  List<WholesaleOrderItem> get items {
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
  @JsonKey()
  final double tax;
  @override
  final double total;
  @override
  final String? notes;
  @override
  final String? deliveryAddress;
  @override
  final DateTime? expectedDeliveryDate;
  @override
  final DateTime? confirmedAt;
  @override
  final DateTime? shippedAt;
  @override
  final DateTime? deliveredAt;
  @override
  final DateTime? cancelledAt;
  @override
  final String? cancellationReason;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'WholesaleOrder(id: $id, orderNumber: $orderNumber, distributorId: $distributorId, storeId: $storeId, storeName: $storeName, status: $status, paymentMethod: $paymentMethod, items: $items, subtotal: $subtotal, discount: $discount, tax: $tax, total: $total, notes: $notes, deliveryAddress: $deliveryAddress, expectedDeliveryDate: $expectedDeliveryDate, confirmedAt: $confirmedAt, shippedAt: $shippedAt, deliveredAt: $deliveredAt, cancelledAt: $cancelledAt, cancellationReason: $cancellationReason, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WholesaleOrderImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orderNumber, orderNumber) ||
                other.orderNumber == orderNumber) &&
            (identical(other.distributorId, distributorId) ||
                other.distributorId == distributorId) &&
            (identical(other.storeId, storeId) || other.storeId == storeId) &&
            (identical(other.storeName, storeName) ||
                other.storeName == storeName) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.subtotal, subtotal) ||
                other.subtotal == subtotal) &&
            (identical(other.discount, discount) ||
                other.discount == discount) &&
            (identical(other.tax, tax) || other.tax == tax) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.deliveryAddress, deliveryAddress) ||
                other.deliveryAddress == deliveryAddress) &&
            (identical(other.expectedDeliveryDate, expectedDeliveryDate) ||
                other.expectedDeliveryDate == expectedDeliveryDate) &&
            (identical(other.confirmedAt, confirmedAt) ||
                other.confirmedAt == confirmedAt) &&
            (identical(other.shippedAt, shippedAt) ||
                other.shippedAt == shippedAt) &&
            (identical(other.deliveredAt, deliveredAt) ||
                other.deliveredAt == deliveredAt) &&
            (identical(other.cancelledAt, cancelledAt) ||
                other.cancelledAt == cancelledAt) &&
            (identical(other.cancellationReason, cancellationReason) ||
                other.cancellationReason == cancellationReason) &&
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
        distributorId,
        storeId,
        storeName,
        status,
        paymentMethod,
        const DeepCollectionEquality().hash(_items),
        subtotal,
        discount,
        tax,
        total,
        notes,
        deliveryAddress,
        expectedDeliveryDate,
        confirmedAt,
        shippedAt,
        deliveredAt,
        cancelledAt,
        cancellationReason,
        createdAt,
        updatedAt
      ]);

  /// Create a copy of WholesaleOrder
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WholesaleOrderImplCopyWith<_$WholesaleOrderImpl> get copyWith =>
      __$$WholesaleOrderImplCopyWithImpl<_$WholesaleOrderImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WholesaleOrderImplToJson(
      this,
    );
  }
}

abstract class _WholesaleOrder extends WholesaleOrder {
  const factory _WholesaleOrder(
      {required final String id,
      required final String orderNumber,
      required final String distributorId,
      required final String storeId,
      required final String storeName,
      required final WholesaleOrderStatus status,
      required final WholesalePaymentMethod paymentMethod,
      required final List<WholesaleOrderItem> items,
      required final double subtotal,
      final double discount,
      final double tax,
      required final double total,
      final String? notes,
      final String? deliveryAddress,
      final DateTime? expectedDeliveryDate,
      final DateTime? confirmedAt,
      final DateTime? shippedAt,
      final DateTime? deliveredAt,
      final DateTime? cancelledAt,
      final String? cancellationReason,
      required final DateTime createdAt,
      final DateTime? updatedAt}) = _$WholesaleOrderImpl;
  const _WholesaleOrder._() : super._();

  factory _WholesaleOrder.fromJson(Map<String, dynamic> json) =
      _$WholesaleOrderImpl.fromJson;

  @override
  String get id;
  @override
  String get orderNumber;
  @override
  String get distributorId;
  @override
  String get storeId;
  @override
  String get storeName;
  @override
  WholesaleOrderStatus get status;
  @override
  WholesalePaymentMethod get paymentMethod;
  @override
  List<WholesaleOrderItem> get items;
  @override
  double get subtotal;
  @override
  double get discount;
  @override
  double get tax;
  @override
  double get total;
  @override
  String? get notes;
  @override
  String? get deliveryAddress;
  @override
  DateTime? get expectedDeliveryDate;
  @override
  DateTime? get confirmedAt;
  @override
  DateTime? get shippedAt;
  @override
  DateTime? get deliveredAt;
  @override
  DateTime? get cancelledAt;
  @override
  String? get cancellationReason;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of WholesaleOrder
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WholesaleOrderImplCopyWith<_$WholesaleOrderImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WholesaleOrderItem _$WholesaleOrderItemFromJson(Map<String, dynamic> json) {
  return _WholesaleOrderItem.fromJson(json);
}

/// @nodoc
mixin _$WholesaleOrderItem {
  String get productId => throw _privateConstructorUsedError;
  String get productName => throw _privateConstructorUsedError;
  String? get productSku => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;
  double get unitPrice => throw _privateConstructorUsedError;
  double get totalPrice => throw _privateConstructorUsedError;
  double? get discount => throw _privateConstructorUsedError;
  String? get unit => throw _privateConstructorUsedError;

  /// Serializes this WholesaleOrderItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WholesaleOrderItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WholesaleOrderItemCopyWith<WholesaleOrderItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WholesaleOrderItemCopyWith<$Res> {
  factory $WholesaleOrderItemCopyWith(
          WholesaleOrderItem value, $Res Function(WholesaleOrderItem) then) =
      _$WholesaleOrderItemCopyWithImpl<$Res, WholesaleOrderItem>;
  @useResult
  $Res call(
      {String productId,
      String productName,
      String? productSku,
      int quantity,
      double unitPrice,
      double totalPrice,
      double? discount,
      String? unit});
}

/// @nodoc
class _$WholesaleOrderItemCopyWithImpl<$Res, $Val extends WholesaleOrderItem>
    implements $WholesaleOrderItemCopyWith<$Res> {
  _$WholesaleOrderItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WholesaleOrderItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = null,
    Object? productName = null,
    Object? productSku = freezed,
    Object? quantity = null,
    Object? unitPrice = null,
    Object? totalPrice = null,
    Object? discount = freezed,
    Object? unit = freezed,
  }) {
    return _then(_value.copyWith(
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
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      unitPrice: null == unitPrice
          ? _value.unitPrice
          : unitPrice // ignore: cast_nullable_to_non_nullable
              as double,
      totalPrice: null == totalPrice
          ? _value.totalPrice
          : totalPrice // ignore: cast_nullable_to_non_nullable
              as double,
      discount: freezed == discount
          ? _value.discount
          : discount // ignore: cast_nullable_to_non_nullable
              as double?,
      unit: freezed == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WholesaleOrderItemImplCopyWith<$Res>
    implements $WholesaleOrderItemCopyWith<$Res> {
  factory _$$WholesaleOrderItemImplCopyWith(_$WholesaleOrderItemImpl value,
          $Res Function(_$WholesaleOrderItemImpl) then) =
      __$$WholesaleOrderItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String productId,
      String productName,
      String? productSku,
      int quantity,
      double unitPrice,
      double totalPrice,
      double? discount,
      String? unit});
}

/// @nodoc
class __$$WholesaleOrderItemImplCopyWithImpl<$Res>
    extends _$WholesaleOrderItemCopyWithImpl<$Res, _$WholesaleOrderItemImpl>
    implements _$$WholesaleOrderItemImplCopyWith<$Res> {
  __$$WholesaleOrderItemImplCopyWithImpl(_$WholesaleOrderItemImpl _value,
      $Res Function(_$WholesaleOrderItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of WholesaleOrderItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = null,
    Object? productName = null,
    Object? productSku = freezed,
    Object? quantity = null,
    Object? unitPrice = null,
    Object? totalPrice = null,
    Object? discount = freezed,
    Object? unit = freezed,
  }) {
    return _then(_$WholesaleOrderItemImpl(
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
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      unitPrice: null == unitPrice
          ? _value.unitPrice
          : unitPrice // ignore: cast_nullable_to_non_nullable
              as double,
      totalPrice: null == totalPrice
          ? _value.totalPrice
          : totalPrice // ignore: cast_nullable_to_non_nullable
              as double,
      discount: freezed == discount
          ? _value.discount
          : discount // ignore: cast_nullable_to_non_nullable
              as double?,
      unit: freezed == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WholesaleOrderItemImpl extends _WholesaleOrderItem {
  const _$WholesaleOrderItemImpl(
      {required this.productId,
      required this.productName,
      this.productSku,
      required this.quantity,
      required this.unitPrice,
      required this.totalPrice,
      this.discount,
      this.unit})
      : super._();

  factory _$WholesaleOrderItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$WholesaleOrderItemImplFromJson(json);

  @override
  final String productId;
  @override
  final String productName;
  @override
  final String? productSku;
  @override
  final int quantity;
  @override
  final double unitPrice;
  @override
  final double totalPrice;
  @override
  final double? discount;
  @override
  final String? unit;

  @override
  String toString() {
    return 'WholesaleOrderItem(productId: $productId, productName: $productName, productSku: $productSku, quantity: $quantity, unitPrice: $unitPrice, totalPrice: $totalPrice, discount: $discount, unit: $unit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WholesaleOrderItemImpl &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.productName, productName) ||
                other.productName == productName) &&
            (identical(other.productSku, productSku) ||
                other.productSku == productSku) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.unitPrice, unitPrice) ||
                other.unitPrice == unitPrice) &&
            (identical(other.totalPrice, totalPrice) ||
                other.totalPrice == totalPrice) &&
            (identical(other.discount, discount) ||
                other.discount == discount) &&
            (identical(other.unit, unit) || other.unit == unit));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, productId, productName,
      productSku, quantity, unitPrice, totalPrice, discount, unit);

  /// Create a copy of WholesaleOrderItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WholesaleOrderItemImplCopyWith<_$WholesaleOrderItemImpl> get copyWith =>
      __$$WholesaleOrderItemImplCopyWithImpl<_$WholesaleOrderItemImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WholesaleOrderItemImplToJson(
      this,
    );
  }
}

abstract class _WholesaleOrderItem extends WholesaleOrderItem {
  const factory _WholesaleOrderItem(
      {required final String productId,
      required final String productName,
      final String? productSku,
      required final int quantity,
      required final double unitPrice,
      required final double totalPrice,
      final double? discount,
      final String? unit}) = _$WholesaleOrderItemImpl;
  const _WholesaleOrderItem._() : super._();

  factory _WholesaleOrderItem.fromJson(Map<String, dynamic> json) =
      _$WholesaleOrderItemImpl.fromJson;

  @override
  String get productId;
  @override
  String get productName;
  @override
  String? get productSku;
  @override
  int get quantity;
  @override
  double get unitPrice;
  @override
  double get totalPrice;
  @override
  double? get discount;
  @override
  String? get unit;

  /// Create a copy of WholesaleOrderItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WholesaleOrderItemImplCopyWith<_$WholesaleOrderItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
