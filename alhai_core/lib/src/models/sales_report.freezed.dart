// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sales_report.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SalesSummary _$SalesSummaryFromJson(Map<String, dynamic> json) {
  return _SalesSummary.fromJson(json);
}

/// @nodoc
mixin _$SalesSummary {
  DateTime get date => throw _privateConstructorUsedError;
  int get ordersCount => throw _privateConstructorUsedError;
  int get itemsSold => throw _privateConstructorUsedError;
  double get revenue => throw _privateConstructorUsedError;
  double get cost => throw _privateConstructorUsedError;
  double get profit => throw _privateConstructorUsedError;
  double get discounts => throw _privateConstructorUsedError;
  double get returns => throw _privateConstructorUsedError;

  /// Serializes this SalesSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SalesSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SalesSummaryCopyWith<SalesSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SalesSummaryCopyWith<$Res> {
  factory $SalesSummaryCopyWith(
    SalesSummary value,
    $Res Function(SalesSummary) then,
  ) = _$SalesSummaryCopyWithImpl<$Res, SalesSummary>;
  @useResult
  $Res call({
    DateTime date,
    int ordersCount,
    int itemsSold,
    double revenue,
    double cost,
    double profit,
    double discounts,
    double returns,
  });
}

/// @nodoc
class _$SalesSummaryCopyWithImpl<$Res, $Val extends SalesSummary>
    implements $SalesSummaryCopyWith<$Res> {
  _$SalesSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SalesSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? ordersCount = null,
    Object? itemsSold = null,
    Object? revenue = null,
    Object? cost = null,
    Object? profit = null,
    Object? discounts = null,
    Object? returns = null,
  }) {
    return _then(
      _value.copyWith(
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            ordersCount: null == ordersCount
                ? _value.ordersCount
                : ordersCount // ignore: cast_nullable_to_non_nullable
                      as int,
            itemsSold: null == itemsSold
                ? _value.itemsSold
                : itemsSold // ignore: cast_nullable_to_non_nullable
                      as int,
            revenue: null == revenue
                ? _value.revenue
                : revenue // ignore: cast_nullable_to_non_nullable
                      as double,
            cost: null == cost
                ? _value.cost
                : cost // ignore: cast_nullable_to_non_nullable
                      as double,
            profit: null == profit
                ? _value.profit
                : profit // ignore: cast_nullable_to_non_nullable
                      as double,
            discounts: null == discounts
                ? _value.discounts
                : discounts // ignore: cast_nullable_to_non_nullable
                      as double,
            returns: null == returns
                ? _value.returns
                : returns // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SalesSummaryImplCopyWith<$Res>
    implements $SalesSummaryCopyWith<$Res> {
  factory _$$SalesSummaryImplCopyWith(
    _$SalesSummaryImpl value,
    $Res Function(_$SalesSummaryImpl) then,
  ) = __$$SalesSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    DateTime date,
    int ordersCount,
    int itemsSold,
    double revenue,
    double cost,
    double profit,
    double discounts,
    double returns,
  });
}

/// @nodoc
class __$$SalesSummaryImplCopyWithImpl<$Res>
    extends _$SalesSummaryCopyWithImpl<$Res, _$SalesSummaryImpl>
    implements _$$SalesSummaryImplCopyWith<$Res> {
  __$$SalesSummaryImplCopyWithImpl(
    _$SalesSummaryImpl _value,
    $Res Function(_$SalesSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SalesSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? ordersCount = null,
    Object? itemsSold = null,
    Object? revenue = null,
    Object? cost = null,
    Object? profit = null,
    Object? discounts = null,
    Object? returns = null,
  }) {
    return _then(
      _$SalesSummaryImpl(
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        ordersCount: null == ordersCount
            ? _value.ordersCount
            : ordersCount // ignore: cast_nullable_to_non_nullable
                  as int,
        itemsSold: null == itemsSold
            ? _value.itemsSold
            : itemsSold // ignore: cast_nullable_to_non_nullable
                  as int,
        revenue: null == revenue
            ? _value.revenue
            : revenue // ignore: cast_nullable_to_non_nullable
                  as double,
        cost: null == cost
            ? _value.cost
            : cost // ignore: cast_nullable_to_non_nullable
                  as double,
        profit: null == profit
            ? _value.profit
            : profit // ignore: cast_nullable_to_non_nullable
                  as double,
        discounts: null == discounts
            ? _value.discounts
            : discounts // ignore: cast_nullable_to_non_nullable
                  as double,
        returns: null == returns
            ? _value.returns
            : returns // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SalesSummaryImpl extends _SalesSummary {
  const _$SalesSummaryImpl({
    required this.date,
    required this.ordersCount,
    required this.itemsSold,
    required this.revenue,
    required this.cost,
    required this.profit,
    this.discounts = 0,
    this.returns = 0,
  }) : super._();

  factory _$SalesSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$SalesSummaryImplFromJson(json);

  @override
  final DateTime date;
  @override
  final int ordersCount;
  @override
  final int itemsSold;
  @override
  final double revenue;
  @override
  final double cost;
  @override
  final double profit;
  @override
  @JsonKey()
  final double discounts;
  @override
  @JsonKey()
  final double returns;

  @override
  String toString() {
    return 'SalesSummary(date: $date, ordersCount: $ordersCount, itemsSold: $itemsSold, revenue: $revenue, cost: $cost, profit: $profit, discounts: $discounts, returns: $returns)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SalesSummaryImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.ordersCount, ordersCount) ||
                other.ordersCount == ordersCount) &&
            (identical(other.itemsSold, itemsSold) ||
                other.itemsSold == itemsSold) &&
            (identical(other.revenue, revenue) || other.revenue == revenue) &&
            (identical(other.cost, cost) || other.cost == cost) &&
            (identical(other.profit, profit) || other.profit == profit) &&
            (identical(other.discounts, discounts) ||
                other.discounts == discounts) &&
            (identical(other.returns, returns) || other.returns == returns));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    date,
    ordersCount,
    itemsSold,
    revenue,
    cost,
    profit,
    discounts,
    returns,
  );

  /// Create a copy of SalesSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SalesSummaryImplCopyWith<_$SalesSummaryImpl> get copyWith =>
      __$$SalesSummaryImplCopyWithImpl<_$SalesSummaryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SalesSummaryImplToJson(this);
  }
}

abstract class _SalesSummary extends SalesSummary {
  const factory _SalesSummary({
    required final DateTime date,
    required final int ordersCount,
    required final int itemsSold,
    required final double revenue,
    required final double cost,
    required final double profit,
    final double discounts,
    final double returns,
  }) = _$SalesSummaryImpl;
  const _SalesSummary._() : super._();

  factory _SalesSummary.fromJson(Map<String, dynamic> json) =
      _$SalesSummaryImpl.fromJson;

  @override
  DateTime get date;
  @override
  int get ordersCount;
  @override
  int get itemsSold;
  @override
  double get revenue;
  @override
  double get cost;
  @override
  double get profit;
  @override
  double get discounts;
  @override
  double get returns;

  /// Create a copy of SalesSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SalesSummaryImplCopyWith<_$SalesSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProductSales _$ProductSalesFromJson(Map<String, dynamic> json) {
  return _ProductSales.fromJson(json);
}

/// @nodoc
mixin _$ProductSales {
  String get productId => throw _privateConstructorUsedError;
  String get productName => throw _privateConstructorUsedError;
  String? get categoryId => throw _privateConstructorUsedError;
  int get quantitySold => throw _privateConstructorUsedError;
  double get revenue => throw _privateConstructorUsedError;
  double get cost => throw _privateConstructorUsedError;
  double get profit => throw _privateConstructorUsedError;

  /// Serializes this ProductSales to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProductSales
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductSalesCopyWith<ProductSales> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductSalesCopyWith<$Res> {
  factory $ProductSalesCopyWith(
    ProductSales value,
    $Res Function(ProductSales) then,
  ) = _$ProductSalesCopyWithImpl<$Res, ProductSales>;
  @useResult
  $Res call({
    String productId,
    String productName,
    String? categoryId,
    int quantitySold,
    double revenue,
    double cost,
    double profit,
  });
}

/// @nodoc
class _$ProductSalesCopyWithImpl<$Res, $Val extends ProductSales>
    implements $ProductSalesCopyWith<$Res> {
  _$ProductSalesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductSales
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = null,
    Object? productName = null,
    Object? categoryId = freezed,
    Object? quantitySold = null,
    Object? revenue = null,
    Object? cost = null,
    Object? profit = null,
  }) {
    return _then(
      _value.copyWith(
            productId: null == productId
                ? _value.productId
                : productId // ignore: cast_nullable_to_non_nullable
                      as String,
            productName: null == productName
                ? _value.productName
                : productName // ignore: cast_nullable_to_non_nullable
                      as String,
            categoryId: freezed == categoryId
                ? _value.categoryId
                : categoryId // ignore: cast_nullable_to_non_nullable
                      as String?,
            quantitySold: null == quantitySold
                ? _value.quantitySold
                : quantitySold // ignore: cast_nullable_to_non_nullable
                      as int,
            revenue: null == revenue
                ? _value.revenue
                : revenue // ignore: cast_nullable_to_non_nullable
                      as double,
            cost: null == cost
                ? _value.cost
                : cost // ignore: cast_nullable_to_non_nullable
                      as double,
            profit: null == profit
                ? _value.profit
                : profit // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProductSalesImplCopyWith<$Res>
    implements $ProductSalesCopyWith<$Res> {
  factory _$$ProductSalesImplCopyWith(
    _$ProductSalesImpl value,
    $Res Function(_$ProductSalesImpl) then,
  ) = __$$ProductSalesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String productId,
    String productName,
    String? categoryId,
    int quantitySold,
    double revenue,
    double cost,
    double profit,
  });
}

/// @nodoc
class __$$ProductSalesImplCopyWithImpl<$Res>
    extends _$ProductSalesCopyWithImpl<$Res, _$ProductSalesImpl>
    implements _$$ProductSalesImplCopyWith<$Res> {
  __$$ProductSalesImplCopyWithImpl(
    _$ProductSalesImpl _value,
    $Res Function(_$ProductSalesImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProductSales
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = null,
    Object? productName = null,
    Object? categoryId = freezed,
    Object? quantitySold = null,
    Object? revenue = null,
    Object? cost = null,
    Object? profit = null,
  }) {
    return _then(
      _$ProductSalesImpl(
        productId: null == productId
            ? _value.productId
            : productId // ignore: cast_nullable_to_non_nullable
                  as String,
        productName: null == productName
            ? _value.productName
            : productName // ignore: cast_nullable_to_non_nullable
                  as String,
        categoryId: freezed == categoryId
            ? _value.categoryId
            : categoryId // ignore: cast_nullable_to_non_nullable
                  as String?,
        quantitySold: null == quantitySold
            ? _value.quantitySold
            : quantitySold // ignore: cast_nullable_to_non_nullable
                  as int,
        revenue: null == revenue
            ? _value.revenue
            : revenue // ignore: cast_nullable_to_non_nullable
                  as double,
        cost: null == cost
            ? _value.cost
            : cost // ignore: cast_nullable_to_non_nullable
                  as double,
        profit: null == profit
            ? _value.profit
            : profit // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductSalesImpl extends _ProductSales {
  const _$ProductSalesImpl({
    required this.productId,
    required this.productName,
    this.categoryId,
    required this.quantitySold,
    required this.revenue,
    required this.cost,
    required this.profit,
  }) : super._();

  factory _$ProductSalesImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductSalesImplFromJson(json);

  @override
  final String productId;
  @override
  final String productName;
  @override
  final String? categoryId;
  @override
  final int quantitySold;
  @override
  final double revenue;
  @override
  final double cost;
  @override
  final double profit;

  @override
  String toString() {
    return 'ProductSales(productId: $productId, productName: $productName, categoryId: $categoryId, quantitySold: $quantitySold, revenue: $revenue, cost: $cost, profit: $profit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductSalesImpl &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.productName, productName) ||
                other.productName == productName) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.quantitySold, quantitySold) ||
                other.quantitySold == quantitySold) &&
            (identical(other.revenue, revenue) || other.revenue == revenue) &&
            (identical(other.cost, cost) || other.cost == cost) &&
            (identical(other.profit, profit) || other.profit == profit));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    productId,
    productName,
    categoryId,
    quantitySold,
    revenue,
    cost,
    profit,
  );

  /// Create a copy of ProductSales
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductSalesImplCopyWith<_$ProductSalesImpl> get copyWith =>
      __$$ProductSalesImplCopyWithImpl<_$ProductSalesImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductSalesImplToJson(this);
  }
}

