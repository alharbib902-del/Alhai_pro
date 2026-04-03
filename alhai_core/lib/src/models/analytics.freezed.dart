// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'analytics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SlowMovingProduct _$SlowMovingProductFromJson(Map<String, dynamic> json) {
  return _SlowMovingProduct.fromJson(json);
}

/// @nodoc
mixin _$SlowMovingProduct {
  String get productId => throw _privateConstructorUsedError;
  String get productName => throw _privateConstructorUsedError;
  String? get categoryName => throw _privateConstructorUsedError;
  int get daysSinceLastSale => throw _privateConstructorUsedError;
  double get stockQty => throw _privateConstructorUsedError;
  double get stockValue => throw _privateConstructorUsedError;
  double get suggestedDiscount => throw _privateConstructorUsedError;
  DateTime? get lastSaleDate => throw _privateConstructorUsedError;

  /// Serializes this SlowMovingProduct to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SlowMovingProduct
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SlowMovingProductCopyWith<SlowMovingProduct> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SlowMovingProductCopyWith<$Res> {
  factory $SlowMovingProductCopyWith(
          SlowMovingProduct value, $Res Function(SlowMovingProduct) then) =
      _$SlowMovingProductCopyWithImpl<$Res, SlowMovingProduct>;
  @useResult
  $Res call(
      {String productId,
      String productName,
      String? categoryName,
      int daysSinceLastSale,
      double stockQty,
      double stockValue,
      double suggestedDiscount,
      DateTime? lastSaleDate});
}

/// @nodoc
class _$SlowMovingProductCopyWithImpl<$Res, $Val extends SlowMovingProduct>
    implements $SlowMovingProductCopyWith<$Res> {
  _$SlowMovingProductCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SlowMovingProduct
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = null,
    Object? productName = null,
    Object? categoryName = freezed,
    Object? daysSinceLastSale = null,
    Object? stockQty = null,
    Object? stockValue = null,
    Object? suggestedDiscount = null,
    Object? lastSaleDate = freezed,
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
      categoryName: freezed == categoryName
          ? _value.categoryName
          : categoryName // ignore: cast_nullable_to_non_nullable
              as String?,
      daysSinceLastSale: null == daysSinceLastSale
          ? _value.daysSinceLastSale
          : daysSinceLastSale // ignore: cast_nullable_to_non_nullable
              as int,
      stockQty: null == stockQty
          ? _value.stockQty
          : stockQty // ignore: cast_nullable_to_non_nullable
              as double,
      stockValue: null == stockValue
          ? _value.stockValue
          : stockValue // ignore: cast_nullable_to_non_nullable
              as double,
      suggestedDiscount: null == suggestedDiscount
          ? _value.suggestedDiscount
          : suggestedDiscount // ignore: cast_nullable_to_non_nullable
              as double,
      lastSaleDate: freezed == lastSaleDate
          ? _value.lastSaleDate
          : lastSaleDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SlowMovingProductImplCopyWith<$Res>
    implements $SlowMovingProductCopyWith<$Res> {
  factory _$$SlowMovingProductImplCopyWith(_$SlowMovingProductImpl value,
          $Res Function(_$SlowMovingProductImpl) then) =
      __$$SlowMovingProductImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String productId,
      String productName,
      String? categoryName,
      int daysSinceLastSale,
      double stockQty,
      double stockValue,
      double suggestedDiscount,
      DateTime? lastSaleDate});
}

