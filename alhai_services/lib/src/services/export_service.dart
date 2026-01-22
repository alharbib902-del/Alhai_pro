import 'dart:convert';

import 'package:alhai_core/alhai_core.dart';

/// خدمة التصدير
/// تستخدم من: admin_pos, pos_app
class ExportService {
  /// تصدير المنتجات إلى CSV
  String exportProductsToCsv(List<Product> products) {
    final buffer = StringBuffer();
    
    // Header
    buffer.writeln('الباركود,اسم المنتج,السعر,المخزون,الفئة');
    
    // Data
    for (final product in products) {
      buffer.writeln(
        '${product.barcode ?? ''},${_escapeCsv(product.name)},${product.price.toStringAsFixed(2)},${product.stockQty},${product.categoryId ?? ''}',
      );
    }
    
    return buffer.toString();
  }

  /// تصدير الديون إلى CSV
  String exportDebtsToCsv(List<Debt> debts) {
    final buffer = StringBuffer();
    
    // Header
    buffer.writeln('اسم الطرف,الهاتف,المبلغ الأصلي,المتبقي,تاريخ الاستحقاق,النوع');
    
    // Data
    for (final debt in debts) {
      buffer.writeln(
        '${_escapeCsv(debt.partyName)},${debt.partyPhone ?? ''},${debt.originalAmount.toStringAsFixed(2)},${debt.remainingAmount.toStringAsFixed(2)},${debt.dueDate != null ? _formatDate(debt.dueDate!) : ''},${_getDebtTypeArabic(debt.type)}',
      );
    }
    
    return buffer.toString();
  }

  /// تصدير الطلبات إلى CSV
  String exportOrdersToCsv(List<Order> orders) {
    final buffer = StringBuffer();
    
    // Header
    buffer.writeln('رقم الطلب,التاريخ,الوقت,العميل,الإجمالي,الحالة,طريقة الدفع');
    
    // Data
    for (final order in orders) {
      buffer.writeln(
        '${order.displayNumber},${_formatDate(order.createdAt)},${_formatTime(order.createdAt)},${_escapeCsv(order.customerName ?? '')},${order.total.toStringAsFixed(2)},${order.status.displayNameAr},${_getPaymentMethodArabic(order.paymentMethod)}',
      );
    }
    
    return buffer.toString();
  }

  /// تصدير البيانات إلى JSON
  String exportToJson(List<Map<String, dynamic>> data) {
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// توليد HTML table
  String exportToHtmlTable(List<Map<String, dynamic>> data, {String? title}) {
    if (data.isEmpty) return '<p>لا توجد بيانات</p>';
    
    final buffer = StringBuffer();
    
    buffer.writeln('<!DOCTYPE html>');
    buffer.writeln('<html dir="rtl" lang="ar">');
    buffer.writeln('<head>');
    buffer.writeln('<meta charset="UTF-8">');
    buffer.writeln('<style>');
    buffer.writeln('body { font-family: Arial, sans-serif; padding: 20px; }');
    buffer.writeln('table { border-collapse: collapse; width: 100%; }');
    buffer.writeln('th, td { border: 1px solid #ddd; padding: 12px; text-align: right; }');
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
    buffer.writeln('تم التصدير في: ${_formatDate(DateTime.now())} ${_formatTime(DateTime.now())}');
    buffer.writeln('</p>');
    buffer.writeln('</body></html>');
    
    return buffer.toString();
  }

  // ==================== Helpers ====================

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

  String _getPaymentMethodArabic(PaymentMethod method) {
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

  String _getDebtTypeArabic(DebtType type) {
    switch (type) {
      case DebtType.customerDebt:
        return 'دين عميل';
      case DebtType.supplierDebt:
        return 'دين مورد';
    }
  }
}
