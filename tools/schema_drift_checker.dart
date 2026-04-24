/// Schema drift checker — compares money-column types between Drift (local)
/// and Supabase (cloud) schemas.
///
/// Background (Phase 3, task 3.6): the POS money pipeline stores values as
/// **int cents** on the Drift side (post C-4 Session 3 migration). Supabase
/// has been converging on int cents too (v79 for qty, Phase-1 task 1.2 for
/// invoices) but the migration is incremental. Every time a new table gets
/// money columns we risk a drift where Drift writes int cents and Supabase
/// column is still DOUBLE PRECISION (SAR) — the 100× display bug caught in
/// Phase 1 (split_receipt:346) was a symptom of exactly this class of issue.
///
/// This script is a **lightweight static analyzer**: it parses Dart table
/// definitions and Supabase SQL migrations via regex, builds the latest
/// authoritative type for each money column on both sides, and reports
/// mismatches. No DB connection needed — runs offline in CI on any PR that
/// touches schema.
///
/// Usage (from repo root):
///   dart run tools/schema_drift_checker.dart
///
/// Exit codes:
///   0 — no drift found
///   1 — one or more money columns have mismatched types
///   2 — could not parse one or more files (fatal, check paths)
///
/// Add to CI (.github/workflows/ci.yml):
///   - name: Schema drift check
///     run: dart run tools/schema_drift_checker.dart

// ignore_for_file: avoid_print
import 'dart:io';

/// Money columns (substring match) that must be int cents on BOTH sides.
/// Add new ones here when introducing money to a table.
const Set<String> _moneyColumns = {
  'subtotal',
  'discount',
  'tax_amount',
  'total',
  'amount_paid',
  'amount_due',
  'amount_received',
  'change_amount',
  'cash_amount',
  'card_amount',
  'credit_amount',
  'balance',
  'credit_limit',
  'opening_float',
  'closing_float',
  'expected_cash',
  'actual_cash',
  'unit_price',
  'cost_price',
  'refund_amount',
  'total_refund',
  'total_sales',
  'total_sales_amount',
  'total_refunds_amount',
  'amount',
  'balance_after',
};

/// Quantities — must be REAL / DOUBLE PRECISION on both sides (v79).
const Set<String> _qtyColumns = {
  'qty',
  'quantity',
  'stock_qty',
  'min_qty',
  'quantity_change',
  'previous_qty',
  'new_qty',
  'received_qty',
};

