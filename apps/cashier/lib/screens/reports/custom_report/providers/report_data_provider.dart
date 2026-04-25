/// موفّر بيانات التقرير استناداً لإعدادات [ReportConfig]
///
/// يُغلّف منطق جلب/فلترة/تجميع السجلات من DAOs ويعود
/// بـ [ReportResult] (الصفوف + الإجماليات). يُستدعى يدويّاً
/// بالضغط على زر "توليد التقرير" وليس عند كل تغيير.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:drift/drift.dart' show Variable;
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_reports/alhai_reports.dart' show PaymentAggregator;

import '../../../../core/services/sentry_service.dart';
import 'report_config_notifier.dart';

/// نتيجة توليد تقرير: صفوف + إجمالي قيمة + إجمالي عدد
@immutable
class ReportResult {
  final List<Map<String, dynamic>> rows;
  final double totalValue;
  final int totalCount;

  const ReportResult({
    required this.rows,
    required this.totalValue,
    required this.totalCount,
  });

  static const empty = ReportResult(rows: [], totalValue: 0, totalCount: 0);
}

/// بند تجميع داخلي (قبل التحويل إلى Map)
///
/// `quantity` (previously named `count`) may be fractional — e.g. an inventory
/// report rolling up `stock_qty` for weighed goods (0.75 kg). The aggregation
/// downstream casts it back to `int` for the "total transactions" KPI, but
/// the row-level display in the preview keeps the fractional part via
/// `toStringAsFixed(2)` (P1 #4 2026-04-24).
class _GroupItem {
  final DateTime date;
  final double value;
  final double quantity;
  final String? label;

  _GroupItem({
    required this.date,
    required this.value,
    required this.quantity,
    this.label,
  });
}

/// مولّد التقارير — نقطة دخول منفصلة عن الواجهة لسهولة الاختبار
class ReportDataRepository {
  final AppDatabase _db;

  ReportDataRepository(this._db);

