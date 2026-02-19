/// مزودات المحادثة مع البيانات بالذكاء الاصطناعي
///
/// Riverpod providers لإدارة حالة شاشة المحادثة مع البيانات
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ai_api_service.dart';
import '../services/ai_chat_with_data_service.dart';
import 'products_providers.dart';

// ============================================================================
// SERVICE PROVIDER
// ============================================================================

/// مزود خدمة المحادثة مع البيانات
final aiChatWithDataServiceProvider = Provider<AiChatWithDataService>((ref) {
  return AiChatWithDataService();
});

// ============================================================================
// STATE PROVIDERS
// ============================================================================

/// مزود نتيجة الاستعلام الحالية
final currentQueryResultProvider = StateProvider<QueryResult?>((ref) => null);

/// مزود حالة التحميل
final isQueryLoadingProvider = StateProvider<bool>((ref) => false);

/// مزود سجل الاستعلامات
final queryHistoryProvider = StateProvider<List<QueryResult>>((ref) => []);

/// مزود الاستعلامات المقترحة
final suggestedQueriesProvider = Provider<List<String>>((ref) {
  final service = ref.watch(aiChatWithDataServiceProvider);
  return service.getSuggestedQueries();
});

/// مزود نص الاستعلام الحالي
final queryTextProvider = StateProvider<String>((ref) => '');

// ============================================================================
// ACTION PROVIDERS
// ============================================================================

/// مزود تنفيذ استعلام
final executeQueryActionProvider = Provider<Future<QueryResult> Function(String)>((ref) {
  return (String query) async {
    final service = ref.read(aiChatWithDataServiceProvider);
    ref.read(isQueryLoadingProvider.notifier).state = true;

    try {
      final result = await service.executeQuery(query, 'store_demo_001');
      ref.read(currentQueryResultProvider.notifier).state = result;

      // تحديث السجل
      final history = List<QueryResult>.from(ref.read(queryHistoryProvider));
      history.insert(0, result);
      if (history.length > 50) history.removeLast();
      ref.read(queryHistoryProvider.notifier).state = history;

      return result;
    } finally {
      ref.read(isQueryLoadingProvider.notifier).state = false;
    }
  };
});

/// مزود مسح السجل
final clearHistoryActionProvider = Provider<void Function()>((ref) {
  return () {
    final service = ref.read(aiChatWithDataServiceProvider);
    service.clearHistory();
    ref.read(queryHistoryProvider.notifier).state = [];
    ref.read(currentQueryResultProvider.notifier).state = null;
  };
});

// ============================================================================
// REMOTE API PROVIDER - مزود API البعيد
// ============================================================================

/// مزود الدردشة مع البيانات عبر خادم AI
final chatApiProvider = Provider<Future<Map<String, dynamic>> Function(String)>((ref) {
  final api = ref.read(aiApiServiceProvider);
  final storeId = ref.read(currentStoreIdProvider) ?? 'store_demo_001';
  return (String message) => api.chatWithData(
        orgId: 'default',
        storeId: storeId,
        message: message,
      );
});
