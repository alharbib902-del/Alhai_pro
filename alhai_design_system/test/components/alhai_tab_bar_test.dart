import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('AlhaiTabBar', () {
    testWidgets('renders all tab labels', (tester) async {
      await tester.pumpWidget(createTestWidget(
        AlhaiTabBar(
          tabs: const [
            AlhaiTabBarItem(label: 'Tab 1'),
            AlhaiTabBarItem(label: 'Tab 2'),
            AlhaiTabBarItem(label: 'Tab 3'),
          ],
          currentIndex: 0,
          onChanged: (_) {},
        ),
      ));

      expect(find.text('Tab 1'), findsOneWidget);
      expect(find.text('Tab 2'), findsOneWidget);
      expect(find.text('Tab 3'), findsOneWidget);
    });

    testWidgets('calls onChanged when tab is tapped', (tester) async {
      int? tappedIndex;
      await tester.pumpWidget(createTestWidget(
        AlhaiTabBar(
          tabs: const [
            AlhaiTabBarItem(label: 'Tab 1'),
            AlhaiTabBarItem(label: 'Tab 2'),
          ],
          currentIndex: 0,
          onChanged: (index) => tappedIndex = index,
        ),
      ));

      await tester.tap(find.text('Tab 2'));
      await tester.pump();

      expect(tappedIndex, 1);
    });

    testWidgets('shows icon when provided', (tester) async {
      await tester.pumpWidget(createTestWidget(
        AlhaiTabBar(
          tabs: const [
            AlhaiTabBarItem(label: 'Home', icon: Icons.home),
            AlhaiTabBarItem(label: 'Search', icon: Icons.search),
          ],
          currentIndex: 0,
          onChanged: (_) {},
        ),
      ));

      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('shows badge text', (tester) async {
      await tester.pumpWidget(createTestWidget(
        AlhaiTabBar(
          tabs: const [
            AlhaiTabBarItem(label: 'Inbox', badge: '3'),
            AlhaiTabBarItem(label: 'Sent'),
          ],
          currentIndex: 0,
          onChanged: (_) {},
        ),
      ));

      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('shows subtitle when provided', (tester) async {
      await tester.pumpWidget(createTestWidget(
        AlhaiTabBar(
          tabs: const [
            AlhaiTabBarItem(label: 'Tab 1', subtitle: 'Details'),
          ],
          currentIndex: 0,
          onChanged: (_) {},
        ),
      ));

      expect(find.text('Details'), findsOneWidget);
    });

    test('AlhaiTabBarVariant has expected values', () {
      expect(AlhaiTabBarVariant.values.length, 2);
      expect(AlhaiTabBarVariant.values, contains(AlhaiTabBarVariant.fixed));
      expect(
          AlhaiTabBarVariant.values, contains(AlhaiTabBarVariant.scrollable));
    });

    test('AlhaiTabBarItem creates correctly', () {
      const item = AlhaiTabBarItem(
        label: 'Test',
        icon: Icons.star,
        badge: '5',
      );

      expect(item.label, 'Test');
      expect(item.icon, Icons.star);
      expect(item.badge, '5');
      expect(item.enabled, isTrue);
    });
  });
}
