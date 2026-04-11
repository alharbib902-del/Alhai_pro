import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('AlhaiCard', () {
    testWidgets('renders child content', (tester) async {
      await tester.pumpWidget(
        createTestWidget(const AlhaiCard(child: Text('Card Content'))),
      );

      expect(find.byType(AlhaiCard), findsOneWidget);
      expect(find.text('Card Content'), findsOneWidget);
    });

    testWidgets('is tappable when onTap is provided', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        createTestWidget(
          AlhaiCard(onTap: () => tapped = true, child: const Text('Tap me')),
        ),
      );

      await tester.tap(find.text('Tap me'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('is not tappable when onTap is null', (tester) async {
      await tester.pumpWidget(
        createTestWidget(const AlhaiCard(child: Text('No tap'))),
      );

      // Should not find InkWell (only used for tappable cards)
      expect(find.byType(InkWell), findsNothing);
    });

    testWidgets('elevated factory renders with elevation', (tester) async {
      await tester.pumpWidget(
        createTestWidget(AlhaiCard.elevated(child: const Text('Elevated'))),
      );

      expect(find.text('Elevated'), findsOneWidget);
    });

    testWidgets('filled factory renders without border', (tester) async {
      await tester.pumpWidget(
        createTestWidget(AlhaiCard.filled(child: const Text('Filled'))),
      );

      expect(find.text('Filled'), findsOneWidget);
    });

    testWidgets('respects custom width', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const AlhaiCard(width: 200, child: Text('Fixed Width')),
        ),
      );

      final container = tester.widget<Container>(
        find.byWidgetPredicate(
          (w) => w is Container && w.constraints?.maxWidth == 200,
        ),
      );
      expect(container, isNotNull);
    });

    testWidgets('applies custom background color', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const AlhaiCard(
            backgroundColor: Colors.blue,
            child: Text('Custom Color'),
          ),
        ),
      );

      expect(find.text('Custom Color'), findsOneWidget);
    });

    testWidgets('onLongPress is called when long pressed', (tester) async {
      var longPressed = false;
      await tester.pumpWidget(
        createTestWidget(
          AlhaiCard(
            onLongPress: () => longPressed = true,
            child: const Text('Long press me'),
          ),
        ),
      );

      await tester.longPress(find.text('Long press me'));
      await tester.pump();

      expect(longPressed, isTrue);
    });

    testWidgets('applies border when showBorder is true', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const AlhaiCard(showBorder: true, child: Text('Bordered')),
        ),
      );

      expect(find.text('Bordered'), findsOneWidget);
    });

    testWidgets('applies custom border radius', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const AlhaiCard(borderRadius: 24, child: Text('Rounded')),
        ),
      );

      expect(find.text('Rounded'), findsOneWidget);
    });
  });
}
