import 'package:supabase_flutter/supabase_flutter.dart';

/// Datasource for per-order chat messages.
class ChatDatasource {
  final SupabaseClient _client;

  ChatDatasource(this._client);

  String get _userId {
    final user = _client.auth.currentUser;
    if (user == null) throw StateError('المستخدم غير مسجّل الدخول');
    return user.id;
  }

  /// Stream chat messages for an order (Realtime).
  Stream<List<Map<String, dynamic>>> streamMessages(String orderId) {
    return _client
        .from('chat_messages')
        .stream(primaryKey: ['id'])
        .eq('order_id', orderId)
        .order('created_at', ascending: true);
  }

  /// Send a text message.
  Future<void> sendMessage({
    required String orderId,
    required String text,
    String? deliveryId,
  }) async {
    final sanitized = text.trim()
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;');
    if (sanitized.isEmpty) return;
    await _client.from('chat_messages').insert({
      'order_id': orderId,
      'delivery_id': deliveryId,
      'sender_type': 'driver',
      'sender_id': _userId,
      'text': sanitized,
      'language': 'ar',
    });
  }

  /// Mark messages as read.
  Future<void> markAsRead(String orderId) async {
    await _client
        .from('chat_messages')
        .update({'is_read': true})
        .eq('order_id', orderId)
        .neq('sender_id', _userId)
        .eq('is_read', false);
  }

  /// Get unread message count for an order.
  Future<int> getUnreadCount(String orderId) async {
    final result = await _client
        .from('chat_messages')
        .select('id')
        .eq('order_id', orderId)
        .neq('sender_id', _userId)
        .eq('is_read', false);
    return (result as List).length;
  }
}
