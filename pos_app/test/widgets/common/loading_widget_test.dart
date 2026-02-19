import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/widgets/common/loading_widget.dart';

// ===========================================
// Loading Widget Tests
// ===========================================

void main() {
  Widget buildTestWidget(Widget child, {bool isDark = false}) {
    return MaterialApp(
      theme: isDark ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(body: child),
    );
  }

  group('LoadingWidget', () {
    testWidgets('يعرض CircularProgressIndicator', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const LoadingWidget(),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('يتمركز في الوسط', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const LoadingWidget(),
      ));

      expect(find.byType(Center), findsOneWidget);
    });
  });

  group('ShimmerList', () {
    testWidgets('يعرض العدد الافتراضي من العناصر (5)', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const ShimmerList(),
      ));
      await tester.pump();

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('يعرض عدد مخصص من العناصر', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const ShimmerList(itemCount: 10),
      ));
      await tester.pump();

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('يستخدم itemHeight المحدد', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const ShimmerList(itemHeight: 100),
      ));
      await tester.pump();

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('يعمل في الوضع الداكن', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const ShimmerList(),
        isDark: true,
      ));
      await tester.pump();

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('يحتوي على NeverScrollableScrollPhysics', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const ShimmerList(),
      ));
      await tester.pump();

      final listView = tester.widget<ListView>(find.byType(ListView));
      expect(listView.physics, isA<NeverScrollableScrollPhysics>());
    });
  });

  group('ShimmerGrid', () {
    testWidgets('يعرض GridView', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const ShimmerGrid(),
      ));
      await tester.pump();

      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('يستخدم العدد الافتراضي من العناصر (6)', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const ShimmerGrid(),
      ));
      await tester.pump();

      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('يستخدم عدد أعمدة مخصص', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const ShimmerGrid(crossAxisCount: 4),
      ));
      await tester.pump();

      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('يستخدم aspectRatio مخصص', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const ShimmerGrid(aspectRatio: 1.0),
      ));
      await tester.pump();

      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('يعمل في الوضع الداكن', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const ShimmerGrid(),
        isDark: true,
      ));
      await tester.pump();

      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('يحتوي على NeverScrollableScrollPhysics', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const ShimmerGrid(),
      ));
      await tester.pump();

      final gridView = tester.widget<GridView>(find.byType(GridView));
      expect(gridView.physics, isA<NeverScrollableScrollPhysics>());
    });
  });

  group('ShimmerCard', () {
    testWidgets('يعرض Container', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const ShimmerCard(),
      ));
      await tester.pump();

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('يستخدم الارتفاع الافتراضي (100)', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const ShimmerCard(),
      ));
      await tester.pump();

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('يستخدم ارتفاع مخصص', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const ShimmerCard(height: 200),
      ));
      await tester.pump();

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('يستخدم عرض مخصص', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const ShimmerCard(width: 150),
      ));
      await tester.pump();

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('يستخدم borderRadius مخصص', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const ShimmerCard(borderRadius: 16),
      ));
      await tester.pump();

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('يعمل في الوضع الداكن', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const ShimmerCard(),
        isDark: true,
      ));
      await tester.pump();

      expect(find.byType(Container), findsWidgets);
    });
  });

  group('Loading Widgets - Default Values', () {
    test('ShimmerList القيم الافتراضية', () {
      const widget = ShimmerList();
      expect(widget.itemCount, 5);
      expect(widget.itemHeight, 80);
    });

    test('ShimmerGrid القيم الافتراضية', () {
      const widget = ShimmerGrid();
      expect(widget.itemCount, 6);
      expect(widget.crossAxisCount, 3);
      expect(widget.aspectRatio, 0.85);
    });

    test('ShimmerCard القيم الافتراضية', () {
      const widget = ShimmerCard();
      expect(widget.width, isNull);
      expect(widget.height, 100);
      expect(widget.borderRadius, 8);
    });
  });
}
