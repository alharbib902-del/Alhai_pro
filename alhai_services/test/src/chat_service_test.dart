import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:alhai_services/alhai_services.dart';

// ---------------------------------------------------------------------------
// Fake
// ---------------------------------------------------------------------------
class FakeChatsRepository implements ChatsRepository {
  final List<StoreConversation> _conversations = [];
  final List<StoreChatMessage> _messages = [];

  @override
  Future<Paginated<StoreConversation>> getStoreConversations(
    String storeId, {
    int page = 1,
    int limit = 20,
    bool? unreadOnly,
  }) async {
    final filtered = _conversations.where((c) => c.storeId == storeId).toList();
    return Paginated(
      items: filtered.take(limit).toList(),
      total: filtered.length,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<List<StoreConversation>> getCustomerConversations(
      String customerId) async {
    return _conversations.where((c) => c.customerId == customerId).toList();
  }

  @override
  Future<StoreConversation> getConversation(String id) async {
    return _conversations.firstWhere((c) => c.id == id);
  }

  @override
  Future<StoreConversation> getOrCreateConversation({
    required String storeId,
    required String customerId,
    String? orderId,
  }) async {
    final existing = _conversations.where(
      (c) => c.storeId == storeId && c.customerId == customerId,
    );
    if (existing.isNotEmpty) return existing.first;

    final conv = StoreConversation(
      id: 'conv-${_conversations.length + 1}',
      storeId: storeId,
      customerId: customerId,
      orderId: orderId,
      createdAt: DateTime.now(),
    );
    _conversations.add(conv);
    return conv;
  }

  @override
  Future<Paginated<StoreChatMessage>> getMessages(
    String conversationId, {
    int page = 1,
    int limit = 50,
  }) async {
    final filtered =
        _messages.where((m) => m.conversationId == conversationId).toList();
    return Paginated(
      items: filtered.take(limit).toList(),
      total: filtered.length,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<StoreChatMessage> sendMessage({
    required String conversationId,
    required String senderId,
    required StoreChatSenderType senderType,
    required String content,
    StoreChatMessageType type = StoreChatMessageType.text,
    String? attachmentUrl,
  }) async {
    final msg = StoreChatMessage(
      id: 'msg-${_messages.length + 1}',
      conversationId: conversationId,
      senderId: senderId,
      senderType: senderType,
      content: content,
      type: type,
      createdAt: DateTime.now(),
    );
    _messages.add(msg);
    return msg;
  }

  @override
  Future<void> markAsRead(String conversationId, String readBy) async {}

  @override
  Future<int> getUnreadCount(String storeId) async {
    return 3;
  }

  @override
  Future<void> archiveConversation(String conversationId) async {
    _conversations.removeWhere((c) => c.id == conversationId);
  }
}

void main() {
  late ChatService chatService;
  late FakeChatsRepository fakeRepo;

  setUp(() {
    fakeRepo = FakeChatsRepository();
    chatService = ChatService(fakeRepo);
  });

  group('ChatService', () {
    test('should be created', () {
      expect(chatService, isNotNull);
    });

    group('conversations', () {
      test('should create or get conversation', () async {
        final conv = await chatService.getOrCreateConversation(
          storeId: 'store-1',
          customerId: 'cust-1',
        );

        expect(conv.id, isNotEmpty);
        expect(conv.storeId, equals('store-1'));
        expect(conv.customerId, equals('cust-1'));
      });

      test('should return same conversation for same pair', () async {
        final conv1 = await chatService.getOrCreateConversation(
          storeId: 'store-1',
          customerId: 'cust-1',
        );
        final conv2 = await chatService.getOrCreateConversation(
          storeId: 'store-1',
          customerId: 'cust-1',
        );

        expect(conv1.id, equals(conv2.id));
      });

      test('should get store conversations', () async {
        await chatService.getOrCreateConversation(
          storeId: 'store-1',
          customerId: 'cust-1',
        );

        final result = await chatService.getStoreConversations('store-1');
        expect(result.items, hasLength(1));
      });

      test('should get customer conversations', () async {
        await chatService.getOrCreateConversation(
          storeId: 'store-1',
          customerId: 'cust-1',
        );

        final convs = await chatService.getCustomerConversations('cust-1');
        expect(convs, hasLength(1));
      });
    });

    group('messages', () {
      test('should send message', () async {
        final conv = await chatService.getOrCreateConversation(
          storeId: 'store-1',
          customerId: 'cust-1',
        );

        final msg = await chatService.sendMessage(
          conversationId: conv.id,
          senderId: 'cust-1',
          senderType: StoreChatSenderType.customer,
          content: 'Hello!',
        );

        expect(msg.content, equals('Hello!'));
        expect(msg.senderType, equals(StoreChatSenderType.customer));
      });

      test('should get messages for conversation', () async {
        final conv = await chatService.getOrCreateConversation(
          storeId: 'store-1',
          customerId: 'cust-1',
        );

        await chatService.sendMessage(
          conversationId: conv.id,
          senderId: 'cust-1',
          senderType: StoreChatSenderType.customer,
          content: 'Message 1',
        );
        await chatService.sendMessage(
          conversationId: conv.id,
          senderId: 'store-1',
          senderType: StoreChatSenderType.store,
          content: 'Reply 1',
        );

        final result = await chatService.getMessages(conv.id);
        expect(result.items, hasLength(2));
      });
    });

    group('unread count', () {
      test('should return unread count', () async {
        final count = await chatService.getUnreadCount('store-1');
        expect(count, equals(3));
      });
    });

    group('archive', () {
      test('should archive conversation', () async {
        final conv = await chatService.getOrCreateConversation(
          storeId: 'store-1',
          customerId: 'cust-1',
        );

        await chatService.archiveConversation(conv.id);

        final result = await chatService.getStoreConversations('store-1');
        expect(result.items, isEmpty);
      });
    });
  });
}
