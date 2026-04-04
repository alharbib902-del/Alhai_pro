import 'dart:convert';

/// JSONB-to-Text conversion utility for sync operations.
///
/// Supabase stores certain fields as JSONB in PostgreSQL,
/// while Drift uses TextColumn in local SQLite.
class JsonColumnConverter {
  static final JsonColumnConverter instance = JsonColumnConverter._();
  JsonColumnConverter._();

  static const Map<String, Set<String>> _jsonbFields = {
    'roles': {'permissions'},
    'sync_queue': {'payload'},
    'audit_log': {'old_value', 'new_value'},
    'discounts': {'product_ids', 'category_ids'},
    'notifications': {'data'},
    'held_invoices': {'items'},
    'stock_takes': {'items'},
    'stock_transfers': {'items'},
    'promotions': {'rules'},
    'organizations': {'settings'},
    'subscriptions': {'features'},
    'pos_terminals': {'settings'},
  };

  bool isJsonbField(String tableName, String fieldName) =>
      _jsonbFields[tableName]?.contains(fieldName) ?? false;

  Set<String> getJsonbFields(String tableName) => _jsonbFields[tableName] ?? {};

  /// Local (Text) -> Remote (JSONB): parse JSON strings into objects
  Map<String, dynamic> toRemote(
    String tableName,
    Map<String, dynamic> payload,
  ) {
    final result = Map<String, dynamic>.from(payload);
    for (final field in getJsonbFields(tableName)) {
      if (result.containsKey(field) && result[field] is String) {
        result[field] = _parseJsonString(result[field] as String);
      }
    }
    return result;
  }

  /// Remote (JSONB) -> Local (Text): serialize objects to JSON strings
  Map<String, dynamic> toLocal(
    String tableName,
    Map<String, dynamic> payload,
  ) {
    final result = Map<String, dynamic>.from(payload);
    for (final field in getJsonbFields(tableName)) {
      if (result.containsKey(field) && result[field] != null) {
        result[field] = _toJsonString(result[field]);
      }
    }
    return result;
  }

  List<Map<String, dynamic>> batchToLocal(
    String tableName,
    List<Map<String, dynamic>> records,
  ) =>
      records.map((r) => toLocal(tableName, r)).toList();

  List<Map<String, dynamic>> batchToRemote(
    String tableName,
    List<Map<String, dynamic>> records,
  ) =>
      records.map((r) => toRemote(tableName, r)).toList();

  dynamic _parseJsonString(String value) {
    if (value.isEmpty) return value;
    try {
      final decoded = jsonDecode(value);
      if (decoded is Map || decoded is List) return decoded;
      return value;
    } catch (_) {
      return value;
    }
  }

  String _toJsonString(dynamic value) {
    if (value is String) return value;
    if (value is Map || value is List) return jsonEncode(value);
    return value.toString();
  }

  static bool isValidJson(String value) {
    try {
      jsonDecode(value);
      return true;
    } catch (_) {
      return false;
    }
  }

  static String mergeJsonStrings(String base, String override) {
    try {
      final baseObj = jsonDecode(base);
      final overrideObj = jsonDecode(override);
      if (baseObj is Map<String, dynamic> &&
          overrideObj is Map<String, dynamic>) {
        return jsonEncode(_deepMerge(baseObj, overrideObj));
      }
      return override;
    } catch (_) {
      return override;
    }
  }

  static Map<String, dynamic> _deepMerge(
    Map<String, dynamic> base,
    Map<String, dynamic> override,
  ) {
    final result = Map<String, dynamic>.from(base);
    for (final entry in override.entries) {
      if (result[entry.key] is Map<String, dynamic> &&
          entry.value is Map<String, dynamic>) {
        result[entry.key] = _deepMerge(
          result[entry.key] as Map<String, dynamic>,
          entry.value as Map<String, dynamic>,
        );
      } else {
        result[entry.key] = entry.value;
      }
    }
    return result;
  }

  static String normalizeJson(String value) {
    try {
      return jsonEncode(_sortKeys(jsonDecode(value)));
    } catch (_) {
      return value;
    }
  }

  static dynamic _sortKeys(dynamic value) {
    if (value is Map<String, dynamic>) {
      final sorted = <String, dynamic>{};
      for (final key in (value.keys.toList()..sort())) {
        sorted[key] = _sortKeys(value[key]);
      }
      return sorted;
    }
    if (value is List) return value.map(_sortKeys).toList();
    return value;
  }
}
