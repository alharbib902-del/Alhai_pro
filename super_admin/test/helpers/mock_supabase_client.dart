import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

// ---------------------------------------------------------------------------
// Fake Supabase client & query builders for unit tests.
//
// No external mocking library is required (the project has no mocktail /
// mockito dependency). Instead we build a thin fake that records the
// operations requested on each query chain and returns pre-configured data.
//
// Usage:
//   final mock = MockSupabaseClient();
//   mock.setResponse('stores', [{'id': '1', 'name': 'Test'}]);
//   final ds = SAStoresDatasource(mock.client as dynamic);
// ---------------------------------------------------------------------------

/// A single recorded query operation (e.g. `.eq('id', '1')`).
class QueryOp {
  final String method;
  final List<dynamic> args;

  const QueryOp(this.method, [this.args = const []]);

  @override
  String toString() => '$method(${args.join(', ')})';
}

/// Lightweight mock for [SupabaseClient].
///
/// Supports the full postgrest chain used by the super_admin datasources:
///   .from('table').select(...) / .insert(...) / .update(...) / .delete()
///   .eq() / .neq() / .inFilter() / .or() / .gte() / .lte() / .lt() / .gt()
///   .order() / .limit() / .range() / .single() / .maybeSingle()
///   .count(CountOption.exact)
///   .rpc('name', params: {})
class MockSupabaseClient {
  final Map<String, _TableConfig> _tables = {};
  final Map<String, _TableConfig> _rpcs = {};

  /// All queries that were executed, keyed by table name.
  final Map<String, List<List<QueryOp>>> queryLog = {};

  // ---------- Configuration API ----------

  /// Set the data returned when querying [table].
  ///
  /// [data] is typically a `List<Map<String, dynamic>>` for selects
  /// or a `Map<String, dynamic>` for `.single()`.
  void setResponse(String table, dynamic data) {
    _configFor(table).data = data;
  }

  /// Set the count value returned for `.count(CountOption.exact)` queries.
  void setCount(String table, int count) {
    _configFor(table).countValue = count;
  }

  /// Make all queries to [table] throw [error].
  void setError(String table, Object error) {
    _configFor(table).error = error;
  }

  /// Set the data returned by `.rpc(name)`.
  void setRpcResponse(String name, dynamic data) {
    _rpcConfigFor(name).data = data;
  }

  /// Make `.rpc(name)` throw [error].
  void setRpcError(String name, Object error) {
    _rpcConfigFor(name).error = error;
  }

  /// Clear all configured responses and query logs.
  void reset() {
    _tables.clear();
    _rpcs.clear();
    queryLog.clear();
  }

  // ---------- Client facade ----------

  /// Returns a fake that quacks like [SupabaseClient].
  ///
  /// Pass it where `SupabaseClient` is expected using `as dynamic`:
  /// ```dart
  /// final ds = MyDatasource(mock.client as dynamic);
  /// ```
  FakeSupabaseClient get client => FakeSupabaseClient._(this);

  _TableConfig _configFor(String table) =>
      _tables.putIfAbsent(table, _TableConfig.new);

  _TableConfig _rpcConfigFor(String name) =>
      _rpcs.putIfAbsent(name, _TableConfig.new);

  void _logQuery(String table, List<QueryOp> ops) {
    queryLog.putIfAbsent(table, () => []).add(ops);
  }
}

// ---------------------------------------------------------------------------
// Internal config
// ---------------------------------------------------------------------------

class _TableConfig {
  dynamic data;
  int? countValue;
  Object? error;
}

// ---------------------------------------------------------------------------
// Fake implementations
// ---------------------------------------------------------------------------

/// Drop-in replacement for [SupabaseClient].
///
/// Datasources accept `SupabaseClient` in their constructor. Because we can't
/// easily construct a real one without a URL + key, we instead create a class
/// that exposes the same `.from()` and `.rpc()` surface and can be passed
/// via `as dynamic`.
class FakeSupabaseClient {
  final MockSupabaseClient _mock;

  FakeSupabaseClient._(this._mock);

  /// Mimics `SupabaseClient.from(table)`.
  FakeQueryBuilder from(String table) {
    return FakeQueryBuilder._(table, _mock);
  }

