import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:driver_app/features/deliveries/providers/driving_mode_provider.dart';
import 'package:driver_app/core/widgets/driving_mode_scale.dart';

void main() {
  group('H7 — Driving Mode', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('drivingModeProvider defaults to false', (tester) async {
      bool? drivingMode;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, _) {
                drivingMode = ref.watch(drivingModeProvider);
                return Text('driving: $drivingMode');
              },
            ),
          ),
        ),
      );
      await tester.pump();

      expect(drivingMode, isFalse);
    });

    testWidgets('toggle switches driving mode on/off', (tester) async {
      late WidgetRef testRef;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, _) {
                testRef = ref;
                final isDriving = ref.watch(drivingModeProvider);
                return Text('driving: $isDriving');
              },
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('driving: false'), findsOneWidget);

      // Toggle on
      testRef.read(drivingModeProvider.notifier).toggle();
      await tester.pump();

      expect(find.text('driving: true'), findsOneWidget);

      // Toggle off
      testRef.read(drivingModeProvider.notifier).toggle();
      await tester.pump();

      expect(find.text('driving: false'), findsOneWidget);
    });

    testWidgets('toggle persists to SharedPreferences', (tester) async {
      SharedPreferences.setMockInitialValues({});

      late WidgetRef testRef;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, _) {
                testRef = ref;
                ref.watch(drivingModeProvider);
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      await tester.pump();

      // Toggle on and wait for SharedPreferences write.
      await testRef.read(drivingModeProvider.notifier).toggle();
      await tester.pump();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('driving_mode_enabled'), isTrue);
    });

    testWidgets('loads persisted driving mode on startup', (tester) async {
      SharedPreferences.setMockInitialValues({'driving_mode_enabled': true});

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, _) {
                final isDriving = ref.watch(drivingModeProvider);
                return Text('driving: $isDriving');
              },
            ),
          ),
        ),
      );

      // Give the async _loadFromPrefs time to complete.
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('driving: true'), findsOneWidget);
    });

    testWidgets('DrivingModeScale applies 1.4x textScaler when driving',
        (tester) async {
      double? capturedScale;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            drivingModeProvider.overrideWith((ref) {
              final notifier = DrivingModeNotifier();
              notifier.setEnabled(true);
              return notifier;
            }),
          ],
          child: MaterialApp(
            theme: AlhaiTheme.light,
            locale: const Locale('ar'),
            supportedLocales: const [Locale('ar')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: Scaffold(
              body: DrivingModeScale(
                child: Builder(
                  builder: (context) {
                    capturedScale =
                        MediaQuery.of(context).textScaler.scale(1.0);
                    return const Text('Test');
                  },
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(capturedScale, closeTo(1.4, 0.01));
    });

    testWidgets('DrivingModeScale applies 1.0x when NOT driving',
        (tester) async {
      double? capturedScale;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AlhaiTheme.light,
            locale: const Locale('ar'),
            supportedLocales: const [Locale('ar')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: Scaffold(
              body: DrivingModeScale(
                child: Builder(
                  builder: (context) {
                    capturedScale =
                        MediaQuery.of(context).textScaler.scale(1.0);
                    return const Text('Test');
                  },
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(capturedScale, closeTo(1.0, 0.01));
    });
  });
}
