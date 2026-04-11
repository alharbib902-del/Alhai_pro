import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_shared_ui/src/widgets/common/error_widget.dart';
import '../../helpers/shared_ui_test_helpers.dart';

void main() {
  group('AppErrorWidget', () {
    testWidgets('should display error message', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          const AppErrorWidget(message: 'Something failed'),
        ),
      );
      expect(find.text('Something failed'), findsOneWidget);
    });

    testWidgets('should display default icon', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(const AppErrorWidget(message: 'Error')),
      );
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should display custom icon', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          const AppErrorWidget(message: 'Error', icon: Icons.warning),
        ),
      );
      expect(find.byIcon(Icons.warning), findsOneWidget);
    });

    testWidgets('should show retry button when onRetry provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          AppErrorWidget(message: 'Error', onRetry: () {}),
        ),
      );
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('should call onRetry when retry button tapped', (tester) async {
      var retryCalled = false;
      await tester.pumpWidget(
        createSimpleTestWidget(
          AppErrorWidget(message: 'Error', onRetry: () => retryCalled = true),
        ),
      );
      // FilledButton.icon renders the retry button with refresh icon
      await tester.tap(find.byIcon(Icons.refresh));
      expect(retryCalled, isTrue);
    });

    testWidgets('should not show retry button when onRetry is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        createSimpleTestWidget(const AppErrorWidget(message: 'Error')),
      );
      expect(find.byIcon(Icons.refresh), findsNothing);
    });

    testWidgets('network factory should render', (tester) async {
      await tester.pumpWidget(createSimpleTestWidget(AppErrorWidget.network()));
      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
    });

    testWidgets('loading factory should render', (tester) async {
      await tester.pumpWidget(createSimpleTestWidget(AppErrorWidget.loading()));
      expect(find.byIcon(Icons.sync_problem), findsOneWidget);
    });

    testWidgets('loading factory with details should render', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(AppErrorWidget.loading(details: 'Custom error')),
      );
      expect(find.text('Custom error'), findsOneWidget);
    });

    testWidgets('generic factory should render', (tester) async {
      await tester.pumpWidget(createSimpleTestWidget(AppErrorWidget.generic()));
      expect(find.byIcon(Icons.warning_amber), findsOneWidget);
    });

    testWidgets('generic factory with message should render', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          AppErrorWidget.generic(message: 'Custom message'),
        ),
      );
      expect(find.text('Custom message'), findsOneWidget);
    });
  });

  group('ErrorMessage', () {
    testWidgets('should display error message', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(const ErrorMessage(message: 'Inline error')),
      );
      expect(find.text('Inline error'), findsOneWidget);
    });

    testWidgets('should show error icon', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(const ErrorMessage(message: 'Error')),
      );
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should show dismiss button when onDismiss provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          ErrorMessage(message: 'Error', onDismiss: () {}),
        ),
      );
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('should call onDismiss when dismiss button tapped', (
      tester,
    ) async {
      var dismissed = false;
      await tester.pumpWidget(
        createSimpleTestWidget(
          ErrorMessage(message: 'Error', onDismiss: () => dismissed = true),
        ),
      );
      await tester.tap(find.byIcon(Icons.close));
      expect(dismissed, isTrue);
    });

    testWidgets('should not show dismiss button when onDismiss is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        createSimpleTestWidget(const ErrorMessage(message: 'Error')),
      );
      expect(find.byIcon(Icons.close), findsNothing);
    });
  });
}
