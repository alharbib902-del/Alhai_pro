import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_shared_ui/src/widgets/common/shimmer_loading.dart';
import '../../helpers/shared_ui_test_helpers.dart';

void main() {
  group('ShimmerLoading', () {
    testWidgets('renders child when not loading', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          const ShimmerLoading(
            isLoading: false,
            child: Text('Loaded Content'),
          ),
        ),
      );
      expect(find.text('Loaded Content'), findsOneWidget);
    });

    testWidgets('renders shimmer effect when loading', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          const ShimmerLoading(
            isLoading: true,
            child: SizedBox(width: 100, height: 20),
          ),
        ),
      );
      expect(find.byType(ShimmerLoading), findsOneWidget);
      expect(find.byType(ShaderMask), findsOneWidget);
    });

    testWidgets('switches from loading to content', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          const ShimmerLoading(
            isLoading: true,
            child: Text('Content'),
          ),
        ),
      );
      expect(find.byType(ShaderMask), findsOneWidget);

      await tester.pumpWidget(
        createSimpleTestWidget(
          const ShimmerLoading(
            isLoading: false,
            child: Text('Content'),
          ),
        ),
      );
      expect(find.text('Content'), findsOneWidget);
      expect(find.byType(ShaderMask), findsNothing);
    });
  });

  group('ShimmerPlaceholder', () {
    testWidgets('renders with default dimensions', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(const ShimmerPlaceholder()),
      );
      expect(find.byType(ShimmerPlaceholder), findsOneWidget);
    });

    testWidgets('renders circular variant', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(ShimmerPlaceholder.circular(size: 48)),
      );
      expect(find.byType(ShimmerPlaceholder), findsOneWidget);
    });

    testWidgets('renders text variant', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(ShimmerPlaceholder.text(width: 200)),
      );
      expect(find.byType(ShimmerPlaceholder), findsOneWidget);
    });

    testWidgets('renders card variant', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(ShimmerPlaceholder.card()),
      );
      expect(find.byType(ShimmerPlaceholder), findsOneWidget);
    });

    testWidgets('renders with custom margin', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          const ShimmerPlaceholder(
            margin: EdgeInsets.all(8),
            width: 100,
            height: 20,
          ),
        ),
      );
      expect(find.byType(ShimmerPlaceholder), findsOneWidget);
    });
  });

  group('ShimmerCard', () {
    testWidgets('renders with default height', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(const ShimmerCard()),
      );
      expect(find.byType(ShimmerCard), findsOneWidget);
    });

    testWidgets('renders with custom height', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(const ShimmerCard(height: 200)),
      );
      expect(find.byType(ShimmerCard), findsOneWidget);
    });
  });

  group('ShimmerStats', () {
    testWidgets('renders with default count', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(const ShimmerStats()),
      );
      expect(find.byType(ShimmerStats), findsOneWidget);
    });

    testWidgets('renders narrow layout', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          const ShimmerStats(isWide: false, count: 2),
        ),
      );
      expect(find.byType(ShimmerStats), findsOneWidget);
    });
  });

  group('ShimmerTopBar', () {
    testWidgets('renders', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(const ShimmerTopBar()),
      );
      expect(find.byType(ShimmerTopBar), findsOneWidget);
    });
  });
}
