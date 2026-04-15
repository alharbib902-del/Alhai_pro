// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'store.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Store _$StoreFromJson(Map<String, dynamic> json) {
  return _Store.fromJson(json);
}

/// @nodoc
mixin _$Store {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  double get lat => throw _privateConstructorUsedError;
  double get lng => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get logoUrl => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  String get ownerId => throw _privateConstructorUsedError;
  double? get deliveryRadius => throw _privateConstructorUsedError;
  double? get minOrderAmount => throw _privateConstructorUsedError;
  double? get deliveryFee => throw _privateConstructorUsedError;
  bool get acceptsDelivery => throw _privateConstructorUsedError;
  bool get acceptsPickup => throw _privateConstructorUsedError;
  WorkingHours? get workingHours => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Store to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Store
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StoreCopyWith<Store> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StoreCopyWith<$Res> {
  factory $StoreCopyWith(Store value, $Res Function(Store) then) =
      _$StoreCopyWithImpl<$Res, Store>;
  @useResult
  $Res call(
      {String id,
      String name,
      String address,
      String? phone,
      String? email,
      double lat,
      double lng,
      String? imageUrl,
      String? logoUrl,
      String? description,
      bool isActive,
      String ownerId,
      double? deliveryRadius,
      double? minOrderAmount,
      double? deliveryFee,
      bool acceptsDelivery,
      bool acceptsPickup,
      WorkingHours? workingHours,
      DateTime createdAt,
      DateTime? updatedAt});

  $WorkingHoursCopyWith<$Res>? get workingHours;
}

/// @nodoc
class _$StoreCopyWithImpl<$Res, $Val extends Store>
    implements $StoreCopyWith<$Res> {
  _$StoreCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Store
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
    Object? workingHours = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
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
      workingHours: freezed == workingHours
          ? _value.workingHours
          : workingHours // ignore: cast_nullable_to_non_nullable
              as WorkingHours?,
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

  /// Create a copy of Store
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WorkingHoursCopyWith<$Res>? get workingHours {
    if (_value.workingHours == null) {
      return null;
    }

    return $WorkingHoursCopyWith<$Res>(_value.workingHours!, (value) {
      return _then(_value.copyWith(workingHours: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$StoreImplCopyWith<$Res> implements $StoreCopyWith<$Res> {
  factory _$$StoreImplCopyWith(
          _$StoreImpl value, $Res Function(_$StoreImpl) then) =
      __$$StoreImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String address,
      String? phone,
      String? email,
      double lat,
      double lng,
      String? imageUrl,
      String? logoUrl,
      String? description,
      bool isActive,
      String ownerId,
      double? deliveryRadius,
      double? minOrderAmount,
      double? deliveryFee,
      bool acceptsDelivery,
      bool acceptsPickup,
      WorkingHours? workingHours,
      DateTime createdAt,
      DateTime? updatedAt});

  @override
  $WorkingHoursCopyWith<$Res>? get workingHours;
}

/// @nodoc
class __$$StoreImplCopyWithImpl<$Res>
    extends _$StoreCopyWithImpl<$Res, _$StoreImpl>
    implements _$$StoreImplCopyWith<$Res> {
  __$$StoreImplCopyWithImpl(
      _$StoreImpl _value, $Res Function(_$StoreImpl) _then)
      : super(_value, _then);

  /// Create a copy of Store
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
    Object? workingHours = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$StoreImpl(
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
      workingHours: freezed == workingHours
          ? _value.workingHours
          : workingHours // ignore: cast_nullable_to_non_nullable
              as WorkingHours?,
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
class _$StoreImpl extends _Store {
  const _$StoreImpl(
      {required this.id,
      required this.name,
      required this.address,
      this.phone,
      this.email,
      required this.lat,
      required this.lng,
      this.imageUrl,
      this.logoUrl,
      this.description,
      required this.isActive,
      required this.ownerId,
      this.deliveryRadius,
      this.minOrderAmount,
      this.deliveryFee,
      this.acceptsDelivery = true,
      this.acceptsPickup = true,
      this.workingHours,
      required this.createdAt,
      this.updatedAt})
      : super._();

  factory _$StoreImpl.fromJson(Map<String, dynamic> json) =>
      _$$StoreImplFromJson(json);

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
  final String? imageUrl;
  @override
  final String? logoUrl;
  @override
  final String? description;
  @override
  final bool isActive;
  @override
  final String ownerId;
  @override
  final double? deliveryRadius;
  @override
  final double? minOrderAmount;
  @override
  final double? deliveryFee;
  @override
  @JsonKey()
  final bool acceptsDelivery;
  @override
  @JsonKey()
  final bool acceptsPickup;
  @override
  final WorkingHours? workingHours;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Store(id: $id, name: $name, address: $address, phone: $phone, email: $email, lat: $lat, lng: $lng, imageUrl: $imageUrl, logoUrl: $logoUrl, description: $description, isActive: $isActive, ownerId: $ownerId, deliveryRadius: $deliveryRadius, minOrderAmount: $minOrderAmount, deliveryFee: $deliveryFee, acceptsDelivery: $acceptsDelivery, acceptsPickup: $acceptsPickup, workingHours: $workingHours, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StoreImpl &&
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
            (identical(other.workingHours, workingHours) ||
                other.workingHours == workingHours) &&
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
        workingHours,
        createdAt,
        updatedAt
      ]);

  /// Create a copy of Store
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StoreImplCopyWith<_$StoreImpl> get copyWith =>
      __$$StoreImplCopyWithImpl<_$StoreImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StoreImplToJson(
      this,
    );
  }
}

abstract class _Store extends Store {
  const factory _Store(
      {required final String id,
      required final String name,
      required final String address,
      final String? phone,
      final String? email,
      required final double lat,
      required final double lng,
      final String? imageUrl,
      final String? logoUrl,
      final String? description,
      required final bool isActive,
      required final String ownerId,
      final double? deliveryRadius,
      final double? minOrderAmount,
      final double? deliveryFee,
      final bool acceptsDelivery,
      final bool acceptsPickup,
      final WorkingHours? workingHours,
      required final DateTime createdAt,
      final DateTime? updatedAt}) = _$StoreImpl;
  const _Store._() : super._();

  factory _Store.fromJson(Map<String, dynamic> json) = _$StoreImpl.fromJson;

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
  String? get imageUrl;
  @override
  String? get logoUrl;
  @override
  String? get description;
  @override
  bool get isActive;
  @override
  String get ownerId;
  @override
  double? get deliveryRadius;
  @override
  double? get minOrderAmount;
  @override
  double? get deliveryFee;
  @override
  bool get acceptsDelivery;
  @override
  bool get acceptsPickup;
  @override
  WorkingHours? get workingHours;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of Store
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StoreImplCopyWith<_$StoreImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WorkingHours _$WorkingHoursFromJson(Map<String, dynamic> json) {
  return _WorkingHours.fromJson(json);
}

/// @nodoc
mixin _$WorkingHours {
  DayHours? get monday => throw _privateConstructorUsedError;
  DayHours? get tuesday => throw _privateConstructorUsedError;
  DayHours? get wednesday => throw _privateConstructorUsedError;
  DayHours? get thursday => throw _privateConstructorUsedError;
  DayHours? get friday => throw _privateConstructorUsedError;
  DayHours? get saturday => throw _privateConstructorUsedError;
  DayHours? get sunday => throw _privateConstructorUsedError;

  /// Serializes this WorkingHours to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WorkingHours
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorkingHoursCopyWith<WorkingHours> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkingHoursCopyWith<$Res> {
  factory $WorkingHoursCopyWith(
          WorkingHours value, $Res Function(WorkingHours) then) =
      _$WorkingHoursCopyWithImpl<$Res, WorkingHours>;
  @useResult
  $Res call(
      {DayHours? monday,
      DayHours? tuesday,
      DayHours? wednesday,
      DayHours? thursday,
      DayHours? friday,
      DayHours? saturday,
      DayHours? sunday});

  $DayHoursCopyWith<$Res>? get monday;
  $DayHoursCopyWith<$Res>? get tuesday;
  $DayHoursCopyWith<$Res>? get wednesday;
  $DayHoursCopyWith<$Res>? get thursday;
  $DayHoursCopyWith<$Res>? get friday;
  $DayHoursCopyWith<$Res>? get saturday;
  $DayHoursCopyWith<$Res>? get sunday;
}

/// @nodoc
class _$WorkingHoursCopyWithImpl<$Res, $Val extends WorkingHours>
    implements $WorkingHoursCopyWith<$Res> {
  _$WorkingHoursCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WorkingHours
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? monday = freezed,
    Object? tuesday = freezed,
    Object? wednesday = freezed,
    Object? thursday = freezed,
    Object? friday = freezed,
    Object? saturday = freezed,
    Object? sunday = freezed,
  }) {
    return _then(_value.copyWith(
      monday: freezed == monday
          ? _value.monday
          : monday // ignore: cast_nullable_to_non_nullable
              as DayHours?,
      tuesday: freezed == tuesday
          ? _value.tuesday
          : tuesday // ignore: cast_nullable_to_non_nullable
              as DayHours?,
      wednesday: freezed == wednesday
          ? _value.wednesday
          : wednesday // ignore: cast_nullable_to_non_nullable
              as DayHours?,
      thursday: freezed == thursday
          ? _value.thursday
          : thursday // ignore: cast_nullable_to_non_nullable
              as DayHours?,
      friday: freezed == friday
          ? _value.friday
          : friday // ignore: cast_nullable_to_non_nullable
              as DayHours?,
      saturday: freezed == saturday
          ? _value.saturday
          : saturday // ignore: cast_nullable_to_non_nullable
              as DayHours?,
      sunday: freezed == sunday
          ? _value.sunday
          : sunday // ignore: cast_nullable_to_non_nullable
              as DayHours?,
    ) as $Val);
  }

  /// Create a copy of WorkingHours
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DayHoursCopyWith<$Res>? get monday {
    if (_value.monday == null) {
      return null;
    }

    return $DayHoursCopyWith<$Res>(_value.monday!, (value) {
      return _then(_value.copyWith(monday: value) as $Val);
    });
  }

  /// Create a copy of WorkingHours
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DayHoursCopyWith<$Res>? get tuesday {
    if (_value.tuesday == null) {
      return null;
    }

    return $DayHoursCopyWith<$Res>(_value.tuesday!, (value) {
      return _then(_value.copyWith(tuesday: value) as $Val);
    });
  }

  /// Create a copy of WorkingHours
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DayHoursCopyWith<$Res>? get wednesday {
    if (_value.wednesday == null) {
      return null;
    }

    return $DayHoursCopyWith<$Res>(_value.wednesday!, (value) {
      return _then(_value.copyWith(wednesday: value) as $Val);
    });
  }

  /// Create a copy of WorkingHours
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DayHoursCopyWith<$Res>? get thursday {
    if (_value.thursday == null) {
      return null;
    }

    return $DayHoursCopyWith<$Res>(_value.thursday!, (value) {
      return _then(_value.copyWith(thursday: value) as $Val);
    });
  }

  /// Create a copy of WorkingHours
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DayHoursCopyWith<$Res>? get friday {
    if (_value.friday == null) {
      return null;
    }

    return $DayHoursCopyWith<$Res>(_value.friday!, (value) {
      return _then(_value.copyWith(friday: value) as $Val);
    });
  }

  /// Create a copy of WorkingHours
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DayHoursCopyWith<$Res>? get saturday {
    if (_value.saturday == null) {
      return null;
    }

    return $DayHoursCopyWith<$Res>(_value.saturday!, (value) {
      return _then(_value.copyWith(saturday: value) as $Val);
    });
  }

  /// Create a copy of WorkingHours
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DayHoursCopyWith<$Res>? get sunday {
    if (_value.sunday == null) {
      return null;
    }

    return $DayHoursCopyWith<$Res>(_value.sunday!, (value) {
      return _then(_value.copyWith(sunday: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$WorkingHoursImplCopyWith<$Res>
    implements $WorkingHoursCopyWith<$Res> {
  factory _$$WorkingHoursImplCopyWith(
          _$WorkingHoursImpl value, $Res Function(_$WorkingHoursImpl) then) =
      __$$WorkingHoursImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DayHours? monday,
      DayHours? tuesday,
      DayHours? wednesday,
      DayHours? thursday,
      DayHours? friday,
      DayHours? saturday,
      DayHours? sunday});

  @override
  $DayHoursCopyWith<$Res>? get monday;
  @override
  $DayHoursCopyWith<$Res>? get tuesday;
  @override
  $DayHoursCopyWith<$Res>? get wednesday;
  @override
  $DayHoursCopyWith<$Res>? get thursday;
  @override
  $DayHoursCopyWith<$Res>? get friday;
  @override
  $DayHoursCopyWith<$Res>? get saturday;
  @override
  $DayHoursCopyWith<$Res>? get sunday;
}

/// @nodoc
class __$$WorkingHoursImplCopyWithImpl<$Res>
    extends _$WorkingHoursCopyWithImpl<$Res, _$WorkingHoursImpl>
    implements _$$WorkingHoursImplCopyWith<$Res> {
  __$$WorkingHoursImplCopyWithImpl(
      _$WorkingHoursImpl _value, $Res Function(_$WorkingHoursImpl) _then)
      : super(_value, _then);

  /// Create a copy of WorkingHours
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? monday = freezed,
    Object? tuesday = freezed,
    Object? wednesday = freezed,
    Object? thursday = freezed,
    Object? friday = freezed,
    Object? saturday = freezed,
    Object? sunday = freezed,
  }) {
    return _then(_$WorkingHoursImpl(
      monday: freezed == monday
          ? _value.monday
          : monday // ignore: cast_nullable_to_non_nullable
              as DayHours?,
      tuesday: freezed == tuesday
          ? _value.tuesday
          : tuesday // ignore: cast_nullable_to_non_nullable
              as DayHours?,
      wednesday: freezed == wednesday
          ? _value.wednesday
          : wednesday // ignore: cast_nullable_to_non_nullable
              as DayHours?,
      thursday: freezed == thursday
          ? _value.thursday
          : thursday // ignore: cast_nullable_to_non_nullable
              as DayHours?,
      friday: freezed == friday
          ? _value.friday
          : friday // ignore: cast_nullable_to_non_nullable
              as DayHours?,
      saturday: freezed == saturday
          ? _value.saturday
          : saturday // ignore: cast_nullable_to_non_nullable
              as DayHours?,
      sunday: freezed == sunday
          ? _value.sunday
          : sunday // ignore: cast_nullable_to_non_nullable
              as DayHours?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkingHoursImpl implements _WorkingHours {
  const _$WorkingHoursImpl(
      {this.monday,
      this.tuesday,
      this.wednesday,
      this.thursday,
      this.friday,
      this.saturday,
      this.sunday});

  factory _$WorkingHoursImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkingHoursImplFromJson(json);

  @override
  final DayHours? monday;
  @override
  final DayHours? tuesday;
  @override
  final DayHours? wednesday;
  @override
  final DayHours? thursday;
  @override
  final DayHours? friday;
  @override
  final DayHours? saturday;
  @override
  final DayHours? sunday;

  @override
  String toString() {
    return 'WorkingHours(monday: $monday, tuesday: $tuesday, wednesday: $wednesday, thursday: $thursday, friday: $friday, saturday: $saturday, sunday: $sunday)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkingHoursImpl &&
            (identical(other.monday, monday) || other.monday == monday) &&
            (identical(other.tuesday, tuesday) || other.tuesday == tuesday) &&
            (identical(other.wednesday, wednesday) ||
                other.wednesday == wednesday) &&
            (identical(other.thursday, thursday) ||
                other.thursday == thursday) &&
            (identical(other.friday, friday) || other.friday == friday) &&
            (identical(other.saturday, saturday) ||
                other.saturday == saturday) &&
            (identical(other.sunday, sunday) || other.sunday == sunday));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, monday, tuesday, wednesday,
      thursday, friday, saturday, sunday);

  /// Create a copy of WorkingHours
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkingHoursImplCopyWith<_$WorkingHoursImpl> get copyWith =>
      __$$WorkingHoursImplCopyWithImpl<_$WorkingHoursImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkingHoursImplToJson(
      this,
    );
  }
}

abstract class _WorkingHours implements WorkingHours {
  const factory _WorkingHours(
      {final DayHours? monday,
      final DayHours? tuesday,
      final DayHours? wednesday,
      final DayHours? thursday,
      final DayHours? friday,
      final DayHours? saturday,
      final DayHours? sunday}) = _$WorkingHoursImpl;

  factory _WorkingHours.fromJson(Map<String, dynamic> json) =
      _$WorkingHoursImpl.fromJson;

  @override
  DayHours? get monday;
  @override
  DayHours? get tuesday;
  @override
  DayHours? get wednesday;
  @override
  DayHours? get thursday;
  @override
  DayHours? get friday;
  @override
  DayHours? get saturday;
  @override
  DayHours? get sunday;

  /// Create a copy of WorkingHours
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkingHoursImplCopyWith<_$WorkingHoursImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DayHours _$DayHoursFromJson(Map<String, dynamic> json) {
  return _DayHours.fromJson(json);
}

/// @nodoc
mixin _$DayHours {
  String get open => throw _privateConstructorUsedError;
  String get close => throw _privateConstructorUsedError;
  bool get isClosed => throw _privateConstructorUsedError;

  /// Serializes this DayHours to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DayHours
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DayHoursCopyWith<DayHours> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DayHoursCopyWith<$Res> {
  factory $DayHoursCopyWith(DayHours value, $Res Function(DayHours) then) =
      _$DayHoursCopyWithImpl<$Res, DayHours>;
  @useResult
  $Res call({String open, String close, bool isClosed});
}

/// @nodoc
class _$DayHoursCopyWithImpl<$Res, $Val extends DayHours>
    implements $DayHoursCopyWith<$Res> {
  _$DayHoursCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DayHours
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? open = null,
    Object? close = null,
    Object? isClosed = null,
  }) {
    return _then(_value.copyWith(
      open: null == open
          ? _value.open
          : open // ignore: cast_nullable_to_non_nullable
              as String,
      close: null == close
          ? _value.close
          : close // ignore: cast_nullable_to_non_nullable
              as String,
      isClosed: null == isClosed
          ? _value.isClosed
          : isClosed // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DayHoursImplCopyWith<$Res>
    implements $DayHoursCopyWith<$Res> {
  factory _$$DayHoursImplCopyWith(
          _$DayHoursImpl value, $Res Function(_$DayHoursImpl) then) =
      __$$DayHoursImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String open, String close, bool isClosed});
}

/// @nodoc
class __$$DayHoursImplCopyWithImpl<$Res>
    extends _$DayHoursCopyWithImpl<$Res, _$DayHoursImpl>
    implements _$$DayHoursImplCopyWith<$Res> {
  __$$DayHoursImplCopyWithImpl(
      _$DayHoursImpl _value, $Res Function(_$DayHoursImpl) _then)
      : super(_value, _then);

  /// Create a copy of DayHours
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? open = null,
    Object? close = null,
    Object? isClosed = null,
  }) {
    return _then(_$DayHoursImpl(
      open: null == open
          ? _value.open
          : open // ignore: cast_nullable_to_non_nullable
              as String,
      close: null == close
          ? _value.close
          : close // ignore: cast_nullable_to_non_nullable
              as String,
      isClosed: null == isClosed
          ? _value.isClosed
          : isClosed // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DayHoursImpl implements _DayHours {
  const _$DayHoursImpl(
      {required this.open, required this.close, this.isClosed = false});

  factory _$DayHoursImpl.fromJson(Map<String, dynamic> json) =>
      _$$DayHoursImplFromJson(json);

  @override
  final String open;
  @override
  final String close;
  @override
  @JsonKey()
  final bool isClosed;

  @override
  String toString() {
    return 'DayHours(open: $open, close: $close, isClosed: $isClosed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DayHoursImpl &&
            (identical(other.open, open) || other.open == open) &&
            (identical(other.close, close) || other.close == close) &&
            (identical(other.isClosed, isClosed) ||
                other.isClosed == isClosed));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, open, close, isClosed);

  /// Create a copy of DayHours
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DayHoursImplCopyWith<_$DayHoursImpl> get copyWith =>
      __$$DayHoursImplCopyWithImpl<_$DayHoursImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DayHoursImplToJson(
      this,
    );
  }
}

abstract class _DayHours implements DayHours {
  const factory _DayHours(
      {required final String open,
      required final String close,
      final bool isClosed}) = _$DayHoursImpl;

  factory _DayHours.fromJson(Map<String, dynamic> json) =
      _$DayHoursImpl.fromJson;

  @override
  String get open;
  @override
  String get close;
  @override
  bool get isClosed;

  /// Create a copy of DayHours
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DayHoursImplCopyWith<_$DayHoursImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
