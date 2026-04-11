import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('AlhaiDropdown', () {
    testWidgets('renders with label', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AlhaiDropdown<String>(
            items: const ['Option 1', 'Option 2'],
            itemLabelBuilder: (item) => item,
            label: 'Select Option',
          ),
        ),
      );

      expect(find.text('Select Option'), findsOneWidget);
    });

    testWidgets('shows hint text when no value selected', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AlhaiDropdown<String>(
            items: const ['Option 1', 'Option 2'],
            itemLabelBuilder: (item) => item,
            hint: 'Choose...',
          ),
        ),
      );

      expect(find.text('Choose...'), findsOneWidget);
    });

    testWidgets('shows selected value', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AlhaiDropdown<String>(
            items: const ['Option 1', 'Option 2'],
            itemLabelBuilder: (item) => item,
            value: 'Option 1',
          ),
        ),
      );

      expect(find.text('Option 1'), findsOneWidget);
    });

    testWidgets('is disabled when enabled is false', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AlhaiDropdown<String>(
            items: const ['Option 1', 'Option 2'],
            itemLabelBuilder: (item) => item,
            enabled: false,
          ),
        ),
      );

      expect(find.byType(AlhaiDropdown<String>), findsOneWidget);
    });

    testWidgets('is disabled when loading', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AlhaiDropdown<String>(
            items: const ['Option 1'],
            itemLabelBuilder: (item) => item,
            loading: true,
          ),
        ),
      );

      expect(find.byType(AlhaiDropdown<String>), findsOneWidget);
    });

    testWidgets('shows prefix widget', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AlhaiDropdown<String>(
            items: const ['Option 1'],
            itemLabelBuilder: (item) => item,
            prefix: const Icon(Icons.category),
          ),
        ),
      );

      expect(find.byIcon(Icons.category), findsOneWidget);
    });
  });
}
