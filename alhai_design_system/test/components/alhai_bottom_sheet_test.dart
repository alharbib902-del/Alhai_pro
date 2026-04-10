import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('AlhaiBottomSheet', () {
    testWidgets('renders child content', (tester) async {
      await tester.pumpWidget(createTestWidget(
        const AlhaiBottomSheet(
          child: Text('Sheet Content'),
        ),
      ));

      expect(find.text('Sheet Content'), findsOneWidget);
    });

    testWidgets('shows title when provided', (tester) async {
      await tester.pumpWidget(createTestWidget(
        const AlhaiBottomSheet(
          title: 'Sheet Title',
          child: Text('Content'),
        ),
      ));

      expect(find.text('Sheet Title'), findsOneWidget);
    });

    testWidgets('shows close button by default', (tester) async {
      await tester.pumpWidget(createTestWidget(
        const AlhaiBottomSheet(
          title: 'Title',
          child: Text('Content'),
        ),
      ));

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('hides close button when showCloseButton is false',
        (tester) async {
      await tester.pumpWidget(createTestWidget(
        const AlhaiBottomSheet(
          title: 'Title',
          showCloseButton: false,
          child: Text('Content'),
        ),
      ));

      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('calls onClose when close button is pressed', (tester) async {
      var closeCalled = false;
      await tester.pumpWidget(createTestWidget(
        AlhaiBottomSheet(
          title: 'Title',
          onClose: () => closeCalled = true,
          child: const Text('Content'),
        ),
      ));

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(closeCalled, isTrue);
    });

    testWidgets('renders actions when provided', (tester) async {
      await tester.pumpWidget(createTestWidget(
        AlhaiBottomSheet(
          title: 'Title',
          actions: [
            ElevatedButton(onPressed: () {}, child: const Text('Save')),
          ],
          child: const Text('Content'),
        ),
      ));

      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('renders without title and actions', (tester) async {
      await tester.pumpWidget(createTestWidget(
        const AlhaiBottomSheet(
          showCloseButton: false,
          child: Text('Simple Content'),
        ),
      ));

      expect(find.text('Simple Content'), findsOneWidget);
    });

    test('AlhaiBottomSheetSize has expected values', () {
      expect(AlhaiBottomSheetSize.values.length, 3);
      expect(AlhaiBottomSheetSize.values, contains(AlhaiBottomSheetSize.auto));
      expect(AlhaiBottomSheetSize.values, contains(AlhaiBottomSheetSize.half));
      expect(AlhaiBottomSheetSize.values, contains(AlhaiBottomSheetSize.full));
    });
  });
}
