import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_shared_ui/src/widgets/common/app_data_table.dart';
import '../../helpers/shared_ui_test_helpers.dart';

void main() {
  final testData = ['Apple', 'Banana', 'Cherry'];
  final testColumns = [
    AppDataColumn<String>(title: 'Fruit', builder: (item) => Text(item)),
  ];

  group('AppDataTable', () {
    testWidgets('renders data rows', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          SizedBox(
            height: 400,
            child: AppDataTable<String>(data: testData, columns: testColumns),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Banana'), findsOneWidget);
      expect(find.text('Cherry'), findsOneWidget);
    });

    testWidgets('renders column header', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          SizedBox(
            height: 400,
            child: AppDataTable<String>(data: testData, columns: testColumns),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Fruit'), findsOneWidget);
    });

    testWidgets('shows empty state when no data', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          SizedBox(
            height: 400,
            child: AppDataTable<String>(data: const [], columns: testColumns),
          ),
        ),
      );
      await tester.pumpAndSettle();
      // Empty state widget should appear
      expect(find.text('Apple'), findsNothing);
    });

    testWidgets('shows loading state', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          SizedBox(
            height: 400,
            child: AppDataTable<String>(
              data: testData,
              columns: testColumns,
              isLoading: true,
            ),
          ),
        ),
      );
      await tester.pump();
      // Data should not be rendered when loading
      expect(find.text('Apple'), findsNothing);
    });

    testWidgets('calls onRowTap when row tapped', (tester) async {
      String? tappedItem;
      await tester.pumpWidget(
        createSimpleTestWidget(
          SizedBox(
            height: 400,
            child: AppDataTable<String>(
              data: testData,
              columns: testColumns,
              onRowTap: (item) => tappedItem = item,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apple'));
      expect(tappedItem, equals('Apple'));
    });
  });

  group('AppPagination', () {
    testWidgets('renders page numbers', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          AppPagination(currentPage: 1, totalPages: 5, onPageChanged: (_) {}),
        ),
      );
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('calls onPageChanged when page button tapped', (tester) async {
      int? newPage;
      await tester.pumpWidget(
        createSimpleTestWidget(
          AppPagination(
            currentPage: 1,
            totalPages: 5,
            onPageChanged: (page) => newPage = page,
          ),
        ),
      );
      await tester.tap(find.text('2'));
      expect(newPage, equals(2));
    });

    testWidgets('shows items info when totalItems provided', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          AppPagination(
            currentPage: 1,
            totalPages: 5,
            totalItems: 50,
            onPageChanged: (_) {},
          ),
        ),
      );
      expect(find.textContaining('1-10'), findsOneWidget);
    });
  });
}
