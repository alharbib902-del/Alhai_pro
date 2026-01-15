import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_design_system/src/components/navigation/alhai_app_bar.dart';

void main() {
  group('AlhaiAppBar', () {
    group('Rendering', () {
      testWidgets('renders with title text', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: const AlhaiAppBar(
                title: 'Test Title',
              ),
              body: const SizedBox(),
            ),
          ),
        );

        // Assert
        expect(find.text('Test Title'), findsOneWidget);
      });

      testWidgets('renders with subtitle', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: const AlhaiAppBar(
                title: 'Main Title',
                subtitle: 'Subtitle Text',
              ),
              body: const SizedBox(),
            ),
          ),
        );

        // Assert
        expect(find.text('Main Title'), findsOneWidget);
        expect(find.text('Subtitle Text'), findsOneWidget);
      });

      testWidgets('renders actions', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: AlhaiAppBar(
                title: 'With Actions',
                actions: [
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {},
                  ),
                ],
              ),
              body: const SizedBox(),
            ),
          ),
        );

        // Assert
        expect(find.byIcon(Icons.settings), findsOneWidget);
      });
    });

    group('Search Mode', () {
      testWidgets('shows search button when enableSearch is true', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: AlhaiAppBar(
                title: 'Searchable',
                enableSearch: true,
                onSearch: (query) {},
              ),
              body: const SizedBox(),
            ),
          ),
        );

        // Assert
        expect(find.byIcon(Icons.search), findsOneWidget);
      });

      testWidgets('factory search creates searchable app bar', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: AlhaiAppBar.search(
                title: 'Search Title',
                onSearch: (query) {},
              ),
              body: const SizedBox(),
            ),
          ),
        );

        // Assert
        expect(find.text('Search Title'), findsOneWidget);
        expect(find.byIcon(Icons.search), findsOneWidget);
      });

      testWidgets('factory simple creates simple app bar', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: AlhaiAppBar.simple(
                title: 'Simple Title',
              ),
              body: const SizedBox(),
            ),
          ),
        );

        // Assert
        expect(find.text('Simple Title'), findsOneWidget);
      });
    });

    group('Styling', () {
      testWidgets('applies custom background color', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: const AlhaiAppBar(
                title: 'Blue AppBar',
                backgroundColor: Colors.blue,
              ),
              body: const SizedBox(),
            ),
          ),
        );

        // Assert
        expect(find.text('Blue AppBar'), findsOneWidget);
      });

      testWidgets('applies center title', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: const AlhaiAppBar(
                title: 'Centered',
                centerTitle: true,
              ),
              body: const SizedBox(),
            ),
          ),
        );

        // Assert
        expect(find.text('Centered'), findsOneWidget);
      });
    });
  });
}
