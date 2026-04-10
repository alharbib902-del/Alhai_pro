import 'package:flutter_test/flutter_test.dart';

import 'package:cashier/services/printing/print_service.dart';

// ---------------------------------------------------------------------------
// print_service.dart declares the abstract interface + a few value types:
//   - PrinterConnectionType enum
//   - PrinterStatus enum
//   - DiscoveredPrinter
//   - PrintResult (with ok / fail factories)
//   - PaperSize (with charsPerLine)
// These tests lock in the value semantics so the rest of the codebase can
// depend on them.
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // PrinterConnectionType
  // -------------------------------------------------------------------------
  group('PrinterConnectionType', () {
    test('has four known connection types', () {
      expect(PrinterConnectionType.values, hasLength(4));
      expect(PrinterConnectionType.values,
          contains(PrinterConnectionType.bluetooth));
      expect(PrinterConnectionType.values,
          contains(PrinterConnectionType.network));
      expect(PrinterConnectionType.values, contains(PrinterConnectionType.usb));
      expect(
          PrinterConnectionType.values, contains(PrinterConnectionType.sunmi));
    });

    test('each has a unique name used for preference serialization', () {
      final names = PrinterConnectionType.values.map((e) => e.name).toSet();
      expect(names, hasLength(4));
    });
  });

  // -------------------------------------------------------------------------
  // PrinterStatus
  // -------------------------------------------------------------------------
  group('PrinterStatus', () {
    test('has five known status values', () {
      expect(PrinterStatus.values, hasLength(5));
      expect(PrinterStatus.values, contains(PrinterStatus.disconnected));
      expect(PrinterStatus.values, contains(PrinterStatus.connecting));
      expect(PrinterStatus.values, contains(PrinterStatus.connected));
      expect(PrinterStatus.values, contains(PrinterStatus.printing));
      expect(PrinterStatus.values, contains(PrinterStatus.error));
    });
  });

  // -------------------------------------------------------------------------
  // DiscoveredPrinter
  // -------------------------------------------------------------------------
  group('DiscoveredPrinter', () {
    test('stores id, name, type, address', () {
      const printer = DiscoveredPrinter(
        id: 'AA:BB:CC:DD:EE:FF',
        name: 'Thermal Printer',
        type: PrinterConnectionType.bluetooth,
        address: 'AA:BB:CC:DD:EE:FF',
      );

      expect(printer.id, equals('AA:BB:CC:DD:EE:FF'));
      expect(printer.name, equals('Thermal Printer'));
      expect(printer.type, equals(PrinterConnectionType.bluetooth));
      expect(printer.address, equals('AA:BB:CC:DD:EE:FF'));
    });

    test('address is optional', () {
      const printer = DiscoveredPrinter(
        id: '1',
        name: 'Sunmi Built-in',
        type: PrinterConnectionType.sunmi,
      );
      expect(printer.address, isNull);
    });

    test('toString includes name, address and type', () {
      const printer = DiscoveredPrinter(
        id: '192.168.1.100',
        name: 'Network Printer',
        type: PrinterConnectionType.network,
        address: '192.168.1.100:9100',
      );
      final str = printer.toString();

      expect(str, contains('Network Printer'));
      expect(str, contains('192.168.1.100:9100'));
      expect(str, contains('network'));
    });

    test('toString handles null address', () {
      const printer = DiscoveredPrinter(
        id: 'id',
        name: 'Sunmi',
        type: PrinterConnectionType.sunmi,
      );
      final str = printer.toString();
      expect(str, contains('Sunmi'));
      expect(str, contains('null'));
      expect(str, contains('sunmi'));
    });
  });

  // -------------------------------------------------------------------------
  // PrintResult
  // -------------------------------------------------------------------------
  group('PrintResult', () {
    test('ok factory returns success=true and null error', () {
      final result = PrintResult.ok();
      expect(result.success, isTrue);
      expect(result.error, isNull);
    });

    test('fail factory returns success=false with the given error', () {
      final result = PrintResult.fail('paper jam');
      expect(result.success, isFalse);
      expect(result.error, equals('paper jam'));
    });

    test('fail factory preserves Arabic error messages', () {
      final result = PrintResult.fail('خطأ في الطابعة');
      expect(result.success, isFalse);
      expect(result.error, equals('خطأ في الطابعة'));
    });

    test('constructor allows manual construction', () {
      const result = PrintResult(success: true, error: null);
      expect(result.success, isTrue);
    });

    test('multiple fail instances are independent values', () {
      final a = PrintResult.fail('err1');
      final b = PrintResult.fail('err2');
      expect(a.error, isNot(equals(b.error)));
    });
  });

  // -------------------------------------------------------------------------
  // PaperSize
  // -------------------------------------------------------------------------
  group('PaperSize', () {
    test('has two sizes: 58mm and 80mm', () {
      expect(PaperSize.values, hasLength(2));
      expect(PaperSize.values, contains(PaperSize.mm58));
      expect(PaperSize.values, contains(PaperSize.mm80));
    });

    test('58mm has 32 chars per line', () {
      expect(PaperSize.mm58.charsPerLine, equals(32));
    });

    test('80mm has 48 chars per line', () {
      expect(PaperSize.mm80.charsPerLine, equals(48));
    });

    test('80mm has more chars than 58mm', () {
      expect(
        PaperSize.mm80.charsPerLine,
        greaterThan(PaperSize.mm58.charsPerLine),
      );
    });
  });
}
