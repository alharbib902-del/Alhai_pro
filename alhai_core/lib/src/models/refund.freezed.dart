// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'refund.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Refund _$RefundFromJson(Map<String, dynamic> json) {
  return _Refund.fromJson(json);
}

/// @nodoc
mixin _$Refund {
  String get id => throw _privateConstructorUsedError;
  String get originalSaleId => throw _privateConstructorUsedError;
  String get storeId => throw _privateConstructorUsedError;
  String get cashierId => throw _privateConstructorUsedError;
  String? get customerId => throw _privateConstructorUsedError;
  RefundStatus get status => throw _privateConstructorUsedError;
  RefundReason get reason => throw _privateConstructorUsedError;
  RefundMethod get method => throw _privateConstructorUsedError;
  double get totalAmount => throw _privateConstructorUsedError;
  List<RefundItem> get items => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get supervisorId => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;

  /// Serializes this Refund to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Refund
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RefundCopyWith<Refund> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RefundCopyWith<$Res> {
  factory $RefundCopyWith(Refund value, $Res Function(Refund) then) =
      _$RefundCopyWithImpl<$Res, Refund>;
  @useResult
  $Res call(
      {String id,
      String originalSaleId,
      String storeId,
      String cashierId,
      String? customerId,
      RefundStatus status,
      RefundReason reason,
      RefundMethod method,
      double totalAmount,
      List<RefundItem> items,
      String? notes,
      String? supervisorId,
      DateTime createdAt,
      DateTime? completedAt});
}

/// @nodoc
class _$RefundCopyWithImpl<$Res, $Val extends Refund>
    implements $RefundCopyWith<$Res> {
  _$RefundCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Refund
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? originalSaleId = null,
    Object? storeId = null,
    Object? cashierId = null,
    Object? customerId = freezed,
    Object? status = null,
    Object? reason = null,
    Object? method = null,
    Object? totalAmount = null,
    Object? items = null,
    Object? notes = freezed,
    Object? supervisorId = freezed,
    Object? createdAt = null,
    Object? completedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      originalSaleId: null == originalSaleId
          ? _value.originalSaleId
          : originalSaleId // ignore: cast_nullable_to_non_nullable
              as String,
      storeId: null == storeId
          ? _value.storeId
          : storeId // ignore: cast_nullable_to_non_nullable
              as String,
      cashierId: null == cashierId
          ? _value.cashierId
          : cashierId // ignore: cast_nullable_to_non_nullable
              as String,
      customerId: freezed == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as RefundStatus,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as RefundReason,
      method: null == method
          ? _value.method
          : method // ignore: cast_nullable_to_non_nullable
              as RefundMethod,
      totalAmount: null == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as double,
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<RefundItem>,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      supervisorId: freezed == supervisorId
          ? _value.supervisorId
          : supervisorId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RefundImplCopyWith<$Res> implements $RefundCopyWith<$Res> {
  factory _$$RefundImplCopyWith(
          _$RefundImpl value, $Res Function(_$RefundImpl) then) =
      __$$RefundImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String originalSaleId,
      String storeId,
      String cashierId,
      String? customerId,
      RefundStatus status,
      RefundReason reason,
      RefundMethod method,
      double totalAmount,
      List<RefundItem> items,
      String? notes,
      String? supervisorId,
      DateTime createdAt,
      DateTime? completedAt});
}

