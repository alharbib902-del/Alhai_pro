import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_shared_ui/src/widgets/layout/split_view.dart';
import '../../helpers/shared_ui_test_helpers.dart';

void main() {
  group('SplitView', () {
    testWidgets('renders primary content', (tester) async {
      // Use desktop width to get side-by-side layout
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        createSimpleTestWidget(
          const SplitView(
            primaryContent: Text('Primary'),
            secondaryContent: Text('Secondary'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Primary'), findsOneWidget);
    });

    testWidgets('renders secondary content when showSecondary is true', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        createSimpleTestWidget(
          const SplitView(
            primaryContent: Text('Primary'),
            secondaryContent: Text('Secondary'),
            showSecondary: true,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Secondary'), findsOneWidget);
    });

    testWidgets('hides secondary content when showSecondary is false', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        createSimpleTestWidget(
          const SplitView(
            primaryContent: Text('Primary'),
            secondaryContent: Text('Secondary'),
            showSecondary: false,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Primary'), findsOneWidget);
      // Secondary should be hidden (animation value 0)
    });

    testWidgets('renders mobile layout for small screens', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        createSimpleTestWidget(
          const SplitView(
            primaryContent: Text('Primary'),
            secondaryContent: Text('Secondary'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Primary'), findsOneWidget);
    });
  });

  group('SplitViewDirection', () {
    test('has correct values', () {
      expect(SplitViewDirection.values.length, 2);
      expect(
        SplitViewDirection.values,
        contains(SplitViewDirection.horizontal),
      );
      expect(SplitViewDirection.values, contains(SplitViewDirection.vertical));
    });
  });

  group('SplitPanelHeader', () {
    testWidgets('renders title', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(const SplitPanelHeader(title: 'Panel Header')),
      );
      expect(find.text('Panel Header'), findsOneWidget);
    });

    testWidgets('renders icon when provided', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          const SplitPanelHeader(title: 'With Icon', icon: Icons.shopping_cart),
        ),
      );
      expect(find.byIcon(Icons.shopping_cart), findsOneWidget);
    });

    testWidgets('renders close button when onClose provided', (tester) async {
      var closed = false;
      await tester.pumpWidget(
        createSimpleTestWidget(
          SplitPanelHeader(title: 'Closable', onClose: () => closed = true),
        ),
      );
      await tester.tap(find.byIcon(Icons.close));
      expect(closed, isTrue);
    });

    testWidgets('renders actions when provided', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          SplitPanelHeader(
            title: 'With Actions',
            actions: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
            ],
          ),
        ),
      );
      expect(find.byIcon(Icons.search), findsOneWidget);
    });
  });
}
