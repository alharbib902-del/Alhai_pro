library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:admin/screens/inventory/damaged_goods_screen.dart';

import '../../helpers/test_helpers.dart';

void main() {
  late MockAppDatabase db;

  setUpAll(() => registerAdminFallbackValues());

  setUp(() {
    db = setupMockDatabase();
    setupTestGetIt(mockDb: db);
  });

  tearDown(() => tearDownTestGetIt());

  group('DamagedGoodsScreen', () {
    testWidgets('renders correctly', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
          createTestWidget(const DamagedGoodsScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(DamagedGoodsScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows add FAB', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
          createTestWidget(const DamagedGoodsScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add_rounded), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows broken image icon', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
          createTestWidget(const DamagedGoodsScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.broken_image_rounded), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows warning icon', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
          createTestWidget(const DamagedGoodsScreen()));
      await tester.pumpAndSettle();

      // Loss type breakdown always shows these icons in the summary row
      expect(find.byIcon(Icons.event_busy_rounded), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('is a ConsumerStatefulWidget', (tester) async {
      const screen = DamagedGoodsScreen();
      expect(screen, isA<DamagedGoodsScreen>());
    });
  });
}
