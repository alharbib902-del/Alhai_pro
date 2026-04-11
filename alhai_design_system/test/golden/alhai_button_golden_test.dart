@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import 'package:alhai_design_system/src/components/buttons/alhai_button.dart';

void main() {
  group('AlhaiButton Golden Tests', () {
    testGoldens('Button variants', (tester) async {
      final builder = GoldenBuilder.grid(columns: 2, widthToHeightRatio: 2)
        ..addScenario(
          'Filled',
          AlhaiButton.filled(label: 'Filled Button', onPressed: () {}),
        )
        ..addScenario(
          'Outlined',
          AlhaiButton.outlined(label: 'Outlined Button', onPressed: () {}),
        )
        ..addScenario(
          'Text',
          AlhaiButton.text(label: 'Text Button', onPressed: () {}),
        )
        ..addScenario(
          'Tonal',
          AlhaiButton(
            label: 'Tonal Button',
            variant: AlhaiButtonVariant.tonal,
            onPressed: () {},
          ),
        );

      await tester.pumpWidgetBuilder(
        builder.build(),
        wrapper: materialAppWrapper(theme: ThemeData.light(useMaterial3: true)),
      );

      await screenMatchesGolden(tester, 'alhai_button_variants');
    });

    testGoldens('Button with icons', (tester) async {
      final builder = GoldenBuilder.column()
        ..addScenario(
          'Leading Icon',
          AlhaiButton.filled(
            label: 'Add Item',
            leadingIcon: Icons.add,
            onPressed: () {},
          ),
        )
        ..addScenario(
          'Trailing Icon',
          AlhaiButton.filled(
            label: 'Next',
            trailingIcon: Icons.arrow_forward,
            onPressed: () {},
          ),
        );

      await tester.pumpWidgetBuilder(
        builder.build(),
        wrapper: materialAppWrapper(theme: ThemeData.light(useMaterial3: true)),
      );

      await screenMatchesGolden(tester, 'alhai_button_icons');
    });

    testGoldens('Button sizes', (tester) async {
      final builder = GoldenBuilder.column()
        ..addScenario(
          'Small',
          AlhaiButton.filled(
            label: 'Small',
            size: AlhaiButtonSize.small,
            onPressed: () {},
          ),
        )
        ..addScenario(
          'Medium',
          AlhaiButton.filled(
            label: 'Medium',
            size: AlhaiButtonSize.medium,
            onPressed: () {},
          ),
        )
        ..addScenario(
          'Large',
          AlhaiButton.filled(
            label: 'Large',
            size: AlhaiButtonSize.large,
            onPressed: () {},
          ),
        );

      await tester.pumpWidgetBuilder(
        builder.build(),
        wrapper: materialAppWrapper(theme: ThemeData.light(useMaterial3: true)),
      );

      await screenMatchesGolden(tester, 'alhai_button_sizes');
    });
  });
}
