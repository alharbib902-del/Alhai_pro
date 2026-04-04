import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:alhai_zatca/src/api/clearance_api.dart';
import 'package:alhai_zatca/src/api/reporting_api.dart';
import 'package:alhai_zatca/src/certificate/certificate_storage.dart';
import 'package:alhai_zatca/src/models/certificate_info.dart';
import 'package:alhai_zatca/src/models/reporting_status.dart';
import 'package:alhai_zatca/src/models/zatca_response.dart';
import 'package:alhai_zatca/src/services/zatca_offline_queue.dart';

class MockReportingApi extends Mock implements ReportingApi {}

class MockClearanceApi extends Mock implements ClearanceApi {}

class MockCertificateStorage extends Mock implements CertificateStorage {}

class FakeCertificateInfo extends Fake implements CertificateInfo {}

void main() {
  late ZatcaOfflineQueue queue;

  final testCertificate = CertificateInfo(
    certificatePem: 'test-cert-pem',
    privateKeyPem: 'test-key-pem',
    csid: 'test-csid',
    secret: 'test-secret',
    isProduction: true,
  );

  final successResponse = const ZatcaResponse(
    isSuccess: true,
    statusCode: 200,
    reportingStatus: ReportingStatus.reported,
  );

  final failureResponse = ZatcaResponse.failure(
    message: 'Validation failed',
  );

  setUpAll(() {
    registerFallbackValue(FakeCertificateInfo());
  });

  setUp(() {
    queue = ZatcaOfflineQueue();
  });

  group('ZatcaOfflineQueue', () {
    // ── Enqueue ─────────────────────────────────────────────

    group('enqueue', () {
      test('adds an invoice to the queue', () async {
        await queue.enqueue(
          invoiceNumber: 'INV-001',
          signedXmlBase64: 'xml-base64',
          invoiceHash: 'hash-abc',
          uuid: 'uuid-001',
          isStandard: false,
        );

        final count = await queue.pendingCount;
        expect(count, 1);
      });

      test('avoids duplicate entries for same invoice number', () async {
        await queue.enqueue(
          invoiceNumber: 'INV-001',
          signedXmlBase64: 'xml-v1',
          invoiceHash: 'hash-v1',
          uuid: 'uuid-001',
          isStandard: false,
        );
        await queue.enqueue(
          invoiceNumber: 'INV-001',
          signedXmlBase64: 'xml-v2',
          invoiceHash: 'hash-v2',
          uuid: 'uuid-001',
          isStandard: false,
        );

        final count = await queue.pendingCount;
        expect(count, 1);

        final items = await queue.getAll();
        expect(items.first.signedXmlBase64, 'xml-v2');
      });

      test('adds multiple distinct invoices', () async {
        for (var i = 1; i <= 5; i++) {
          await queue.enqueue(
            invoiceNumber: 'INV-00$i',
            signedXmlBase64: 'xml-$i',
            invoiceHash: 'hash-$i',
            uuid: 'uuid-$i',
            isStandard: i.isOdd,
          );
        }

        final count = await queue.pendingCount;
        expect(count, 5);
      });

      test('sets retry count to 0 for new entries', () async {
        await queue.enqueue(
          invoiceNumber: 'INV-001',
          signedXmlBase64: 'xml',
          invoiceHash: 'hash',
          uuid: 'uuid',
          isStandard: false,
        );

        final items = await queue.getAll();
        expect(items.first.retryCount, 0);
      });
    });

    // ── Dequeue ─────────────────────────────────────────────

    group('dequeue', () {
      test('removes an invoice from the queue', () async {
        await queue.enqueue(
          invoiceNumber: 'INV-001',
          signedXmlBase64: 'xml',
          invoiceHash: 'hash',
          uuid: 'uuid',
          isStandard: false,
        );
        await queue.dequeue(invoiceNumber: 'INV-001');

        final count = await queue.pendingCount;
        expect(count, 0);
      });

      test('does nothing when dequeuing non-existent invoice', () async {
        await queue.enqueue(
          invoiceNumber: 'INV-001',
          signedXmlBase64: 'xml',
          invoiceHash: 'hash',
          uuid: 'uuid',
          isStandard: false,
        );
        await queue.dequeue(invoiceNumber: 'INV-999');

        final count = await queue.pendingCount;
        expect(count, 1);
      });
    });

    // ── Retry Count ─────────────────────────────────────────

    group('retry tracking', () {
      test('increments retry count', () async {
        await queue.enqueue(
          invoiceNumber: 'INV-001',
          signedXmlBase64: 'xml',
          invoiceHash: 'hash',
          uuid: 'uuid',
          isStandard: false,
        );

        await queue.incrementRetry(invoiceNumber: 'INV-001');
        await queue.incrementRetry(invoiceNumber: 'INV-001');

        final items = await queue.getAll();
        expect(items.first.retryCount, 2);
      });

      test('sets lastRetryAt on increment', () async {
        await queue.enqueue(
          invoiceNumber: 'INV-001',
          signedXmlBase64: 'xml',
          invoiceHash: 'hash',
          uuid: 'uuid',
          isStandard: false,
        );

        await queue.incrementRetry(invoiceNumber: 'INV-001');

        final items = await queue.getAll();
        expect(items.first.lastRetryAt, isNotNull);
      });

      test('marks invoice as max retries exceeded at limit', () async {
        await queue.enqueue(
          invoiceNumber: 'INV-001',
          signedXmlBase64: 'xml',
          invoiceHash: 'hash',
          uuid: 'uuid',
          isStandard: false,
        );

        for (var i = 0; i < QueuedInvoice.maxRetries; i++) {
          await queue.incrementRetry(invoiceNumber: 'INV-001');
        }

        final items = await queue.getAll();
        expect(items.first.isMaxRetriesExceeded, isTrue);
      });
    });

    // ── Failed Invoices ─────────────────────────────────────

    group('failed invoices', () {
      test('getFailedInvoices returns max-retried items', () async {
        await queue.enqueue(
          invoiceNumber: 'INV-001',
          signedXmlBase64: 'xml',
          invoiceHash: 'hash',
          uuid: 'uuid',
          isStandard: false,
        );
        for (var i = 0; i < QueuedInvoice.maxRetries; i++) {
          await queue.incrementRetry(invoiceNumber: 'INV-001');
        }

        await queue.enqueue(
          invoiceNumber: 'INV-002',
          signedXmlBase64: 'xml2',
          invoiceHash: 'hash2',
          uuid: 'uuid2',
          isStandard: false,
        );

        final failed = await queue.getFailedInvoices();
        expect(failed.length, 1);
        expect(failed.first.invoiceNumber, 'INV-001');
      });

      test('retryableCount excludes max-retried items', () async {
        await queue.enqueue(
          invoiceNumber: 'INV-001',
          signedXmlBase64: 'xml',
          invoiceHash: 'hash',
          uuid: 'uuid',
          isStandard: false,
        );
        for (var i = 0; i < QueuedInvoice.maxRetries; i++) {
          await queue.incrementRetry(invoiceNumber: 'INV-001');
        }

        await queue.enqueue(
          invoiceNumber: 'INV-002',
          signedXmlBase64: 'xml2',
          invoiceHash: 'hash2',
          uuid: 'uuid2',
          isStandard: false,
        );

        final retryable = await queue.retryableCount;
        expect(retryable, 1);
      });
    });

    // ── Clear ───────────────────────────────────────────────

    group('clear operations', () {
      test('clearAll removes everything', () async {
        for (var i = 1; i <= 3; i++) {
          await queue.enqueue(
            invoiceNumber: 'INV-00$i',
            signedXmlBase64: 'xml-$i',
            invoiceHash: 'hash-$i',
            uuid: 'uuid-$i',
            isStandard: false,
          );
        }
        await queue.clearAll();

        final count = await queue.pendingCount;
        expect(count, 0);
      });

      test('clearFailed removes only max-retried items', () async {
        // INV-001: exhausted retries
        await queue.enqueue(
          invoiceNumber: 'INV-001',
          signedXmlBase64: 'xml',
          invoiceHash: 'hash',
          uuid: 'uuid',
          isStandard: false,
        );
        for (var i = 0; i < QueuedInvoice.maxRetries; i++) {
          await queue.incrementRetry(invoiceNumber: 'INV-001');
        }

        // INV-002: still retryable
        await queue.enqueue(
          invoiceNumber: 'INV-002',
          signedXmlBase64: 'xml2',
          invoiceHash: 'hash2',
          uuid: 'uuid2',
          isStandard: false,
        );

        final removed = await queue.clearFailed();
        expect(removed, 1);

        final remaining = await queue.pendingCount;
        expect(remaining, 1);
      });
    });

    // ── processQueue ────────────────────────────────────────

    group('processQueue', () {
      late MockReportingApi mockReportingApi;
      late MockClearanceApi mockClearanceApi;
      late MockCertificateStorage mockCertStorage;

      setUp(() {
        mockReportingApi = MockReportingApi();
        mockClearanceApi = MockClearanceApi();
        mockCertStorage = MockCertificateStorage();
      });

      test('returns error if no certificate found', () async {
        when(() =>
                mockCertStorage.getCertificate(storeId: any(named: 'storeId')))
            .thenAnswer((_) async => null);

        await queue.enqueue(
          invoiceNumber: 'INV-001',
          signedXmlBase64: 'xml',
          invoiceHash: 'hash',
          uuid: 'uuid',
          isStandard: false,
        );

        final results = await queue.processQueue(
          reportingApi: mockReportingApi,
          clearanceApi: mockClearanceApi,
          certStorage: mockCertStorage,
          storeId: 'store-1',
        );

        expect(results.length, 1);
        expect(results.first.success, isFalse);
        expect(results.first.message, contains('No certificate'));
      });

      test('submits simplified invoice via reporting API', () async {
        when(() =>
                mockCertStorage.getCertificate(storeId: any(named: 'storeId')))
            .thenAnswer((_) async => testCertificate);
        when(() => mockReportingApi.reportInvoice(
              signedXmlBase64: any(named: 'signedXmlBase64'),
              invoiceHash: any(named: 'invoiceHash'),
              uuid: any(named: 'uuid'),
              certificate: any(named: 'certificate'),
            )).thenAnswer((_) async => successResponse);

        await queue.enqueue(
          invoiceNumber: 'INV-001',
          signedXmlBase64: 'xml',
          invoiceHash: 'hash',
          uuid: 'uuid',
          isStandard: false,
        );

        final results = await queue.processQueue(
          reportingApi: mockReportingApi,
          clearanceApi: mockClearanceApi,
          certStorage: mockCertStorage,
          storeId: 'store-1',
        );

        expect(results.length, 1);
        expect(results.first.success, isTrue);

        // Should have been dequeued
        final count = await queue.pendingCount;
        expect(count, 0);
      });

      test('submits standard invoice via clearance API', () async {
        when(() =>
                mockCertStorage.getCertificate(storeId: any(named: 'storeId')))
            .thenAnswer((_) async => testCertificate);
        when(() => mockClearanceApi.clearInvoice(
              signedXmlBase64: any(named: 'signedXmlBase64'),
              invoiceHash: any(named: 'invoiceHash'),
              uuid: any(named: 'uuid'),
              certificate: any(named: 'certificate'),
            )).thenAnswer((_) async => successResponse);

        await queue.enqueue(
          invoiceNumber: 'INV-001',
          signedXmlBase64: 'xml',
          invoiceHash: 'hash',
          uuid: 'uuid',
          isStandard: true,
        );

        final results = await queue.processQueue(
          reportingApi: mockReportingApi,
          clearanceApi: mockClearanceApi,
          certStorage: mockCertStorage,
          storeId: 'store-1',
        );

        expect(results.first.success, isTrue);
        verify(() => mockClearanceApi.clearInvoice(
              signedXmlBase64: any(named: 'signedXmlBase64'),
              invoiceHash: any(named: 'invoiceHash'),
              uuid: any(named: 'uuid'),
              certificate: any(named: 'certificate'),
            )).called(1);
      });

      test('increments retry on ZATCA rejection', () async {
        when(() =>
                mockCertStorage.getCertificate(storeId: any(named: 'storeId')))
            .thenAnswer((_) async => testCertificate);
        when(() => mockReportingApi.reportInvoice(
              signedXmlBase64: any(named: 'signedXmlBase64'),
              invoiceHash: any(named: 'invoiceHash'),
              uuid: any(named: 'uuid'),
              certificate: any(named: 'certificate'),
            )).thenAnswer((_) async => failureResponse);

        await queue.enqueue(
          invoiceNumber: 'INV-001',
          signedXmlBase64: 'xml',
          invoiceHash: 'hash',
          uuid: 'uuid',
          isStandard: false,
        );

        final results = await queue.processQueue(
          reportingApi: mockReportingApi,
          clearanceApi: mockClearanceApi,
          certStorage: mockCertStorage,
          storeId: 'store-1',
        );

        expect(results.first.success, isFalse);

        // Invoice should still be in queue with incremented retry count
        final items = await queue.getAll();
        expect(items.length, 1);
        expect(items.first.retryCount, 1);
      });

      test('increments retry on network exception', () async {
        when(() =>
                mockCertStorage.getCertificate(storeId: any(named: 'storeId')))
            .thenAnswer((_) async => testCertificate);
        when(() => mockReportingApi.reportInvoice(
              signedXmlBase64: any(named: 'signedXmlBase64'),
              invoiceHash: any(named: 'invoiceHash'),
              uuid: any(named: 'uuid'),
              certificate: any(named: 'certificate'),
            )).thenThrow(Exception('Connection refused'));

        await queue.enqueue(
          invoiceNumber: 'INV-001',
          signedXmlBase64: 'xml',
          invoiceHash: 'hash',
          uuid: 'uuid',
          isStandard: false,
        );

        final results = await queue.processQueue(
          reportingApi: mockReportingApi,
          clearanceApi: mockClearanceApi,
          certStorage: mockCertStorage,
          storeId: 'store-1',
        );

        expect(results.first.success, isFalse);
        expect(results.first.message, contains('Network error'));
      });

      test('skips max-retried invoices during processing', () async {
        when(() =>
                mockCertStorage.getCertificate(storeId: any(named: 'storeId')))
            .thenAnswer((_) async => testCertificate);

        // Add invoice and exhaust retries
        await queue.enqueue(
          invoiceNumber: 'INV-001',
          signedXmlBase64: 'xml',
          invoiceHash: 'hash',
          uuid: 'uuid',
          isStandard: false,
        );
        for (var i = 0; i < QueuedInvoice.maxRetries; i++) {
          await queue.incrementRetry(invoiceNumber: 'INV-001');
        }

        final results = await queue.processQueue(
          reportingApi: mockReportingApi,
          clearanceApi: mockClearanceApi,
          certStorage: mockCertStorage,
          storeId: 'store-1',
        );

        // No invoices to process
        expect(results, isEmpty);
        verifyNever(() => mockReportingApi.reportInvoice(
              signedXmlBase64: any(named: 'signedXmlBase64'),
              invoiceHash: any(named: 'invoiceHash'),
              uuid: any(named: 'uuid'),
              certificate: any(named: 'certificate'),
            ));
      });
    });

    // ── Persistence Callbacks ───────────────────────────────

    group('persistence callbacks', () {
      test('calls onQueueChanged when enqueuing', () async {
        var callCount = 0;
        queue.onQueueChanged = (_) async {
          callCount++;
        };

        await queue.enqueue(
          invoiceNumber: 'INV-001',
          signedXmlBase64: 'xml',
          invoiceHash: 'hash',
          uuid: 'uuid',
          isStandard: false,
        );

        expect(callCount, 1);
      });

      test('calls onLoadQueue on first access', () async {
        var loadCalled = false;
        queue.onLoadQueue = () async {
          loadCalled = true;
          return [
            QueuedInvoice(
              invoiceNumber: 'PERSISTED-001',
              signedXmlBase64: 'xml',
              invoiceHash: 'hash',
              uuid: 'uuid',
              isStandard: false,
              queuedAt: DateTime.now(),
            ),
          ];
        };

        final items = await queue.getAll();
        expect(loadCalled, isTrue);
        expect(items.length, 1);
        expect(items.first.invoiceNumber, 'PERSISTED-001');
      });

      test('does not crash when persistence callback throws', () async {
        queue.onQueueChanged = (_) async {
          throw Exception('Storage full');
        };

        // Should not throw
        await queue.enqueue(
          invoiceNumber: 'INV-001',
          signedXmlBase64: 'xml',
          invoiceHash: 'hash',
          uuid: 'uuid',
          isStandard: false,
        );

        final count = await queue.pendingCount;
        expect(count, 1);
      });
    });

    // ── QueuedInvoice Model ─────────────────────────────────

    group('QueuedInvoice model', () {
      test('toJson and fromJson round-trip', () {
        final original = QueuedInvoice(
          invoiceNumber: 'INV-001',
          signedXmlBase64: 'xml-data',
          invoiceHash: 'hash-data',
          uuid: 'uuid-data',
          isStandard: true,
          storeId: 'store-1',
          queuedAt: DateTime(2026, 1, 15, 10, 0),
          lastRetryAt: DateTime(2026, 1, 15, 11, 0),
          retryCount: 3,
        );

        final json = original.toJson();
        final restored = QueuedInvoice.fromJson(json);

        expect(restored.invoiceNumber, original.invoiceNumber);
        expect(restored.signedXmlBase64, original.signedXmlBase64);
        expect(restored.invoiceHash, original.invoiceHash);
        expect(restored.uuid, original.uuid);
        expect(restored.isStandard, original.isStandard);
        expect(restored.storeId, original.storeId);
        expect(restored.retryCount, original.retryCount);
      });

      test('isMaxRetriesExceeded returns false when under limit', () {
        final item = QueuedInvoice(
          invoiceNumber: 'INV-001',
          signedXmlBase64: 'xml',
          invoiceHash: 'hash',
          uuid: 'uuid',
          isStandard: false,
          queuedAt: DateTime.now(),
          retryCount: QueuedInvoice.maxRetries - 1,
        );

        expect(item.isMaxRetriesExceeded, isFalse);
      });

      test('timeInQueue returns positive duration', () {
        final item = QueuedInvoice(
          invoiceNumber: 'INV-001',
          signedXmlBase64: 'xml',
          invoiceHash: 'hash',
          uuid: 'uuid',
          isStandard: false,
          queuedAt: DateTime.now().subtract(const Duration(hours: 2)),
        );

        expect(item.timeInQueue.inHours, greaterThanOrEqualTo(2));
      });
    });
  });
}