/// @nodoc
class __$$SlowMovingProductImplCopyWithImpl<$Res>
    extends _$SlowMovingProductCopyWithImpl<$Res, _$SlowMovingProductImpl>
    implements _$$SlowMovingProductImplCopyWith<$Res> {
  __$$SlowMovingProductImplCopyWithImpl(_$SlowMovingProductImpl _value,
      $Res Function(_$SlowMovingProductImpl) _then)
      : super(_value, _then);

  /// Create a copy of SlowMovingProduct
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = null,
    Object? productName = null,
    Object? categoryName = freezed,
    Object? daysSinceLastSale = null,
    Object? stockQty = null,
    Object? stockValue = null,
    Object? suggestedDiscount = null,
    Object? lastSaleDate = freezed,
  }) {
    return _then(_$SlowMovingProductImpl(
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      productName: null == productName
          ? _value.productName
          : productName // ignore: cast_nullable_to_non_nullable
              as String,
      categoryName: freezed == categoryName
          ? _value.categoryName
          : categoryName // ignore: cast_nullable_to_non_nullable
              as String?,
      daysSinceLastSale: null == daysSinceLastSale
          ? _value.daysSinceLastSale
          : daysSinceLastSale // ignore: cast_nullable_to_non_nullable
              as int,
      stockQty: null == stockQty
          ? _value.stockQty
          : stockQty // ignore: cast_nullable_to_non_nullable
              as double,
      stockValue: null == stockValue
          ? _value.stockValue
          : stockValue // ignore: cast_nullable_to_non_nullable
              as double,
      suggestedDiscount: null == suggestedDiscount
          ? _value.suggestedDiscount
          : suggestedDiscount // ignore: cast_nullable_to_non_nullable
              as double,
      lastSaleDate: freezed == lastSaleDate
          ? _value.lastSaleDate
          : lastSaleDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SlowMovingProductImpl extends _SlowMovingProduct {
  const _$SlowMovingProductImpl(
      {required this.productId,
      required this.productName,
      this.categoryName,
      required this.daysSinceLastSale,
      required this.stockQty,
      required this.stockValue,
      this.suggestedDiscount = 0,
      this.lastSaleDate})
      : super._();

  factory _$SlowMovingProductImpl.fromJson(Map<String, dynamic> json) =>
      _$$SlowMovingProductImplFromJson(json);

  @override
  final String productId;
  @override
  final String productName;
  @override
  final String? categoryName;
  @override
  final int daysSinceLastSale;
  @override
  final double stockQty;
  @override
  final double stockValue;
  @override
  @JsonKey()
  final double suggestedDiscount;
  @override
  final DateTime? lastSaleDate;

  @override
  String toString() {
    return 'SlowMovingProduct(productId: $productId, productName: $productName, categoryName: $categoryName, daysSinceLastSale: $daysSinceLastSale, stockQty: $stockQty, stockValue: $stockValue, suggestedDiscount: $suggestedDiscount, lastSaleDate: $lastSaleDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SlowMovingProductImpl &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.productName, productName) ||
                other.productName == productName) &&
            (identical(other.categoryName, categoryName) ||
                other.categoryName == categoryName) &&
            (identical(other.daysSinceLastSale, daysSinceLastSale) ||
                other.daysSinceLastSale == daysSinceLastSale) &&
            (identical(other.stockQty, stockQty) ||
                other.stockQty == stockQty) &&
            (identical(other.stockValue, stockValue) ||
                other.stockValue == stockValue) &&
            (identical(other.suggestedDiscount, suggestedDiscount) ||
                other.suggestedDiscount == suggestedDiscount) &&
            (identical(other.lastSaleDate, lastSaleDate) ||
                other.lastSaleDate == lastSaleDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      productId,
      productName,
      categoryName,
      daysSinceLastSale,
      stockQty,
      stockValue,
      suggestedDiscount,
      lastSaleDate);

  /// Create a copy of SlowMovingProduct
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SlowMovingProductImplCopyWith<_$SlowMovingProductImpl> get copyWith =>
      __$$SlowMovingProductImplCopyWithImpl<_$SlowMovingProductImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SlowMovingProductImplToJson(
      this,
    );
  }
}

abstract class _SlowMovingProduct extends SlowMovingProduct {
  const factory _SlowMovingProduct(
      {required final String productId,
      required final String productName,
      final String? categoryName,
      required final int daysSinceLastSale,
      required final double stockQty,
      required final double stockValue,
      final double suggestedDiscount,
      final DateTime? lastSaleDate}) = _$SlowMovingProductImpl;
  const _SlowMovingProduct._() : super._();

  factory _SlowMovingProduct.fromJson(Map<String, dynamic> json) =
      _$SlowMovingProductImpl.fromJson;

  @override
  String get productId;
  @override
  String get productName;
  @override
  String? get categoryName;
  @override
  int get daysSinceLastSale;
  @override
  double get stockQty;
  @override
  double get stockValue;
  @override
  double get suggestedDiscount;
  @override
  DateTime? get lastSaleDate;

  /// Create a copy of SlowMovingProduct
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SlowMovingProductImplCopyWith<_$SlowMovingProductImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SalesForecast _$SalesForecastFromJson(Map<String, dynamic> json) {
  return _SalesForecast.fromJson(json);
}

/// @nodoc
mixin _$SalesForecast {
  DateTime get date => throw _privateConstructorUsedError;
  double get predictedRevenue => throw _privateConstructorUsedError;
  int get predictedOrders => throw _privateConstructorUsedError;
  double get confidence => throw _privateConstructorUsedError;
  double? get lowerBound => throw _privateConstructorUsedError;
  double? get upperBound => throw _privateConstructorUsedError;

  /// Serializes this SalesForecast to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SalesForecast
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SalesForecastCopyWith<SalesForecast> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SalesForecastCopyWith<$Res> {
  factory $SalesForecastCopyWith(
          SalesForecast value, $Res Function(SalesForecast) then) =
      _$SalesForecastCopyWithImpl<$Res, SalesForecast>;
  @useResult
  $Res call(
      {DateTime date,
      double predictedRevenue,
      int predictedOrders,
      double confidence,
      double? lowerBound,
      double? upperBound});
}

/// @nodoc
class _$SalesForecastCopyWithImpl<$Res, $Val extends SalesForecast>
    implements $SalesForecastCopyWith<$Res> {
  _$SalesForecastCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SalesForecast
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? predictedRevenue = null,
    Object? predictedOrders = null,
    Object? confidence = null,
    Object? lowerBound = freezed,
    Object? upperBound = freezed,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      predictedRevenue: null == predictedRevenue
          ? _value.predictedRevenue
          : predictedRevenue // ignore: cast_nullable_to_non_nullable
              as double,
      predictedOrders: null == predictedOrders
          ? _value.predictedOrders
          : predictedOrders // ignore: cast_nullable_to_non_nullable
              as int,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
      lowerBound: freezed == lowerBound
          ? _value.lowerBound
          : lowerBound // ignore: cast_nullable_to_non_nullable
              as double?,
      upperBound: freezed == upperBound
          ? _value.upperBound
          : upperBound // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SalesForecastImplCopyWith<$Res>
    implements $SalesForecastCopyWith<$Res> {
  factory _$$SalesForecastImplCopyWith(
          _$SalesForecastImpl value, $Res Function(_$SalesForecastImpl) then) =
      __$$SalesForecastImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime date,
      double predictedRevenue,
      int predictedOrders,
      double confidence,
      double? lowerBound,
      double? upperBound});
}

/// @nodoc
class __$$SalesForecastImplCopyWithImpl<$Res>
    extends _$SalesForecastCopyWithImpl<$Res, _$SalesForecastImpl>
    implements _$$SalesForecastImplCopyWith<$Res> {
  __$$SalesForecastImplCopyWithImpl(
      _$SalesForecastImpl _value, $Res Function(_$SalesForecastImpl) _then)
      : super(_value, _then);

  /// Create a copy of SalesForecast
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? predictedRevenue = null,
    Object? predictedOrders = null,
    Object? confidence = null,
    Object? lowerBound = freezed,
    Object? upperBound = freezed,
  }) {
    return _then(_$SalesForecastImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      predictedRevenue: null == predictedRevenue
          ? _value.predictedRevenue
          : predictedRevenue // ignore: cast_nullable_to_non_nullable
              as double,
      predictedOrders: null == predictedOrders
          ? _value.predictedOrders
          : predictedOrders // ignore: cast_nullable_to_non_nullable
              as int,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
      lowerBound: freezed == lowerBound
          ? _value.lowerBound
          : lowerBound // ignore: cast_nullable_to_non_nullable
              as double?,
      upperBound: freezed == upperBound
          ? _value.upperBound
          : upperBound // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SalesForecastImpl extends _SalesForecast {
  const _$SalesForecastImpl(
      {required this.date,
      required this.predictedRevenue,
      required this.predictedOrders,
      required this.confidence,
      this.lowerBound,
      this.upperBound})
      : super._();

  factory _$SalesForecastImpl.fromJson(Map<String, dynamic> json) =>
      _$$SalesForecastImplFromJson(json);

  @override
  final DateTime date;
  @override
  final double predictedRevenue;
  @override
  final int predictedOrders;
  @override
  final double confidence;
  @override
  final double? lowerBound;
  @override
  final double? upperBound;

  @override
  String toString() {
    return 'SalesForecast(date: $date, predictedRevenue: $predictedRevenue, predictedOrders: $predictedOrders, confidence: $confidence, lowerBound: $lowerBound, upperBound: $upperBound)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SalesForecastImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.predictedRevenue, predictedRevenue) ||
                other.predictedRevenue == predictedRevenue) &&
            (identical(other.predictedOrders, predictedOrders) ||
                other.predictedOrders == predictedOrders) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            (identical(other.lowerBound, lowerBound) ||
                other.lowerBound == lowerBound) &&
            (identical(other.upperBound, upperBound) ||
                other.upperBound == upperBound));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, date, predictedRevenue,
      predictedOrders, confidence, lowerBound, upperBound);

  /// Create a copy of SalesForecast
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SalesForecastImplCopyWith<_$SalesForecastImpl> get copyWith =>
      __$$SalesForecastImplCopyWithImpl<_$SalesForecastImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SalesForecastImplToJson(
      this,
    );
  }
}

