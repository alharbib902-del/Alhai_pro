import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('AlhaiRadioGroup', () {
    testWidgets('renders all option labels', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AlhaiRadioGroup<String>(
            value: 'a',
            options: const [
              AlhaiRadioOption(value: 'a', label: 'Option A'),
              AlhaiRadioOption(value: 'b', label: 'Option B'),
              AlhaiRadioOption(value: 'c', label: 'Option C'),
            ],
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text('Option A'), findsOneWidget);
      expect(find.text('Option B'), findsOneWidget);
      expect(find.text('Option C'), findsOneWidget);
    });

    testWidgets('shows radio widgets', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AlhaiRadioGroup<String>(
            value: 'a',
            options: const [
              AlhaiRadioOption(value: 'a', label: 'Option A'),
              AlhaiRadioOption(value: 'b', label: 'Option B'),
            ],
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.byType(Radio<String>), findsNWidgets(2));
    });

    testWidgets('calls onChanged when option is tapped', (tester) async {
      String? selectedValue;
      await tester.pumpWidget(
        createTestWidget(
          AlhaiRadioGroup<String>(
            value: 'a',
            options: const [
              AlhaiRadioOption(value: 'a', label: 'Option A'),
              AlhaiRadioOption(value: 'b', label: 'Option B'),
            ],
            onChanged: (value) => selectedValue = value,
          ),
        ),
      );

      await tester.tap(find.text('Option B'));
      await tester.pump();

      expect(selectedValue, 'b');
    });

    testWidgets('shows subtitle when provided', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AlhaiRadioGroup<String>(
            value: 'a',
            options: const [
              AlhaiRadioOption(
                value: 'a',
                label: 'Option A',
                subtitle: 'Description A',
              ),
            ],
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text('Description A'), findsOneWidget);
    });

    testWidgets('shows leading widget when provided', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AlhaiRadioGroup<String>(
            value: 'a',
            options: const [
              AlhaiRadioOption(
                value: 'a',
                label: 'Option A',
                leading: Icon(Icons.star),
              ),
            ],
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('disabled option does not trigger onChanged', (tester) async {
      String? selectedValue;
      await tester.pumpWidget(
        createTestWidget(
          AlhaiRadioGroup<String>(
            value: 'a',
            options: const [
              AlhaiRadioOption(value: 'a', label: 'Option A'),
              AlhaiRadioOption(value: 'b', label: 'Option B', enabled: false),
            ],
            onChanged: (value) => selectedValue = value,
          ),
        ),
      );

      // Tap the disabled radio directly
      final radios = find.byType(Radio<String>);
      await tester.tap(radios.at(1));
      await tester.pump();

      expect(selectedValue, isNull);
    });
  });
}