/// @nodoc
class __$$RefundImplCopyWithImpl<$Res>
    extends _$RefundCopyWithImpl<$Res, _$RefundImpl>
    implements _$$RefundImplCopyWith<$Res> {
  __$$RefundImplCopyWithImpl(
      _$RefundImpl _value, $Res Function(_$RefundImpl) _then)
      : super(_value, _then);

  /// Create a copy of Refund
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? originalSaleId = null,
    Object? storeId = null,
    Object? cashierId = null,
    Object? customerId = freezed,
    Object? status = null,
    Object? reason = null,
    Object? method = null,
    Object? totalAmount = null,
    Object? items = null,
    Object? notes = freezed,
    Object? supervisorId = freezed,
    Object? createdAt = null,
    Object? completedAt = freezed,
  }) {
    return _then(_$RefundImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      originalSaleId: null == originalSaleId
          ? _value.originalSaleId
          : originalSaleId // ignore: cast_nullable_to_non_nullable
              as String,
      storeId: null == storeId
          ? _value.storeId
          : storeId // ignore: cast_nullable_to_non_nullable
              as String,
      cashierId: null == cashierId
          ? _value.cashierId
          : cashierId // ignore: cast_nullable_to_non_nullable
              as String,
      customerId: freezed == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as RefundStatus,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as RefundReason,
      method: null == method
          ? _value.method
          : method // ignore: cast_nullable_to_non_nullable
              as RefundMethod,
      totalAmount: null == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as double,
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<RefundItem>,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      supervisorId: freezed == supervisorId
          ? _value.supervisorId
          : supervisorId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RefundImpl extends _Refund {
  const _$RefundImpl(
      {required this.id,
      required this.originalSaleId,
      required this.storeId,
      required this.cashierId,
      this.customerId,
      required this.status,
      required this.reason,
      required this.method,
      required this.totalAmount,
      required final List<RefundItem> items,
      this.notes,
      this.supervisorId,
      required this.createdAt,
      this.completedAt})
      : _items = items,
        super._();

  factory _$RefundImpl.fromJson(Map<String, dynamic> json) =>
      _$$RefundImplFromJson(json);

  @override
  final String id;
  @override
  final String originalSaleId;
  @override
  final String storeId;
  @override
  final String cashierId;
  @override
  final String? customerId;
  @override
  final RefundStatus status;
  @override
  final RefundReason reason;
  @override
  final RefundMethod method;
  @override
  final double totalAmount;
  final List<RefundItem> _items;
  @override
  List<RefundItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final String? notes;
  @override
  final String? supervisorId;
  @override
  final DateTime createdAt;
  @override
  final DateTime? completedAt;

  @override
  String toString() {
    return 'Refund(id: $id, originalSaleId: $originalSaleId, storeId: $storeId, cashierId: $cashierId, customerId: $customerId, status: $status, reason: $reason, method: $method, totalAmount: $totalAmount, items: $items, notes: $notes, supervisorId: $supervisorId, createdAt: $createdAt, completedAt: $completedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RefundImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.originalSaleId, originalSaleId) ||
                other.originalSaleId == originalSaleId) &&
            (identical(other.storeId, storeId) || other.storeId == storeId) &&
            (identical(other.cashierId, cashierId) ||
                other.cashierId == cashierId) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.method, method) || other.method == method) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.supervisorId, supervisorId) ||
                other.supervisorId == supervisorId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      originalSaleId,
      storeId,
      cashierId,
      customerId,
      status,
      reason,
      method,
      totalAmount,
      const DeepCollectionEquality().hash(_items),
      notes,
      supervisorId,
      createdAt,
      completedAt);

  /// Create a copy of Refund
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RefundImplCopyWith<_$RefundImpl> get copyWith =>
      __$$RefundImplCopyWithImpl<_$RefundImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RefundImplToJson(
      this,
    );
  }
}

abstract class _Refund extends Refund {
  const factory _Refund(
      {required final String id,
      required final String originalSaleId,
      required final String storeId,
      required final String cashierId,
      final String? customerId,
      required final RefundStatus status,
      required final RefundReason reason,
      required final RefundMethod method,
      required final double totalAmount,
      required final List<RefundItem> items,
      final String? notes,
      final String? supervisorId,
      required final DateTime createdAt,
      final DateTime? completedAt}) = _$RefundImpl;
  const _Refund._() : super._();

  factory _Refund.fromJson(Map<String, dynamic> json) = _$RefundImpl.fromJson;

  @override
  String get id;
  @override
  String get originalSaleId;
  @override
  String get storeId;
  @override
  String get cashierId;
  @override
  String? get customerId;
  @override
  RefundStatus get status;
  @override
  RefundReason get reason;
  @override
  RefundMethod get method;
  @override
  double get totalAmount;
  @override
  List<RefundItem> get items;
  @override
  String? get notes;
  @override
  String? get supervisorId;
  @override
  DateTime get createdAt;
  @override
  DateTime? get completedAt;

