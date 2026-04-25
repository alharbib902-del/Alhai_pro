/// BackupManager - Real backup/restore using database export
///
/// Bridges AppDatabase ↔ BackupService for actual data export/import.
/// Supports: full JSON export, import with validation, share via platform share sheet.
library;

import 'dart:convert';

import 'package:alhai_database/alhai_database.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;

import 'sentry_service.dart';

/// Manages real backup/restore operations against the local database.
class BackupManager {
  final AppDatabase _db;

  BackupManager(this._db);

  // ===========================================================================
  // EXPORT
  // ===========================================================================

  /// Export all store data as a JSON map.
  ///
  /// Returns a Map containing every table's rows scoped to [storeId].
  /// Tables without a storeId column are exported in full (settings, etc.).
  Future<BackupBundle> exportAsJson(String storeId) {
    // Phase 5 §5.4 — trace full backup export (bulk db.query over ~25 tables).
    return tracePerformance(
      name: 'exportBackup',
      operation: 'db.query',
      body: () => _exportAsJsonImpl(storeId),
    );
  }

  Future<BackupBundle> _exportAsJsonImpl(String storeId) async {
    try {
      final now = DateTime.now();
      final data = <String, dynamic>{};

      // --- Core tables ---
      data['products'] = await _queryRows(
        'SELECT * FROM products WHERE store_id = ?',
        [Variable.withString(storeId)],
      );
      data['categories'] = await _queryRows(
        'SELECT * FROM categories WHERE store_id = ?',
        [Variable.withString(storeId)],
      );
      data['sales'] = await _queryRows(
        'SELECT * FROM sales WHERE store_id = ?',
        [Variable.withString(storeId)],
      );
      data['sale_items'] = await _queryRows(
        'SELECT si.* FROM sale_items si INNER JOIN sales s ON si.sale_id = s.id WHERE s.store_id = ?',
        [Variable.withString(storeId)],
      );
      data['customers'] = await _queryRows(
        'SELECT * FROM customers WHERE store_id = ?',
        [Variable.withString(storeId)],
      );
      data['customer_addresses'] = await _queryRows(
        'SELECT ca.* FROM customer_addresses ca INNER JOIN customers c ON ca.customer_id = c.id WHERE c.store_id = ?',
        [Variable.withString(storeId)],
      );

      // --- Financial ---
      data['accounts'] = await _queryRows(
        'SELECT * FROM accounts WHERE store_id = ?',
        [Variable.withString(storeId)],
      );
      data['transactions'] = await _queryRows(
        'SELECT * FROM transactions WHERE store_id = ?',
        [Variable.withString(storeId)],
      );

      // --- Inventory ---
      data['inventory_movements'] = await _queryRows(
        'SELECT * FROM inventory_movements WHERE store_id = ?',
        [Variable.withString(storeId)],
      );
      data['stock_transfers'] = await _queryRows(
        'SELECT * FROM stock_transfers WHERE from_store_id = ? OR to_store_id = ?',
        [Variable.withString(storeId), Variable.withString(storeId)],
      );

      // --- Orders ---
      data['orders'] = await _queryRows(
        'SELECT * FROM orders WHERE store_id = ?',
        [Variable.withString(storeId)],
      );
      data['order_items'] = await _queryRows(
        'SELECT oi.* FROM order_items oi INNER JOIN orders o ON oi.order_id = o.id WHERE o.store_id = ?',
        [Variable.withString(storeId)],
      );

      // --- Returns ---
      data['returns'] = await _queryRows(
        'SELECT * FROM returns WHERE store_id = ?',
        [Variable.withString(storeId)],
      );
      data['return_items'] = await _queryRows(
        'SELECT ri.* FROM return_items ri INNER JOIN returns r ON ri.return_id = r.id WHERE r.store_id = ?',
        [Variable.withString(storeId)],
      );

      // --- Shifts ---
      data['shifts'] = await _queryRows(
        'SELECT * FROM shifts WHERE store_id = ?',
        [Variable.withString(storeId)],
      );
      data['cash_movements'] = await _queryRows(
        'SELECT cm.* FROM cash_movements cm INNER JOIN shifts sh ON cm.shift_id = sh.id WHERE sh.store_id = ?',
        [Variable.withString(storeId)],
      );

      // --- Suppliers & Purchases ---
      data['suppliers'] = await _queryRows(
        'SELECT * FROM suppliers WHERE store_id = ?',
        [Variable.withString(storeId)],
      );
      data['purchases'] = await _queryRows(
        'SELECT * FROM purchases WHERE store_id = ?',
        [Variable.withString(storeId)],
      );
      data['purchase_items'] = await _queryRows(
        'SELECT pi.* FROM purchase_items pi INNER JOIN purchases p ON pi.purchase_id = p.id WHERE p.store_id = ?',
        [Variable.withString(storeId)],
      );

      // --- Expenses ---
      data['expenses'] = await _queryRows(
        'SELECT * FROM expenses WHERE store_id = ?',
        [Variable.withString(storeId)],
      );
      data['expense_categories'] = await _queryRows(
        'SELECT * FROM expense_categories WHERE store_id = ?',
        [Variable.withString(storeId)],
      );

      // --- Promotions ---
      data['discounts'] = await _queryRows(
        'SELECT * FROM discounts WHERE store_id = ?',
        [Variable.withString(storeId)],
      );
      data['coupons'] = await _queryRows(
        'SELECT * FROM coupons WHERE store_id = ?',
        [Variable.withString(storeId)],
      );
      data['promotions'] = await _queryRows(
        'SELECT * FROM promotions WHERE store_id = ?',
        [Variable.withString(storeId)],
      );

      // --- Settings ---
      data['settings'] = await _queryRows(
        'SELECT * FROM settings WHERE store_id = ?',
        [Variable.withString(storeId)],
      );

      // --- Held invoices ---
      data['held_invoices'] = await _queryRows(
        'SELECT * FROM held_invoices WHERE store_id = ?',
        [Variable.withString(storeId)],
      );

      // --- ZATCA (Wave 5 / P0-08) ---
      // Without these the encrypted backup wouldn't carry the e-invoice
      // chain, the offline queue waiting for clearance, or the dead-letter
      // log that auditors need to reconcile failed submissions. Restoring
      // a backup that's missing them silently breaks the cashier's ZATCA
      // pipeline on the new device.
      data['invoices'] = await _queryRows(
        'SELECT * FROM invoices WHERE store_id = ?',
        [Variable.withString(storeId)],
      );
      data['zatca_offline_queue'] = await _queryRows(
        'SELECT * FROM zatca_offline_queue WHERE store_id = ?',
        [Variable.withString(storeId)],
      );
      data['zatca_dead_letter'] = await _queryRows(
        'SELECT * FROM zatca_dead_letter WHERE store_id = ?',
        [Variable.withString(storeId)],
      );

      // --- Loyalty ---
      data['loyalty_points'] = await _queryRows(
        'SELECT * FROM loyalty_points WHERE store_id = ?',
        [Variable.withString(storeId)],
      );

      // --- Favorites ---
      data['favorites'] = await _queryRows(
        'SELECT * FROM favorites WHERE store_id = ?',
        [Variable.withString(storeId)],
      );

      // --- Notifications ---
      data['notifications'] = await _queryRows(
        'SELECT * FROM notifications WHERE store_id = ?',
        [Variable.withString(storeId)],
      );

      // --- Daily Summaries ---
      data['daily_summaries'] = await _queryRows(
        'SELECT * FROM daily_summaries WHERE store_id = ?',
        [Variable.withString(storeId)],
      );

      // Count total rows
      int totalRows = 0;
      for (final entry in data.entries) {
        if (entry.value is List) totalRows += (entry.value as List).length;
      }

      final jsonString = jsonEncode({
        // Backup envelope version. Bump when restoreOrder / required
        // tables change in a way that an older app can't read.
        'version': '1.1.0',
        // Wave 5 (P0-08): persist the Drift schema version so import
        // can refuse a cross-migration restore. AppDatabase.schemaVersion
        // is a single source of truth; reading it here keeps the gate
        // honest without a parallel constant.
        'schemaVersion': _db.schemaVersion,
        'storeId': storeId,
        'createdAt': now.toIso8601String(),
        'tableCount': data.length,
        'totalRows': totalRows,
        'data': data,
      });

      addBreadcrumb(
        message: 'Backup exported: $totalRows rows, ${data.length} tables',
        category: 'backup',
      );

      return BackupBundle(
        jsonString: jsonString,
        totalRows: totalRows,
        tableCount: data.length,
        sizeBytes: utf8.encode(jsonString).length,
        createdAt: now,
      );
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Export backup');
      rethrow;
    }
  }

