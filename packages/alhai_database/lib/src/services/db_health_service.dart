import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../app_database.dart';

/// تقرير صحة قاعدة البيانات
class DbHealthReport {
  /// نتيجة PRAGMA integrity_check
  final bool integrityOk;
  final String integrityMessage;

  /// عدد انتهاكات المفاتيح الأجنبية
  final int foreignKeyViolations;

  /// عدد السجلات اليتيمة (sale_items بدون sale)
  final int orphanedSaleItems;

  /// عدد السجلات اليتيمة (return_items بدون return)
  final int orphanedReturnItems;

  /// شذوذات البيانات المكتشفة
  final List<String> anomalies;

  /// حجم قاعدة البيانات بالبايتات
  final int? databaseSizeBytes;

  /// عدد الصفحات الفارغة (القابلة للاستعادة)
  final int? freePages;

  /// الوقت المستغرق بالمللي ثانية
  final int checkDurationMs;

  const DbHealthReport({
    required this.integrityOk,
    required this.integrityMessage,
    required this.foreignKeyViolations,
    required this.orphanedSaleItems,
    required this.orphanedReturnItems,
    required this.anomalies,
    this.databaseSizeBytes,
    this.freePages,
    required this.checkDurationMs,
  });

  /// هل قاعدة البيانات سليمة بالكامل؟
  bool get isHealthy =>
      integrityOk &&
      foreignKeyViolations == 0 &&
      orphanedSaleItems == 0 &&
      orphanedReturnItems == 0 &&
      anomalies.isEmpty;

  /// مستوى الصحة: healthy, warning, critical
  String get healthLevel {
    if (isHealthy) return 'healthy';
    if (!integrityOk || foreignKeyViolations > 10) return 'critical';
    return 'warning';
  }

  /// عدد المشاكل الكلي
  int get totalIssues =>
      (integrityOk ? 0 : 1) +
      foreignKeyViolations +
      orphanedSaleItems +
      orphanedReturnItems +
      anomalies.length;

  @override
  String toString() {
    final sb = StringBuffer('=== DB Health Report ===\n');
    sb.writeln('Status: $healthLevel');
    sb.writeln(
        'Integrity: ${integrityOk ? "OK" : "FAILED"} ($integrityMessage)');
    sb.writeln('FK Violations: $foreignKeyViolations');
    sb.writeln('Orphaned sale_items: $orphanedSaleItems');
    sb.writeln('Orphaned return_items: $orphanedReturnItems');
    if (anomalies.isNotEmpty) {
      sb.writeln('Anomalies:');
      for (final a in anomalies) {
        sb.writeln('  - $a');
      }
    }
    if (databaseSizeBytes != null) {
      final sizeMB = (databaseSizeBytes! / 1024 / 1024).toStringAsFixed(2);
      sb.writeln('DB Size: $sizeMB MB');
    }
    if (freePages != null) {
      sb.writeln('Free pages: $freePages');
    }
    sb.writeln('Check duration: ${checkDurationMs}ms');
    return sb.toString();
  }
}

/// نتيجة الإصلاح التلقائي
class AutoFixResult {
  final int orphanedSaleItemsDeleted;
  final int orphanedReturnItemsDeleted;
  final int negativeStockFixed;
  final int freeSpaceReclaimed;

  const AutoFixResult({
    this.orphanedSaleItemsDeleted = 0,
    this.orphanedReturnItemsDeleted = 0,
    this.negativeStockFixed = 0,
    this.freeSpaceReclaimed = 0,
  });

  int get totalFixes =>
      orphanedSaleItemsDeleted +
      orphanedReturnItemsDeleted +
      negativeStockFixed +
      freeSpaceReclaimed;

  @override
  String toString() {
    return 'AutoFixResult: $totalFixes fixes '
        '(orphanedSaleItems=$orphanedSaleItemsDeleted, '
        'orphanedReturnItems=$orphanedReturnItemsDeleted, '
        'negativeStock=$negativeStockFixed, '
        'freeSpaceReclaimed=$freeSpaceReclaimed)';
  }
}

/// خدمة فحص صحة قاعدة البيانات واكتشاف التلف
///
/// تفحص:
/// 1. سلامة بنية قاعدة البيانات (PRAGMA integrity_check)
/// 2. انتهاكات المفاتيح الأجنبية (PRAGMA foreign_key_check)
/// 3. السجلات اليتيمة (sale_items بدون sale، return_items بدون return)
/// 4. شذوذات البيانات (مخزون سالب، مبيعات بإجمالي صفري، تواريخ مستقبلية)
/// 5. حجم قاعدة البيانات والصفحات الفارغة
class DbHealthService {
  final AppDatabase _db;

  DbHealthService(this._db);

