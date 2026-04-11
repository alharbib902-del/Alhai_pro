/// ESC/POS receipt builder for thermal printers
///
/// Generates complete receipt byte sequences from [ReceiptData] using
/// raw ESC/POS commands. Supports Arabic text, ZATCA QR codes,
/// and standard 58mm/80mm paper widths.
///
/// All text is output in Arabic (RTL content printed LTR by the printer,
/// which handles bidi internally on most ESC/POS printers with Arabic support).
library;

import 'dart:typed_data';

import 'esc_pos_commands.dart';
import 'receipt_data.dart';
import 'print_service.dart' show PaperSize;

/// Builds ESC/POS byte commands for a thermal receipt
class ReceiptBuilder {
  ReceiptBuilder._();

  /// Build complete receipt bytes from structured data
  static Future<Uint8List> build(
    ReceiptData receipt, {
    PaperSize size = PaperSize.mm80,
  }) async {
    final cmd = EscPosCommandBuilder(charsPerLine: size.charsPerLine)
      ..initialize()
      ..setUtf8Mode();

    // ─── Store Header ──────────────────────────────────
    cmd
      ..setAlign(EscPosAlign.center)
      ..setTextSize(EscPosTextSize.doubleWidth)
      ..setBold(true)
      ..printLine(receipt.store.name)
      ..setTextSize(EscPosTextSize.normal)
      ..setBold(false)
      ..printLine(receipt.store.address)
      ..printLine('هاتف: ${receipt.store.phone}');

    if (receipt.store.crNumber != null) {
      cmd.printLine('سجل تجاري: ${receipt.store.crNumber}');
    }
    cmd
      ..printLine('الرقم الضريبي: ${receipt.store.vatNumber}')
      ..doubleLine();

    // ─── Receipt Info ──────────────────────────────────
    cmd.setAlign(EscPosAlign.left);

    final dateStr = _formatDate(receipt.dateTime);
    final timeStr = _formatTime(receipt.dateTime);

    cmd
      ..printTwoColumns('رقم الفاتورة:', receipt.receiptNumber)
      ..printTwoColumns('التاريخ:', dateStr)
      ..printTwoColumns('الوقت:', timeStr)
      ..printTwoColumns('الكاشير:', receipt.cashierName);

    if (receipt.customerName != null && receipt.customerName!.isNotEmpty) {
      cmd.printTwoColumns('العميل:', receipt.customerName!);
    }
    if (receipt.customerId != null && receipt.customerId!.isNotEmpty) {
      cmd.printTwoColumns('رقم العميل:', receipt.customerId!);
    }

    cmd.dashLine();

    // ─── Items Header ──────────────────────────────────
    cmd
      ..setBold(true)
      ..printThreeColumns('الصنف', 'الكمية × السعر', 'المجموع')
      ..setBold(false)
      ..dashLine();

    // ─── Items ─────────────────────────────────────────
    for (final item in receipt.items) {
      final qtyPrice =
          '${_formatQty(item.quantity)} × ${_formatMoney(item.unitPrice)}';
      final totalStr = _formatMoney(item.total);

      // If item name is long, print it on its own line then details below
      if (_estimateWidth(item.name) +
              _estimateWidth(qtyPrice) +
              _estimateWidth(totalStr) +
              2 >
          size.charsPerLine) {
        cmd
          ..printLine(item.name)
          ..printTwoColumns('  $qtyPrice', totalStr);
      } else {
        cmd.printThreeColumns(item.name, qtyPrice, totalStr);
      }
    }

    cmd.dashLine();

    // ─── Totals ────────────────────────────────────────
    cmd.printTwoColumns('المجموع الفرعي:', _formatMoney(receipt.subtotal));

    if (receipt.discount > 0) {
      cmd.printTwoColumns('الخصم:', '- ${_formatMoney(receipt.discount)}');
    }

    cmd
      ..printTwoColumns(
        'ضريبة القيمة المضافة (15%):',
        _formatMoney(receipt.tax),
      )
      ..doubleLine()
      ..setBold(true)
      ..setTextSize(EscPosTextSize.doubleHeight)
      ..printTwoColumns('الإجمالي:', '${_formatMoney(receipt.total)} ر.س')
      ..setTextSize(EscPosTextSize.normal)
      ..setBold(false)
      ..doubleLine();

    // ─── Payment Info ──────────────────────────────────
    cmd.printTwoColumns(
      'طريقة الدفع:',
      _translatePaymentMethod(receipt.paymentMethod),
    );

    if (receipt.amountReceived != null && receipt.amountReceived! > 0) {
      cmd.printTwoColumns(
        'المبلغ المدفوع:',
        _formatMoney(receipt.amountReceived!),
      );
    }
    if (receipt.changeAmount != null && receipt.changeAmount! > 0) {
      cmd.printTwoColumns('الباقي:', _formatMoney(receipt.changeAmount!));
    }

    cmd.dashLine();

    // ─── ZATCA QR Code ─────────────────────────────────
    if (receipt.zatcaQrData != null && receipt.zatcaQrData!.isNotEmpty) {
      cmd
        ..setAlign(EscPosAlign.center)
        ..emptyLine()
        ..printLine('رمز الفاتورة الإلكترونية')
        ..printQrCode(receipt.zatcaQrData!, moduleSize: 5)
        ..emptyLine();
    }

    // ─── Note ──────────────────────────────────────────
    if (receipt.note != null && receipt.note!.isNotEmpty) {
      cmd
        ..setAlign(EscPosAlign.center)
        ..printLine(receipt.note!);
    }

    // ─── Footer ────────────────────────────────────────
    cmd
      ..setAlign(EscPosAlign.center)
      ..dashLine()
      ..printLine('شكراً لزيارتكم')
      ..printLine('Thank you for visiting')
      ..emptyLine()
      ..printLine('تمت الطباعة بواسطة نظام الحي')
      ..feedLines(4)
      ..cutPaper();

    return cmd.build();
  }

