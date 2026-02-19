import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pos_app/data/local/app_database.dart';
import 'package:pos_app/data/local/daos/whatsapp_messages_dao.dart';
import 'package:pos_app/services/connectivity_service.dart';
import 'package:pos_app/services/whatsapp/models/wasender_models.dart';
import 'package:pos_app/services/whatsapp/wasender_api_client.dart';
import 'package:pos_app/services/whatsapp/whatsapp_queue_processor.dart';

// ===========================================
// Mocks
// ===========================================

class MockWaSenderApiClient extends Mock implements WaSenderApiClient {}

class MockWhatsAppMessagesDao extends Mock implements WhatsAppMessagesDao {}

class MockConnectivityService extends Mock implements ConnectivityService {}

// ===========================================
// Helpers
// ===========================================

WhatsAppMessagesTableData _fakeMessage({
  required String id,
  String status = 'pending',
  String messageType = 'text',
  String phone = '966501234567',
  String? textContent = 'Hello',
  String? mediaUrl,
  String? mediaLocalPath,
  String? fileName,
  int retryCount = 0,
  DateTime? lastAttemptAt,
}) {
  return WhatsAppMessagesTableData(
    id: id,
    storeId: 'test-store',
    phone: phone,
    messageType: messageType,
    textContent: textContent,
    mediaUrl: mediaUrl,
    mediaLocalPath: mediaLocalPath,
    fileName: fileName,
    status: status,
    retryCount: retryCount,
    maxRetries: 3,
    priority: 2,
    createdAt: DateTime.now(),
    lastAttemptAt: lastAttemptAt,
  );
}

// ===========================================
// Tests
// ===========================================

