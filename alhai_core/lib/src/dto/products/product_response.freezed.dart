// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ProductResponse _$ProductResponseFromJson(Map<String, dynamic> json) {
  return _ProductResponse.fromJson(json);
}

/// @nodoc
mixin _$ProductResponse {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'store_id')
  String get storeId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get sku => throw _privateConstructorUsedError;
  String? get barcode => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  @JsonKey(name: 'cost_price')
  double? get costPrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'stock_qty')
  int get stockQty => throw _privateConstructorUsedError;
  @JsonKey(name: 'min_qty')
  int get minQty => throw _privateConstructorUsedError;
  String? get unit => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @Deprecated('Use imageThumbnail, imageMedium, or imageLarge')
  @JsonKey(name: 'image_url')
  String? get imageUrl =>
      throw _privateConstructorUsedError; // R2 Image Storage (Cloudflare CDN)
  @JsonKey(name: 'image_thumbnail')
  String? get imageThumbnail => throw _privateConstructorUsedError; // 300×300
  @JsonKey(name: 'image_medium')
  String? get imageMedium => throw _privateConstructorUsedError; // 600×600
  @JsonKey(name: 'image_large')
  String? get imageLarge => throw _privateConstructorUsedError; // 1200×1200
  @JsonKey(name: 'image_hash')
  String? get imageHash => throw _privateConstructorUsedError; // Versioning
  @JsonKey(name: 'category_id')
  String? get categoryId => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;
  @JsonKey(name: 'track_inventory')
  bool get trackInventory => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  String? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this ProductResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProductResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductResponseCopyWith<ProductResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductResponseCopyWith<$Res> {
  factory $ProductResponseCopyWith(
          ProductResponse value, $Res Function(ProductResponse) then) =
      _$ProductResponseCopyWithImpl<$Res, ProductResponse>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'store_id') String storeId,
      String name,
      String? sku,
      String? barcode,
      double price,
      @JsonKey(name: 'cost_price') double? costPrice,
      @JsonKey(name: 'stock_qty') int stockQty,
      @JsonKey(name: 'min_qty') int minQty,
      String? unit,
      String? description,
      @Deprecated('Use imageThumbnail, imageMedium, or imageLarge')
      @JsonKey(name: 'image_url')
      String? imageUrl,
      @JsonKey(name: 'image_thumbnail') String? imageThumbnail,
      @JsonKey(name: 'image_medium') String? imageMedium,
      @JsonKey(name: 'image_large') String? imageLarge,
      @JsonKey(name: 'image_hash') String? imageHash,
      @JsonKey(name: 'category_id') String? categoryId,
      @JsonKey(name: 'is_active') bool isActive,
      @JsonKey(name: 'track_inventory') bool trackInventory,
      @JsonKey(name: 'created_at') String createdAt,
      @JsonKey(name: 'updated_at') String? updatedAt});
}

/// @nodoc
class _$ProductResponseCopyWithImpl<$Res, $Val extends ProductResponse>
    implements $ProductResponseCopyWith<$Res> {
  _$ProductResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? storeId = null,
    Object? name = null,
    Object? sku = freezed,
    Object? barcode = freezed,
    Object? price = null,
    Object? costPrice = freezed,
    Object? stockQty = null,
    Object? minQty = null,
    Object? unit = freezed,
    Object? description = freezed,
    Object? imageUrl = freezed,
    Object? imageThumbnail = freezed,
    Object? imageMedium = freezed,
    Object? imageLarge = freezed,
    Object? imageHash = freezed,
    Object? categoryId = freezed,
    Object? isActive = null,
    Object? trackInventory = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      storeId: null == storeId
          ? _value.storeId
          : storeId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      sku: freezed == sku
          ? _value.sku
          : sku // ignore: cast_nullable_to_non_nullable
              as String?,
      barcode: freezed == barcode
          ? _value.barcode
          : barcode // ignore: cast_nullable_to_non_nullable
              as String?,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      costPrice: freezed == costPrice
          ? _value.costPrice
          : costPrice // ignore: cast_nullable_to_non_nullable
              as double?,
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
      imageThumbnail: freezed == imageThumbnail
          ? _value.imageThumbnail
          : imageThumbnail // ignore: cast_nullable_to_non_nullable
              as String?,
      imageMedium: freezed == imageMedium
          ? _value.imageMedium
          : imageMedium // ignore: cast_nullable_to_non_nullable
              as String?,
      imageLarge: freezed == imageLarge
          ? _value.imageLarge
          : imageLarge // ignore: cast_nullable_to_non_nullable
              as String?,
      imageHash: freezed == imageHash
          ? _value.imageHash
          : imageHash // ignore: cast_nullable_to_non_nullable
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
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProductResponseImplCopyWith<$Res>
    implements $ProductResponseCopyWith<$Res> {
  factory _$$ProductResponseImplCopyWith(_$ProductResponseImpl value,
          $Res Function(_$ProductResponseImpl) then) =
      __$$ProductResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'store_id') String storeId,
      String name,
      String? sku,
      String? barcode,
      double price,
      @JsonKey(name: 'cost_price') double? costPrice,
      @JsonKey(name: 'stock_qty') int stockQty,
      @JsonKey(name: 'min_qty') int minQty,
      String? unit,
      String? description,
      @Deprecated('Use imageThumbnail, imageMedium, or imageLarge')
      @JsonKey(name: 'image_url')
      String? imageUrl,
      @JsonKey(name: 'image_thumbnail') String? imageThumbnail,
      @JsonKey(name: 'image_medium') String? imageMedium,
      @JsonKey(name: 'image_large') String? imageLarge,
      @JsonKey(name: 'image_hash') String? imageHash,
      @JsonKey(name: 'category_id') String? categoryId,
      @JsonKey(name: 'is_active') bool isActive,
      @JsonKey(name: 'track_inventory') bool trackInventory,
      @JsonKey(name: 'created_at') String createdAt,
      @JsonKey(name: 'updated_at') String? updatedAt});
}

