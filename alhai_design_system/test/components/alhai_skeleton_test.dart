import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('AlhaiSkeleton', () {
    testWidgets('renders default skeleton', (tester) async {
      await tester.pumpWidget(createTestWidget(const AlhaiSkeleton()));

      expect(find.byType(AlhaiSkeleton), findsOneWidget);
    });

    testWidgets('rectangle renders with specified dimensions', (tester) async {
      await tester.pumpWidget(
        createTestWidget(const AlhaiSkeleton.rectangle(width: 200, height: 50)),
      );

      expect(find.byType(AlhaiSkeleton), findsOneWidget);
    });

    testWidgets('circle renders', (tester) async {
      await tester.pumpWidget(createTestWidget(AlhaiSkeleton.circle(size: 48)));

      expect(find.byWidgetPredicate((w) => w is AlhaiSkeleton), findsOneWidget);
    });

    testWidgets('text renders with single line', (tester) async {
      await tester.pumpWidget(createTestWidget(AlhaiSkeleton.text(width: 150)));

      expect(find.byWidgetPredicate((w) => w is AlhaiSkeleton), findsOneWidget);
    });

    testWidgets('text renders with multiple lines', (tester) async {
      await tester.pumpWidget(createTestWidget(AlhaiSkeleton.text(lines: 3)));

      expect(find.byWidgetPredicate((w) => w is AlhaiSkeleton), findsOneWidget);
    });

    testWidgets('accepts custom border radius', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const AlhaiSkeleton(
            width: 100,
            height: 40,
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      );

      expect(find.byType(AlhaiSkeleton), findsOneWidget);
    });
  });
}
