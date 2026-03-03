/// Sunmi built-in printer stub for web builds
///
/// The actual Sunmi printing package (sunmi_printer_plus) is not
/// available on web. This stub returns "not supported" for all operations.
library;

import 'dart:typed_data';

import 'print_service.dart';
import 'receipt_data.dart';

/// Sunmi printer stub (not supported on web)
class SunmiPrintService implements ThermalPrintService {
  PrinterStatus _status = PrinterStatus.disconnected;
  PaperSize _paperSize = PaperSize.mm58;

  @override
  PrinterStatus get status => _status;

  @override
  String? get connectedPrinterName => null;

  @override
  PaperSize get paperSize => _paperSize;

  @override
  set paperSize(PaperSize size) => _paperSize = size;

  @override
  Future<List<DiscoveredPrinter>> scanForPrinters({
    Duration timeout = const Duration(seconds: 10),
  }) async =>
      [];

  @override
  Future<bool> connect(DiscoveredPrinter printer) async => false;

  @override
  Future<void> disconnect() async {
    _status = PrinterStatus.disconnected;
  }

  @override
  Future<PrintResult> printReceipt(ReceiptData receipt) async =>
      PrintResult.fail('Sunmi printing not supported on web');

  @override
  Future<PrintResult> printRawBytes(Uint8List bytes) async =>
      PrintResult.fail('Sunmi printing not supported on web');

  @override
  Future<PrintResult> printTestPage() async =>
      PrintResult.fail('Sunmi printing not supported on web');

  @override
  Future<PrintResult> openCashDrawer() async =>
      PrintResult.fail('Sunmi printing not supported on web');
}