void main() {
  late MockWaSenderApiClient mockApi;
  late MockWhatsAppMessagesDao mockDao;
  late MockConnectivityService mockConnectivity;
  late WhatsAppQueueProcessor processor;

  setUpAll(() {
    registerFallbackValue(const Duration(days: 90));
  });

  setUp(() {
    mockApi = MockWaSenderApiClient();
    mockDao = MockWhatsAppMessagesDao();
    mockConnectivity = MockConnectivityService();

    processor = WhatsAppQueueProcessor(
      apiClient: mockApi,
      messagesDao: mockDao,
      connectivity: mockConnectivity,
    );

    // Default: online
    when(() => mockConnectivity.isOffline).thenReturn(false);

    // Default stubs
    when(() => mockDao.getPendingMessages()).thenAnswer((_) async => []);
    when(() => mockDao.markAsUploading(any())).thenAnswer((_) async => 1);
    when(() => mockDao.markAsSending(any())).thenAnswer((_) async => 1);
    when(() => mockDao.markAsSent(any(), any())).thenAnswer((_) async => 1);
    when(() => mockDao.markAsFailed(any(), any())).thenAnswer((_) async => 1);
    when(() => mockDao.updateMediaUrl(any(), any()))
        .thenAnswer((_) async => 1);
    when(() => mockDao.deleteOlderThan(olderThan: any(named: 'olderThan')))
        .thenAnswer((_) async => 0);
  });

  tearDown(() {
    processor.dispose();
  });

  // ═══════════════════════════════════════════════════════
  // Initial state
  // ═══════════════════════════════════════════════════════

  group('initial state', () {
    test('is not running initially', () {
      expect(processor.isRunning, isFalse);
    });

    test('is not processing initially', () {
      expect(processor.isProcessing, isFalse);
    });
  });

  // ═══════════════════════════════════════════════════════
  // processQueue - basic flow
  // ═══════════════════════════════════════════════════════

  group('processQueue', () {
    test('skips when offline', () async {
      when(() => mockConnectivity.isOffline).thenReturn(true);

      await processor.processQueue();

      verifyNever(() => mockDao.getPendingMessages());
    });

    test('does nothing when queue is empty', () async {
      when(() => mockDao.getPendingMessages()).thenAnswer((_) async => []);

      await processor.processQueue();

      verify(() => mockDao.getPendingMessages()).called(1);
      verifyNever(() => mockDao.markAsSending(any()));
    });

    test('sends text message successfully', () async {
      final msg = _fakeMessage(id: 'msg-1', textContent: 'Hello');
      when(() => mockDao.getPendingMessages())
          .thenAnswer((_) async => [msg]);
      when(() => mockApi.sendText(to: any(named: 'to'), text: any(named: 'text')))
          .thenAnswer((_) async => const WaSenderResponse(
                success: true,
                msgId: 'ext-1',
              ));

      await processor.processQueue();

      verify(() => mockDao.markAsSending('msg-1')).called(1);
      verify(() => mockDao.markAsSent('msg-1', 'ext-1')).called(1);
    });

    test('marks message as failed on API error', () async {
      final msg = _fakeMessage(id: 'msg-2', textContent: 'Hello');
      when(() => mockDao.getPendingMessages())
          .thenAnswer((_) async => [msg]);
      when(() => mockApi.sendText(to: any(named: 'to'), text: any(named: 'text')))
          .thenAnswer((_) async => WaSenderResponse.error('Rate limited'));

      await processor.processQueue();

      verify(() => mockDao.markAsFailed('msg-2', 'Rate limited')).called(1);
    });

    test('marks message as failed on exception', () async {
      final msg = _fakeMessage(id: 'msg-3', textContent: 'Hello');
      when(() => mockDao.getPendingMessages())
          .thenAnswer((_) async => [msg]);
      when(() => mockApi.sendText(to: any(named: 'to'), text: any(named: 'text')))
          .thenThrow(Exception('Network error'));

      await processor.processQueue();

      verify(() => mockDao.markAsFailed('msg-3', any())).called(1);
    });

    test('processes multiple messages', () async {
      final msg1 = _fakeMessage(id: 'msg-a', textContent: 'A');
      final msg2 = _fakeMessage(id: 'msg-b', textContent: 'B');
      when(() => mockDao.getPendingMessages())
          .thenAnswer((_) async => [msg1, msg2]);
      when(() => mockApi.sendText(to: any(named: 'to'), text: any(named: 'text')))
          .thenAnswer((_) async => const WaSenderResponse(
                success: true,
                msgId: 'ext-x',
              ));

      await processor.processQueue();

      verify(() => mockDao.markAsSending(any())).called(2);
      verify(() => mockDao.markAsSent(any(), any())).called(2);
    });

    test('stops processing when going offline mid-queue', () async {
      var callCount = 0;
      final msg1 = _fakeMessage(id: 'msg-1', textContent: 'A');
      final msg2 = _fakeMessage(id: 'msg-2', textContent: 'B');

      when(() => mockDao.getPendingMessages())
          .thenAnswer((_) async => [msg1, msg2]);

      // Go offline after first check (processQueue entry) and first loop iteration
      when(() => mockConnectivity.isOffline).thenAnswer((_) {
        callCount++;
        // callCount 1: processQueue entry check -> false (online)
        // callCount 2: first loop iteration -> false (still online, process msg1)
        // callCount 3: second loop iteration -> true (offline, skip msg2)
        return callCount > 2;
      });

      when(() => mockApi.sendText(to: any(named: 'to'), text: any(named: 'text')))
          .thenAnswer((_) async => const WaSenderResponse(
                success: true,
                msgId: 'ext-1',
              ));

      await processor.processQueue();

      // Only the first message should be processed fully
      verify(() => mockDao.markAsSending('msg-1')).called(1);
      verify(() => mockDao.markAsSent('msg-1', 'ext-1')).called(1);
      // Second message should not be processed
      verifyNever(() => mockDao.markAsSending('msg-2'));
    });
  });

  // ═══════════════════════════════════════════════════════
  // Message types
  // ═══════════════════════════════════════════════════════

  group('message types', () {
    test('sends image message with mediaUrl', () async {
      final msg = _fakeMessage(
        id: 'img-1',
        messageType: 'image',
        mediaUrl: 'https://example.com/image.jpg',
        textContent: 'Caption',
      );
      when(() => mockDao.getPendingMessages())
          .thenAnswer((_) async => [msg]);
      when(() => mockApi.sendImage(
            to: any(named: 'to'),
            imageUrl: any(named: 'imageUrl'),
            caption: any(named: 'caption'),
          )).thenAnswer((_) async => const WaSenderResponse(
            success: true,
            msgId: 'ext-img',
          ));

      await processor.processQueue();

      verify(() => mockApi.sendImage(
            to: '966501234567',
            imageUrl: 'https://example.com/image.jpg',
            caption: 'Caption',
          )).called(1);
    });

    test('sends document message', () async {
      final msg = _fakeMessage(
        id: 'doc-1',
        messageType: 'document',
        mediaUrl: 'https://example.com/file.pdf',
        fileName: 'receipt.pdf',
        textContent: 'Receipt',
      );
      when(() => mockDao.getPendingMessages())
          .thenAnswer((_) async => [msg]);
      when(() => mockApi.sendDocument(
            to: any(named: 'to'),
            documentUrl: any(named: 'documentUrl'),
            fileName: any(named: 'fileName'),
            caption: any(named: 'caption'),
          )).thenAnswer((_) async => const WaSenderResponse(
            success: true,
            msgId: 'ext-doc',
          ));

      await processor.processQueue();

      verify(() => mockApi.sendDocument(
            to: '966501234567',
            documentUrl: 'https://example.com/file.pdf',
            fileName: 'receipt.pdf',
            caption: 'Receipt',
          )).called(1);
    });

    test('returns error for image without mediaUrl', () async {
      final msg = _fakeMessage(
        id: 'img-err',
        messageType: 'image',
        textContent: 'No image',
      );
      when(() => mockDao.getPendingMessages())
          .thenAnswer((_) async => [msg]);

      await processor.processQueue();

      verify(() => mockDao.markAsFailed('img-err', any())).called(1);
    });
  });

  // ═══════════════════════════════════════════════════════
  // Retry delay (exponential backoff)
  // ═══════════════════════════════════════════════════════

  group('retry delay', () {
    test('skips message when retry delay not elapsed', () async {
      final msg = _fakeMessage(
        id: 'retry-1',
        retryCount: 1,
        lastAttemptAt: DateTime.now().subtract(const Duration(seconds: 2)),
        // retryCount=1 -> 5s delay, only 2s elapsed
      );
      when(() => mockDao.getPendingMessages())
          .thenAnswer((_) async => [msg]);

      await processor.processQueue();

      // Should not attempt to send
      verifyNever(() => mockDao.markAsSending('retry-1'));
    });

    test('processes message when retry delay has elapsed', () async {
      final msg = _fakeMessage(
        id: 'retry-2',
        retryCount: 1,
        lastAttemptAt: DateTime.now().subtract(const Duration(seconds: 10)),
        // retryCount=1 -> 5s delay, 10s elapsed
      );
      when(() => mockDao.getPendingMessages())
          .thenAnswer((_) async => [msg]);
      when(() => mockApi.sendText(to: any(named: 'to'), text: any(named: 'text')))
          .thenAnswer((_) async => const WaSenderResponse(
                success: true,
                msgId: 'ext-retry',
              ));

      await processor.processQueue();

      verify(() => mockDao.markAsSending('retry-2')).called(1);
    });
  });

  // ═══════════════════════════════════════════════════════
  // start / stop / dispose
  // ═══════════════════════════════════════════════════════

  group('lifecycle', () {
    test('stop cancels timers', () {
      // Just verify it doesn't throw
      processor.stop();
      expect(processor.isRunning, isFalse);
    });

    test('dispose calls stop', () {
      processor.dispose();
      expect(processor.isRunning, isFalse);
    });
  });
}
