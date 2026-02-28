library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:admin/screens/settings/roles_permissions_screen.dart';

import '../../helpers/test_helpers.dart';

void main() {
  late MockAppDatabase db;
  late MockUsersDao usersDao;

  setUpAll(() => registerAdminFallbackValues());

  setUp(() {
    usersDao = MockUsersDao();
    db = setupMockDatabase(usersDao: usersDao);
    setupTestGetIt(mockDb: db);

    when(() => usersDao.getAllRoles(any())).thenAnswer((_) async => []);
  });

  tearDown(() => tearDownTestGetIt());

  group('RolesPermissionsScreen', () {
    testWidgets('renders correctly', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const RolesPermissionsScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(RolesPermissionsScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows tab bar with roles and permissions tabs', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const RolesPermissionsScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(TabBar), findsOneWidget);
      expect(find.byIcon(Icons.groups), findsOneWidget);
      expect(find.byIcon(Icons.security), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows add role button', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const RolesPermissionsScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows default roles when DB is empty', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const RolesPermissionsScreen()));
      await tester.pumpAndSettle();

      // Default roles include admin, store manager, cashier, etc.
      expect(find.byIcon(Icons.admin_panel_settings), findsWidgets);
      expect(find.byIcon(Icons.point_of_sale), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