  // ===========================================================================
  // IMPORT / RESTORE
  // ===========================================================================

  /// Import data from a JSON backup string.
  ///
  /// Runs inside a database transaction so either everything succeeds or
  /// nothing changes. Existing rows with the same primary key are replaced.
  Future<RestoreReport> importFromJson(String jsonString) {
    // Phase 5 §5.4 — trace full restore transaction.
    return tracePerformance(
      name: 'importBackup',
      operation: 'db.write',
      data: {'payload_bytes': jsonString.length},
      body: () => _importFromJsonImpl(jsonString),
    );
  }

  Future<RestoreReport> _importFromJsonImpl(String jsonString) async {
    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      final version = map['version'] as String? ?? '1.0.0';
      final dataMap = map['data'] as Map<String, dynamic>? ?? {};

      if (dataMap.isEmpty) {
        return const RestoreReport(success: false, error: 'Empty backup data');
      }

      // Wave 5 (P0-08): refuse a backup whose Drift schema doesn't
      // match the running app. Drift's migration graph is forward-only
      // and a foreign-version backup will either fail mid-restore (FK /
      // column-shape mismatch leaves a half-restored DB) or, worse,
      // silently insert into a column that's been semantically repurposed.
      // Older v1.0.0 backups didn't ship `schemaVersion`; we accept those
      // with a warning since they predate the gate.
      final backupSchemaVersion = map['schemaVersion'] as int?;
      final currentSchemaVersion = _db.schemaVersion;
      if (backupSchemaVersion != null &&
          backupSchemaVersion != currentSchemaVersion) {
        return RestoreReport(
          success: false,
          error:
              'Schema mismatch: backup is at v$backupSchemaVersion, '
              'app is at v$currentSchemaVersion. Update or downgrade the '
              'app to match before restoring.',
        );
      }

      int restoredRows = 0;
      int restoredTables = 0;

      await _db.transaction(() async {
        // Restore order matters for FK constraints — parents first.
        // Wave 5 (P0-08): added invoices + zatca_offline_queue +
        // zatca_dead_letter so the e-invoicing pipeline survives a
        // restore. invoices depends on sales (FK on sale_id), so it
        // sits after sales/sale_items. The two zatca queues only FK
        // to stores, but ordering them after invoices keeps the audit
        // trail readable in the order it was generated.
        const restoreOrder = [
          'categories',
          'products',
          'customers',
          'customer_addresses',
          'suppliers',
          'settings',
          'expense_categories',
          'accounts',
          'shifts',
          'cash_movements',
          'sales',
          'sale_items',
          'orders',
          'order_items',
          'returns',
          'return_items',
          'transactions',
          'inventory_movements',
          'stock_transfers',
          'purchases',
          'purchase_items',
          'expenses',
          'discounts',
          'coupons',
          'promotions',
          'held_invoices',
          'invoices',
          'zatca_offline_queue',
          'zatca_dead_letter',
          'loyalty_points',
          'favorites',
          'notifications',
          'daily_summaries',
        ];

        for (final tableName in restoreOrder) {
          final rows = dataMap[tableName];
          if (rows == null || rows is! List || rows.isEmpty) continue;

          for (final row in rows) {
            if (row is! Map<String, dynamic>) continue;
            await _insertOrReplace(tableName, row);
            restoredRows++;
          }
          restoredTables++;
        }
      });

      addBreadcrumb(
        message:
            'Backup restored: $restoredRows rows, $restoredTables tables (v$version)',
        category: 'backup',
      );

      return RestoreReport(
        success: true,
        restoredRows: restoredRows,
        restoredTables: restoredTables,
      );
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Import backup');
      return RestoreReport(success: false, error: '$e');
    }
  }

  // ===========================================================================
  // VALIDATE
  // ===========================================================================

  /// Quick-validate a backup JSON string without importing.
  BackupInfo? validateBackup(String jsonString) {
    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return BackupInfo(
        version: map['version'] as String? ?? '?',
        // Wave 5 (P0-08): pre-1.1 backups didn't ship schemaVersion;
        // null means "unknown — the gate will let it through with a
        // logged warning instead of refusing outright". Newer backups
        // always carry it.
        schemaVersion: map['schemaVersion'] as int?,
        storeId: map['storeId'] as String? ?? '?',
        createdAt: DateTime.tryParse(map['createdAt'] as String? ?? ''),
        tableCount: map['tableCount'] as int? ?? 0,
        totalRows: map['totalRows'] as int? ?? 0,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Backup validation failed: $e');
      return null;
    }
  }

  /// Returns the schema version the running app would write into a fresh
  /// backup. UI can compare this against [BackupInfo.schemaVersion] before
  /// even calling restore, so the user sees the mismatch in the preview
  /// dialog instead of as an "import failed" toast after the fact.
  int get currentSchemaVersion => _db.schemaVersion;

  // ===========================================================================
  // HELPERS
  // ===========================================================================

  Future<List<Map<String, dynamic>>> _queryRows(
    String sql,
    List<Variable> vars,
  ) async {
    final result = await _db.customSelect(sql, variables: vars).get();
    return result.map((r) => r.data).toList();
  }

  Future<void> _insertOrReplace(
    String tableName,
    Map<String, dynamic> row,
  ) async {
    final columns = row.keys.toList();
    final placeholders = List.filled(columns.length, '?').join(', ');
    final columnNames = columns.join(', ');

    final variables = columns.map((col) {
      final value = row[col];
      if (value == null) return const Variable<String>(null);
      if (value is int) return Variable.withInt(value);
      if (value is double) return Variable.withReal(value);
      if (value is bool) return Variable.withBool(value);
      return Variable.withString(value.toString());
    }).toList();

    await _db.customStatement(
      'INSERT OR REPLACE INTO $tableName ($columnNames) VALUES ($placeholders)',
      variables,
    );
  }
}

