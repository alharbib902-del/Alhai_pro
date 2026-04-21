// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_product_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CreateProductRequest _$CreateProductRequestFromJson(Map<String, dynamic> json) {
  return _CreateProductRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateProductRequest {
  String get name =>
      throw _privateConstructorUsedError; // C-4 Stage B: int cents on the wire (matches int-cents Supabase schema).
  int get price => throw _privateConstructorUsedError;
  @JsonKey(name: 'store_id')
  String get storeId => throw _privateConstructorUsedError;
  @JsonKey(name: 'cost_price')
  int? get costPrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'stock_qty')
  int get stockQty => throw _privateConstructorUsedError;
  @JsonKey(name: 'min_qty')
  int get minQty => throw _privateConstructorUsedError;
  String? get unit => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_url')
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get barcode => throw _privateConstructorUsedError;
  String? get sku => throw _privateConstructorUsedError;
  @JsonKey(name: 'category_id')
  String? get categoryId => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;
  @JsonKey(name: 'track_inventory')
  bool get trackInventory => throw _privateConstructorUsedError;

  /// Serializes this CreateProductRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateProductRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateProductRequestCopyWith<CreateProductRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateProductRequestCopyWith<$Res> {
  factory $CreateProductRequestCopyWith(CreateProductRequest value,
          $Res Function(CreateProductRequest) then) =
      _$CreateProductRequestCopyWithImpl<$Res, CreateProductRequest>;
  @useResult
  $Res call(
      {String name,
      int price,
      @JsonKey(name: 'store_id') String storeId,
      @JsonKey(name: 'cost_price') int? costPrice,
      @JsonKey(name: 'stock_qty') int stockQty,
      @JsonKey(name: 'min_qty') int minQty,
      String? unit,
      String? description,
      @JsonKey(name: 'image_url') String? imageUrl,
      String? barcode,
      String? sku,
      @JsonKey(name: 'category_id') String? categoryId,
      @JsonKey(name: 'is_active') bool isActive,
      @JsonKey(name: 'track_inventory') bool trackInventory});
}

/// @nodoc
class _$CreateProductRequestCopyWithImpl<$Res,
        $Val extends CreateProductRequest>
    implements $CreateProductRequestCopyWith<$Res> {
  _$CreateProductRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateProductRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? price = null,
    Object? storeId = null,
    Object? costPrice = freezed,
    Object? stockQty = null,
    Object? minQty = null,
    Object? unit = freezed,
    Object? description = freezed,
    Object? imageUrl = freezed,
    Object? barcode = freezed,
    Object? sku = freezed,
    Object? categoryId = freezed,
    Object? isActive = null,
    Object? trackInventory = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as int,
      storeId: null == storeId
          ? _value.storeId
          : storeId // ignore: cast_nullable_to_non_nullable
              as String,
      costPrice: freezed == costPrice
          ? _value.costPrice
          : costPrice // ignore: cast_nullable_to_non_nullable
              as int?,
      stockQty: null == stockQty
          ? _value.stockQty
          : stockQty // ignore: cast_nullable_to_non_nullable
              as int,
      minQty: null == minQty
          ? _value.minQty
          : minQty // ignore: cast_nullable_to_non_nullable
              as int,
      unit: freezed == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      barcode: freezed == barcode
          ? _value.barcode
          : barcode // ignore: cast_nullable_to_non_nullable
              as String?,
      sku: freezed == sku
          ? _value.sku
          : sku // ignore: cast_nullable_to_non_nullable
              as String?,
      categoryId: freezed == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      trackInventory: null == trackInventory
          ? _value.trackInventory
          : trackInventory // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreateProductRequestImplCopyWith<$Res>
    implements $CreateProductRequestCopyWith<$Res> {
  factory _$$CreateProductRequestImplCopyWith(_$CreateProductRequestImpl value,
          $Res Function(_$CreateProductRequestImpl) then) =
      __$$CreateProductRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      int price,
      @JsonKey(name: 'store_id') String storeId,
      @JsonKey(name: 'cost_price') int? costPrice,
      @JsonKey(name: 'stock_qty') int stockQty,
      @JsonKey(name: 'min_qty') int minQty,
      String? unit,
      String? description,
      @JsonKey(name: 'image_url') String? imageUrl,
      String? barcode,
      String? sku,
      @JsonKey(name: 'category_id') String? categoryId,
      @JsonKey(name: 'is_active') bool isActive,
      @JsonKey(name: 'track_inventory') bool trackInventory});
}

