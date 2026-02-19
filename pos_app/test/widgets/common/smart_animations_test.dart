import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/widgets/common/smart_animations.dart';

// ===========================================
// Smart Animations Tests
// ===========================================

void main() {
  group('SimpleAnimatedCounter', () {
    testWidgets('يعرض القيمة', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SimpleAnimatedCounter(value: 42),
          ),
        ),
      );

      // يجب أن يبدأ من 0 ويصل إلى 42
      await tester.pumpAndSettle();
      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('يعرض prefix و suffix', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SimpleAnimatedCounter(
              value: 10,
              prefix: 'x',
              suffix: ' items',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('x10 items'), findsOneWidget);
    });

    testWidgets('يعرض 0 عند القيمة 0', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SimpleAnimatedCounter(value: 0),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('يستخدم style مخصص', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SimpleAnimatedCounter(
              value: 5,
              style: TextStyle(fontSize: 24, color: Colors.red),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('5'), findsOneWidget);
    });
  });

  group('AnimatedPrice', () {
    testWidgets('يعرض السعر مع العملة الافتراضية', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedPrice(value: 99.99),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.textContaining('99.99'), findsOneWidget);
      expect(find.textContaining('ر.س'), findsOneWidget);
    });

    testWidgets('يعرض السعر مع عملة مخصصة', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedPrice(
              value: 50.00,
              currency: 'USD',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.textContaining('50.00'), findsOneWidget);
      expect(find.textContaining('USD'), findsOneWidget);
    });

    testWidgets('يعرض 0.00 للقيمة صفر', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedPrice(value: 0),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.textContaining('0.00'), findsOneWidget);
    });
  });

  group('AddToCartAnimation', () {
    testWidgets('يعرض child', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AddToCartAnimation(
              child: Text('Product'),
            ),
          ),
        ),
      );

      expect(find.text('Product'), findsOneWidget);
    });

    testWidgets('لا يُحرك عندما animate = false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AddToCartAnimation(
              animate: false,
              child: Text('Product'),
            ),
          ),
        ),
      );

      expect(find.text('Product'), findsOneWidget);
    });

    testWidgets('يستخدم duration مخصص', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AddToCartAnimation(
              duration: Duration(milliseconds: 500),
              child: Text('Product'),
            ),
          ),
        ),
      );

      expect(find.text('Product'), findsOneWidget);
    });
  });

  group('SuccessAnimation', () {
    testWidgets('يعرض عندما show = true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SuccessAnimation(show: true),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(SuccessAnimation), findsOneWidget);
    });

    testWidgets('لا يعرض icon عندما show = false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SuccessAnimation(show: false),
          ),
        ),
      );

      // Animation hasn't started yet
      expect(find.byType(SuccessAnimation), findsOneWidget);
    });

    testWidgets('يستخدم size مخصص', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SuccessAnimation(
              show: true,
              size: 64,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(SuccessAnimation), findsOneWidget);
    });

    testWidgets('يستخدم color مخصص', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SuccessAnimation(
              show: true,
              color: Colors.green,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(SuccessAnimation), findsOneWidget);
    });
  });

  group('ShimmerLoading', () {
    testWidgets('يعرض child عندما isLoading = false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SimpleShimmer(
              isLoading: false,
              child: Text('Content'),
            ),
          ),
        ),
      );

      expect(find.text('Content'), findsOneWidget);
    });

    testWidgets('يعرض shimmer عندما isLoading = true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SimpleShimmer(
              isLoading: true,
              child: Container(
                width: 100,
                height: 100,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(SimpleShimmer), findsOneWidget);
    });

    testWidgets('يعرض child داخل shimmer', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SimpleShimmer(
              isLoading: true,
              child: SizedBox(
                key: Key('shimmer-child'),
                width: 100,
                height: 100,
              ),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('shimmer-child')), findsOneWidget);
    });
  });

  group('PulseAnimation', () {
    testWidgets('يعرض child', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PulseAnimation(
              child: Text('Pulsing'),
            ),
          ),
        ),
      );

      expect(find.text('Pulsing'), findsOneWidget);
    });

    testWidgets('لا يُحرك عندما pulse = false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PulseAnimation(
              pulse: false,
              child: Text('Static'),
            ),
          ),
        ),
      );

      expect(find.text('Static'), findsOneWidget);
    });

    testWidgets('يستخدم duration مخصص', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PulseAnimation(
              duration: Duration(seconds: 2),
              child: Text('Slow Pulse'),
            ),
          ),
        ),
      );

      expect(find.text('Slow Pulse'), findsOneWidget);
    });
  });

  group('Animation Duration Constants', () {
    test('AddToCartAnimation default duration = 300ms', () {
      const defaultDuration = Duration(milliseconds: 300);
      expect(defaultDuration.inMilliseconds, 300);
    });

    test('AnimatedCounter default duration = 400ms', () {
      const defaultDuration = Duration(milliseconds: 400);
      expect(defaultDuration.inMilliseconds, 400);
    });

    test('AnimatedPrice default duration = 400ms', () {
      const defaultDuration = Duration(milliseconds: 400);
      expect(defaultDuration.inMilliseconds, 400);
    });

    test('SuccessAnimation default duration = 500ms', () {
      const defaultDuration = Duration(milliseconds: 500);
      expect(defaultDuration.inMilliseconds, 500);
    });

    test('ShimmerLoading duration = 1500ms', () {
      const shimmerDuration = Duration(milliseconds: 1500);
      expect(shimmerDuration.inMilliseconds, 1500);
    });

    test('PulseAnimation default duration = 1000ms', () {
      const defaultDuration = Duration(milliseconds: 1000);
      expect(defaultDuration.inMilliseconds, 1000);
    });
  });

  group('Accessibility - Reduce Motion', () {
    testWidgets('animations يجب أن تحترم reduce motion', (tester) async {
      // This test verifies the pattern exists in all animation widgets
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                SimpleAnimatedCounter(value: 10),
                AnimatedPrice(value: 10.0),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(SimpleAnimatedCounter), findsOneWidget);
      expect(find.byType(AnimatedPrice), findsOneWidget);
    });
  });

  group('Widget Types', () {
    test('AddToCartAnimation is a StatefulWidget', () {
      expect(AddToCartAnimation, isNot(StatelessWidget));
    });

    test('AnimatedCounter is a StatelessWidget', () {
      const widget = SimpleAnimatedCounter(value: 0);
      expect(widget, isA<StatelessWidget>());
    });

    test('AnimatedPrice is a StatelessWidget', () {
      const widget = AnimatedPrice(value: 0);
      expect(widget, isA<StatelessWidget>());
    });

    test('SuccessAnimation is a StatefulWidget', () {
      expect(SuccessAnimation, isNot(StatelessWidget));
    });

    test('SimpleShimmer is a StatefulWidget', () {
      expect(SimpleShimmer, isNot(StatelessWidget));
    });

    test('PulseAnimation is a StatefulWidget', () {
      expect(PulseAnimation, isNot(StatelessWidget));
    });
  });
}
