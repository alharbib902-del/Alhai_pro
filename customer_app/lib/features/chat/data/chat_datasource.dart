import 'package:supabase_flutter/supabase_flutter.dart';

/// Datasource for customer-side chat.
class CustomerChatDatasource {
  final SupabaseClient _client;

  CustomerChatDatasource(this._client);

  String get _userId => _client.auth.currentUser!.id;

  /// Stream chat messages for an order.
  Stream<List<Map<String, dynamic>>> streamMessages(String orderId) {
    return _client
        .from('chat_messages')
        .stream(primaryKey: ['id'])
        .eq('order_id', orderId)
        .order('created_at', ascending: true);
  }

  /// Send a message as customer.
  Future<void> sendMessage({
    required String orderId,
    required String text,
  }) async {
    try {
      await _client.from('chat_messages').insert({
        'order_id': orderId,
        'sender_type': 'customer',
        'sender_id': _userId,
        'text': text,
        'language': 'ar',
      });
    } catch (e) {
      throw Exception('فشل إرسال الرسالة');
    }
  }

  /// Mark messages as read.
  Future<void> markAsRead(String orderId) async {
    try {
      await _client
          .from('chat_messages')
          .update({'is_read': true})
          .eq('order_id', orderId)
          .neq('sender_id', _userId)
          .eq('is_read', false);
    } catch (_) {
      // Best-effort — don't block UI for read receipts
    }
  }
}
