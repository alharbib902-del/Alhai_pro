import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('AlhaiDivider', () {
    testWidgets('horizontal divider renders', (tester) async {
      await tester.pumpWidget(
        createTestWidget(const SizedBox(width: 300, child: AlhaiDivider())),
      );

      expect(find.byType(AlhaiDivider), findsOneWidget);
    });

    testWidgets('horizontal factory renders', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const SizedBox(width: 300, child: AlhaiDivider.horizontal()),
        ),
      );

      expect(find.byType(AlhaiDivider), findsOneWidget);
    });

    testWidgets('vertical divider renders', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const SizedBox(height: 100, child: AlhaiDivider.vertical(height: 50)),
        ),
      );

      expect(find.byType(AlhaiDivider), findsOneWidget);
    });

    testWidgets('withLabel renders label text', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const SizedBox(
            width: 300,
            child: AlhaiDivider.withLabel(label: 'OR'),
          ),
        ),
      );

      expect(find.text('OR'), findsOneWidget);
    });

    testWidgets('withLabel at start position', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const SizedBox(
            width: 300,
            child: AlhaiDivider.withLabel(
              label: 'Start',
              position: AlhaiDividerLabelPosition.start,
            ),
          ),
        ),
      );

      expect(find.text('Start'), findsOneWidget);
    });

    testWidgets('withLabel at end position', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const SizedBox(
            width: 300,
            child: AlhaiDivider.withLabel(
              label: 'End',
              position: AlhaiDividerLabelPosition.end,
            ),
          ),
        ),
      );

      expect(find.text('End'), findsOneWidget);
    });

    testWidgets('custom color is applied', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const SizedBox(width: 300, child: AlhaiDivider(color: Colors.red)),
        ),
      );

      expect(find.byType(AlhaiDivider), findsOneWidget);
    });

    testWidgets('respects indent', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const SizedBox(
            width: 300,
            child: AlhaiDivider(indent: 16, endIndent: 16),
          ),
        ),
      );

      expect(find.byType(AlhaiDivider), findsOneWidget);
    });
  });
}
