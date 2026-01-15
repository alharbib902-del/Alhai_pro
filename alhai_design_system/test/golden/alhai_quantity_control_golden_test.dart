import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import 'package:alhai_design_system/src/components/inputs/alhai_quantity_control.dart';

void main() {
  group('AlhaiQuantityControl Golden Tests', () {
    testGoldens('Quantity control sizes', (tester) async {
      final builder = GoldenBuilder.grid(
        columns: 2,
        widthToHeightRatio: 2,
      )
        ..addScenario(
          'Compact',
          AlhaiQuantityControl(
            quantity: 3,
            size: AlhaiQuantityControlSize.compact,
            onChanged: (_) {},
          ),
        )
        ..addScenario(
          'Regular',
          AlhaiQuantityControl(
            quantity: 5,
            size: AlhaiQuantityControlSize.regular,
            onChanged: (_) {},
          ),
        );

      await tester.pumpWidgetBuilder(
        builder.build(),
        wrapper: materialAppWrapper(theme: ThemeData.light(useMaterial3: true)),
      );

      await screenMatchesGolden(tester, 'alhai_quantity_control_sizes');
    });

    testGoldens('Quantity control values', (tester) async {
      final builder = GoldenBuilder.column()
        ..addScenario(
          'Min Value',
          AlhaiQuantityControl(
            quantity: 1,
            min: 1,
            onChanged: (_) {},
          ),
        )
        ..addScenario(
          'Normal Value',
          AlhaiQuantityControl(
            quantity: 5,
            onChanged: (_) {},
          ),
        )
        ..addScenario(
          'Max Value',
          AlhaiQuantityControl(
            quantity: 10,
            max: 10,
            onChanged: (_) {},
          ),
        );

      await tester.pumpWidgetBuilder(
        builder.build(),
        wrapper: materialAppWrapper(theme: ThemeData.light(useMaterial3: true)),
      );

      await screenMatchesGolden(tester, 'alhai_quantity_control_values');
    });
  });
}
