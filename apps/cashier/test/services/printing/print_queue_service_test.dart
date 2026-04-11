import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cashier/services/printing/print_queue_service.dart';
import 'package:cashier/services/printing/print_service.dart';
import 'package:cashier/services/printing/receipt_data.dart';

// ---------------------------------------------------------------------------
// Test doubles
// ---------------------------------------------------------------------------

class _FakePrintService implements ThermalPrintService {
  @override
  PrinterStatus status = PrinterStatus.connected;

  /// Decide what the next call to [printReceipt] returns.
  PrintResult Function(ReceiptData receipt) onPrintReceipt = (_) =>
      PrintResult.ok();

  int printCallCount = 0;

  @override
  String? get connectedPrinterName => 'FakePrinter';

  @override
  PaperSize paperSize = PaperSize.mm80;

  @override
  Future<bool> connect(DiscoveredPrinter printer) async => true;

  @override
  Future<void> disconnect() async {}

  @override
  Future<PrintResult> openCashDrawer() async => PrintResult.ok();

  @override
  Future<PrintResult> printRawBytes(Uint8List bytes) async => PrintResult.ok();

  @override
  Future<PrintResult> printReceipt(ReceiptData receipt) async {
    printCallCount++;
    return onPrintReceipt(receipt);
  }

  @override
  Future<PrintResult> printTestPage() async => PrintResult.ok();

