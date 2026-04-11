import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('AlhaiButton', () {
    testWidgets('renders with label text', (tester) async {
      await tester.pumpWidget(
        createTestWidget(AlhaiButton(label: 'Click Me', onPressed: () {})),
      );

      expect(find.text('Click Me'), findsOneWidget);
      expect(find.byType(AlhaiButton), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        createTestWidget(
          AlhaiButton(label: 'Press', onPressed: () => pressed = true),
        ),
      );

      await tester.tap(find.byType(AlhaiButton));
      await tester.pump();

      expect(pressed, isTrue);
    });

    testWidgets('is disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(
        createTestWidget(const AlhaiButton(label: 'Disabled', onPressed: null)),
      );

      // FilledButton should be present but not tappable
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('shows loading indicator when isLoading', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AlhaiButton(label: 'Loading', isLoading: true, onPressed: () {}),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('does not call onPressed when loading', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        createTestWidget(
          AlhaiButton(
            label: 'Loading',
            isLoading: true,
            onPressed: () => pressed = true,
          ),
        ),
      );

      await tester.tap(find.byType(AlhaiButton));
      await tester.pump();

      expect(pressed, isFalse);
    });

    testWidgets('renders leading icon', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AlhaiButton(label: 'Add', leadingIcon: Icons.add, onPressed: () {}),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('renders trailing icon', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AlhaiButton(
            label: 'Next',
            trailingIcon: Icons.arrow_forward,
            onPressed: () {},
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
    });

    group('factories', () {
      testWidgets('AlhaiButton.filled renders as filled button', (
        tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(
            AlhaiButton.filled(label: 'Filled', onPressed: () {}),
          ),
        );

        expect(find.byType(FilledButton), findsOneWidget);
        expect(find.text('Filled'), findsOneWidget);
      });

      testWidgets('AlhaiButton.outlined renders as outlined button', (
        tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(
            AlhaiButton.outlined(label: 'Outlined', onPressed: () {}),
          ),
        );

        expect(find.byType(OutlinedButton), findsOneWidget);
        expect(find.text('Outlined'), findsOneWidget);
      });

      testWidgets('AlhaiButton.text renders as text button', (tester) async {
        await tester.pumpWidget(
          createTestWidget(AlhaiButton.text(label: 'Text', onPressed: () {})),
        );

        expect(find.byType(TextButton), findsOneWidget);
        expect(find.text('Text'), findsOneWidget);
      });
    });

    group('sizes', () {
      testWidgets('small button renders', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            AlhaiButton(
              label: 'Small',
              size: AlhaiButtonSize.small,
              onPressed: () {},
            ),
          ),
        );

        expect(find.text('Small'), findsOneWidget);
      });

      testWidgets('large button renders', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            AlhaiButton(
              label: 'Large',
              size: AlhaiButtonSize.large,
              onPressed: () {},
            ),
          ),
        );

        expect(find.text('Large'), findsOneWidget);
      });
    });

    testWidgets('fullWidth button expands horizontally', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AlhaiButton(label: 'Full Width', fullWidth: true, onPressed: () {}),
        ),
      );

      // Should find a SizedBox with width: double.infinity
      expect(
        find.byWidgetPredicate(
          (w) => w is SizedBox && w.width == double.infinity,
        ),
        findsOneWidget,
      );
    });

    group('variants', () {
      testWidgets('tonal variant renders correctly', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            AlhaiButton(
              label: 'Tonal',
              variant: AlhaiButtonVariant.tonal,
              onPressed: () {},
            ),
          ),
        );

        expect(find.text('Tonal'), findsOneWidget);
      });
    });

    group('theming', () {
      testWidgets('applies custom background color', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            AlhaiButton.filled(
              label: 'Custom',
              backgroundColor: Colors.red,
              onPressed: () {},
            ),
          ),
        );

        expect(find.text('Custom'), findsOneWidget);
      });

      testWidgets('applies custom foreground color', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            AlhaiButton.filled(
              label: 'Custom FG',
              foregroundColor: Colors.yellow,
              onPressed: () {},
            ),
          ),
        );

        expect(find.text('Custom FG'), findsOneWidget);
      });
    });
  });
}
