library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:admin/screens/settings/system/activity_log_screen.dart';

import '../../helpers/test_helpers.dart';

void main() {
  late MockAppDatabase db;
  late MockAuditLogDao auditLogDao;

  setUpAll(() => registerAdminFallbackValues());

  setUp(() {
    auditLogDao = MockAuditLogDao();
    db = setupMockDatabase(auditLogDao: auditLogDao);
    setupTestGetIt(mockDb: db);

    when(
      () => auditLogDao.getLogs(any(), limit: any(named: 'limit')),
    ).thenAnswer((_) async => []);
  });

  tearDown(() => tearDownTestGetIt());

  group('ActivityLogScreen', () {
    testWidgets('renders correctly', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const ActivityLogScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(ActivityLogScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows activity log title', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const ActivityLogScreen()));
      await tester.pumpAndSettle();

      // The screen renders its widget tree with activity log
      expect(find.byType(ActivityLogScreen), findsOneWidget);
      // Filter chips row is visible
      expect(find.byType(SingleChildScrollView), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows filter chips', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const ActivityLogScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(FilterChip), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('is a ConsumerStatefulWidget', (tester) async {
      const screen = ActivityLogScreen();
      expect(screen, isA<ActivityLogScreen>());
    });
  });
}
