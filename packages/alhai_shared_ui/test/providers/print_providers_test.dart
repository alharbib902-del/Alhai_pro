/// Unit tests for print providers
///
/// Tests: PrintJob model, PrintQueueNotifier state management
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alhai_shared_ui/alhai_shared_ui.dart';

void main() {
  group('PrintJob', () {
    test('creates with default status pending', () {
      final job = PrintJob(
        id: 'job-1',
        saleId: 'sale-1',
        receiptNo: 'REC-001',
        type: 'receipt',
        createdAt: DateTime(2026, 1, 1),
      );
      expect(job.status, 'pending');
      expect(job.retryCount, 0);
      expect(job.errorMessage, isNull);
    });

    test('toJson serializes correctly', () {
      final job = PrintJob(
        id: 'job-1',
        saleId: 'sale-1',
        receiptNo: 'REC-001',
        type: 'receipt',
        status: 'failed',
        errorMessage: 'Connection lost',
        retryCount: 2,
        createdAt: DateTime(2026, 1, 1),
      );
      final json = job.toJson();
      expect(json['id'], 'job-1');
      expect(json['saleId'], 'sale-1');
      expect(json['status'], 'failed');
      expect(json['errorMessage'], 'Connection lost');
      expect(json['retryCount'], 2);
    });

    test('fromJson deserializes correctly', () {
      final json = {
        'id': 'job-1',
        'saleId': 'sale-1',
        'receiptNo': 'REC-001',
        'type': 'receipt',
        'status': 'completed',
        'retryCount': 1,
        'createdAt': '2026-01-01T00:00:00.000',
      };
      final job = PrintJob.fromJson(json);
      expect(job.id, 'job-1');
      expect(job.status, 'completed');
      expect(job.retryCount, 1);
    });

    test('copyWith updates status', () {
      final job = PrintJob(
        id: 'job-1',
        saleId: 'sale-1',
        receiptNo: 'REC-001',
        type: 'receipt',
        createdAt: DateTime(2026, 1, 1),
      );
      final updated = job.copyWith(status: 'completed');
      expect(updated.status, 'completed');
      expect(updated.id, 'job-1');
    });

    test('copyWith updates error message and retry count', () {
      final job = PrintJob(
        id: 'job-1',
        saleId: 'sale-1',
        receiptNo: 'REC-001',
        type: 'receipt',
        createdAt: DateTime(2026, 1, 1),
      );
      final updated = job.copyWith(
        status: 'failed',
        errorMessage: 'Timeout',
        retryCount: 3,
      );
      expect(updated.status, 'failed');
      expect(updated.errorMessage, 'Timeout');
      expect(updated.retryCount, 3);
    });
  });

  group('PrintQueueNotifier', () {
    test('starts with empty list', () {
      final notifier = PrintQueueNotifier();
      expect(notifier.state, isEmpty);
      expect(notifier.pendingCount, 0);
      expect(notifier.failedCount, 0);
    });

    test('addJob adds a job to state', () {
      final notifier = PrintQueueNotifier();
      notifier.addJob(
        PrintJob(
          id: 'job-1',
          saleId: 'sale-1',
          receiptNo: 'REC-001',
          type: 'receipt',
          createdAt: DateTime(2026, 1, 1),
        ),
      );
      expect(notifier.state.length, 1);
      expect(notifier.pendingCount, 1);
    });

    test('removeJob removes a job', () {
      final notifier = PrintQueueNotifier();
      notifier.addJob(
        PrintJob(
          id: 'job-1',
          saleId: 'sale-1',
          receiptNo: 'REC-001',
          type: 'receipt',
          createdAt: DateTime(2026, 1, 1),
        ),
      );
      notifier.removeJob('job-1');
      expect(notifier.state, isEmpty);
    });

    test('markFailed updates job status', () {
      final notifier = PrintQueueNotifier();
      notifier.addJob(
        PrintJob(
          id: 'job-1',
          saleId: 'sale-1',
          receiptNo: 'REC-001',
          type: 'receipt',
          createdAt: DateTime(2026, 1, 1),
        ),
      );
      notifier.markFailed('job-1', 'Connection error');
      expect(notifier.state.first.status, 'failed');
      expect(notifier.state.first.errorMessage, 'Connection error');
      expect(notifier.state.first.retryCount, 1);
      expect(notifier.failedCount, 1);
    });

    test('markCompleted updates job status', () {
      final notifier = PrintQueueNotifier();
      notifier.addJob(
        PrintJob(
          id: 'job-1',
          saleId: 'sale-1',
          receiptNo: 'REC-001',
          type: 'receipt',
          createdAt: DateTime(2026, 1, 1),
        ),
      );
      notifier.markCompleted('job-1');
      expect(notifier.state.first.status, 'completed');
      expect(notifier.pendingCount, 0);
    });

    test('retryJob resets status to pending', () {
      final notifier = PrintQueueNotifier();
      notifier.addJob(
        PrintJob(
          id: 'job-1',
          saleId: 'sale-1',
          receiptNo: 'REC-001',
          type: 'receipt',
          status: 'failed',
          errorMessage: 'Error',
          createdAt: DateTime(2026, 1, 1),
        ),
      );
      notifier.retryJob('job-1');
      expect(notifier.state.first.status, 'pending');
      expect(notifier.state.first.errorMessage, isNull);
    });

    test('markPrinting updates job status', () {
      final notifier = PrintQueueNotifier();
      notifier.addJob(
        PrintJob(
          id: 'job-1',
          saleId: 'sale-1',
          receiptNo: 'REC-001',
          type: 'receipt',
          createdAt: DateTime(2026, 1, 1),
        ),
      );
      notifier.markPrinting('job-1');
      expect(notifier.state.first.status, 'printing');
    });

    test('clearAll removes all jobs', () {
      final notifier = PrintQueueNotifier();
      notifier.addJob(
        PrintJob(
          id: 'j1',
          saleId: 's1',
          receiptNo: 'R1',
          type: 'receipt',
          createdAt: DateTime(2026, 1, 1),
        ),
      );
      notifier.addJob(
        PrintJob(
          id: 'j2',
          saleId: 's2',
          receiptNo: 'R2',
          type: 'receipt',
          createdAt: DateTime(2026, 1, 1),
        ),
      );
      notifier.clearAll();
      expect(notifier.state, isEmpty);
    });

    test('clearCompleted removes only completed jobs', () {
      final notifier = PrintQueueNotifier();
      notifier.addJob(
        PrintJob(
          id: 'j1',
          saleId: 's1',
          receiptNo: 'R1',
          type: 'receipt',
          createdAt: DateTime(2026, 1, 1),
        ),
      );
      notifier.addJob(
        PrintJob(
          id: 'j2',
          saleId: 's2',
          receiptNo: 'R2',
          type: 'receipt',
          status: 'completed',
          createdAt: DateTime(2026, 1, 1),
        ),
      );
      notifier.clearCompleted();
      expect(notifier.state.length, 1);
      expect(notifier.state.first.id, 'j1');
    });
  });

  group('pendingPrintCountProvider', () {
    test('counts pending and failed jobs', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(printQueueProvider.notifier);
      notifier.addJob(
        PrintJob(
          id: 'j1',
          saleId: 's1',
          receiptNo: 'R1',
          type: 'receipt',
          createdAt: DateTime(2026, 1, 1),
        ),
      );
      notifier.addJob(
        PrintJob(
          id: 'j2',
          saleId: 's2',
          receiptNo: 'R2',
          type: 'receipt',
          status: 'failed',
          createdAt: DateTime(2026, 1, 1),
        ),
      );
      notifier.addJob(
        PrintJob(
          id: 'j3',
          saleId: 's3',
          receiptNo: 'R3',
          type: 'receipt',
          status: 'completed',
          createdAt: DateTime(2026, 1, 1),
        ),
      );

      final count = container.read(pendingPrintCountProvider);
      expect(count, 2); // pending + failed
    });
  });
}
