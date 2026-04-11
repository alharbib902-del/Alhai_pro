// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'address_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AddressResponse _$AddressResponseFromJson(Map<String, dynamic> json) {
  return _AddressResponse.fromJson(json);
}

/// @nodoc
mixin _$AddressResponse {
  String get id => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  @JsonKey(name: 'full_address')
  String get fullAddress => throw _privateConstructorUsedError;
  String get city => throw _privateConstructorUsedError;
  String? get district => throw _privateConstructorUsedError;
  String? get street => throw _privateConstructorUsedError;
  @JsonKey(name: 'building_number')
  String? get buildingNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'apartment_number')
  String? get apartmentNumber => throw _privateConstructorUsedError;
  String? get landmark => throw _privateConstructorUsedError;
  double get lat => throw _privateConstructorUsedError;
  double get lng => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_default')
  bool get isDefault => throw _privateConstructorUsedError;

  /// Serializes this AddressResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AddressResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AddressResponseCopyWith<AddressResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AddressResponseCopyWith<$Res> {
  factory $AddressResponseCopyWith(
    AddressResponse value,
    $Res Function(AddressResponse) then,
  ) = _$AddressResponseCopyWithImpl<$Res, AddressResponse>;
  @useResult
  $Res call({
    String id,
    String label,
    @JsonKey(name: 'full_address') String fullAddress,
    String city,
    String? district,
    String? street,
    @JsonKey(name: 'building_number') String? buildingNumber,
    @JsonKey(name: 'apartment_number') String? apartmentNumber,
    String? landmark,
    double lat,
    double lng,
    @JsonKey(name: 'is_default') bool isDefault,
  });
}

/// @nodoc
class _$AddressResponseCopyWithImpl<$Res, $Val extends AddressResponse>
    implements $AddressResponseCopyWith<$Res> {
  _$AddressResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AddressResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? label = null,
    Object? fullAddress = null,
    Object? city = null,
    Object? district = freezed,
    Object? street = freezed,
    Object? buildingNumber = freezed,
    Object? apartmentNumber = freezed,
    Object? landmark = freezed,
    Object? lat = null,
    Object? lng = null,
    Object? isDefault = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            label: null == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String,
            fullAddress: null == fullAddress
                ? _value.fullAddress
                : fullAddress // ignore: cast_nullable_to_non_nullable
                      as String,
            city: null == city
                ? _value.city
                : city // ignore: cast_nullable_to_non_nullable
                      as String,
            district: freezed == district
                ? _value.district
                : district // ignore: cast_nullable_to_non_nullable
                      as String?,
            street: freezed == street
                ? _value.street
                : street // ignore: cast_nullable_to_non_nullable
                      as String?,
            buildingNumber: freezed == buildingNumber
                ? _value.buildingNumber
                : buildingNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            apartmentNumber: freezed == apartmentNumber
                ? _value.apartmentNumber
                : apartmentNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            landmark: freezed == landmark
                ? _value.landmark
                : landmark // ignore: cast_nullable_to_non_nullable
                      as String?,
            lat: null == lat
                ? _value.lat
                : lat // ignore: cast_nullable_to_non_nullable
                      as double,
            lng: null == lng
                ? _value.lng
                : lng // ignore: cast_nullable_to_non_nullable
                      as double,
            isDefault: null == isDefault
                ? _value.isDefault
                : isDefault // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AddressResponseImplCopyWith<$Res>
    implements $AddressResponseCopyWith<$Res> {
  factory _$$AddressResponseImplCopyWith(
    _$AddressResponseImpl value,
    $Res Function(_$AddressResponseImpl) then,
  ) = __$$AddressResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String label,
    @JsonKey(name: 'full_address') String fullAddress,
    String city,
    String? district,
    String? street,
    @JsonKey(name: 'building_number') String? buildingNumber,
    @JsonKey(name: 'apartment_number') String? apartmentNumber,
    String? landmark,
    double lat,
    double lng,
    @JsonKey(name: 'is_default') bool isDefault,
  });
}