abstract class _SalesForecast extends SalesForecast {
  const factory _SalesForecast(
      {required final DateTime date,
      required final double predictedRevenue,
      required final int predictedOrders,
      required final double confidence,
      final double? lowerBound,
      final double? upperBound}) = _$SalesForecastImpl;
  const _SalesForecast._() : super._();

  factory _SalesForecast.fromJson(Map<String, dynamic> json) =
      _$SalesForecastImpl.fromJson;

  @override
  DateTime get date;
  @override
  double get predictedRevenue;
  @override
  int get predictedOrders;
  @override
  double get confidence;
  @override
  double? get lowerBound;
  @override
  double? get upperBound;

  /// Create a copy of SalesForecast
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SalesForecastImplCopyWith<_$SalesForecastImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SmartAlert _$SmartAlertFromJson(Map<String, dynamic> json) {
  return _SmartAlert.fromJson(json);
}

/// @nodoc
mixin _$SmartAlert {
  String get id => throw _privateConstructorUsedError;
  AlertType get type => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  String? get actionLabel => throw _privateConstructorUsedError;
  String? get actionRoute => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;
  bool get isRead => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this SmartAlert to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SmartAlert
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SmartAlertCopyWith<SmartAlert> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SmartAlertCopyWith<$Res> {
  factory $SmartAlertCopyWith(
          SmartAlert value, $Res Function(SmartAlert) then) =
      _$SmartAlertCopyWithImpl<$Res, SmartAlert>;
  @useResult
  $Res call(
      {String id,
      AlertType type,
      String title,
      String message,
      String? actionLabel,
      String? actionRoute,
      Map<String, dynamic>? metadata,
      bool isRead,
      DateTime createdAt});
}

/// @nodoc
class _$SmartAlertCopyWithImpl<$Res, $Val extends SmartAlert>
    implements $SmartAlertCopyWith<$Res> {
  _$SmartAlertCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SmartAlert
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? title = null,
    Object? message = null,
    Object? actionLabel = freezed,
    Object? actionRoute = freezed,
    Object? metadata = freezed,
    Object? isRead = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as AlertType,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      actionLabel: freezed == actionLabel
          ? _value.actionLabel
          : actionLabel // ignore: cast_nullable_to_non_nullable
              as String?,
      actionRoute: freezed == actionRoute
          ? _value.actionRoute
          : actionRoute // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      isRead: null == isRead
          ? _value.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SmartAlertImplCopyWith<$Res>
    implements $SmartAlertCopyWith<$Res> {
  factory _$$SmartAlertImplCopyWith(
          _$SmartAlertImpl value, $Res Function(_$SmartAlertImpl) then) =
      __$$SmartAlertImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      AlertType type,
      String title,
      String message,
      String? actionLabel,
      String? actionRoute,
      Map<String, dynamic>? metadata,
      bool isRead,
      DateTime createdAt});
}

/// @nodoc
class __$$SmartAlertImplCopyWithImpl<$Res>
    extends _$SmartAlertCopyWithImpl<$Res, _$SmartAlertImpl>
    implements _$$SmartAlertImplCopyWith<$Res> {
  __$$SmartAlertImplCopyWithImpl(
      _$SmartAlertImpl _value, $Res Function(_$SmartAlertImpl) _then)
      : super(_value, _then);

  /// Create a copy of SmartAlert
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? title = null,
    Object? message = null,
    Object? actionLabel = freezed,
    Object? actionRoute = freezed,
    Object? metadata = freezed,
    Object? isRead = null,
    Object? createdAt = null,
  }) {
    return _then(_$SmartAlertImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as AlertType,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      actionLabel: freezed == actionLabel
          ? _value.actionLabel
          : actionLabel // ignore: cast_nullable_to_non_nullable
              as String?,
      actionRoute: freezed == actionRoute
          ? _value.actionRoute
          : actionRoute // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      isRead: null == isRead
          ? _value.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SmartAlertImpl extends _SmartAlert {
  const _$SmartAlertImpl(
      {required this.id,
      required this.type,
      required this.title,
      required this.message,
      this.actionLabel,
      this.actionRoute,
      final Map<String, dynamic>? metadata,
      this.isRead = false,
      required this.createdAt})
      : _metadata = metadata,
        super._();

  factory _$SmartAlertImpl.fromJson(Map<String, dynamic> json) =>
      _$$SmartAlertImplFromJson(json);

  @override
  final String id;
  @override
  final AlertType type;
  @override
  final String title;
  @override
  final String message;
  @override
  final String? actionLabel;
  @override
  final String? actionRoute;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey()
  final bool isRead;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'SmartAlert(id: $id, type: $type, title: $title, message: $message, actionLabel: $actionLabel, actionRoute: $actionRoute, metadata: $metadata, isRead: $isRead, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SmartAlertImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.actionLabel, actionLabel) ||
                other.actionLabel == actionLabel) &&
            (identical(other.actionRoute, actionRoute) ||
                other.actionRoute == actionRoute) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.isRead, isRead) || other.isRead == isRead) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      type,
      title,
      message,
      actionLabel,
      actionRoute,
      const DeepCollectionEquality().hash(_metadata),
      isRead,
      createdAt);

  /// Create a copy of SmartAlert
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SmartAlertImplCopyWith<_$SmartAlertImpl> get copyWith =>
      __$$SmartAlertImplCopyWithImpl<_$SmartAlertImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SmartAlertImplToJson(
      this,
    );
  }
}

