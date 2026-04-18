import '../data/chat_datasource.dart';

abstract class ChatRepository {
  Stream<List<ChatMessage>> streamMessages(String orderId);
  Future<void> sendMessage({required String orderId, required String text});
  Future<void> markAsRead(String orderId);
}

class ChatMessage {
  final String id;
  final String orderId;
  final String senderType;
  final String senderId;
  final String text;
  final bool isRead;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.orderId,
    required this.senderType,
    required this.senderId,
    required this.text,
    required this.isRead,
    required this.createdAt,
  });

  bool get isFromCustomer => senderType == 'customer';

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: (map['id'] ?? '').toString(),
      orderId: (map['order_id'] ?? '').toString(),
      senderType: (map['sender_type'] ?? '').toString(),
      senderId: (map['sender_id'] ?? '').toString(),
      text: (map['text'] ?? '').toString(),
      isRead: map['is_read'] == true,
      createdAt: DateTime.tryParse((map['created_at'] ?? '').toString()) ??
          DateTime.now(),
    );
  }
}

class ChatRepositoryImpl implements ChatRepository {
  final CustomerChatDatasource _datasource;

  ChatRepositoryImpl(this._datasource);

  @override
  Stream<List<ChatMessage>> streamMessages(String orderId) {
    return _datasource.streamMessages(orderId).map(
          (rows) => rows.map(ChatMessage.fromMap).toList(),
        );
  }

  @override
  Future<void> sendMessage({
    required String orderId,
    required String text,
  }) {
    return _datasource.sendMessage(orderId: orderId, text: text);
  }

  @override
  Future<void> markAsRead(String orderId) {
    return _datasource.markAsRead(orderId);
  }
}
