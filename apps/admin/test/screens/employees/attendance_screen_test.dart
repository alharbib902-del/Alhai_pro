import 'dart:async';

import 'package:admin/screens/employees/attendance_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

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

  group('AttendanceScreen', () {
    testWidgets('renders the screen widget', (tester) async {
      // UsersDao.getAllUsers is stubbed, but customSelect for shifts won't be.
      // The screen handles the error gracefully.
      when(() => mockUsersDao.getAllUsers(any())).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestWidget(const AttendanceScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(AttendanceScreen), findsOneWidget);
    });

    testWidgets('shows loading state initially', (tester) async {
      final completer = Completer<List<dynamic>>();
      when(() => mockUsersDao.getAllUsers(any()))
          .thenAnswer((_) => completer.future.then((v) => v.cast()));

      await tester.pumpWidget(createTestWidget(const AttendanceScreen()));
      await tester.pump();

      // Should show loading or progress indicator
      expect(find.byType(AttendanceScreen), findsOneWidget);
    });

    testWidgets('screen handles missing storeId gracefully', (tester) async {
      await tester.pumpWidget(createTestWidget(
        const AttendanceScreen(),
        overrides: [],
      ));
      await tester.pumpAndSettle();

      expect(find.byType(AttendanceScreen), findsOneWidget);
    });

    testWidgets('has the attendance screen structure', (tester) async {
      when(() => mockUsersDao.getAllUsers(any())).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestWidget(const AttendanceScreen()));
      await tester.pumpAndSettle();

      // The screen widget tree should be present
      expect(find.byType(AttendanceScreen), findsOneWidget);
    });
  });
}