/// @nodoc
class __$$ProductResponseImplCopyWithImpl<$Res>
    extends _$ProductResponseCopyWithImpl<$Res, _$ProductResponseImpl>
    implements _$$ProductResponseImplCopyWith<$Res> {
  __$$ProductResponseImplCopyWithImpl(
      _$ProductResponseImpl _value, $Res Function(_$ProductResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProductResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? storeId = null,
    Object? name = null,
    Object? sku = freezed,
    Object? barcode = freezed,
    Object? price = null,
    Object? costPrice = freezed,
    Object? stockQty = null,
    Object? minQty = null,
    Object? unit = freezed,
    Object? description = freezed,
    Object? imageUrl = freezed,
    Object? imageThumbnail = freezed,
    Object? imageMedium = freezed,
    Object? imageLarge = freezed,
    Object? imageHash = freezed,
    Object? categoryId = freezed,
    Object? isActive = null,
    Object? trackInventory = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$ProductResponseImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      storeId: null == storeId
          ? _value.storeId
          : storeId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      sku: freezed == sku
          ? _value.sku
          : sku // ignore: cast_nullable_to_non_nullable
              as String?,
      barcode: freezed == barcode
          ? _value.barcode
          : barcode // ignore: cast_nullable_to_non_nullable
              as String?,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      costPrice: freezed == costPrice
          ? _value.costPrice
          : costPrice // ignore: cast_nullable_to_non_nullable
              as double?,
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
      imageThumbnail: freezed == imageThumbnail
          ? _value.imageThumbnail
          : imageThumbnail // ignore: cast_nullable_to_non_nullable
              as String?,
      imageMedium: freezed == imageMedium
          ? _value.imageMedium
          : imageMedium // ignore: cast_nullable_to_non_nullable
              as String?,
      imageLarge: freezed == imageLarge
          ? _value.imageLarge
          : imageLarge // ignore: cast_nullable_to_non_nullable
              as String?,
      imageHash: freezed == imageHash
          ? _value.imageHash
          : imageHash // ignore: cast_nullable_to_non_nullable
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
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductResponseImpl extends _ProductResponse {
  const _$ProductResponseImpl(
      {required this.id,
      @JsonKey(name: 'store_id') required this.storeId,
      required this.name,
      this.sku,
      this.barcode,
      required this.price,
      @JsonKey(name: 'cost_price') this.costPrice,
      @JsonKey(name: 'stock_qty') required this.stockQty,
      @JsonKey(name: 'min_qty') this.minQty = 1,
      this.unit,
      this.description,
      @Deprecated('Use imageThumbnail, imageMedium, or imageLarge')
      @JsonKey(name: 'image_url')
      this.imageUrl,
      @JsonKey(name: 'image_thumbnail') this.imageThumbnail,
      @JsonKey(name: 'image_medium') this.imageMedium,
      @JsonKey(name: 'image_large') this.imageLarge,
      @JsonKey(name: 'image_hash') this.imageHash,
      @JsonKey(name: 'category_id') this.categoryId,
      @JsonKey(name: 'is_active') required this.isActive,
      @JsonKey(name: 'track_inventory') this.trackInventory = true,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt})
      : super._();

  factory _$ProductResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductResponseImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'store_id')
  final String storeId;
  @override
  final String name;
  @override
  final String? sku;
  @override
  final String? barcode;
  @override
  final double price;
  @override
  @JsonKey(name: 'cost_price')
  final double? costPrice;
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
  @Deprecated('Use imageThumbnail, imageMedium, or imageLarge')
  @JsonKey(name: 'image_url')
  final String? imageUrl;
// R2 Image Storage (Cloudflare CDN)
  @override
  @JsonKey(name: 'image_thumbnail')
  final String? imageThumbnail;
// 300×300
  @override
  @JsonKey(name: 'image_medium')
  final String? imageMedium;
// 600×600
  @override
  @JsonKey(name: 'image_large')
  final String? imageLarge;
// 1200×1200
  @override
  @JsonKey(name: 'image_hash')
  final String? imageHash;
// Versioning
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
  @JsonKey(name: 'created_at')
  final String createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  @override
  String toString() {
    return 'ProductResponse(id: $id, storeId: $storeId, name: $name, sku: $sku, barcode: $barcode, price: $price, costPrice: $costPrice, stockQty: $stockQty, minQty: $minQty, unit: $unit, description: $description, imageUrl: $imageUrl, imageThumbnail: $imageThumbnail, imageMedium: $imageMedium, imageLarge: $imageLarge, imageHash: $imageHash, categoryId: $categoryId, isActive: $isActive, trackInventory: $trackInventory, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductResponseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.storeId, storeId) || other.storeId == storeId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.sku, sku) || other.sku == sku) &&
            (identical(other.barcode, barcode) || other.barcode == barcode) &&
            (identical(other.price, price) || other.price == price) &&
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
            (identical(other.imageThumbnail, imageThumbnail) ||
                other.imageThumbnail == imageThumbnail) &&
            (identical(other.imageMedium, imageMedium) ||
                other.imageMedium == imageMedium) &&
            (identical(other.imageLarge, imageLarge) ||
                other.imageLarge == imageLarge) &&
            (identical(other.imageHash, imageHash) ||
                other.imageHash == imageHash) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.trackInventory, trackInventory) ||
                other.trackInventory == trackInventory) &&
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
        storeId,
        name,
        sku,
        barcode,
        price,
        costPrice,
        stockQty,
        minQty,
        unit,
        description,
        imageUrl,
        imageThumbnail,
        imageMedium,
        imageLarge,
        imageHash,
        categoryId,
        isActive,
        trackInventory,
        createdAt,
        updatedAt
      ]);

  /// Create a copy of ProductResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductResponseImplCopyWith<_$ProductResponseImpl> get copyWith =>
      __$$ProductResponseImplCopyWithImpl<_$ProductResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductResponseImplToJson(
      this,
    );
  }
}

