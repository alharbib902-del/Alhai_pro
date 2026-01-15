// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'customer_account.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CustomerAccount _$CustomerAccountFromJson(Map<String, dynamic> json) {
  return _CustomerAccount.fromJson(json);
}

/// @nodoc
mixin _$CustomerAccount {
  String get id => throw _privateConstructorUsedError;
  String get customerId =>
      throw _privateConstructorUsedError; // global_customers.id
  String get storeId => throw _privateConstructorUsedError;
  double get balance =>
      throw _privateConstructorUsedError; // negative = debt, positive = credit
  double get creditLimit => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  int get totalOrders => throw _privateConstructorUsedError;
  int get completedOrders => throw _privateConstructorUsedError;
  int get cancelledOrders => throw _privateConstructorUsedError;
  DateTime? get lastOrderAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this CustomerAccount to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CustomerAccount
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CustomerAccountCopyWith<CustomerAccount> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CustomerAccountCopyWith<$Res> {
  factory $CustomerAccountCopyWith(
          CustomerAccount value, $Res Function(CustomerAccount) then) =
      _$CustomerAccountCopyWithImpl<$Res, CustomerAccount>;
  @useResult
  $Res call(
      {String id,
      String customerId,
      String storeId,
      double balance,
      double creditLimit,
      bool isActive,
      int totalOrders,
      int completedOrders,
      int cancelledOrders,
      DateTime? lastOrderAt,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$CustomerAccountCopyWithImpl<$Res, $Val extends CustomerAccount>
    implements $CustomerAccountCopyWith<$Res> {
  _$CustomerAccountCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CustomerAccount
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? customerId = null,
    Object? storeId = null,
    Object? balance = null,
    Object? creditLimit = null,
    Object? isActive = null,
    Object? totalOrders = null,
    Object? completedOrders = null,
    Object? cancelledOrders = null,
    Object? lastOrderAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      customerId: null == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String,
      storeId: null == storeId
          ? _value.storeId
          : storeId // ignore: cast_nullable_to_non_nullable
              as String,
      balance: null == balance
          ? _value.balance
          : balance // ignore: cast_nullable_to_non_nullable
              as double,
      creditLimit: null == creditLimit
          ? _value.creditLimit
          : creditLimit // ignore: cast_nullable_to_non_nullable
              as double,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      totalOrders: null == totalOrders
          ? _value.totalOrders
          : totalOrders // ignore: cast_nullable_to_non_nullable
              as int,
      completedOrders: null == completedOrders
          ? _value.completedOrders
          : completedOrders // ignore: cast_nullable_to_non_nullable
              as int,
      cancelledOrders: null == cancelledOrders
          ? _value.cancelledOrders
          : cancelledOrders // ignore: cast_nullable_to_non_nullable
              as int,
      lastOrderAt: freezed == lastOrderAt
          ? _value.lastOrderAt
          : lastOrderAt // ignore: cast_nullable_to_non_nullable
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
abstract class _$$CustomerAccountImplCopyWith<$Res>
    implements $CustomerAccountCopyWith<$Res> {
  factory _$$CustomerAccountImplCopyWith(_$CustomerAccountImpl value,
          $Res Function(_$CustomerAccountImpl) then) =
      __$$CustomerAccountImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String customerId,
      String storeId,
      double balance,
      double creditLimit,
      bool isActive,
      int totalOrders,
      int completedOrders,
      int cancelledOrders,
      DateTime? lastOrderAt,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$CustomerAccountImplCopyWithImpl<$Res>
    extends _$CustomerAccountCopyWithImpl<$Res, _$CustomerAccountImpl>
    implements _$$CustomerAccountImplCopyWith<$Res> {
  __$$CustomerAccountImplCopyWithImpl(
      _$CustomerAccountImpl _value, $Res Function(_$CustomerAccountImpl) _then)
      : super(_value, _then);

  /// Create a copy of CustomerAccount
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? customerId = null,
    Object? storeId = null,
    Object? balance = null,
    Object? creditLimit = null,
    Object? isActive = null,
    Object? totalOrders = null,
    Object? completedOrders = null,
    Object? cancelledOrders = null,
    Object? lastOrderAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$CustomerAccountImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      customerId: null == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String,
      storeId: null == storeId
          ? _value.storeId
          : storeId // ignore: cast_nullable_to_non_nullable
              as String,
      balance: null == balance
          ? _value.balance
          : balance // ignore: cast_nullable_to_non_nullable
              as double,
      creditLimit: null == creditLimit
          ? _value.creditLimit
          : creditLimit // ignore: cast_nullable_to_non_nullable
              as double,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      totalOrders: null == totalOrders
          ? _value.totalOrders
          : totalOrders // ignore: cast_nullable_to_non_nullable
              as int,
      completedOrders: null == completedOrders
          ? _value.completedOrders
          : completedOrders // ignore: cast_nullable_to_non_nullable
              as int,
      cancelledOrders: null == cancelledOrders
          ? _value.cancelledOrders
          : cancelledOrders // ignore: cast_nullable_to_non_nullable
              as int,
      lastOrderAt: freezed == lastOrderAt
          ? _value.lastOrderAt
          : lastOrderAt // ignore: cast_nullable_to_non_nullable
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
class _$CustomerAccountImpl extends _CustomerAccount {
  const _$CustomerAccountImpl(
      {required this.id,
      required this.customerId,
      required this.storeId,
      this.balance = 0.0,
      this.creditLimit = 500.0,
      this.isActive = true,
      this.totalOrders = 0,
      this.completedOrders = 0,
      this.cancelledOrders = 0,
      this.lastOrderAt,
      required this.createdAt,
      this.updatedAt})
      : super._();

  factory _$CustomerAccountImpl.fromJson(Map<String, dynamic> json) =>
      _$$CustomerAccountImplFromJson(json);

  @override
  final String id;
  @override
  final String customerId;
// global_customers.id
  @override
  final String storeId;
  @override
  @JsonKey()
  final double balance;
// negative = debt, positive = credit
  @override
  @JsonKey()
  final double creditLimit;
  @override
  @JsonKey()
  final bool isActive;
  @override
  @JsonKey()
  final int totalOrders;
  @override
  @JsonKey()
  final int completedOrders;
  @override
  @JsonKey()
  final int cancelledOrders;
  @override
  final DateTime? lastOrderAt;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'CustomerAccount(id: $id, customerId: $customerId, storeId: $storeId, balance: $balance, creditLimit: $creditLimit, isActive: $isActive, totalOrders: $totalOrders, completedOrders: $completedOrders, cancelledOrders: $cancelledOrders, lastOrderAt: $lastOrderAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomerAccountImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.storeId, storeId) || other.storeId == storeId) &&
            (identical(other.balance, balance) || other.balance == balance) &&
            (identical(other.creditLimit, creditLimit) ||
                other.creditLimit == creditLimit) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.totalOrders, totalOrders) ||
                other.totalOrders == totalOrders) &&
            (identical(other.completedOrders, completedOrders) ||
                other.completedOrders == completedOrders) &&
            (identical(other.cancelledOrders, cancelledOrders) ||
                other.cancelledOrders == cancelledOrders) &&
            (identical(other.lastOrderAt, lastOrderAt) ||
                other.lastOrderAt == lastOrderAt) &&
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
      customerId,
      storeId,
      balance,
      creditLimit,
      isActive,
      totalOrders,
      completedOrders,
      cancelledOrders,
      lastOrderAt,
      createdAt,
      updatedAt);

  /// Create a copy of CustomerAccount
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomerAccountImplCopyWith<_$CustomerAccountImpl> get copyWith =>
      __$$CustomerAccountImplCopyWithImpl<_$CustomerAccountImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomerAccountImplToJson(
      this,
    );
  }
}

abstract class _CustomerAccount extends CustomerAccount {
  const factory _CustomerAccount(
      {required final String id,
      required final String customerId,
      required final String storeId,
      final double balance,
      final double creditLimit,
      final bool isActive,
      final int totalOrders,
      final int completedOrders,
      final int cancelledOrders,
      final DateTime? lastOrderAt,
      required final DateTime createdAt,
      final DateTime? updatedAt}) = _$CustomerAccountImpl;
  const _CustomerAccount._() : super._();

  factory _CustomerAccount.fromJson(Map<String, dynamic> json) =
      _$CustomerAccountImpl.fromJson;

  @override
  String get id;
  @override
  String get customerId; // global_customers.id
  @override
  String get storeId;
  @override
  double get balance; // negative = debt, positive = credit
  @override
  double get creditLimit;
  @override
  bool get isActive;
  @override
  int get totalOrders;
  @override
  int get completedOrders;
  @override
  int get cancelledOrders;
  @override
  DateTime? get lastOrderAt;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of CustomerAccount
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CustomerAccountImplCopyWith<_$CustomerAccountImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
