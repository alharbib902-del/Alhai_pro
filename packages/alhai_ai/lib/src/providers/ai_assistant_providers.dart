/// مزودات المساعد الذكي - AI Assistant Providers
///
/// توفر حالة المحادثة مع المساعد الذكي
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import 'package:alhai_database/alhai_database.dart';
import '../services/ai_api_service.dart';
import '../services/ai_assistant_service.dart';
import 'package:alhai_auth/alhai_auth.dart';

// ============================================================================
// SERVICE PROVIDER
// ============================================================================

/// مزود خدمة المساعد الذكي
final aiAssistantServiceProvider = Provider<AiAssistantService>((ref) {
  return AiAssistantService(GetIt.instance<AppDatabase>());
});

// ============================================================================
// CHAT STATE
// ============================================================================

/// مدير حالة رسائل المحادثة
class ChatMessagesNotifier extends StateNotifier<List<ChatMessage>> {
  final AiAssistantService _service;
  final Ref _ref;

  ChatMessagesNotifier(this._service, this._ref)
    : super([
        ChatMessage(
          id: 'welcome_${DateTime.now().millisecondsSinceEpoch}',
          role: ChatRole.assistant,
          content: '''
مرحباً! أنا مساعدك الذكي لإدارة المتجر.

يمكنني مساعدتك في معرفة المبيعات، حالة المخزون، ديون العملاء، والمزيد.

جرب أحد الأسئلة السريعة أدناه أو اكتب سؤالك!''',
          // Welcome message
          timestamp: DateTime.now(),
          suggestedActions: const [
            SuggestedAction(label: 'مبيعات اليوم', icon: null),
            SuggestedAction(label: 'حالة المخزون', icon: null),
          ],
        ),
      ]);

  /// إرسال رسالة من المستخدم
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      role: ChatRole.user,
      content: text.trim(),
      timestamp: DateTime.now(),
    );

    // إضافة رسالة المستخدم
    state = [...state, userMsg];

    // تعيين حالة المعالجة
    _ref.read(isProcessingProvider.notifier).state = true;

    try {
      final storeId = _ref.read(currentStoreIdProvider)!;
      final response = await _service.processQuery(text.trim(), storeId);

      final assistantMsg = ChatMessage(
        id: 'assistant_${DateTime.now().millisecondsSinceEpoch}',
        role: ChatRole.assistant,
        content: response.text,
        timestamp: DateTime.now(),
        data: response.data,
        suggestedActions: response.suggestedActions,
      );

      state = [...state, assistantMsg];
    } catch (e) {
      final errorMsg = ChatMessage(
        id: 'error_${DateTime.now().millisecondsSinceEpoch}',
        role: ChatRole.assistant,
        content: 'عذراً، حدث خطأ. يرجى المحاولة مرة أخرى.',
        // Sorry, an error occurred
        timestamp: DateTime.now(),
      );
      state = [...state, errorMsg];
    } finally {
      _ref.read(isProcessingProvider.notifier).state = false;
    }
  }

  /// مسح المحادثة
  void clearChat() {
    state = [
      ChatMessage(
        id: 'welcome_${DateTime.now().millisecondsSinceEpoch}',
        role: ChatRole.assistant,
        content: 'تم مسح المحادثة. كيف يمكنني مساعدتك؟',
        // Chat cleared. How can I help?
        timestamp: DateTime.now(),
      ),
    ];
  }
}

/// مزود رسائل المحادثة
final chatMessagesProvider =
    StateNotifierProvider<ChatMessagesNotifier, List<ChatMessage>>((ref) {
      final service = ref.read(aiAssistantServiceProvider);
      return ChatMessagesNotifier(service, ref);
    });

/// مزود حالة المعالجة
final isProcessingProvider = StateProvider<bool>((ref) => false);

/// مزود القوالب السريعة
final quickTemplatesProvider = Provider<List<QuickTemplate>>((ref) {
  final service = ref.read(aiAssistantServiceProvider);
  return service.getQuickTemplates();
});

// ============================================================================
// REMOTE API PROVIDER - مزود API البعيد
// ============================================================================

/// مزود المساعد الذكي عبر خادم AI
final assistantApiProvider =
    Provider<Future<Map<String, dynamic>> Function(String)>((ref) {
      final api = ref.read(aiApiServiceProvider);
      final storeId = ref.read(currentStoreIdProvider)!;
      return (String query) =>
          api.askAssistant(orgId: 'default', storeId: storeId, query: query);
    });
