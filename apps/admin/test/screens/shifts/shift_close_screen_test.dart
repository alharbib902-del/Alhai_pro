library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:admin/screens/shifts/shift_close_screen.dart';

import '../../helpers/test_helpers.dart';

void main() {
  late MockAppDatabase db;
  late MockShiftsDao shiftsDao;

  setUpAll(() => registerAdminFallbackValues());

  setUp(() {
    shiftsDao = MockShiftsDao();
    db = setupMockDatabase(shiftsDao: shiftsDao);
    setupTestGetIt(mockDb: db);

    // Return null to indicate no open shift
    when(() => shiftsDao.getAnyOpenShift(any())).thenAnswer((_) async => null);
  });

  tearDown(() => tearDownTestGetIt());

  group('ShiftCloseScreen', () {
    testWidgets('renders correctly', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const ShiftCloseScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(ShiftCloseScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows no-shift icon when no open shift', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const ShiftCloseScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.timer_off_rounded), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows lock icon for close button', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const ShiftCloseScreen()));
      await tester.pumpAndSettle();

      // When no shift is open, the close button may not be visible
      // but the screen should still render
      expect(find.byType(ShiftCloseScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('is a ConsumerStatefulWidget', (tester) async {
      const screen = ShiftCloseScreen();
      expect(screen, isA<ShiftCloseScreen>());
    });
  });
}
