/// Sunmi built-in printer service
///
/// Communicates with the built-in thermal printer on Sunmi Android POS
/// devices (V2, V2 Pro, T2, etc.) via platform channel. The Sunmi
/// printer uses a proprietary SDK rather than raw ESC/POS commands,
/// so this service translates receipt data into Sunmi-specific calls.
///
/// Platform channel: `com.alhai.cashier/sunmi_printer`
/// Native side wraps the Sunmi Inner Printer SDK (AIDL service).
///
/// On non-Sunmi devices or web, all operations return "not supported".
library;

import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode, debugPrint;
import 'package:flutter/services.dart';

import 'print_service.dart';
import 'receipt_data.dart';

/// Sunmi built-in thermal printer service
class SunmiPrintService implements ThermalPrintService {
  static const _channel = MethodChannel('com.alhai.cashier/sunmi_printer');

  PrinterStatus _status = PrinterStatus.disconnected;
  PaperSize _paperSize = PaperSize.mm58; // Sunmi devices are typically 58mm
  String? _connectedPrinterName;
  bool _isSunmiDevice = false;

  @override
  PrinterStatus get status => _status;

  @override
  String? get connectedPrinterName => _connectedPrinterName;

  @override
  PaperSize get paperSize => _paperSize;

  @override
  set paperSize(PaperSize size) => _paperSize = size;

