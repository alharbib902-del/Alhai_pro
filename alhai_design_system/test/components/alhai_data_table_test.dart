import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('AlhaiDataTable', () {
    testWidgets('renders column headers', (tester) async {
      await tester.pumpWidget(createTestWidget(
        AlhaiDataTable<String>(
          columns: const ['Name', 'Price', 'Qty'],
          data: const ['Item 1', 'Item 2'],
          cellBuilder: (item, colIndex) => Text('$item-$colIndex'),
        ),
      ));

      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Price'), findsOneWidget);
      expect(find.text('Qty'), findsOneWidget);
    });

    testWidgets('renders data rows', (tester) async {
      await tester.pumpWidget(createTestWidget(
        AlhaiDataTable<String>(
          columns: const ['Col1'],
          data: const ['Row1', 'Row2'],
          cellBuilder: (item, _) => Text(item),
        ),
      ));

      expect(find.text('Row1'), findsOneWidget);
      expect(find.text('Row2'), findsOneWidget);
    });

    testWidgets('shows empty state when data is empty', (tester) async {
      await tester.pumpWidget(createTestWidget(
        AlhaiDataTable<String>(
          columns: const ['Col1'],
          data: const [],
          cellBuilder: (item, _) => Text(item),
        ),
      ));

      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });

    testWidgets('shows loading skeleton when isLoading is true',
        (tester) async {
      await tester.pumpWidget(createTestWidget(
        AlhaiDataTable<String>(
          columns: const ['Col1'],
          data: const [],
          cellBuilder: (item, _) => Text(item),
          isLoading: true,
        ),
      ));

      // Should show skeleton rows, not empty state
      expect(find.byIcon(Icons.inbox_outlined), findsNothing);
    });

    testWidgets('hides header when showHeader is false', (tester) async {
      await tester.pumpWidget(createTestWidget(
        AlhaiDataTable<String>(
          columns: const ['Name'],
          data: const ['Item'],
          cellBuilder: (item, _) => Text(item),
          showHeader: false,
        ),
      ));

      expect(find.text('Name'), findsNothing);
    });

    testWidgets('calls onRowTap when row is tapped', (tester) async {
      String? tappedItem;
      await tester.pumpWidget(createTestWidget(
        AlhaiDataTable<String>(
          columns: const ['Col1'],
          data: const ['Tap me'],
          cellBuilder: (item, _) => Text(item),
          onRowTap: (item) => tappedItem = item,
        ),
      ));

      await tester.tap(find.text('Tap me'));
      await tester.pump();

      expect(tappedItem, 'Tap me');
    });
  });
}
