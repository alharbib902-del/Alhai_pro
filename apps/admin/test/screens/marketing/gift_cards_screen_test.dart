import 'package:admin/screens/marketing/gift_cards_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_helpers.dart';

void main() {
  setUpAll(() {
    suppressOverflowErrors();
  });

  setUp(() {
    final mockDb = setupMockDatabase();
    setupTestGetIt(mockDb: mockDb);
  });

  tearDown(() {
    tearDownTestGetIt();
  });

  group('GiftCardsScreen', () {
    testWidgets('renders with AppBar and tabs', (tester) async {
      await tester.pumpWidget(createTestWidget(const GiftCardsScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(GiftCardsScreen), findsOneWidget);
      expect(find.byType(TabBar), findsOneWidget);
      // Two tabs: البطاقات and الإحصائيات
      expect(find.byType(Tab), findsNWidgets(2));
    });

    testWidgets('shows cards list after loading', (tester) async {
      await tester.pumpWidget(createTestWidget(const GiftCardsScreen()));
      await tester.pumpAndSettle();

      // Mock data is loaded after delay, should show card codes
      expect(find.text('GC-2025-001'), findsOneWidget);
      expect(find.text('GC-2025-002'), findsOneWidget);
      expect(find.text('GC-2025-003'), findsOneWidget);
    });

    testWidgets('shows search field', (tester) async {
      await tester.pumpWidget(createTestWidget(const GiftCardsScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    });

    testWidgets('shows filter chips', (tester) async {
      await tester.pumpWidget(createTestWidget(const GiftCardsScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(FilterChip), findsNWidgets(4));
    });

    testWidgets('has floating action button for issuing gift card',
        (tester) async {
      await tester.pumpWidget(createTestWidget(const GiftCardsScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('statistics tab shows stat cards', (tester) async {
      await tester.pumpWidget(createTestWidget(const GiftCardsScreen()));
      await tester.pumpAndSettle();

      // Navigate to statistics tab
      await tester.tap(find.text('الإحصائيات'));
      await tester.pumpAndSettle();

      // Should show stat icons
      expect(find.byIcon(Icons.account_balance_wallet_rounded), findsOneWidget);
      expect(find.byIcon(Icons.card_giftcard_rounded), findsWidgets);
    });
  });
}
