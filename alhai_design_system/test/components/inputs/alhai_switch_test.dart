import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('AlhaiSwitch', () {
    testWidgets('renders correctly with value false', (tester) async {
      await tester.pumpWidget(createTestWidget(
        AlhaiSwitch(value: false, onChanged: (_) {}),
      ));

      expect(find.byType(AlhaiSwitch), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('renders correctly with value true', (tester) async {
      await tester.pumpWidget(createTestWidget(
        AlhaiSwitch(value: true, onChanged: (_) {}),
      ));

      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, isTrue);
    });

    testWidgets('calls onChanged when toggled', (tester) async {
      bool? changedValue;
      await tester.pumpWidget(createTestWidget(
        AlhaiSwitch(
          value: false,
          onChanged: (value) => changedValue = value,
        ),
      ));

      await tester.tap(find.byType(Switch));
      await tester.pump();

      expect(changedValue, isTrue);
    });

    testWidgets('shows label text', (tester) async {
      await tester.pumpWidget(createTestWidget(
        AlhaiSwitch(
          value: false,
          label: 'Dark Mode',
          onChanged: (_) {},
        ),
      ));

      expect(find.text('Dark Mode'), findsOneWidget);
    });

    testWidgets('shows subtitle text', (tester) async {
      await tester.pumpWidget(createTestWidget(
        AlhaiSwitch(
          value: false,
          label: 'Notifications',
          subtitle: 'Receive push notifications',
          onChanged: (_) {},
        ),
      ));

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Receive push notifications'), findsOneWidget);
    });

    testWidgets('shows leading widget', (tester) async {
      await tester.pumpWidget(createTestWidget(
        AlhaiSwitch(
          value: false,
          label: 'Dark Mode',
          leading: const Icon(Icons.dark_mode),
          onChanged: (_) {},
        ),
      ));

      expect(find.byIcon(Icons.dark_mode), findsOneWidget);
    });

    testWidgets('is disabled when onChanged is null', (tester) async {
      await tester.pumpWidget(createTestWidget(
        const AlhaiSwitch(
          value: false,
          onChanged: null,
          label: 'Disabled',
        ),
      ));

      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.onChanged, isNull);
    });

    testWidgets('is disabled when enabled is false', (tester) async {
      await tester.pumpWidget(createTestWidget(
        AlhaiSwitch(
          value: false,
          enabled: false,
          onChanged: (_) {},
          label: 'Disabled',
        ),
      ));

      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.onChanged, isNull);
    });

    testWidgets('label tap toggles switch', (tester) async {
      bool? changedValue;
      await tester.pumpWidget(createTestWidget(
        AlhaiSwitch(
          value: false,
          label: 'Click me',
          onChanged: (value) => changedValue = value,
        ),
      ));

      await tester.tap(find.text('Click me'));
      await tester.pump();

      expect(changedValue, isTrue);
    });

    testWidgets('applies reduced opacity when disabled', (tester) async {
      await tester.pumpWidget(createTestWidget(
        AlhaiSwitch(
          value: false,
          enabled: false,
          label: 'Disabled',
          onChanged: (_) {},
        ),
      ));

      // Find the Opacity widget with the disabled opacity value
      final opacityFinder = find.byWidgetPredicate(
        (w) => w is Opacity && w.opacity == AlhaiColors.disabledOpacity,
      );
      expect(opacityFinder, findsOneWidget);
    });

    testWidgets('can be toggled off', (tester) async {
      bool? newValue;

      await tester.pumpWidget(createTestWidget(
        AlhaiSwitch(
          value: true,
          onChanged: (value) => newValue = value,
        ),
      ));

      await tester.tap(find.byType(Switch));
      await tester.pump();

      expect(newValue, isFalse);
    });
  });
}
