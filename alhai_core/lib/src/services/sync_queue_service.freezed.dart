// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sync_queue_service.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SyncQueueItem _$SyncQueueItemFromJson(Map<String, dynamic> json) {
  return _SyncQueueItem.fromJson(json);
}

/// @nodoc
mixin _$SyncQueueItem {
  String get id => throw _privateConstructorUsedError;
  SyncEntityType get entityType => throw _privateConstructorUsedError;
  String get entityId => throw _privateConstructorUsedError;
  SyncOperationType get operation => throw _privateConstructorUsedError;
  SyncStatus get status => throw _privateConstructorUsedError;
  String get payload => throw _privateConstructorUsedError;
  int get attempts => throw _privateConstructorUsedError;
  int get maxAttempts => throw _privateConstructorUsedError;
  String? get lastError => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get syncedAt => throw _privateConstructorUsedError;
  DateTime? get nextRetryAt => throw _privateConstructorUsedError;

  /// Serializes this SyncQueueItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SyncQueueItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SyncQueueItemCopyWith<SyncQueueItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SyncQueueItemCopyWith<$Res> {
  factory $SyncQueueItemCopyWith(
          SyncQueueItem value, $Res Function(SyncQueueItem) then) =
      _$SyncQueueItemCopyWithImpl<$Res, SyncQueueItem>;
  @useResult
  $Res call(
      {String id,
      SyncEntityType entityType,
      String entityId,
      SyncOperationType operation,
      SyncStatus status,
      String payload,
      int attempts,
      int maxAttempts,
      String? lastError,
      DateTime createdAt,
      DateTime? syncedAt,
      DateTime? nextRetryAt});
}

/// @nodoc
class _$SyncQueueItemCopyWithImpl<$Res, $Val extends SyncQueueItem>
    implements $SyncQueueItemCopyWith<$Res> {
  _$SyncQueueItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SyncQueueItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? entityType = null,
    Object? entityId = null,
    Object? operation = null,
    Object? status = null,
    Object? payload = null,
    Object? attempts = null,
    Object? maxAttempts = null,
    Object? lastError = freezed,
    Object? createdAt = null,
    Object? syncedAt = freezed,
    Object? nextRetryAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      entityType: null == entityType
          ? _value.entityType
          : entityType // ignore: cast_nullable_to_non_nullable
              as SyncEntityType,
      entityId: null == entityId
          ? _value.entityId
          : entityId // ignore: cast_nullable_to_non_nullable
              as String,
      operation: null == operation
          ? _value.operation
          : operation // ignore: cast_nullable_to_non_nullable
              as SyncOperationType,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as SyncStatus,
      payload: null == payload
          ? _value.payload
          : payload // ignore: cast_nullable_to_non_nullable
              as String,
      attempts: null == attempts
          ? _value.attempts
          : attempts // ignore: cast_nullable_to_non_nullable
              as int,
      maxAttempts: null == maxAttempts
          ? _value.maxAttempts
          : maxAttempts // ignore: cast_nullable_to_non_nullable
              as int,
      lastError: freezed == lastError
          ? _value.lastError
          : lastError // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      syncedAt: freezed == syncedAt
          ? _value.syncedAt
          : syncedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      nextRetryAt: freezed == nextRetryAt
          ? _value.nextRetryAt
          : nextRetryAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SyncQueueItemImplCopyWith<$Res>
    implements $SyncQueueItemCopyWith<$Res> {
  factory _$$SyncQueueItemImplCopyWith(
          _$SyncQueueItemImpl value, $Res Function(_$SyncQueueItemImpl) then) =
      __$$SyncQueueItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      SyncEntityType entityType,
      String entityId,
      SyncOperationType operation,
      SyncStatus status,
      String payload,
      int attempts,
      int maxAttempts,
      String? lastError,
      DateTime createdAt,
      DateTime? syncedAt,
      DateTime? nextRetryAt});
}

