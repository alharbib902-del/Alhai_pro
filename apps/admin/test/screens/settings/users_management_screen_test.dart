library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:admin/screens/settings/system/users_management_screen.dart';

import '../../helpers/test_helpers.dart';

void main() {
  late MockAppDatabase db;
  late MockUsersDao usersDao;

  setUpAll(() => registerAdminFallbackValues());

  setUp(() {
    usersDao = MockUsersDao();
    db = setupMockDatabase(usersDao: usersDao);
    setupTestGetIt(mockDb: db);

    when(() => usersDao.getAllUsers(any())).thenAnswer((_) async => []);
  });

  tearDown(() => tearDownTestGetIt());

  group('UsersManagementScreen', () {
    testWidgets('renders correctly', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const UsersManagementScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(UsersManagementScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows add user button', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const UsersManagementScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.person_add_rounded), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows user count in header', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const UsersManagementScreen()));
      await tester.pumpAndSettle();

      expect(find.textContaining('(0)'), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows loading indicator initially', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final completer = Completer<List<dynamic>>();
      when(
        () => usersDao.getAllUsers(any()),
      ).thenAnswer((_) => completer.future.then((v) => v.cast()));

      await tester.pumpWidget(createTestWidget(const UsersManagementScreen()));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
