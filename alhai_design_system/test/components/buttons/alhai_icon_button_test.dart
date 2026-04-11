import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('AlhaiIconButton', () {
    testWidgets('renders with icon', (tester) async {
      await tester.pumpWidget(
        createTestWidget(AlhaiIconButton(icon: Icons.add, onPressed: () {})),
      );

      expect(find.byType(AlhaiIconButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        createTestWidget(
          AlhaiIconButton(icon: Icons.add, onPressed: () => pressed = true),
        ),
      );

      await tester.tap(find.byType(AlhaiIconButton));
      await tester.pump();

      expect(pressed, isTrue);
    });

    testWidgets('is disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const AlhaiIconButton(icon: Icons.add, onPressed: null),
        ),
      );

      // InkWell should be present but onTap should be null
      final inkWell = tester.widget<InkWell>(find.byType(InkWell));
      expect(inkWell.onTap, isNull);
    });

    testWidgets('shows loading indicator when isLoading', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AlhaiIconButton(icon: Icons.add, isLoading: true, onPressed: () {}),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // The icon should not be visible when loading
      expect(find.byIcon(Icons.add), findsNothing);
    });

    testWidgets('shows tooltip when provided', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AlhaiIconButton(
            icon: Icons.add,
            tooltip: 'Add item',
            onPressed: () {},
          ),
        ),
      );

      expect(find.byType(Tooltip), findsOneWidget);
      final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
      expect(tooltip.message, 'Add item');
    });

    testWidgets('shows badge count', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AlhaiIconButton(
            icon: Icons.notifications,
            badgeCount: 5,
            onPressed: () {},
          ),
        ),
      );

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('shows 99+ for large badge count', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AlhaiIconButton(
            icon: Icons.notifications,
            badgeCount: 150,
            onPressed: () {},
          ),
        ),
      );

      expect(find.text('99+'), findsOneWidget);
    });

    testWidgets('shows dot badge when showBadge is true', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AlhaiIconButton(
            icon: Icons.notifications,
            showBadge: true,
            onPressed: () {},
          ),
        ),
      );

      // The badge dot is rendered as a Container with circle shape
      expect(find.byType(AlhaiIconButton), findsOneWidget);
      // Stack should be present for badge overlay
      expect(find.byType(Stack), findsAtLeast(1));
    });

    testWidgets('does not call onPressed when loading', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        createTestWidget(
          AlhaiIconButton(
            icon: Icons.add,
            isLoading: true,
            onPressed: () => pressed = true,
          ),
        ),
      );

      await tester.tap(find.byType(AlhaiIconButton));
      await tester.pump();

      expect(pressed, isFalse);
    });
  });
}
