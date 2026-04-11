import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('AlhaiTabs', () {
    testWidgets('renders tab labels and views', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          SizedBox(
            height: 400,
            child: AlhaiTabs(
              tabs: const [
                AlhaiTabItem(label: 'Tab 1'),
                AlhaiTabItem(label: 'Tab 2'),
              ],
              views: const [Text('View 1'), Text('View 2')],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tab 1'), findsOneWidget);
      expect(find.text('Tab 2'), findsOneWidget);
      expect(find.text('View 1'), findsOneWidget);
    });

    testWidgets('switches view when tab is tapped', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          SizedBox(
            height: 400,
            child: AlhaiTabs(
              tabs: const [
                AlhaiTabItem(label: 'Tab 1'),
                AlhaiTabItem(label: 'Tab 2'),
              ],
              views: const [Text('View 1'), Text('View 2')],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tab 2'));
      await tester.pumpAndSettle();

      expect(find.text('View 2'), findsOneWidget);
    });

    testWidgets('shows icon in tab when provided', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          SizedBox(
            height: 400,
            child: AlhaiTabs(
              tabs: const [
                AlhaiTabItem(label: 'Home', icon: Icon(Icons.home)),
                AlhaiTabItem(label: 'Settings', icon: Icon(Icons.settings)),
              ],
              views: const [Text('Home View'), Text('Settings View')],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('works with fixed viewHeight', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          SingleChildScrollView(
            child: AlhaiTabs(
              tabs: const [
                AlhaiTabItem(label: 'Tab 1'),
                AlhaiTabItem(label: 'Tab 2'),
              ],
              views: const [Text('View 1'), Text('View 2')],
              viewHeight: 300,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('View 1'), findsOneWidget);
    });

    testWidgets('calls onTap callback', (tester) async {
      int? tappedIndex;
      await tester.pumpWidget(
        createTestWidget(
          SizedBox(
            height: 400,
            child: AlhaiTabs(
              tabs: const [
                AlhaiTabItem(label: 'Tab 1'),
                AlhaiTabItem(label: 'Tab 2'),
              ],
              views: const [Text('View 1'), Text('View 2')],
              onTap: (index) => tappedIndex = index,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tab 2'));
      await tester.pumpAndSettle();

      expect(tappedIndex, 1);
    });

    test('AlhaiTabItem creates correctly', () {
      const item = AlhaiTabItem(label: 'Test');
      expect(item.label, 'Test');
      expect(item.icon, isNull);
      expect(item.badge, isNull);
    });
  });
}