  /// Mimics `SupabaseClient.rpc(fn, params: ...)`.
  Future<dynamic> rpc(String fn, {Map<String, dynamic>? params}) async {
    final cfg = _mock._rpcConfigFor(fn);
    _mock._logQuery('rpc:$fn', [
      QueryOp('rpc', [fn, params]),
    ]);
    if (cfg.error != null) throw cfg.error!;
    return cfg.data;
  }
}

/// Fake for the query builder returned by `.from()`.
class FakeQueryBuilder {
  final String _table;
  final MockSupabaseClient _mock;

  FakeQueryBuilder._(this._table, this._mock);

  FakeFilterBuilder select([String columns = '*']) {
    return FakeFilterBuilder._(_table, _mock, [
      QueryOp('select', [columns]),
    ]);
  }

  FakeFilterBuilder insert(Object values, {bool defaultToNull = true}) {
    return FakeFilterBuilder._(_table, _mock, [
      QueryOp('insert', [values]),
    ]);
  }

  FakeFilterBuilder update(Object values) {
    return FakeFilterBuilder._(_table, _mock, [
      QueryOp('update', [values]),
    ]);
  }

  FakeFilterBuilder delete() {
    return FakeFilterBuilder._(_table, _mock, [QueryOp('delete')]);
  }

  FakeFilterBuilder upsert(Object values, {String? onConflict}) {
    return FakeFilterBuilder._(_table, _mock, [
      QueryOp('upsert', [values]),
    ]);
  }
}

/// Fake for the chained filter / transform builder.
///
/// Every filter method returns `this` so chaining works.
/// Awaiting (or calling `.single()` / `.maybeSingle()`) resolves the data.
class FakeFilterBuilder implements Future<dynamic> {
  final String _table;
  final MockSupabaseClient _mock;
  final List<QueryOp> _ops;

  FakeFilterBuilder._(this._table, this._mock, this._ops);

  // ---- Filters ----

  FakeFilterBuilder eq(String column, Object value) {
    _ops.add(QueryOp('eq', [column, value]));
    return this;
  }

  FakeFilterBuilder neq(String column, Object value) {
    _ops.add(QueryOp('neq', [column, value]));
    return this;
  }

  FakeFilterBuilder gt(String column, Object value) {
    _ops.add(QueryOp('gt', [column, value]));
    return this;
  }

  FakeFilterBuilder gte(String column, Object value) {
    _ops.add(QueryOp('gte', [column, value]));
    return this;
  }

  FakeFilterBuilder lt(String column, Object value) {
    _ops.add(QueryOp('lt', [column, value]));
    return this;
  }

  FakeFilterBuilder lte(String column, Object value) {
    _ops.add(QueryOp('lte', [column, value]));
    return this;
  }

  FakeFilterBuilder inFilter(String column, List<Object> values) {
    _ops.add(QueryOp('inFilter', [column, values]));
    return this;
  }

  FakeFilterBuilder or(String filters, {String? referencedTable}) {
    _ops.add(QueryOp('or', [filters, referencedTable]));
    return this;
  }

  FakeFilterBuilder isFilter(String column, Object? value) {
    _ops.add(QueryOp('isFilter', [column, value]));
    return this;
  }

  FakeFilterBuilder ilike(String column, String pattern) {
    _ops.add(QueryOp('ilike', [column, pattern]));
    return this;
  }

  FakeFilterBuilder like(String column, String pattern) {
    _ops.add(QueryOp('like', [column, pattern]));
    return this;
  }

  FakeFilterBuilder match(Map<String, Object> query) {
    _ops.add(QueryOp('match', [query]));
    return this;
  }

  // ---- Transforms ----

  FakeFilterBuilder order(String column, {bool ascending = true}) {
    _ops.add(QueryOp('order', [column, ascending]));
    return this;
  }

  FakeFilterBuilder limit(int count) {
    _ops.add(QueryOp('limit', [count]));
    return this;
  }

  FakeFilterBuilder range(int from, int to) {
    _ops.add(QueryOp('range', [from, to]));
    return this;
  }

  // ---- Select (chained after insert/update to request return data) ----

  FakeFilterBuilder select([String columns = '*']) {
    _ops.add(QueryOp('select', [columns]));
    return this;
  }

  // ---- Terminators ----

  Future<Map<String, dynamic>> single() async {
    _ops.add(QueryOp('single'));
    final result = await _resolve();
    if (result is List && result.isNotEmpty) {
      return result.first as Map<String, dynamic>;
    }
    if (result is Map<String, dynamic>) return result;
    return <String, dynamic>{};
  }

