import 'dart:convert';

/// Schema conversion utilities for mapping between Supabase and Drift types.
///
/// Supabase uses UUID, ENUM, JSONB, DECIMAL types while
/// Drift/SQLite uses TEXT, REAL for all of these.
class SchemaConverter {
  SchemaConverter._();

  // ============================================
  // ID Conversions
  // ============================================

  /// Supabase UUID (String) → Drift TEXT (String)
  /// No conversion needed - both are String representations.
  static String uuidToText(String uuid) => uuid;

  /// Drift TEXT → Supabase UUID (validates format)
  static String textToUuid(String text) {
    final uuidPattern = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    if (!uuidPattern.hasMatch(text)) {
      throw FormatException('Invalid UUID format: $text');
    }
    return text;
  }

  // ============================================
  // Quantity Conversions
  // ============================================

  /// Supabase INT → Drift REAL
  static double intToReal(int value) => value.toDouble();

  /// Drift REAL → Supabase INT (rounds)
  static int realToInt(double value) => value.round();

  // ============================================
  // JSON Conversions
  // ============================================

  /// Supabase JSONB (Map) → Drift TEXT (JSON string)
  static String? jsonbToText(dynamic jsonb) {
    if (jsonb == null) return null;
    if (jsonb is String) return jsonb;
    return jsonEncode(jsonb);
  }

  /// Drift TEXT (JSON string) → Supabase JSONB (Map)
  static Map<String, dynamic>? textToJsonb(String? text) {
    if (text == null || text.isEmpty) return null;
    try {
      final decoded = jsonDecode(text);
      if (decoded is Map<String, dynamic>) return decoded;
      return null;
    } catch (_) {
      return null;
    }
  }

  // ============================================
  // Decimal Conversions
  // ============================================

  /// Supabase DECIMAL → Drift REAL
  static double decimalToReal(dynamic decimal) {
    if (decimal is double) return decimal;
    if (decimal is int) return decimal.toDouble();
    if (decimal is String) return double.tryParse(decimal) ?? 0.0;
    return 0.0;
  }

  /// Drift REAL → Supabase DECIMAL (2 decimal places)
  static double realToDecimal(double value) {
    return (value * 100).round() / 100;
  }

  // ============================================
  // Enum Conversions
  // ============================================

  /// Validate a string value against allowed enum values
  static String validateEnum(String value, Set<String> allowed,
      {String? fallback}) {
    if (allowed.contains(value)) return value;
    if (fallback != null) return fallback;
    throw ArgumentError('Invalid enum value: $value. Allowed: $allowed');
  }

  // Known Supabase ENUMs
  static const orderStatusValues = {
    'created', 'confirmed', 'preparing', 'ready',
    'delivering', 'completed', 'cancelled', 'refunded',
  };

  static const paymentMethodValues = {
    'cash', 'card', 'bank_transfer', 'wallet', 'mixed',
  };

  static const userRoleValues = {
    'owner', 'admin', 'manager', 'cashier', 'driver', 'customer',
  };

  // ============================================
  // Timestamp Conversions
  // ============================================

  /// Supabase TIMESTAMPTZ (ISO string) → Drift DateTime
  static DateTime? timestampToDateTime(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is DateTime) return timestamp;
    if (timestamp is String) return DateTime.tryParse(timestamp);
    return null;
  }

  /// Drift DateTime → Supabase TIMESTAMPTZ (ISO string)
  static String? dateTimeToTimestamp(DateTime? dt) {
    return dt?.toUtc().toIso8601String();
  }

  // ============================================
  // Row Mapping Helpers
  // ============================================

  /// Convert a Supabase row to Drift-compatible map
  static Map<String, dynamic> supabaseToDrift(
    Map<String, dynamic> row, {
    Map<String, String>? columnMapping,
    Set<String>? jsonColumns,
    Set<String>? intToRealColumns,
  }) {
    final result = <String, dynamic>{};

    for (final entry in row.entries) {
      final key = columnMapping?[entry.key] ?? _snakeToCamel(entry.key);
      var value = entry.value;

      if (jsonColumns?.contains(entry.key) == true && value != null) {
        value = jsonbToText(value);
      }
      if (intToRealColumns?.contains(entry.key) == true && value is int) {
        value = value.toDouble();
      }

      result[key] = value;
    }

    return result;
  }

  /// Convert a Drift row to Supabase-compatible map
  static Map<String, dynamic> driftToSupabase(
    Map<String, dynamic> row, {
    Map<String, String>? columnMapping,
    Set<String>? jsonColumns,
    Set<String>? realToIntColumns,
  }) {
    final result = <String, dynamic>{};

    for (final entry in row.entries) {
      final key = columnMapping?[entry.key] ?? _camelToSnake(entry.key);
      var value = entry.value;

      if (jsonColumns?.contains(entry.key) == true && value is String) {
        value = textToJsonb(value);
      }
      if (realToIntColumns?.contains(entry.key) == true && value is double) {
        value = value.round();
      }
      if (value is DateTime) {
        value = dateTimeToTimestamp(value);
      }

      result[key] = value;
    }

    return result;
  }

  static String _snakeToCamel(String s) {
    final parts = s.split('_');
    if (parts.length == 1) return s;
    return parts.first +
        parts.skip(1).map((p) => p.isEmpty ? '' : '${p[0].toUpperCase()}${p.substring(1)}').join();
  }

  static String _camelToSnake(String s) {
    return s.replaceAllMapped(
      RegExp(r'[A-Z]'),
      (m) => '_${m.group(0)!.toLowerCase()}',
    );
  }
}