/// @nodoc
class __$$SyncQueueItemImplCopyWithImpl<$Res>
    extends _$SyncQueueItemCopyWithImpl<$Res, _$SyncQueueItemImpl>
    implements _$$SyncQueueItemImplCopyWith<$Res> {
  __$$SyncQueueItemImplCopyWithImpl(
      _$SyncQueueItemImpl _value, $Res Function(_$SyncQueueItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of SyncQueueItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? entityType = null,
    Object? entityId = null,
    Object? operation = null,
    Object? status = null,
    Object? payload = null,
    Object? attempts = null,
    Object? maxAttempts = null,
    Object? lastError = freezed,
    Object? createdAt = null,
    Object? syncedAt = freezed,
    Object? nextRetryAt = freezed,
  }) {
    return _then(_$SyncQueueItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      entityType: null == entityType
          ? _value.entityType
          : entityType // ignore: cast_nullable_to_non_nullable
              as SyncEntityType,
      entityId: null == entityId
          ? _value.entityId
          : entityId // ignore: cast_nullable_to_non_nullable
              as String,
      operation: null == operation
          ? _value.operation
          : operation // ignore: cast_nullable_to_non_nullable
              as SyncOperationType,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as SyncStatus,
      payload: null == payload
          ? _value.payload
          : payload // ignore: cast_nullable_to_non_nullable
              as String,
      attempts: null == attempts
          ? _value.attempts
          : attempts // ignore: cast_nullable_to_non_nullable
              as int,
      maxAttempts: null == maxAttempts
          ? _value.maxAttempts
          : maxAttempts // ignore: cast_nullable_to_non_nullable
              as int,
      lastError: freezed == lastError
          ? _value.lastError
          : lastError // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      syncedAt: freezed == syncedAt
          ? _value.syncedAt
          : syncedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      nextRetryAt: freezed == nextRetryAt
          ? _value.nextRetryAt
          : nextRetryAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SyncQueueItemImpl extends _SyncQueueItem {
  const _$SyncQueueItemImpl(
      {required this.id,
      required this.entityType,
      required this.entityId,
      required this.operation,
      required this.status,
      required this.payload,
      this.attempts = 0,
      this.maxAttempts = 3,
      this.lastError,
      required this.createdAt,
      this.syncedAt,
      this.nextRetryAt})
      : super._();

  factory _$SyncQueueItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$SyncQueueItemImplFromJson(json);

  @override
  final String id;
  @override
  final SyncEntityType entityType;
  @override
  final String entityId;
  @override
  final SyncOperationType operation;
  @override
  final SyncStatus status;
  @override
  final String payload;
  @override
  @JsonKey()
  final int attempts;
  @override
  @JsonKey()
  final int maxAttempts;
  @override
  final String? lastError;
  @override
  final DateTime createdAt;
  @override
  final DateTime? syncedAt;
  @override
  final DateTime? nextRetryAt;

  @override
  String toString() {
    return 'SyncQueueItem(id: $id, entityType: $entityType, entityId: $entityId, operation: $operation, status: $status, payload: $payload, attempts: $attempts, maxAttempts: $maxAttempts, lastError: $lastError, createdAt: $createdAt, syncedAt: $syncedAt, nextRetryAt: $nextRetryAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SyncQueueItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.entityType, entityType) ||
                other.entityType == entityType) &&
            (identical(other.entityId, entityId) ||
                other.entityId == entityId) &&
            (identical(other.operation, operation) ||
                other.operation == operation) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.payload, payload) || other.payload == payload) &&
            (identical(other.attempts, attempts) ||
                other.attempts == attempts) &&
            (identical(other.maxAttempts, maxAttempts) ||
                other.maxAttempts == maxAttempts) &&
            (identical(other.lastError, lastError) ||
                other.lastError == lastError) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.syncedAt, syncedAt) ||
                other.syncedAt == syncedAt) &&
            (identical(other.nextRetryAt, nextRetryAt) ||
                other.nextRetryAt == nextRetryAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      entityType,
      entityId,
      operation,
      status,
      payload,
      attempts,
      maxAttempts,
      lastError,
      createdAt,
      syncedAt,
      nextRetryAt);

  /// Create a copy of SyncQueueItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SyncQueueItemImplCopyWith<_$SyncQueueItemImpl> get copyWith =>
      __$$SyncQueueItemImplCopyWithImpl<_$SyncQueueItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SyncQueueItemImplToJson(
      this,
    );
  }
}

abstract class _SyncQueueItem extends SyncQueueItem {
  const factory _SyncQueueItem(
      {required final String id,
      required final SyncEntityType entityType,
      required final String entityId,
      required final SyncOperationType operation,
      required final SyncStatus status,
      required final String payload,
      final int attempts,
      final int maxAttempts,
      final String? lastError,
      required final DateTime createdAt,
      final DateTime? syncedAt,
      final DateTime? nextRetryAt}) = _$SyncQueueItemImpl;
  const _SyncQueueItem._() : super._();

  factory _SyncQueueItem.fromJson(Map<String, dynamic> json) =
      _$SyncQueueItemImpl.fromJson;

