@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import 'package:alhai_design_system/src/components/feedback/alhai_badge.dart';

void main() {
  group('AlhaiBadge Golden Tests', () {
    testGoldens('Badge types', (tester) async {
      final builder = GoldenBuilder.grid(columns: 3, widthToHeightRatio: 1)
        ..addScenario(
          'Dot',
          AlhaiBadge.dot(child: const Icon(Icons.notifications, size: 32)),
        )
        ..addScenario(
          'Count 5',
          AlhaiBadge.count(count: 5, child: const Icon(Icons.mail, size: 32)),
        )
        ..addScenario(
          'Count 99+',
          AlhaiBadge.count(
            count: 150,
            child: const Icon(Icons.inbox, size: 32),
          ),
        );

      await tester.pumpWidgetBuilder(
        builder.build(),
        wrapper: materialAppWrapper(theme: ThemeData.light(useMaterial3: true)),
      );

      await screenMatchesGolden(tester, 'alhai_badge_types');
    });

    testGoldens('Badge sizes', (tester) async {
      final builder = GoldenBuilder.grid(columns: 3, widthToHeightRatio: 1)
        ..addScenario(
          'Small',
          AlhaiBadge.count(
            count: 3,
            size: AlhaiBadgeSize.small,
            child: const Icon(Icons.shopping_cart, size: 32),
          ),
        )
        ..addScenario(
          'Medium',
          AlhaiBadge.count(
            count: 7,
            size: AlhaiBadgeSize.medium,
            child: const Icon(Icons.shopping_cart, size: 32),
          ),
        )
        ..addScenario(
          'Large',
          AlhaiBadge.count(
            count: 12,
            size: AlhaiBadgeSize.large,
            child: const Icon(Icons.shopping_cart, size: 32),
          ),
        );

      await tester.pumpWidgetBuilder(
        builder.build(),
        wrapper: materialAppWrapper(theme: ThemeData.light(useMaterial3: true)),
      );

      await screenMatchesGolden(tester, 'alhai_badge_sizes');
    });

    testGoldens('Badge custom colors', (tester) async {
      final builder = GoldenBuilder.grid(columns: 3, widthToHeightRatio: 1)
        ..addScenario(
          'Blue',
          AlhaiBadge.count(
            count: 5,
            backgroundColor: Colors.blue,
            child: const Icon(Icons.message, size: 32),
          ),
        )
        ..addScenario(
          'Green',
          AlhaiBadge.count(
            count: 3,
            backgroundColor: Colors.green,
            child: const Icon(Icons.check_circle, size: 32),
          ),
        )
        ..addScenario(
          'Orange',
          AlhaiBadge.count(
            count: 8,
            backgroundColor: Colors.orange,
            child: const Icon(Icons.warning, size: 32),
          ),
        );

      await tester.pumpWidgetBuilder(
        builder.build(),
        wrapper: materialAppWrapper(theme: ThemeData.light(useMaterial3: true)),
      );

      await screenMatchesGolden(tester, 'alhai_badge_colors');
    });

    testGoldens('Badge dark theme', (tester) async {
      final builder = GoldenBuilder.grid(columns: 2, widthToHeightRatio: 1)
        ..addScenario(
          'Dot Dark',
          AlhaiBadge.dot(
            child: const Icon(
              Icons.notifications,
              size: 32,
              color: Colors.white,
            ),
          ),
        )
        ..addScenario(
          'Count Dark',
          AlhaiBadge.count(
            count: 10,
            child: const Icon(Icons.mail, size: 32, color: Colors.white),
          ),
        );

      await tester.pumpWidgetBuilder(
        builder.build(),
        wrapper: materialAppWrapper(theme: ThemeData.dark(useMaterial3: true)),
      );

      await screenMatchesGolden(tester, 'alhai_badge_dark');
    });
  });
}