  /// Create a copy of Refund
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RefundImplCopyWith<_$RefundImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RefundItem _$RefundItemFromJson(Map<String, dynamic> json) {
  return _RefundItem.fromJson(json);
}

/// @nodoc
mixin _$RefundItem {
  String get productId => throw _privateConstructorUsedError;
  String get productName => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;
  double get unitPrice => throw _privateConstructorUsedError;
  double get totalAmount => throw _privateConstructorUsedError;
  String? get reason => throw _privateConstructorUsedError;

  /// Serializes this RefundItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RefundItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RefundItemCopyWith<RefundItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RefundItemCopyWith<$Res> {
  factory $RefundItemCopyWith(
          RefundItem value, $Res Function(RefundItem) then) =
      _$RefundItemCopyWithImpl<$Res, RefundItem>;
  @useResult
  $Res call(
      {String productId,
      String productName,
      int quantity,
      double unitPrice,
      double totalAmount,
      String? reason});
}

/// @nodoc
class _$RefundItemCopyWithImpl<$Res, $Val extends RefundItem>
    implements $RefundItemCopyWith<$Res> {
  _$RefundItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RefundItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = null,
    Object? productName = null,
    Object? quantity = null,
    Object? unitPrice = null,
    Object? totalAmount = null,
    Object? reason = freezed,
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
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      unitPrice: null == unitPrice
          ? _value.unitPrice
          : unitPrice // ignore: cast_nullable_to_non_nullable
              as double,
      totalAmount: null == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as double,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RefundItemImplCopyWith<$Res>
    implements $RefundItemCopyWith<$Res> {
  factory _$$RefundItemImplCopyWith(
          _$RefundItemImpl value, $Res Function(_$RefundItemImpl) then) =
      __$$RefundItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String productId,
      String productName,
      int quantity,
      double unitPrice,
      double totalAmount,
      String? reason});
}

/// @nodoc
class __$$RefundItemImplCopyWithImpl<$Res>
    extends _$RefundItemCopyWithImpl<$Res, _$RefundItemImpl>
    implements _$$RefundItemImplCopyWith<$Res> {
  __$$RefundItemImplCopyWithImpl(
      _$RefundItemImpl _value, $Res Function(_$RefundItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of RefundItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = null,
    Object? productName = null,
    Object? quantity = null,
    Object? unitPrice = null,
    Object? totalAmount = null,
    Object? reason = freezed,
  }) {
    return _then(_$RefundItemImpl(
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      productName: null == productName
          ? _value.productName
          : productName // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      unitPrice: null == unitPrice
          ? _value.unitPrice
          : unitPrice // ignore: cast_nullable_to_non_nullable
              as double,
      totalAmount: null == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as double,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RefundItemImpl extends _RefundItem {
  const _$RefundItemImpl(
      {required this.productId,
      required this.productName,
      required this.quantity,
      required this.unitPrice,
      required this.totalAmount,
      this.reason})
      : super._();

  factory _$RefundItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$RefundItemImplFromJson(json);

  @override
  final String productId;
  @override
  final String productName;
  @override
  final int quantity;
  @override
  final double unitPrice;
  @override
  final double totalAmount;
  @override
  final String? reason;

  @override
  String toString() {
    return 'RefundItem(productId: $productId, productName: $productName, quantity: $quantity, unitPrice: $unitPrice, totalAmount: $totalAmount, reason: $reason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RefundItemImpl &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.productName, productName) ||
                other.productName == productName) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.unitPrice, unitPrice) ||
                other.unitPrice == unitPrice) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.reason, reason) || other.reason == reason));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, productId, productName, quantity,
      unitPrice, totalAmount, reason);

  /// Create a copy of RefundItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RefundItemImplCopyWith<_$RefundItemImpl> get copyWith =>
      __$$RefundItemImplCopyWithImpl<_$RefundItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RefundItemImplToJson(
      this,
    );
  }
}

abstract class _RefundItem extends RefundItem {
  const factory _RefundItem(
      {required final String productId,
      required final String productName,
      required final int quantity,
      required final double unitPrice,
      required final double totalAmount,
      final String? reason}) = _$RefundItemImpl;
  const _RefundItem._() : super._();

  factory _RefundItem.fromJson(Map<String, dynamic> json) =
      _$RefundItemImpl.fromJson;

  @override
  String get productId;
  @override
  String get productName;
  @override
  int get quantity;
  @override
  double get unitPrice;
  @override
  double get totalAmount;
  @override
  String? get reason;

  /// Create a copy of RefundItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RefundItemImplCopyWith<_$RefundItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
