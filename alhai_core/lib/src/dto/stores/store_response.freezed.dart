// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'store_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

StoreResponse _$StoreResponseFromJson(Map<String, dynamic> json) {
  return _StoreResponse.fromJson(json);
}

/// @nodoc
mixin _$StoreResponse {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  double get lat => throw _privateConstructorUsedError;
  double get lng => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_url')
  String? get imageUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'logo_url')
  String? get logoUrl => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;
  @JsonKey(name: 'owner_id')
  String get ownerId => throw _privateConstructorUsedError;
  @JsonKey(name: 'delivery_radius')
  double? get deliveryRadius => throw _privateConstructorUsedError;
  @JsonKey(name: 'min_order_amount')
  double? get minOrderAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'delivery_fee')
  double? get deliveryFee => throw _privateConstructorUsedError;
  @JsonKey(name: 'accepts_delivery')
  bool get acceptsDelivery => throw _privateConstructorUsedError;
  @JsonKey(name: 'accepts_pickup')
  bool get acceptsPickup => throw _privateConstructorUsedError;
  @JsonKey(name: 'working_hours')
  Map<String, dynamic>? get workingHoursJson =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  String? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this StoreResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StoreResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StoreResponseCopyWith<StoreResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StoreResponseCopyWith<$Res> {
  factory $StoreResponseCopyWith(
    StoreResponse value,
    $Res Function(StoreResponse) then,
  ) = _$StoreResponseCopyWithImpl<$Res, StoreResponse>;
  @useResult
  $Res call({
    String id,
    String name,
    String address,
    String? phone,
    String? email,
    double lat,
    double lng,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'logo_url') String? logoUrl,
    String? description,
    @JsonKey(name: 'is_active') bool isActive,
    @JsonKey(name: 'owner_id') String ownerId,
    @JsonKey(name: 'delivery_radius') double? deliveryRadius,
    @JsonKey(name: 'min_order_amount') double? minOrderAmount,
    @JsonKey(name: 'delivery_fee') double? deliveryFee,
    @JsonKey(name: 'accepts_delivery') bool acceptsDelivery,
    @JsonKey(name: 'accepts_pickup') bool acceptsPickup,
    @JsonKey(name: 'working_hours') Map<String, dynamic>? workingHoursJson,
    @JsonKey(name: 'created_at') String createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  });
}

/// @nodoc
class _$StoreResponseCopyWithImpl<$Res, $Val extends StoreResponse>
    implements $StoreResponseCopyWith<$Res> {
  _$StoreResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StoreResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? address = null,
    Object? phone = freezed,
    Object? email = freezed,
    Object? lat = null,
    Object? lng = null,
    Object? imageUrl = freezed,
    Object? logoUrl = freezed,
    Object? description = freezed,
    Object? isActive = null,
    Object? ownerId = null,
    Object? deliveryRadius = freezed,
    Object? minOrderAmount = freezed,
    Object? deliveryFee = freezed,
    Object? acceptsDelivery = null,
    Object? acceptsPickup = null,
    Object? workingHoursJson = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            address: null == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String,
            phone: freezed == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String?,
            email: freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String?,
            lat: null == lat
                ? _value.lat
                : lat // ignore: cast_nullable_to_non_nullable
                      as double,
            lng: null == lng
                ? _value.lng
                : lng // ignore: cast_nullable_to_non_nullable
                      as double,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            logoUrl: freezed == logoUrl
                ? _value.logoUrl
                : logoUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            ownerId: null == ownerId
                ? _value.ownerId
                : ownerId // ignore: cast_nullable_to_non_nullable
                      as String,
            deliveryRadius: freezed == deliveryRadius
                ? _value.deliveryRadius
                : deliveryRadius // ignore: cast_nullable_to_non_nullable
                      as double?,
            minOrderAmount: freezed == minOrderAmount
                ? _value.minOrderAmount
                : minOrderAmount // ignore: cast_nullable_to_non_nullable
                      as double?,
            deliveryFee: freezed == deliveryFee
                ? _value.deliveryFee
                : deliveryFee // ignore: cast_nullable_to_non_nullable
                      as double?,
            acceptsDelivery: null == acceptsDelivery
                ? _value.acceptsDelivery
                : acceptsDelivery // ignore: cast_nullable_to_non_nullable
                      as bool,
            acceptsPickup: null == acceptsPickup
                ? _value.acceptsPickup
                : acceptsPickup // ignore: cast_nullable_to_non_nullable
                      as bool,
            workingHoursJson: freezed == workingHoursJson
                ? _value.workingHoursJson
                : workingHoursJson // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
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
abstract class _$$StoreResponseImplCopyWith<$Res>
    implements $StoreResponseCopyWith<$Res> {
  factory _$$StoreResponseImplCopyWith(
    _$StoreResponseImpl value,
    $Res Function(_$StoreResponseImpl) then,
  ) = __$$StoreResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String address,
    String? phone,
    String? email,
    double lat,
    double lng,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'logo_url') String? logoUrl,
    String? description,
    @JsonKey(name: 'is_active') bool isActive,
    @JsonKey(name: 'owner_id') String ownerId,
    @JsonKey(name: 'delivery_radius') double? deliveryRadius,
    @JsonKey(name: 'min_order_amount') double? minOrderAmount,
    @JsonKey(name: 'delivery_fee') double? deliveryFee,
    @JsonKey(name: 'accepts_delivery') bool acceptsDelivery,
    @JsonKey(name: 'accepts_pickup') bool acceptsPickup,
    @JsonKey(name: 'working_hours') Map<String, dynamic>? workingHoursJson,
    @JsonKey(name: 'created_at') String createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  });
}

