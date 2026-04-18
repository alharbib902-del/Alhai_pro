/// Shared utilities for cleaning sync payloads before sending to Supabase.
///
/// Consolidates the duplicated `_cleanPayload` logic from:
/// - SyncApiService
/// - OrgSyncService
/// - PushStrategy
/// - BidirectionalStrategy

/// Removes local-only fields from a sync payload before sending to Supabase.
///
/// This removes:
/// - `syncedAt` / `synced_at` (local sync tracking fields)
/// - `items` (embedded items that are synced via their own tables, e.g. sale_items)
/// - Per-table local-only columns (see [_localOnlyColumns])
///
/// If [removeItems] is false, the `items` field is kept (used by OrgSyncService
/// and SyncApiService which do not embed items).
Map<String, dynamic> cleanSyncPayload(
  Map<String, dynamic> payload, {
  bool removeItems = true,
  String? tableName,
}) {
  final clean = Map<String, dynamic>.from(payload);
  clean.remove('syncedAt');
  clean.remove('synced_at');
  if (removeItems) {
    clean.remove('items');
  }
  // Strip columns that exist in Drift but not in Supabase for this table
  if (tableName != null) {
    final excluded = _localOnlyColumns[tableName];
    if (excluded != null) {
      for (final col in excluded) {
        clean.remove(col);
      }
    }
  }
  return clean;
}

/// Columns that exist in the local Drift schema but NOT in Supabase.
///
/// These are stripped from push payloads by [cleanSyncPayload] to prevent
/// Supabase "column does not exist" errors. Add entries here when Drift has
/// a column that Supabase lacks (rather than removing the column from Drift,
/// which would require a local migration).
// Re-verified against live Supabase 2026-04-18 (migration v44):
// sales.shift_id, sales.deleted_at, returns.deleted_at now EXIST in Supabase,
// so no stripping is needed. Kept as an empty map so future Drift-only
// columns can be added here without re-plumbing callers.
const Map<String, Set<String>> _localOnlyColumns = {};

/// Converts map keys from camelCase to snake_case for Supabase compatibility.
Map<String, dynamic> toSnakeCase(Map<String, dynamic> map) {
  return map.map((key, value) {
    final snakeKey = _camelToSnake(key);
    if (value is Map<String, dynamic>) {
      return MapEntry(snakeKey, toSnakeCase(value));
    }
    return MapEntry(snakeKey, value);
  });
}

String _camelToSnake(String input) {
  return input.replaceAllMapped(
    RegExp(r'[A-Z]'),
    (match) => '_${match.group(0)!.toLowerCase()}',
  );
}

// ---------------------------------------------------------------------------
// M36: Column name mapping between Drift (local) and Supabase (remote)
// ---------------------------------------------------------------------------

/// Column renames: local Drift name -> Supabase remote name.
///
/// The Drift ORM generates snake_case column names from Dart camelCase
/// getters, but the Supabase SQL schema uses different names for some
/// columns. This map defines the renames per table.
///
/// Verified against LIVE Supabase schema 2026-04-04: all Drift column
/// names match Supabase exactly for the vast majority of tables.
///
/// EXCEPTIONS (daily_summaries, added 2026-04-17 after v39):
/// - Drift `total_sales`   (INT  count) -> Supabase `total_sales_count`
///   (INT added in v29). Without this rename a push would stuff a count
///   into the Supabase DOUBLE `total_sales` column — which is money.
/// - Drift `total_sales_amount` (REAL money) -> Supabase `total_sales`
///   (DOUBLE money from v25). Drift's `_amount` suffix is the money
///   field; Supabase's canonical money column is `total_sales`.
/// - Drift `total_refunds` (INT count) -> Supabase `total_refunds_count`
///   (INT added in v39, this repo). See migration
///   supabase/migrations/20260417_v39_daily_summaries_count_column.sql.
/// - `total_refunds_amount` stays as-is (name + money semantic agree).
/// - `total_orders` / `total_orders_amount` agree between Drift and
///   Supabase (no rename needed).
const Map<String, Map<String, String>> _localToRemoteColumnMap = {
  'daily_summaries': {
    'total_sales': 'total_sales_count',
    'total_sales_amount': 'total_sales',
    'total_refunds': 'total_refunds_count',
  },
};

/// Reverse map: Supabase remote name -> local Drift name.
/// Built lazily from [_localToRemoteColumnMap].
final Map<String, Map<String, String>> _remoteToLocalColumnMap = () {
  final result = <String, Map<String, String>>{};
  for (final entry in _localToRemoteColumnMap.entries) {
    final reversed = <String, String>{};
    for (final col in entry.value.entries) {
      reversed[col.value] = col.key;
    }
    result[entry.key] = reversed;
  }
  return result;
}();

/// Renames local Drift column names to Supabase column names in [payload].
///
/// Call this before sending a payload to Supabase (push / upsert).
/// Only affects tables listed in the column map; other tables pass through
/// unchanged.
Map<String, dynamic> mapColumnsToRemote(
  String tableName,
  Map<String, dynamic> payload,
) {
  final renames = _localToRemoteColumnMap[tableName];
  if (renames == null || renames.isEmpty) return payload;
  return _renameKeys(payload, renames);
}

/// Renames Supabase column names to local Drift column names in [payload].
///
/// Call this after receiving a payload from Supabase (pull / realtime).
/// Only affects tables listed in the column map; other tables pass through
/// unchanged.
Map<String, dynamic> mapColumnsToLocal(
  String tableName,
  Map<String, dynamic> payload,
) {
  final renames = _remoteToLocalColumnMap[tableName];
  if (renames == null || renames.isEmpty) return payload;
  return _renameKeys(payload, renames);
}

/// Batch variant of [mapColumnsToRemote].
List<Map<String, dynamic>> batchMapColumnsToRemote(
  String tableName,
  List<Map<String, dynamic>> records,
) => records.map((r) => mapColumnsToRemote(tableName, r)).toList();

/// Batch variant of [mapColumnsToLocal].
List<Map<String, dynamic>> batchMapColumnsToLocal(
  String tableName,
  List<Map<String, dynamic>> records,
) => records.map((r) => mapColumnsToLocal(tableName, r)).toList();

/// Renames keys in [map] according to [renames].
Map<String, dynamic> _renameKeys(
  Map<String, dynamic> map,
  Map<String, String> renames,
) {
  final result = <String, dynamic>{};
  for (final entry in map.entries) {
    final newKey = renames[entry.key] ?? entry.key;
    result[newKey] = entry.value;
  }
  return result;
}
