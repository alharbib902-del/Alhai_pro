import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('AlhaiBottomNavBar', () {
    testWidgets('renders with required items', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AlhaiBottomNavBar(
            items: const [
              AlhaiBottomNavItem(icon: Icons.home, label: 'Home'),
              AlhaiBottomNavItem(icon: Icons.settings, label: 'Settings'),
            ],
            currentIndex: 0,
          ),
        ),
      );

      expect(find.byType(AlhaiBottomNavBar), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('shows correct number of items', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AlhaiBottomNavBar(
            items: const [
              AlhaiBottomNavItem(icon: Icons.home, label: 'Home'),
              AlhaiBottomNavItem(icon: Icons.search, label: 'Search'),
              AlhaiBottomNavItem(icon: Icons.settings, label: 'Settings'),
            ],
            currentIndex: 0,
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('calls onTap when item is tapped', (tester) async {
      int? tappedIndex;
      await tester.pumpWidget(
        createTestWidget(
          AlhaiBottomNavBar(
            items: const [
              AlhaiBottomNavItem(icon: Icons.home, label: 'Home'),
              AlhaiBottomNavItem(icon: Icons.settings, label: 'Settings'),
            ],
            currentIndex: 0,
            onTap: (index) => tappedIndex = index,
          ),
        ),
      );

      await tester.tap(find.text('Settings'));
      await tester.pump();

      expect(tappedIndex, 1);
    });

    testWidgets('does not call onTap when disabled', (tester) async {
      int? tappedIndex;
      await tester.pumpWidget(
        createTestWidget(
          AlhaiBottomNavBar(
            items: const [
              AlhaiBottomNavItem(icon: Icons.home, label: 'Home'),
              AlhaiBottomNavItem(icon: Icons.settings, label: 'Settings'),
            ],
            currentIndex: 0,
            onTap: (index) => tappedIndex = index,
            enabled: false,
          ),
        ),
      );

      await tester.tap(find.text('Settings'));
      await tester.pump();

      expect(tappedIndex, isNull);
    });

    testWidgets('shows badge text', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AlhaiBottomNavBar(
            items: const [
              AlhaiBottomNavItem(icon: Icons.home, label: 'Home', badge: '5'),
              AlhaiBottomNavItem(icon: Icons.settings, label: 'Settings'),
            ],
            currentIndex: 0,
          ),
        ),
      );

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('shows badge dot when configured', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AlhaiBottomNavBar(
            items: const [
              AlhaiBottomNavItem(
                icon: Icons.home,
                label: 'Home',
                showBadgeDot: true,
              ),
              AlhaiBottomNavItem(icon: Icons.settings, label: 'Settings'),
            ],
            currentIndex: 0,
          ),
        ),
      );

      expect(find.byType(AlhaiBottomNavBar), findsOneWidget);
    });

    testWidgets('uses activeIcon when selected', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AlhaiBottomNavBar(
            items: const [
              AlhaiBottomNavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Home',
              ),
              AlhaiBottomNavItem(icon: Icons.settings, label: 'Settings'),
            ],
            currentIndex: 0,
          ),
        ),
      );

      expect(find.byIcon(Icons.home), findsOneWidget);
    });
  });
}
