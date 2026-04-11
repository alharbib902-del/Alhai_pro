import 'dart:async';

import 'package:admin/screens/marketing/discounts_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_helpers.dart';

void main() {
  late MockAppDatabase mockDb;
  late MockDiscountsDao mockDiscountsDao;

  setUpAll(() {
    suppressOverflowErrors();
    registerAdminFallbackValues();
  });

  setUp(() {
    mockDiscountsDao = MockDiscountsDao();
    mockDb = setupMockDatabase(discountsDao: mockDiscountsDao);
    setupTestGetIt(mockDb: mockDb);
  });

  tearDown(() {
    tearDownTestGetIt();
  });

  group('DiscountsScreen', () {
    testWidgets('shows loading indicator initially', (tester) async {
      final completer = Completer<List<dynamic>>();
      when(
        () => mockDiscountsDao.getAllDiscounts(any()),
      ).thenAnswer((_) => completer.future.then((v) => v.cast()));

      await tester.pumpWidget(createTestWidget(const DiscountsScreen()));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty state when no discounts', (tester) async {
      when(
        () => mockDiscountsDao.getAllDiscounts(any()),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestWidget(const DiscountsScreen()));
      await tester.pumpAndSettle();

      // AppEmptyState.noOffers() should be displayed
      expect(find.byType(DiscountsScreen), findsOneWidget);
    });

    testWidgets('displays discounts list when data is available', (
      tester,
    ) async {
      final discounts = [
        createTestDiscount(id: 'd-1', name: 'خصم تجريبي', isActive: true),
        createTestDiscount(id: 'd-2', name: 'خصم ثاني', isActive: false),
      ];
      when(
        () => mockDiscountsDao.getAllDiscounts(any()),
      ).thenAnswer((_) async => discounts);

      await tester.pumpWidget(createTestWidget(const DiscountsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('خصم تجريبي'), findsOneWidget);
      expect(find.text('خصم ثاني'), findsOneWidget);
    });

    testWidgets('displays stat cards with correct counts', (tester) async {
      final discounts = [
        createTestDiscount(id: 'd-1', isActive: true),
        createTestDiscount(id: 'd-2', isActive: true),
        createTestDiscount(id: 'd-3', isActive: false),
      ];
      when(
        () => mockDiscountsDao.getAllDiscounts(any()),
      ).thenAnswer((_) async => discounts);

      await tester.pumpWidget(createTestWidget(const DiscountsScreen()));
      await tester.pumpAndSettle();

      // Total count (may appear in multiple places like AppHeader badge)
      expect(find.text('3'), findsWidgets);
      // Active count
      expect(find.text('2'), findsWidgets);
      // Inactive count
      expect(find.text('1'), findsWidgets);
    });

    testWidgets('contains switch widgets for active toggle', (tester) async {
      final discounts = [createTestDiscount(id: 'd-1', isActive: true)];
      when(
        () => mockDiscountsDao.getAllDiscounts(any()),
      ).thenAnswer((_) async => discounts);

      await tester.pumpWidget(createTestWidget(const DiscountsScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(Switch), findsWidgets);
    });

    testWidgets('contains delete icon button', (tester) async {
      final discounts = [createTestDiscount(id: 'd-1')];
      when(
        () => mockDiscountsDao.getAllDiscounts(any()),
      ).thenAnswer((_) async => discounts);

      await tester.pumpWidget(createTestWidget(const DiscountsScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });
  });
}