  /// تشغيل فحص صحة شامل
  Future<DbHealthReport> checkHealth() async {
    final stopwatch = Stopwatch()..start();

    // تنفيذ الفحوصات بالتوازي حيث ممكن
    final results = await Future.wait([
      _runIntegrityCheck(),
      _runForeignKeyCheck(),
      _checkOrphanedSaleItems(),
      _checkOrphanedReturnItems(),
      _checkDataAnomalies(),
      _getDatabaseSize(),
    ]);

    stopwatch.stop();

    final integrityResult = results[0] as _IntegrityResult;
    final fkViolations = results[1] as int;
    final orphanedSaleItems = results[2] as int;
    final orphanedReturnItems = results[3] as int;
    final anomalies = results[4] as List<String>;
    final sizeInfo = results[5] as _SizeInfo;

    final report = DbHealthReport(
      integrityOk: integrityResult.ok,
      integrityMessage: integrityResult.message,
      foreignKeyViolations: fkViolations,
      orphanedSaleItems: orphanedSaleItems,
      orphanedReturnItems: orphanedReturnItems,
      anomalies: anomalies,
      databaseSizeBytes: sizeInfo.sizeBytes,
      freePages: sizeInfo.freePages,
      checkDurationMs: stopwatch.elapsedMilliseconds,
    );

    if (kDebugMode) {
      debugPrint(report.toString());
    }

    return report;
  }

