import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_design_system/src/components/feedback/alhai_dialog.dart';

void main() {
  group('AlhaiDialog', () {
    group('Confirm Dialog', () {
      testWidgets('returns true on confirm', (tester) async {
        // Arrange
        bool? result;

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: ElevatedButton(
                    onPressed: () async {
                      result = await AlhaiDialog.confirm(
                        context: context,
                        title: 'Confirm?',
                        confirmText: 'Yes',
                        cancelText: 'No',
                      );
                    },
                    child: const Text('Show'),
                  ),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Show'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Yes'));
        await tester.pumpAndSettle();

        // Assert
        expect(result, isTrue);
      });

      testWidgets('returns false on cancel', (tester) async {
        // Arrange
        bool? result;

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: ElevatedButton(
                    onPressed: () async {
                      result = await AlhaiDialog.confirm(
                        context: context,
                        title: 'Confirm?',
                        confirmText: 'Yes',
                        cancelText: 'No',
                      );
                    },
                    child: const Text('Show'),
                  ),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Show'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('No'));
        await tester.pumpAndSettle();

        // Assert
        expect(result, isFalse);
      });
    });

    group('Info Dialog', () {
      testWidgets('renders info dialog with OK button', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: ElevatedButton(
                    onPressed: () {
                      AlhaiDialog.info(
                        context: context,
                        title: 'Information',
                        message: 'This is an info message',
                        okText: 'OK',
                      );
                    },
                    child: const Text('Show'),
                  ),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Show'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Information'), findsOneWidget);
        expect(find.text('OK'), findsOneWidget);
      });
    });

    group('Destructive Dialog', () {
      testWidgets('renders destructive dialog with warning style', (
        tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: ElevatedButton(
                    onPressed: () {
                      AlhaiDialog.destructive(
                        context: context,
                        title: 'Delete Item?',
                        message: 'This cannot be undone',
                        destructText: 'Delete',
                        cancelText: 'Keep',
                      );
                    },
                    child: const Text('Show'),
                  ),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Show'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Delete Item?'), findsOneWidget);
        expect(find.text('Delete'), findsOneWidget);
        expect(find.text('Keep'), findsOneWidget);
      });
    });
  });
}