  @override
  String get id;
  @override
  SyncEntityType get entityType;
  @override
  String get entityId;
  @override
  SyncOperationType get operation;
  @override
  SyncStatus get status;
  @override
  String get payload;
  @override
  int get attempts;
  @override
  int get maxAttempts;
  @override
  String? get lastError;
  @override
  DateTime get createdAt;
  @override
  DateTime? get syncedAt;
  @override
  DateTime? get nextRetryAt;

  /// Create a copy of SyncQueueItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SyncQueueItemImplCopyWith<_$SyncQueueItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SyncConflict _$SyncConflictFromJson(Map<String, dynamic> json) {
  return _SyncConflict.fromJson(json);
}

/// @nodoc
mixin _$SyncConflict {
  String get id => throw _privateConstructorUsedError;
  SyncEntityType get entityType => throw _privateConstructorUsedError;
  String get entityId => throw _privateConstructorUsedError;
  Map<String, dynamic> get localValue => throw _privateConstructorUsedError;
  Map<String, dynamic> get serverValue => throw _privateConstructorUsedError;
  DateTime get detectedAt => throw _privateConstructorUsedError;
  bool get isResolved => throw _privateConstructorUsedError;
  String? get resolution => throw _privateConstructorUsedError;
  DateTime? get resolvedAt => throw _privateConstructorUsedError;

  /// Serializes this SyncConflict to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SyncConflict
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SyncConflictCopyWith<SyncConflict> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SyncConflictCopyWith<$Res> {
  factory $SyncConflictCopyWith(
          SyncConflict value, $Res Function(SyncConflict) then) =
      _$SyncConflictCopyWithImpl<$Res, SyncConflict>;
  @useResult
  $Res call(
      {String id,
      SyncEntityType entityType,
      String entityId,
      Map<String, dynamic> localValue,
      Map<String, dynamic> serverValue,
      DateTime detectedAt,
      bool isResolved,
      String? resolution,
      DateTime? resolvedAt});
}

/// @nodoc
class _$SyncConflictCopyWithImpl<$Res, $Val extends SyncConflict>
    implements $SyncConflictCopyWith<$Res> {
  _$SyncConflictCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SyncConflict
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? entityType = null,
    Object? entityId = null,
    Object? localValue = null,
    Object? serverValue = null,
    Object? detectedAt = null,
    Object? isResolved = null,
    Object? resolution = freezed,
    Object? resolvedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      entityType: null == entityType
          ? _value.entityType
          : entityType // ignore: cast_nullable_to_non_nullable
              as SyncEntityType,
      entityId: null == entityId
          ? _value.entityId
          : entityId // ignore: cast_nullable_to_non_nullable
              as String,
      localValue: null == localValue
          ? _value.localValue
          : localValue // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      serverValue: null == serverValue
          ? _value.serverValue
          : serverValue // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      detectedAt: null == detectedAt
          ? _value.detectedAt
          : detectedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isResolved: null == isResolved
          ? _value.isResolved
          : isResolved // ignore: cast_nullable_to_non_nullable
              as bool,
      resolution: freezed == resolution
          ? _value.resolution
          : resolution // ignore: cast_nullable_to_non_nullable
              as String?,
      resolvedAt: freezed == resolvedAt
          ? _value.resolvedAt
          : resolvedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SyncConflictImplCopyWith<$Res>
    implements $SyncConflictCopyWith<$Res> {
  factory _$$SyncConflictImplCopyWith(
          _$SyncConflictImpl value, $Res Function(_$SyncConflictImpl) then) =
      __$$SyncConflictImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      SyncEntityType entityType,
      String entityId,
      Map<String, dynamic> localValue,
      Map<String, dynamic> serverValue,
      DateTime detectedAt,
      bool isResolved,
      String? resolution,
      DateTime? resolvedAt});
}

