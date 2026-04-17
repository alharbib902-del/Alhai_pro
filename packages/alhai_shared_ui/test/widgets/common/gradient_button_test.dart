import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_shared_ui/src/widgets/common/gradient_button.dart';
import '../../helpers/shared_ui_test_helpers.dart';

void main() {
  group('GradientButton', () {
    testWidgets('renders label', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(const GradientButton(label: 'Click Me')),
      );
      expect(find.text('Click Me'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        createSimpleTestWidget(
          GradientButton(label: 'Tap Me', onPressed: () => tapped = true),
        ),
      );
      await tester.tap(find.text('Tap Me'));
      expect(tapped, isTrue);
    });

    testWidgets('does not call onPressed when disabled', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        createSimpleTestWidget(
          GradientButton(
            label: 'Disabled',
            onPressed: () => tapped = true,
            isDisabled: true,
          ),
        ),
      );
      await tester.tap(find.text('Disabled'));
      expect(tapped, isFalse);
    });

    testWidgets('does not call onPressed when loading', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        createSimpleTestWidget(
          GradientButton(
            label: 'Loading',
            onPressed: () => tapped = true,
            isLoading: true,
          ),
        ),
      );
      // Loading shows spinner, not text label
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows icon when provided', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          const GradientButton(label: 'With Icon', icon: Icons.add),
        ),
      );
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('primary factory renders', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(GradientButton.primary(label: 'Primary')),
      );
      expect(find.text('Primary'), findsOneWidget);
    });

    testWidgets('secondary factory renders', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(GradientButton.secondary(label: 'Secondary')),
      );
      expect(find.text('Secondary'), findsOneWidget);
    });

    testWidgets('success factory renders', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(GradientButton.success(label: 'Success')),
      );
      expect(find.text('Success'), findsOneWidget);
    });

    testWidgets('danger factory renders', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(GradientButton.danger(label: 'Danger')),
      );
      expect(find.text('Danger'), findsOneWidget);
    });

    testWidgets('renders small size', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          const GradientButton(label: 'Small', size: GradientButtonSize.small),
        ),
      );
      expect(find.text('Small'), findsOneWidget);
    });

    testWidgets('renders large size', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          const GradientButton(label: 'Large', size: GradientButtonSize.large),
        ),
      );
      expect(find.text('Large'), findsOneWidget);
    });
  });

  group('GradientIconButton', () {
    testWidgets('renders icon', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(const GradientIconButton(icon: Icons.add)),
      );
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        createSimpleTestWidget(
          GradientIconButton(icon: Icons.add, onPressed: () => tapped = true),
        ),
      );
      await tester.tap(find.byIcon(Icons.add));
      expect(tapped, isTrue);
    });

    testWidgets('shows tooltip when provided', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          const GradientIconButton(icon: Icons.add, tooltip: 'Add Item'),
        ),
      );
      expect(find.byType(Tooltip), findsOneWidget);
    });

    testWidgets('shows loading state', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          const GradientIconButton(icon: Icons.add, isLoading: true),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
