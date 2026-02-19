# Critical Code Quality Fixes Log

**Date:** 2026-02-15
**Dart Analyze Result:** No issues found

---

## Fix 1: Inverted Balance Colors

**File:** `lib/core/theme/app_colors.dart:346`
**Severity:** CRITICAL (Bug)
**Issue:** `getBalanceColor()` returned `debt` color for positive balances and `credit` color for negative — completely inverted.

**Before:**
```dart
static Color getBalanceColor(double balance) {
  if (balance > 0) return debt;   // WRONG: positive = debt color
  if (balance < 0) return credit; // WRONG: negative = credit color
  return textMuted;
}
```

**After:**
```dart
static Color getBalanceColor(double balance) {
  if (balance > 0) return credit; // FIXED: positive = credit color
  if (balance < 0) return debt;   // FIXED: negative = debt color
  return textMuted;
}
```

---

## Fix 2: Duplicate Identical Conditions

**File:** `lib/core/constants/breakpoints.dart:98-101`
**Severity:** CRITICAL (Dead code branch)
**Issue:** Two consecutive conditions were identical — `width < Breakpoints.mobileSmall` (360) was a subset of `width < Breakpoints.mobile` (600), both returning `2`. The first branch was redundant.

**Before:**
```dart
int getProductGridColumns(double width) {
  if (width < Breakpoints.mobileSmall) {
    return 2;
  } else if (width < Breakpoints.mobile) {
    return 2;
  } else if (width < Breakpoints.tablet) {
```

**After:**
```dart
int getProductGridColumns(double width) {
  if (width < Breakpoints.mobile) {
    return 2;
  } else if (width < Breakpoints.tablet) {
```

---

## Fix 3a: Unbounded Recursion in `_sanitizeContext()`

**File:** `lib/core/monitoring/production_logger.dart:343`
**Severity:** CRITICAL (Stack overflow risk)
**Issue:** Recursive call on nested `Map<String, dynamic>` with no depth limit. Deeply nested or circular-reference data would crash.

**Before:**
```dart
static Map<String, dynamic>? _sanitizeContext(Map<String, dynamic>? context) {
  if (context == null) return null;
  return context.map((key, value) {
    // ...
    if (value is Map<String, dynamic>) {
      return MapEntry(key, _sanitizeContext(value));   // No depth limit
    }
    // ...
  });
}
```

**After:**
```dart
static Map<String, dynamic>? _sanitizeContext(
  Map<String, dynamic>? context, {
  int maxDepth = 10,
}) {
  if (context == null) return null;
  if (maxDepth <= 0) return {'_truncated': 'max depth reached'};
  return context.map((key, value) {
    // ...
    if (value is Map<String, dynamic>) {
      return MapEntry(key, _sanitizeContext(value, maxDepth: maxDepth - 1));
    }
    // ...
  });
}
```

---

## Fix 3b: Unbounded Recursion in `_serializeMap()`

**File:** `lib/core/security/data_integrity.dart:294`
**Severity:** CRITICAL (Stack overflow risk)
**Issue:** Recursive serialization of nested maps with no depth guard.

**Before:**
```dart
static String _serializeMap(Map<String, dynamic> map) {
  // ...
  if (value is Map<String, dynamic>) {
    value = _serializeMap(value);   // No depth limit
  }
  // ...
}
```

**After:**
```dart
static String _serializeMap(Map<String, dynamic> map, {int maxDepth = 10}) {
  // ...
  if (value is Map<String, dynamic>) {
    if (maxDepth <= 0) {
      value = '{_truncated}';
    } else {
      value = _serializeMap(value, maxDepth: maxDepth - 1);
    }
  }
  // ...
}
```

---

## Fix 3c: Unbounded Recursion in `_sanitizeData()`

**File:** `lib/core/security/audit_trail.dart:515`
**Severity:** CRITICAL (Stack overflow risk)
**Issue:** Same unbounded recursion pattern as production_logger.

**Before:**
```dart
static Map<String, dynamic>? _sanitizeData(Map<String, dynamic>? data) {
  if (data == null) return null;
  return data.map((key, value) {
    // ...
    if (value is Map<String, dynamic>) {
      return MapEntry(key, _sanitizeData(value));   // No depth limit
    }
    // ...
  });
}
```

**After:**
```dart
static Map<String, dynamic>? _sanitizeData(
  Map<String, dynamic>? data, {
  int maxDepth = 10,
}) {
  if (data == null) return null;
  if (maxDepth <= 0) return {'_truncated': 'max depth reached'};
  return data.map((key, value) {
    // ...
    if (value is Map<String, dynamic>) {
      return MapEntry(key, _sanitizeData(value, maxDepth: maxDepth - 1));
    }
    // ...
  });
}
```

---

## Fix 4: Unhandled Custom Validator Exception

**File:** `lib/core/validators/json_schema_validator.dart:318`
**Severity:** CRITICAL (Unhandled exception / crash)
**Issue:** `schema.customValidator!(value)` was called without try-catch. If the custom validator function throws, the entire validation crashes instead of reporting a validation error.

**Before:**
```dart
if (schema.customValidator != null) {
  if (!schema.customValidator!(value)) {
    errors.add(SchemaValidationError(
      path: path,
      message: schema.customValidatorMessage ?? 'Custom validation failed',
      actualValue: value,
    ));
  }
}
```

**After:**
```dart
if (schema.customValidator != null) {
  try {
    if (!schema.customValidator!(value)) {
      errors.add(SchemaValidationError(
        path: path,
        message: schema.customValidatorMessage ?? 'Custom validation failed',
        actualValue: value,
      ));
    }
  } catch (e) {
    errors.add(SchemaValidationError(
      path: path,
      message: 'Custom validator threw an exception: $e',
      actualValue: value,
    ));
  }
}
```

---

## Verification

```
$ dart analyze <all 6 files>
Analyzing app_colors.dart, breakpoints.dart, production_logger.dart,
  data_integrity.dart, audit_trail.dart, json_schema_validator.dart...
No issues found!
```

All 6 fixes pass `dart analyze` with zero warnings or errors.
