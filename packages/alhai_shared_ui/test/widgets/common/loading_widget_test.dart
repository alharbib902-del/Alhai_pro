import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_shared_ui/src/widgets/common/loading_widget.dart';
import '../../helpers/shared_ui_test_helpers.dart';

void main() {
  group('LoadingWidget', () {
    testWidgets('should display CircularProgressIndicator', (tester) async {
      await tester.pumpWidget(createSimpleTestWidget(
        const LoadingWidget(),
      ));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should be centered', (tester) async {
      await tester.pumpWidget(createSimpleTestWidget(
        const LoadingWidget(),
      ));
      expect(find.byType(Center), findsWidgets);
    });
  });

  group('ShimmerList', () {
    testWidgets('should render with default item count', (tester) async {
      await tester.pumpWidget(createSimpleTestWidget(
        const ShimmerList(),
      ));
      // ShimmerList uses ListView.builder, should render
      expect(find.byType(ShimmerList), findsOneWidget);
    });

    testWidgets('should render with custom item count', (tester) async {
      await tester.pumpWidget(createSimpleTestWidget(
        const ShimmerList(itemCount: 3),
      ));
      expect(find.byType(ShimmerList), findsOneWidget);
    });
  });

  group('ShimmerGrid', () {
    testWidgets('should render with default values', (tester) async {
      await tester.pumpWidget(createSimpleTestWidget(
        const ShimmerGrid(),
      ));
      expect(find.byType(ShimmerGrid), findsOneWidget);
    });

    testWidgets('should render with custom crossAxisCount', (tester) async {
      await tester.pumpWidget(createSimpleTestWidget(
        const ShimmerGrid(crossAxisCount: 2),
      ));
      expect(find.byType(ShimmerGrid), findsOneWidget);
    });
  });

  group('ShimmerCard', () {
    testWidgets('should render with default values', (tester) async {
      await tester.pumpWidget(createSimpleTestWidget(
        const ShimmerCard(),
      ));
      expect(find.byType(ShimmerCard), findsOneWidget);
    });

    testWidgets('should render with custom dimensions', (tester) async {
      await tester.pumpWidget(createSimpleTestWidget(
        const ShimmerCard(width: 200, height: 150),
      ));
      expect(find.byType(ShimmerCard), findsOneWidget);
    });
  });
}