  Future<Map<String, dynamic>?> maybeSingle() async {
    _ops.add(QueryOp('maybeSingle'));
    final result = await _resolve();
    if (result is List) {
      return result.isEmpty ? null : result.first as Map<String, dynamic>;
    }
    if (result is Map<String, dynamic>) return result;
    return null;
  }

  /// Mimics `.count(CountOption.exact)`.
  FakeCountBuilder count([CountOption option = CountOption.exact]) {
    _ops.add(QueryOp('count', [option]));
    return FakeCountBuilder._(_table, _mock, _ops);
  }

  // ---- Future implementation (for await on the chain) ----

  Future<dynamic> _resolve() async {
    _mock._logQuery(_table, List.unmodifiable(_ops));
    final cfg = _mock._configFor(_table);
    if (cfg.error != null) throw cfg.error!;
    return cfg.data ?? <dynamic>[];
  }

  @override
  Stream<dynamic> asStream() => _resolve().asStream();

  @override
  Future<dynamic> catchError(
    Function onError, {
    bool Function(Object error)? test,
  }) => _resolve().catchError(onError, test: test);

  @override
  Future<R> then<R>(
    FutureOr<R> Function(dynamic value) onValue, {
    Function? onError,
  }) => _resolve().then(onValue, onError: onError);

  @override
  Future<dynamic> timeout(
    Duration timeLimit, {
    FutureOr<dynamic> Function()? onTimeout,
  }) => _resolve().timeout(timeLimit, onTimeout: onTimeout);

  @override
  Future<dynamic> whenComplete(FutureOr<void> Function() action) =>
      _resolve().whenComplete(action);
}

/// Fake result of `.count(CountOption.exact)`.
///
/// Supabase returns an object with a `.count` property when using
/// `CountOption.exact`. This fake provides that same interface.
class FakeCountBuilder implements Future<dynamic> {
  final String _table;
  final MockSupabaseClient _mock;
  final List<QueryOp> _ops;

  FakeCountBuilder._(this._table, this._mock, this._ops);

  Future<FakeCountResult> _resolve() async {
    _mock._logQuery(_table, List.unmodifiable(_ops));
    final cfg = _mock._configFor(_table);
    if (cfg.error != null) throw cfg.error!;
    final data = cfg.data ?? <dynamic>[];
    final countValue = cfg.countValue ?? (data is List ? data.length : 0);
    return FakeCountResult(data: data, count: countValue);
  }

  // ---- Filters (can be chained before await) ----

  FakeCountBuilder eq(String column, Object value) {
    _ops.add(QueryOp('eq', [column, value]));
    return this;
  }

  FakeCountBuilder neq(String column, Object value) {
    _ops.add(QueryOp('neq', [column, value]));
    return this;
  }

  FakeCountBuilder gte(String column, Object value) {
    _ops.add(QueryOp('gte', [column, value]));
    return this;
  }

  FakeCountBuilder inFilter(String column, List<Object> values) {
    _ops.add(QueryOp('inFilter', [column, values]));
    return this;
  }

  FakeCountBuilder or(String filters, {String? referencedTable}) {
    _ops.add(QueryOp('or', [filters, referencedTable]));
    return this;
  }

  // ---- Future implementation ----

  @override
  Stream<dynamic> asStream() => _resolve().asStream();

  @override
  Future<dynamic> catchError(
    Function onError, {
    bool Function(Object error)? test,
  }) => _resolve().catchError(onError, test: test);

  @override
  Future<R> then<R>(
    FutureOr<R> Function(dynamic value) onValue, {
    Function? onError,
  }) => _resolve().then(onValue, onError: onError);

  @override
  Future<dynamic> timeout(
    Duration timeLimit, {
    FutureOr<dynamic> Function()? onTimeout,
  }) => _resolve()
      .then<dynamic>((v) => v)
      .timeout(timeLimit, onTimeout: onTimeout);

  @override
  Future<dynamic> whenComplete(FutureOr<void> Function() action) =>
      _resolve().then<dynamic>((v) => v).whenComplete(action);
}

/// The resolved result of a `.count(CountOption.exact)` query.
class FakeCountResult {
  final dynamic data;
  final int count;

  const FakeCountResult({this.data, required this.count});
}
