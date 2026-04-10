import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

void main() {
  group('AlhaiScaffold', () {
    testWidgets('renders body content', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AlhaiScaffold(
            body: Text('Body Content'),
          ),
        ),
      );

      expect(find.text('Body Content'), findsOneWidget);
    });

    testWidgets('renders with appBar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AlhaiScaffold(
            appBar: AppBar(title: const Text('Title')),
            body: const Text('Body'),
          ),
        ),
      );

      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Body'), findsOneWidget);
    });

    testWidgets('renders with bottomNavigationBar', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AlhaiScaffold(
            body: Text('Body'),
            bottomNavigationBar: BottomAppBar(
              child: Row(
                children: [Icon(Icons.home)],
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.home), findsOneWidget);
    });

    testWidgets('renders with FAB', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AlhaiScaffold(
            body: const Text('Body'),
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.add),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('fullScreen factory renders', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AlhaiScaffold.fullScreen(
            body: const Text('Full Screen'),
          ),
        ),
      );

      expect(find.text('Full Screen'), findsOneWidget);
    });

    testWidgets('renders scaffold under the hood', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AlhaiScaffold(
            body: Text('Content'),
          ),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
