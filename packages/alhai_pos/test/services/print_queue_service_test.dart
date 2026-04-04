/// Tests for PrintQueueService - queue, retry, persistence
///
/// Covers: enqueue, sequential processing, retry with backoff,
/// max-retry failure, retryFailedJob, SharedPreferences persistence,
/// and initialize loading.
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cashier/services/printing/print_service.dart';
import 'package:cashier/services/printing/receipt_data.dart';
import 'package:cashier/services/printing/print_queue_service.dart';

// ==========================================================================
// Mocks
// ==========================================================================

class MockThermalPrintService extends Mock implements ThermalPrintService {}

// ==========================================================================
// Helpers
// ==========================================================================

ReceiptData _receipt({String number = 'INV-001'}) => ReceiptData(
      receiptNumber: number,
      dateTime: DateTime(2026, 1, 1),
      cashierName: 'Test',
      items: const [
        ReceiptItem(name: 'Item', quantity: 1, unitPrice: 10, total: 10),
      ],
      subtotal: 10,
      tax: 1.5,
      total: 11.5,
      paymentMethod: 'cash',
    );

// ==========================================================================
// Tests
// ==========================================================================

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockThermalPrintService mockPrint;
  late PrintQueueService queue;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockPrint = MockThermalPrintService();
    queue = PrintQueueService(mockPrint);
  });

  tearDown(() {
    queue.dispose();
  });

  // ──────────────────────────────────────────────────────────────────────────
  // enqueue
  // ──────────────────────────────────────────────────────────────────────────
  group('enqueue', () {
    test('adds job to queue and returns an ID', () async {
      // Printer connected so processQueue runs, but print succeeds instantly
      when(() => mockPrint.status).thenReturn(PrinterStatus.connected);
      when(() => mockPrint.printReceipt(any()))
          .thenAnswer((_) async => PrintResult.ok());

      final id = await queue.enqueue(_receipt());

      expect(id, isNotEmpty);
      expect(id, contains('INV-001'));
    });

    test('emits job on jobStatusStream when enqueued', () async {
      when(() => mockPrint.status).thenReturn(PrinterStatus.connected);
      when(() => mockPrint.printReceipt(any()))
          .thenAnswer((_) async => PrintResult.ok());

      final statuses = <PrintJob>[];
      queue.jobStatusStream.listen(statuses.add);

      await queue.enqueue(_receipt());
      // Allow async processing to complete
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Should have at least the initial enqueue event
      expect(statuses, isNotEmpty);
      expect(statuses.first.receipt.receiptNumber, 'INV-001');
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Sequential processing
  // ──────────────────────────────────────────────────────────────────────────
  group('processing', () {
    test('executes print jobs sequentially (not in parallel)', () async {
      when(() => mockPrint.status).thenReturn(PrinterStatus.connected);

      // Track the order of print calls
      final printOrder = <String>[];
      when(() => mockPrint.printReceipt(any())).thenAnswer((inv) async {
        final receipt = inv.positionalArguments[0] as ReceiptData;
        printOrder.add(receipt.receiptNumber);
        // Simulate some processing time
        await Future<void>.delayed(const Duration(milliseconds: 20));
        return PrintResult.ok();
      });

      await queue.enqueue(_receipt(number: 'FIRST'));
      // Give it time to start processing
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await queue.enqueue(_receipt(number: 'SECOND'));

      // Wait for all processing
      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(printOrder, ['FIRST', 'SECOND']);
    });

    test('successful job removed from pendingJobs', () async {
      when(() => mockPrint.status).thenReturn(PrinterStatus.connected);
      when(() => mockPrint.printReceipt(any()))
          .thenAnswer((_) async => PrintResult.ok());

      await queue.enqueue(_receipt());
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(queue.pendingJobs, isEmpty);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Retry logic
  // ──────────────────────────────────────────────────────────────────────────
  group('retry on failure', () {
    test('failed print retried up to 3 times', () async {
      when(() => mockPrint.status).thenReturn(PrinterStatus.connected);

      var attempts = 0;
      when(() => mockPrint.printReceipt(any())).thenAnswer((_) async {
        attempts++;
        return PrintResult.fail('Paper jam');
      });

      await queue.enqueue(_receipt());

      // Wait enough for 3 retries with exponential backoff:
      // Attempt 1 immediate, then delay 3s, attempt 2, delay 6s, attempt 3
      // We use a generous timeout to avoid flaky tests
      await Future<void>.delayed(const Duration(seconds: 12));

      expect(attempts, PrintQueueService.maxRetries);
    });

    test('after max retries, job moves to failedJobs', () async {
      when(() => mockPrint.status).thenReturn(PrinterStatus.connected);
      when(() => mockPrint.printReceipt(any()))
          .thenAnswer((_) async => PrintResult.fail('Error'));

      await queue.enqueue(_receipt());
      await Future<void>.delayed(const Duration(seconds: 12));

      expect(queue.failedJobs, hasLength(1));
      expect(queue.failedJobs.first.status, PrintJobStatus.failed);
      expect(queue.failedJobs.first.lastError, 'Error');
      expect(queue.pendingJobs, isEmpty);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // retryFailedJob
  // ──────────────────────────────────────────────────────────────────────────
  group('retryFailedJob', () {
    test('moves job from failedJobs back to pending queue', () async {
      when(() => mockPrint.status).thenReturn(PrinterStatus.connected);

      // First: fail all attempts so job lands in failedJobs
      when(() => mockPrint.printReceipt(any()))
          .thenAnswer((_) async => PrintResult.fail('Error'));

      final id = await queue.enqueue(_receipt());
      await Future<void>.delayed(const Duration(seconds: 12));

      expect(queue.failedJobs, hasLength(1));
      final failedId = queue.failedJobs.first.id;

      // Now make print succeed
      when(() => mockPrint.printReceipt(any()))
          .thenAnswer((_) async => PrintResult.ok());

      final result = await queue.retryFailedJob(failedId);
      expect(result, isTrue);

      // After retry, failedJobs should be empty (moved back to queue)
      // and the job should process successfully
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(queue.failedJobs, isEmpty);
    });

    test('retryFailedJob resets attempt counter to 0', () async {
      when(() => mockPrint.status).thenReturn(PrinterStatus.connected);
      when(() => mockPrint.printReceipt(any()))
          .thenAnswer((_) async => PrintResult.fail('Error'));

      await queue.enqueue(_receipt());
      await Future<void>.delayed(const Duration(seconds: 12));

      final failedJob = queue.failedJobs.first;
      expect(failedJob.attempts, PrintQueueService.maxRetries);

      // Retry and check counter resets before processing
      final statuses = <PrintJob>[];
      queue.jobStatusStream.listen(statuses.add);

      when(() => mockPrint.printReceipt(any()))
          .thenAnswer((_) async => PrintResult.ok());

      await queue.retryFailedJob(failedJob.id);
      await Future<void>.delayed(const Duration(milliseconds: 200));

      // The job that was moved back should have had attempts reset
      final retriedStatus = statuses.firstWhere(
        (j) => j.id == failedJob.id && j.status == PrintJobStatus.pending,
      );
      expect(retriedStatus.attempts, 0);
    });

    test('returns false for non-existent job ID', () async {
      final result = await queue.retryFailedJob('non-existent-id');
      expect(result, isFalse);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Persistence
  // ──────────────────────────────────────────────────────────────────────────
  group('SharedPreferences persistence', () {
    test('failed jobs are persisted to SharedPreferences', () async {
      when(() => mockPrint.status).thenReturn(PrinterStatus.connected);
      when(() => mockPrint.printReceipt(any()))
          .thenAnswer((_) async => PrintResult.fail('Printer offline'));

      await queue.enqueue(_receipt(number: 'PERSIST-001'));
      await Future<void>.delayed(const Duration(seconds: 12));

      // Verify data was written to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('print_queue_failed_jobs');

      expect(jsonStr, isNotNull);
      final decoded = json.decode(jsonStr!) as List<dynamic>;
      expect(decoded, hasLength(1));

      final jobMap = decoded.first as Map<String, dynamic>;
      expect(jobMap['status'], 'failed');
      expect(jobMap['lastError'], 'Printer offline');
    });

    test('initialize loads persisted failed jobs', () async {
      // Pre-populate SharedPreferences with a failed job
      final failedJobJson = json.encode([
        {
          'id': 'persisted-job-1',
          'receiptNumber': 'INV-PERSISTED',
          'status': 'failed',
          'attempts': 3,
          'createdAt': DateTime(2026, 1, 1).toIso8601String(),
          'lastError': 'Saved error',
          'receipt': {
            'receiptNumber': 'INV-PERSISTED',
            'dateTime': DateTime(2026, 1, 1).toIso8601String(),
            'cashierName': 'Test',
            'items': [
              {
                'name': 'Item',
                'quantity': 1.0,
                'unitPrice': 10.0,
                'total': 10.0,
              }
            ],
            'subtotal': 10.0,
            'discount': 0.0,
            'tax': 1.5,
            'total': 11.5,
            'paymentMethod': 'cash',
            'storeName': 'Al-HAI Store',
            'storeAddress': 'Test',
            'storePhone': '0500000000',
            'storeVat': '300000000000003',
          },
        }
      ]);
      SharedPreferences.setMockInitialValues({
        'print_queue_failed_jobs': failedJobJson,
      });

      // Create a fresh queue and initialize
      final freshQueue = PrintQueueService(mockPrint);
      await freshQueue.initialize();

      expect(freshQueue.failedJobs, hasLength(1));
      expect(freshQueue.failedJobs.first.id, 'persisted-job-1');
      expect(freshQueue.failedJobs.first.lastError, 'Saved error');
      expect(
          freshQueue.failedJobs.first.receipt.receiptNumber, 'INV-PERSISTED');

      freshQueue.dispose();
    });

    test('clearing failed jobs removes SharedPreferences key', () async {
      when(() => mockPrint.status).thenReturn(PrinterStatus.connected);
      when(() => mockPrint.printReceipt(any()))
          .thenAnswer((_) async => PrintResult.fail('Error'));

      await queue.enqueue(_receipt());
      await Future<void>.delayed(const Duration(seconds: 12));

      expect(queue.failedJobs, hasLength(1));

      await queue.clearFailedJobs();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('print_queue_failed_jobs'), isNull);
      expect(queue.failedJobs, isEmpty);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Printer disconnected
  // ──────────────────────────────────────────────────────────────────────────
  group('printer not connected', () {
    test('job moves to failed immediately when printer disconnected', () async {
      when(() => mockPrint.status).thenReturn(PrinterStatus.disconnected);

      await queue.enqueue(_receipt());
      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(queue.failedJobs, hasLength(1));
      expect(queue.pendingJobs, isEmpty);
    });
  });
}
