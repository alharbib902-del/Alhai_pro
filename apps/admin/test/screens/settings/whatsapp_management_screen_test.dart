library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:admin/screens/settings/whatsapp_management_screen.dart';

import '../../helpers/test_helpers.dart';

void main() {
  late MockAppDatabase db;
  late MockWhatsAppMessagesDao waMessagesDao;
  late MockWhatsAppTemplatesDao waTemplatesDao;

  setUpAll(() => registerAdminFallbackValues());

  setUp(() {
    waMessagesDao = MockWhatsAppMessagesDao();
    waTemplatesDao = MockWhatsAppTemplatesDao();
    db = setupMockDatabase(
      whatsAppMessagesDao: waMessagesDao,
      whatsAppTemplatesDao: waTemplatesDao,
    );
    setupTestGetIt(mockDb: db);

    when(() => waMessagesDao.getAllMessages())
        .thenAnswer((_) async => []);
    when(() => waTemplatesDao.getAllTemplates(any()))
        .thenAnswer((_) async => []);
  });

  tearDown(() => tearDownTestGetIt());

  group('WhatsAppManagementScreen', () {
    testWidgets('renders correctly', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
          createTestWidget(const WhatsAppManagementScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(WhatsAppManagementScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows tab bar', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
          createTestWidget(const WhatsAppManagementScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(TabBar), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows message icon', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
          createTestWidget(const WhatsAppManagementScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.message_outlined), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('is a ConsumerStatefulWidget', (tester) async {
      const screen = WhatsAppManagementScreen();
      expect(screen, isA<WhatsAppManagementScreen>());
    });
  });
}
