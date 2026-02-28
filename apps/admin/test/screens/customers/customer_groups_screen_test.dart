library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:admin/screens/customers/customer_groups_screen.dart';

import '../../helpers/test_helpers.dart';

void main() {
  late MockAppDatabase db;

  setUpAll(() => registerAdminFallbackValues());

  setUp(() {
    db = setupMockDatabase();
    setupTestGetIt(mockDb: db);
  });

  tearDown(() => tearDownTestGetIt());

  group('CustomerGroupsScreen', () {
    testWidgets('renders correctly', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
          createTestWidget(const CustomerGroupsScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(CustomerGroupsScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows group icon', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
          createTestWidget(const CustomerGroupsScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.group_rounded), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows refresh button', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
          createTestWidget(const CustomerGroupsScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.refresh_rounded), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows touch hint icon', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
          createTestWidget(const CustomerGroupsScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.touch_app_rounded), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('is a ConsumerStatefulWidget', (tester) async {
      const screen = CustomerGroupsScreen();
      expect(screen, isA<CustomerGroupsScreen>());
    });
  });
}
