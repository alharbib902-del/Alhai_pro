import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_shared_ui/src/widgets/dashboard/quick_action_grid.dart';
import 'package:alhai_design_system/alhai_design_system.dart' show AppColors;
import '../../helpers/shared_ui_test_helpers.dart';

void main() {
  group('QuickAction', () {
    test('stores properties correctly', () {
      final action = QuickAction(
        id: 'test',
        title: 'Test',
        icon: Icons.add,
        color: Colors.blue,
        badge: '3',
      );
      expect(action.id, 'test');
      expect(action.title, 'Test');
      expect(action.icon, Icons.add);
      expect(action.badge, '3');
      expect(action.isPrimary, isFalse);
    });
  });

  group('QuickActionButton', () {
    testWidgets('renders action title', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          QuickActionButton(
            action: QuickAction(
              id: 'sale',
              title: 'New Sale',
              icon: Icons.point_of_sale,
              color: AppColors.primary,
            ),
          ),
        ),
      );
      expect(find.text('New Sale'), findsOneWidget);
      expect(find.byIcon(Icons.point_of_sale), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        createSimpleTestWidget(
          QuickActionButton(
            action: QuickAction(
              id: 'test',
              title: 'Tap Me',
              icon: Icons.add,
              color: Colors.blue,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );
      // Tap on the GestureDetector area
      await tester.tap(find.text('Tap Me'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });

    testWidgets('renders badge when provided', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          QuickActionButton(
            action: QuickAction(
              id: 'inv',
              title: 'Inventory',
              icon: Icons.inventory,
              color: Colors.green,
              badge: '5',
            ),
          ),
        ),
      );
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('renders primary style', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          QuickActionButton(
            action: QuickAction(
              id: 'primary',
              title: 'Primary',
              icon: Icons.star,
              color: Colors.blue,
              isPrimary: true,
            ),
          ),
        ),
      );
      expect(find.text('Primary'), findsOneWidget);
    });

    testWidgets('renders compact mode', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          QuickActionButton(
            compact: true,
            action: QuickAction(
              id: 'compact',
              title: 'Compact',
              icon: Icons.add,
              color: Colors.blue,
            ),
          ),
        ),
      );
      expect(find.text('Compact'), findsOneWidget);
    });
  });

  group('QuickActionGrid', () {
    final actions = [
      QuickAction(
        id: 'a1',
        title: 'Action 1',
        icon: Icons.add,
        color: Colors.blue,
      ),
      QuickAction(
        id: 'a2',
        title: 'Action 2',
        icon: Icons.edit,
        color: Colors.green,
      ),
    ];

    testWidgets('renders all actions', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          QuickActionGrid(actions: actions, crossAxisCount: 2),
        ),
      );
      expect(find.text('Action 1'), findsOneWidget);
      expect(find.text('Action 2'), findsOneWidget);
    });
  });

  group('QuickActionRow', () {
    final actions = [
      QuickAction(
        id: 'r1',
        title: 'Row 1',
        icon: Icons.add,
        color: Colors.blue,
      ),
      QuickAction(
        id: 'r2',
        title: 'Row 2',
        icon: Icons.edit,
        color: Colors.green,
      ),
    ];

    testWidgets('renders actions in a row', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(QuickActionRow(actions: actions)),
      );
      expect(find.text('Row 1'), findsOneWidget);
      expect(find.text('Row 2'), findsOneWidget);
    });
  });
}
