library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cashier/screens/settings/account/keyboard_shortcuts_screen.dart';

import '../../helpers/test_helpers.dart';
import '../../helpers/mock_database.dart';

void main() {
  setUpAll(() => registerCashierFallbackValues());

  setUp(() {
    // KeyboardShortcutsScreen has no DB access - it's a static reference screen.
    final db = setupMockDatabase();
    setupTestGetIt(mockDb: db);
  });

  tearDown(() => tearDownTestGetIt());

  group('KeyboardShortcutsScreen', () {
    testWidgets('renders the shortcuts reference', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        createTestWidget(const KeyboardShortcutsScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(KeyboardShortcutsScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('renders in dark mode', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        createTestWidget(
          const KeyboardShortcutsScreen(),
          theme: ThemeData.dark(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(KeyboardShortcutsScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('renders on mobile viewport', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        createTestWidget(const KeyboardShortcutsScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(KeyboardShortcutsScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('renders on tablet viewport', (tester) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        createTestWidget(const KeyboardShortcutsScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(KeyboardShortcutsScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows category filter chips', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        createTestWidget(const KeyboardShortcutsScreen()),
      );
      await tester.pumpAndSettle();

      // Keyboard shortcuts screen has category filter chips
      // rendered as custom GestureDetector containers
      expect(find.byType(GestureDetector), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