void main(List<String> args) async {
  final repoRoot = Directory.current.path;
  final driftTablesDir = Directory('$repoRoot/packages/alhai_database/lib/src/tables');
  final supabaseDir = Directory('$repoRoot/supabase/migrations');

  if (!driftTablesDir.existsSync()) {
    stderr.writeln('❌ Drift tables not found: ${driftTablesDir.path}');
    exit(2);
  }
  if (!supabaseDir.existsSync()) {
    stderr.writeln('❌ Supabase migrations not found: ${supabaseDir.path}');
    exit(2);
  }

  print('🔍 Schema drift check — money + qty columns');
  print('   Drift:    ${driftTablesDir.path}');
  print('   Supabase: ${supabaseDir.path}');
  print('');

  final driftColumns = _parseDriftColumns(driftTablesDir);
  final supabaseColumns = _parseSupabaseColumns(supabaseDir);

  final issues = <String>[];

  // Money columns: must be int cents on both sides.
  for (final entry in driftColumns.entries) {
    final qualified = entry.key;
    final (table, column) = _splitQualified(qualified);
    if (!_moneyColumns.any((needle) => column.contains(needle))) continue;

    final driftType = entry.value;
    final supabaseType = supabaseColumns[qualified];

    if (driftType.isInteger && supabaseType != null && supabaseType.isDouble) {
      issues.add(
        '🔴 MISMATCH $table.$column: Drift=int cents, Supabase=DOUBLE → '
        '100× corruption risk on push. Migrate Supabase to INTEGER.',
      );
    }
    if (driftType.isDouble && supabaseType != null && supabaseType.isInteger) {
      issues.add(
        '🔴 MISMATCH $table.$column: Drift=REAL/double, Supabase=INTEGER → '
        'silent precision loss on push. Migrate Drift to int cents.',
      );
    }
  }

  // Qty columns: must be REAL/DOUBLE on both sides (v79 convention).
  for (final entry in driftColumns.entries) {
    final qualified = entry.key;
    final (table, column) = _splitQualified(qualified);
    if (!_qtyColumns.contains(column)) continue;

    final driftType = entry.value;
    final supabaseType = supabaseColumns[qualified];

    if (driftType.isInteger) {
      issues.add(
        '🟠 QTY ROUNDING $table.$column: Drift stores qty as INTEGER — '
        'fractional qty (2.5 kg) will be truncated. Migrate to REAL.',
      );
    }
    if (supabaseType != null && supabaseType.isInteger) {
      issues.add(
        '🟠 QTY ROUNDING $table.$column: Supabase stores qty as INTEGER. '
        'Migrate column to DOUBLE PRECISION (v79 pattern).',
      );
    }
  }

  if (issues.isEmpty) {
    print('✅ No schema drift detected across '
        '${driftColumns.length} Drift columns and '
        '${supabaseColumns.length} Supabase columns.');
    exit(0);
  }

  print('❌ ${issues.length} issue(s) found:\n');
  for (final issue in issues) {
    print('  $issue');
  }
  print('');
  print('Fix by emitting matching migrations on both sides. Example:');
  print('  supabase: ALTER TABLE x ALTER COLUMN c TYPE INTEGER USING ROUND(c*100)::INTEGER;');
  print('  drift:    change column type + bump schemaVersion + migration step');
  exit(1);
}

(String, String) _splitQualified(String qualified) {
  final idx = qualified.indexOf('.');
  return (qualified.substring(0, idx), qualified.substring(idx + 1));
}

/// Parse Drift table .dart files. Look for column definitions of the form:
///   IntColumn get subtotal => integer()...
///   RealColumn get qty => real()...
///   TextColumn get name => text()...
Map<String, _ColumnType> _parseDriftColumns(Directory dir) {
  final result = <String, _ColumnType>{};

  final tableDef = RegExp(
    r"class\s+(\w+Table)\s+extends\s+Table\s*\{([\s\S]*?)\n\}",
    multiLine: true,
  );
  // Matches: IntColumn get foo => integer()(); or RealColumn get foo => real()...()
  final colDef = RegExp(
    r'(IntColumn|RealColumn|TextColumn|DateTimeColumn|BoolColumn)\s+get\s+(\w+)',
    multiLine: true,
  );

  for (final file in dir.listSync().whereType<File>()) {
    if (!file.path.endsWith('.dart')) continue;
    final content = file.readAsStringSync();

    for (final tableMatch in tableDef.allMatches(content)) {
      final className = tableMatch.group(1)!;
      final tableName = _tableNameFromClass(className);
      final body = tableMatch.group(2)!;

      for (final colMatch in colDef.allMatches(body)) {
        final kind = colMatch.group(1)!;
        final camelName = colMatch.group(2)!;
        final snakeName = _camelToSnake(camelName);

        result['$tableName.$snakeName'] = _ColumnType.fromDriftKind(kind);
      }
    }
  }

  return result;
}