/// @nodoc
class __$$StoreResponseImplCopyWithImpl<$Res>
    extends _$StoreResponseCopyWithImpl<$Res, _$StoreResponseImpl>
    implements _$$StoreResponseImplCopyWith<$Res> {
  __$$StoreResponseImplCopyWithImpl(
    _$StoreResponseImpl _value,
    $Res Function(_$StoreResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StoreResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? address = null,
    Object? phone = freezed,
    Object? email = freezed,
    Object? lat = null,
    Object? lng = null,
    Object? imageUrl = freezed,
    Object? logoUrl = freezed,
    Object? description = freezed,
    Object? isActive = null,
    Object? ownerId = null,
    Object? deliveryRadius = freezed,
    Object? minOrderAmount = freezed,
    Object? deliveryFee = freezed,
    Object? acceptsDelivery = null,
    Object? acceptsPickup = null,
    Object? workingHoursJson = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$StoreResponseImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        address: null == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String,
        phone: freezed == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String?,
        email: freezed == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String?,
        lat: null == lat
            ? _value.lat
            : lat // ignore: cast_nullable_to_non_nullable
                  as double,
        lng: null == lng
            ? _value.lng
            : lng // ignore: cast_nullable_to_non_nullable
                  as double,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        logoUrl: freezed == logoUrl
            ? _value.logoUrl
            : logoUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        ownerId: null == ownerId
            ? _value.ownerId
            : ownerId // ignore: cast_nullable_to_non_nullable
                  as String,
        deliveryRadius: freezed == deliveryRadius
            ? _value.deliveryRadius
            : deliveryRadius // ignore: cast_nullable_to_non_nullable
                  as double?,
        minOrderAmount: freezed == minOrderAmount
            ? _value.minOrderAmount
            : minOrderAmount // ignore: cast_nullable_to_non_nullable
                  as double?,
        deliveryFee: freezed == deliveryFee
            ? _value.deliveryFee
            : deliveryFee // ignore: cast_nullable_to_non_nullable
                  as double?,
        acceptsDelivery: null == acceptsDelivery
            ? _value.acceptsDelivery
            : acceptsDelivery // ignore: cast_nullable_to_non_nullable
                  as bool,
        acceptsPickup: null == acceptsPickup
            ? _value.acceptsPickup
            : acceptsPickup // ignore: cast_nullable_to_non_nullable
                  as bool,
        workingHoursJson: freezed == workingHoursJson
            ? _value._workingHoursJson
            : workingHoursJson // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
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
class _$StoreResponseImpl extends _StoreResponse {
  const _$StoreResponseImpl({
    required this.id,
    required this.name,
    required this.address,
    this.phone,
    this.email,
    required this.lat,
    required this.lng,
    @JsonKey(name: 'image_url') this.imageUrl,
    @JsonKey(name: 'logo_url') this.logoUrl,
    this.description,
    @JsonKey(name: 'is_active') required this.isActive,
    @JsonKey(name: 'owner_id') required this.ownerId,
    @JsonKey(name: 'delivery_radius') this.deliveryRadius,
    @JsonKey(name: 'min_order_amount') this.minOrderAmount,
    @JsonKey(name: 'delivery_fee') this.deliveryFee,
    @JsonKey(name: 'accepts_delivery') this.acceptsDelivery = true,
    @JsonKey(name: 'accepts_pickup') this.acceptsPickup = true,
    @JsonKey(name: 'working_hours')
    final Map<String, dynamic>? workingHoursJson,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'updated_at') this.updatedAt,
  }) : _workingHoursJson = workingHoursJson,
       super._();

  factory _$StoreResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$StoreResponseImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String address;
  @override
  final String? phone;
  @override
  final String? email;
  @override
  final double lat;
  @override
  final double lng;
  @override
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @override
  @JsonKey(name: 'logo_url')
  final String? logoUrl;
  @override
  final String? description;
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;
  @override
  @JsonKey(name: 'owner_id')
  final String ownerId;
  @override
  @JsonKey(name: 'delivery_radius')
  final double? deliveryRadius;
  @override
  @JsonKey(name: 'min_order_amount')
  final double? minOrderAmount;
  @override
  @JsonKey(name: 'delivery_fee')
  final double? deliveryFee;
  @override
  @JsonKey(name: 'accepts_delivery')
  final bool acceptsDelivery;
  @override
  @JsonKey(name: 'accepts_pickup')
  final bool acceptsPickup;
  final Map<String, dynamic>? _workingHoursJson;
  @override
  @JsonKey(name: 'working_hours')
  Map<String, dynamic>? get workingHoursJson {
    final value = _workingHoursJson;
    if (value == null) return null;
    if (_workingHoursJson is EqualUnmodifiableMapView) return _workingHoursJson;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey(name: 'created_at')
  final String createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  @override
  String toString() {
    return 'StoreResponse(id: $id, name: $name, address: $address, phone: $phone, email: $email, lat: $lat, lng: $lng, imageUrl: $imageUrl, logoUrl: $logoUrl, description: $description, isActive: $isActive, ownerId: $ownerId, deliveryRadius: $deliveryRadius, minOrderAmount: $minOrderAmount, deliveryFee: $deliveryFee, acceptsDelivery: $acceptsDelivery, acceptsPickup: $acceptsPickup, workingHoursJson: $workingHoursJson, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StoreResponseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.ownerId, ownerId) || other.ownerId == ownerId) &&
            (identical(other.deliveryRadius, deliveryRadius) ||
                other.deliveryRadius == deliveryRadius) &&
            (identical(other.minOrderAmount, minOrderAmount) ||
                other.minOrderAmount == minOrderAmount) &&
            (identical(other.deliveryFee, deliveryFee) ||
                other.deliveryFee == deliveryFee) &&
            (identical(other.acceptsDelivery, acceptsDelivery) ||
                other.acceptsDelivery == acceptsDelivery) &&
            (identical(other.acceptsPickup, acceptsPickup) ||
                other.acceptsPickup == acceptsPickup) &&
            const DeepCollectionEquality().equals(
              other._workingHoursJson,
              _workingHoursJson,
            ) &&
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
    name,
    address,
    phone,
    email,
    lat,
    lng,
    imageUrl,
    logoUrl,
    description,
    isActive,
    ownerId,
    deliveryRadius,
    minOrderAmount,
    deliveryFee,
    acceptsDelivery,
    acceptsPickup,
    const DeepCollectionEquality().hash(_workingHoursJson),
    createdAt,
    updatedAt,
  ]);

  /// Create a copy of StoreResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StoreResponseImplCopyWith<_$StoreResponseImpl> get copyWith =>
      __$$StoreResponseImplCopyWithImpl<_$StoreResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StoreResponseImplToJson(this);
  }
}

abstract class _StoreResponse extends StoreResponse {
  const factory _StoreResponse({
    required final String id,
    required final String name,
    required final String address,
    final String? phone,
    final String? email,
    required final double lat,
    required final double lng,
    @JsonKey(name: 'image_url') final String? imageUrl,
    @JsonKey(name: 'logo_url') final String? logoUrl,
    final String? description,
    @JsonKey(name: 'is_active') required final bool isActive,
    @JsonKey(name: 'owner_id') required final String ownerId,
    @JsonKey(name: 'delivery_radius') final double? deliveryRadius,
    @JsonKey(name: 'min_order_amount') final double? minOrderAmount,
    @JsonKey(name: 'delivery_fee') final double? deliveryFee,
    @JsonKey(name: 'accepts_delivery') final bool acceptsDelivery,
    @JsonKey(name: 'accepts_pickup') final bool acceptsPickup,
    @JsonKey(name: 'working_hours')
    final Map<String, dynamic>? workingHoursJson,
    @JsonKey(name: 'created_at') required final String createdAt,
    @JsonKey(name: 'updated_at') final String? updatedAt,
  }) = _$StoreResponseImpl;
  const _StoreResponse._() : super._();

  factory _StoreResponse.fromJson(Map<String, dynamic> json) =
      _$StoreResponseImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get address;
  @override
  String? get phone;
  @override
  String? get email;
  @override
  double get lat;
  @override
  double get lng;
  @override
  @JsonKey(name: 'image_url')
  String? get imageUrl;
  @override
  @JsonKey(name: 'logo_url')
  String? get logoUrl;
  @override
  String? get description;
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;
  @override
  @JsonKey(name: 'owner_id')
  String get ownerId;
  @override
  @JsonKey(name: 'delivery_radius')
  double? get deliveryRadius;
  @override
  @JsonKey(name: 'min_order_amount')
  double? get minOrderAmount;
  @override
  @JsonKey(name: 'delivery_fee')
  double? get deliveryFee;
  @override
  @JsonKey(name: 'accepts_delivery')
  bool get acceptsDelivery;
  @override
  @JsonKey(name: 'accepts_pickup')
  bool get acceptsPickup;
  @override
  @JsonKey(name: 'working_hours')
  Map<String, dynamic>? get workingHoursJson;
  @override
  @JsonKey(name: 'created_at')
  String get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  String? get updatedAt;

  /// Create a copy of StoreResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StoreResponseImplCopyWith<_$StoreResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