  @override
  Future<List<DiscoveredPrinter>> scanForPrinters({
    Duration timeout = const Duration(seconds: 10),
  }) async => [];
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

ReceiptData _sampleReceipt({String number = 'INV-0001'}) => ReceiptData(
  receiptNumber: number,
  dateTime: DateTime(2026, 1, 1, 10, 30),
  cashierName: 'Ahmed',
  items: const [ReceiptItem(name: 'Tea', quantity: 1, unitPrice: 5, total: 5)],
  subtotal: 5,
  tax: 0.75,
  total: 5.75,
  paymentMethod: 'cash',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    // Reset shared preferences before each test
    SharedPreferences.setMockInitialValues({});
  });

  // -------------------------------------------------------------------------
  // PrintJob serialization
  // -------------------------------------------------------------------------
  group('PrintJob', () {
    test('default state is pending with zero attempts', () {
      final job = PrintJob(id: 'j1', receipt: _sampleReceipt());
      expect(job.status, equals(PrintJobStatus.pending));
      expect(job.attempts, equals(0));
      expect(job.lastError, isNull);
      expect(job.lastAttemptAt, isNull);
    });

    test('toJson preserves all fields', () {
      final job = PrintJob(
        id: 'j2',
        receipt: _sampleReceipt(number: 'INV-0002'),
        status: PrintJobStatus.failed,
        attempts: 2,
        createdAt: DateTime(2026, 1, 1, 10, 0),
        lastAttemptAt: DateTime(2026, 1, 1, 10, 5),
        lastError: 'timeout',
      );
      final json = job.toJson();
      expect(json['id'], equals('j2'));
      expect(json['receiptNumber'], equals('INV-0002'));
      expect(json['status'], equals('failed'));
      expect(json['attempts'], equals(2));
      expect(json['lastError'], equals('timeout'));
      expect(json['receipt'], isA<Map<String, dynamic>>());
    });

    test('fromJson reconstructs job with matching fields', () {
      final original = PrintJob(
        id: 'j3',
        receipt: _sampleReceipt(number: 'INV-0003'),
        status: PrintJobStatus.failed,
        attempts: 3,
        createdAt: DateTime(2026, 1, 1, 10, 0),
        lastAttemptAt: DateTime(2026, 1, 1, 10, 5),
        lastError: 'paper jam',
      );
      final json = original.toJson();
      final restored = PrintJob.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.status, equals(original.status));
      expect(restored.attempts, equals(original.attempts));
      expect(restored.lastError, equals(original.lastError));
      expect(
        restored.receipt.receiptNumber,
        equals(original.receipt.receiptNumber),
      );
    });

    test('fromJson gracefully handles unknown status', () {
      final job = PrintJob(id: 'j4', receipt: _sampleReceipt());
      final json = job.toJson();
      json['status'] = 'nonexistent_status';

      final restored = PrintJob.fromJson(json);
      // Should fall back to failed
      expect(restored.status, equals(PrintJobStatus.failed));
    });

    test('fromJson uses default for missing attempts', () {
      final job = PrintJob(id: 'j5', receipt: _sampleReceipt());
      final json = job.toJson();
      json.remove('attempts');
      final restored = PrintJob.fromJson(json);
      expect(restored.attempts, equals(0));
    });

    test('fromJson handles invalid createdAt gracefully', () {
      final job = PrintJob(id: 'j6', receipt: _sampleReceipt());
      final json = job.toJson();
      json['createdAt'] = 'not-a-date';
      final restored = PrintJob.fromJson(json);
      // Should fall back to DateTime.now(), not throw
      expect(restored.createdAt, isA<DateTime>());
    });
  });

  // -------------------------------------------------------------------------
  // Constants & initial state
  // -------------------------------------------------------------------------
  group('constants and initial state', () {
    test('maxRetries constant is 3', () {
      expect(PrintQueueService.maxRetries, equals(3));
    });

    test('a fresh queue has no pending or failed jobs', () {
      final svc = _FakePrintService();
      final queue = PrintQueueService(svc);

      expect(queue.pendingJobs, isEmpty);
      expect(queue.failedJobs, isEmpty);
      expect(queue.totalJobs, equals(0));
      expect(queue.hasActiveJobs, isFalse);

      queue.dispose();
    });
  });

  // -------------------------------------------------------------------------
  // enqueue + successful print
  // -------------------------------------------------------------------------
  group('enqueue and processing', () {
    test('successful print removes job from queue', () async {
      final svc = _FakePrintService();
      final queue = PrintQueueService(svc);

      final id = await queue.enqueue(_sampleReceipt());
      expect(id, isNotEmpty);

      // Let the queue process
      await Future<void>.delayed(Duration.zero);
      // Another microtask to let the async printReceipt complete
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(svc.printCallCount, equals(1));
      expect(queue.pendingJobs, isEmpty);
      expect(queue.failedJobs, isEmpty);

      queue.dispose();
    });

    test('printer not connected moves job to failed immediately', () async {
      final svc = _FakePrintService()..status = PrinterStatus.disconnected;
      final queue = PrintQueueService(svc);

      await queue.enqueue(_sampleReceipt());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(svc.printCallCount, equals(0));
      expect(queue.pendingJobs, isEmpty);
      expect(queue.failedJobs.length, equals(1));
      expect(queue.failedJobs.first.lastError, contains('الطابعة'));

      queue.dispose();
    });

    test('totalJobs reflects failed job count', () async {
      final svc = _FakePrintService()..status = PrinterStatus.disconnected;
      final queue = PrintQueueService(svc);

      await queue.enqueue(_sampleReceipt(number: 'INV-A'));
      await queue.enqueue(_sampleReceipt(number: 'INV-B'));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(queue.totalJobs, equals(2));

      queue.dispose();
    });
  });

  // -------------------------------------------------------------------------
  // cancelJob
  // -------------------------------------------------------------------------
  group('cancelJob', () {
    test('returns false for a non-existent job id', () {
      final svc = _FakePrintService();
      final queue = PrintQueueService(svc);
      expect(queue.cancelJob('does-not-exist'), isFalse);
      queue.dispose();
    });
  });

  // -------------------------------------------------------------------------
  // retry operations
  // -------------------------------------------------------------------------
  group('retry operations', () {
    test('retryFailedJob returns false when job id not found', () async {
      final svc = _FakePrintService();
      final queue = PrintQueueService(svc);

      final result = await queue.retryFailedJob('nonexistent');
      expect(result, isFalse);

      queue.dispose();
    });

    test('retryAllFailed returns 0 when nothing failed', () async {
      final svc = _FakePrintService();
      final queue = PrintQueueService(svc);

      final count = await queue.retryAllFailed();
      expect(count, equals(0));

      queue.dispose();
    });

    test(
      'retryAllFailed resets failed jobs to pending and re-enqueues',
      () async {
        final svc = _FakePrintService()..status = PrinterStatus.disconnected;
        final queue = PrintQueueService(svc);

        await queue.enqueue(_sampleReceipt(number: 'R-1'));
        await queue.enqueue(_sampleReceipt(number: 'R-2'));
        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(queue.failedJobs.length, equals(2));

        // Now make the printer available again
        svc.status = PrinterStatus.connected;
        final count = await queue.retryAllFailed();
        expect(count, equals(2));

        // Allow the queue to process
        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(queue.failedJobs, isEmpty);

        queue.dispose();
      },
    );
  });

  // -------------------------------------------------------------------------
  // failed job management
  // -------------------------------------------------------------------------
  group('failed job management', () {
    test('clearFailedJobs empties the failed list', () async {
      final svc = _FakePrintService()..status = PrinterStatus.disconnected;
      final queue = PrintQueueService(svc);

      await queue.enqueue(_sampleReceipt());
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(queue.failedJobs, isNotEmpty);

      await queue.clearFailedJobs();
      expect(queue.failedJobs, isEmpty);

      queue.dispose();
    });

    test('removeFailedJob with unknown id is a no-op', () async {
      final svc = _FakePrintService();
      final queue = PrintQueueService(svc);

      await queue.removeFailedJob('does-not-exist');
      expect(queue.failedJobs, isEmpty);

      queue.dispose();
    });
  });

  // -------------------------------------------------------------------------
  // initialize / persistence
  // -------------------------------------------------------------------------
  group('initialize', () {
    test('initialize() on empty prefs loads zero jobs', () async {
      SharedPreferences.setMockInitialValues({});
      final svc = _FakePrintService();
      final queue = PrintQueueService(svc);

      await queue.initialize();
      expect(queue.failedJobs, isEmpty);

      queue.dispose();
    });

    test('initialize() on malformed JSON safely returns', () async {
      SharedPreferences.setMockInitialValues({
        'print_queue_failed_jobs': 'not valid json',
      });
      final svc = _FakePrintService();
      final queue = PrintQueueService(svc);

      await queue.initialize();
      // Should not throw, just keep empty
      expect(queue.failedJobs, isEmpty);

      queue.dispose();
    });
  });

  // -------------------------------------------------------------------------
  // jobStatusStream
  // -------------------------------------------------------------------------
  group('jobStatusStream', () {
    test('is a broadcast stream', () {
      final svc = _FakePrintService();
      final queue = PrintQueueService(svc);

      final sub1 = queue.jobStatusStream.listen((_) {});
      final sub2 = queue.jobStatusStream.listen((_) {});
      expect(sub1, isNotNull);
      expect(sub2, isNotNull);

      sub1.cancel();
      sub2.cancel();
      queue.dispose();
    });

    test('emits a status event when a job is enqueued', () async {
      final svc = _FakePrintService();
      final queue = PrintQueueService(svc);

      final events = <PrintJob>[];
      final sub = queue.jobStatusStream.listen(events.add);

      await queue.enqueue(_sampleReceipt());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(events, isNotEmpty);

      await sub.cancel();
      queue.dispose();
    });
  });
}
