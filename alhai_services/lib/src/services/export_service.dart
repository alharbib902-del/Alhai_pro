import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:alhai_core/alhai_core.dart';

// ============================================================================
// Top-level functions for compute() isolate offloading
// These must be top-level (not closures) so they can be sent to isolates.
// ============================================================================

/// Build CSV string from serialized product maps
String _buildProductsCsv(List<Map<String, dynamic>> products) {
  final buffer = StringBuffer();

  // Header
  buffer.writeln('الباركود,اسم المنتج,السعر,المخزون,الفئة');

  // Data
  for (final p in products) {
    buffer.writeln(
      '${p['barcode'] ?? ''},${_escapeCsv(p['name'] as String? ?? '')},${(p['price'] as num).toStringAsFixed(2)},${p['stockQty'] ?? 0},${p['categoryId'] ?? ''}',
    );
  }

  return buffer.toString();
}

/// Build CSV string from serialized debt maps
String _buildDebtsCsv(List<Map<String, dynamic>> debts) {
  final buffer = StringBuffer();

  // Header
  buffer.writeln(
    'اسم الطرف,الهاتف,المبلغ الأصلي,المتبقي,تاريخ الاستحقاق,النوع',
  );

  // Data
  for (final d in debts) {
    final dueDate = d['dueDate'] as String?;
    buffer.writeln(
      '${_escapeCsv(d['partyName'] as String? ?? '')},${d['partyPhone'] ?? ''},${(d['originalAmount'] as num).toStringAsFixed(2)},${(d['remainingAmount'] as num).toStringAsFixed(2)},${dueDate ?? ''},${d['_debtTypeArabic'] ?? ''}',
    );
  }

  return buffer.toString();
}

/// Build CSV string from serialized order maps
String _buildOrdersCsv(List<Map<String, dynamic>> orders) {
  final buffer = StringBuffer();

  // Header
  buffer.writeln('رقم الطلب,التاريخ,الوقت,العميل,الإجمالي,الحالة,طريقة الدفع');

  // Data
  for (final o in orders) {
    buffer.writeln(
      '${o['_displayNumber'] ?? ''},${o['_date'] ?? ''},${o['_time'] ?? ''},${_escapeCsv(o['customerName'] as String? ?? '')},${(o['total'] as num).toStringAsFixed(2)},${o['_statusArabic'] ?? ''},${o['_paymentMethodArabic'] ?? ''}',
    );
  }

  return buffer.toString();
}

/// Build JSON string from data (for isolate)
String _buildJsonString(List<Map<String, dynamic>> data) {
  return const JsonEncoder.withIndent('  ').convert(data);
}

/// Build HTML table from data and optional title (for isolate)
/// Receives a map with 'data' and optional 'title' keys.
String _buildHtmlTable(Map<String, dynamic> params) {
  final data = (params['data'] as List).cast<Map<String, dynamic>>();
  final title = params['title'] as String?;
  final exportTimestamp = params['exportTimestamp'] as String? ?? '';

  if (data.isEmpty) return '<p>لا توجد بيانات</p>';

  final buffer = StringBuffer();

  buffer.writeln('<!DOCTYPE html>');
  buffer.writeln('<html dir="rtl" lang="ar">');
  buffer.writeln('<head>');
  buffer.writeln('<meta charset="UTF-8">');
  buffer.writeln('<style>');
  buffer.writeln('body { font-family: Arial, sans-serif; padding: 20px; }');
  buffer.writeln('table { border-collapse: collapse; width: 100%; }');
  buffer.writeln(
    'th, td { border: 1px solid #ddd; padding: 12px; text-align: right; }',
  );
  buffer.writeln('th { background-color: #4CAF50; color: white; }');
  buffer.writeln('tr:nth-child(even) { background-color: #f2f2f2; }');
  buffer.writeln('h1 { color: #333; }');
  buffer.writeln('</style>');
  buffer.writeln('</head>');
  buffer.writeln('<body>');

  if (title != null) {
    buffer.writeln('<h1>$title</h1>');
  }

  buffer.writeln('<table>');

  // Header
  buffer.writeln('<tr>');
  for (final key in data.first.keys) {
    buffer.writeln('<th>${_escapeCsv(key)}</th>');
  }
  buffer.writeln('</tr>');

  // Data
  for (final row in data) {
    buffer.writeln('<tr>');
    for (final value in row.values) {
      buffer.writeln('<td>${_escapeCsv(value?.toString() ?? '')}</td>');
    }
    buffer.writeln('</tr>');
  }

  buffer.writeln('</table>');
  buffer.writeln('<p style="margin-top: 20px; color: #666;">');
  buffer.writeln('تم التصدير في: $exportTimestamp');
  buffer.writeln('</p>');
  buffer.writeln('</body></html>');

  return buffer.toString();
}