/// @nodoc
class __$$CreateProductRequestImplCopyWithImpl<$Res>
    extends _$CreateProductRequestCopyWithImpl<$Res, _$CreateProductRequestImpl>
    implements _$$CreateProductRequestImplCopyWith<$Res> {
  __$$CreateProductRequestImplCopyWithImpl(_$CreateProductRequestImpl _value,
      $Res Function(_$CreateProductRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of CreateProductRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? price = null,
    Object? storeId = null,
    Object? costPrice = freezed,
    Object? stockQty = null,
    Object? minQty = null,
    Object? unit = freezed,
    Object? description = freezed,
    Object? imageUrl = freezed,
    Object? barcode = freezed,
    Object? sku = freezed,
    Object? categoryId = freezed,
    Object? isActive = null,
    Object? trackInventory = null,
  }) {
    return _then(_$CreateProductRequestImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as int,
      storeId: null == storeId
          ? _value.storeId
          : storeId // ignore: cast_nullable_to_non_nullable
              as String,
      costPrice: freezed == costPrice
          ? _value.costPrice
          : costPrice // ignore: cast_nullable_to_non_nullable
              as int?,
      stockQty: null == stockQty
          ? _value.stockQty
          : stockQty // ignore: cast_nullable_to_non_nullable
              as int,
      minQty: null == minQty
          ? _value.minQty
          : minQty // ignore: cast_nullable_to_non_nullable
              as int,
      unit: freezed == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      barcode: freezed == barcode
          ? _value.barcode
          : barcode // ignore: cast_nullable_to_non_nullable
              as String?,
      sku: freezed == sku
          ? _value.sku
          : sku // ignore: cast_nullable_to_non_nullable
              as String?,
      categoryId: freezed == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      trackInventory: null == trackInventory
          ? _value.trackInventory
          : trackInventory // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateProductRequestImpl extends _CreateProductRequest {
  const _$CreateProductRequestImpl(
      {required this.name,
      required this.price,
      @JsonKey(name: 'store_id') required this.storeId,
      @JsonKey(name: 'cost_price') this.costPrice,
      @JsonKey(name: 'stock_qty') this.stockQty = 0,
      @JsonKey(name: 'min_qty') this.minQty = 1,
      this.unit,
      this.description,
      @JsonKey(name: 'image_url') this.imageUrl,
      this.barcode,
      this.sku,
      @JsonKey(name: 'category_id') this.categoryId,
      @JsonKey(name: 'is_active') this.isActive = true,
      @JsonKey(name: 'track_inventory') this.trackInventory = true})
      : super._();

  factory _$CreateProductRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateProductRequestImplFromJson(json);

  @override
  final String name;
// C-4 Stage B: int cents on the wire (matches int-cents Supabase schema).
  @override
  final int price;
  @override
  @JsonKey(name: 'store_id')
  final String storeId;
  @override
  @JsonKey(name: 'cost_price')
  final int? costPrice;
  @override
  @JsonKey(name: 'stock_qty')
  final int stockQty;
  @override
  @JsonKey(name: 'min_qty')
  final int minQty;
  @override
  final String? unit;
  @override
  final String? description;
  @override
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @override
  final String? barcode;
  @override
  final String? sku;
  @override
  @JsonKey(name: 'category_id')
  final String? categoryId;
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;
  @override
  @JsonKey(name: 'track_inventory')
  final bool trackInventory;

  @override
  String toString() {
    return 'CreateProductRequest(name: $name, price: $price, storeId: $storeId, costPrice: $costPrice, stockQty: $stockQty, minQty: $minQty, unit: $unit, description: $description, imageUrl: $imageUrl, barcode: $barcode, sku: $sku, categoryId: $categoryId, isActive: $isActive, trackInventory: $trackInventory)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateProductRequestImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.storeId, storeId) || other.storeId == storeId) &&
            (identical(other.costPrice, costPrice) ||
                other.costPrice == costPrice) &&
            (identical(other.stockQty, stockQty) ||
                other.stockQty == stockQty) &&
            (identical(other.minQty, minQty) || other.minQty == minQty) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.barcode, barcode) || other.barcode == barcode) &&
            (identical(other.sku, sku) || other.sku == sku) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.trackInventory, trackInventory) ||
                other.trackInventory == trackInventory));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      name,
      price,
      storeId,
      costPrice,
      stockQty,
      minQty,
      unit,
      description,
      imageUrl,
      barcode,
      sku,
      categoryId,
      isActive,
      trackInventory);

  /// Create a copy of CreateProductRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateProductRequestImplCopyWith<_$CreateProductRequestImpl>
      get copyWith =>
          __$$CreateProductRequestImplCopyWithImpl<_$CreateProductRequestImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateProductRequestImplToJson(
      this,
    );
  }
}

abstract class _CreateProductRequest extends CreateProductRequest {
  const factory _CreateProductRequest(
          {required final String name,
          required final int price,
          @JsonKey(name: 'store_id') required final String storeId,
          @JsonKey(name: 'cost_price') final int? costPrice,
          @JsonKey(name: 'stock_qty') final int stockQty,
          @JsonKey(name: 'min_qty') final int minQty,
          final String? unit,
          final String? description,
          @JsonKey(name: 'image_url') final String? imageUrl,
          final String? barcode,
          final String? sku,
          @JsonKey(name: 'category_id') final String? categoryId,
          @JsonKey(name: 'is_active') final bool isActive,
          @JsonKey(name: 'track_inventory') final bool trackInventory}) =
      _$CreateProductRequestImpl;
  const _CreateProductRequest._() : super._();

  factory _CreateProductRequest.fromJson(Map<String, dynamic> json) =
      _$CreateProductRequestImpl.fromJson;

  @override
  String
      get name; // C-4 Stage B: int cents on the wire (matches int-cents Supabase schema).
  @override
  int get price;
  @override
  @JsonKey(name: 'store_id')
  String get storeId;
  @override
  @JsonKey(name: 'cost_price')
  int? get costPrice;
  @override
  @JsonKey(name: 'stock_qty')
  int get stockQty;
  @override
  @JsonKey(name: 'min_qty')
  int get minQty;
  @override
  String? get unit;
  @override
  String? get description;
  @override
  @JsonKey(name: 'image_url')
  String? get imageUrl;
  @override
  String? get barcode;
  @override
  String? get sku;
  @override
  @JsonKey(name: 'category_id')
  String? get categoryId;
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;
  @override
  @JsonKey(name: 'track_inventory')
  bool get trackInventory;

  /// Create a copy of CreateProductRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateProductRequestImplCopyWith<_$CreateProductRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}