/// Parse Supabase SQL migrations for latest column types.
///
/// Looks for:
///   CREATE TABLE x (...)
///   ALTER TABLE x ALTER COLUMN c TYPE newtype
///   ALTER TABLE x ADD COLUMN c type
Map<String, _ColumnType> _parseSupabaseColumns(Directory dir) {
  final result = <String, _ColumnType>{};

  // Process files in chronological order (filename starts with YYYYMMDD).
  final files = dir.listSync().whereType<File>()
      .where((f) => f.path.endsWith('.sql'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  final createTable = RegExp(
    r"CREATE\s+TABLE(?:\s+IF\s+NOT\s+EXISTS)?\s+(?:public\.)?(\w+)\s*\(([\s\S]*?)\);",
    caseSensitive: false,
  );
  // Inside CREATE TABLE body — rough column matcher.
  final inlineCol = RegExp(
    r'^\s*(\w+)\s+(INTEGER|BIGINT|DOUBLE\s+PRECISION|REAL|NUMERIC|TEXT|UUID|BOOLEAN|TIMESTAMPTZ|DATE|JSONB|BYTEA)\b',
    multiLine: true,
    caseSensitive: false,
  );
  final alterType = RegExp(
    r"ALTER\s+TABLE\s+(?:public\.)?(\w+)\s+ALTER\s+COLUMN\s+(\w+)\s+TYPE\s+(INTEGER|BIGINT|DOUBLE\s+PRECISION|REAL|NUMERIC|TEXT|UUID|BOOLEAN)",
    caseSensitive: false,
  );
  final addCol = RegExp(
    r"ALTER\s+TABLE\s+(?:public\.)?(\w+)\s+ADD\s+COLUMN(?:\s+IF\s+NOT\s+EXISTS)?\s+(\w+)\s+(INTEGER|BIGINT|DOUBLE\s+PRECISION|REAL|NUMERIC|TEXT|UUID|BOOLEAN)",
    caseSensitive: false,
  );

  for (final file in files) {
    final content = file.readAsStringSync();

    // 1. CREATE TABLE statements.
    for (final tm in createTable.allMatches(content)) {
      final tableName = tm.group(1)!;
      final body = tm.group(2)!;
      for (final cm in inlineCol.allMatches(body)) {
        final colName = cm.group(1)!.toLowerCase();
        final typeStr = cm.group(2)!;
        // Skip SQL keywords that regex might capture (CONSTRAINT, etc).
        if (_isSqlKeyword(colName)) continue;
        result['$tableName.$colName'] = _ColumnType.fromSqlType(typeStr);
      }
    }

    // 2. ALTER TABLE ... ALTER COLUMN ... TYPE
    for (final am in alterType.allMatches(content)) {
      final tableName = am.group(1)!;
      final colName = am.group(2)!;
      final typeStr = am.group(3)!;
      result['$tableName.$colName'] = _ColumnType.fromSqlType(typeStr);
    }

    // 3. ALTER TABLE ... ADD COLUMN
    for (final am in addCol.allMatches(content)) {
      final tableName = am.group(1)!;
      final colName = am.group(2)!;
      final typeStr = am.group(3)!;
      result['$tableName.$colName'] = _ColumnType.fromSqlType(typeStr);
    }
  }

  return result;
}

bool _isSqlKeyword(String s) {
  const keywords = {
    'primary', 'foreign', 'unique', 'check', 'constraint', 'references',
    'not', 'null', 'default', 'on', 'delete', 'update', 'key',
  };
  return keywords.contains(s);
}

String _tableNameFromClass(String className) {
  // ProductsTable -> products; SaleItemsTable -> sale_items
  var base = className.replaceAll(RegExp(r'Table$'), '');
  return _camelToSnake(base);
}

String _camelToSnake(String s) {
  return s.replaceAllMapped(
    RegExp(r'([a-z0-9])([A-Z])'),
    (m) => '${m.group(1)}_${m.group(2)!.toLowerCase()}',
  ).toLowerCase();
}

class _ColumnType {
  final bool isInteger;
  final bool isDouble;

  const _ColumnType.integer() : isInteger = true, isDouble = false;
  const _ColumnType.double() : isInteger = false, isDouble = true;
  const _ColumnType.other() : isInteger = false, isDouble = false;

  factory _ColumnType.fromDriftKind(String kind) {
    switch (kind) {
      case 'IntColumn':
        return const _ColumnType.integer();
      case 'RealColumn':
        return const _ColumnType.double();
      default:
        return const _ColumnType.other();
    }
  }

  factory _ColumnType.fromSqlType(String type) {
    final t = type.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
    if (t == 'integer' || t == 'bigint') return const _ColumnType.integer();
    if (t == 'double precision' || t == 'real' || t == 'numeric') {
      return const _ColumnType.double();
    }
    return const _ColumnType.other();
  }
}
