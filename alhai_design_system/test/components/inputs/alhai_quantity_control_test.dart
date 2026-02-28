import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('AlhaiQuantityControl', () {
    testWidgets('renders with quantity', (tester) async {
      await tester.pumpWidget(createTestWidget(
        AlhaiQuantityControl(quantity: 3, onChanged: (_) {}),
      ));

      expect(find.byType(AlhaiQuantityControl), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('shows plus and minus icons', (tester) async {
      await tester.pumpWidget(createTestWidget(
        AlhaiQuantityControl(quantity: 5, onChanged: (_) {}),
      ));

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.remove), findsOneWidget);
    });

    testWidgets('increment button increases quantity', (tester) async {
      int? newValue;
      await tester.pumpWidget(createTestWidget(
        AlhaiQuantityControl(
          quantity: 3,
          onChanged: (value) => newValue = value,
        ),
      ));

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(newValue, 4);
    });

    testWidgets('decrement button decreases quantity', (tester) async {
      int? newValue;
      await tester.pumpWidget(createTestWidget(
        AlhaiQuantityControl(
          quantity: 3,
          onChanged: (value) => newValue = value,
        ),
      ));

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();

      expect(newValue, 2);
    });

    testWidgets('does not go below minimum', (tester) async {
      int? newValue;
      await tester.pumpWidget(createTestWidget(
        AlhaiQuantityControl(
          quantity: 1,
          min: 1,
          onChanged: (value) => newValue = value,
        ),
      ));

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();

      // Should not have been called since already at min
      expect(newValue, isNull);
    });

    testWidgets('does not go above maximum', (tester) async {
      int? newValue;
      await tester.pumpWidget(createTestWidget(
        AlhaiQuantityControl(
          quantity: 10,
          max: 10,
          onChanged: (value) => newValue = value,
        ),
      ));

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Should not have been called since already at max
      expect(newValue, isNull);
    });

    testWidgets('clamps quantity to valid range', (tester) async {
      await tester.pumpWidget(createTestWidget(
        AlhaiQuantityControl(
          quantity: -5,
          min: 0,
          onChanged: (_) {},
        ),
      ));

      // Display should show clamped value (0)
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('uses step for increment', (tester) async {
      int? newValue;
      await tester.pumpWidget(createTestWidget(
        AlhaiQuantityControl(
          quantity: 5,
          step: 5,
          onChanged: (value) => newValue = value,
        ),
      ));

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(newValue, 10);
    });

    testWidgets('is disabled when enabled is false', (tester) async {
      await tester.pumpWidget(createTestWidget(
        AlhaiQuantityControl(
          quantity: 3,
          enabled: false,
          onChanged: (_) {},
        ),
      ));

      // Should have reduced opacity
      final opacityWidget = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacityWidget.opacity, AlhaiColors.disabledOpacity);
    });

    testWidgets('compact size renders', (tester) async {
      await tester.pumpWidget(createTestWidget(
        AlhaiQuantityControl(
          quantity: 1,
          size: AlhaiQuantityControlSize.compact,
          onChanged: (_) {},
        ),
      ));

      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('renders custom decrement icon', (tester) async {
      await tester.pumpWidget(createTestWidget(
        AlhaiQuantityControl(
          quantity: 5,
          onChanged: (_) {},
          decrementIcon: Icons.remove_circle,
        ),
      ));

      expect(find.byIcon(Icons.remove_circle), findsOneWidget);
    });

    testWidgets('renders custom increment icon', (tester) async {
      await tester.pumpWidget(createTestWidget(
        AlhaiQuantityControl(
          quantity: 5,
          onChanged: (_) {},
          incrementIcon: Icons.add_circle,
        ),
      ));

      expect(find.byIcon(Icons.add_circle), findsOneWidget);
    });

    testWidgets('disabled control does not respond to taps', (tester) async {
      var tapped = false;

      await tester.pumpWidget(createTestWidget(
        AlhaiQuantityControl(
          quantity: 5,
          enabled: false,
          onChanged: (_) => tapped = true,
        ),
      ));

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(tapped, isFalse);
    });
  });
}
