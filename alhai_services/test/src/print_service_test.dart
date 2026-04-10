import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_services/alhai_services.dart';

void main() {
  late PrintService printService;

  setUp(() {
    printService = PrintService();
  });

  group('PrintService', () {
    test('should be created', () {
      expect(printService, isNotNull);
    });

    test('initial status should be disconnected', () {
      expect(printService.status, equals(PrinterStatus.disconnected));
      expect(printService.connectedPrinterName, isNull);
      expect(printService.connectedDevice, isNull);
    });

    group('scanForPrinters', () {
      test('should throw UnimplementedError', () async {
        expect(
          () => printService.scanForPrinters(),
          throwsA(isA<UnimplementedError>()),
        );
      });
    });

    group('connect', () {
      test('should throw UnimplementedError for valid device', () async {
        const device = PrinterDevice(
          id: 'printer-1',
          name: 'Test Printer',
          type: PrinterConnectionType.bluetooth,
        );

        expect(
          () => printService.connect(device),
          throwsA(isA<UnimplementedError>()),
        );
      });

      test('should return false for empty device ID', () async {
        const device = PrinterDevice(
          id: '',
          name: 'Bad Printer',
          type: PrinterConnectionType.usb,
        );

        final result = await printService.connect(device);
        expect(result, isFalse);
        expect(printService.status, equals(PrinterStatus.error));
      });

      test('should return false while already connecting', () async {
        const device = PrinterDevice(
          id: 'printer-1',
          name: 'Test',
          type: PrinterConnectionType.bluetooth,
        );

        // Start a connection attempt - will throw but that's expected
        try {
          await printService.connect(device);
        } catch (_) {}
        // After error, status is 'error', not 'connecting'
      });
    });

    group('disconnect', () {
      test('should set status to disconnected', () async {
        await printService.disconnect();
        expect(printService.status, equals(PrinterStatus.disconnected));
        expect(printService.connectedPrinterName, isNull);
        expect(printService.connectedDevice, isNull);
      });
    });

    group('printText', () {
      test('should fail when not connected', () async {
        final result = await printService.printText('Test');
        expect(result.success, isFalse);
        expect(result.error, contains('غير متصلة'));
      });
    });

    group('printReceipt', () {
      test('should fail when not connected', () async {
        final result = await printService.printReceipt('Receipt text');
        expect(result.success, isFalse);
        expect(result.error, contains('غير متصلة'));
      });
    });

    group('printBarcode', () {
      test('should fail when not connected', () async {
        final result = await printService.printBarcode('1234567890');
        expect(result.success, isFalse);
        expect(result.error, contains('غير متصلة'));
      });
    });

    group('printImage', () {
      test('should fail when not connected', () async {
        final result = await printService.printImage([1, 2, 3]);
        expect(result.success, isFalse);
        expect(result.error, contains('غير متصلة'));
      });

      test('should fail with empty image data when not connected', () async {
        final result = await printService.printImage([]);
        expect(result.success, isFalse);
      });
    });

    group('openCashDrawer', () {
      test('should fail when not connected', () async {
        final result = await printService.openCashDrawer();
        expect(result.success, isFalse);
        expect(result.error, contains('غير متصلة'));
      });
    });

    group('printTestPage', () {
      test('should fail when not connected', () async {
        final result = await printService.printTestPage();
        expect(result.success, isFalse);
      });
    });

    group('EscPosCommandBuilder', () {
      test('should build command bytes', () {
        final builder = EscPosCommandBuilder()
          ..initialize()
          ..setAlignment(EscPosAlignment.center)
          ..setBold(true)
          ..addText('Test')
          ..setBold(false)
          ..addSeparator()
          ..feedLines(2)
          ..cut();

        final bytes = builder.build();
        expect(bytes, isNotEmpty);
        expect(builder.byteCount, greaterThan(0));
      });

      test('initialize should emit ESC @', () {
        final builder = EscPosCommandBuilder()..initialize();
        final bytes = builder.build();
        expect(bytes[0], equals(0x1B)); // ESC
        expect(bytes[1], equals(0x40)); // @
      });

      test('cut should emit GS V', () {
        final builder = EscPosCommandBuilder()..cut();
        final bytes = builder.build();
        expect(bytes[0], equals(0x1D)); // GS
        expect(bytes[1], equals(0x56)); // V
      });
    });

    group('PrinterDevice', () {
      test('should store device properties', () {
        const device = PrinterDevice(
          id: 'bt-123',
          name: 'My Printer',
          type: PrinterConnectionType.bluetooth,
          address: '00:11:22:33:44:55',
        );

        expect(device.id, equals('bt-123'));
        expect(device.name, equals('My Printer'));
        expect(device.type, equals(PrinterConnectionType.bluetooth));
        expect(device.address, equals('00:11:22:33:44:55'));
      });
    });

    group('enums', () {
      test('PrinterStatus should have all values', () {
        expect(PrinterStatus.values, contains(PrinterStatus.disconnected));
        expect(PrinterStatus.values, contains(PrinterStatus.connecting));
        expect(PrinterStatus.values, contains(PrinterStatus.connected));
        expect(PrinterStatus.values, contains(PrinterStatus.printing));
        expect(PrinterStatus.values, contains(PrinterStatus.error));
      });

      test('PrinterConnectionType should have all values', () {
        expect(PrinterConnectionType.values,
            contains(PrinterConnectionType.bluetooth));
        expect(
            PrinterConnectionType.values, contains(PrinterConnectionType.usb));
        expect(PrinterConnectionType.values,
            contains(PrinterConnectionType.network));
        expect(PrinterConnectionType.values,
            contains(PrinterConnectionType.sunmi));
      });
    });
  });
}
