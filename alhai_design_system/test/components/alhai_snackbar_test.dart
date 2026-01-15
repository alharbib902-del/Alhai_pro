import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_design_system/src/components/feedback/alhai_snackbar.dart';

void main() {
  group('AlhaiSnackbar', () {
    group('Show Methods', () {
      testWidgets('shows success snackbar', (tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: ElevatedButton(
                    onPressed: () {
                      AlhaiSnackbar.success(context, 'Success message');
                    },
                    child: const Text('Show'),
                  ),
                );
              },
            ),
          ),
        );

        // Act
        await tester.tap(find.text('Show'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Success message'), findsOneWidget);
      });

      testWidgets('shows error snackbar', (tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: ElevatedButton(
                    onPressed: () {
                      AlhaiSnackbar.error(context, 'Error message');
                    },
                    child: const Text('Show'),
                  ),
                );
              },
            ),
          ),
        );

        // Act
        await tester.tap(find.text('Show'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Error message'), findsOneWidget);
      });

      testWidgets('shows info snackbar', (tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: ElevatedButton(
                    onPressed: () {
                      AlhaiSnackbar.info(context, 'Info message');
                    },
                    child: const Text('Show'),
                  ),
                );
              },
            ),
          ),
        );

        // Act
        await tester.tap(find.text('Show'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Info message'), findsOneWidget);
      });

      testWidgets('shows warning snackbar', (tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: ElevatedButton(
                    onPressed: () {
                      AlhaiSnackbar.warning(context, 'Warning message');
                    },
                    child: const Text('Show'),
                  ),
                );
              },
            ),
          ),
        );

        // Act
        await tester.tap(find.text('Show'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Warning message'), findsOneWidget);
      });
    });

    group('Custom Action', () {
      testWidgets('shows action button when provided', (tester) async {
        // Arrange
        var actionCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: ElevatedButton(
                    onPressed: () {
                      AlhaiSnackbar.show(
                        context,
                        message: 'With action',
                        actionText: 'Undo',
                        onAction: () => actionCalled = true,
                      );
                    },
                    child: const Text('Show'),
                  ),
                );
              },
            ),
          ),
        );

        // Act
        await tester.tap(find.text('Show'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Undo'));
        await tester.pumpAndSettle();

        // Assert
        expect(actionCalled, isTrue);
      });
    });
  });
}