  @override
  Future<List<DiscoveredPrinter>> scanForPrinters({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    if (kIsWeb) return [];

    try {
      final hasPrinter = await _channel.invokeMethod<bool>('hasPrinter');

      if (hasPrinter == true) {
        _isSunmiDevice = true;
        final model =
            await _channel.invokeMethod<String>('getModel') ?? 'Sunmi';

        return [
          DiscoveredPrinter(
            id: 'sunmi_builtin',
            name: 'Sunmi $model (مدمجة)',
            type: PrinterConnectionType.sunmi,
            address: 'builtin',
          ),
        ];
      }
    } on PlatformException catch (e) {
      if (kDebugMode) debugPrint('Sunmi scan error: ${e.message}');
    } on MissingPluginException {
      if (kDebugMode) {
        debugPrint(
            'Sunmi: platform channel not available (not a Sunmi device)');
      }
    }

    return [];
  }

  @override
  Future<bool> connect(DiscoveredPrinter printer) async {
    if (kIsWeb) return false;

    _status = PrinterStatus.connecting;

    try {
      // Initialize the Sunmi printer service (binds to AIDL)
      final success = await _channel.invokeMethod<bool>('initPrinter');

      if (success == true) {
        _status = PrinterStatus.connected;
        _connectedPrinterName = printer.name;
        _isSunmiDevice = true;
        return true;
      } else {
        _status = PrinterStatus.error;
        return false;
      }
    } on PlatformException catch (e) {
      if (kDebugMode) debugPrint('Sunmi init error: ${e.message}');
      _status = PrinterStatus.error;
      return false;
    } on MissingPluginException {
      _status = PrinterStatus.disconnected;
      return false;
    }
  }

  @override
  Future<void> disconnect() async {
    _status = PrinterStatus.disconnected;
    _connectedPrinterName = null;
    // Sunmi printer doesn't need explicit disconnect (AIDL auto-manages)
  }

  @override
  Future<PrintResult> printReceipt(ReceiptData receipt) async {
    if (kIsWeb || !_isSunmiDevice) {
      return PrintResult.fail('Sunmi printing not supported on this device');
    }

    if (_status != PrinterStatus.connected) {
      return PrintResult.fail('طابعة سنمي غير متصلة');
    }

    _status = PrinterStatus.printing;

    try {
      // Start a print transaction
      await _channel.invokeMethod<void>('beginTransaction');

      // ─── Store Header ──────────────────────────────
      await _sunmiSetAlign(1); // center
      await _sunmiSetBold(true);
      await _sunmiSetFontSize(28);
      await _sunmiPrintText('${receipt.store.name}\n');
      await _sunmiSetFontSize(22);
      await _sunmiSetBold(false);
      await _sunmiPrintText('${receipt.store.address}\n');
      await _sunmiPrintText('هاتف: ${receipt.store.phone}\n');
      if (receipt.store.crNumber != null) {
        await _sunmiPrintText('سجل تجاري: ${receipt.store.crNumber}\n');
      }
      await _sunmiPrintText('الرقم الضريبي: ${receipt.store.vatNumber}\n');
      await _sunmiPrintDivider();

      // ─── Receipt Info ──────────────────────────────
      await _sunmiSetAlign(0); // left
      await _sunmiSetFontSize(20);
      await _sunmiPrintRow('رقم الفاتورة:', receipt.receiptNumber);
      await _sunmiPrintRow('التاريخ:', _formatDate(receipt.dateTime));
      await _sunmiPrintRow('الوقت:', _formatTime(receipt.dateTime));
      await _sunmiPrintRow('الكاشير:', receipt.cashierName);

      if (receipt.customerName != null && receipt.customerName!.isNotEmpty) {
        await _sunmiPrintRow('العميل:', receipt.customerName!);
      }
      await _sunmiPrintDivider();

      // ─── Items Header ──────────────────────────────
      await _sunmiSetBold(true);
      await _sunmiPrintThreeCol('الصنف', 'الكمية × السعر', 'المجموع');
      await _sunmiSetBold(false);
      await _sunmiPrintDivider();

      // ─── Items ─────────────────────────────────────
      for (final item in receipt.items) {
        final qtyPrice =
            '${_formatQty(item.quantity)} × ${_formatMoney(item.unitPrice)}';
        await _sunmiPrintThreeCol(
            item.name, qtyPrice, _formatMoney(item.total));
      }
      await _sunmiPrintDivider();

      // ─── Totals ────────────────────────────────────
      await _sunmiPrintRow('المجموع الفرعي:', _formatMoney(receipt.subtotal));
      if (receipt.discount > 0) {
        await _sunmiPrintRow('الخصم:', '- ${_formatMoney(receipt.discount)}');
      }
      await _sunmiPrintRow(
          'ضريبة القيمة المضافة (15%):', _formatMoney(receipt.tax));

      await _sunmiSetBold(true);
      await _sunmiSetFontSize(26);
      await _sunmiPrintRow('الإجمالي:', '${_formatMoney(receipt.total)} ر.س');
      await _sunmiSetFontSize(20);
      await _sunmiSetBold(false);
      await _sunmiPrintDivider();

      // ─── Payment Info ──────────────────────────────
      await _sunmiPrintRow(
          'طريقة الدفع:', _translatePaymentMethod(receipt.paymentMethod));
      if (receipt.amountReceived != null && receipt.amountReceived! > 0) {
        await _sunmiPrintRow(
            'المبلغ المدفوع:', _formatMoney(receipt.amountReceived!));
      }
      if (receipt.changeAmount != null && receipt.changeAmount! > 0) {
        await _sunmiPrintRow('الباقي:', _formatMoney(receipt.changeAmount!));
      }

      // ─── ZATCA QR Code ─────────────────────────────
      if (receipt.zatcaQrData != null && receipt.zatcaQrData!.isNotEmpty) {
        await _sunmiSetAlign(1);
        await _sunmiPrintText('\nرمز الفاتورة الإلكترونية\n');
        await _sunmiPrintQr(receipt.zatcaQrData!);
        await _sunmiPrintText('\n');
      }

      // ─── Note ──────────────────────────────────────
      if (receipt.note != null && receipt.note!.isNotEmpty) {
        await _sunmiSetAlign(1);
        await _sunmiPrintText('${receipt.note!}\n');
      }

      // ─── Footer ────────────────────────────────────
      await _sunmiSetAlign(1);
      await _sunmiPrintDivider();
      await _sunmiPrintText('شكراً لزيارتكم\n');
      await _sunmiPrintText('Thank you for visiting\n\n');
      await _sunmiPrintText('تمت الطباعة بواسطة نظام الحي\n');

      // Feed and cut
      await _sunmiFeedAndCut();

      // Commit the transaction
      await _channel.invokeMethod<void>('commitTransaction');

      _status = PrinterStatus.connected;
      return PrintResult.ok();
    } on PlatformException catch (e) {
      _status = PrinterStatus.connected;
      return PrintResult.fail('خطأ في طابعة سنمي: ${e.message}');
    } catch (e) {
      _status = PrinterStatus.error;
      return PrintResult.fail('خطأ غير متوقع: $e');
    }
  }

  @override
  Future<PrintResult> printRawBytes(Uint8List bytes) async {
    if (kIsWeb || !_isSunmiDevice) {
      return PrintResult.fail('Sunmi printing not supported on this device');
    }

    try {
      await _channel.invokeMethod<void>('printRawData', {'data': bytes});
      return PrintResult.ok();
    } on PlatformException catch (e) {
      return PrintResult.fail('خطأ في طابعة سنمي: ${e.message}');
    }
  }

  @override
  Future<PrintResult> printTestPage() async {
    if (kIsWeb || !_isSunmiDevice) {
      return PrintResult.fail('Sunmi printing not supported on this device');
    }

    if (_status != PrinterStatus.connected) {
      return PrintResult.fail('طابعة سنمي غير متصلة');
    }

    _status = PrinterStatus.printing;

    try {
      await _channel.invokeMethod<void>('beginTransaction');

      await _sunmiSetAlign(1);
      await _sunmiSetBold(true);
      await _sunmiSetFontSize(28);
      await _sunmiPrintText('صفحة اختبار الطباعة\n');
      await _sunmiPrintText('Print Test Page\n');
      await _sunmiSetFontSize(22);
      await _sunmiSetBold(false);
      await _sunmiPrintDivider();
      await _sunmiSetAlign(0);
      await _sunmiPrintText('نظام الحي - نقاط البيع\n');
      await _sunmiPrintText('Al-HAI POS System\n');
      await _sunmiPrintDivider();
      await _sunmiPrintRow(
          'حجم الورق:', _paperSize == PaperSize.mm58 ? '58mm' : '80mm');
      await _sunmiPrintRow('التاريخ:', _formatDate(DateTime.now()));
      await _sunmiPrintRow('الوقت:', _formatTime(DateTime.now()));
      await _sunmiPrintDivider();
      await _sunmiSetAlign(1);
      await _sunmiPrintText('اختبار رمز QR:\n');
      await _sunmiPrintQr('https://alhai.app');
      await _sunmiPrintText('\n');
      await _sunmiPrintDivider();
      await _sunmiPrintText('الطابعة تعمل بنجاح\n');
      await _sunmiPrintText('Printer is working\n');
      await _sunmiFeedAndCut();

      await _channel.invokeMethod<void>('commitTransaction');

      _status = PrinterStatus.connected;
      return PrintResult.ok();
    } catch (e) {
      _status = PrinterStatus.connected;
      return PrintResult.fail('خطأ في صفحة الاختبار: $e');
    }
  }

  @override
  Future<PrintResult> openCashDrawer() async {
    if (kIsWeb || !_isSunmiDevice) {
      return PrintResult.fail('Sunmi cash drawer not supported on this device');
    }

    try {
      await _channel.invokeMethod<void>('openCashDrawer');
      return PrintResult.ok();
    } on PlatformException catch (e) {
      return PrintResult.fail('فشل فتح درج النقد: ${e.message}');
    }
  }

  // ─── Sunmi Channel Helpers ─────────────────────────────

  Future<void> _sunmiPrintText(String text) =>
      _channel.invokeMethod<void>('printText', {'text': text});

  Future<void> _sunmiSetAlign(int align) =>
      _channel.invokeMethod<void>('setAlign', {'align': align});

  Future<void> _sunmiSetBold(bool bold) =>
      _channel.invokeMethod<void>('setBold', {'bold': bold});

  Future<void> _sunmiSetFontSize(int size) =>
      _channel.invokeMethod<void>('setFontSize', {'size': size});

  Future<void> _sunmiPrintDivider() =>
      _channel.invokeMethod<void>('printDivider');

  Future<void> _sunmiPrintQr(String data) =>
      _channel.invokeMethod<void>('printQrCode', {
        'data': data,
        'moduleSize': 5,
        'errorLevel': 1, // M
      });

  Future<void> _sunmiFeedAndCut() =>
      _channel.invokeMethod<void>('feedAndCut', {'lines': 4});

  /// Print a two-column row using Sunmi's column print API
  Future<void> _sunmiPrintRow(String left, String right) =>
      _channel.invokeMethod<void>('printColumns', {
        'texts': [left, right],
        'widths': [1, 1],
        'aligns': [0, 2], // left, right
      });

  /// Print a three-column row
  Future<void> _sunmiPrintThreeCol(String left, String center, String right) =>
      _channel.invokeMethod<void>('printColumns', {
        'texts': [left, center, right],
        'widths': [2, 2, 1],
        'aligns': [0, 1, 2], // left, center, right
      });

  // ─── Formatting Helpers ────────────────────────────────

  String _formatDate(DateTime dt) =>
      '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';

  String _formatMoney(double amount) {
    final parts = amount.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final decPart = parts[1];
    final buffer = StringBuffer();
    final digits = intPart.startsWith('-') ? intPart.substring(1) : intPart;
    final isNegative = intPart.startsWith('-');

    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }

    return '${isNegative ? '-' : ''}${buffer.toString()}.$decPart';
  }

  String _formatQty(double qty) {
    if (qty == qty.roundToDouble()) return qty.toInt().toString();
    return qty.toStringAsFixed(2);
  }

  String _translatePaymentMethod(String method) {
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
}
