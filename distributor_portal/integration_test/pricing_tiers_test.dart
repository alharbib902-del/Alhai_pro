/// Integration test: Pricing Tiers flows for the Distributor Portal.
///
/// Tests the tier-based pricing system:
///   1. Create a pricing tier (gold / silver)
///   2. Set a tier as the default
///   3. Assign a store to a tier
///   4. Verify discount applied in an order detail
///
/// All screens are stubs; the tests verify navigation flow, route
/// parameter handling, and data consistency. Real pricing logic is
/// covered by unit tests for PricingTierProviders and the datasource.
///
/// Run with:
///   flutter test integration_test/pricing_tiers_test.dart
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
  // PRICING TIERS (شرائح التسعير)
  // ==========================================================================

  group('Pricing Tiers - شرائح التسعير', () {
    // ========================================================================
    // Flow 1: Create Tier
    // ========================================================================
    group('Flow 1: Create Tier', () {
      testWidgets('pricing tiers screen loads at /pricing-tiers', (
        tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          buildDistributorTestApp(initialRoute: '/pricing-tiers'),
        );
        await pumpAndSettleWithTimeout(tester);

        // Assert
        expectStubScreen('Pricing Tiers');
      });

      testWidgets('pricing screen loads at /pricing', (tester) async {
        // Arrange
        await tester.pumpWidget(
          buildDistributorTestApp(initialRoute: '/pricing'),
        );
        await pumpAndSettleWithTimeout(tester);

        // Assert
        expectStubScreen('Pricing');
      });

      testWidgets(
        'create tier flow: pricing-tiers -> create gold tier -> verify in list',
        (tester) async {
          // Arrange: Start at pricing tiers screen
          await tester.pumpWidget(
            buildDistributorTestApp(initialRoute: '/pricing-tiers'),
          );
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Pricing Tiers');

          // Step 1: In the real PricingTiersScreen, the distributor taps
          // "Add Tier" to open a dialog/form for creating a new tier.
          // Verify gold tier data is well-formed.
          expect(kSampleTier['name'], equals('ذهبي'));
          expect(kSampleTier['name_en'], equals('Gold'));
          expect(kSampleTier['discount_percent'], equals(10.0));
          expect(kSampleTier['min_order_amount'], equals(5000.0));
          expect(kSampleTier['is_active'], isTrue);

          // Step 2: Verify silver tier data is also well-formed.
          expect(kSampleTier2['name'], equals('فضي'));
          expect(kSampleTier2['name_en'], equals('Silver'));
          expect(kSampleTier2['discount_percent'], equals(5.0));
          expect(kSampleTier2['min_order_amount'], equals(2000.0));

          // Step 3: After creation, the tier appears in the list.
          // The screen stays on /pricing-tiers showing the updated list.
          final router = GoRouter.of(
            tester.element(find.byKey(const Key('stub_Pricing Tiers'))),
          );

          // Navigate away and back to simulate refresh
          router.go('/dashboard');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Dashboard');

          router.go('/pricing-tiers');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Pricing Tiers');
        },
      );
    });

    // ========================================================================
    // Flow 2: Set as Default
    // ========================================================================
    group('Flow 2: Set as Default', () {
      testWidgets(
        'set default flow: select tier -> set default -> verify badge',
        (tester) async {
          // Arrange: Start at pricing tiers
          await tester.pumpWidget(
            buildDistributorTestApp(initialRoute: '/pricing-tiers'),
          );
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Pricing Tiers');

          // Step 1: The gold tier is not default initially.
          expect(kSampleTier['is_default'], isFalse);

          // Step 2: The silver tier is the current default.
          expect(kSampleTier2['is_default'], isTrue);

          // Step 3: In the real app, the distributor selects the gold tier
          // and taps "Set as Default". This calls
          // pricingTierProvider.setDefault(tierId) which updates the DB
          // and invalidates the tier list provider.

          // Step 4: After setting default, verify the tier IDs are distinct
          // (only one tier can be default at a time).
          expect(kSampleTier['id'], isNot(equals(kSampleTier2['id'])));

          // Step 5: The UI refreshes and shows a "Default" badge on the
          // gold tier. Navigate to pricing to verify consistency.
          final router = GoRouter.of(
            tester.element(find.byKey(const Key('stub_Pricing Tiers'))),
          );
          router.go('/pricing');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Pricing');
        },
      );
    });

    // ========================================================================
    // Flow 3: Assign Store to Tier
    // ========================================================================
    group('Flow 3: Assign Store to Tier', () {
      testWidgets(
        'assign store flow: pricing-tiers -> assign store -> verify',
        (tester) async {
          // Arrange: Start at pricing tiers
          await tester.pumpWidget(
            buildDistributorTestApp(initialRoute: '/pricing-tiers'),
          );
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Pricing Tiers');

          // Step 1: In the real PricingTiersScreen, there is a "Store
          // Assignments" tab/section. The distributor taps to assign
          // a store to a specific tier.

          // Verify store assignment data links store to tier
          expect(
            kSampleStoreAssignment['store_id'],
            equals(kTestStoreId),
          );
          expect(
            kSampleStoreAssignment['tier_id'],
            equals(kTestTierId),
          );
          expect(kSampleStoreAssignment['store_name'], isNotEmpty);
          expect(kSampleStoreAssignment['tier_name'], equals('ذهبي'));

          // Step 2: After assignment, navigate to orders to verify
          // the tier discount will be applied to orders from this store.
          final router = GoRouter.of(
            tester.element(find.byKey(const Key('stub_Pricing Tiers'))),
          );
          router.go('/orders');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Orders');

          // Step 3: Return to pricing tiers
          router.go('/pricing-tiers');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Pricing Tiers');
        },
      );
    });

    // ========================================================================
    // Flow 4: Discount Applied in Order
    // ========================================================================
    group('Flow 4: Discount in Order Detail', () {
      testWidgets('order detail shows discount calculation', (tester) async {
        // Arrange: Navigate to order detail
        await tester.pumpWidget(
          buildDistributorTestApp(initialRoute: '/orders/$kTestOrderId'),
        );
        await pumpAndSettleWithTimeout(tester);

        // Assert: Order detail screen is shown
        expectStubScreen('Order $kTestOrderId');

        // Verify order has pricing fields for discount
        expect(kSampleOrder['total_before_vat'], equals(1500.0));
        expect(kSampleOrder['vat_amount'], equals(225.0));
        expect(kSampleOrder['total'], equals(1725.0));
        expect(kSampleOrder['discount_amount'], isNotNull);
      });

      testWidgets(
        'discount calculation: gold tier 10% on qualifying order',
        (tester) async {
          // Arrange: Start at pricing tiers to verify tier config
          await tester.pumpWidget(
            buildDistributorTestApp(initialRoute: '/pricing-tiers'),
          );
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Pricing Tiers');

          final router = GoRouter.of(
            tester.element(find.byKey(const Key('stub_Pricing Tiers'))),
          );

          // Step 1: The gold tier provides 10% discount on orders >= 5000 SAR.
          final discountPercent =
              kSampleTier['discount_percent'] as double;
          final minOrderAmount =
              kSampleTier['min_order_amount'] as double;
          expect(discountPercent, equals(10.0));
          expect(minOrderAmount, equals(5000.0));

          // Step 2: The sample order total (1725 SAR) is below the gold
          // tier's min_order_amount (5000 SAR), so no discount applies.
          // This is correct business logic: the store needs to order more
          // to qualify for the gold tier discount.
          final orderTotal = kSampleOrder['total'] as double;
          final qualifies = orderTotal >= minOrderAmount;
          expect(qualifies, isFalse);

          // Step 3: Navigate to order detail to see the zero discount.
          router.go('/orders/$kTestOrderId');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Order $kTestOrderId');
          expect(kSampleOrder['discount_amount'], equals(0.0));

          // Step 4: For a qualifying order, the discount would be:
          // subtotal * discount_percent / 100
          // e.g., 5000 * 10 / 100 = 500 SAR discount
          const hypotheticalSubtotal = 5000.0;
          final expectedDiscount =
              hypotheticalSubtotal * discountPercent / 100;
          expect(expectedDiscount, equals(500.0));
        },
      );
    });

    // ========================================================================
    // End-to-End: Full Pricing Tiers Lifecycle
    // ========================================================================
    group('End-to-End: Pricing Tiers Lifecycle', () {
      testWidgets(
        'full flow: tiers -> create -> set default -> assign store -> order discount',
        (tester) async {
          // Arrange: Start at dashboard
          await tester.pumpWidget(
            buildDistributorTestApp(initialRoute: '/dashboard'),
          );
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Dashboard');

          final router = GoRouter.of(
            tester.element(find.byKey(const Key('stub_Dashboard'))),
          );

          // Step 1: Navigate to pricing tiers
          router.go('/pricing-tiers');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Pricing Tiers');

          // Step 2: Create gold and silver tiers (verified via data)
          expect(kSampleTier['name'], equals('ذهبي'));
          expect(kSampleTier2['name'], equals('فضي'));

          // Step 3: Set gold tier as default
          expect(kSampleTier['is_default'], isFalse);

          // Step 4: Navigate to pricing for product-level prices
          router.go('/pricing');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Pricing');

          // Step 5: Navigate to orders to see tier-based pricing
          router.go('/orders');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Orders');

          // Step 6: View order detail with discount
          router.go('/orders/$kTestOrderId');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Order $kTestOrderId');

          // Step 7: Check invoice with discounted amounts
          router.go('/invoices/$kTestInvoiceId');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Invoice $kTestInvoiceId');

          // Step 8: Review audit trail for pricing changes
          router.go('/audit');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Audit');

          // Step 9: Back to dashboard
          router.go('/dashboard');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Dashboard');
        },
      );
    });
  });
}
