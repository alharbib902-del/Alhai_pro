// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'whatsapp_service.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

WhatsAppReceiptRequest _$WhatsAppReceiptRequestFromJson(
  Map<String, dynamic> json,
) {
  return _WhatsAppReceiptRequest.fromJson(json);
}

/// @nodoc
mixin _$WhatsAppReceiptRequest {
  String get orderId => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  String get customerName => throw _privateConstructorUsedError;
  String? get language => throw _privateConstructorUsedError;

  /// Serializes this WhatsAppReceiptRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WhatsAppReceiptRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WhatsAppReceiptRequestCopyWith<WhatsAppReceiptRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WhatsAppReceiptRequestCopyWith<$Res> {
  factory $WhatsAppReceiptRequestCopyWith(
    WhatsAppReceiptRequest value,
    $Res Function(WhatsAppReceiptRequest) then,
  ) = _$WhatsAppReceiptRequestCopyWithImpl<$Res, WhatsAppReceiptRequest>;
  @useResult
  $Res call({
    String orderId,
    String phone,
    String customerName,
    String? language,
  });
}

/// @nodoc
class _$WhatsAppReceiptRequestCopyWithImpl<
  $Res,
  $Val extends WhatsAppReceiptRequest
>
    implements $WhatsAppReceiptRequestCopyWith<$Res> {
  _$WhatsAppReceiptRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WhatsAppReceiptRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orderId = null,
    Object? phone = null,
    Object? customerName = null,
    Object? language = freezed,
  }) {
    return _then(
      _value.copyWith(
            orderId: null == orderId
                ? _value.orderId
                : orderId // ignore: cast_nullable_to_non_nullable
                      as String,
            phone: null == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String,
            customerName: null == customerName
                ? _value.customerName
                : customerName // ignore: cast_nullable_to_non_nullable
                      as String,
            language: freezed == language
                ? _value.language
                : language // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WhatsAppReceiptRequestImplCopyWith<$Res>
    implements $WhatsAppReceiptRequestCopyWith<$Res> {
  factory _$$WhatsAppReceiptRequestImplCopyWith(
    _$WhatsAppReceiptRequestImpl value,
    $Res Function(_$WhatsAppReceiptRequestImpl) then,
  ) = __$$WhatsAppReceiptRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String orderId,
    String phone,
    String customerName,
    String? language,
  });
}

/// @nodoc
class __$$WhatsAppReceiptRequestImplCopyWithImpl<$Res>
    extends
        _$WhatsAppReceiptRequestCopyWithImpl<$Res, _$WhatsAppReceiptRequestImpl>
    implements _$$WhatsAppReceiptRequestImplCopyWith<$Res> {
  __$$WhatsAppReceiptRequestImplCopyWithImpl(
    _$WhatsAppReceiptRequestImpl _value,
    $Res Function(_$WhatsAppReceiptRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WhatsAppReceiptRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orderId = null,
    Object? phone = null,
    Object? customerName = null,
    Object? language = freezed,
  }) {
    return _then(
      _$WhatsAppReceiptRequestImpl(
        orderId: null == orderId
            ? _value.orderId
            : orderId // ignore: cast_nullable_to_non_nullable
                  as String,
        phone: null == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String,
        customerName: null == customerName
            ? _value.customerName
            : customerName // ignore: cast_nullable_to_non_nullable
                  as String,
        language: freezed == language
            ? _value.language
            : language // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WhatsAppReceiptRequestImpl implements _WhatsAppReceiptRequest {
  const _$WhatsAppReceiptRequestImpl({
    required this.orderId,
    required this.phone,
    required this.customerName,
    this.language,
  });

  factory _$WhatsAppReceiptRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$WhatsAppReceiptRequestImplFromJson(json);

  @override
  final String orderId;
  @override
  final String phone;
  @override
  final String customerName;
  @override
  final String? language;

  @override
  String toString() {
    return 'WhatsAppReceiptRequest(orderId: $orderId, phone: $phone, customerName: $customerName, language: $language)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WhatsAppReceiptRequestImpl &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.language, language) ||
                other.language == language));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, orderId, phone, customerName, language);

  /// Create a copy of WhatsAppReceiptRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WhatsAppReceiptRequestImplCopyWith<_$WhatsAppReceiptRequestImpl>
  get copyWith =>
      __$$WhatsAppReceiptRequestImplCopyWithImpl<_$WhatsAppReceiptRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$WhatsAppReceiptRequestImplToJson(this);
  }
}

abstract class _WhatsAppReceiptRequest implements WhatsAppReceiptRequest {
  const factory _WhatsAppReceiptRequest({
    required final String orderId,
    required final String phone,
    required final String customerName,
    final String? language,
  }) = _$WhatsAppReceiptRequestImpl;

  factory _WhatsAppReceiptRequest.fromJson(Map<String, dynamic> json) =
      _$WhatsAppReceiptRequestImpl.fromJson;

  @override
  String get orderId;
  @override
  String get phone;
  @override
  String get customerName;
  @override
  String? get language;

  /// Create a copy of WhatsAppReceiptRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WhatsAppReceiptRequestImplCopyWith<_$WhatsAppReceiptRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}

WhatsAppReceiptResponse _$WhatsAppReceiptResponseFromJson(
  Map<String, dynamic> json,
) {
  return _WhatsAppReceiptResponse.fromJson(json);
}

/// @nodoc
mixin _$WhatsAppReceiptResponse {
  String get messageId => throw _privateConstructorUsedError;
  WhatsAppMessageStatus get status => throw _privateConstructorUsedError;
  String get receiptUrl => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Serializes this WhatsAppReceiptResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WhatsAppReceiptResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WhatsAppReceiptResponseCopyWith<WhatsAppReceiptResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WhatsAppReceiptResponseCopyWith<$Res> {
  factory $WhatsAppReceiptResponseCopyWith(
    WhatsAppReceiptResponse value,
    $Res Function(WhatsAppReceiptResponse) then,
  ) = _$WhatsAppReceiptResponseCopyWithImpl<$Res, WhatsAppReceiptResponse>;
  @useResult
  $Res call({
    String messageId,
    WhatsAppMessageStatus status,
    String receiptUrl,
    String? errorMessage,
  });
}

/// @nodoc
class _$WhatsAppReceiptResponseCopyWithImpl<
  $Res,
  $Val extends WhatsAppReceiptResponse
>
    implements $WhatsAppReceiptResponseCopyWith<$Res> {
  _$WhatsAppReceiptResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WhatsAppReceiptResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? messageId = null,
    Object? status = null,
    Object? receiptUrl = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            messageId: null == messageId
                ? _value.messageId
                : messageId // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as WhatsAppMessageStatus,
            receiptUrl: null == receiptUrl
                ? _value.receiptUrl
                : receiptUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WhatsAppReceiptResponseImplCopyWith<$Res>
    implements $WhatsAppReceiptResponseCopyWith<$Res> {
  factory _$$WhatsAppReceiptResponseImplCopyWith(
    _$WhatsAppReceiptResponseImpl value,
    $Res Function(_$WhatsAppReceiptResponseImpl) then,
  ) = __$$WhatsAppReceiptResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String messageId,
    WhatsAppMessageStatus status,
    String receiptUrl,
    String? errorMessage,
  });
}

/// @nodoc
class __$$WhatsAppReceiptResponseImplCopyWithImpl<$Res>
    extends
        _$WhatsAppReceiptResponseCopyWithImpl<
          $Res,
          _$WhatsAppReceiptResponseImpl
        >
    implements _$$WhatsAppReceiptResponseImplCopyWith<$Res> {
  __$$WhatsAppReceiptResponseImplCopyWithImpl(
    _$WhatsAppReceiptResponseImpl _value,
    $Res Function(_$WhatsAppReceiptResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WhatsAppReceiptResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? messageId = null,
    Object? status = null,
    Object? receiptUrl = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _$WhatsAppReceiptResponseImpl(
        messageId: null == messageId
            ? _value.messageId
            : messageId // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as WhatsAppMessageStatus,
        receiptUrl: null == receiptUrl
            ? _value.receiptUrl
            : receiptUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WhatsAppReceiptResponseImpl implements _WhatsAppReceiptResponse {
  const _$WhatsAppReceiptResponseImpl({
    required this.messageId,
    required this.status,
    required this.receiptUrl,
    this.errorMessage,
  });

  factory _$WhatsAppReceiptResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$WhatsAppReceiptResponseImplFromJson(json);

  @override
  final String messageId;
  @override
  final WhatsAppMessageStatus status;
  @override
  final String receiptUrl;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'WhatsAppReceiptResponse(messageId: $messageId, status: $status, receiptUrl: $receiptUrl, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WhatsAppReceiptResponseImpl &&
            (identical(other.messageId, messageId) ||
                other.messageId == messageId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.receiptUrl, receiptUrl) ||
                other.receiptUrl == receiptUrl) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, messageId, status, receiptUrl, errorMessage);

  /// Create a copy of WhatsAppReceiptResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WhatsAppReceiptResponseImplCopyWith<_$WhatsAppReceiptResponseImpl>
  get copyWith =>
      __$$WhatsAppReceiptResponseImplCopyWithImpl<
        _$WhatsAppReceiptResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WhatsAppReceiptResponseImplToJson(this);
  }
}

abstract class _WhatsAppReceiptResponse implements WhatsAppReceiptResponse {
  const factory _WhatsAppReceiptResponse({
    required final String messageId,
    required final WhatsAppMessageStatus status,
    required final String receiptUrl,
    final String? errorMessage,
  }) = _$WhatsAppReceiptResponseImpl;

  factory _WhatsAppReceiptResponse.fromJson(Map<String, dynamic> json) =
      _$WhatsAppReceiptResponseImpl.fromJson;

  @override
  String get messageId;
  @override
  WhatsAppMessageStatus get status;
  @override
  String get receiptUrl;
  @override
  String? get errorMessage;

  /// Create a copy of WhatsAppReceiptResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WhatsAppReceiptResponseImplCopyWith<_$WhatsAppReceiptResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}