abstract class _ProductResponse extends ProductResponse {
  const factory _ProductResponse(
          {required final String id,
          @JsonKey(name: 'store_id') required final String storeId,
          required final String name,
          final String? sku,
          final String? barcode,
          required final double price,
          @JsonKey(name: 'cost_price') final double? costPrice,
          @JsonKey(name: 'stock_qty') required final int stockQty,
          @JsonKey(name: 'min_qty') final int minQty,
          final String? unit,
          final String? description,
          @Deprecated('Use imageThumbnail, imageMedium, or imageLarge')
          @JsonKey(name: 'image_url')
          final String? imageUrl,
          @JsonKey(name: 'image_thumbnail') final String? imageThumbnail,
          @JsonKey(name: 'image_medium') final String? imageMedium,
          @JsonKey(name: 'image_large') final String? imageLarge,
          @JsonKey(name: 'image_hash') final String? imageHash,
          @JsonKey(name: 'category_id') final String? categoryId,
          @JsonKey(name: 'is_active') required final bool isActive,
          @JsonKey(name: 'track_inventory') final bool trackInventory,
          @JsonKey(name: 'created_at') required final String createdAt,
          @JsonKey(name: 'updated_at') final String? updatedAt}) =
      _$ProductResponseImpl;
  const _ProductResponse._() : super._();

  factory _ProductResponse.fromJson(Map<String, dynamic> json) =
      _$ProductResponseImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'store_id')
  String get storeId;
  @override
  String get name;
  @override
  String? get sku;
  @override
  String? get barcode;
  @override
  double get price;
  @override
  @JsonKey(name: 'cost_price')
  double? get costPrice;
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
  @Deprecated('Use imageThumbnail, imageMedium, or imageLarge')
  @JsonKey(name: 'image_url')
  String? get imageUrl; // R2 Image Storage (Cloudflare CDN)
  @override
  @JsonKey(name: 'image_thumbnail')
  String? get imageThumbnail; // 300×300
  @override
  @JsonKey(name: 'image_medium')
  String? get imageMedium; // 600×600
  @override
  @JsonKey(name: 'image_large')
  String? get imageLarge; // 1200×1200
  @override
  @JsonKey(name: 'image_hash')
  String? get imageHash; // Versioning
  @override
  @JsonKey(name: 'category_id')
  String? get categoryId;
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;
  @override
  @JsonKey(name: 'track_inventory')
  bool get trackInventory;
  @override
  @JsonKey(name: 'created_at')
  String get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  String? get updatedAt;

  /// Create a copy of ProductResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductResponseImplCopyWith<_$ProductResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
