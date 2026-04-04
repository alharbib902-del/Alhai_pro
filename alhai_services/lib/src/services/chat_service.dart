import 'package:alhai_core/alhai_core.dart';

/// خدمة الدردشة بين المتجر والعميل
/// تستخدم من: customer_app, cashier
class ChatService {
  final ChatsRepository _chatsRepo;

  ChatService(this._chatsRepo);

  // ==================== المحادثات ====================

  /// محادثات المتجر
  Future<Paginated<StoreConversation>> getStoreConversations(
    String storeId, {
    int page = 1,
    int limit = 20,
    bool? unreadOnly,
  }) async {
    return await _chatsRepo.getStoreConversations(
      storeId,
      page: page,
      limit: limit,
      unreadOnly: unreadOnly,
    );
  }

  /// محادثات العميل
  Future<List<StoreConversation>> getCustomerConversations(
      String customerId) async {
    return await _chatsRepo.getCustomerConversations(customerId);
  }

  /// الحصول على محادثة
  Future<StoreConversation> getConversation(String id) async {
    return await _chatsRepo.getConversation(id);
  }

  /// الحصول على أو إنشاء محادثة
  Future<StoreConversation> getOrCreateConversation({
    required String storeId,
    required String customerId,
    String? orderId,
  }) async {
    return await _chatsRepo.getOrCreateConversation(
      storeId: storeId,
      customerId: customerId,
      orderId: orderId,
    );
  }

  // ==================== الرسائل ====================

  /// الحصول على رسائل المحادثة
  Future<Paginated<StoreChatMessage>> getMessages(
    String conversationId, {
    int page = 1,
    int limit = 50,
  }) async {
    return await _chatsRepo.getMessages(
      conversationId,
      page: page,
      limit: limit,
    );
  }

  /// إرسال رسالة
  Future<StoreChatMessage> sendMessage({
    required String conversationId,
    required String senderId,
    required StoreChatSenderType senderType,
    required String content,
    StoreChatMessageType type = StoreChatMessageType.text,
    String? attachmentUrl,
  }) async {
    return await _chatsRepo.sendMessage(
      conversationId: conversationId,
      senderId: senderId,
      senderType: senderType,
      content: content,
      type: type,
      attachmentUrl: attachmentUrl,
    );
  }

  /// تحديد الرسائل كمقروءة
  Future<void> markAsRead(String conversationId, String readBy) async {
    await _chatsRepo.markAsRead(conversationId, readBy);
  }

  /// عدد الرسائل غير المقروءة
  Future<int> getUnreadCount(String storeId) async {
    return await _chatsRepo.getUnreadCount(storeId);
  }

  /// أرشفة محادثة
  Future<void> archiveConversation(String conversationId) async {
    await _chatsRepo.archiveConversation(conversationId);
  }
}
