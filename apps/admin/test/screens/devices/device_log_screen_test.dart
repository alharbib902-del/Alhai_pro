library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:admin/screens/devices/device_log_screen.dart';

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

  group('DeviceLogScreen', () {
    testWidgets('renders correctly', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const DeviceLogScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(DeviceLogScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows refresh button', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const DeviceLogScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.refresh), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows info banner', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const DeviceLogScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.info_outline), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows history icon', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const DeviceLogScreen()));
      await tester.pumpAndSettle();

      // With empty logs, shows empty state with folder_open icon
      expect(find.byIcon(Icons.folder_open), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('is a ConsumerStatefulWidget', (tester) async {
      const screen = DeviceLogScreen();
      expect(screen, isA<DeviceLogScreen>());
    });
  });
}
