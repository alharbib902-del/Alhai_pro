// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'paginated.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Paginated<T> _$PaginatedFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object?) fromJsonT,
) {
  return _Paginated<T>.fromJson(json, fromJsonT);
}

/// @nodoc
mixin _$Paginated<T> {
  /// List of items for current page
  List<T> get items => throw _privateConstructorUsedError;

  /// Current page number (1-indexed)
  int get page => throw _privateConstructorUsedError;

  /// Items per page limit
  int get limit => throw _privateConstructorUsedError;

  /// Total items count (if available from API)
  int? get total => throw _privateConstructorUsedError;

  /// Whether more pages exist
  bool get hasMore => throw _privateConstructorUsedError;

  /// Serializes this Paginated to a JSON map.
  Map<String, dynamic> toJson(Object? Function(T) toJsonT) =>
      throw _privateConstructorUsedError;

  /// Create a copy of Paginated
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PaginatedCopyWith<T, Paginated<T>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaginatedCopyWith<T, $Res> {
  factory $PaginatedCopyWith(
    Paginated<T> value,
    $Res Function(Paginated<T>) then,
  ) = _$PaginatedCopyWithImpl<T, $Res, Paginated<T>>;
  @useResult
  $Res call({List<T> items, int page, int limit, int? total, bool hasMore});
}

/// @nodoc
class _$PaginatedCopyWithImpl<T, $Res, $Val extends Paginated<T>>
    implements $PaginatedCopyWith<T, $Res> {
  _$PaginatedCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Paginated
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? page = null,
    Object? limit = null,
    Object? total = freezed,
    Object? hasMore = null,
  }) {
    return _then(
      _value.copyWith(
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<T>,
            page: null == page
                ? _value.page
                : page // ignore: cast_nullable_to_non_nullable
                      as int,
            limit: null == limit
                ? _value.limit
                : limit // ignore: cast_nullable_to_non_nullable
                      as int,
            total: freezed == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                      as int?,
            hasMore: null == hasMore
                ? _value.hasMore
                : hasMore // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PaginatedImplCopyWith<T, $Res>
    implements $PaginatedCopyWith<T, $Res> {
  factory _$$PaginatedImplCopyWith(
    _$PaginatedImpl<T> value,
    $Res Function(_$PaginatedImpl<T>) then,
  ) = __$$PaginatedImplCopyWithImpl<T, $Res>;
  @override
  @useResult
  $Res call({List<T> items, int page, int limit, int? total, bool hasMore});
}

/// @nodoc
class __$$PaginatedImplCopyWithImpl<T, $Res>
    extends _$PaginatedCopyWithImpl<T, $Res, _$PaginatedImpl<T>>
    implements _$$PaginatedImplCopyWith<T, $Res> {
  __$$PaginatedImplCopyWithImpl(
    _$PaginatedImpl<T> _value,
    $Res Function(_$PaginatedImpl<T>) _then,
  ) : super(_value, _then);

  /// Create a copy of Paginated
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? page = null,
    Object? limit = null,
    Object? total = freezed,
    Object? hasMore = null,
  }) {
    return _then(
      _$PaginatedImpl<T>(
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<T>,
        page: null == page
            ? _value.page
            : page // ignore: cast_nullable_to_non_nullable
                  as int,
        limit: null == limit
            ? _value.limit
            : limit // ignore: cast_nullable_to_non_nullable
                  as int,
        total: freezed == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as int?,
        hasMore: null == hasMore
            ? _value.hasMore
            : hasMore // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable(genericArgumentFactories: true)
class _$PaginatedImpl<T> implements _Paginated<T> {
  const _$PaginatedImpl({
    required final List<T> items,
    required this.page,
    required this.limit,
    this.total,
    this.hasMore = false,
  }) : _items = items;

  factory _$PaginatedImpl.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) => _$$PaginatedImplFromJson(json, fromJsonT);

  /// List of items for current page
  final List<T> _items;

  /// List of items for current page
  @override
  List<T> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  /// Current page number (1-indexed)
  @override
  final int page;

  /// Items per page limit
  @override
  final int limit;

  /// Total items count (if available from API)
  @override
  final int? total;

  /// Whether more pages exist
  @override
  @JsonKey()
  final bool hasMore;

  @override
  String toString() {
    return 'Paginated<$T>(items: $items, page: $page, limit: $limit, total: $total, hasMore: $hasMore)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaginatedImpl<T> &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.limit, limit) || other.limit == limit) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_items),
    page,
    limit,
    total,
    hasMore,
  );

  /// Create a copy of Paginated
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaginatedImplCopyWith<T, _$PaginatedImpl<T>> get copyWith =>
      __$$PaginatedImplCopyWithImpl<T, _$PaginatedImpl<T>>(this, _$identity);

  @override
  Map<String, dynamic> toJson(Object? Function(T) toJsonT) {
    return _$$PaginatedImplToJson<T>(this, toJsonT);
  }
}

abstract class _Paginated<T> implements Paginated<T> {
  const factory _Paginated({
    required final List<T> items,
    required final int page,
    required final int limit,
    final int? total,
    final bool hasMore,
  }) = _$PaginatedImpl<T>;

  factory _Paginated.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) = _$PaginatedImpl<T>.fromJson;

  /// List of items for current page
  @override
  List<T> get items;

  /// Current page number (1-indexed)
  @override
  int get page;

  /// Items per page limit
  @override
  int get limit;

  /// Total items count (if available from API)
  @override
  int? get total;

  /// Whether more pages exist
  @override
  bool get hasMore;

  /// Create a copy of Paginated
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaginatedImplCopyWith<T, _$PaginatedImpl<T>> get copyWith =>
      throw _privateConstructorUsedError;
}