/// @nodoc
class __$$SyncConflictImplCopyWithImpl<$Res>
    extends _$SyncConflictCopyWithImpl<$Res, _$SyncConflictImpl>
    implements _$$SyncConflictImplCopyWith<$Res> {
  __$$SyncConflictImplCopyWithImpl(
      _$SyncConflictImpl _value, $Res Function(_$SyncConflictImpl) _then)
      : super(_value, _then);

  /// Create a copy of SyncConflict
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? entityType = null,
    Object? entityId = null,
    Object? localValue = null,
    Object? serverValue = null,
    Object? detectedAt = null,
    Object? isResolved = null,
    Object? resolution = freezed,
    Object? resolvedAt = freezed,
  }) {
    return _then(_$SyncConflictImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      entityType: null == entityType
          ? _value.entityType
          : entityType // ignore: cast_nullable_to_non_nullable
              as SyncEntityType,
      entityId: null == entityId
          ? _value.entityId
          : entityId // ignore: cast_nullable_to_non_nullable
              as String,
      localValue: null == localValue
          ? _value._localValue
          : localValue // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      serverValue: null == serverValue
          ? _value._serverValue
          : serverValue // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      detectedAt: null == detectedAt
          ? _value.detectedAt
          : detectedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isResolved: null == isResolved
          ? _value.isResolved
          : isResolved // ignore: cast_nullable_to_non_nullable
              as bool,
      resolution: freezed == resolution
          ? _value.resolution
          : resolution // ignore: cast_nullable_to_non_nullable
              as String?,
      resolvedAt: freezed == resolvedAt
          ? _value.resolvedAt
          : resolvedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SyncConflictImpl implements _SyncConflict {
  const _$SyncConflictImpl(
      {required this.id,
      required this.entityType,
      required this.entityId,
      required final Map<String, dynamic> localValue,
      required final Map<String, dynamic> serverValue,
      required this.detectedAt,
      this.isResolved = false,
      this.resolution,
      this.resolvedAt})
      : _localValue = localValue,
        _serverValue = serverValue;

  factory _$SyncConflictImpl.fromJson(Map<String, dynamic> json) =>
      _$$SyncConflictImplFromJson(json);

  @override
  final String id;
  @override
  final SyncEntityType entityType;
  @override
  final String entityId;
  final Map<String, dynamic> _localValue;
  @override
  Map<String, dynamic> get localValue {
    if (_localValue is EqualUnmodifiableMapView) return _localValue;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_localValue);
  }

  final Map<String, dynamic> _serverValue;
  @override
  Map<String, dynamic> get serverValue {
    if (_serverValue is EqualUnmodifiableMapView) return _serverValue;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_serverValue);
  }

  @override
  final DateTime detectedAt;
  @override
  @JsonKey()
  final bool isResolved;
  @override
  final String? resolution;
  @override
  final DateTime? resolvedAt;

  @override
  String toString() {
    return 'SyncConflict(id: $id, entityType: $entityType, entityId: $entityId, localValue: $localValue, serverValue: $serverValue, detectedAt: $detectedAt, isResolved: $isResolved, resolution: $resolution, resolvedAt: $resolvedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SyncConflictImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.entityType, entityType) ||
                other.entityType == entityType) &&
            (identical(other.entityId, entityId) ||
                other.entityId == entityId) &&
            const DeepCollectionEquality()
                .equals(other._localValue, _localValue) &&
            const DeepCollectionEquality()
                .equals(other._serverValue, _serverValue) &&
            (identical(other.detectedAt, detectedAt) ||
                other.detectedAt == detectedAt) &&
            (identical(other.isResolved, isResolved) ||
                other.isResolved == isResolved) &&
            (identical(other.resolution, resolution) ||
                other.resolution == resolution) &&
            (identical(other.resolvedAt, resolvedAt) ||
                other.resolvedAt == resolvedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      entityType,
      entityId,
      const DeepCollectionEquality().hash(_localValue),
      const DeepCollectionEquality().hash(_serverValue),
      detectedAt,
      isResolved,
      resolution,
      resolvedAt);

  /// Create a copy of SyncConflict
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SyncConflictImplCopyWith<_$SyncConflictImpl> get copyWith =>
      __$$SyncConflictImplCopyWithImpl<_$SyncConflictImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SyncConflictImplToJson(
      this,
    );
  }
}

abstract class _SyncConflict implements SyncConflict {
  const factory _SyncConflict(
      {required final String id,
      required final SyncEntityType entityType,
      required final String entityId,
      required final Map<String, dynamic> localValue,
      required final Map<String, dynamic> serverValue,
      required final DateTime detectedAt,
      final bool isResolved,
      final String? resolution,
      final DateTime? resolvedAt}) = _$SyncConflictImpl;

  factory _SyncConflict.fromJson(Map<String, dynamic> json) =
      _$SyncConflictImpl.fromJson;

  @override
  String get id;
  @override
  SyncEntityType get entityType;
  @override
  String get entityId;
  @override
  Map<String, dynamic> get localValue;
  @override
  Map<String, dynamic> get serverValue;
  @override
  DateTime get detectedAt;
  @override
  bool get isResolved;
  @override
  String? get resolution;
  @override
  DateTime? get resolvedAt;

  /// Create a copy of SyncConflict
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SyncConflictImplCopyWith<_$SyncConflictImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