abstract class _SmartAlert extends SmartAlert {
  const factory _SmartAlert(
      {required final String id,
      required final AlertType type,
      required final String title,
      required final String message,
      final String? actionLabel,
      final String? actionRoute,
      final Map<String, dynamic>? metadata,
      final bool isRead,
      required final DateTime createdAt}) = _$SmartAlertImpl;
  const _SmartAlert._() : super._();

  factory _SmartAlert.fromJson(Map<String, dynamic> json) =
      _$SmartAlertImpl.fromJson;

  @override
  String get id;
  @override
  AlertType get type;
  @override
  String get title;
  @override
  String get message;
  @override
  String? get actionLabel;
  @override
  String? get actionRoute;
  @override
  Map<String, dynamic>? get metadata;
  @override
  bool get isRead;
  @override
  DateTime get createdAt;

  /// Create a copy of SmartAlert
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SmartAlertImplCopyWith<_$SmartAlertImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReorderSuggestion _$ReorderSuggestionFromJson(Map<String, dynamic> json) {
  return _ReorderSuggestion.fromJson(json);
}

/// @nodoc
mixin _$ReorderSuggestion {
  String get productId => throw _privateConstructorUsedError;
  String get productName => throw _privateConstructorUsedError;
  int get currentStock => throw _privateConstructorUsedError;
  int get suggestedQuantity => throw _privateConstructorUsedError;
  double get averageDailySales => throw _privateConstructorUsedError;
  int get daysUntilStockout => throw _privateConstructorUsedError;
  String? get preferredSupplierId => throw _privateConstructorUsedError;
  String? get preferredSupplierName => throw _privateConstructorUsedError;

  /// Serializes this ReorderSuggestion to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReorderSuggestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReorderSuggestionCopyWith<ReorderSuggestion> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReorderSuggestionCopyWith<$Res> {
  factory $ReorderSuggestionCopyWith(
          ReorderSuggestion value, $Res Function(ReorderSuggestion) then) =
      _$ReorderSuggestionCopyWithImpl<$Res, ReorderSuggestion>;
  @useResult
  $Res call(
      {String productId,
      String productName,
      int currentStock,
      int suggestedQuantity,
      double averageDailySales,
      int daysUntilStockout,
      String? preferredSupplierId,
      String? preferredSupplierName});
}

/// @nodoc
class _$ReorderSuggestionCopyWithImpl<$Res, $Val extends ReorderSuggestion>
    implements $ReorderSuggestionCopyWith<$Res> {
  _$ReorderSuggestionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReorderSuggestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = null,
    Object? productName = null,
    Object? currentStock = null,
    Object? suggestedQuantity = null,
    Object? averageDailySales = null,
    Object? daysUntilStockout = null,
    Object? preferredSupplierId = freezed,
    Object? preferredSupplierName = freezed,
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
      currentStock: null == currentStock
          ? _value.currentStock
          : currentStock // ignore: cast_nullable_to_non_nullable
              as int,
      suggestedQuantity: null == suggestedQuantity
          ? _value.suggestedQuantity
          : suggestedQuantity // ignore: cast_nullable_to_non_nullable
              as int,
      averageDailySales: null == averageDailySales
          ? _value.averageDailySales
          : averageDailySales // ignore: cast_nullable_to_non_nullable
              as double,
      daysUntilStockout: null == daysUntilStockout
          ? _value.daysUntilStockout
          : daysUntilStockout // ignore: cast_nullable_to_non_nullable
              as int,
      preferredSupplierId: freezed == preferredSupplierId
          ? _value.preferredSupplierId
          : preferredSupplierId // ignore: cast_nullable_to_non_nullable
              as String?,
      preferredSupplierName: freezed == preferredSupplierName
          ? _value.preferredSupplierName
          : preferredSupplierName // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReorderSuggestionImplCopyWith<$Res>
    implements $ReorderSuggestionCopyWith<$Res> {
  factory _$$ReorderSuggestionImplCopyWith(_$ReorderSuggestionImpl value,
          $Res Function(_$ReorderSuggestionImpl) then) =
      __$$ReorderSuggestionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String productId,
      String productName,
      int currentStock,
      int suggestedQuantity,
      double averageDailySales,
      int daysUntilStockout,
      String? preferredSupplierId,
      String? preferredSupplierName});
}

