import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:alhai_ai/src/services/ai_assistant_service.dart';
import 'package:alhai_ai/src/providers/ai_assistant_providers.dart';

class MockAiAssistantService extends Mock implements AiAssistantService {}

void main() {
  group('ChatMessagesNotifier', () {
    late MockAiAssistantService mockService;
    late ProviderContainer container;

    setUp(() {
      mockService = MockAiAssistantService();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state has welcome message', () {
      container = ProviderContainer(
        overrides: [
          aiAssistantServiceProvider.overrideWithValue(mockService),
        ],
      );

      final messages = container.read(chatMessagesProvider);
      expect(messages, isNotEmpty);
      expect(messages.first.role, ChatRole.assistant);
    });

    test('initial state has suggested actions', () {
      container = ProviderContainer(
        overrides: [
          aiAssistantServiceProvider.overrideWithValue(mockService),
        ],
      );

      final messages = container.read(chatMessagesProvider);
      expect(messages.first.suggestedActions, isNotNull);
      expect(messages.first.suggestedActions, isNotEmpty);
    });

    test('isProcessingProvider initial state is false', () {
      container = ProviderContainer(
        overrides: [
          aiAssistantServiceProvider.overrideWithValue(mockService),
        ],
      );

      expect(container.read(isProcessingProvider), isFalse);
    });

    test('clearChat resets to single welcome message', () {
      container = ProviderContainer(
        overrides: [
          aiAssistantServiceProvider.overrideWithValue(mockService),
        ],
      );

      final notifier = container.read(chatMessagesProvider.notifier);
      notifier.clearChat();

      final messages = container.read(chatMessagesProvider);
      expect(messages.length, 1);
      expect(messages.first.role, ChatRole.assistant);
    });
  });

  group('quickTemplatesProvider', () {
    test('returns templates from service', () {
      final mockService = MockAiAssistantService();
      when(() => mockService.getQuickTemplates()).thenReturn([
        const QuickTemplate(
          id: 'q1',
          icon: Icons.shopping_cart,
          titleAr: 'مبيعات اليوم',
          titleEn: 'Today Sales',
          query: 'مبيعات اليوم',
        ),
      ]);

      final container = ProviderContainer(
        overrides: [
          aiAssistantServiceProvider.overrideWithValue(mockService),
        ],
      );
      addTearDown(container.dispose);

      final templates = container.read(quickTemplatesProvider);
      expect(templates, isNotEmpty);
      expect(templates.length, 1);
      expect(templates.first.query, 'مبيعات اليوم');
    });
  });

  group('ChatMessage model', () {
    test('creates with required fields', () {
      final msg = ChatMessage(
        id: 'test-1',
        role: ChatRole.user,
        content: 'Hello',
        timestamp: DateTime.now(),
      );

      expect(msg.id, 'test-1');
      expect(msg.role, ChatRole.user);
      expect(msg.content, 'Hello');
    });

    test('copyWith updates content', () {
      final msg = ChatMessage(
        id: 'test-1',
        role: ChatRole.user,
        content: 'Hello',
        timestamp: DateTime.now(),
      );

      final updated = msg.copyWith(content: 'Updated');
      expect(updated.content, 'Updated');
      expect(updated.id, 'test-1');
      expect(updated.role, ChatRole.user);
    });
  });

  group('ChatRole', () {
    test('has user and assistant values', () {
      expect(ChatRole.values, contains(ChatRole.user));
      expect(ChatRole.values, contains(ChatRole.assistant));
    });
  });
}
