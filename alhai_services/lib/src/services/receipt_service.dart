import 'package:alhai_core/alhai_core.dart';

/// خدمة توليد الفواتير
/// تستخدم من: cashier
class ReceiptService {
  /// توليد محتوى الفاتورة كنص
  String generateReceiptText({
    required Order order,
    required Store store,
    StoreSettings? settings,
    String? cashierName,
  }) {
    final buffer = StringBuffer();
    final divider = '=' * 32;
    final thinDivider = '-' * 32;

    // Header
    if (settings?.receiptHeader != null) {
      buffer.writeln(settings!.receiptHeader);
      buffer.writeln();
    }

    buffer.writeln(_center(store.name, 32));
    buffer.writeln(_center(store.address, 32));
    if (store.phone != null) {
      buffer.writeln(_center('هاتف: ${store.phone}', 32));
    }
    buffer.writeln();
    buffer.writeln(divider);

    // Order info
    buffer.writeln('رقم الفاتورة: ${order.displayNumber}');
    buffer.writeln('التاريخ: ${_formatDate(order.createdAt)}');
    buffer.writeln('الوقت: ${_formatTime(order.createdAt)}');
    if (cashierName != null) {
      buffer.writeln('الكاشير: $cashierName');
    }
    buffer.writeln(thinDivider);

    // Items
    buffer.writeln(_padRight('الصنف', 20) + _padLeft('المبلغ', 12));
    buffer.writeln(thinDivider);

    for (final item in order.items) {
      buffer.writeln(item.name);
      buffer.writeln(
        '  ${item.qty} x ${_formatPrice(item.unitPrice)} = ${_formatPrice(item.lineTotal)}',
      );
    }

    buffer.writeln(thinDivider);

    // Totals
    buffer.writeln(
      _padRight('المجموع الفرعي:', 20) +
          _padLeft(_formatPrice(order.subtotal), 12),
    );

    if (order.discount > 0) {
      buffer.writeln(
        _padRight('الخصم:', 20) +
            _padLeft('-${_formatPrice(order.discount)}', 12),
      );
    }

    if (order.tax > 0) {
      buffer.writeln(
        _padRight('الضريبة:', 20) + _padLeft(_formatPrice(order.tax), 12),
      );
    }

    buffer.writeln(divider);
    buffer.writeln(
      _padRight('الإجمالي:', 20) + _padLeft(_formatPrice(order.total), 12),
    );
    buffer.writeln(divider);

    // Payment
    buffer.writeln(
      'طريقة الدفع: ${_getPaymentMethodArabic(order.paymentMethod)}',
    );

    // Footer
    buffer.writeln();
    if (settings?.receiptFooter != null) {
      buffer.writeln(_center(settings!.receiptFooter!, 32));
    } else {
      buffer.writeln(_center('شكراً لزيارتكم', 32));
      buffer.writeln(_center('نتمنى لكم يوماً سعيداً', 32));
    }

    return buffer.toString();
  }

  /// توليد فاتورة HTML
  String generateReceiptHtml({
    required Order order,
    required Store store,
    StoreSettings? settings,
    String? cashierName,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('<!DOCTYPE html>');
    buffer.writeln('<html dir="rtl" lang="ar">');
    buffer.writeln('<head>');
    buffer.writeln('<meta charset="UTF-8">');
    buffer.writeln('<style>');
    buffer.writeln(
      'body { font-family: Arial, sans-serif; font-size: 12px; width: 80mm; margin: 0 auto; }',
    );
    buffer.writeln('.header { text-align: center; margin-bottom: 10px; }');
    buffer.writeln('.divider { border-top: 1px dashed #000; margin: 5px 0; }');
    buffer.writeln('.item { display: flex; justify-content: space-between; }');
    buffer.writeln('.total { font-weight: bold; font-size: 14px; }');
    buffer.writeln('.footer { text-align: center; margin-top: 10px; }');
    buffer.writeln('</style>');
    buffer.writeln('</head>');
    buffer.writeln('<body>');

    // Header - all user data is HTML-escaped to prevent XSS
    buffer.writeln('<div class="header">');
    if (settings?.receiptHeader != null) {
      buffer.writeln('<p>${_escapeHtml(settings!.receiptHeader!)}</p>');
    }
    buffer.writeln('<h2>${_escapeHtml(store.name)}</h2>');
    buffer.writeln('<p>${_escapeHtml(store.address)}</p>');
    if (store.phone != null) {
      buffer.writeln('<p>هاتف: ${_escapeHtml(store.phone!)}</p>');
    }
    buffer.writeln('</div>');

    buffer.writeln('<div class="divider"></div>');

    // Order info
    buffer.writeln('<p>رقم الفاتورة: ${_escapeHtml(order.displayNumber)}</p>');
    buffer.writeln(
      '<p>التاريخ: ${_formatDate(order.createdAt)} ${_formatTime(order.createdAt)}</p>',
    );
    if (cashierName != null) {
      buffer.writeln('<p>الكاشير: ${_escapeHtml(cashierName)}</p>');
    }

    buffer.writeln('<div class="divider"></div>');

    // Items
    for (final item in order.items) {
      buffer.writeln('<div class="item">');
      buffer.writeln('<span>${_escapeHtml(item.name)}</span>');
      buffer.writeln(
        '<span>${item.qty} x ${_formatPrice(item.unitPrice)} = ${_formatPrice(item.lineTotal)}</span>',
      );
      buffer.writeln('</div>');
    }

    buffer.writeln('<div class="divider"></div>');

    // Totals
    buffer.writeln(
      '<div class="item"><span>المجموع الفرعي:</span><span>${_formatPrice(order.subtotal)}</span></div>',
    );
    if (order.discount > 0) {
      buffer.writeln(
        '<div class="item"><span>الخصم:</span><span>-${_formatPrice(order.discount)}</span></div>',
      );
    }
    if (order.tax > 0) {
      buffer.writeln(
        '<div class="item"><span>الضريبة:</span><span>${_formatPrice(order.tax)}</span></div>',
      );
    }
    buffer.writeln('<div class="divider"></div>');
    buffer.writeln(
      '<div class="item total"><span>الإجمالي:</span><span>${_formatPrice(order.total)}</span></div>',
    );

    // Footer
    buffer.writeln('<div class="footer">');
    buffer.writeln(
      '<p>${_escapeHtml(settings?.receiptFooter ?? 'شكراً لزيارتكم')}</p>',
    );
    buffer.writeln('</div>');

    buffer.writeln('</body></html>');

    return buffer.toString();
  }

  // ==================== Helpers ====================

  /// HTML-encode a string to prevent XSS
  String _escapeHtml(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;');
  }

  String _formatPrice(double price) =>
      '${price.toStringAsFixed(2)} ${StoreSettings.defaultCurrencySymbol}';

  String _formatDate(DateTime date) =>
      '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';

  String _formatTime(DateTime date) =>
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

  String _center(String text, int width) {
    if (text.length >= width) return text;
    final padding = (width - text.length) ~/ 2;
    return ' ' * padding + text;
  }

  String _padRight(String text, int width) {
    if (text.length >= width) return text;
    return text + ' ' * (width - text.length);
  }

  String _padLeft(String text, int width) {
    if (text.length >= width) return text;
    return ' ' * (width - text.length) + text;
  }

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
}
