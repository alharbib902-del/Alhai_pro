// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_product_params.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CreateProductParams _$CreateProductParamsFromJson(Map<String, dynamic> json) {
  return _CreateProductParams.fromJson(json);
}

/// @nodoc
mixin _$CreateProductParams {
  /// Product name
  String get name => throw _privateConstructorUsedError;

  /// Product price
  double get price => throw _privateConstructorUsedError;

  /// Store ID
  String get storeId => throw _privateConstructorUsedError;

  /// Product description (optional)
  String? get description => throw _privateConstructorUsedError;

  /// Product image URL (optional)
  String? get imageUrl => throw _privateConstructorUsedError;

  /// Product barcode (optional)
  String? get barcode => throw _privateConstructorUsedError;

  /// Category ID (optional)
  String? get categoryId => throw _privateConstructorUsedError;

  /// Whether product is available
  bool get available => throw _privateConstructorUsedError;

  /// Serializes this CreateProductParams to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateProductParams
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateProductParamsCopyWith<CreateProductParams> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateProductParamsCopyWith<$Res> {
  factory $CreateProductParamsCopyWith(
    CreateProductParams value,
    $Res Function(CreateProductParams) then,
  ) = _$CreateProductParamsCopyWithImpl<$Res, CreateProductParams>;
  @useResult
  $Res call({
    String name,
    double price,
    String storeId,
    String? description,
    String? imageUrl,
    String? barcode,
    String? categoryId,
    bool available,
  });
}

/// @nodoc
class _$CreateProductParamsCopyWithImpl<$Res, $Val extends CreateProductParams>
    implements $CreateProductParamsCopyWith<$Res> {
  _$CreateProductParamsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateProductParams
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? price = null,
    Object? storeId = null,
    Object? description = freezed,
    Object? imageUrl = freezed,
    Object? barcode = freezed,
    Object? categoryId = freezed,
    Object? available = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            price: null == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                      as double,
            storeId: null == storeId
                ? _value.storeId
                : storeId // ignore: cast_nullable_to_non_nullable
                      as String,
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
            categoryId: freezed == categoryId
                ? _value.categoryId
                : categoryId // ignore: cast_nullable_to_non_nullable
                      as String?,
            available: null == available
                ? _value.available
                : available // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CreateProductParamsImplCopyWith<$Res>
    implements $CreateProductParamsCopyWith<$Res> {
  factory _$$CreateProductParamsImplCopyWith(
    _$CreateProductParamsImpl value,
    $Res Function(_$CreateProductParamsImpl) then,
  ) = __$$CreateProductParamsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    double price,
    String storeId,
    String? description,
    String? imageUrl,
    String? barcode,
    String? categoryId,
    bool available,
  });
}

/// @nodoc
class __$$CreateProductParamsImplCopyWithImpl<$Res>
    extends _$CreateProductParamsCopyWithImpl<$Res, _$CreateProductParamsImpl>
    implements _$$CreateProductParamsImplCopyWith<$Res> {
  __$$CreateProductParamsImplCopyWithImpl(
    _$CreateProductParamsImpl _value,
    $Res Function(_$CreateProductParamsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreateProductParams
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? price = null,
    Object? storeId = null,
    Object? description = freezed,
    Object? imageUrl = freezed,
    Object? barcode = freezed,
    Object? categoryId = freezed,
    Object? available = null,
  }) {
    return _then(
      _$CreateProductParamsImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        price: null == price
            ? _value.price
            : price // ignore: cast_nullable_to_non_nullable
                  as double,
        storeId: null == storeId
            ? _value.storeId
            : storeId // ignore: cast_nullable_to_non_nullable
                  as String,
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
        categoryId: freezed == categoryId
            ? _value.categoryId
            : categoryId // ignore: cast_nullable_to_non_nullable
                  as String?,
        available: null == available
            ? _value.available
            : available // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateProductParamsImpl implements _CreateProductParams {
  const _$CreateProductParamsImpl({
    required this.name,
    required this.price,
    required this.storeId,
    this.description,
    this.imageUrl,
    this.barcode,
    this.categoryId,
    this.available = true,
  });

  factory _$CreateProductParamsImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateProductParamsImplFromJson(json);

  /// Product name
  @override
  final String name;

  /// Product price
  @override
  final double price;

  /// Store ID
  @override
  final String storeId;

  /// Product description (optional)
  @override
  final String? description;

  /// Product image URL (optional)
  @override
  final String? imageUrl;

  /// Product barcode (optional)
  @override
  final String? barcode;

  /// Category ID (optional)
  @override
  final String? categoryId;

  /// Whether product is available
  @override
  @JsonKey()
  final bool available;

  @override
  String toString() {
    return 'CreateProductParams(name: $name, price: $price, storeId: $storeId, description: $description, imageUrl: $imageUrl, barcode: $barcode, categoryId: $categoryId, available: $available)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateProductParamsImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.storeId, storeId) || other.storeId == storeId) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.barcode, barcode) || other.barcode == barcode) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.available, available) ||
                other.available == available));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    price,
    storeId,
    description,
    imageUrl,
    barcode,
    categoryId,
    available,
  );

  /// Create a copy of CreateProductParams
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateProductParamsImplCopyWith<_$CreateProductParamsImpl> get copyWith =>
      __$$CreateProductParamsImplCopyWithImpl<_$CreateProductParamsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateProductParamsImplToJson(this);
  }
}

abstract class _CreateProductParams implements CreateProductParams {
  const factory _CreateProductParams({
    required final String name,
    required final double price,
    required final String storeId,
    final String? description,
    final String? imageUrl,
    final String? barcode,
    final String? categoryId,
    final bool available,
  }) = _$CreateProductParamsImpl;

  factory _CreateProductParams.fromJson(Map<String, dynamic> json) =
      _$CreateProductParamsImpl.fromJson;

  /// Product name
  @override
  String get name;

  /// Product price
  @override
  double get price;

  /// Store ID
  @override
  String get storeId;

  /// Product description (optional)
  @override
  String? get description;

  /// Product image URL (optional)
  @override
  String? get imageUrl;

  /// Product barcode (optional)
  @override
  String? get barcode;

  /// Category ID (optional)
  @override
  String? get categoryId;

  /// Whether product is available
  @override
  bool get available;

  /// Create a copy of CreateProductParams
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateProductParamsImplCopyWith<_$CreateProductParamsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
