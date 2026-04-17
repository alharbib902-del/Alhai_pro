import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_shared_ui/src/widgets/common/app_badge.dart';
import '../../helpers/shared_ui_test_helpers.dart';

void main() {
  group('AppBadge', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(const AppBadge(label: 'Active')),
      );
      expect(find.text('Active'), findsOneWidget);
    });

    testWidgets('renders with icon', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          const AppBadge(label: 'With Icon', icon: Icons.check),
        ),
      );
      expect(find.text('With Icon'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        createSimpleTestWidget(
          AppBadge(label: 'Tap Me', onTap: () => tapped = true),
        ),
      );
      await tester.tap(find.text('Tap Me'));
      expect(tapped, isTrue);
    });

    testWidgets('shows delete icon when onDelete provided', (tester) async {
      var deleted = false;
      await tester.pumpWidget(
        createSimpleTestWidget(
          AppBadge(label: 'Deletable', onDelete: () => deleted = true),
        ),
      );
      expect(find.byIcon(Icons.close), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close));
      expect(deleted, isTrue);
    });

    testWidgets('success factory renders correctly', (tester) async {
      await tester.pumpWidget(createSimpleTestWidget(AppBadge.success('Done')));
      expect(find.text('Done'), findsOneWidget);
    });

    testWidgets('warning factory renders correctly', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(AppBadge.warning('Caution')),
      );
      expect(find.text('Caution'), findsOneWidget);
    });

    testWidgets('error factory renders correctly', (tester) async {
      await tester.pumpWidget(createSimpleTestWidget(AppBadge.error('Failed')));
      expect(find.text('Failed'), findsOneWidget);
    });

    testWidgets('info factory renders correctly', (tester) async {
      await tester.pumpWidget(createSimpleTestWidget(AppBadge.info('Note')));
      expect(find.text('Note'), findsOneWidget);
    });

    testWidgets('renders small size correctly', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          const AppBadge(label: 'Small', size: AppBadgeSize.small),
        ),
      );
      expect(find.text('Small'), findsOneWidget);
    });

    testWidgets('renders large size correctly', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          const AppBadge(label: 'Large', size: AppBadgeSize.large),
        ),
      );
      expect(find.text('Large'), findsOneWidget);
    });

    testWidgets('renders outlined variant', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          const AppBadge(label: 'Outlined', variant: AppBadgeVariant.outlined),
        ),
      );
      expect(find.text('Outlined'), findsOneWidget);
    });
  });

  group('AppCountBadge', () {
    testWidgets('renders count', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(const AppCountBadge(count: 5)),
      );
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('hides when count is 0 and showZero is false', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(const AppCountBadge(count: 0)),
      );
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('shows when count is 0 and showZero is true', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(const AppCountBadge(count: 0, showZero: true)),
      );
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('caps at maxCount', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(const AppCountBadge(count: 150)),
      );
      expect(find.text('99+'), findsOneWidget);
    });

    testWidgets('shows exact count under maxCount', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(const AppCountBadge(count: 42)),
      );
      expect(find.text('42'), findsOneWidget);
    });
  });

  group('AppStatusBadge', () {
    testWidgets('renders active state', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          const AppStatusBadge(isActive: true, label: 'Online'),
        ),
      );
      expect(find.text('Online'), findsOneWidget);
    });

    testWidgets('renders inactive state', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          const AppStatusBadge(isActive: false, label: 'Offline'),
        ),
      );
      expect(find.text('Offline'), findsOneWidget);
    });

    testWidgets('hides label when showLabel is false', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          const AppStatusBadge(
            isActive: true,
            label: 'Hidden',
            showLabel: false,
          ),
        ),
      );
      expect(find.text('Hidden'), findsNothing);
    });
  });

  group('AppCategoryBadge', () {
    testWidgets('renders category name', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(const AppCategoryBadge(category: 'Electronics')),
      );
      expect(find.text('Electronics'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        createSimpleTestWidget(
          AppCategoryBadge(category: 'Food', onTap: () => tapped = true),
        ),
      );
      await tester.tap(find.text('Food'));
      expect(tapped, isTrue);
    });

    testWidgets('renders selected state', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          const AppCategoryBadge(category: 'Drinks', isSelected: true),
        ),
      );
      expect(find.text('Drinks'), findsOneWidget);
    });
  });
}
