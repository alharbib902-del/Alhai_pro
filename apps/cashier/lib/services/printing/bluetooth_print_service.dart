/// Bluetooth ESC/POS print service
///
/// Communicates with Bluetooth thermal printers using platform channels.
/// On Android, delegates to the BluetoothSocket API via a MethodChannel.
/// On iOS, delegates to CoreBluetooth via the same channel.
/// On web, all operations return "not supported".
///
/// The platform channel name is `com.alhai.cashier/bluetooth_printer`.
/// Native side must implement: scan, connect, disconnect, write, isConnected.
library;

import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode, debugPrint;
import 'package:flutter/services.dart';

import 'print_service.dart';
import 'receipt_builder.dart';
import 'receipt_data.dart';

/// Bluetooth thermal printer service using platform channels
class BluetoothPrintService implements ThermalPrintService {
  static const _channel = MethodChannel('com.alhai.cashier/bluetooth_printer');

  PrinterStatus _status = PrinterStatus.disconnected;
  PaperSize _paperSize = PaperSize.mm80;
  String? _connectedPrinterName;
  String? _connectedAddress;

  /// Number of reconnection attempts before giving up
  static const _maxReconnectAttempts = 3;

  /// Delay between reconnection attempts
  static const _reconnectDelay = Duration(seconds: 2);

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
      final result = await _channel.invokeMethod<List<dynamic>>(
        'scan',
        {'timeout': timeout.inMilliseconds},
      );

      if (result == null) return [];