  /// Build test page bytes
  static Future<Uint8List> buildTestPage({
    PaperSize size = PaperSize.mm80,
  }) async {
    final cmd = EscPosCommandBuilder(charsPerLine: size.charsPerLine)
      ..initialize()
      ..setUtf8Mode()
      ..setAlign(EscPosAlign.center)
      ..setTextSize(EscPosTextSize.doubleWidth)
      ..setBold(true)
      ..printLine('صفحة اختبار الطباعة')
      ..printLine('Print Test Page')
      ..setTextSize(EscPosTextSize.normal)
      ..setBold(false)
      ..doubleLine()
      ..setAlign(EscPosAlign.left)
      ..printLine('نظام الحي - نقاط البيع')
      ..printLine('Al-HAI POS System')
      ..dashLine()
      ..printTwoColumns('حجم الورق:', size == PaperSize.mm80 ? '80mm' : '58mm')
      ..printTwoColumns('أحرف في السطر:', '${size.charsPerLine}')
      ..printTwoColumns('التاريخ:', _formatDate(DateTime.now()))
      ..printTwoColumns('الوقت:', _formatTime(DateTime.now()))
      ..dashLine()
      ..setAlign(EscPosAlign.center)
      ..printLine('اختبار الخط العريض:')
      ..setBold(true)
      ..printLine('هذا نص عريض - Bold text')
      ..setBold(false)
      ..emptyLine()
      ..printLine('اختبار حجم النص:')
      ..setTextSize(EscPosTextSize.doubleWidth)
      ..printLine('نص عريض')
      ..setTextSize(EscPosTextSize.doubleHeight)
      ..printLine('نص طويل')
      ..setTextSize(EscPosTextSize.quadArea)
      ..printLine('كبير')
      ..setTextSize(EscPosTextSize.normal)
      ..emptyLine()
      ..printLine('اختبار رمز QR:')
      ..printQrCode('https://alhai.app', moduleSize: 6)
      ..emptyLine()
      ..doubleLine()
      ..printLine('الطابعة تعمل بنجاح')
      ..printLine('Printer is working')
      ..feedLines(4)
      ..cutPaper();

    return cmd.build();
  }

  /// Build cash drawer kick bytes
  static Future<Uint8List> buildCashDrawerKick({
    PaperSize size = PaperSize.mm80,
  }) async {
    final cmd = EscPosCommandBuilder(charsPerLine: size.charsPerLine)
      ..initialize()
      ..kickCashDrawer(pin: 0);
    return cmd.build();
  }

  // ─── Formatting Helpers ────────────────────────────────

  static String _formatDate(DateTime dt) {
    final y = dt.year.toString();
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y/$m/$d';
  }

  static String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$h:$min:$s';
  }

  static String _formatMoney(double amount) {
    // Format with 2 decimal places and comma separators
    final parts = amount.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final decPart = parts[1];

    // Add comma separators for thousands
    final buffer = StringBuffer();
    final digits = intPart.startsWith('-') ? intPart.substring(1) : intPart;
    final isNegative = intPart.startsWith('-');

    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(digits[i]);
    }

    final formatted = '${isNegative ? '-' : ''}${buffer.toString()}.$decPart';
    return formatted;
  }

  static String _formatQty(double qty) {
    // Show integer if whole number, otherwise 2 decimal places
    if (qty == qty.roundToDouble()) {
      return qty.toInt().toString();
    }
    return qty.toStringAsFixed(2);
  }

  static String _translatePaymentMethod(String method) {
    return switch (method.toLowerCase()) {
      'cash' => 'نقدي',
      'card' || 'credit_card' || 'credit' => 'بطاقة ائتمان',
      'mada' => 'مدى',
      'apple_pay' || 'applepay' => 'Apple Pay',
      'stc_pay' || 'stcpay' => 'STC Pay',
      'transfer' || 'bank_transfer' => 'تحويل بنكي',
      'split' => 'دفع مقسم',
      _ => method,
    };
  }

  static int _estimateWidth(String text) => text.length;
}
