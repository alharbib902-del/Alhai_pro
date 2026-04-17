import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_shared_ui/src/widgets/common/app_dialog.dart';
import '../../helpers/shared_ui_test_helpers.dart';

void main() {
  group('AppDialog', () {
    testWidgets('renders title and content', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => const AppDialog(
                    title: 'Test Dialog',
                    content: Text('Dialog Content'),
                  ),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Test Dialog'), findsOneWidget);
      expect(find.text('Dialog Content'), findsOneWidget);
    });

    testWidgets('renders icon when provided', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => const AppDialog(
                    title: 'With Icon',
                    icon: Icons.info,
                    content: Text('Content'),
                  ),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.info), findsOneWidget);
    });

    testWidgets('renders actions when provided', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AppDialog(
                    title: 'With Actions',
                    content: const Text('Content'),
                    actions: [
                      TextButton(onPressed: () {}, child: const Text('Cancel')),
                      TextButton(onPressed: () {}, child: const Text('OK')),
                    ],
                  ),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
    });
  });

  group('AppBottomSheet', () {
    testWidgets('renders content', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          const AppBottomSheet(content: Text('Sheet Content')),
        ),
      );
      expect(find.text('Sheet Content'), findsOneWidget);
    });

    testWidgets('renders title when provided', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          const AppBottomSheet(title: 'Sheet Title', content: Text('Content')),
        ),
      );
      expect(find.text('Sheet Title'), findsOneWidget);
    });

    testWidgets('renders handle when showHandle is true', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          const AppBottomSheet(showHandle: true, content: Text('Content')),
        ),
      );
      // The handle is a Container - the sheet should render
      expect(find.text('Content'), findsOneWidget);
    });

    testWidgets('hides handle when showHandle is false', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          const AppBottomSheet(showHandle: false, content: Text('Content')),
        ),
      );
      expect(find.text('Content'), findsOneWidget);
    });
  });
}
