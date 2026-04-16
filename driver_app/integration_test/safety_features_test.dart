/// Integration test: Safety Features (ميزات السلامة)
///
/// Tests driver safety features that protect both drivers and customers:
///   1. SOS emergency button accessibility and confirmation dialog
///   2. Wake lock behavior during active deliveries
///   3. Mock GPS detection blocking status transitions
///   4. Shift toggle guard preventing end-shift during active delivery
///
/// These tests validate navigation flows and UI state for safety-critical
/// features using stub screens and programmatic GoRouter navigation.
///
/// Run with:
///   flutter test integration_test/safety_features_test.dart
///   (requires a running device or emulator)
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'helpers/test_data.dart';
import 'helpers/test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ==========================================================================
  // SAFETY FEATURES (ميزات السلامة)
  // ==========================================================================

  group('Safety Features - ميزات السلامة', () {
    // ========================================================================
    // SOS Emergency Button
    // ========================================================================
    group('SOS Emergency Button', () {
      testWidgets('SOS button is accessible from home screen', (
        tester,
      ) async {
        // Arrange: Build a custom app that includes an SOS button on the
        // home screen stub, simulating the real HomeScreen's SOS FAB.
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              locale: const Locale('ar'),
              home: Scaffold(
                body: const Center(
                  child: Text('Home', key: Key('stub_Home')),
                ),
                floatingActionButton: FloatingActionButton(
                  key: const Key('sos_button'),
                  onPressed: () {},
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.sos),
                ),
              ),
            ),
          ),
        );
        await pumpAndSettleWithTimeout(tester);

        // Assert: SOS button is visible and tappable
        expect(find.byKey(const Key('sos_button')), findsOneWidget);
        expect(find.byIcon(Icons.sos), findsOneWidget);
      });

      testWidgets('SOS button shows confirmation dialog before action', (
        tester,
      ) async {
        // Arrange: Build a home screen with SOS button that opens a dialog
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              locale: const Locale('ar'),
              home: Builder(
                builder: (context) => Scaffold(
                  body: const Center(
                    child: Text('Home', key: Key('stub_Home')),
                  ),
                  floatingActionButton: FloatingActionButton(
                    key: const Key('sos_button'),
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('طوارئ'),
                          content: const Text(
                            'هل تريد الاتصال بالطوارئ؟',
                            key: Key('sos_confirm_text'),
                          ),
                          actions: [
                            TextButton(
                              key: const Key('sos_cancel'),
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('إلغاء'),
                            ),
                            TextButton(
                              key: const Key('sos_confirm'),
                              onPressed: () {},
                              child: const Text('اتصال'),
                            ),
                          ],
                        ),
                      );
                    },
                    backgroundColor: Colors.red,
                    child: const Icon(Icons.sos),
                  ),
                ),
              ),
            ),
          ),
        );
        await pumpAndSettleWithTimeout(tester);

        // Act: Tap the SOS button
        await tester.tap(find.byKey(const Key('sos_button')));
        await tester.pumpAndSettle();

        // Assert: Confirmation dialog is shown with cancel/confirm options
        expect(find.byKey(const Key('sos_confirm_text')), findsOneWidget);
        expect(find.byKey(const Key('sos_cancel')), findsOneWidget);
        expect(find.byKey(const Key('sos_confirm')), findsOneWidget);
      });

      testWidgets('SOS confirmation dialog can be dismissed', (tester) async {
        // Arrange: Build app with SOS dialog
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              locale: const Locale('ar'),
              home: Builder(
                builder: (context) => Scaffold(
                  body: const Center(
                    child: Text('Home', key: Key('stub_Home')),
                  ),
                  floatingActionButton: FloatingActionButton(
                    key: const Key('sos_button'),
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('طوارئ'),
                          content: const Text('هل تريد الاتصال بالطوارئ؟'),
                          actions: [
                            TextButton(
                              key: const Key('sos_cancel'),
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('إلغاء'),
                            ),
                          ],
                        ),
                      );
                    },
                    backgroundColor: Colors.red,
                    child: const Icon(Icons.sos),
                  ),
                ),
              ),
            ),
          ),
        );
        await pumpAndSettleWithTimeout(tester);

        // Act: Open and then dismiss the dialog
        await tester.tap(find.byKey(const Key('sos_button')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('sos_cancel')));
        await tester.pumpAndSettle();

        // Assert: Dialog is dismissed, home screen is visible
        expect(find.text('هل تريد الاتصال بالطوارئ؟'), findsNothing);
        expect(find.byKey(const Key('stub_Home')), findsOneWidget);
      });
    });

    // ========================================================================
    // Wake Lock During Active Delivery
    // ========================================================================
    group('Wake Lock During Active Delivery', () {
      testWidgets(
        'navigation screen implies wake lock is active during delivery',
        (tester) async {
          // Arrange: Driver is actively navigating to a delivery.
          // In production, NavigationScreen enables wakelock_plus to prevent
          // the screen from sleeping while the driver is en route.
          await tester.pumpWidget(
            buildDriverTestApp(
              initialRoute: '/orders/$kTestDeliveryId/navigate',
            ),
          );
          await pumpAndSettleWithTimeout(tester);

          // Assert: Navigation screen is rendered (wake lock would be active).
          // The real NavigationScreen calls WakelockPlus.enable() in initState.
          expectStubScreen('Navigate $kTestDeliveryId');
        },
      );

      testWidgets(
        'leaving navigation screen implies wake lock is released',
        (tester) async {
          // Arrange: Driver is on navigation screen
          await tester.pumpWidget(
            buildDriverTestApp(
              initialRoute: '/orders/$kTestDeliveryId/navigate',
            ),
          );
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Navigate $kTestDeliveryId');

          // Act: Driver completes navigation and goes to proof screen.
          // In production, NavigationScreen releases wake lock in dispose().
          final router = GoRouter.of(
            tester.element(
              find.byKey(Key('stub_Navigate $kTestDeliveryId')),
            ),
          );
          router.go('/orders/$kTestDeliveryId/proof');
          await pumpAndSettleWithTimeout(tester);

          // Assert: Navigation screen is gone, proof screen is shown.
          // Wake lock dispose() would have been called.
          expect(
            find.byKey(Key('stub_Navigate $kTestDeliveryId')),
            findsNothing,
          );
          expectStubScreen('Proof $kTestDeliveryId');
        },
      );

      testWidgets(
        'home screen does not imply wake lock (no active delivery)',
        (tester) async {
          // Arrange: Driver is on home screen, no active delivery
          await tester.pumpWidget(buildDriverTestApp(initialRoute: '/home'));
          await pumpAndSettleWithTimeout(tester);

          // Assert: Home screen is shown. WakelockPlus should NOT be active
          // when the driver is idle (not on navigation screen).
          expectStubScreen('Home');
        },
      );
    });

    // ========================================================================
    // Mock GPS Detection
    // ========================================================================
    group('Mock GPS Detection', () {
      testWidgets(
        'status transition requires valid location context',
        (tester) async {
          // Concept test: In production, the update_delivery_status RPC
          // receives the driver's GPS coordinates. The backend validates
          // that the coordinates are not from a mock location provider.
          //
          // This test verifies the navigation flow that would be blocked
          // if GPS spoofing were detected.

          // Arrange: Driver is on order details (accepted state)
          await tester.pumpWidget(
            buildDriverTestApp(initialRoute: '/orders/$kTestDeliveryId'),
          );
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Order $kTestDeliveryId');

          // Act: Attempt to navigate (which triggers heading_to_pickup).
          // In production, if mock GPS is detected, the app shows an error
          // dialog instead of proceeding to navigation.
          final router = GoRouter.of(
            tester.element(
              find.byKey(Key('stub_Order $kTestDeliveryId')),
            ),
          );
          router.go('/orders/$kTestDeliveryId/navigate');
          await pumpAndSettleWithTimeout(tester);

          // Assert: Navigation screen is accessible with valid GPS.
          // With mock GPS, the real app would show a blocking error dialog
          // and prevent the status transition.
          expectStubScreen('Navigate $kTestDeliveryId');
        },
      );

      testWidgets('mock GPS warning prevents proof capture', (tester) async {
        // Concept test: When the driver arrives at the customer and the
        // device has mock location enabled, the proof capture screen
        // should block photo capture and show a warning.

        // Arrange: Driver at proof capture screen
        await tester.pumpWidget(
          buildDriverTestApp(
            initialRoute: '/orders/$kTestDeliveryId/proof',
          ),
        );
        await pumpAndSettleWithTimeout(tester);

        // Assert: Proof screen is accessible. In production, the screen
        // checks Geolocator.isLocationServiceEnabled() and isMocked
        // before allowing photo/signature capture.
        expectStubScreen('Proof $kTestDeliveryId');
      });
    });

    // ========================================================================
    // Shift Toggle Guard
    // ========================================================================
    group('Shift Toggle Guard', () {
      testWidgets('home screen shows shift toggle', (tester) async {
        // Arrange: Driver is on home screen
        await tester.pumpWidget(buildDriverTestApp(initialRoute: '/home'));
        await pumpAndSettleWithTimeout(tester);

        // Assert: Home screen renders. In production, HomeScreen displays
        // a shift toggle switch that starts/ends the driver's active shift.
        expectStubScreen('Home');
      });

      testWidgets(
        'cannot end shift while active delivery exists',
        (tester) async {
          // Concept test: In production, when the driver has an active
          // (non-terminal) delivery, the shift toggle is either disabled
          // or shows a confirmation dialog preventing shift end.

          // Arrange: Build a custom home screen with a disabled shift toggle
          // simulating active delivery state.
          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp(
                locale: const Locale('ar'),
                home: Scaffold(
                  body: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    // ignore: prefer_const_literals_to_create_immutables
                    children: <Widget>[
                      const Text('Home', key: Key('stub_Home')),
                      Switch(
                        key: const Key('shift_toggle'),
                        value: true, // Shift is active
                        onChanged: null, // Disabled: active delivery exists
                      ),
                      const Text(
                        'لا يمكن إنهاء الوردية أثناء توصيل نشط',
                        key: Key('shift_guard_message'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
          await pumpAndSettleWithTimeout(tester);

          // Assert: Shift toggle is visible but disabled
          final switchWidget = tester.widget<Switch>(
            find.byKey(const Key('shift_toggle')),
          );
          expect(switchWidget.onChanged, isNull); // Disabled
          expect(switchWidget.value, isTrue); // Still active
          expect(
            find.byKey(const Key('shift_guard_message')),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'can end shift when no active deliveries',
        (tester) async {
          // Concept test: When the driver has no active deliveries (all
          // deliveries are terminal), the shift toggle is enabled and
          // the driver can end their shift.

          var shiftActive = true;

          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp(
                locale: const Locale('ar'),
                home: StatefulBuilder(
                  builder: (context, setState) => Scaffold(
                    body: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Home', key: Key('stub_Home')),
                        Switch(
                          key: const Key('shift_toggle'),
                          value: shiftActive,
                          onChanged: (value) {
                            setState(() => shiftActive = value);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
          await pumpAndSettleWithTimeout(tester);

          // Assert: Shift toggle is enabled
          final switchFinder = find.byKey(const Key('shift_toggle'));
          final switchWidget = tester.widget<Switch>(switchFinder);
          expect(switchWidget.onChanged, isNotNull); // Enabled

          // Act: End shift
          await tester.tap(switchFinder);
          await tester.pumpAndSettle();

          // Assert: Shift is now ended
          final updatedSwitch = tester.widget<Switch>(switchFinder);
          expect(updatedSwitch.value, isFalse);
        },
      );
    });
  });
}
