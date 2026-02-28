library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:admin/screens/settings/receipt_template_screen.dart';

import '../../helpers/test_helpers.dart';

void main() {
  late MockAppDatabase db;

  setUpAll(() => registerAdminFallbackValues());

  setUp(() {
    db = setupMockDatabase();
    setupTestGetIt(mockDb: db);
  });

  tearDown(() => tearDownTestGetIt());

  group('ReceiptTemplateScreen', () {
    testWidgets('renders correctly', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const ReceiptTemplateScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(ReceiptTemplateScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows receipt icon', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const ReceiptTemplateScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.receipt_long_rounded), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows switch list tiles for receipt options', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const ReceiptTemplateScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(SwitchListTile), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows save button', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const ReceiptTemplateScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.save_rounded), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
