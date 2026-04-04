/// Riverpod providers for the printing service layer
///
/// Manages the active print service, discovered printers, and default printer
/// configuration. Persists the preferred printer in SharedPreferences.
library;

import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'print_service.dart';
import 'print_queue_service.dart';
import 'receipt_data.dart';
import 'bluetooth_print_service.dart';
import 'network_print_service.dart';
import 'sunmi_print_service.dart';

// ─── Preference keys ────────────────────────────────────
const _kPrefPrinterType = 'pref_printer_type'; // bluetooth | network | sunmi
const _kPrefPrinterName = 'pref_printer_name';
const _kPrefPrinterAddress = 'pref_printer_address';
const _kPrefPaperSize = 'pref_paper_size'; // 58 | 80
const _kPrefAutoPrint = 'pref_auto_print'; // true | false

/// The currently active print service
final printServiceProvider =
    StateNotifierProvider<PrintServiceNotifier, ThermalPrintService?>(
  (ref) => PrintServiceNotifier(),
);

/// Whether auto-print is enabled after payment
final autoPrintEnabledProvider = StateProvider<bool>((ref) => false);

/// Current printer status
final printerStatusProvider = Provider<PrinterStatus>((ref) {
  final service = ref.watch(printServiceProvider);
  return service?.status ?? PrinterStatus.disconnected;
});

/// Connected printer name
final connectedPrinterNameProvider = Provider<String?>((ref) {
  final service = ref.watch(printServiceProvider);
  return service?.connectedPrinterName;
});

/// Manages the active print service lifecycle
class PrintServiceNotifier extends StateNotifier<ThermalPrintService?> {
  PrintServiceNotifier() : super(null);

  /// Initialize from saved preferences
  Future<void> loadSavedPrinter() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final type = prefs.getString(_kPrefPrinterType);
      final name = prefs.getString(_kPrefPrinterName);
      final address = prefs.getString(_kPrefPrinterAddress);
      final paperSizeValue = prefs.getInt(_kPrefPaperSize) ?? 80;
      final paperSize = paperSizeValue == 58 ? PaperSize.mm58 : PaperSize.mm80;

      if (type == null || name == null) return;

      final service = _createService(type);
      if (service == null) return;

      service.paperSize = paperSize;
      state = service;

      // Try to reconnect to the saved printer
      if (address != null) {
        final connectionType = _parseConnectionType(type);
        if (connectionType != null) {
          await service.connect(DiscoveredPrinter(
            id: address,
            name: name,
            type: connectionType,
            address: address,
          ));
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to load saved printer: $e');
    }
  }

  /// Set the active print service by type
  Future<void> setServiceType(String type) async {
    // Disconnect current service
    await state?.disconnect();

    final service = _createService(type);
    state = service;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPrefPrinterType, type);
  }

  /// Connect to a discovered printer and save as default
  Future<bool> connectAndSave(DiscoveredPrinter printer) async {
    if (state == null) return false;

    final success = await state!.connect(printer);
    if (success) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kPrefPrinterName, printer.name);
      await prefs.setString(_kPrefPrinterAddress, printer.address ?? '');
      // Force state update for listeners
      state = state;
    }
    return success;
  }

  /// Update paper size
  Future<void> setPaperSize(PaperSize size) async {
    state?.paperSize = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kPrefPaperSize, size == PaperSize.mm58 ? 58 : 80);
  }

  /// Toggle auto-print preference
  static Future<void> setAutoPrint(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kPrefAutoPrint, enabled);
  }

  /// Check auto-print preference
  static Future<bool> isAutoPrintEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kPrefAutoPrint) ?? false;
  }

  /// Disconnect and clear saved printer
  Future<void> disconnectAndClear() async {
    await state?.disconnect();
    state = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kPrefPrinterType);
    await prefs.remove(_kPrefPrinterName);
    await prefs.remove(_kPrefPrinterAddress);
  }

  ThermalPrintService? _createService(String type) {
    switch (type.toLowerCase()) {
      case 'bluetooth':
        return BluetoothPrintService();
      case 'network':
        return NetworkPrintService();
      case 'sunmi':
        return SunmiPrintService();
      default:
        return null;
    }
  }

  PrinterConnectionType? _parseConnectionType(String type) {
    switch (type.toLowerCase()) {
      case 'bluetooth':
        return PrinterConnectionType.bluetooth;
      case 'network':
        return PrinterConnectionType.network;
      case 'sunmi':
        return PrinterConnectionType.sunmi;
      default:
        return null;
    }
  }
}

/// The print queue service for retry and persistence
final printQueueProvider = Provider<PrintQueueService?>((ref) {
  final service = ref.watch(printServiceProvider);
  if (service == null) return null;

  final queue = PrintQueueService(service);
  // Initialize asynchronously (loads failed jobs from storage)
  queue.initialize();

  ref.onDispose(() => queue.dispose());
  return queue;
});

/// Number of failed print jobs (for UI badge display)
final failedPrintJobsCountProvider = Provider<int>((ref) {
  final queue = ref.watch(printQueueProvider);
  return queue?.failedJobs.length ?? 0;
});

/// Helper to print a receipt using the current service
///
/// Sends the receipt directly to the printer. For queued printing
/// with automatic retry, use [printReceiptQueued] instead.
Future<PrintResult> printReceiptWithService(
  WidgetRef ref,
  ReceiptData receipt,
) async {
  final service = ref.read(printServiceProvider);
  if (service == null) {
    return PrintResult.fail('لم يتم إعداد طابعة');
  }
  if (service.status != PrinterStatus.connected) {
    return PrintResult.fail('الطابعة غير متصلة');
  }
  return service.printReceipt(receipt);
}

/// Print a receipt through the queue with automatic retry on failure
///
/// Returns the job ID. The print will be retried up to 3 times
/// with exponential backoff. Failed jobs are persisted for manual reprint.
Future<String?> printReceiptQueued(
  WidgetRef ref,
  ReceiptData receipt,
) async {
  final queue = ref.read(printQueueProvider);
  if (queue == null) {
    if (kDebugMode) debugPrint('Print queue not available (no printer set)');
    return null;
  }
  return queue.enqueue(receipt);
}
