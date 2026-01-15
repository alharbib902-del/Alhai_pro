import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import 'package:alhai_design_system/src/components/inputs/alhai_text_field.dart';

void main() {
  group('AlhaiTextField Golden Tests', () {
    testGoldens('TextField basic', (tester) async {
      await tester.pumpWidgetBuilder(
        const Center(
          child: SizedBox(
            width: 300,
            child: AlhaiTextField(
              labelText: 'Username',
              hintText: 'Enter username',
            ),
          ),
        ),
        wrapper: materialAppWrapper(theme: ThemeData.light(useMaterial3: true)),
        surfaceSize: const Size(400, 120),
      );

      await screenMatchesGolden(tester, 'alhai_text_field_basic');
    });

    testGoldens('TextField with icon', (tester) async {
      await tester.pumpWidgetBuilder(
        const Center(
          child: SizedBox(
            width: 300,
            child: AlhaiTextField(
              labelText: 'Email',
              hintText: 'Enter email',
              prefixIcon: Icons.email,
            ),
          ),
        ),
        wrapper: materialAppWrapper(theme: ThemeData.light(useMaterial3: true)),
        surfaceSize: const Size(400, 120),
      );

      await screenMatchesGolden(tester, 'alhai_text_field_with_icon');
    });
  });
}
