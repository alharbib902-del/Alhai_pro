import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_shared_ui/src/widgets/common/app_card.dart';
import '../../helpers/shared_ui_test_helpers.dart';

void main() {
  group('AppCard', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          const AppCard(child: Text('Card Content')),
        ),
      );
      expect(find.text('Card Content'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        createSimpleTestWidget(
          AppCard(child: const Text('Tap Me'), onTap: () => tapped = true),
        ),
      );
      await tester.tap(find.text('Tap Me'));
      expect(tapped, isTrue);
    });

    testWidgets('calls onLongPress when long pressed', (tester) async {
      var longPressed = false;
      await tester.pumpWidget(
        createSimpleTestWidget(
          AppCard(
            child: const Text('Hold Me'),
            onLongPress: () => longPressed = true,
          ),
        ),
      );
      await tester.longPress(find.text('Hold Me'));
      expect(longPressed, isTrue);
    });

    testWidgets('renders with custom padding', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          const AppCard(
            padding: EdgeInsets.all(32),
            child: Text('Padded'),
          ),
        ),
      );
      expect(find.text('Padded'), findsOneWidget);
    });

    testWidgets('renders with isSelected true', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          const AppCard(isSelected: true, child: Text('Selected')),
        ),
      );
      expect(find.text('Selected'), findsOneWidget);
    });

    testWidgets('renders cornerWidget when provided', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          const AppCard(
            cornerWidget: Icon(Icons.check),
            child: Text('With Corner'),
          ),
        ),
      );
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('renders with custom elevation', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          const AppCard(elevation: 4, child: Text('Elevated')),
        ),
      );
      expect(find.text('Elevated'), findsOneWidget);
    });
  });

  group('StatCard (from app_card)', () {
    testWidgets('renders title and value', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          const StatCard(
            title: 'Revenue',
            value: '1,000',
            icon: Icons.attach_money,
          ),
        ),
      );
      expect(find.text('Revenue'), findsOneWidget);
      expect(find.text('1,000'), findsOneWidget);
      expect(find.byIcon(Icons.attach_money), findsOneWidget);
    });

    testWidgets('shows positive change indicator', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          const StatCard(
            title: 'Revenue',
            value: '1,000',
            icon: Icons.attach_money,
            change: 12.5,
            changeLabel: 'vs last week',
          ),
        ),
      );
      expect(find.text('+12.5%'), findsOneWidget);
      expect(find.text('vs last week'), findsOneWidget);
      expect(find.byIcon(Icons.trending_up), findsOneWidget);
    });

    testWidgets('shows negative change indicator', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          const StatCard(
            title: 'Revenue',
            value: '500',
            icon: Icons.attach_money,
            change: -5.2,
          ),
        ),
      );
      expect(find.text('-5.2%'), findsOneWidget);
      expect(find.byIcon(Icons.trending_down), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        createSimpleTestWidget(
          StatCard(
            title: 'Revenue',
            value: '1,000',
            icon: Icons.attach_money,
            onTap: () => tapped = true,
          ),
        ),
      );
      await tester.tap(find.text('Revenue'));
      expect(tapped, isTrue);
    });
  });
}