/// @nodoc
class __$$ReorderSuggestionImplCopyWithImpl<$Res>
    extends _$ReorderSuggestionCopyWithImpl<$Res, _$ReorderSuggestionImpl>
    implements _$$ReorderSuggestionImplCopyWith<$Res> {
  __$$ReorderSuggestionImplCopyWithImpl(_$ReorderSuggestionImpl _value,
      $Res Function(_$ReorderSuggestionImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReorderSuggestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = null,
    Object? productName = null,
    Object? currentStock = null,
    Object? suggestedQuantity = null,
    Object? averageDailySales = null,
    Object? daysUntilStockout = null,
    Object? preferredSupplierId = freezed,
    Object? preferredSupplierName = freezed,
  }) {
    return _then(_$ReorderSuggestionImpl(
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      productName: null == productName
          ? _value.productName
          : productName // ignore: cast_nullable_to_non_nullable
              as String,
      currentStock: null == currentStock
          ? _value.currentStock
          : currentStock // ignore: cast_nullable_to_non_nullable
              as int,
      suggestedQuantity: null == suggestedQuantity
          ? _value.suggestedQuantity
          : suggestedQuantity // ignore: cast_nullable_to_non_nullable
              as int,
      averageDailySales: null == averageDailySales
          ? _value.averageDailySales
          : averageDailySales // ignore: cast_nullable_to_non_nullable
              as double,
      daysUntilStockout: null == daysUntilStockout
          ? _value.daysUntilStockout
          : daysUntilStockout // ignore: cast_nullable_to_non_nullable
              as int,
      preferredSupplierId: freezed == preferredSupplierId
          ? _value.preferredSupplierId
          : preferredSupplierId // ignore: cast_nullable_to_non_nullable
              as String?,
      preferredSupplierName: freezed == preferredSupplierName
          ? _value.preferredSupplierName
          : preferredSupplierName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReorderSuggestionImpl extends _ReorderSuggestion {
  const _$ReorderSuggestionImpl(
      {required this.productId,
      required this.productName,
      required this.currentStock,
      required this.suggestedQuantity,
      required this.averageDailySales,
      required this.daysUntilStockout,
      this.preferredSupplierId,
      this.preferredSupplierName})
      : super._();

  factory _$ReorderSuggestionImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReorderSuggestionImplFromJson(json);

  @override
  final String productId;
  @override
  final String productName;
  @override
  final int currentStock;
  @override
  final int suggestedQuantity;
  @override
  final double averageDailySales;
  @override
  final int daysUntilStockout;
  @override
  final String? preferredSupplierId;
  @override
  final String? preferredSupplierName;

  @override
  String toString() {
    return 'ReorderSuggestion(productId: $productId, productName: $productName, currentStock: $currentStock, suggestedQuantity: $suggestedQuantity, averageDailySales: $averageDailySales, daysUntilStockout: $daysUntilStockout, preferredSupplierId: $preferredSupplierId, preferredSupplierName: $preferredSupplierName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReorderSuggestionImpl &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.productName, productName) ||
                other.productName == productName) &&
            (identical(other.currentStock, currentStock) ||
                other.currentStock == currentStock) &&
            (identical(other.suggestedQuantity, suggestedQuantity) ||
                other.suggestedQuantity == suggestedQuantity) &&
            (identical(other.averageDailySales, averageDailySales) ||
                other.averageDailySales == averageDailySales) &&
            (identical(other.daysUntilStockout, daysUntilStockout) ||
                other.daysUntilStockout == daysUntilStockout) &&
            (identical(other.preferredSupplierId, preferredSupplierId) ||
                other.preferredSupplierId == preferredSupplierId) &&
            (identical(other.preferredSupplierName, preferredSupplierName) ||
                other.preferredSupplierName == preferredSupplierName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      productId,
      productName,
      currentStock,
      suggestedQuantity,
      averageDailySales,
      daysUntilStockout,
      preferredSupplierId,
      preferredSupplierName);

  /// Create a copy of ReorderSuggestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReorderSuggestionImplCopyWith<_$ReorderSuggestionImpl> get copyWith =>
      __$$ReorderSuggestionImplCopyWithImpl<_$ReorderSuggestionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReorderSuggestionImplToJson(
      this,
    );
  }
}

abstract class _ReorderSuggestion extends ReorderSuggestion {
  const factory _ReorderSuggestion(
      {required final String productId,
      required final String productName,
      required final int currentStock,
      required final int suggestedQuantity,
      required final double averageDailySales,
      required final int daysUntilStockout,
      final String? preferredSupplierId,
      final String? preferredSupplierName}) = _$ReorderSuggestionImpl;
  const _ReorderSuggestion._() : super._();

  factory _ReorderSuggestion.fromJson(Map<String, dynamic> json) =
      _$ReorderSuggestionImpl.fromJson;

  @override
  String get productId;
  @override
  String get productName;
  @override
  int get currentStock;
  @override
  int get suggestedQuantity;
  @override
  double get averageDailySales;
  @override
  int get daysUntilStockout;
  @override
  String? get preferredSupplierId;
  @override
  String? get preferredSupplierName;

  /// Create a copy of ReorderSuggestion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReorderSuggestionImplCopyWith<_$ReorderSuggestionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PeakHoursAnalysis _$PeakHoursAnalysisFromJson(Map<String, dynamic> json) {
  return _PeakHoursAnalysis.fromJson(json);
}

/// @nodoc
mixin _$PeakHoursAnalysis {
  Map<int, double> get hourlyRevenue => throw _privateConstructorUsedError;
  Map<int, int> get hourlyOrders => throw _privateConstructorUsedError;
  int get peakHour => throw _privateConstructorUsedError;
  int get slowestHour => throw _privateConstructorUsedError;
  double get peakHourRevenue => throw _privateConstructorUsedError;

  /// Serializes this PeakHoursAnalysis to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PeakHoursAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PeakHoursAnalysisCopyWith<PeakHoursAnalysis> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PeakHoursAnalysisCopyWith<$Res> {
  factory $PeakHoursAnalysisCopyWith(
          PeakHoursAnalysis value, $Res Function(PeakHoursAnalysis) then) =
      _$PeakHoursAnalysisCopyWithImpl<$Res, PeakHoursAnalysis>;
  @useResult
  $Res call(
      {Map<int, double> hourlyRevenue,
      Map<int, int> hourlyOrders,
      int peakHour,
      int slowestHour,
      double peakHourRevenue});
}

/// @nodoc
class _$PeakHoursAnalysisCopyWithImpl<$Res, $Val extends PeakHoursAnalysis>
    implements $PeakHoursAnalysisCopyWith<$Res> {
  _$PeakHoursAnalysisCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PeakHoursAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hourlyRevenue = null,
    Object? hourlyOrders = null,
    Object? peakHour = null,
    Object? slowestHour = null,
    Object? peakHourRevenue = null,
  }) {
    return _then(_value.copyWith(
      hourlyRevenue: null == hourlyRevenue
          ? _value.hourlyRevenue
          : hourlyRevenue // ignore: cast_nullable_to_non_nullable
              as Map<int, double>,
      hourlyOrders: null == hourlyOrders
          ? _value.hourlyOrders
          : hourlyOrders // ignore: cast_nullable_to_non_nullable
              as Map<int, int>,
      peakHour: null == peakHour
          ? _value.peakHour
          : peakHour // ignore: cast_nullable_to_non_nullable
              as int,
      slowestHour: null == slowestHour
          ? _value.slowestHour
          : slowestHour // ignore: cast_nullable_to_non_nullable
              as int,
      peakHourRevenue: null == peakHourRevenue
          ? _value.peakHourRevenue
          : peakHourRevenue // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PeakHoursAnalysisImplCopyWith<$Res>
    implements $PeakHoursAnalysisCopyWith<$Res> {
  factory _$$PeakHoursAnalysisImplCopyWith(_$PeakHoursAnalysisImpl value,
          $Res Function(_$PeakHoursAnalysisImpl) then) =
      __$$PeakHoursAnalysisImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Map<int, double> hourlyRevenue,
      Map<int, int> hourlyOrders,
      int peakHour,
      int slowestHour,
      double peakHourRevenue});
}

/// @nodoc
class __$$PeakHoursAnalysisImplCopyWithImpl<$Res>
    extends _$PeakHoursAnalysisCopyWithImpl<$Res, _$PeakHoursAnalysisImpl>
    implements _$$PeakHoursAnalysisImplCopyWith<$Res> {
  __$$PeakHoursAnalysisImplCopyWithImpl(_$PeakHoursAnalysisImpl _value,
      $Res Function(_$PeakHoursAnalysisImpl) _then)
      : super(_value, _then);

  /// Create a copy of PeakHoursAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hourlyRevenue = null,
    Object? hourlyOrders = null,
    Object? peakHour = null,
    Object? slowestHour = null,
    Object? peakHourRevenue = null,
  }) {
    return _then(_$PeakHoursAnalysisImpl(
      hourlyRevenue: null == hourlyRevenue
          ? _value._hourlyRevenue
          : hourlyRevenue // ignore: cast_nullable_to_non_nullable
              as Map<int, double>,
      hourlyOrders: null == hourlyOrders
          ? _value._hourlyOrders
          : hourlyOrders // ignore: cast_nullable_to_non_nullable
              as Map<int, int>,
      peakHour: null == peakHour
          ? _value.peakHour
          : peakHour // ignore: cast_nullable_to_non_nullable
              as int,
      slowestHour: null == slowestHour
          ? _value.slowestHour
          : slowestHour // ignore: cast_nullable_to_non_nullable
              as int,
      peakHourRevenue: null == peakHourRevenue
          ? _value.peakHourRevenue
          : peakHourRevenue // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PeakHoursAnalysisImpl implements _PeakHoursAnalysis {
  const _$PeakHoursAnalysisImpl(
      {required final Map<int, double> hourlyRevenue,
      required final Map<int, int> hourlyOrders,
      required this.peakHour,
      required this.slowestHour,
      required this.peakHourRevenue})
      : _hourlyRevenue = hourlyRevenue,
        _hourlyOrders = hourlyOrders;

  factory _$PeakHoursAnalysisImpl.fromJson(Map<String, dynamic> json) =>
      _$$PeakHoursAnalysisImplFromJson(json);

  final Map<int, double> _hourlyRevenue;
  @override
  Map<int, double> get hourlyRevenue {
    if (_hourlyRevenue is EqualUnmodifiableMapView) return _hourlyRevenue;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_hourlyRevenue);
  }

  final Map<int, int> _hourlyOrders;
  @override
  Map<int, int> get hourlyOrders {
    if (_hourlyOrders is EqualUnmodifiableMapView) return _hourlyOrders;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_hourlyOrders);
  }

  @override
  final int peakHour;
  @override
  final int slowestHour;
  @override
  final double peakHourRevenue;

  @override
  String toString() {
    return 'PeakHoursAnalysis(hourlyRevenue: $hourlyRevenue, hourlyOrders: $hourlyOrders, peakHour: $peakHour, slowestHour: $slowestHour, peakHourRevenue: $peakHourRevenue)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PeakHoursAnalysisImpl &&
            const DeepCollectionEquality()
                .equals(other._hourlyRevenue, _hourlyRevenue) &&
            const DeepCollectionEquality()
                .equals(other._hourlyOrders, _hourlyOrders) &&
            (identical(other.peakHour, peakHour) ||
                other.peakHour == peakHour) &&
            (identical(other.slowestHour, slowestHour) ||
                other.slowestHour == slowestHour) &&
            (identical(other.peakHourRevenue, peakHourRevenue) ||
                other.peakHourRevenue == peakHourRevenue));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_hourlyRevenue),
      const DeepCollectionEquality().hash(_hourlyOrders),
      peakHour,
      slowestHour,
      peakHourRevenue);

  /// Create a copy of PeakHoursAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PeakHoursAnalysisImplCopyWith<_$PeakHoursAnalysisImpl> get copyWith =>
      __$$PeakHoursAnalysisImplCopyWithImpl<_$PeakHoursAnalysisImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PeakHoursAnalysisImplToJson(
      this,
    );
  }
}