// Shared helper used by both top-level functions and the class
String _escapeCsv(String text) {
  if (text.contains(',') || text.contains('"') || text.contains('\n')) {
    return '"${text.replaceAll('"', '""')}"';
  }
  return text;
}

String _formatDate(DateTime date) =>
    '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';

String _formatTime(DateTime date) =>
    '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

/// خدمة التصدير
/// تستخدم من: admin_pos, cashier
///
/// Heavy CSV/JSON/HTML generation is offloaded to isolates via compute()
/// on native platforms. On web (where isolates are not supported), the
/// work runs on the main thread.
class ExportService {
  /// تصدير المنتجات إلى CSV (isolate-safe)
  Future<String> exportProductsToCsv(List<Product> products) async {
    // Serialize to plain maps so data is sendable across isolates
    final maps = products.map((p) => p.toJson()).toList();

    if (kIsWeb) {
      return _buildProductsCsv(maps);
    }
    return compute(_buildProductsCsv, maps);
  }

  /// تصدير الديون إلى CSV (isolate-safe)
  Future<String> exportDebtsToCsv(List<Debt> debts) async {
    // Pre-compute Arabic labels on the main thread then serialize
    final maps = debts.map((debt) {
      final json = debt.toJson();
      // Inject pre-computed Arabic label and formatted date
      json['_debtTypeArabic'] = _getDebtTypeArabic(debt.type);
      if (debt.dueDate != null) {
        json['dueDate'] = _formatDate(debt.dueDate!);
      }
      return json;
    }).toList();

    if (kIsWeb) {
      return _buildDebtsCsv(maps);
    }
    return compute(_buildDebtsCsv, maps);
  }

  /// تصدير الطلبات إلى CSV (isolate-safe)
  Future<String> exportOrdersToCsv(List<Order> orders) async {
    // Pre-compute display values on the main thread (they rely on enums/extensions)
    final maps = orders.map((order) {
      final json = <String, dynamic>{
        'customerName': order.customerName ?? '',
        'total': order.total,
        '_displayNumber': order.displayNumber,
        '_date': _formatDate(order.createdAt),
        '_time': _formatTime(order.createdAt),
        '_statusArabic': order.status.displayNameAr,
        '_paymentMethodArabic': _getPaymentMethodArabic(order.paymentMethod),
      };
      return json;
    }).toList();

    if (kIsWeb) {
      return _buildOrdersCsv(maps);
    }
    return compute(_buildOrdersCsv, maps);
  }

  /// تصدير البيانات إلى JSON (isolate-safe)
  Future<String> exportToJson(List<Map<String, dynamic>> data) async {
    if (kIsWeb) {
      return _buildJsonString(data);
    }
    return compute(_buildJsonString, data);
  }

  /// توليد HTML table (isolate-safe)
  Future<String> exportToHtmlTable(
    List<Map<String, dynamic>> data, {
    String? title,
  }) async {
    if (data.isEmpty) return '<p>لا توجد بيانات</p>';

    final now = DateTime.now();
    final params = <String, dynamic>{
      'data': data,
      'title': title,
      'exportTimestamp': '${_formatDate(now)} ${_formatTime(now)}',
    };

    if (kIsWeb) {
      return _buildHtmlTable(params);
    }
    return compute(_buildHtmlTable, params);
  }

  // ==================== Helpers ====================

  static String _getPaymentMethodArabic(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'نقدي';
      case PaymentMethod.card:
        return 'بطاقة';
      case PaymentMethod.wallet:
        return 'محفظة';
      case PaymentMethod.bankTransfer:
        return 'تحويل بنكي';
    }
  }

  static String _getDebtTypeArabic(DebtType type) {
    switch (type) {
      case DebtType.customerDebt:
        return 'دين عميل';
      case DebtType.supplierDebt:
        return 'دين مورد';
    }
  }
}