  /// فحص سريع (integrity_check فقط)
  Future<bool> quickCheck() async {
    try {
      final result = await _runIntegrityCheck();
      return result.ok;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[DbHealthService] Quick check failed: $e');
      }
      return false;
    }
  }

  /// إصلاح تلقائي للمشاكل الآمنة
  ///
  /// يُصلح:
  /// - السجلات اليتيمة (حذف sale_items بدون sale)
  /// - المخزون السالب (تصفيره)
  /// - استعادة المساحة الفارغة (PRAGMA incremental_vacuum)
  Future<AutoFixResult> autoFix() async {
    int orphanedSaleItemsDeleted = 0;
    int orphanedReturnItemsDeleted = 0;
    int negativeStockFixed = 0;
    int freeSpaceReclaimed = 0;

    try {
      // 1. حذف sale_items اليتيمة
      final orphanedSaleResult = await _db.customUpdate(
        'DELETE FROM sale_items WHERE sale_id NOT IN (SELECT id FROM sales)',
        updates: {},
        updateKind: UpdateKind.delete,
      );
      orphanedSaleItemsDeleted = orphanedSaleResult;

      // 2. حذف return_items اليتيمة
      final orphanedReturnResult = await _db.customUpdate(
        'DELETE FROM return_items WHERE return_id NOT IN (SELECT id FROM returns)',
        updates: {},
        updateKind: UpdateKind.delete,
      );
      orphanedReturnItemsDeleted = orphanedReturnResult;

      // 3. تصفير المخزون السالب
      final negativeStockResult = await _db.customUpdate(
        'UPDATE products SET stock_qty = 0 WHERE stock_qty < 0',
        updates: {},
        updateKind: UpdateKind.update,
      );
      negativeStockFixed = negativeStockResult;

      // 4. استعادة المساحة الفارغة
      try {
        final freePagesBefore = await _getFreePages();
        await _db.customStatement('PRAGMA incremental_vacuum(100)');
        final freePagesAfter = await _getFreePages();
        freeSpaceReclaimed = freePagesBefore - freePagesAfter;
      } catch (_) {
        // incremental_vacuum قد لا يعمل إذا لم يكن auto_vacuum مُفعّلاً
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[DbHealthService] Auto-fix error: $e');
      }
    }

    final result = AutoFixResult(
      orphanedSaleItemsDeleted: orphanedSaleItemsDeleted,
      orphanedReturnItemsDeleted: orphanedReturnItemsDeleted,
      negativeStockFixed: negativeStockFixed,
      freeSpaceReclaimed: freeSpaceReclaimed,
    );

    if (kDebugMode) {
      debugPrint('[DbHealthService] $result');
    }

    return result;
  }

  // ============================================================================
  // Private Checks
  // ============================================================================

  /// PRAGMA integrity_check
  Future<_IntegrityResult> _runIntegrityCheck() async {
    try {
      final result = await _db.customSelect('PRAGMA integrity_check').get();
      if (result.isEmpty) {
        return const _IntegrityResult(ok: false, message: 'no result');
      }
      final message = result.first.data.values.first?.toString() ?? '';
      return _IntegrityResult(
        ok: message == 'ok',
        message: message,
      );
    } catch (e) {
      return _IntegrityResult(ok: false, message: 'check failed: $e');
    }
  }

  /// PRAGMA foreign_key_check
  Future<int> _runForeignKeyCheck() async {
    try {
      final result = await _db.customSelect('PRAGMA foreign_key_check').get();
      return result.length;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[DbHealthService] FK check failed: $e');
      }
      return -1; // -1 = فشل الفحص
    }
  }

  /// فحص sale_items اليتيمة
  Future<int> _checkOrphanedSaleItems() async {
    try {
      final result = await _db
          .customSelect(
            'SELECT COUNT(*) as cnt FROM sale_items WHERE sale_id NOT IN (SELECT id FROM sales)',
          )
          .getSingle();
      return result.data['cnt'] as int? ?? 0;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[DbHealthService] Orphaned sale_items check failed: $e');
      }
      return 0;
    }
  }

  /// فحص return_items اليتيمة
  Future<int> _checkOrphanedReturnItems() async {
    try {
      final result = await _db
          .customSelect(
            'SELECT COUNT(*) as cnt FROM return_items WHERE return_id NOT IN (SELECT id FROM returns)',
          )
          .getSingle();
      return result.data['cnt'] as int? ?? 0;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[DbHealthService] Orphaned return_items check failed: $e');
      }
      return 0;
    }
  }

  /// فحص شذوذات البيانات
  Future<List<String>> _checkDataAnomalies() async {
    final anomalies = <String>[];

    try {
      // 1. مخزون سالب
      final negativeStock = await _db
          .customSelect(
            'SELECT COUNT(*) as cnt FROM products WHERE stock_qty < 0',
          )
          .getSingle();
      final negCount = negativeStock.data['cnt'] as int? ?? 0;
      if (negCount > 0) {
        anomalies.add('$negCount products with negative stock');
      }

      // 2. مبيعات مكتملة بإجمالي صفري أو سالب
      final zeroSales = await _db
          .customSelect(
            "SELECT COUNT(*) as cnt FROM sales WHERE status = 'completed' AND total <= 0",
          )
          .getSingle();
      final zeroCount = zeroSales.data['cnt'] as int? ?? 0;
      if (zeroCount > 0) {
        anomalies.add('$zeroCount completed sales with zero or negative total');
      }

      // 3. مبيعات بتاريخ مستقبلي (أكثر من 24 ساعة)
      final futureDate = DateTime.now().add(const Duration(hours: 24));
      final futureSales = await _db.customSelect(
        'SELECT COUNT(*) as cnt FROM sales WHERE created_at > ?',
        variables: [Variable.withDateTime(futureDate)],
      ).getSingle();
      final futureCount = futureSales.data['cnt'] as int? ?? 0;
      if (futureCount > 0) {
        anomalies.add('$futureCount sales with future dates (>24h from now)');
      }

      // 4. منتجات بسعر سالب
      final negativePrices = await _db
          .customSelect(
            'SELECT COUNT(*) as cnt FROM products WHERE price < 0',
          )
          .getSingle();
      final negPriceCount = negativePrices.data['cnt'] as int? ?? 0;
      if (negPriceCount > 0) {
        anomalies.add('$negPriceCount products with negative price');
      }

      // 5. sync_queue عالقة في حالة syncing (أكثر من ساعة)
      final stuckCutoff = DateTime.now().subtract(const Duration(hours: 1));
      final stuckItems = await _db.customSelect(
        "SELECT COUNT(*) as cnt FROM sync_queue WHERE status = 'syncing' AND last_attempt_at < ?",
        variables: [Variable.withDateTime(stuckCutoff)],
      ).getSingle();
      final stuckCount = stuckItems.data['cnt'] as int? ?? 0;
      if (stuckCount > 0) {
        anomalies.add('$stuckCount sync items stuck in syncing state (>1h)');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[DbHealthService] Anomaly check failed: $e');
      }
      anomalies.add('anomaly check failed: $e');
    }

    return anomalies;
  }

  /// الحصول على حجم قاعدة البيانات
  Future<_SizeInfo> _getDatabaseSize() async {
    try {
      final pageCount = await _db.customSelect('PRAGMA page_count').getSingle();
      final pageSize = await _db.customSelect('PRAGMA page_size').getSingle();
      final freePages =
          await _db.customSelect('PRAGMA freelist_count').getSingle();

      final pages = pageCount.data.values.first as int? ?? 0;
      final size = pageSize.data.values.first as int? ?? 4096;
      final free = freePages.data.values.first as int? ?? 0;

      return _SizeInfo(
        sizeBytes: pages * size,
        freePages: free,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[DbHealthService] Size check failed: $e');
      }
      return const _SizeInfo();
    }
  }

  /// الحصول على عدد الصفحات الفارغة
  Future<int> _getFreePages() async {
    try {
      final result =
          await _db.customSelect('PRAGMA freelist_count').getSingle();
      return result.data.values.first as int? ?? 0;
    } catch (_) {
      return 0;
    }
  }
}

/// نتيجة فحص السلامة
class _IntegrityResult {
  final bool ok;
  final String message;

  const _IntegrityResult({required this.ok, required this.message});
}

/// معلومات حجم قاعدة البيانات
class _SizeInfo {
  final int? sizeBytes;
  final int? freePages;

  const _SizeInfo({this.sizeBytes, this.freePages});
}
