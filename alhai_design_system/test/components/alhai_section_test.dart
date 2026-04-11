import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('AlhaiSection', () {
    testWidgets('renders child content', (tester) async {
      await tester.pumpWidget(
        createTestWidget(const AlhaiSection(child: Text('Section Content'))),
      );

      expect(find.text('Section Content'), findsOneWidget);
    });

    testWidgets('renders title when provided', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const AlhaiSection(title: 'Section Title', child: Text('Content')),
        ),
      );

      expect(find.text('Section Title'), findsOneWidget);
    });

    testWidgets('renders subtitle when provided', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const AlhaiSection(
            title: 'Title',
            subtitle: 'Subtitle',
            child: Text('Content'),
          ),
        ),
      );

      expect(find.text('Subtitle'), findsOneWidget);
    });

    testWidgets('renders trailing widget when provided', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AlhaiSection(
            title: 'Title',
            trailing: TextButton(
              onPressed: () {},
              child: const Text('View All'),
            ),
            child: const Text('Content'),
          ),
        ),
      );

      expect(find.text('View All'), findsOneWidget);
    });

    testWidgets('renders without title', (tester) async {
      await tester.pumpWidget(
        createTestWidget(const AlhaiSection(child: Text('Content Only'))),
      );

      expect(find.text('Content Only'), findsOneWidget);
    });

    testWidgets('list factory renders children', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AlhaiSection.list(
            title: 'List Section',
            children: const [Text('Item 1'), Text('Item 2')],
          ),
        ),
      );

      expect(find.text('List Section'), findsOneWidget);
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
    });

    testWidgets('shows divider when showDivider is true', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const AlhaiSection(
            title: 'Title',
            showDivider: true,
            child: Text('Content'),
          ),
        ),
      );

      expect(find.byType(Divider), findsOneWidget);
    });
  });
}
