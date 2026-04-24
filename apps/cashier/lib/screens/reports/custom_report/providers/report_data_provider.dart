/// موفّر بيانات التقرير استناداً لإعدادات [ReportConfig]
///
/// يُغلّف منطق جلب/فلترة/تجميع السجلات من DAOs ويعود
/// بـ [ReportResult] (الصفوف + الإجماليات). يُستدعى يدويّاً
/// بالضغط على زر "توليد التقرير" وليس عند كل تغيير.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_database/alhai_database.dart';

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
class _GroupItem {
  final DateTime date;
  final double value;
  final double count;
  final String? label;

  _GroupItem({
    required this.date,
    required this.value,
    required this.count,
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
  }

  Future<List<Map<String, dynamic>>> _sales(
    String storeId,
    ReportConfig config,
    DateTimeRange range,
  ) async {
    final sales = await _db.salesDao.getAllSales(storeId);
    final filtered = sales.where((o) {
      return o.createdAt.isAfter(range.start) &&
          o.createdAt.isBefore(range.end.add(const Duration(days: 1)));
    }).toList();

    return _groupByKey(
      config.groupBy,
      // C-4 Session 3: sale.total is int cents; _GroupItem.value is SAR.
      filtered
          .map(
            (o) => _GroupItem(
              date: o.createdAt,
              value: o.total / 100.0,
              count: 1,
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
      final existing = grouped[key];
      if (existing != null) {
        grouped[key] = _GroupItem(
          date: DateTime.now(),
          value: existing.value + (product.price * product.stockQty),
          count: existing.count + product.stockQty,
          label: key,
        );
      } else {
        grouped[key] = _GroupItem(
          date: DateTime.now(),
          value: product.price * product.stockQty,
          count: product.stockQty,
          label: key,
        );
      }
    }
    return grouped.entries
        .map(
          (e) => {
            'label': e.key,
            'value': e.value.value,
            'count': e.value.count,
          },
        )
        .toList();
  }

  Future<List<Map<String, dynamic>>> _customers(
    String storeId,
    ReportConfig config,
    DateTimeRange range,
  ) async {
    final customers = await _db.customersDao.getAllCustomers(storeId);
    final filtered = customers.where((c) {
      return c.createdAt.isAfter(range.start) &&
          c.createdAt.isBefore(range.end.add(const Duration(days: 1)));
    }).toList();

    return _groupByKey(
      config.groupBy,
      filtered
          .map((c) => _GroupItem(date: c.createdAt, value: 0, count: 1))
          .toList(),
    );
  }

  Future<List<Map<String, dynamic>>> _payments(
    String storeId,
    DateTimeRange range,
  ) async {
    final sales = await _db.salesDao.getAllSales(storeId);
    final filtered = sales.where((o) {
      return o.createdAt.isAfter(range.start) &&
          o.createdAt.isBefore(range.end.add(const Duration(days: 1)));
    }).toList();

    final Map<String, double> byMethod = {};
    final Map<String, int> countByMethod = {};
    for (final order in filtered) {
      final method = order.paymentMethod;
      byMethod[method] = (byMethod[method] ?? 0) + order.total;
      countByMethod[method] = (countByMethod[method] ?? 0) + 1;
    }

    return byMethod.entries
        .map(
          (e) => {
            'label': e.key,
            'value': e.value,
            'count': countByMethod[e.key] ?? 0,
          },
        )
        .toList();
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
            (grouped[key]!['count'] as double) + item.count;
      } else {
        grouped[key] = {'label': key, 'value': item.value, 'count': item.count};
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

  int _weekNumber(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
    return ((dayOfYear + 10) / 7).floor();
  }
}

/// Provider للـ repository (يستخدم GetIt لتوفير AppDatabase)
final reportDataRepositoryProvider = Provider.autoDispose<ReportDataRepository>(
  (ref) => ReportDataRepository(GetIt.I<AppDatabase>()),
);
