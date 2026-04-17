import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_shared_ui/src/widgets/common/skeleton_loader.dart';
import '../../helpers/shared_ui_test_helpers.dart';

void main() {
  group('SkeletonLoader', () {
    testWidgets('renders with default dimensions', (tester) async {
      await tester.pumpWidget(createSimpleTestWidget(const SkeletonLoader()));
      expect(find.byType(SkeletonLoader), findsOneWidget);
    });

    testWidgets('renders with custom dimensions', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          const SkeletonLoader(width: 200, height: 24, borderRadius: 12),
        ),
      );
      expect(find.byType(SkeletonLoader), findsOneWidget);
    });
  });

  group('SkeletonListItem', () {
    testWidgets('renders with leading', (tester) async {
      await tester.pumpWidget(createSimpleTestWidget(const SkeletonListItem()));
      expect(find.byType(SkeletonListItem), findsOneWidget);
    });

    testWidgets('renders without leading', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(const SkeletonListItem(hasLeading: false)),
      );
      expect(find.byType(SkeletonListItem), findsOneWidget);
    });

    testWidgets('renders with trailing', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(const SkeletonListItem(hasTrailing: true)),
      );
      expect(find.byType(SkeletonListItem), findsOneWidget);
    });
  });

  group('SkeletonCard', () {
    testWidgets('renders', (tester) async {
      await tester.pumpWidget(createSimpleTestWidget(const SkeletonCard()));
      expect(find.byType(SkeletonCard), findsOneWidget);
    });
  });

  group('SkeletonTable', () {
    testWidgets('renders with default rows and columns', (tester) async {
      await tester.pumpWidget(createSimpleTestWidget(const SkeletonTable()));
      expect(find.byType(SkeletonTable), findsOneWidget);
    });

    testWidgets('renders with custom rows and columns', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(const SkeletonTable(rows: 3, columns: 2)),
      );
      expect(find.byType(SkeletonTable), findsOneWidget);
    });
  });
}
