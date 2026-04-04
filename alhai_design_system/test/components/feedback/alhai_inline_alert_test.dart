import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('AlhaiInlineAlert', () {
    testWidgets('renders message text', (tester) async {
      await tester.pumpWidget(createTestWidget(
        const AlhaiInlineAlert(
          type: AlhaiInlineAlertType.info,
          message: 'This is an info message',
        ),
      ));

      expect(find.byType(AlhaiInlineAlert), findsOneWidget);
      expect(find.text('This is an info message'), findsOneWidget);
    });

    testWidgets('renders title when provided', (tester) async {
      await tester.pumpWidget(createTestWidget(
        const AlhaiInlineAlert(
          type: AlhaiInlineAlertType.info,
          message: 'Details here',
          title: 'Important',
        ),
      ));

      expect(find.text('Important'), findsOneWidget);
      expect(find.text('Details here'), findsOneWidget);
    });

    testWidgets('shows close button when onClose is provided', (tester) async {
      var closed = false;
      await tester.pumpWidget(createTestWidget(
        AlhaiInlineAlert(
          type: AlhaiInlineAlertType.info,
          message: 'Dismissable alert',
          onClose: () => closed = true,
        ),
      ));

      expect(find.byIcon(Icons.close), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(closed, isTrue);
    });

    testWidgets('does not show close button when onClose is null',
        (tester) async {
      await tester.pumpWidget(createTestWidget(
        const AlhaiInlineAlert(
          type: AlhaiInlineAlertType.info,
          message: 'No close button',
        ),
      ));

      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('shows action button when actionText and onAction provided',
        (tester) async {
      var actionCalled = false;
      await tester.pumpWidget(createTestWidget(
        AlhaiInlineAlert(
          type: AlhaiInlineAlertType.warning,
          message: 'Action required',
          actionText: 'Fix now',
          onAction: () => actionCalled = true,
        ),
      ));

      expect(find.text('Fix now'), findsOneWidget);

      await tester.tap(find.text('Fix now'));
      await tester.pump();

      expect(actionCalled, isTrue);
    });

    group('type factories', () {
      testWidgets('success factory renders with check icon', (tester) async {
        await tester.pumpWidget(createTestWidget(
          AlhaiInlineAlert.success(message: 'Operation succeeded'),
        ));

        expect(find.text('Operation succeeded'), findsOneWidget);
        expect(find.byIcon(Icons.check_circle_outline_rounded), findsOneWidget);
      });

      testWidgets('info factory renders with info icon', (tester) async {
        await tester.pumpWidget(createTestWidget(
          AlhaiInlineAlert.info(message: 'FYI'),
        ));

        expect(find.text('FYI'), findsOneWidget);
        expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
      });

      testWidgets('warning factory renders with warning icon', (tester) async {
        await tester.pumpWidget(createTestWidget(
          AlhaiInlineAlert.warning(message: 'Be careful'),
        ));

        expect(find.text('Be careful'), findsOneWidget);
        expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      });

      testWidgets('error factory renders with error icon', (tester) async {
        await tester.pumpWidget(createTestWidget(
          AlhaiInlineAlert.error(message: 'Something went wrong'),
        ));

        expect(find.text('Something went wrong'), findsOneWidget);
        expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
      });
    });

    testWidgets('outlined style renders without filled background',
        (tester) async {
      await tester.pumpWidget(createTestWidget(
        const AlhaiInlineAlert(
          type: AlhaiInlineAlertType.info,
          message: 'Outlined',
          filled: false,
        ),
      ));

      expect(find.text('Outlined'), findsOneWidget);
    });
  });
}
