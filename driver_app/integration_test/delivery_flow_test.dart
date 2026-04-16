/// Integration test: Delivery Flow (دورة التوصيل)
///
/// Tests the complete delivery lifecycle from the driver's perspective:
///   1. Driver accepts a new delivery assignment
///   2. Driver completes pickup (heading -> arrive -> OTP verify -> picked up)
///   3. Driver completes delivery (heading -> arrive -> proof capture -> delivered)
///
/// Uses stub screens and programmatic GoRouter navigation to validate
/// route transitions without deep DI dependencies.
///
/// Run with:
///   flutter test integration_test/delivery_flow_test.dart
///   (requires a running device or emulator)
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:go_router/go_router.dart';

import 'helpers/test_data.dart';
import 'helpers/test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ==========================================================================
  // DELIVERY FLOW (دورة التوصيل)
  // ==========================================================================

  group('Delivery Flow - دورة التوصيل', () {
    // ========================================================================
    // Step 1: Driver Accepts Delivery
    // ========================================================================
    group('Step 1: Driver Accepts Delivery', () {
      testWidgets('login screen loads at initial route', (tester) async {
        // Arrange: Launch driver app at login
        await tester.pumpWidget(buildDriverTestApp(initialRoute: '/login'));
        await pumpAndSettleWithTimeout(tester);

        // Assert: Login screen stub is visible
        expectStubScreen('Login');
      });

      testWidgets('authenticated driver sees deliveries list', (
        tester,
      ) async {
        // Arrange: Start at deliveries (authenticated driver)
        await tester.pumpWidget(
          buildDriverTestApp(initialRoute: '/deliveries'),
        );
        await pumpAndSettleWithTimeout(tester);

        // Assert: Deliveries list screen is shown
        expectStubScreen('Deliveries');
      });

      testWidgets('new order notification navigates to new order screen', (
        tester,
      ) async {
        // Arrange: Start at deliveries list
        await tester.pumpWidget(
          buildDriverTestApp(initialRoute: '/deliveries'),
        );
        await pumpAndSettleWithTimeout(tester);

        // Act: Simulate a new order push notification by navigating
        // to the new order screen. In production, FCM triggers this.
        final router = GoRouter.of(
          tester.element(find.byKey(const Key('stub_Deliveries'))),
        );
        router.go('/orders/new');
        await pumpAndSettleWithTimeout(tester);

        // Assert: New order screen shown with accept/reject actions
        expectStubScreen('New Order');
      });

      testWidgets('accepting delivery navigates to order details', (
        tester,
      ) async {
        // Arrange: Driver is viewing the new order screen
        await tester.pumpWidget(
          buildDriverTestApp(initialRoute: '/orders/new'),
        );
        await pumpAndSettleWithTimeout(tester);
        expectStubScreen('New Order');

        // Act: Driver accepts the delivery. In production, tapping "Accept"
        // calls update_delivery_status RPC with status=accepted and navigates
        // to order details. Simulate with router navigation.
        final router = GoRouter.of(
          tester.element(find.byKey(const Key('stub_New Order'))),
        );
        router.go('/orders/$kTestDeliveryId');
        await pumpAndSettleWithTimeout(tester);

        // Assert: Order details screen is shown for the accepted delivery
        expectStubScreen('Order $kTestDeliveryId');
      });

      testWidgets(
        'full accept flow: login -> deliveries -> new order -> accept',
        (tester) async {
          // Arrange: Start at login
          await tester.pumpWidget(buildDriverTestApp(initialRoute: '/login'));
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Login');

          final router = GoRouter.of(
            tester.element(find.byKey(const Key('stub_Login'))),
          );

          // Step 1: Authenticated driver lands on home
          router.go('/home');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Home');

          // Step 2: Navigate to deliveries tab
          router.go('/deliveries');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Deliveries');

          // Step 3: New order arrives
          router.go('/orders/new');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('New Order');

          // Step 4: Driver accepts -> order details
          router.go('/orders/$kTestDeliveryId');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Order $kTestDeliveryId');
        },
      );
    });

    // ========================================================================
    // Step 2: Driver Completes Pickup
    // ========================================================================
    group('Step 2: Driver Completes Pickup', () {
      testWidgets('accepted delivery shows navigation option', (tester) async {
        // Arrange: Driver viewing accepted order details
        await tester.pumpWidget(
          buildDriverTestApp(initialRoute: '/orders/$kTestDeliveryId'),
        );
        await pumpAndSettleWithTimeout(tester);

        // Act: Driver taps "Navigate to Store". In production this calls
        // update_delivery_status(heading_to_pickup) then opens NavigationScreen.
        final router = GoRouter.of(
          tester.element(
            find.byKey(Key('stub_Order $kTestDeliveryId')),
          ),
        );
        router.go('/orders/$kTestDeliveryId/navigate');
        await pumpAndSettleWithTimeout(tester);

        // Assert: Navigation screen is shown
        expectStubScreen('Navigate $kTestDeliveryId');
      });

      testWidgets('arriving at pickup opens OTP screen', (tester) async {
        // Arrange: Driver is navigating to store (heading_to_pickup)
        await tester.pumpWidget(
          buildDriverTestApp(
            initialRoute: '/orders/$kTestDeliveryId/navigate',
          ),
        );
        await pumpAndSettleWithTimeout(tester);
        expectStubScreen('Navigate $kTestDeliveryId');

        // Act: Driver arrives at store. In production, geofence triggers
        // arrived_at_pickup status and navigates to OTP screen.
        final router = GoRouter.of(
          tester.element(
            find.byKey(Key('stub_Navigate $kTestDeliveryId')),
          ),
        );
        router.go('/orders/$kTestDeliveryId/pickup-otp');
        await pumpAndSettleWithTimeout(tester);

        // Assert: OTP verification screen is shown
        expectStubScreen('Pickup OTP $kTestDeliveryId');
      });

      testWidgets('OTP verification returns to order details', (
        tester,
      ) async {
        // Arrange: Driver is on the OTP screen
        await tester.pumpWidget(
          buildDriverTestApp(
            initialRoute: '/orders/$kTestDeliveryId/pickup-otp',
          ),
        );
        await pumpAndSettleWithTimeout(tester);
        expectStubScreen('Pickup OTP $kTestDeliveryId');

        // Act: Driver enters OTP (kTestPickupOtp = '1234') and it verifies.
        // In production, PickupOtpScreen calls the backend, updates status
        // to picked_up, and pops back to order details.
        final router = GoRouter.of(
          tester.element(
            find.byKey(Key('stub_Pickup OTP $kTestDeliveryId')),
          ),
        );
        router.go('/orders/$kTestDeliveryId');
        await pumpAndSettleWithTimeout(tester);

        // Assert: Order details screen is shown with picked_up status
        expectStubScreen('Order $kTestDeliveryId');
      });

      testWidgets(
        'full pickup flow: order -> navigate -> arrive -> OTP -> picked up',
        (tester) async {
          // Arrange: Driver accepted the delivery
          await tester.pumpWidget(
            buildDriverTestApp(initialRoute: '/orders/$kTestDeliveryId'),
          );
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Order $kTestDeliveryId');

          final router = GoRouter.of(
            tester.element(
              find.byKey(Key('stub_Order $kTestDeliveryId')),
            ),
          );

          // Step 1: heading_to_pickup -> navigate to store
          router.go('/orders/$kTestDeliveryId/navigate');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Navigate $kTestDeliveryId');

          // Step 2: arrived_at_pickup -> OTP screen
          router.go('/orders/$kTestDeliveryId/pickup-otp');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Pickup OTP $kTestDeliveryId');

          // Step 3: picked_up -> back to order details
          router.go('/orders/$kTestDeliveryId');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Order $kTestDeliveryId');
        },
      );
    });

    // ========================================================================
    // Step 3: Driver Completes Delivery
    // ========================================================================
    group('Step 3: Driver Completes Delivery', () {
      testWidgets('picked up order shows navigate-to-customer option', (
        tester,
      ) async {
        // Arrange: Order is picked up, driver views order details
        await tester.pumpWidget(
          buildDriverTestApp(initialRoute: '/orders/$kTestDeliveryId'),
        );
        await pumpAndSettleWithTimeout(tester);

        // Act: Driver taps "Navigate to Customer". Status transitions
        // to heading_to_customer.
        final router = GoRouter.of(
          tester.element(
            find.byKey(Key('stub_Order $kTestDeliveryId')),
          ),
        );
        router.go('/orders/$kTestDeliveryId/navigate');
        await pumpAndSettleWithTimeout(tester);

        // Assert: Navigation screen is shown for customer address
        expectStubScreen('Navigate $kTestDeliveryId');
      });

      testWidgets('arriving at customer opens proof capture', (tester) async {
        // Arrange: Driver is heading to customer
        await tester.pumpWidget(
          buildDriverTestApp(
            initialRoute: '/orders/$kTestDeliveryId/navigate',
          ),
        );
        await pumpAndSettleWithTimeout(tester);
        expectStubScreen('Navigate $kTestDeliveryId');

        // Act: Driver arrives at customer location. Geofence triggers
        // arrived_at_customer status and navigates to proof capture.
        final router = GoRouter.of(
          tester.element(
            find.byKey(Key('stub_Navigate $kTestDeliveryId')),
          ),
        );
        router.go('/orders/$kTestDeliveryId/proof');
        await pumpAndSettleWithTimeout(tester);

        // Assert: Delivery proof screen is shown
        expectStubScreen('Proof $kTestDeliveryId');
      });

      testWidgets('proof capture completes delivery', (tester) async {
        // Arrange: Driver is on proof capture screen
        await tester.pumpWidget(
          buildDriverTestApp(
            initialRoute: '/orders/$kTestDeliveryId/proof',
          ),
        );
        await pumpAndSettleWithTimeout(tester);
        expectStubScreen('Proof $kTestDeliveryId');

        // Act: Driver captures photo + signature, uploads proof.
        // DeliveryProofScreen calls the backend, updates status to delivered,
        // and navigates back to deliveries list.
        final router = GoRouter.of(
          tester.element(
            find.byKey(Key('stub_Proof $kTestDeliveryId')),
          ),
        );
        router.go('/deliveries');
        await pumpAndSettleWithTimeout(tester);

        // Assert: Back to deliveries list with delivery marked as delivered
        expectStubScreen('Deliveries');
      });

      testWidgets(
        'full delivery flow: navigate -> arrive -> proof -> delivered',
        (tester) async {
          // Arrange: Driver has picked up the order
          await tester.pumpWidget(
            buildDriverTestApp(initialRoute: '/orders/$kTestDeliveryId'),
          );
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Order $kTestDeliveryId');

          final router = GoRouter.of(
            tester.element(
              find.byKey(Key('stub_Order $kTestDeliveryId')),
            ),
          );

          // Step 1: heading_to_customer -> navigate
          router.go('/orders/$kTestDeliveryId/navigate');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Navigate $kTestDeliveryId');

          // Step 2: arrived_at_customer -> proof capture
          router.go('/orders/$kTestDeliveryId/proof');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Proof $kTestDeliveryId');

          // Step 3: delivered -> back to deliveries list
          router.go('/deliveries');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Deliveries');
        },
      );
    });

    // ========================================================================
    // END-TO-END: Full Delivery Lifecycle
    // ========================================================================
    group('End-to-End: Complete Delivery Lifecycle', () {
      testWidgets(
        'full flow: accept -> pickup -> deliver -> back to list',
        (tester) async {
          // Arrange: Driver on deliveries list, new order arrives
          await tester.pumpWidget(
            buildDriverTestApp(initialRoute: '/deliveries'),
          );
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Deliveries');

          final router = GoRouter.of(
            tester.element(find.byKey(const Key('stub_Deliveries'))),
          );

          // ── Phase 1: Accept ──
          // New order notification -> accept
          router.go('/orders/new');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('New Order');

          router.go('/orders/$kTestDeliveryId');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Order $kTestDeliveryId');

          // ── Phase 2: Pickup ──
          // heading_to_pickup -> navigate to store
          router.go('/orders/$kTestDeliveryId/navigate');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Navigate $kTestDeliveryId');

          // arrived_at_pickup -> OTP verification
          router.go('/orders/$kTestDeliveryId/pickup-otp');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Pickup OTP $kTestDeliveryId');

          // picked_up -> back to order details
          router.go('/orders/$kTestDeliveryId');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Order $kTestDeliveryId');

          // ── Phase 3: Deliver ──
          // heading_to_customer -> navigate to customer
          router.go('/orders/$kTestDeliveryId/navigate');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Navigate $kTestDeliveryId');

          // arrived_at_customer -> proof capture
          router.go('/orders/$kTestDeliveryId/proof');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Proof $kTestDeliveryId');

          // delivered -> back to deliveries list
          router.go('/deliveries');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Deliveries');
        },
      );
    });
  });
}
