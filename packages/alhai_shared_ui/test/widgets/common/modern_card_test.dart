import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_shared_ui/src/widgets/common/modern_card.dart';
import '../../helpers/shared_ui_test_helpers.dart';

void main() {
  group('ModernCard', () {
    testWidgets('renders child', (tester) async {
      await tester.pumpWidget(
        createTestWidget(const ModernCard(child: Text('Card Content'))),
      );
      expect(find.text('Card Content'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        createTestWidget(
          ModernCard(child: const Text('Tap Me'), onTap: () => tapped = true),
        ),
      );
      await tester.tap(find.text('Tap Me'));
      expect(tapped, isTrue);
    });

    testWidgets('renders normal variant', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const ModernCard(
            variant: ModernCardVariant.normal,
            child: Text('Normal'),
          ),
        ),
      );
      expect(find.text('Normal'), findsOneWidget);
    });

    testWidgets('renders flat variant', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const ModernCard(
            variant: ModernCardVariant.flat,
            child: Text('Flat'),
          ),
        ),
      );
      expect(find.text('Flat'), findsOneWidget);
    });

    testWidgets('renders elevated variant', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const ModernCard(
            variant: ModernCardVariant.elevated,
            child: Text('Elevated'),
          ),
        ),
      );
      expect(find.text('Elevated'), findsOneWidget);
    });

    testWidgets('renders gradient variant', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          ModernCard.gradient(
            gradient: const LinearGradient(
              colors: [Colors.blue, Colors.purple],
            ),
            child: const Text('Gradient'),
          ),
        ),
      );
      expect(find.text('Gradient'), findsOneWidget);
    });

    testWidgets('renders glass variant', (tester) async {
      await tester.pumpWidget(
        createTestWidget(ModernCard.glass(child: const Text('Glass'))),
      );
      expect(find.text('Glass'), findsOneWidget);
    });

    testWidgets('stat factory renders title and value', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          ModernCard.stat(
            title: 'Revenue',
            value: '1,200',
            icon: Icons.attach_money,
          ),
        ),
      );
      expect(find.text('Revenue'), findsOneWidget);
      expect(find.text('1,200'), findsOneWidget);
    });

    testWidgets('stat factory shows change indicator', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          ModernCard.stat(
            title: 'Sales',
            value: '50',
            icon: Icons.shopping_cart,
            change: 15.0,
            changeLabel: 'vs yesterday',
          ),
        ),
      );
      expect(find.text('Sales'), findsOneWidget);
      expect(find.text('vs yesterday'), findsOneWidget);
    });

    testWidgets('renders with custom width and height', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const ModernCard(width: 200, height: 100, child: Text('Sized')),
        ),
      );
      expect(find.text('Sized'), findsOneWidget);
    });

    testWidgets('renders with border', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const ModernCard(hasBorder: true, child: Text('Bordered')),
        ),
      );
      expect(find.text('Bordered'), findsOneWidget);
    });
  });
}
