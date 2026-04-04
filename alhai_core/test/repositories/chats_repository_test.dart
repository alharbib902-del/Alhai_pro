import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_core/src/repositories/chats_repository.dart';

/// Tests for StoreConversation, StoreChatMessage, StoreChatSenderType,
/// StoreChatMessageType defined in chats_repository.dart.
/// ChatsRepository is an abstract interface - no implementation to test yet.
void main() {
  group('StoreConversation', () {
    test('should construct with all required fields', () {
      final conversation = StoreConversation(
        id: 'conv-1',
        storeId: 'store-1',
        customerId: 'customer-1',
        customerName: 'Ahmed',
        orderId: 'order-1',
        unreadCount: 3,
        createdAt: DateTime(2026, 1, 15),
      );

      expect(conversation.id, equals('conv-1'));
      expect(conversation.storeId, equals('store-1'));
      expect(conversation.customerId, equals('customer-1'));
      expect(conversation.customerName, equals('Ahmed'));
      expect(conversation.orderId, equals('order-1'));
      expect(conversation.unreadCount, equals(3));
      expect(conversation.isArchived, isFalse);
    });

    test('should default unread count to 0 and isArchived to false', () {
      final conversation = StoreConversation(
        id: 'conv-1',
        storeId: 'store-1',
        customerId: 'customer-1',
        createdAt: DateTime(2026, 1, 15),
      );

      expect(conversation.unreadCount, equals(0));
      expect(conversation.isArchived, isFalse);
      expect(conversation.lastMessage, isNull);
      expect(conversation.lastMessageAt, isNull);
    });

    test('should include last message when available', () {
      final lastMsg = StoreChatMessage(
        id: 'msg-1',
        conversationId: 'conv-1',
        senderId: 'customer-1',
        senderType: StoreChatSenderType.customer,
        content: 'Hello',
        createdAt: DateTime(2026, 1, 15),
      );

      final conversation = StoreConversation(
        id: 'conv-1',
        storeId: 'store-1',
        customerId: 'customer-1',
        lastMessage: lastMsg,
        lastMessageAt: DateTime(2026, 1, 15),
        createdAt: DateTime(2026, 1, 15),
      );

      expect(conversation.lastMessage, isNotNull);
      expect(conversation.lastMessage!.content, equals('Hello'));
    });
  });

  group('StoreChatMessage', () {
    test('should construct text message', () {
      final message = StoreChatMessage(
        id: 'msg-1',
        conversationId: 'conv-1',
        senderId: 'store-1',
        senderType: StoreChatSenderType.store,
        content: 'Your order is ready',
        createdAt: DateTime(2026, 1, 15),
      );

      expect(message.id, equals('msg-1'));
      expect(message.senderType, equals(StoreChatSenderType.store));
      expect(message.content, equals('Your order is ready'));
      expect(message.type, equals(StoreChatMessageType.text));
      expect(message.isRead, isFalse);
      expect(message.attachmentUrl, isNull);
    });

    test('should construct image message', () {
      final message = StoreChatMessage(
        id: 'msg-2',
        conversationId: 'conv-1',
        senderId: 'customer-1',
        senderType: StoreChatSenderType.customer,
        content: 'Product photo',
        type: StoreChatMessageType.image,
        attachmentUrl: 'https://example.com/image.jpg',
        createdAt: DateTime(2026, 1, 15),
      );

      expect(message.type, equals(StoreChatMessageType.image));
      expect(message.attachmentUrl, isNotNull);
    });

    test('should support all message types', () {
      for (final type in StoreChatMessageType.values) {
        final message = StoreChatMessage(
          id: 'msg-${type.name}',
          conversationId: 'conv-1',
          senderId: 'user-1',
          senderType: StoreChatSenderType.store,
          content: 'Test ${type.name}',
          type: type,
          createdAt: DateTime(2026, 1, 15),
        );
        expect(message.type, equals(type));
      }
    });
  });

  group('StoreChatSenderType', () {
    test('should have store and customer values', () {
      expect(StoreChatSenderType.values, hasLength(2));
      expect(StoreChatSenderType.values, contains(StoreChatSenderType.store));
      expect(
          StoreChatSenderType.values, contains(StoreChatSenderType.customer));
    });
  });

  group('StoreChatMessageType', () {
    test('should have all expected values', () {
      expect(StoreChatMessageType.values, hasLength(5));
      expect(StoreChatMessageType.values, contains(StoreChatMessageType.text));
      expect(StoreChatMessageType.values, contains(StoreChatMessageType.image));
      expect(StoreChatMessageType.values, contains(StoreChatMessageType.voice));
      expect(StoreChatMessageType.values, contains(StoreChatMessageType.order));
      expect(
          StoreChatMessageType.values, contains(StoreChatMessageType.location));
    });
  });
}