abstract class _ProductSales extends ProductSales {
  const factory _ProductSales({
    required final String productId,
    required final String productName,
    final String? categoryId,
    required final int quantitySold,
    required final double revenue,
    required final double cost,
    required final double profit,
  }) = _$ProductSalesImpl;
  const _ProductSales._() : super._();

  factory _ProductSales.fromJson(Map<String, dynamic> json) =
      _$ProductSalesImpl.fromJson;

  @override
  String get productId;
  @override
  String get productName;
  @override
  String? get categoryId;
  @override
  int get quantitySold;
  @override
  double get revenue;
  @override
  double get cost;
  @override
  double get profit;

  /// Create a copy of ProductSales
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductSalesImplCopyWith<_$ProductSalesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CategorySales _$CategorySalesFromJson(Map<String, dynamic> json) {
  return _CategorySales.fromJson(json);
}

/// @nodoc
mixin _$CategorySales {
  String get categoryId => throw _privateConstructorUsedError;
  String get categoryName => throw _privateConstructorUsedError;
  int get productsSold => throw _privateConstructorUsedError;
  double get revenue => throw _privateConstructorUsedError;
  double get profit => throw _privateConstructorUsedError;

  /// Serializes this CategorySales to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CategorySales
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CategorySalesCopyWith<CategorySales> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CategorySalesCopyWith<$Res> {
  factory $CategorySalesCopyWith(
    CategorySales value,
    $Res Function(CategorySales) then,
  ) = _$CategorySalesCopyWithImpl<$Res, CategorySales>;
  @useResult
  $Res call({
    String categoryId,
    String categoryName,
    int productsSold,
    double revenue,
    double profit,
  });
}

/// @nodoc
class _$CategorySalesCopyWithImpl<$Res, $Val extends CategorySales>
    implements $CategorySalesCopyWith<$Res> {
  _$CategorySalesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CategorySales
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? categoryId = null,
    Object? categoryName = null,
    Object? productsSold = null,
    Object? revenue = null,
    Object? profit = null,
  }) {
    return _then(
      _value.copyWith(
            categoryId: null == categoryId
                ? _value.categoryId
                : categoryId // ignore: cast_nullable_to_non_nullable
                      as String,
            categoryName: null == categoryName
                ? _value.categoryName
                : categoryName // ignore: cast_nullable_to_non_nullable
                      as String,
            productsSold: null == productsSold
                ? _value.productsSold
                : productsSold // ignore: cast_nullable_to_non_nullable
                      as int,
            revenue: null == revenue
                ? _value.revenue
                : revenue // ignore: cast_nullable_to_non_nullable
                      as double,
            profit: null == profit
                ? _value.profit
                : profit // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CategorySalesImplCopyWith<$Res>
    implements $CategorySalesCopyWith<$Res> {
  factory _$$CategorySalesImplCopyWith(
    _$CategorySalesImpl value,
    $Res Function(_$CategorySalesImpl) then,
  ) = __$$CategorySalesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String categoryId,
    String categoryName,
    int productsSold,
    double revenue,
    double profit,
  });
}

/// @nodoc
class __$$CategorySalesImplCopyWithImpl<$Res>
    extends _$CategorySalesCopyWithImpl<$Res, _$CategorySalesImpl>
    implements _$$CategorySalesImplCopyWith<$Res> {
  __$$CategorySalesImplCopyWithImpl(
    _$CategorySalesImpl _value,
    $Res Function(_$CategorySalesImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CategorySales
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? categoryId = null,
    Object? categoryName = null,
    Object? productsSold = null,
    Object? revenue = null,
    Object? profit = null,
  }) {
    return _then(
      _$CategorySalesImpl(
        categoryId: null == categoryId
            ? _value.categoryId
            : categoryId // ignore: cast_nullable_to_non_nullable
                  as String,
        categoryName: null == categoryName
            ? _value.categoryName
            : categoryName // ignore: cast_nullable_to_non_nullable
                  as String,
        productsSold: null == productsSold
            ? _value.productsSold
            : productsSold // ignore: cast_nullable_to_non_nullable
                  as int,
        revenue: null == revenue
            ? _value.revenue
            : revenue // ignore: cast_nullable_to_non_nullable
                  as double,
        profit: null == profit
            ? _value.profit
            : profit // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CategorySalesImpl implements _CategorySales {
  const _$CategorySalesImpl({
    required this.categoryId,
    required this.categoryName,
    required this.productsSold,
    required this.revenue,
    required this.profit,
  });

  factory _$CategorySalesImpl.fromJson(Map<String, dynamic> json) =>
      _$$CategorySalesImplFromJson(json);

  @override
  final String categoryId;
  @override
  final String categoryName;
  @override
  final int productsSold;
  @override
  final double revenue;
  @override
  final double profit;

  @override
  String toString() {
    return 'CategorySales(categoryId: $categoryId, categoryName: $categoryName, productsSold: $productsSold, revenue: $revenue, profit: $profit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CategorySalesImpl &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.categoryName, categoryName) ||
                other.categoryName == categoryName) &&
            (identical(other.productsSold, productsSold) ||
                other.productsSold == productsSold) &&
            (identical(other.revenue, revenue) || other.revenue == revenue) &&
            (identical(other.profit, profit) || other.profit == profit));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    categoryId,
    categoryName,
    productsSold,
    revenue,
    profit,
  );

  /// Create a copy of CategorySales
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CategorySalesImplCopyWith<_$CategorySalesImpl> get copyWith =>
      __$$CategorySalesImplCopyWithImpl<_$CategorySalesImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CategorySalesImplToJson(this);
  }
}

abstract class _CategorySales implements CategorySales {
  const factory _CategorySales({
    required final String categoryId,
    required final String categoryName,
    required final int productsSold,
    required final double revenue,
    required final double profit,
  }) = _$CategorySalesImpl;

  factory _CategorySales.fromJson(Map<String, dynamic> json) =
      _$CategorySalesImpl.fromJson;

  @override
  String get categoryId;
  @override
  String get categoryName;
  @override
  int get productsSold;
  @override
  double get revenue;
  @override
  double get profit;

  /// Create a copy of CategorySales
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CategorySalesImplCopyWith<_$CategorySalesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

InventoryValue _$InventoryValueFromJson(Map<String, dynamic> json) {
  return _InventoryValue.fromJson(json);
}

/// @nodoc
mixin _$InventoryValue {
  int get totalProducts => throw _privateConstructorUsedError;
  int get totalUnits => throw _privateConstructorUsedError;
  double get costValue => throw _privateConstructorUsedError;
  double get retailValue => throw _privateConstructorUsedError;
  int get lowStockCount => throw _privateConstructorUsedError;
  int get outOfStockCount => throw _privateConstructorUsedError;

  /// Serializes this InventoryValue to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of InventoryValue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InventoryValueCopyWith<InventoryValue> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InventoryValueCopyWith<$Res> {
  factory $InventoryValueCopyWith(
    InventoryValue value,
    $Res Function(InventoryValue) then,
  ) = _$InventoryValueCopyWithImpl<$Res, InventoryValue>;
  @useResult
  $Res call({
    int totalProducts,
    int totalUnits,
    double costValue,
    double retailValue,
    int lowStockCount,
    int outOfStockCount,
  });
}

/// @nodoc
class _$InventoryValueCopyWithImpl<$Res, $Val extends InventoryValue>
    implements $InventoryValueCopyWith<$Res> {
  _$InventoryValueCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InventoryValue
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalProducts = null,
    Object? totalUnits = null,
    Object? costValue = null,
    Object? retailValue = null,
    Object? lowStockCount = null,
    Object? outOfStockCount = null,
  }) {
    return _then(
      _value.copyWith(
            totalProducts: null == totalProducts
                ? _value.totalProducts
                : totalProducts // ignore: cast_nullable_to_non_nullable
                      as int,
            totalUnits: null == totalUnits
                ? _value.totalUnits
                : totalUnits // ignore: cast_nullable_to_non_nullable
                      as int,
            costValue: null == costValue
                ? _value.costValue
                : costValue // ignore: cast_nullable_to_non_nullable
                      as double,
            retailValue: null == retailValue
                ? _value.retailValue
                : retailValue // ignore: cast_nullable_to_non_nullable
                      as double,
            lowStockCount: null == lowStockCount
                ? _value.lowStockCount
                : lowStockCount // ignore: cast_nullable_to_non_nullable
                      as int,
            outOfStockCount: null == outOfStockCount
                ? _value.outOfStockCount
                : outOfStockCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$InventoryValueImplCopyWith<$Res>
    implements $InventoryValueCopyWith<$Res> {
  factory _$$InventoryValueImplCopyWith(
    _$InventoryValueImpl value,
    $Res Function(_$InventoryValueImpl) then,
  ) = __$$InventoryValueImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int totalProducts,
    int totalUnits,
    double costValue,
    double retailValue,
    int lowStockCount,
    int outOfStockCount,
  });
}

/// @nodoc
class __$$InventoryValueImplCopyWithImpl<$Res>
    extends _$InventoryValueCopyWithImpl<$Res, _$InventoryValueImpl>
    implements _$$InventoryValueImplCopyWith<$Res> {
  __$$InventoryValueImplCopyWithImpl(
    _$InventoryValueImpl _value,
    $Res Function(_$InventoryValueImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of InventoryValue
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalProducts = null,
    Object? totalUnits = null,
    Object? costValue = null,
    Object? retailValue = null,
    Object? lowStockCount = null,
    Object? outOfStockCount = null,
  }) {
    return _then(
      _$InventoryValueImpl(
        totalProducts: null == totalProducts
            ? _value.totalProducts
            : totalProducts // ignore: cast_nullable_to_non_nullable
                  as int,
        totalUnits: null == totalUnits
            ? _value.totalUnits
            : totalUnits // ignore: cast_nullable_to_non_nullable
                  as int,
        costValue: null == costValue
            ? _value.costValue
            : costValue // ignore: cast_nullable_to_non_nullable
                  as double,
        retailValue: null == retailValue
            ? _value.retailValue
            : retailValue // ignore: cast_nullable_to_non_nullable
                  as double,
        lowStockCount: null == lowStockCount
            ? _value.lowStockCount
            : lowStockCount // ignore: cast_nullable_to_non_nullable
                  as int,
        outOfStockCount: null == outOfStockCount
            ? _value.outOfStockCount
            : outOfStockCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$InventoryValueImpl implements _InventoryValue {
  const _$InventoryValueImpl({
    required this.totalProducts,
    required this.totalUnits,
    required this.costValue,
    required this.retailValue,
    required this.lowStockCount,
    required this.outOfStockCount,
  });

  factory _$InventoryValueImpl.fromJson(Map<String, dynamic> json) =>
      _$$InventoryValueImplFromJson(json);

  @override
  final int totalProducts;
  @override
  final int totalUnits;
  @override
  final double costValue;
  @override
  final double retailValue;
  @override
  final int lowStockCount;
  @override
  final int outOfStockCount;

  @override
  String toString() {
    return 'InventoryValue(totalProducts: $totalProducts, totalUnits: $totalUnits, costValue: $costValue, retailValue: $retailValue, lowStockCount: $lowStockCount, outOfStockCount: $outOfStockCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InventoryValueImpl &&
            (identical(other.totalProducts, totalProducts) ||
                other.totalProducts == totalProducts) &&
            (identical(other.totalUnits, totalUnits) ||
                other.totalUnits == totalUnits) &&
            (identical(other.costValue, costValue) ||
                other.costValue == costValue) &&
            (identical(other.retailValue, retailValue) ||
                other.retailValue == retailValue) &&
            (identical(other.lowStockCount, lowStockCount) ||
                other.lowStockCount == lowStockCount) &&
            (identical(other.outOfStockCount, outOfStockCount) ||
                other.outOfStockCount == outOfStockCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    totalProducts,
    totalUnits,
    costValue,
    retailValue,
    lowStockCount,
    outOfStockCount,
  );

  /// Create a copy of InventoryValue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InventoryValueImplCopyWith<_$InventoryValueImpl> get copyWith =>
      __$$InventoryValueImplCopyWithImpl<_$InventoryValueImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$InventoryValueImplToJson(this);
  }
}

abstract class _InventoryValue implements InventoryValue {
  const factory _InventoryValue({
    required final int totalProducts,
    required final int totalUnits,
    required final double costValue,
    required final double retailValue,
    required final int lowStockCount,
    required final int outOfStockCount,
  }) = _$InventoryValueImpl;

  factory _InventoryValue.fromJson(Map<String, dynamic> json) =
      _$InventoryValueImpl.fromJson;

  @override
  int get totalProducts;
  @override
  int get totalUnits;
  @override
  double get costValue;
  @override
  double get retailValue;
  @override
  int get lowStockCount;
  @override
  int get outOfStockCount;

  /// Create a copy of InventoryValue
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InventoryValueImplCopyWith<_$InventoryValueImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
