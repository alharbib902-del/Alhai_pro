import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('AlhaiCheckbox', () {
    testWidgets('renders correctly with value false', (tester) async {
      await tester.pumpWidget(
        createTestWidget(AlhaiCheckbox(value: false, onChanged: (_) {})),
      );

      expect(find.byType(AlhaiCheckbox), findsOneWidget);
      expect(find.byType(Checkbox), findsOneWidget);
    });

    testWidgets('renders correctly with value true', (tester) async {
      await tester.pumpWidget(
        createTestWidget(AlhaiCheckbox(value: true, onChanged: (_) {})),
      );

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isTrue);
    });

    testWidgets('calls onChanged when tapped', (tester) async {
      bool? changedValue;
      await tester.pumpWidget(
        createTestWidget(
          AlhaiCheckbox(
            value: false,
            onChanged: (value) => changedValue = value,
          ),
        ),
      );

      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      expect(changedValue, isNotNull);
    });

    testWidgets('shows label text', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AlhaiCheckbox(value: false, label: 'Accept terms', onChanged: (_) {}),
        ),
      );

      expect(find.text('Accept terms'), findsOneWidget);
    });

    testWidgets('shows subtitle text', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AlhaiCheckbox(
            value: false,
            label: 'Accept',
            subtitle: 'Read the terms first',
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text('Accept'), findsOneWidget);
      expect(find.text('Read the terms first'), findsOneWidget);
    });

    testWidgets('is disabled when onChanged is null', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const AlhaiCheckbox(value: false, onChanged: null, label: 'Disabled'),
        ),
      );

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.onChanged, isNull);
    });

    testWidgets('is disabled when enabled is false', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AlhaiCheckbox(
            value: false,
            enabled: false,
            onChanged: (_) {},
            label: 'Disabled',
          ),
        ),
      );

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.onChanged, isNull);
    });

    testWidgets('label tap toggles checkbox', (tester) async {
      bool? changedValue;
      await tester.pumpWidget(
        createTestWidget(
          AlhaiCheckbox(
            value: false,
            label: 'Click me',
            onChanged: (value) => changedValue = value,
          ),
        ),
      );

      await tester.tap(find.text('Click me'));
      await tester.pump();

      expect(changedValue, isTrue);
    });

    testWidgets('tristate supports null value', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AlhaiCheckbox(value: null, tristate: true, onChanged: (_) {}),
        ),
      );

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.tristate, isTrue);
      expect(checkbox.value, isNull);
    });

    testWidgets('can be toggled off', (tester) async {
      bool? newValue;

      await tester.pumpWidget(
        createTestWidget(
          AlhaiCheckbox(value: true, onChanged: (value) => newValue = value),
        ),
      );

      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      expect(newValue, isFalse);
    });

    testWidgets('disabled checkbox does not respond to tap', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        createTestWidget(
          AlhaiCheckbox(
            value: false,
            enabled: false,
            onChanged: (_) => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      expect(tapped, isFalse);
    });
  });
}
