// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Product _$ProductFromJson(Map<String, dynamic> json) {
  return _Product.fromJson(json);
}

/// @nodoc
mixin _$Product {
  String get id => throw _privateConstructorUsedError;
  String get storeId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get sku => throw _privateConstructorUsedError;
  String? get barcode => throw _privateConstructorUsedError;
  int get price => throw _privateConstructorUsedError;
  int? get costPrice => throw _privateConstructorUsedError;
  double get stockQty => throw _privateConstructorUsedError;
  double get minQty => throw _privateConstructorUsedError;
  String? get unit => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @Deprecated('Use imageThumbnail, imageMedium, or imageLarge')
  String? get imageUrl =>
      throw _privateConstructorUsedError; // R2 Image Storage (Cloudflare CDN)
  String? get imageThumbnail =>
      throw _privateConstructorUsedError; // 300×300 - for Grid/List
  String? get imageMedium =>
      throw _privateConstructorUsedError; // 600×600 - for Quick View
  String? get imageLarge =>
      throw _privateConstructorUsedError; // 1200×1200 - for Detail/Zoom
  String? get imageHash =>
      throw _privateConstructorUsedError; // For cache versioning
  String? get categoryId => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  bool get trackInventory => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Product to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductCopyWith<Product> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductCopyWith<$Res> {
  factory $ProductCopyWith(Product value, $Res Function(Product) then) =
      _$ProductCopyWithImpl<$Res, Product>;
  @useResult
  $Res call(
      {String id,
      String storeId,
      String name,
      String? sku,
      String? barcode,
      int price,
      int? costPrice,
      double stockQty,
      double minQty,
      String? unit,
      String? description,
      @Deprecated('Use imageThumbnail, imageMedium, or imageLarge')
      String? imageUrl,
      String? imageThumbnail,
      String? imageMedium,
      String? imageLarge,
      String? imageHash,
      String? categoryId,
      bool isActive,
      bool trackInventory,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$ProductCopyWithImpl<$Res, $Val extends Product>
    implements $ProductCopyWith<$Res> {
  _$ProductCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Product
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
              as int,
      costPrice: freezed == costPrice
          ? _value.costPrice
          : costPrice // ignore: cast_nullable_to_non_nullable
              as int?,
      stockQty: null == stockQty
          ? _value.stockQty
          : stockQty // ignore: cast_nullable_to_non_nullable
              as double,
      minQty: null == minQty
          ? _value.minQty
          : minQty // ignore: cast_nullable_to_non_nullable
              as double,
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
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProductImplCopyWith<$Res> implements $ProductCopyWith<$Res> {
  factory _$$ProductImplCopyWith(
          _$ProductImpl value, $Res Function(_$ProductImpl) then) =
      __$$ProductImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String storeId,
      String name,
      String? sku,
      String? barcode,
      int price,
      int? costPrice,
      double stockQty,
      double minQty,
      String? unit,
      String? description,
      @Deprecated('Use imageThumbnail, imageMedium, or imageLarge')
      String? imageUrl,
      String? imageThumbnail,
      String? imageMedium,
      String? imageLarge,
      String? imageHash,
      String? categoryId,
      bool isActive,
      bool trackInventory,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$ProductImplCopyWithImpl<$Res>
    extends _$ProductCopyWithImpl<$Res, _$ProductImpl>
    implements _$$ProductImplCopyWith<$Res> {
  __$$ProductImplCopyWithImpl(
      _$ProductImpl _value, $Res Function(_$ProductImpl) _then)
      : super(_value, _then);

  /// Create a copy of Product
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
    return _then(_$ProductImpl(
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
              as int,
      costPrice: freezed == costPrice
          ? _value.costPrice
          : costPrice // ignore: cast_nullable_to_non_nullable
              as int?,
      stockQty: null == stockQty
          ? _value.stockQty
          : stockQty // ignore: cast_nullable_to_non_nullable
              as double,
      minQty: null == minQty
          ? _value.minQty
          : minQty // ignore: cast_nullable_to_non_nullable
              as double,
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
class _$ProductImpl extends _Product {
  const _$ProductImpl(
      {required this.id,
      required this.storeId,
      required this.name,
      this.sku,
      this.barcode,
      required this.price,
      this.costPrice,
      required this.stockQty,
      this.minQty = 0,
      this.unit,
      this.description,
      @Deprecated('Use imageThumbnail, imageMedium, or imageLarge')
      this.imageUrl,
      this.imageThumbnail,
      this.imageMedium,
      this.imageLarge,
      this.imageHash,
      this.categoryId,
      required this.isActive,
      this.trackInventory = true,
      required this.createdAt,
      this.updatedAt})
      : super._();

  factory _$ProductImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductImplFromJson(json);

  @override
  final String id;
  @override
  final String storeId;
  @override
  final String name;
  @override
  final String? sku;
  @override
  final String? barcode;
  @override
  final int price;
  @override
  final int? costPrice;
  @override
  final double stockQty;
  @override
  @JsonKey()
  final double minQty;
  @override
  final String? unit;
  @override
  final String? description;
  @override
  @Deprecated('Use imageThumbnail, imageMedium, or imageLarge')
  final String? imageUrl;
// R2 Image Storage (Cloudflare CDN)
  @override
  final String? imageThumbnail;
// 300×300 - for Grid/List
  @override
  final String? imageMedium;
// 600×600 - for Quick View
  @override
  final String? imageLarge;
// 1200×1200 - for Detail/Zoom
  @override
  final String? imageHash;
// For cache versioning
  @override
  final String? categoryId;
  @override
  final bool isActive;
  @override
  @JsonKey()
  final bool trackInventory;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Product(id: $id, storeId: $storeId, name: $name, sku: $sku, barcode: $barcode, price: $price, costPrice: $costPrice, stockQty: $stockQty, minQty: $minQty, unit: $unit, description: $description, imageUrl: $imageUrl, imageThumbnail: $imageThumbnail, imageMedium: $imageMedium, imageLarge: $imageLarge, imageHash: $imageHash, categoryId: $categoryId, isActive: $isActive, trackInventory: $trackInventory, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductImpl &&
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

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductImplCopyWith<_$ProductImpl> get copyWith =>
      __$$ProductImplCopyWithImpl<_$ProductImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductImplToJson(
      this,
    );
  }
}

abstract class _Product extends Product {
  const factory _Product(
      {required final String id,
      required final String storeId,
      required final String name,
      final String? sku,
      final String? barcode,
      required final int price,
      final int? costPrice,
      required final double stockQty,
      final double minQty,
      final String? unit,
      final String? description,
      @Deprecated('Use imageThumbnail, imageMedium, or imageLarge')
      final String? imageUrl,
      final String? imageThumbnail,
      final String? imageMedium,
      final String? imageLarge,
      final String? imageHash,
      final String? categoryId,
      required final bool isActive,
      final bool trackInventory,
      required final DateTime createdAt,
      final DateTime? updatedAt}) = _$ProductImpl;
  const _Product._() : super._();

  factory _Product.fromJson(Map<String, dynamic> json) = _$ProductImpl.fromJson;

  @override
  String get id;
  @override
  String get storeId;
  @override
  String get name;
  @override
  String? get sku;
  @override
  String? get barcode;
  @override
  int get price;
  @override
  int? get costPrice;
  @override
  double get stockQty;
  @override
  double get minQty;
  @override
  String? get unit;
  @override
  String? get description;
  @override
  @Deprecated('Use imageThumbnail, imageMedium, or imageLarge')
  String? get imageUrl; // R2 Image Storage (Cloudflare CDN)
  @override
  String? get imageThumbnail; // 300×300 - for Grid/List
  @override
  String? get imageMedium; // 600×600 - for Quick View
  @override
  String? get imageLarge; // 1200×1200 - for Detail/Zoom
  @override
  String? get imageHash; // For cache versioning
  @override
  String? get categoryId;
  @override
  bool get isActive;
  @override
  bool get trackInventory;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductImplCopyWith<_$ProductImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
