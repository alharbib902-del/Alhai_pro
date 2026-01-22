import '../models/paginated.dart';

/// Repository contract for store-customer chat operations (v2.7.0)
/// Real-time chat between store and customers
abstract class ChatsRepository {
  /// Gets conversations for a store
  Future<Paginated<StoreConversation>> getStoreConversations(
    String storeId, {
    int page = 1,
    int limit = 20,
    bool? unreadOnly,
  });

  /// Gets conversations for a customer
  Future<List<StoreConversation>> getCustomerConversations(String customerId);

  /// Gets a conversation by ID
  Future<StoreConversation> getConversation(String id);

  /// Gets or creates a conversation
  Future<StoreConversation> getOrCreateConversation({
    required String storeId,
    required String customerId,
    String? orderId,
  });

  /// Gets messages for a conversation
  Future<Paginated<StoreChatMessage>> getMessages(
    String conversationId, {
    int page = 1,
    int limit = 50,
  });

  /// Sends a message
  Future<StoreChatMessage> sendMessage({
    required String conversationId,
    required String senderId,
    required StoreChatSenderType senderType,
    required String content,
    StoreChatMessageType type = StoreChatMessageType.text,
    String? attachmentUrl,
  });

  /// Marks messages as read
  Future<void> markAsRead(String conversationId, String readBy);

  /// Gets unread count
  Future<int> getUnreadCount(String storeId);

  /// Archives a conversation
  Future<void> archiveConversation(String conversationId);
}

/// Store conversation model (renamed to avoid conflict with ChatConversation)
class StoreConversation {
  final String id;
  final String storeId;
  final String customerId;
  final String? customerName;
  final String? orderId;
  final StoreChatMessage? lastMessage;
  final int unreadCount;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime? lastMessageAt;

  const StoreConversation({
    required this.id,
    required this.storeId,
    required this.customerId,
    this.customerName,
    this.orderId,
    this.lastMessage,
    this.unreadCount = 0,
    this.isArchived = false,
    required this.createdAt,
    this.lastMessageAt,
  });
}

/// Store chat message model (renamed to avoid conflict with ChatMessage)
class StoreChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final StoreChatSenderType senderType;
  final String content;
  final StoreChatMessageType type;
  final String? attachmentUrl;
  final bool isRead;
  final DateTime createdAt;

  const StoreChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderType,
    required this.content,
    this.type = StoreChatMessageType.text,
    this.attachmentUrl,
    this.isRead = false,
    required this.createdAt,
  });
}

/// Sender type for store chat
enum StoreChatSenderType { store, customer }

/// Message type for store chat
enum StoreChatMessageType { text, image, voice, order, location }