/// @nodoc
class __$$AddressResponseImplCopyWithImpl<$Res>
    extends _$AddressResponseCopyWithImpl<$Res, _$AddressResponseImpl>
    implements _$$AddressResponseImplCopyWith<$Res> {
  __$$AddressResponseImplCopyWithImpl(
    _$AddressResponseImpl _value,
    $Res Function(_$AddressResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AddressResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? label = null,
    Object? fullAddress = null,
    Object? city = null,
    Object? district = freezed,
    Object? street = freezed,
    Object? buildingNumber = freezed,
    Object? apartmentNumber = freezed,
    Object? landmark = freezed,
    Object? lat = null,
    Object? lng = null,
    Object? isDefault = null,
  }) {
    return _then(
      _$AddressResponseImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        label: null == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String,
        fullAddress: null == fullAddress
            ? _value.fullAddress
            : fullAddress // ignore: cast_nullable_to_non_nullable
                  as String,
        city: null == city
            ? _value.city
            : city // ignore: cast_nullable_to_non_nullable
                  as String,
        district: freezed == district
            ? _value.district
            : district // ignore: cast_nullable_to_non_nullable
                  as String?,
        street: freezed == street
            ? _value.street
            : street // ignore: cast_nullable_to_non_nullable
                  as String?,
        buildingNumber: freezed == buildingNumber
            ? _value.buildingNumber
            : buildingNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        apartmentNumber: freezed == apartmentNumber
            ? _value.apartmentNumber
            : apartmentNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        landmark: freezed == landmark
            ? _value.landmark
            : landmark // ignore: cast_nullable_to_non_nullable
                  as String?,
        lat: null == lat
            ? _value.lat
            : lat // ignore: cast_nullable_to_non_nullable
                  as double,
        lng: null == lng
            ? _value.lng
            : lng // ignore: cast_nullable_to_non_nullable
                  as double,
        isDefault: null == isDefault
            ? _value.isDefault
            : isDefault // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AddressResponseImpl extends _AddressResponse {
  const _$AddressResponseImpl({
    required this.id,
    required this.label,
    @JsonKey(name: 'full_address') required this.fullAddress,
    required this.city,
    this.district,
    this.street,
    @JsonKey(name: 'building_number') this.buildingNumber,
    @JsonKey(name: 'apartment_number') this.apartmentNumber,
    this.landmark,
    required this.lat,
    required this.lng,
    @JsonKey(name: 'is_default') this.isDefault = false,
  }) : super._();

  factory _$AddressResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$AddressResponseImplFromJson(json);

  @override
  final String id;
  @override
  final String label;
  @override
  @JsonKey(name: 'full_address')
  final String fullAddress;
  @override
  final String city;
  @override
  final String? district;
  @override
  final String? street;
  @override
  @JsonKey(name: 'building_number')
  final String? buildingNumber;
  @override
  @JsonKey(name: 'apartment_number')
  final String? apartmentNumber;
  @override
  final String? landmark;
  @override
  final double lat;
  @override
  final double lng;
  @override
  @JsonKey(name: 'is_default')
  final bool isDefault;

  @override
  String toString() {
    return 'AddressResponse(id: $id, label: $label, fullAddress: $fullAddress, city: $city, district: $district, street: $street, buildingNumber: $buildingNumber, apartmentNumber: $apartmentNumber, landmark: $landmark, lat: $lat, lng: $lng, isDefault: $isDefault)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AddressResponseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.fullAddress, fullAddress) ||
                other.fullAddress == fullAddress) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.district, district) ||
                other.district == district) &&
            (identical(other.street, street) || other.street == street) &&
            (identical(other.buildingNumber, buildingNumber) ||
                other.buildingNumber == buildingNumber) &&
            (identical(other.apartmentNumber, apartmentNumber) ||
                other.apartmentNumber == apartmentNumber) &&
            (identical(other.landmark, landmark) ||
                other.landmark == landmark) &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng) &&
            (identical(other.isDefault, isDefault) ||
                other.isDefault == isDefault));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    label,
    fullAddress,
    city,
    district,
    street,
    buildingNumber,
    apartmentNumber,
    landmark,
    lat,
    lng,
    isDefault,
  );

  /// Create a copy of AddressResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AddressResponseImplCopyWith<_$AddressResponseImpl> get copyWith =>
      __$$AddressResponseImplCopyWithImpl<_$AddressResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AddressResponseImplToJson(this);
  }
}

abstract class _AddressResponse extends AddressResponse {
  const factory _AddressResponse({
    required final String id,
    required final String label,
    @JsonKey(name: 'full_address') required final String fullAddress,
    required final String city,
    final String? district,
    final String? street,
    @JsonKey(name: 'building_number') final String? buildingNumber,
    @JsonKey(name: 'apartment_number') final String? apartmentNumber,
    final String? landmark,
    required final double lat,
    required final double lng,
    @JsonKey(name: 'is_default') final bool isDefault,
  }) = _$AddressResponseImpl;
  const _AddressResponse._() : super._();

  factory _AddressResponse.fromJson(Map<String, dynamic> json) =
      _$AddressResponseImpl.fromJson;

  @override
  String get id;
  @override
  String get label;
  @override
  @JsonKey(name: 'full_address')
  String get fullAddress;
  @override
  String get city;
  @override
  String? get district;
  @override
  String? get street;
  @override
  @JsonKey(name: 'building_number')
  String? get buildingNumber;
  @override
  @JsonKey(name: 'apartment_number')
  String? get apartmentNumber;
  @override
  String? get landmark;
  @override
  double get lat;
  @override
  double get lng;
  @override
  @JsonKey(name: 'is_default')
  bool get isDefault;

  /// Create a copy of AddressResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AddressResponseImplCopyWith<_$AddressResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
