// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pin_validation_service.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PinValidationRequest _$PinValidationRequestFromJson(Map<String, dynamic> json) {
  return _PinValidationRequest.fromJson(json);
}

/// @nodoc
mixin _$PinValidationRequest {
  String get pin => throw _privateConstructorUsedError;
  PinActionType get action => throw _privateConstructorUsedError;
  String? get supervisorId => throw _privateConstructorUsedError;

  /// Serializes this PinValidationRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PinValidationRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PinValidationRequestCopyWith<PinValidationRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PinValidationRequestCopyWith<$Res> {
  factory $PinValidationRequestCopyWith(PinValidationRequest value,
          $Res Function(PinValidationRequest) then) =
      _$PinValidationRequestCopyWithImpl<$Res, PinValidationRequest>;
  @useResult
  $Res call({String pin, PinActionType action, String? supervisorId});
}

/// @nodoc
class _$PinValidationRequestCopyWithImpl<$Res,
        $Val extends PinValidationRequest>
    implements $PinValidationRequestCopyWith<$Res> {
  _$PinValidationRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PinValidationRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pin = null,
    Object? action = null,
    Object? supervisorId = freezed,
  }) {
    return _then(_value.copyWith(
      pin: null == pin
          ? _value.pin
          : pin // ignore: cast_nullable_to_non_nullable
              as String,
      action: null == action
          ? _value.action
          : action // ignore: cast_nullable_to_non_nullable
              as PinActionType,
      supervisorId: freezed == supervisorId
          ? _value.supervisorId
          : supervisorId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PinValidationRequestImplCopyWith<$Res>
    implements $PinValidationRequestCopyWith<$Res> {
  factory _$$PinValidationRequestImplCopyWith(_$PinValidationRequestImpl value,
          $Res Function(_$PinValidationRequestImpl) then) =
      __$$PinValidationRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String pin, PinActionType action, String? supervisorId});
}

/// @nodoc
class __$$PinValidationRequestImplCopyWithImpl<$Res>
    extends _$PinValidationRequestCopyWithImpl<$Res, _$PinValidationRequestImpl>
    implements _$$PinValidationRequestImplCopyWith<$Res> {
  __$$PinValidationRequestImplCopyWithImpl(_$PinValidationRequestImpl _value,
      $Res Function(_$PinValidationRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of PinValidationRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pin = null,
    Object? action = null,
    Object? supervisorId = freezed,
  }) {
    return _then(_$PinValidationRequestImpl(
      pin: null == pin
          ? _value.pin
          : pin // ignore: cast_nullable_to_non_nullable
              as String,
      action: null == action
          ? _value.action
          : action // ignore: cast_nullable_to_non_nullable
              as PinActionType,
      supervisorId: freezed == supervisorId
          ? _value.supervisorId
          : supervisorId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PinValidationRequestImpl implements _PinValidationRequest {
  const _$PinValidationRequestImpl(
      {required this.pin, required this.action, this.supervisorId});

  factory _$PinValidationRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$PinValidationRequestImplFromJson(json);

  @override
  final String pin;
  @override
  final PinActionType action;
  @override
  final String? supervisorId;

  @override
  String toString() {
    return 'PinValidationRequest(pin: $pin, action: $action, supervisorId: $supervisorId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PinValidationRequestImpl &&
            (identical(other.pin, pin) || other.pin == pin) &&
            (identical(other.action, action) || other.action == action) &&
            (identical(other.supervisorId, supervisorId) ||
                other.supervisorId == supervisorId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, pin, action, supervisorId);

  /// Create a copy of PinValidationRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PinValidationRequestImplCopyWith<_$PinValidationRequestImpl>
      get copyWith =>
          __$$PinValidationRequestImplCopyWithImpl<_$PinValidationRequestImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PinValidationRequestImplToJson(
      this,
    );
  }
}

abstract class _PinValidationRequest implements PinValidationRequest {
  const factory _PinValidationRequest(
      {required final String pin,
      required final PinActionType action,
      final String? supervisorId}) = _$PinValidationRequestImpl;

  factory _PinValidationRequest.fromJson(Map<String, dynamic> json) =
      _$PinValidationRequestImpl.fromJson;

  @override
  String get pin;
  @override
  PinActionType get action;
  @override
  String? get supervisorId;

  /// Create a copy of PinValidationRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PinValidationRequestImplCopyWith<_$PinValidationRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}

PinValidationResult _$PinValidationResultFromJson(Map<String, dynamic> json) {
  return _PinValidationResult.fromJson(json);
}

/// @nodoc
mixin _$PinValidationResult {
  bool get isValid => throw _privateConstructorUsedError;
  String? get userId => throw _privateConstructorUsedError;
  String? get userName => throw _privateConstructorUsedError;
  String? get role => throw _privateConstructorUsedError;
  List<String>? get permissions => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  int get remainingAttempts => throw _privateConstructorUsedError;
  DateTime? get lockedUntil => throw _privateConstructorUsedError;

  /// Serializes this PinValidationResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PinValidationResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PinValidationResultCopyWith<PinValidationResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PinValidationResultCopyWith<$Res> {
  factory $PinValidationResultCopyWith(
          PinValidationResult value, $Res Function(PinValidationResult) then) =
      _$PinValidationResultCopyWithImpl<$Res, PinValidationResult>;
  @useResult
  $Res call(
      {bool isValid,
      String? userId,
      String? userName,
      String? role,
      List<String>? permissions,
      String? errorMessage,
      int remainingAttempts,
      DateTime? lockedUntil});
}

/// @nodoc
class _$PinValidationResultCopyWithImpl<$Res, $Val extends PinValidationResult>
    implements $PinValidationResultCopyWith<$Res> {
  _$PinValidationResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PinValidationResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isValid = null,
    Object? userId = freezed,
    Object? userName = freezed,
    Object? role = freezed,
    Object? permissions = freezed,
    Object? errorMessage = freezed,
    Object? remainingAttempts = null,
    Object? lockedUntil = freezed,
  }) {
    return _then(_value.copyWith(
      isValid: null == isValid
          ? _value.isValid
          : isValid // ignore: cast_nullable_to_non_nullable
              as bool,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      userName: freezed == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String?,
      role: freezed == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String?,
      permissions: freezed == permissions
          ? _value.permissions
          : permissions // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      remainingAttempts: null == remainingAttempts
          ? _value.remainingAttempts
          : remainingAttempts // ignore: cast_nullable_to_non_nullable
              as int,
      lockedUntil: freezed == lockedUntil
          ? _value.lockedUntil
          : lockedUntil // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PinValidationResultImplCopyWith<$Res>
    implements $PinValidationResultCopyWith<$Res> {
  factory _$$PinValidationResultImplCopyWith(_$PinValidationResultImpl value,
          $Res Function(_$PinValidationResultImpl) then) =
      __$$PinValidationResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isValid,
      String? userId,
      String? userName,
      String? role,
      List<String>? permissions,
      String? errorMessage,
      int remainingAttempts,
      DateTime? lockedUntil});
}

/// @nodoc
class __$$PinValidationResultImplCopyWithImpl<$Res>
    extends _$PinValidationResultCopyWithImpl<$Res, _$PinValidationResultImpl>
    implements _$$PinValidationResultImplCopyWith<$Res> {
  __$$PinValidationResultImplCopyWithImpl(_$PinValidationResultImpl _value,
      $Res Function(_$PinValidationResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of PinValidationResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isValid = null,
    Object? userId = freezed,
    Object? userName = freezed,
    Object? role = freezed,
    Object? permissions = freezed,
    Object? errorMessage = freezed,
    Object? remainingAttempts = null,
    Object? lockedUntil = freezed,
  }) {
    return _then(_$PinValidationResultImpl(
      isValid: null == isValid
          ? _value.isValid
          : isValid // ignore: cast_nullable_to_non_nullable
              as bool,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      userName: freezed == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String?,
      role: freezed == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String?,
      permissions: freezed == permissions
          ? _value._permissions
          : permissions // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      remainingAttempts: null == remainingAttempts
          ? _value.remainingAttempts
          : remainingAttempts // ignore: cast_nullable_to_non_nullable
              as int,
      lockedUntil: freezed == lockedUntil
          ? _value.lockedUntil
          : lockedUntil // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PinValidationResultImpl extends _PinValidationResult {
  const _$PinValidationResultImpl(
      {required this.isValid,
      this.userId,
      this.userName,
      this.role,
      final List<String>? permissions,
      this.errorMessage,
      this.remainingAttempts = 0,
      this.lockedUntil})
      : _permissions = permissions,
        super._();

  factory _$PinValidationResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$PinValidationResultImplFromJson(json);

  @override
  final bool isValid;
  @override
  final String? userId;
  @override
  final String? userName;
  @override
  final String? role;
  final List<String>? _permissions;
  @override
  List<String>? get permissions {
    final value = _permissions;
    if (value == null) return null;
    if (_permissions is EqualUnmodifiableListView) return _permissions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? errorMessage;
  @override
  @JsonKey()
  final int remainingAttempts;
  @override
  final DateTime? lockedUntil;

  @override
  String toString() {
    return 'PinValidationResult(isValid: $isValid, userId: $userId, userName: $userName, role: $role, permissions: $permissions, errorMessage: $errorMessage, remainingAttempts: $remainingAttempts, lockedUntil: $lockedUntil)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PinValidationResultImpl &&
            (identical(other.isValid, isValid) || other.isValid == isValid) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.role, role) || other.role == role) &&
            const DeepCollectionEquality()
                .equals(other._permissions, _permissions) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.remainingAttempts, remainingAttempts) ||
                other.remainingAttempts == remainingAttempts) &&
            (identical(other.lockedUntil, lockedUntil) ||
                other.lockedUntil == lockedUntil));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      isValid,
      userId,
      userName,
      role,
      const DeepCollectionEquality().hash(_permissions),
      errorMessage,
      remainingAttempts,
      lockedUntil);

  /// Create a copy of PinValidationResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PinValidationResultImplCopyWith<_$PinValidationResultImpl> get copyWith =>
      __$$PinValidationResultImplCopyWithImpl<_$PinValidationResultImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PinValidationResultImplToJson(
      this,
    );
  }
}

abstract class _PinValidationResult extends PinValidationResult {
  const factory _PinValidationResult(
      {required final bool isValid,
      final String? userId,
      final String? userName,
      final String? role,
      final List<String>? permissions,
      final String? errorMessage,
      final int remainingAttempts,
      final DateTime? lockedUntil}) = _$PinValidationResultImpl;
  const _PinValidationResult._() : super._();

  factory _PinValidationResult.fromJson(Map<String, dynamic> json) =
      _$PinValidationResultImpl.fromJson;

  @override
  bool get isValid;
  @override
  String? get userId;
  @override
  String? get userName;
  @override
  String? get role;
  @override
  List<String>? get permissions;
  @override
  String? get errorMessage;
  @override
  int get remainingAttempts;
  @override
  DateTime? get lockedUntil;

  /// Create a copy of PinValidationResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PinValidationResultImplCopyWith<_$PinValidationResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EmergencyCode _$EmergencyCodeFromJson(Map<String, dynamic> json) {
  return _EmergencyCode.fromJson(json);
}

/// @nodoc
mixin _$EmergencyCode {
  String get code => throw _privateConstructorUsedError;
  String get supervisorId => throw _privateConstructorUsedError;
  DateTime get expiresAt => throw _privateConstructorUsedError;
  bool get isUsed => throw _privateConstructorUsedError;

  /// Serializes this EmergencyCode to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EmergencyCode
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EmergencyCodeCopyWith<EmergencyCode> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EmergencyCodeCopyWith<$Res> {
  factory $EmergencyCodeCopyWith(
          EmergencyCode value, $Res Function(EmergencyCode) then) =
      _$EmergencyCodeCopyWithImpl<$Res, EmergencyCode>;
  @useResult
  $Res call(
      {String code, String supervisorId, DateTime expiresAt, bool isUsed});
}

/// @nodoc
class _$EmergencyCodeCopyWithImpl<$Res, $Val extends EmergencyCode>
    implements $EmergencyCodeCopyWith<$Res> {
  _$EmergencyCodeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EmergencyCode
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? supervisorId = null,
    Object? expiresAt = null,
    Object? isUsed = null,
  }) {
    return _then(_value.copyWith(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      supervisorId: null == supervisorId
          ? _value.supervisorId
          : supervisorId // ignore: cast_nullable_to_non_nullable
              as String,
      expiresAt: null == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isUsed: null == isUsed
          ? _value.isUsed
          : isUsed // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EmergencyCodeImplCopyWith<$Res>
    implements $EmergencyCodeCopyWith<$Res> {
  factory _$$EmergencyCodeImplCopyWith(
          _$EmergencyCodeImpl value, $Res Function(_$EmergencyCodeImpl) then) =
      __$$EmergencyCodeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String code, String supervisorId, DateTime expiresAt, bool isUsed});
}

/// @nodoc
class __$$EmergencyCodeImplCopyWithImpl<$Res>
    extends _$EmergencyCodeCopyWithImpl<$Res, _$EmergencyCodeImpl>
    implements _$$EmergencyCodeImplCopyWith<$Res> {
  __$$EmergencyCodeImplCopyWithImpl(
      _$EmergencyCodeImpl _value, $Res Function(_$EmergencyCodeImpl) _then)
      : super(_value, _then);

  /// Create a copy of EmergencyCode
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? supervisorId = null,
    Object? expiresAt = null,
    Object? isUsed = null,
  }) {
    return _then(_$EmergencyCodeImpl(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      supervisorId: null == supervisorId
          ? _value.supervisorId
          : supervisorId // ignore: cast_nullable_to_non_nullable
              as String,
      expiresAt: null == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isUsed: null == isUsed
          ? _value.isUsed
          : isUsed // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EmergencyCodeImpl implements _EmergencyCode {
  const _$EmergencyCodeImpl(
      {required this.code,
      required this.supervisorId,
      required this.expiresAt,
      this.isUsed = false});

  factory _$EmergencyCodeImpl.fromJson(Map<String, dynamic> json) =>
      _$$EmergencyCodeImplFromJson(json);

  @override
  final String code;
  @override
  final String supervisorId;
  @override
  final DateTime expiresAt;
  @override
  @JsonKey()
  final bool isUsed;

  @override
  String toString() {
    return 'EmergencyCode(code: $code, supervisorId: $supervisorId, expiresAt: $expiresAt, isUsed: $isUsed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EmergencyCodeImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.supervisorId, supervisorId) ||
                other.supervisorId == supervisorId) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.isUsed, isUsed) || other.isUsed == isUsed));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, code, supervisorId, expiresAt, isUsed);

  /// Create a copy of EmergencyCode
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EmergencyCodeImplCopyWith<_$EmergencyCodeImpl> get copyWith =>
      __$$EmergencyCodeImplCopyWithImpl<_$EmergencyCodeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EmergencyCodeImplToJson(
      this,
    );
  }
}

abstract class _EmergencyCode implements EmergencyCode {
  const factory _EmergencyCode(
      {required final String code,
      required final String supervisorId,
      required final DateTime expiresAt,
      final bool isUsed}) = _$EmergencyCodeImpl;

  factory _EmergencyCode.fromJson(Map<String, dynamic> json) =
      _$EmergencyCodeImpl.fromJson;

  @override
  String get code;
  @override
  String get supervisorId;
  @override
  DateTime get expiresAt;
  @override
  bool get isUsed;

  /// Create a copy of EmergencyCode
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EmergencyCodeImplCopyWith<_$EmergencyCodeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TotpSecret _$TotpSecretFromJson(Map<String, dynamic> json) {
  return _TotpSecret.fromJson(json);
}

/// @nodoc
mixin _$TotpSecret {
  String get userId => throw _privateConstructorUsedError;
  String get secret => throw _privateConstructorUsedError;
  DateTime get syncedAt => throw _privateConstructorUsedError;

  /// Serializes this TotpSecret to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TotpSecret
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TotpSecretCopyWith<TotpSecret> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TotpSecretCopyWith<$Res> {
  factory $TotpSecretCopyWith(
          TotpSecret value, $Res Function(TotpSecret) then) =
      _$TotpSecretCopyWithImpl<$Res, TotpSecret>;
  @useResult
  $Res call({String userId, String secret, DateTime syncedAt});
}

/// @nodoc
class _$TotpSecretCopyWithImpl<$Res, $Val extends TotpSecret>
    implements $TotpSecretCopyWith<$Res> {
  _$TotpSecretCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TotpSecret
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? secret = null,
    Object? syncedAt = null,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      secret: null == secret
          ? _value.secret
          : secret // ignore: cast_nullable_to_non_nullable
              as String,
      syncedAt: null == syncedAt
          ? _value.syncedAt
          : syncedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TotpSecretImplCopyWith<$Res>
    implements $TotpSecretCopyWith<$Res> {
  factory _$$TotpSecretImplCopyWith(
          _$TotpSecretImpl value, $Res Function(_$TotpSecretImpl) then) =
      __$$TotpSecretImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String userId, String secret, DateTime syncedAt});
}

/// @nodoc
class __$$TotpSecretImplCopyWithImpl<$Res>
    extends _$TotpSecretCopyWithImpl<$Res, _$TotpSecretImpl>
    implements _$$TotpSecretImplCopyWith<$Res> {
  __$$TotpSecretImplCopyWithImpl(
      _$TotpSecretImpl _value, $Res Function(_$TotpSecretImpl) _then)
      : super(_value, _then);

  /// Create a copy of TotpSecret
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? secret = null,
    Object? syncedAt = null,
  }) {
    return _then(_$TotpSecretImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      secret: null == secret
          ? _value.secret
          : secret // ignore: cast_nullable_to_non_nullable
              as String,
      syncedAt: null == syncedAt
          ? _value.syncedAt
          : syncedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TotpSecretImpl implements _TotpSecret {
  const _$TotpSecretImpl(
      {required this.userId, required this.secret, required this.syncedAt});

  factory _$TotpSecretImpl.fromJson(Map<String, dynamic> json) =>
      _$$TotpSecretImplFromJson(json);

  @override
  final String userId;
  @override
  final String secret;
  @override
  final DateTime syncedAt;

  @override
  String toString() {
    return 'TotpSecret(userId: $userId, secret: $secret, syncedAt: $syncedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TotpSecretImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.secret, secret) || other.secret == secret) &&
            (identical(other.syncedAt, syncedAt) ||
                other.syncedAt == syncedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, userId, secret, syncedAt);

  /// Create a copy of TotpSecret
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TotpSecretImplCopyWith<_$TotpSecretImpl> get copyWith =>
      __$$TotpSecretImplCopyWithImpl<_$TotpSecretImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TotpSecretImplToJson(
      this,
    );
  }
}

abstract class _TotpSecret implements TotpSecret {
  const factory _TotpSecret(
      {required final String userId,
      required final String secret,
      required final DateTime syncedAt}) = _$TotpSecretImpl;

  factory _TotpSecret.fromJson(Map<String, dynamic> json) =
      _$TotpSecretImpl.fromJson;

  @override
  String get userId;
  @override
  String get secret;
  @override
  DateTime get syncedAt;

  /// Create a copy of TotpSecret
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TotpSecretImplCopyWith<_$TotpSecretImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
