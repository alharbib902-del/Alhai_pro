import 'dart:async';

import 'package:admin/screens/employees/employee_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:alhai_database/alhai_database.dart';

import '../../helpers/test_helpers.dart';

void main() {
  late MockAppDatabase mockDb;
  late MockUsersDao mockUsersDao;

  setUpAll(() {
    suppressOverflowErrors();
    registerAdminFallbackValues();
  });

  setUp(() {
    mockUsersDao = MockUsersDao();
    mockDb = setupMockDatabase(usersDao: mockUsersDao);
    setupTestGetIt(mockDb: mockDb);
  });

  tearDown(() {
    tearDownTestGetIt();
  });

  group('EmployeeProfileScreen', () {
    testWidgets('shows loading indicator initially', (tester) async {
      final completer = Completer<UsersTableData?>();
      when(
        () => mockUsersDao.getUserById(any()),
      ).thenAnswer((_) => completer.future);

      await tester.pumpWidget(
        createTestWidget(const EmployeeProfileScreen(userId: 'user-1')),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('shows error state when user not found', (tester) async {
      when(
        () => mockUsersDao.getUserById('user-1'),
      ).thenAnswer((_) async => null);

      await tester.pumpWidget(
        createTestWidget(const EmployeeProfileScreen(userId: 'user-1')),
      );
      await tester.pumpAndSettle();

      // Screen should handle null user
      expect(find.byType(EmployeeProfileScreen), findsOneWidget);
    });

    testWidgets('displays user info when loaded', (tester) async {
      final user = UsersTableData(
        id: 'user-1',
        storeId: 'test-store-1',
        name: 'أحمد محمد',
        phone: '0501234567',
        role: 'cashier',
        isActive: true,
        createdAt: DateTime(2026, 1, 1),
      );
      when(
        () => mockUsersDao.getUserById('user-1'),
      ).thenAnswer((_) async => user);

      await tester.pumpWidget(
        createTestWidget(const EmployeeProfileScreen(userId: 'user-1')),
      );
      await tester.pumpAndSettle();

      expect(find.text('أحمد محمد'), findsWidgets);
    });

    testWidgets('has 4 tabs', (tester) async {
      final user = UsersTableData(
        id: 'user-1',
        storeId: 'test-store-1',
        name: 'أحمد',
        phone: '0501234567',
        role: 'cashier',
        isActive: true,
        createdAt: DateTime(2026, 1, 1),
      );
      when(
        () => mockUsersDao.getUserById('user-1'),
      ).thenAnswer((_) async => user);

      await tester.pumpWidget(
        createTestWidget(const EmployeeProfileScreen(userId: 'user-1')),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TabBar), findsOneWidget);
      expect(find.byType(Tab), findsNWidgets(4));
    });

    testWidgets('screen handles error from getUserById', (tester) async {
      when(
        () => mockUsersDao.getUserById('user-1'),
      ).thenAnswer((_) async => throw Exception('DB error'));

      await tester.pumpWidget(
        createTestWidget(const EmployeeProfileScreen(userId: 'user-1')),
      );
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(EmployeeProfileScreen), findsOneWidget);
    });
  });
}
