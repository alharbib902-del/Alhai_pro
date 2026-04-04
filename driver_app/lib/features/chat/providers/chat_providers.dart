import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../data/chat_datasource.dart';

/// Stream of chat messages for a specific order.
final chatMessagesProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((ref, orderId) {
  final ds = GetIt.instance<ChatDatasource>();
  return ds.streamMessages(orderId);
});

/// Quick predefined messages for drivers.
const quickMessages = [
  'في الطريق إليك',
  '5 دقائق وأوصلك',
  'وصلت الموقع',
  'أنا عند الباب',
  'أرجو التواصل معي',
  'الرجاء إرسال الموقع بالتحديد',
  'لا أستطيع إيجاد العنوان',
];
