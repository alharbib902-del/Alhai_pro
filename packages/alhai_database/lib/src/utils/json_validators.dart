import 'dart:convert';

/// Validates JSON column data before database insert/update.
///
/// Use these helpers to ensure JSON strings stored in TEXT columns
/// are well-formed before writing them to the database.
///
/// Example:
/// ```dart
/// final metadata = JsonColumnValidator.validateJsonMap(rawJson);
/// if (metadata == null) {
///   throw ArgumentError('Invalid metadata JSON');
/// }
/// ```
class JsonColumnValidator {
  JsonColumnValidator._();

  /// Validates that a JSON string is valid and returns the parsed
  /// [Map<String, dynamic>], or `null` if the input is null, empty,
  /// or not a valid JSON object.
  static Map<String, dynamic>? validateJsonMap(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return null;
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is Map<String, dynamic>) return decoded;
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Validates that a JSON string is a valid JSON array and returns the
  /// parsed [List<dynamic>], or `null` if the input is null, empty,
  /// or not a valid JSON array.
  static List<dynamic>? validateJsonList(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return null;
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is List) return decoded;
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Returns `true` if the JSON string is a valid JSON object (map).
  ///
  /// Useful for quick guard checks on metadata columns.
  static bool isValidMetadata(String? jsonString) {
    return validateJsonMap(jsonString) != null;
  }

  /// Returns `true` if the JSON string is a valid JSON array.
  ///
  /// Useful for quick guard checks on list-type JSON columns
  /// (e.g., stock transfer items, order items payload).
  static bool isValidJsonList(String? jsonString) {
    return validateJsonList(jsonString) != null;
  }

  /// Safely encodes a [Map] to a JSON string.
  /// Returns `null` if the map is null.
  static String? encodeMap(Map<String, dynamic>? map) {
    if (map == null) return null;
    return jsonEncode(map);
  }

  /// Safely encodes a [List] to a JSON string.
  /// Returns `null` if the list is null.
  static String? encodeList(List<dynamic>? list) {
    if (list == null) return null;
    return jsonEncode(list);
  }
}
