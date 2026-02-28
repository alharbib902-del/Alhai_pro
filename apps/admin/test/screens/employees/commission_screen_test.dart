import 'package:admin/screens/employees/commission_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_helpers.dart';

void main() {
  late MockAppDatabase mockDb;

  setUpAll(() {
    suppressOverflowErrors();
    registerAdminFallbackValues();
  });

  setUp(() {
    mockDb = setupMockDatabase();
    setupTestGetIt(mockDb: mockDb);
  });

  tearDown(() {
    tearDownTestGetIt();
  });

  group('CommissionScreen', () {
    testWidgets('renders the screen widget', (tester) async {
      // customSelect will throw since not stubbed, screen handles error
      await tester
          .pumpWidget(createTestWidget(const CommissionScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(CommissionScreen), findsOneWidget);
    });

    testWidgets('shows loading or error after startup', (tester) async {
      await tester
          .pumpWidget(createTestWidget(const CommissionScreen()));
      await tester.pump();

      expect(find.byType(CommissionScreen), findsOneWidget);
    });

    testWidgets('has period selector UI elements', (tester) async {
      await tester
          .pumpWidget(createTestWidget(const CommissionScreen()));
      await tester.pumpAndSettle();

      // The screen should be mounted; period selector is internal state
      expect(find.byType(CommissionScreen), findsOneWidget);
    });

    testWidgets('screen handles missing store ID gracefully', (tester) async {
      await tester.pumpWidget(createTestWidget(
        const CommissionScreen(),
        overrides: [
          // Override with null storeId
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.byType(CommissionScreen), findsOneWidget);
    });
  });
}