abstract class _PeakHoursAnalysis implements PeakHoursAnalysis {
  const factory _PeakHoursAnalysis(
      {required final Map<int, double> hourlyRevenue,
      required final Map<int, int> hourlyOrders,
      required final int peakHour,
      required final int slowestHour,
      required final double peakHourRevenue}) = _$PeakHoursAnalysisImpl;

  factory _PeakHoursAnalysis.fromJson(Map<String, dynamic> json) =
      _$PeakHoursAnalysisImpl.fromJson;

  @override
  Map<int, double> get hourlyRevenue;
  @override
  Map<int, int> get hourlyOrders;
  @override
  int get peakHour;
  @override
  int get slowestHour;
  @override
  double get peakHourRevenue;

  /// Create a copy of PeakHoursAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PeakHoursAnalysisImplCopyWith<_$PeakHoursAnalysisImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CustomerPattern _$CustomerPatternFromJson(Map<String, dynamic> json) {
  return _CustomerPattern.fromJson(json);
}

/// @nodoc
mixin _$CustomerPattern {
  String get customerId => throw _privateConstructorUsedError;
  String get customerName => throw _privateConstructorUsedError;
  int get totalOrders => throw _privateConstructorUsedError;
  double get totalSpent => throw _privateConstructorUsedError;
  double get averageOrderValue => throw _privateConstructorUsedError;
  List<String> get frequentProducts => throw _privateConstructorUsedError;
  int get daysSinceLastOrder => throw _privateConstructorUsedError;
  DateTime? get lastOrderDate => throw _privateConstructorUsedError;

  /// Serializes this CustomerPattern to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CustomerPattern
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CustomerPatternCopyWith<CustomerPattern> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CustomerPatternCopyWith<$Res> {
  factory $CustomerPatternCopyWith(
          CustomerPattern value, $Res Function(CustomerPattern) then) =
      _$CustomerPatternCopyWithImpl<$Res, CustomerPattern>;
  @useResult
  $Res call(
      {String customerId,
      String customerName,
      int totalOrders,
      double totalSpent,
      double averageOrderValue,
      List<String> frequentProducts,
      int daysSinceLastOrder,
      DateTime? lastOrderDate});
}

/// @nodoc
class _$CustomerPatternCopyWithImpl<$Res, $Val extends CustomerPattern>
    implements $CustomerPatternCopyWith<$Res> {
  _$CustomerPatternCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CustomerPattern
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? customerId = null,
    Object? customerName = null,
    Object? totalOrders = null,
    Object? totalSpent = null,
    Object? averageOrderValue = null,
    Object? frequentProducts = null,
    Object? daysSinceLastOrder = null,
    Object? lastOrderDate = freezed,
  }) {
    return _then(_value.copyWith(
      customerId: null == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String,
      customerName: null == customerName
          ? _value.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String,
      totalOrders: null == totalOrders
          ? _value.totalOrders
          : totalOrders // ignore: cast_nullable_to_non_nullable
              as int,
      totalSpent: null == totalSpent
          ? _value.totalSpent
          : totalSpent // ignore: cast_nullable_to_non_nullable
              as double,
      averageOrderValue: null == averageOrderValue
          ? _value.averageOrderValue
          : averageOrderValue // ignore: cast_nullable_to_non_nullable
              as double,
      frequentProducts: null == frequentProducts
          ? _value.frequentProducts
          : frequentProducts // ignore: cast_nullable_to_non_nullable
              as List<String>,
      daysSinceLastOrder: null == daysSinceLastOrder
          ? _value.daysSinceLastOrder
          : daysSinceLastOrder // ignore: cast_nullable_to_non_nullable
              as int,
      lastOrderDate: freezed == lastOrderDate
          ? _value.lastOrderDate
          : lastOrderDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CustomerPatternImplCopyWith<$Res>
    implements $CustomerPatternCopyWith<$Res> {
  factory _$$CustomerPatternImplCopyWith(_$CustomerPatternImpl value,
          $Res Function(_$CustomerPatternImpl) then) =
      __$$CustomerPatternImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String customerId,
      String customerName,
      int totalOrders,
      double totalSpent,
      double averageOrderValue,
      List<String> frequentProducts,
      int daysSinceLastOrder,
      DateTime? lastOrderDate});
}

/// @nodoc
class __$$CustomerPatternImplCopyWithImpl<$Res>
    extends _$CustomerPatternCopyWithImpl<$Res, _$CustomerPatternImpl>
    implements _$$CustomerPatternImplCopyWith<$Res> {
  __$$CustomerPatternImplCopyWithImpl(
      _$CustomerPatternImpl _value, $Res Function(_$CustomerPatternImpl) _then)
      : super(_value, _then);

  /// Create a copy of CustomerPattern
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? customerId = null,
    Object? customerName = null,
    Object? totalOrders = null,
    Object? totalSpent = null,
    Object? averageOrderValue = null,
    Object? frequentProducts = null,
    Object? daysSinceLastOrder = null,
    Object? lastOrderDate = freezed,
  }) {
    return _then(_$CustomerPatternImpl(
      customerId: null == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String,
      customerName: null == customerName
          ? _value.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String,
      totalOrders: null == totalOrders
          ? _value.totalOrders
          : totalOrders // ignore: cast_nullable_to_non_nullable
              as int,
      totalSpent: null == totalSpent
          ? _value.totalSpent
          : totalSpent // ignore: cast_nullable_to_non_nullable
              as double,
      averageOrderValue: null == averageOrderValue
          ? _value.averageOrderValue
          : averageOrderValue // ignore: cast_nullable_to_non_nullable
              as double,
      frequentProducts: null == frequentProducts
          ? _value._frequentProducts
          : frequentProducts // ignore: cast_nullable_to_non_nullable
              as List<String>,
      daysSinceLastOrder: null == daysSinceLastOrder
          ? _value.daysSinceLastOrder
          : daysSinceLastOrder // ignore: cast_nullable_to_non_nullable
              as int,
      lastOrderDate: freezed == lastOrderDate
          ? _value.lastOrderDate
          : lastOrderDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomerPatternImpl implements _CustomerPattern {
  const _$CustomerPatternImpl(
      {required this.customerId,
      required this.customerName,
      required this.totalOrders,
      required this.totalSpent,
      required this.averageOrderValue,
      required final List<String> frequentProducts,
      required this.daysSinceLastOrder,
      this.lastOrderDate})
      : _frequentProducts = frequentProducts;

  factory _$CustomerPatternImpl.fromJson(Map<String, dynamic> json) =>
      _$$CustomerPatternImplFromJson(json);

  @override
  final String customerId;
  @override
  final String customerName;
  @override
  final int totalOrders;
  @override
  final double totalSpent;
  @override
  final double averageOrderValue;
  final List<String> _frequentProducts;
  @override
  List<String> get frequentProducts {
    if (_frequentProducts is EqualUnmodifiableListView)
      return _frequentProducts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_frequentProducts);
  }

  @override
  final int daysSinceLastOrder;
  @override
  final DateTime? lastOrderDate;

  @override
  String toString() {
    return 'CustomerPattern(customerId: $customerId, customerName: $customerName, totalOrders: $totalOrders, totalSpent: $totalSpent, averageOrderValue: $averageOrderValue, frequentProducts: $frequentProducts, daysSinceLastOrder: $daysSinceLastOrder, lastOrderDate: $lastOrderDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomerPatternImpl &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.totalOrders, totalOrders) ||
                other.totalOrders == totalOrders) &&
            (identical(other.totalSpent, totalSpent) ||
                other.totalSpent == totalSpent) &&
            (identical(other.averageOrderValue, averageOrderValue) ||
                other.averageOrderValue == averageOrderValue) &&
            const DeepCollectionEquality()
                .equals(other._frequentProducts, _frequentProducts) &&
            (identical(other.daysSinceLastOrder, daysSinceLastOrder) ||
                other.daysSinceLastOrder == daysSinceLastOrder) &&
            (identical(other.lastOrderDate, lastOrderDate) ||
                other.lastOrderDate == lastOrderDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      customerId,
      customerName,
      totalOrders,
      totalSpent,
      averageOrderValue,
      const DeepCollectionEquality().hash(_frequentProducts),
      daysSinceLastOrder,
      lastOrderDate);

  /// Create a copy of CustomerPattern
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomerPatternImplCopyWith<_$CustomerPatternImpl> get copyWith =>
      __$$CustomerPatternImplCopyWithImpl<_$CustomerPatternImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomerPatternImplToJson(
      this,
    );
  }
}

abstract class _CustomerPattern implements CustomerPattern {
  const factory _CustomerPattern(
      {required final String customerId,
      required final String customerName,
      required final int totalOrders,
      required final double totalSpent,
      required final double averageOrderValue,
      required final List<String> frequentProducts,
      required final int daysSinceLastOrder,
      final DateTime? lastOrderDate}) = _$CustomerPatternImpl;

  factory _CustomerPattern.fromJson(Map<String, dynamic> json) =
      _$CustomerPatternImpl.fromJson;

  @override
  String get customerId;
  @override
  String get customerName;
  @override
  int get totalOrders;
  @override
  double get totalSpent;
  @override
  double get averageOrderValue;
  @override
  List<String> get frequentProducts;
  @override
  int get daysSinceLastOrder;
  @override
  DateTime? get lastOrderDate;

  /// Create a copy of CustomerPattern
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CustomerPatternImplCopyWith<_$CustomerPatternImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
