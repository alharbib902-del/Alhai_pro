import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../data/chat_datasource.dart';

/// Stream of chat messages for a specific order.
final customerChatMessagesProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>(
        (ref, orderId) {
  final ds = GetIt.instance<CustomerChatDatasource>();
  return ds.streamMessages(orderId);
});
