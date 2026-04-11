// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'store_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

StoreSettings _$StoreSettingsFromJson(Map<String, dynamic> json) {
  return _StoreSettings.fromJson(json);
}

/// @nodoc
mixin _$StoreSettings {
  String get id => throw _privateConstructorUsedError;
  String get storeId => throw _privateConstructorUsedError;
  String? get receiptHeader => throw _privateConstructorUsedError;
  String? get receiptFooter => throw _privateConstructorUsedError;
  double get taxRate => throw _privateConstructorUsedError;
  int get lowStockThreshold => throw _privateConstructorUsedError;
  bool get enableLoyalty => throw _privateConstructorUsedError;
  int get loyaltyPointsPerRial => throw _privateConstructorUsedError;
  bool get autoPrintReceipt => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this StoreSettings to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StoreSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StoreSettingsCopyWith<StoreSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StoreSettingsCopyWith<$Res> {
  factory $StoreSettingsCopyWith(
    StoreSettings value,
    $Res Function(StoreSettings) then,
  ) = _$StoreSettingsCopyWithImpl<$Res, StoreSettings>;
  @useResult
  $Res call({
    String id,
    String storeId,
    String? receiptHeader,
    String? receiptFooter,
    double taxRate,
    int lowStockThreshold,
    bool enableLoyalty,
    int loyaltyPointsPerRial,
    bool autoPrintReceipt,
    String currency,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$StoreSettingsCopyWithImpl<$Res, $Val extends StoreSettings>
    implements $StoreSettingsCopyWith<$Res> {
  _$StoreSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StoreSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? storeId = null,
    Object? receiptHeader = freezed,
    Object? receiptFooter = freezed,
    Object? taxRate = null,
    Object? lowStockThreshold = null,
    Object? enableLoyalty = null,
    Object? loyaltyPointsPerRial = null,
    Object? autoPrintReceipt = null,
    Object? currency = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            storeId: null == storeId
                ? _value.storeId
                : storeId // ignore: cast_nullable_to_non_nullable
                      as String,
            receiptHeader: freezed == receiptHeader
                ? _value.receiptHeader
                : receiptHeader // ignore: cast_nullable_to_non_nullable
                      as String?,
            receiptFooter: freezed == receiptFooter
                ? _value.receiptFooter
                : receiptFooter // ignore: cast_nullable_to_non_nullable
                      as String?,
            taxRate: null == taxRate
                ? _value.taxRate
                : taxRate // ignore: cast_nullable_to_non_nullable
                      as double,
            lowStockThreshold: null == lowStockThreshold
                ? _value.lowStockThreshold
                : lowStockThreshold // ignore: cast_nullable_to_non_nullable
                      as int,
            enableLoyalty: null == enableLoyalty
                ? _value.enableLoyalty
                : enableLoyalty // ignore: cast_nullable_to_non_nullable
                      as bool,
            loyaltyPointsPerRial: null == loyaltyPointsPerRial
                ? _value.loyaltyPointsPerRial
                : loyaltyPointsPerRial // ignore: cast_nullable_to_non_nullable
                      as int,
            autoPrintReceipt: null == autoPrintReceipt
                ? _value.autoPrintReceipt
                : autoPrintReceipt // ignore: cast_nullable_to_non_nullable
                      as bool,
            currency: null == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                      as String,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StoreSettingsImplCopyWith<$Res>
    implements $StoreSettingsCopyWith<$Res> {
  factory _$$StoreSettingsImplCopyWith(
    _$StoreSettingsImpl value,
    $Res Function(_$StoreSettingsImpl) then,
  ) = __$$StoreSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String storeId,
    String? receiptHeader,
    String? receiptFooter,
    double taxRate,
    int lowStockThreshold,
    bool enableLoyalty,
    int loyaltyPointsPerRial,
    bool autoPrintReceipt,
    String currency,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$StoreSettingsImplCopyWithImpl<$Res>
    extends _$StoreSettingsCopyWithImpl<$Res, _$StoreSettingsImpl>
    implements _$$StoreSettingsImplCopyWith<$Res> {
  __$$StoreSettingsImplCopyWithImpl(
    _$StoreSettingsImpl _value,
    $Res Function(_$StoreSettingsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StoreSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? storeId = null,
    Object? receiptHeader = freezed,
    Object? receiptFooter = freezed,
    Object? taxRate = null,
    Object? lowStockThreshold = null,
    Object? enableLoyalty = null,
    Object? loyaltyPointsPerRial = null,
    Object? autoPrintReceipt = null,
    Object? currency = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$StoreSettingsImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        storeId: null == storeId
            ? _value.storeId
            : storeId // ignore: cast_nullable_to_non_nullable
                  as String,
        receiptHeader: freezed == receiptHeader
            ? _value.receiptHeader
            : receiptHeader // ignore: cast_nullable_to_non_nullable
                  as String?,
        receiptFooter: freezed == receiptFooter
            ? _value.receiptFooter
            : receiptFooter // ignore: cast_nullable_to_non_nullable
                  as String?,
        taxRate: null == taxRate
            ? _value.taxRate
            : taxRate // ignore: cast_nullable_to_non_nullable
                  as double,
        lowStockThreshold: null == lowStockThreshold
            ? _value.lowStockThreshold
            : lowStockThreshold // ignore: cast_nullable_to_non_nullable
                  as int,
        enableLoyalty: null == enableLoyalty
            ? _value.enableLoyalty
            : enableLoyalty // ignore: cast_nullable_to_non_nullable
                  as bool,
        loyaltyPointsPerRial: null == loyaltyPointsPerRial
            ? _value.loyaltyPointsPerRial
            : loyaltyPointsPerRial // ignore: cast_nullable_to_non_nullable
                  as int,
        autoPrintReceipt: null == autoPrintReceipt
            ? _value.autoPrintReceipt
            : autoPrintReceipt // ignore: cast_nullable_to_non_nullable
                  as bool,
        currency: null == currency
            ? _value.currency
            : currency // ignore: cast_nullable_to_non_nullable
                  as String,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StoreSettingsImpl extends _StoreSettings {
  const _$StoreSettingsImpl({
    required this.id,
    required this.storeId,
    this.receiptHeader,
    this.receiptFooter,
    this.taxRate = 15.0,
    this.lowStockThreshold = 10,
    this.enableLoyalty = true,
    this.loyaltyPointsPerRial = 1,
    this.autoPrintReceipt = true,
    this.currency = 'SAR',
    this.updatedAt,
  }) : super._();

  factory _$StoreSettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$StoreSettingsImplFromJson(json);

  @override
  final String id;
  @override
  final String storeId;
  @override
  final String? receiptHeader;
  @override
  final String? receiptFooter;
  @override
  @JsonKey()
  final double taxRate;
  @override
  @JsonKey()
  final int lowStockThreshold;
  @override
  @JsonKey()
  final bool enableLoyalty;
  @override
  @JsonKey()
  final int loyaltyPointsPerRial;
  @override
  @JsonKey()
  final bool autoPrintReceipt;
  @override
  @JsonKey()
  final String currency;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'StoreSettings(id: $id, storeId: $storeId, receiptHeader: $receiptHeader, receiptFooter: $receiptFooter, taxRate: $taxRate, lowStockThreshold: $lowStockThreshold, enableLoyalty: $enableLoyalty, loyaltyPointsPerRial: $loyaltyPointsPerRial, autoPrintReceipt: $autoPrintReceipt, currency: $currency, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StoreSettingsImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.storeId, storeId) || other.storeId == storeId) &&
            (identical(other.receiptHeader, receiptHeader) ||
                other.receiptHeader == receiptHeader) &&
            (identical(other.receiptFooter, receiptFooter) ||
                other.receiptFooter == receiptFooter) &&
            (identical(other.taxRate, taxRate) || other.taxRate == taxRate) &&
            (identical(other.lowStockThreshold, lowStockThreshold) ||
                other.lowStockThreshold == lowStockThreshold) &&
            (identical(other.enableLoyalty, enableLoyalty) ||
                other.enableLoyalty == enableLoyalty) &&
            (identical(other.loyaltyPointsPerRial, loyaltyPointsPerRial) ||
                other.loyaltyPointsPerRial == loyaltyPointsPerRial) &&
            (identical(other.autoPrintReceipt, autoPrintReceipt) ||
                other.autoPrintReceipt == autoPrintReceipt) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    storeId,
    receiptHeader,
    receiptFooter,
    taxRate,
    lowStockThreshold,
    enableLoyalty,
    loyaltyPointsPerRial,
    autoPrintReceipt,
    currency,
    updatedAt,
  );

  /// Create a copy of StoreSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StoreSettingsImplCopyWith<_$StoreSettingsImpl> get copyWith =>
      __$$StoreSettingsImplCopyWithImpl<_$StoreSettingsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StoreSettingsImplToJson(this);
  }
}

abstract class _StoreSettings extends StoreSettings {
  const factory _StoreSettings({
    required final String id,
    required final String storeId,
    final String? receiptHeader,
    final String? receiptFooter,
    final double taxRate,
    final int lowStockThreshold,
    final bool enableLoyalty,
    final int loyaltyPointsPerRial,
    final bool autoPrintReceipt,
    final String currency,
    final DateTime? updatedAt,
  }) = _$StoreSettingsImpl;
  const _StoreSettings._() : super._();

  factory _StoreSettings.fromJson(Map<String, dynamic> json) =
      _$StoreSettingsImpl.fromJson;

  @override
  String get id;
  @override
  String get storeId;
  @override
  String? get receiptHeader;
  @override
  String? get receiptFooter;
  @override
  double get taxRate;
  @override
  int get lowStockThreshold;
  @override
  bool get enableLoyalty;
  @override
  int get loyaltyPointsPerRial;
  @override
  bool get autoPrintReceipt;
  @override
  String get currency;
  @override
  DateTime? get updatedAt;

  /// Create a copy of StoreSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StoreSettingsImplCopyWith<_$StoreSettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
