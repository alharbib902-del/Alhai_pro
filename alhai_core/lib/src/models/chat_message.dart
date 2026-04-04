import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message.freezed.dart';
part 'chat_message.g.dart';

/// Chat Message model (v3.4)
@freezed
class ChatMessage with _$ChatMessage {
  const ChatMessage._();

  const factory ChatMessage({
    required String id,
    required String orderId,
    required String sender, // 'customer' | 'driver' | 'system'
    required String text,
    String? textTranslated, // Translated version
    String? imageUrl,
    String? language, // 'ar', 'en', 'ur', 'hi', 'bn', 'id'
    @Default(false) bool isRead,
    @Default(false) bool isSystem, // System messages (order updates)
    required DateTime timestamp,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);

  /// Check if message is from customer
  bool get isFromCustomer => sender == 'customer';

  /// Check if message is from driver
  bool get isFromDriver => sender == 'driver';

  /// Get display text (translated if available)
  String get displayText => textTranslated ?? text;
}

/// Chat Conversation summary
@freezed
class ChatConversation with _$ChatConversation {
  const ChatConversation._();

  const factory ChatConversation({
    required String orderId,
    required String orderNumber,
    required String driverId,
    required String driverName,
    String? driverPhoto,
    ChatMessage? lastMessage,
    @Default(0) int unreadCount,
    required DateTime lastActivityAt,
  }) = _ChatConversation;

  factory ChatConversation.fromJson(Map<String, dynamic> json) =>
      _$ChatConversationFromJson(json);

  /// Check if has unread messages
  bool get hasUnread => unreadCount > 0;
}
