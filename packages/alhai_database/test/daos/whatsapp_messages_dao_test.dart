import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:alhai_database/alhai_database.dart';
import '../helpers/database_test_helpers.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = createTestDatabase();
  });

  tearDown(() async {
    await db.close();
  });

  WhatsAppMessagesTableCompanion _makeMessage({
    String id = 'wa-1',
    String storeId = 'store-1',
    String phone = '966501234567',
    String messageType = 'text',
    String? textContent = 'مرحبا، هذا إيصالك',
    String status = 'pending',
    String? referenceType,
    String? referenceId,
    String? batchId,
    int priority = 2,
    DateTime? createdAt,
  }) {
    return WhatsAppMessagesTableCompanion.insert(
      id: id,
      storeId: storeId,
      phone: phone,
      messageType: messageType,
      textContent: Value(textContent),
      status: Value(status),
      referenceType: Value(referenceType),
      referenceId: Value(referenceId),
      batchId: Value(batchId),
      priority: Value(priority),
      createdAt: createdAt ?? DateTime(2025, 6, 15, 10, 0),
    );
  }

  group('WhatsAppMessagesDao', () {
    test('enqueue and getPendingMessages', () async {
      await db.whatsAppMessagesDao.enqueue(_makeMessage());

      final pending = await db.whatsAppMessagesDao.getPendingMessages();
      expect(pending, hasLength(1));
      expect(pending.first.phone, '966501234567');
      expect(pending.first.messageType, 'text');
    });

    test('getPendingCount returns correct count', () async {
      await db.whatsAppMessagesDao.enqueue(_makeMessage(id: 'wa-1'));
      await db.whatsAppMessagesDao
          .enqueue(_makeMessage(id: 'wa-2', phone: '966509876543'));

      final count = await db.whatsAppMessagesDao.getPendingCount();
      expect(count, 2);
    });

    test('markAsSending updates status', () async {
      await db.whatsAppMessagesDao.enqueue(_makeMessage());

      await db.whatsAppMessagesDao.markAsSending('wa-1');

      final messages = await db.whatsAppMessagesDao.getAllMessages();
      expect(messages.first.status, 'sending');
    });

    test('markAsSent sets status and externalMsgId', () async {
      await db.whatsAppMessagesDao.enqueue(_makeMessage());

      await db.whatsAppMessagesDao.markAsSent('wa-1', 'ext-msg-123');

      final messages = await db.whatsAppMessagesDao.getAllMessages();
      expect(messages.first.status, 'sent');
      expect(messages.first.externalMsgId, 'ext-msg-123');
      expect(messages.first.sentAt, isNotNull);
    });

    test('markAsDelivered updates status', () async {
      await db.whatsAppMessagesDao.enqueue(_makeMessage());
      await db.whatsAppMessagesDao.markAsSent('wa-1', 'ext-1');

      await db.whatsAppMessagesDao.markAsDelivered('wa-1');

      final messages = await db.whatsAppMessagesDao.getAllMessages();
      expect(messages.first.status, 'delivered');
      expect(messages.first.deliveredAt, isNotNull);
    });

    test('markAsRead updates status', () async {
      await db.whatsAppMessagesDao.enqueue(_makeMessage());

      await db.whatsAppMessagesDao.markAsRead('wa-1');

      final messages = await db.whatsAppMessagesDao.getAllMessages();
      expect(messages.first.status, 'read');
      expect(messages.first.readAt, isNotNull);
    });

    test('markAsFailed increments retryCount', () async {
      await db.whatsAppMessagesDao.enqueue(_makeMessage());

      await db.whatsAppMessagesDao.markAsFailed('wa-1', 'فشل الإرسال');

      final messages = await db.whatsAppMessagesDao.getAllMessages();
      expect(messages.first.status, 'failed');
      expect(messages.first.retryCount, 1);
      expect(messages.first.lastError, 'فشل الإرسال');
    });

    test('findByExternalMsgId finds message', () async {
      await db.whatsAppMessagesDao.enqueue(_makeMessage());
      await db.whatsAppMessagesDao.markAsSent('wa-1', 'ext-abc-123');

      final msg = await db.whatsAppMessagesDao
          .findByExternalMsgId('ext-abc-123');
      expect(msg, isNotNull);
      expect(msg!.id, 'wa-1');
    });

    test('getByCustomer returns messages for customer', () async {
      await db.whatsAppMessagesDao.enqueue(
        WhatsAppMessagesTableCompanion.insert(
          id: 'wa-1',
          storeId: 'store-1',
          phone: '966501234567',
          messageType: 'text',
          customerId: const Value('cust-1'),
          createdAt: DateTime(2025, 6, 15),
        ),
      );

      final messages =
          await db.whatsAppMessagesDao.getByCustomer('cust-1');
      expect(messages, hasLength(1));
    });

    test('getByReference returns messages by reference', () async {
      await db.whatsAppMessagesDao.enqueue(_makeMessage(
        id: 'wa-1',
        referenceType: 'sale',
        referenceId: 'sale-1',
      ));

      final messages =
          await db.whatsAppMessagesDao.getByReference('sale', 'sale-1');
      expect(messages, hasLength(1));
    });

    test('getByBatchId returns batch messages', () async {
      await db.whatsAppMessagesDao
          .enqueue(_makeMessage(id: 'wa-1', batchId: 'batch-1'));
      await db.whatsAppMessagesDao
          .enqueue(_makeMessage(id: 'wa-2', batchId: 'batch-1', phone: '966509999999'));
      await db.whatsAppMessagesDao
          .enqueue(_makeMessage(id: 'wa-3', batchId: 'batch-2', phone: '966508888888'));

      final batch =
          await db.whatsAppMessagesDao.getByBatchId('batch-1');
      expect(batch, hasLength(2));
    });

    test('retryMessage resets status and retryCount', () async {
      await db.whatsAppMessagesDao.enqueue(_makeMessage());
      await db.whatsAppMessagesDao.markAsFailed('wa-1', 'error');

      await db.whatsAppMessagesDao.retryMessage('wa-1');

      final messages = await db.whatsAppMessagesDao.getAllMessages();
      expect(messages.first.status, 'pending');
      expect(messages.first.retryCount, 0);
    });

    test('removeMessage deletes message', () async {
      await db.whatsAppMessagesDao.enqueue(_makeMessage());

      final deleted = await db.whatsAppMessagesDao.removeMessage('wa-1');
      expect(deleted, 1);

      final count = await db.whatsAppMessagesDao.getPendingCount();
      expect(count, 0);
    });

    test('updateMediaUrl sets media URL', () async {
      await db.whatsAppMessagesDao.enqueue(_makeMessage(
        messageType: 'image',
        textContent: null,
      ));

      await db.whatsAppMessagesDao
          .updateMediaUrl('wa-1', 'https://cdn.example.com/image.jpg');

      final messages = await db.whatsAppMessagesDao.getAllMessages();
      expect(messages.first.mediaUrl, 'https://cdn.example.com/image.jpg');
    });

    test('cancelBatch removes pending messages in batch', () async {
      await db.whatsAppMessagesDao.enqueue(_makeMessage(
        id: 'wa-1',
        batchId: 'batch-1',
        status: 'pending',
      ));
      await db.whatsAppMessagesDao.enqueue(_makeMessage(
        id: 'wa-2',
        phone: '966509999999',
        batchId: 'batch-1',
        status: 'sent',
      ));

      final deleted = await db.whatsAppMessagesDao.cancelBatch('batch-1');
      expect(deleted, 1); // only pending ones
    });

    test('getStatusCounts groups by status', () async {
      await db.whatsAppMessagesDao.enqueue(
          _makeMessage(id: 'wa-1', status: 'pending'));
      await db.whatsAppMessagesDao.enqueue(
          _makeMessage(id: 'wa-2', phone: '966502222222', status: 'pending'));
      await db.whatsAppMessagesDao.enqueue(
          _makeMessage(id: 'wa-3', phone: '966503333333', status: 'sent'));

      final counts = await db.whatsAppMessagesDao.getStatusCounts();
      expect(counts['pending'], 2);
      expect(counts['sent'], 1);
    });
  });
}
