library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_core/alhai_core.dart' show User, UserRole;
import 'package:cashier/screens/products/edit_price_screen.dart';

import '../../helpers/test_helpers.dart';
import '../../helpers/mock_database.dart';
import '../../helpers/test_factories.dart';

void main() {
  late MockAppDatabase db;
  late MockProductsDao productsDao;
  late MockAuditLogDao auditLogDao;

  // Screen accesses product.updatedAt for price history, so it must be non-null
  // C-4 Stage B: SAR × 100 = cents
  final testProduct = createTestProduct(
    id: 'prod-1',
    name: 'Test Product',
    barcode: '123456789',
    price: 2500,
    costPrice: 1500,
    stockQty: 100,
  ).copyWith(updatedAt: Value(DateTime(2026, 1, 15)));

  setUpAll(() {
    registerCashierFallbackValues();
    // updateProduct(any()) needs a fallback for ProductsTableData
    registerFallbackValue(createTestProduct());
    // For auditLogDao.getLogsByAction(any(), any()) the second arg is an
    // AuditAction enum. Mocktail requires a fallback for non-null matchers.
    registerFallbackValue(AuditAction.priceChange);
    // Wave 10 (P0-30): updatePriceAndCost takes a Drift `Value<int?>`
    // for costPriceCents. Mocktail's any() matcher needs a fallback
    // value of the exact generic type for non-primitives.
    registerFallbackValue(const Value<int?>.absent());
  });

  setUp(() {
    productsDao = MockProductsDao();
    auditLogDao = MockAuditLogDao();

    db = setupMockDatabase(
      productsDao: productsDao,
      auditLogDao: auditLogDao,
    );
    setupTestGetIt(mockDb: db);

    // Default stubs
    when(
      () => productsDao.getProductById(any()),
    ).thenAnswer((_) async => testProduct);
    // Wave 10 (P0-29): screen now uses tenant-isolated `getByIdForStore`
    // for the load + the new `updatePriceAndCost` for the save.
    when(
      () => productsDao.getByIdForStore(any(), any()),
    ).thenAnswer((_) async => testProduct);
    when(() => productsDao.updateProduct(any())).thenAnswer((_) async => true);
    when(
      () => productsDao.updatePriceAndCost(
        productId: any(named: 'productId'),
        priceCents: any(named: 'priceCents'),
        costPriceCents: any(named: 'costPriceCents'),
      ),
    ).thenAnswer((_) async => 1);

    // P1 #9 (2026-04-24): screen now pulls price history from audit_log.
    when(
      () => auditLogDao.getLogsByAction(any(), any()),
    ).thenAnswer((_) async => <AuditLogTableData>[]);
  });

  tearDown(() => tearDownTestGetIt());

  group('EditPriceScreen', () {
    testWidgets('renders correctly with product data', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        createTestWidget(const EditPriceScreen(productId: 'prod-1')),
      );
      await tester.pumpAndSettle();

      expect(find.byType(EditPriceScreen), findsOneWidget);
      expect(find.text('Test Product'), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows loading indicator initially', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      // Use Completer to hold the future without pending timers.
      // Wave 10 (P0-29): screen now calls `getByIdForStore` instead.
      final completer = Completer<ProductsTableData?>();
      when(
        () => productsDao.getByIdForStore(any(), any()),
      ).thenAnswer((_) => completer.future);

      await tester.pumpWidget(
        createTestWidget(const EditPriceScreen(productId: 'prod-1')),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete future to avoid pending timer issues
      completer.complete(testProduct);
      await tester.pumpAndSettle();

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows not found when product is null', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      when(
        () => productsDao.getByIdForStore(any(), any()),
      ).thenAnswer((_) async => null);

      await tester.pumpWidget(
        createTestWidget(const EditPriceScreen(productId: 'nonexistent')),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.search_off_rounded), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('displays price comparison card', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        createTestWidget(const EditPriceScreen(productId: 'prod-1')),
      );
      await tester.pumpAndSettle();

      // P1 #11 (2026-04-24): "Price Comparison" → Arabic "مقارنة الأسعار";
      // current-price inline label → "السعر الحالي".
      expect(find.text('\u0645\u0642\u0627\u0631\u0646\u0629 \u0627\u0644\u0623\u0633\u0639\u0627\u0631'), findsOneWidget);
      expect(find.text('\u0627\u0644\u0633\u0639\u0631 \u0627\u0644\u062d\u0627\u0644\u064a'), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('pre-fills current price in input field', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        createTestWidget(const EditPriceScreen(productId: 'prod-1')),
      );
      await tester.pumpAndSettle();

      // The price input should be pre-filled with the current price
      final textFields = find.byType(TextField);
      expect(textFields, findsWidgets);

      // Verify the price text is displayed — CurrencyFormatter renders
      // "25.00 ر.س" (formatMoney). We assert the numeric part is present.
      expect(find.textContaining('25.00'), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('displays price history card', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        createTestWidget(const EditPriceScreen(productId: 'prod-1')),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.history_rounded), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets(
      'save button is disabled for non-owner roles (permission gate)',
      (tester) async {
        // P1 #7 (2026-04-24): only storeOwner / superAdmin can save edits.
        // Default helper uses UserRole.employee → expect Save button disabled.
        tester.view.physicalSize = const Size(1920, 1080);
        tester.view.devicePixelRatio = 1.0;
        suppressOverflowErrors();

        await tester.pumpWidget(
          createTestWidget(const EditPriceScreen(productId: 'prod-1')),
        );
        await tester.pumpAndSettle();

        // The save button is a FilledButton.icon. Find all and assert the
        // one inside the Tooltip (permission-gate) is disabled.
        final tooltip = find.byTooltip(
          '\u0644\u0627 \u062a\u0645\u0644\u0643 \u0635\u0644\u0627\u062d\u064a\u0629 \u062a\u0639\u062f\u064a\u0644 \u0627\u0644\u0633\u0639\u0631',
        );
        expect(tooltip, findsOneWidget);

        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      },
    );

    testWidgets(
      'save button is enabled for storeOwner role',
      (tester) async {
        tester.view.physicalSize = const Size(1920, 1080);
        tester.view.devicePixelRatio = 1.0;
        suppressOverflowErrors();

        // Wave 9 (P0-02/28): screen now reads `currentUserProvider`
        // (full User) and routes through Permissions, not the
        // userRoleProvider shortcut. Override the user directly.
        await tester.pumpWidget(
          createTestWidget(
            const EditPriceScreen(productId: 'prod-1'),
            overrides: [
              currentUserProvider.overrideWithValue(
                User(
                  id: 'owner-1',
                  phone: '+966500000000',
                  name: 'Store Owner',
                  role: UserRole.storeOwner,
                  createdAt: DateTime(2025),
                ),
              ),
            ],
          ),
        );
        await tester.pumpAndSettle();

        // Tooltip disappears when permitted — screen renders the bare button.
        final tooltip = find.byTooltip(
          '\u0644\u0627 \u062a\u0645\u0644\u0643 \u0635\u0644\u0627\u062d\u064a\u0629 \u062a\u0639\u062f\u064a\u0644 \u0627\u0644\u0633\u0639\u0631',
        );
        expect(tooltip, findsNothing);

        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      },
    );
  });
}