/// Result of a backup export
class BackupBundle {
  final String jsonString;
  final int totalRows;
  final int tableCount;
  final int sizeBytes;
  final DateTime createdAt;

  const BackupBundle({
    required this.jsonString,
    required this.totalRows,
    required this.tableCount,
    required this.sizeBytes,
    required this.createdAt,
  });

  double get sizeMb => sizeBytes / (1024 * 1024);
}

/// Result of a restore operation
class RestoreReport {
  final bool success;
  final String? error;
  final int restoredRows;
  final int restoredTables;

  const RestoreReport({
    required this.success,
    this.error,
    this.restoredRows = 0,
    this.restoredTables = 0,
  });
}

/// Result of a pending-auto-backup catch-up run.
///
/// Wave 5 (P0-09): the workmanager isolate can't run the full export
/// pipeline (no GetIt, no secure storage chain). It only marks "the OS
/// fired the task at T". The next time the app opens, the screen calls
/// [BackupManager.runPendingAutoBackup] which checks for the marker and
/// runs the real backup inside the app's normal isolate.
class AutoBackupCatchUpReport {
  /// True if a pending mark was found and the catch-up ran.
  final bool ran;

  /// True if the catch-up succeeded (or no work was needed).
  final bool success;

  /// When the OS fired the most-recent task. Null if no mark.
  final DateTime? scheduledAt;

  /// How many fires accumulated since the last catch-up. Spikes >1
  /// usually mean the device was off / app wasn't opened for a while.
  final int pendingCount;

  /// Bundle produced by the catch-up, if [ran] && [success].
  final BackupBundle? bundle;

  /// Error message when [ran] but !success.
  final String? error;

  const AutoBackupCatchUpReport({
    required this.ran,
    required this.success,
    this.scheduledAt,
    this.pendingCount = 0,
    this.bundle,
    this.error,
  });

  static const idle = AutoBackupCatchUpReport(ran: false, success: true);
}

/// Quick info about a backup file
class BackupInfo {
  final String version;

  /// Drift schema version embedded in the backup (Wave 5 / P0-08).
  /// Null on legacy v1.0.0 backups that pre-date the field.
  final int? schemaVersion;

  final String storeId;
  final DateTime? createdAt;
  final int tableCount;
  final int totalRows;

  const BackupInfo({
    required this.version,
    this.schemaVersion,
    required this.storeId,
    this.createdAt,
    required this.tableCount,
    required this.totalRows,
  });
}