  /// ينتج [ReportResult] وفق [config] و [storeId].
  Future<ReportResult> generate({
    required String storeId,
    required ReportConfig config,
  }) async {
    final range = config.dateRange;
    if (range == null) return ReportResult.empty;

    // Phase 5 §5.4 — trace report generation (dashboard-tier rollup).
    return tracePerformance(
      name: 'generateReport',
      operation: 'db.query',
      data: {
        'report_type': config.reportType,
        'group_by': config.groupBy,
      },
      body: () async {
        List<Map<String, dynamic>> rows;
        switch (config.reportType) {
          case 'sales':
            rows = await _sales(storeId, config, range);
            break;
          case 'inventory':
            rows = await _inventory(storeId);
            break;
          case 'customers':
            rows = await _customers(storeId, config, range);
            break;
          case 'payments':
            rows = await _payments(storeId, range);
            break;
          default:
            rows = const [];
        }

        // P2 #4 (2026-04-24): `count` in raw rows is polymorphic —
        //   - inventory reports store it as `double` (fractional stock units,
        //     e.g. 0.75 kg), preserved via `_GroupItem.quantity`.
        //   - sales/customers/payments store it as `int` (transaction count).
        // The aggregate KPI collapses to int by truncation. The preview
        // widget formats per-row according to the report type.
        double total = 0;
        int count = 0;
        for (final row in rows) {
          total += (row['value'] as double?) ?? 0;
          final rawCount = row['count'];
          if (rawCount is int) {
            count += rawCount;
          } else if (rawCount is double) {
            count += rawCount.toInt();
          }
        }

        return ReportResult(
          rows: rows,
          totalValue: total,
          totalCount: count,
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _sales(
    String storeId,
    ReportConfig config,
    DateTimeRange range,
  ) async {
    // Wave 8 (P0-33): push the date filter to SQL. The previous path
    // pulled `getAllSales` (1000-row silent ceiling) then filtered in
    // Dart — a long-history store missed older rows entirely. The
    // status filter still happens client-side because the grouping API
    // wants the rows, not just totals; here the row count is bounded by
    // the report's range so 5000 is a safer ceiling than the unbounded
    // store-wide call we used to make.
    final sales = await _db.salesDao.getSalesByDateRange(
      storeId,
      range.start,
      range.end.add(const Duration(days: 1)),
    );
    final filtered = sales
        .where((o) => o.status == 'completed' || o.status == 'paid')
        .toList();

    return _groupByKey(
      config.groupBy,
      // C-4 Session 3: sale.total is int cents; _GroupItem.value is SAR.
      filtered
          .map(
            (o) => _GroupItem(
              date: o.createdAt,
              value: o.total / 100.0,
              quantity: 1,
            ),
          )
          .toList(),
    );
  }

  Future<List<Map<String, dynamic>>> _inventory(String storeId) async {
    final products = await _db.productsDao.getAllProducts(storeId);
    final Map<String, _GroupItem> grouped = {};
    for (final product in products) {
      final key = product.categoryId ?? 'uncategorized';
      // Sprint 1 / P0-17: inventory valuation must use cost basis, not the
      // retail price. The previous code multiplied stock by `product.price`
      // (sell price), which inflated balance-sheet inventory assets by the
      // markup percentage — a real accounting error. We now use
      // `product.costPrice`; rows with a null cost (legacy entries before
      // cost tracking) contribute zero rather than the misleading sell
      // price. Sprint 2 — `add_inventory` will require unit_cost on every
      // movement, closing the null-cost gap going forward.
      final unitCostCents = product.costPrice ?? 0;
      final lineValue = (unitCostCents / 100.0) * product.stockQty;
      final existing = grouped[key];
      if (existing != null) {
        grouped[key] = _GroupItem(
          date: DateTime.now(),
          value: existing.value + lineValue,
          quantity: existing.quantity + product.stockQty,
          label: key,
        );
      } else {
        grouped[key] = _GroupItem(
          date: DateTime.now(),
          value: lineValue,
          quantity: product.stockQty,
          label: key,
        );
      }
    }
    return grouped.entries
        .map(
          (e) => {
            'label': e.key,
            'value': e.value.value,
            // P1 #4 (2026-04-24): fractional quantity (e.g. 0.75 kg) is preserved
            // in the raw map so the preview can format it with
            // `toStringAsFixed(2)`. The aggregate KPI still casts to int via
            // `rawCount.toInt()` in `generate()`.
            'count': e.value.quantity,
          },
        )
        .toList();
  }

  Future<List<Map<String, dynamic>>> _customers(
    String storeId,
    ReportConfig config,
    DateTimeRange range,
  ) async {
    // Wave 8 (P0-33): push the date filter to SQL. `getAllCustomers`
    // capped at 500 rows hid older signups in long-tenured stores; the
    // direct query bounds the result by the report range instead.
    final endExclusive = range.end.add(const Duration(days: 1));
    final rows = await _db
        .customSelect(
          'SELECT id, name, created_at FROM customers '
          'WHERE store_id = ? AND created_at >= ? AND created_at < ? '
          'ORDER BY created_at',
          variables: [
            Variable.withString(storeId),
            Variable.withDateTime(range.start),
            Variable.withDateTime(endExclusive),
          ],
        )
        .get();

    final filtered = rows
        .map(
          (r) => _GroupItem(
            date:
                DateTime.tryParse(r.data['created_at'].toString()) ??
                DateTime.now(),
            value: 0,
            quantity: 1,
          ),
        )
        .toList();

    return _groupByKey(config.groupBy, filtered);
  }

  Future<List<Map<String, dynamic>>> _payments(
    String storeId,
    DateTimeRange range,
  ) async {
    // Wave 8 (P0-33): SQL aggregation directly — same per-tender semantics
    // as PaymentAggregator.aggregate, but no row materialisation and no
    // 1000/5000-row truncation hazard. payment_reports_screen uses the
    // same path; reports cannot disagree.
    final raw = await _db.salesDao.aggregatePaymentBreakdownRaw(
      storeId,
      from: range.start,
      to: range.end.add(const Duration(days: 1)),
    );
    final breakdown = PaymentAggregator.fromRaw(raw);

    final rows = <Map<String, dynamic>>[];
    if (breakdown.cashCount > 0 || breakdown.cashCents > 0) {
      rows.add({
        'label': 'cash',
        'value': breakdown.cashSar,
        'count': breakdown.cashCount,
      });
    }
    if (breakdown.cardCount > 0 || breakdown.cardCents > 0) {
      rows.add({
        'label': 'card',
        'value': breakdown.cardSar,
        'count': breakdown.cardCount,
      });
    }
    if (breakdown.creditCount > 0 || breakdown.creditCents > 0) {
      rows.add({
        'label': 'credit',
        'value': breakdown.creditSar,
        'count': breakdown.creditCount,
      });
    }
    return rows;
  }

  List<Map<String, dynamic>> _groupByKey(
    String groupBy,
    List<_GroupItem> items,
  ) {
    final Map<String, Map<String, dynamic>> grouped = {};

    for (final item in items) {
      final key = _keyFor(groupBy, item.date);
      if (grouped.containsKey(key)) {
        grouped[key]!['value'] =
            (grouped[key]!['value'] as double) + item.value;
        grouped[key]!['count'] =
            (grouped[key]!['count'] as double) + item.quantity;
      } else {
        grouped[key] = {
          'label': key,
          'value': item.value,
          'count': item.quantity,
        };
      }
    }

    final result = grouped.values.toList();
    result.sort(
      (a, b) => (a['label'] as String).compareTo(b['label'] as String),
    );
    return result;
  }

  String _keyFor(String groupBy, DateTime date) {
    switch (groupBy) {
      case 'day':
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      case 'week':
        final weekStart = date.subtract(Duration(days: date.weekday - 1));
        return '${weekStart.year}-W${_weekNumber(weekStart).toString().padLeft(2, '0')}';
      case 'month':
        return '${date.year}-${date.month.toString().padLeft(2, '0')}';
      default:
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }

  /// Compute ISO 8601 week number.
  ///
  /// P2 #3 (2026-04-24): prior implementation (`(dayOfYear + 10) / 7`) wasn't
  /// anchored to Monday and could straddle years incorrectly. The corrected
  /// formula accounts for `date.weekday` (Mon=1..Sun=7) and produces the
  /// standard ISO week.
  int _weekNumber(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays + 1;
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }
}

/// Provider للـ repository (يستخدم GetIt لتوفير AppDatabase)
final reportDataRepositoryProvider = Provider.autoDispose<ReportDataRepository>(
  (ref) => ReportDataRepository(GetIt.I<AppDatabase>()),
);