      return result
          .cast<Map<dynamic, dynamic>>()
          .map((device) => DiscoveredPrinter(
                id: device['address'] as String? ?? '',
                name: device['name'] as String? ?? 'Unknown',
                type: PrinterConnectionType.bluetooth,
                address: device['address'] as String?,
              ))
          .toList();
    } on PlatformException catch (e) {
      if (kDebugMode) debugPrint('BT scan error: ${e.message}');
      return [];
    } on MissingPluginException {
      if (kDebugMode) {
        debugPrint('BT scan: platform channel not available');
      }
      return [];
    }
  }

  @override
  Future<bool> connect(DiscoveredPrinter printer) async {
    if (kIsWeb) return false;

    _status = PrinterStatus.connecting;
    try {
      final success = await _channel.invokeMethod<bool>(
        'connect',
        {'address': printer.address},
      );

      if (success == true) {
        _status = PrinterStatus.connected;
        _connectedPrinterName = printer.name;
        _connectedAddress = printer.address;
        return true;
      } else {
        _status = PrinterStatus.error;
        return false;
      }
    } on PlatformException catch (e) {
      if (kDebugMode) debugPrint('BT connect error: ${e.message}');
      _status = PrinterStatus.error;
      return false;
    } on MissingPluginException {
      _status = PrinterStatus.disconnected;
      return false;
    }
  }

  @override
  Future<void> disconnect() async {
    if (kIsWeb) return;

    try {
      await _channel.invokeMethod<void>('disconnect');
    } on PlatformException catch (e) {
      if (kDebugMode) debugPrint('BT disconnect error: ${e.message}');
    } on MissingPluginException {
      // Platform channel not available
    } finally {
      _status = PrinterStatus.disconnected;
      _connectedPrinterName = null;
      _connectedAddress = null;
    }
  }

  @override
  Future<PrintResult> printReceipt(ReceiptData receipt) async {
    if (kIsWeb) {
      return PrintResult.fail('Bluetooth printing not supported on web');
    }

    final bytes = await ReceiptBuilder.build(receipt, size: _paperSize);
    return _sendBytesWithReconnect(bytes);
  }

  @override
  Future<PrintResult> printRawBytes(Uint8List bytes) async {
    if (kIsWeb) {
      return PrintResult.fail('Bluetooth printing not supported on web');
    }
    return _sendBytesWithReconnect(bytes);
  }

  @override
  Future<PrintResult> printTestPage() async {
    if (kIsWeb) {
      return PrintResult.fail('Bluetooth printing not supported on web');
    }

    final bytes = await ReceiptBuilder.buildTestPage(size: _paperSize);
    return _sendBytesWithReconnect(bytes);
  }

  @override
  Future<PrintResult> openCashDrawer() async {
    if (kIsWeb) {
      return PrintResult.fail('Bluetooth printing not supported on web');
    }

    final bytes = await ReceiptBuilder.buildCashDrawerKick(size: _paperSize);
    return _sendBytesWithReconnect(bytes);
  }

  // ─── Internal ──────────────────────────────────────────

  /// Send bytes to the printer with automatic reconnection on failure
  Future<PrintResult> _sendBytesWithReconnect(Uint8List bytes) async {
    if (_status != PrinterStatus.connected) {
      // Attempt reconnection if we have a saved address
      if (_connectedAddress != null) {
        final reconnected = await _tryReconnect();
        if (!reconnected) {
          return PrintResult.fail('الطابعة غير متصلة ولم تنجح إعادة الاتصال');
        }
      } else {
        return PrintResult.fail('الطابعة غير متصلة');
      }
    }

    _status = PrinterStatus.printing;

    // Send bytes in chunks to avoid buffer overflow on some printers
    try {
      final result = await _sendBytesChunked(bytes);
      _status = PrinterStatus.connected;
      return result;
    } catch (e) {
      // Connection lost during printing - try reconnect and resend
      if (kDebugMode) debugPrint('BT print failed, attempting reconnect: $e');
      _status = PrinterStatus.error;

      final reconnected = await _tryReconnect();
      if (reconnected) {
        try {
          _status = PrinterStatus.printing;
          final result = await _sendBytesChunked(bytes);
          _status = PrinterStatus.connected;
          return result;
        } catch (e2) {
          _status = PrinterStatus.error;
          return PrintResult.fail('فشلت الطباعة بعد إعادة الاتصال: $e2');
        }
      }
      return PrintResult.fail('فشل الاتصال بالطابعة: $e');
    }
  }

  /// Send bytes in 512-byte chunks with a small delay between chunks
  ///
  /// Many Bluetooth thermal printers have limited receive buffers.
  /// Sending large receipts in one shot can overflow the buffer and
  /// cause garbled output or disconnection.
  Future<PrintResult> _sendBytesChunked(Uint8List bytes) async {
    const chunkSize = 512;

    for (var offset = 0; offset < bytes.length; offset += chunkSize) {
      final end = (offset + chunkSize > bytes.length)
          ? bytes.length
          : offset + chunkSize;
      final chunk = bytes.sublist(offset, end);

      try {
        final success = await _channel.invokeMethod<bool>(
          'write',
          {'data': chunk},
        );

        if (success != true) {
          return PrintResult.fail('فشل إرسال البيانات إلى الطابعة');
        }

        // Small delay between chunks to avoid buffer overflow
        if (end < bytes.length) {
          await Future<void>.delayed(const Duration(milliseconds: 50));
        }
      } on PlatformException catch (e) {
        return PrintResult.fail('خطأ في الطباعة: ${e.message}');
      }
    }

    return PrintResult.ok();
  }

  /// Try to reconnect to the last known printer
  Future<bool> _tryReconnect() async {
    if (_connectedAddress == null) return false;

    for (var attempt = 1; attempt <= _maxReconnectAttempts; attempt++) {
      if (kDebugMode) {
        debugPrint('BT reconnect attempt $attempt/$_maxReconnectAttempts');
      }

      _status = PrinterStatus.connecting;

      try {
        final success = await _channel.invokeMethod<bool>(
          'connect',
          {'address': _connectedAddress},
        );

        if (success == true) {
          _status = PrinterStatus.connected;
          if (kDebugMode) debugPrint('BT reconnected successfully');
          return true;
        }
      } on PlatformException catch (e) {
        if (kDebugMode) {
          debugPrint('BT reconnect attempt $attempt failed: ${e.message}');
        }
      } on MissingPluginException {
        _status = PrinterStatus.disconnected;
        return false;
      }

      // Wait with exponential backoff before next attempt
      if (attempt < _maxReconnectAttempts) {
        await Future<void>.delayed(_reconnectDelay * attempt);
      }
    }

    _status = PrinterStatus.error;
    return false;
  }
}
