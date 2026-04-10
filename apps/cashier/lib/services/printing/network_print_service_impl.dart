/// Network TCP print service for ESC/POS thermal printers (mobile/desktop)
///
/// Connects to network printers via raw TCP socket on port 9100
/// (the standard ESC/POS printer port). Supports printer discovery
/// via subnet scan, connection keepalive, and automatic reconnection.
library;

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;

import 'print_service.dart';
import 'receipt_builder.dart';
import 'receipt_data.dart';

/// Standard ESC/POS network printing port
const _kDefaultPort = 9100;

/// Network TCP thermal printer service
class NetworkPrintService implements ThermalPrintService {
  PrinterStatus _status = PrinterStatus.disconnected;
  PaperSize _paperSize = PaperSize.mm80;
  String? _connectedPrinterName;

  Socket? _socket;
  String? _connectedAddress;
  int _connectedPort = _kDefaultPort;

  /// Number of reconnection attempts before giving up
  static const _maxReconnectAttempts = 3;

  /// Timeout for TCP connection attempts
  static const _connectTimeout = Duration(seconds: 5);

  /// Delay between reconnection attempts
  static const _reconnectBaseDelay = Duration(seconds: 1);

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
    final printers = <DiscoveredPrinter>[];

    // Scan common subnet for printers on port 9100
    // Uses a parallel connection-attempt approach: try to connect
    // to each IP on the local /24 subnet and see which ones respond.
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
      );

      for (final interface in interfaces) {
        for (final addr in interface.addresses) {
          final parts = addr.address.split('.');
          if (parts.length != 4) continue;

          final subnet = '${parts[0]}.${parts[1]}.${parts[2]}';
          final futures = <Future<DiscoveredPrinter?>>[];

          // Scan IPs 1-254 in parallel with a short timeout
          for (var i = 1; i < 255; i++) {
            final ip = '$subnet.$i';
            if (ip == addr.address) continue;

            futures.add(_probeAddress(ip, timeout: const Duration(seconds: 2)));
          }

          final results = await Future.wait(futures).timeout(
            timeout,
            onTimeout: () => futures.map((_) => null).toList(),
          );

          for (final printer in results) {
            if (printer != null) printers.add(printer);
          }
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Network scan error: $e');
    }

    return printers;
  }

  /// Probe a single IP:port to see if a printer responds
  Future<DiscoveredPrinter?> _probeAddress(
    String ip, {
    int port = _kDefaultPort,
    Duration timeout = const Duration(seconds: 2),
  }) async {
    try {
      final socket = await Socket.connect(ip, port, timeout: timeout);
      await socket.close();
      socket.destroy();

      return DiscoveredPrinter(
        id: '$ip:$port',
        name: 'Printer @ $ip',
        type: PrinterConnectionType.network,
        address: ip,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> connect(DiscoveredPrinter printer) async {
    _status = PrinterStatus.connecting;

    final address = printer.address;
    if (address == null || address.isEmpty) {
      _status = PrinterStatus.error;
      return false;
    }

    // Parse port from address if format is "ip:port"
    var ip = address;
    var port = _kDefaultPort;
    if (address.contains(':')) {
      final parts = address.split(':');
      ip = parts[0];
      port = int.tryParse(parts[1]) ?? _kDefaultPort;
    }

    try {
      _socket = await Socket.connect(ip, port, timeout: _connectTimeout);
      _connectedAddress = ip;
      _connectedPort = port;
      _connectedPrinterName = printer.name;
      _status = PrinterStatus.connected;

      // Listen for connection close events
      _socket!.listen(
        (_) {}, // Ignore incoming data from printer
        onError: (Object error) {
          if (kDebugMode) debugPrint('TCP socket error: $error');
          _status = PrinterStatus.error;
        },
        onDone: () {
          if (kDebugMode) debugPrint('TCP socket closed by printer');
          _status = PrinterStatus.disconnected;
          _socket = null;
        },
        cancelOnError: true,
      );

      return true;
    } on SocketException catch (e) {
      if (kDebugMode) debugPrint('TCP connect failed: ${e.message}');
      _status = PrinterStatus.error;
      return false;
    } on TimeoutException {
      if (kDebugMode) debugPrint('TCP connect timeout to $ip:$port');
      _status = PrinterStatus.error;
      return false;
    }
  }

  @override
  Future<void> disconnect() async {
    try {
      await _socket?.close();
      _socket?.destroy();
    } catch (e) {
      if (kDebugMode) debugPrint('TCP disconnect error: $e');
    } finally {
      _socket = null;
      _status = PrinterStatus.disconnected;
      _connectedPrinterName = null;
      _connectedAddress = null;
    }
  }

  @override
  Future<PrintResult> printReceipt(ReceiptData receipt) async {
    final bytes = await ReceiptBuilder.build(receipt, size: _paperSize);
    return _sendBytesWithReconnect(bytes);
  }

  @override
  Future<PrintResult> printRawBytes(Uint8List bytes) async {
    return _sendBytesWithReconnect(bytes);
  }

  @override
  Future<PrintResult> printTestPage() async {
    final bytes = await ReceiptBuilder.buildTestPage(size: _paperSize);
    return _sendBytesWithReconnect(bytes);
  }

  @override
  Future<PrintResult> openCashDrawer() async {
    final bytes = await ReceiptBuilder.buildCashDrawerKick(size: _paperSize);
    return _sendBytesWithReconnect(bytes);
  }

  // ─── Internal ──────────────────────────────────────────

  /// Send bytes with automatic reconnection on socket failure
  Future<PrintResult> _sendBytesWithReconnect(Uint8List bytes) async {
    if (_socket == null || _status != PrinterStatus.connected) {
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

    try {
      _socket!.add(bytes);
      await _socket!.flush();
      _status = PrinterStatus.connected;
      return PrintResult.ok();
    } on SocketException catch (e) {
      if (kDebugMode) debugPrint('TCP write failed: ${e.message}');
      _status = PrinterStatus.error;

      // Try reconnect and resend once
      final reconnected = await _tryReconnect();
      if (reconnected) {
        try {
          _status = PrinterStatus.printing;
          _socket!.add(bytes);
          await _socket!.flush();
          _status = PrinterStatus.connected;
          return PrintResult.ok();
        } on SocketException catch (e2) {
          _status = PrinterStatus.error;
          return PrintResult.fail(
              'فشلت الطباعة بعد إعادة الاتصال: ${e2.message}');
        }
      }

      return PrintResult.fail('فشل الاتصال بالطابعة: ${e.message}');
    }
  }

  /// Try to reconnect to the last known printer address
  Future<bool> _tryReconnect() async {
    if (_connectedAddress == null) return false;

    // Close existing socket if any. A failure here is expected when the
    // socket is already broken (that's why we're reconnecting), so we
    // only log it and continue the reconnect sequence.
    try {
      await _socket?.close();
      _socket?.destroy();
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
            'TCP close-before-reconnect failed (expected if socket is already broken): $e');
      }
    }
    _socket = null;

    for (var attempt = 1; attempt <= _maxReconnectAttempts; attempt++) {
      if (kDebugMode) {
        debugPrint(
          'TCP reconnect attempt $attempt/$_maxReconnectAttempts '
          'to $_connectedAddress:$_connectedPort',
        );
      }

      _status = PrinterStatus.connecting;

      try {
        _socket = await Socket.connect(
          _connectedAddress!,
          _connectedPort,
          timeout: _connectTimeout,
        );

        _socket!.listen(
          (_) {},
          onError: (Object error) {
            _status = PrinterStatus.error;
          },
          onDone: () {
            _status = PrinterStatus.disconnected;
            _socket = null;
          },
          cancelOnError: true,
        );

        _status = PrinterStatus.connected;
        if (kDebugMode) debugPrint('TCP reconnected successfully');
        return true;
      } on SocketException catch (e) {
        if (kDebugMode) {
          debugPrint('TCP reconnect attempt $attempt failed: ${e.message}');
        }
      } on TimeoutException {
        if (kDebugMode) {
          debugPrint('TCP reconnect attempt $attempt timed out');
        }
      }

      // Exponential backoff
      if (attempt < _maxReconnectAttempts) {
        await Future<void>.delayed(_reconnectBaseDelay * attempt);
      }
    }

    _status = PrinterStatus.error;
    return false;
  }
}
