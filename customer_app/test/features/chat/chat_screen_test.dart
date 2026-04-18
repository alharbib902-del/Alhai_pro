import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:customer_app/features/chat/domain/chat_repository.dart';
import 'package:customer_app/features/chat/presentation/chat_screen.dart';
import 'package:customer_app/features/chat/providers/chat_providers.dart';

class _FakeChatRepository implements ChatRepository {
  _FakeChatRepository();

  @override
  Stream<List<ChatMessage>> streamMessages(String orderId) async* {
    yield const <ChatMessage>[];
  }

  @override
  Future<void> sendMessage({
    required String orderId,
    required String text,
  }) async {}

  @override
  Future<void> markAsRead(String orderId) async {}
}

Widget _buildTestWidget(ChatRepository repo) {
  return ProviderScope(
    overrides: [chatRepositoryProvider.overrideWithValue(repo)],
    child: MaterialApp(
      theme: AlhaiTheme.light,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: ChatScreen(orderId: 'order-123'),
      ),
    ),
  );
}

void main() {
  group('ChatScreen', () {
    testWidgets('renders empty state when there are no messages',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget(_FakeChatRepository()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('ابدأ محادثتك'), findsOneWidget);
      expect(find.text('المحادثة'), findsOneWidget);
      expect(find.byIcon(Icons.send), findsOneWidget);
    });
  });
}
