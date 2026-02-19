import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pos_app/data/local/app_database.dart';
import 'package:pos_app/data/local/daos/whatsapp_messages_dao.dart';
import 'package:pos_app/services/whatsapp/webhook_handler.dart';

// ===========================================
// Mocks
// ===========================================

class MockWhatsAppMessagesDao extends Mock implements WhatsAppMessagesDao {}

// ===========================================
// Helpers
// ===========================================

/// Compute HMAC-SHA256 for testing
String computeHmac(String payload, String secret) {
  final key = utf8.encode(secret);
  final bytes = utf8.encode(payload);
  final hmac = Hmac(sha256, key);
  return hmac.convert(bytes).toString();
}

WhatsAppMessagesTableData _fakeMessage({
  required String id,
  String status = 'sending',
  String? externalMsgId,
}) {
  return WhatsAppMessagesTableData(
    id: id,
    storeId: 'test-store',
    phone: '966501234567',
    messageType: 'text',
    textContent: 'test',
    status: status,
    externalMsgId: externalMsgId,
    retryCount: 0,
    maxRetries: 3,
    priority: 2,
    createdAt: DateTime.now(),
  );
}

// ===========================================
// Tests
// ===========================================

void main() {
  late MockWhatsAppMessagesDao mockDao;
  late WhatsAppWebhookHandler handler;

  setUp(() {
    mockDao = MockWhatsAppMessagesDao();
    handler = WhatsAppWebhookHandler(mockDao);

    // Default stubs
    when(() => mockDao.findByExternalMsgId(any()))
        .thenAnswer((_) async => null);
    when(() => mockDao.markAsSent(any(), any())).thenAnswer((_) async => 1);
    when(() => mockDao.markAsDelivered(any())).thenAnswer((_) async => 1);
    when(() => mockDao.markAsRead(any())).thenAnswer((_) async => 1);
    when(() => mockDao.markAsFailed(any(), any())).thenAnswer((_) async => 1);
  });

  // ═══════════════════════════════════════════════════════
  // verifySignature (HMAC-SHA256)
  // ═══════════════════════════════════════════════════════

  group('verifySignature', () {
    const secret = 'my-webhook-secret';
    const payload = '{"event":"message.sent","data":{}}';

    test('returns true for valid HMAC signature', () {
      final signature = computeHmac(payload, secret);
      expect(
        WhatsAppWebhookHandler.verifySignature(payload, signature, secret),
        isTrue,
      );
    });

    test('returns false for invalid signature', () {
      expect(
        WhatsAppWebhookHandler.verifySignature(payload, 'bad-sig', secret),
        isFalse,
      );
    });

    test('returns false for wrong secret', () {
      final signature = computeHmac(payload, secret);
      expect(
        WhatsAppWebhookHandler.verifySignature(
          payload,
          signature,
          'wrong-secret',
        ),
        isFalse,
      );
    });

    test('returns false for tampered payload', () {
      final signature = computeHmac(payload, secret);
      expect(
        WhatsAppWebhookHandler.verifySignature(
          'tampered-payload',
          signature,
          secret,
        ),
        isFalse,
      );
    });

    test('returns false for empty payload', () {
      expect(
        WhatsAppWebhookHandler.verifySignature('', 'sig', secret),
        isFalse,
      );
    });

    test('returns false for empty signature', () {
      expect(
        WhatsAppWebhookHandler.verifySignature(payload, '', secret),
        isFalse,
      );
    });

    test('returns false for empty secret', () {
      expect(
        WhatsAppWebhookHandler.verifySignature(payload, 'sig', ''),
        isFalse,
      );
    });
  });

  // ═══════════════════════════════════════════════════════
  // verifyTimestamp
  // ═══════════════════════════════════════════════════════

  group('verifyTimestamp', () {
    test('returns true for current unix timestamp', () {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      expect(WhatsAppWebhookHandler.verifyTimestamp(now), isTrue);
    });

    test('returns true for timestamp within tolerance', () {
      final twoMinutesAgo =
          DateTime.now().subtract(const Duration(minutes: 2));
      final ts = twoMinutesAgo.millisecondsSinceEpoch ~/ 1000;
      expect(WhatsAppWebhookHandler.verifyTimestamp(ts), isTrue);
    });

    test('returns false for timestamp older than tolerance', () {
      final tenMinutesAgo =
          DateTime.now().subtract(const Duration(minutes: 10));
      final ts = tenMinutesAgo.millisecondsSinceEpoch ~/ 1000;
      expect(WhatsAppWebhookHandler.verifyTimestamp(ts), isFalse);
    });

    test('returns true for ISO 8601 timestamp within tolerance', () {
      final now = DateTime.now().toIso8601String();
      expect(WhatsAppWebhookHandler.verifyTimestamp(now), isTrue);
    });

    test('returns false for invalid string timestamp', () {
      expect(
        WhatsAppWebhookHandler.verifyTimestamp('not-a-date'),
        isFalse,
      );
    });

    test('returns false for null timestamp', () {
      expect(WhatsAppWebhookHandler.verifyTimestamp(null), isFalse);
    });

    test('respects custom tolerance', () {
      final eightMinutesAgo =
          DateTime.now().subtract(const Duration(minutes: 8));
      final ts = eightMinutesAgo.millisecondsSinceEpoch ~/ 1000;

      // Fails with default 5-min tolerance
      expect(WhatsAppWebhookHandler.verifyTimestamp(ts), isFalse);

      // Passes with 10-min tolerance
      expect(
        WhatsAppWebhookHandler.verifyTimestamp(
          ts,
          tolerance: const Duration(minutes: 10),
        ),
        isTrue,
      );
    });
  });

  // ═══════════════════════════════════════════════════════
  // processEvent - message.sent
  // ═══════════════════════════════════════════════════════

  group('processEvent - message.sent', () {
    test('marks message as sent when found with sending status', () async {
      final msg = _fakeMessage(id: 'local-1', status: 'sending');
      when(() => mockDao.findByExternalMsgId('ext-123'))
          .thenAnswer((_) async => msg);

      await handler.processEvent({
        'event': 'message.sent',
        'data': {
          'key': {'id': 'ext-123'},
        },
      });

      verify(() => mockDao.markAsSent('local-1', 'ext-123')).called(1);
    });

    test('skips update when message already sent', () async {
      final msg = _fakeMessage(
        id: 'local-1',
        status: 'sent',
        externalMsgId: 'ext-123',
      );
      when(() => mockDao.findByExternalMsgId('ext-123'))
          .thenAnswer((_) async => msg);

      await handler.processEvent({
        'event': 'message.sent',
        'data': {
          'key': {'id': 'ext-123'},
        },
      });

      verifyNever(() => mockDao.markAsSent(any(), any()));
    });

    test('handles missing message ID gracefully', () async {
      await handler.processEvent({
        'event': 'message.sent',
        'data': <String, dynamic>{},
      });

      verifyNever(() => mockDao.findByExternalMsgId(any()));
    });

    test('handles message not found gracefully', () async {
      when(() => mockDao.findByExternalMsgId('ext-999'))
          .thenAnswer((_) async => null);

      await handler.processEvent({
        'event': 'message.sent',
        'data': {
          'key': {'id': 'ext-999'},
        },
      });

      verifyNever(() => mockDao.markAsSent(any(), any()));
    });
  });

  // ═══════════════════════════════════════════════════════
  // processEvent - message-update (delivered/read)
  // ═══════════════════════════════════════════════════════

  group('processEvent - message-update', () {
    test('marks message as delivered for status 3', () async {
      final msg = _fakeMessage(
        id: 'local-1',
        status: 'sent',
        externalMsgId: 'ext-123',
      );
      when(() => mockDao.findByExternalMsgId('ext-123'))
          .thenAnswer((_) async => msg);

      await handler.processEvent({
        'event': 'message-update',
        'data': {
          'key': {'id': 'ext-123'},
          'update': {'status': 3},
        },
      });

      verify(() => mockDao.markAsDelivered('local-1')).called(1);
    });

    test('marks message as read for status 4', () async {
      final msg = _fakeMessage(
        id: 'local-1',
        status: 'delivered',
        externalMsgId: 'ext-123',
      );
      when(() => mockDao.findByExternalMsgId('ext-123'))
          .thenAnswer((_) async => msg);

      await handler.processEvent({
        'event': 'message-update',
        'data': {
          'key': {'id': 'ext-123'},
          'update': {'status': 4},
        },
      });

      verify(() => mockDao.markAsRead('local-1')).called(1);
    });

    test('marks message as read for played (status 5)', () async {
      final msg = _fakeMessage(
        id: 'local-1',
        status: 'delivered',
        externalMsgId: 'ext-123',
      );
      when(() => mockDao.findByExternalMsgId('ext-123'))
          .thenAnswer((_) async => msg);

      await handler.processEvent({
        'event': 'message-update',
        'data': {
          'key': {'id': 'ext-123'},
          'update': {'status': 5},
        },
      });

      verify(() => mockDao.markAsRead('local-1')).called(1);
    });

    test('marks message as failed for string status "failed"', () async {
      final msg = _fakeMessage(
        id: 'local-1',
        status: 'sending',
        externalMsgId: 'ext-123',
      );
      when(() => mockDao.findByExternalMsgId('ext-123'))
          .thenAnswer((_) async => msg);

      await handler.processEvent({
        'event': 'message-update',
        'data': {
          'key': {'id': 'ext-123'},
          'update': {'status': 'failed'},
        },
      });

      verify(() => mockDao.markAsFailed('local-1', any())).called(1);
    });

    test('handles string status "delivery_ack"', () async {
      final msg = _fakeMessage(
        id: 'local-1',
        status: 'sent',
        externalMsgId: 'ext-123',
      );
      when(() => mockDao.findByExternalMsgId('ext-123'))
          .thenAnswer((_) async => msg);

      await handler.processEvent({
        'event': 'message-update',
        'data': {
          'key': {'id': 'ext-123'},
          'update': {'status': 'delivery_ack'},
        },
      });

      verify(() => mockDao.markAsDelivered('local-1')).called(1);
    });
  });

  // ═══════════════════════════════════════════════════════
  // processEvent - messages.upsert
  // ═══════════════════════════════════════════════════════

  group('processEvent - messages.upsert', () {
    test('routes outgoing message (fromMe=true) to message.sent handler',
        () async {
      final msg = _fakeMessage(id: 'local-1', status: 'sending');
      when(() => mockDao.findByExternalMsgId('ext-upsert'))
          .thenAnswer((_) async => msg);

      await handler.processEvent({
        'event': 'messages.upsert',
        'data': {
          'key': {'id': 'ext-upsert', 'fromMe': true},
        },
      });

      verify(() => mockDao.markAsSent('local-1', 'ext-upsert')).called(1);
    });

    test('routes incoming message (fromMe=false) to incoming handler',
        () async {
      await handler.processEvent({
        'event': 'messages.upsert',
        'data': {
          'key': {'id': 'ext-incoming', 'fromMe': false},
          'cleanedSenderPn': '966501234567',
          'messageBody': 'Hello',
        },
      });

      // Incoming messages don't update the DB currently, just log
      verifyNever(() => mockDao.markAsSent(any(), any()));
    });
  });

  // ═══════════════════════════════════════════════════════
  // processEvent - timestamp rejection
  // ═══════════════════════════════════════════════════════

  group('processEvent - timestamp validation', () {
    test('rejects event with old timestamp', () async {
      final oldTimestamp =
          DateTime.now().subtract(const Duration(minutes: 10));
      final ts = oldTimestamp.millisecondsSinceEpoch ~/ 1000;

      await handler.processEvent({
        'event': 'message.sent',
        'timestamp': ts,
        'data': {
          'key': {'id': 'ext-old'},
        },
      });

      verifyNever(() => mockDao.findByExternalMsgId(any()));
    });

    test('processes event with valid timestamp', () async {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      await handler.processEvent({
        'event': 'message.sent',
        'timestamp': now,
        'data': {
          'key': {'id': 'ext-valid'},
        },
      });

      verify(() => mockDao.findByExternalMsgId('ext-valid')).called(1);
    });

    test('processes event without timestamp (no rejection)', () async {
      await handler.processEvent({
        'event': 'message.sent',
        'data': {
          'key': {'id': 'ext-no-ts'},
        },
      });

      verify(() => mockDao.findByExternalMsgId('ext-no-ts')).called(1);
    });
  });

  // ═══════════════════════════════════════════════════════
  // processEvent - unknown event type
  // ═══════════════════════════════════════════════════════

  group('processEvent - unknown events', () {
    test('handles unknown event type gracefully', () async {
      await handler.processEvent({
        'event': 'unknown.event',
        'data': <String, dynamic>{},
      });

      verifyNever(() => mockDao.findByExternalMsgId(any()));
      verifyNever(() => mockDao.markAsSent(any(), any()));
    });
  });
}
