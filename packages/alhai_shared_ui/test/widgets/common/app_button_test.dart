import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_shared_ui/src/widgets/common/app_button.dart';
import '../../helpers/shared_ui_test_helpers.dart';

void main() {
  group('AppButton', () {
    testWidgets('should display label text', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(const AppButton(label: 'Click Me')),
      );
      expect(find.text('Click Me'), findsOneWidget);
    });

    testWidgets('should call onPressed when tapped', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        createSimpleTestWidget(
          AppButton(label: 'Click Me', onPressed: () => pressed = true),
        ),
      );
      await tester.tap(find.text('Click Me'));
      expect(pressed, isTrue);
    });

    testWidgets('should not call onPressed when disabled', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        createSimpleTestWidget(
          AppButton(
            label: 'Click Me',
            onPressed: () => pressed = true,
            disabled: true,
          ),
        ),
      );
      await tester.tap(find.text('Click Me'));
      expect(pressed, isFalse);
    });

    testWidgets('should not call onPressed when loading', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        createSimpleTestWidget(
          AppButton(
            label: 'Click Me',
            onPressed: () => pressed = true,
            isLoading: true,
          ),
        ),
      );
      await tester.tap(find.text('Click Me'));
      expect(pressed, isFalse);
    });

    testWidgets('should show loading indicator when isLoading', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          const AppButton(label: 'Loading', isLoading: true),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show icon when provided', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          const AppButton(label: 'With Icon', icon: Icons.add),
        ),
      );
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should show suffix icon when provided', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          const AppButton(
            label: 'With Suffix',
            suffixIcon: Icons.arrow_forward,
          ),
        ),
      );
      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
    });

    testWidgets('should not show suffix icon when loading', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          const AppButton(
            label: 'Loading',
            suffixIcon: Icons.arrow_forward,
            isLoading: true,
          ),
        ),
      );
      expect(find.byIcon(Icons.arrow_forward), findsNothing);
    });

    testWidgets('primary factory should render', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(AppButton.primary(label: 'Primary')),
      );
      expect(find.text('Primary'), findsOneWidget);
    });

    testWidgets('secondary factory should render', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(AppButton.secondary(label: 'Secondary')),
      );
      expect(find.text('Secondary'), findsOneWidget);
    });

    testWidgets('danger factory should render', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(AppButton.danger(label: 'Danger')),
      );
      expect(find.text('Danger'), findsOneWidget);
    });

    testWidgets('success factory should render', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(AppButton.success(label: 'Success')),
      );
      expect(find.text('Success'), findsOneWidget);
    });

    testWidgets('ghost factory should render', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(AppButton.ghost(label: 'Ghost')),
      );
      expect(find.text('Ghost'), findsOneWidget);
    });

    testWidgets('should show shortcut hint when provided', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          const AppButton(label: 'Save', shortcutHint: 'Ctrl+S'),
        ),
      );
      expect(find.text('Ctrl+S'), findsOneWidget);
    });

    testWidgets('should not show shortcut hint when loading', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          const AppButton(
            label: 'Save',
            shortcutHint: 'Ctrl+S',
            isLoading: true,
          ),
        ),
      );
      expect(find.text('Ctrl+S'), findsNothing);
    });
  });

  group('AppIconButton', () {
    testWidgets('should display icon', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(const AppIconButton(icon: Icons.close)),
      );
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('should call onPressed when tapped', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        createSimpleTestWidget(
          AppIconButton(icon: Icons.close, onPressed: () => pressed = true),
        ),
      );
      await tester.tap(find.byType(AppIconButton));
      expect(pressed, isTrue);
    });

    testWidgets('should not call onPressed when disabled', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        createSimpleTestWidget(
          AppIconButton(
            icon: Icons.close,
            onPressed: () => pressed = true,
            disabled: true,
          ),
        ),
      );
      await tester.tap(find.byType(AppIconButton));
      expect(pressed, isFalse);
    });

    testWidgets('should show loading indicator', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          const AppIconButton(icon: Icons.close, isLoading: true),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show tooltip when provided', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          const AppIconButton(icon: Icons.close, tooltip: 'Close'),
        ),
      );
      expect(find.byType(Tooltip), findsOneWidget);
    });
  });
}
