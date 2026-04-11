/// Abstract print service for ESC/POS thermal printers
///
/// Provides the interface for connecting, printing receipts, and
/// controlling peripheral devices (cash drawer). Concrete implementations
/// handle Bluetooth, Network TCP, and Sunmi built-in printers.
library;

import 'dart:typed_data';

import 'receipt_data.dart';

/// Connection type of a discovered printer
enum PrinterConnectionType { bluetooth, network, usb, sunmi }

/// Status of the print service
enum PrinterStatus { disconnected, connecting, connected, printing, error }

/// A discovered printer device
class DiscoveredPrinter {
  final String id;
  final String name;
  final PrinterConnectionType type;
  final String? address; // IP for network, MAC for bluetooth

  const DiscoveredPrinter({
    required this.id,
    required this.name,
    required this.type,
    this.address,
  });

  @override
  String toString() => '$name ($address) [${type.name}]';
}

/// Result of a print operation
class PrintResult {
  final bool success;
  final String? error;

  const PrintResult({required this.success, this.error});

  factory PrintResult.ok() => const PrintResult(success: true);
  factory PrintResult.fail(String error) =>
      PrintResult(success: false, error: error);
}

/// Paper width for ESC/POS formatting
enum PaperSize {
  mm58(32), // 32 chars per line
  mm80(48); // 48 chars per line

  const PaperSize(this.charsPerLine);
  final int charsPerLine;
}

/// Abstract print service interface
abstract class ThermalPrintService {
  /// Current connection status
  PrinterStatus get status;

  /// Name of the currently connected printer
  String? get connectedPrinterName;

  /// Paper size (default 80mm)
  PaperSize get paperSize;
  set paperSize(PaperSize size);

  /// Scan for available printers of this service's type
  Future<List<DiscoveredPrinter>> scanForPrinters({
    Duration timeout = const Duration(seconds: 10),
  });

  /// Connect to a specific printer
  Future<bool> connect(DiscoveredPrinter printer);

  /// Disconnect from the current printer
  Future<void> disconnect();

  /// Print a formatted receipt from structured data
  Future<PrintResult> printReceipt(ReceiptData receipt);

  /// Print raw ESC/POS bytes (for advanced use)
  Future<PrintResult> printRawBytes(Uint8List bytes);

  /// Print a test page
  Future<PrintResult> printTestPage();

  /// Open the cash drawer via ESC/POS pulse command
  Future<PrintResult> openCashDrawer();
}
