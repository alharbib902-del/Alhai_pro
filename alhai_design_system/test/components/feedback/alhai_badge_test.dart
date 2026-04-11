import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('AlhaiBadge', () {
    testWidgets('renders count badge', (tester) async {
      await tester.pumpWidget(createTestWidget(const AlhaiBadge(count: 5)));

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('shows 99+ for count over max', (tester) async {
      await tester.pumpWidget(createTestWidget(const AlhaiBadge(count: 150)));

      expect(find.text('99+'), findsOneWidget);
    });

    testWidgets('custom maxCount is respected', (tester) async {
      await tester.pumpWidget(
        createTestWidget(const AlhaiBadge(count: 50, maxCount: 49)),
      );

      expect(find.text('49+'), findsOneWidget);
    });

    testWidgets('hides when count is 0', (tester) async {
      await tester.pumpWidget(
        createTestWidget(const AlhaiBadge(count: 0, child: Icon(Icons.mail))),
      );

      // Should show the child but not the badge number
      expect(find.text('0'), findsNothing);
      expect(find.byIcon(Icons.mail), findsOneWidget);
    });

    testWidgets('hides when show is false', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const AlhaiBadge(count: 5, show: false, child: Icon(Icons.mail)),
        ),
      );

      expect(find.text('5'), findsNothing);
      expect(find.byIcon(Icons.mail), findsOneWidget);
    });

    testWidgets('renders dot badge with no count', (tester) async {
      await tester.pumpWidget(
        createTestWidget(AlhaiBadge.dot(child: const Icon(Icons.mail))),
      );

      // Should render as a container with circle shape (dot badge)
      expect(find.byType(AlhaiBadge), findsOneWidget);
      expect(find.byIcon(Icons.mail), findsOneWidget);
    });

    testWidgets('renders as Stack when child is present', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const AlhaiBadge(count: 3, child: Icon(Icons.notifications)),
        ),
      );

      expect(find.byType(Stack), findsAtLeast(1));
      expect(find.byIcon(Icons.notifications), findsOneWidget);
    });

    testWidgets('renders standalone when no child', (tester) async {
      await tester.pumpWidget(createTestWidget(const AlhaiBadge(count: 7)));

      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('count factory sets show based on count', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AlhaiBadge.count(count: 3, child: const Icon(Icons.mail)),
        ),
      );

      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('count factory hides when count is 0', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AlhaiBadge.count(count: 0, child: const Icon(Icons.mail)),
        ),
      );

      expect(find.text('0'), findsNothing);
    });

    group('size variants', () {
      test('AlhaiBadgeSize.small has correct dot size', () {
        expect(AlhaiBadgeSize.small.dotSize, 6);
      });

      test('AlhaiBadgeSize.medium has correct dot size', () {
        expect(AlhaiBadgeSize.medium.dotSize, 8);
      });

      test('AlhaiBadgeSize.large has correct dot size', () {
        expect(AlhaiBadgeSize.large.dotSize, 10);
      });

      test('sizes increase from small to large', () {
        expect(
          AlhaiBadgeSize.large.minWidth,
          greaterThan(AlhaiBadgeSize.medium.minWidth),
        );
        expect(
          AlhaiBadgeSize.medium.minWidth,
          greaterThan(AlhaiBadgeSize.small.minWidth),
        );
      });

      testWidgets('renders small size badge', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            AlhaiBadge.count(
              count: 3,
              size: AlhaiBadgeSize.small,
              child: const Icon(Icons.inbox),
            ),
          ),
        );

        expect(find.text('3'), findsOneWidget);
      });

      testWidgets('renders large size badge', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            AlhaiBadge.count(
              count: 10,
              size: AlhaiBadgeSize.large,
              child: const Icon(Icons.inbox),
            ),
          ),
        );

        expect(find.text('10'), findsOneWidget);
      });
    });

    group('custom colors', () {
      testWidgets('applies custom background color', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            AlhaiBadge.count(
              count: 7,
              backgroundColor: Colors.blue,
              child: const Icon(Icons.inbox),
            ),
          ),
        );

        expect(find.text('7'), findsOneWidget);
      });

      testWidgets('applies custom text color', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            AlhaiBadge.count(
              count: 9,
              textColor: Colors.yellow,
              child: const Icon(Icons.inbox),
            ),
          ),
        );

        expect(find.text('9'), findsOneWidget);
      });
    });

    testWidgets('dot badge hides when show is false', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AlhaiBadge.dot(show: false, child: const Icon(Icons.notifications)),
        ),
      );

      expect(find.byIcon(Icons.notifications), findsOneWidget);
    });
  });
}
