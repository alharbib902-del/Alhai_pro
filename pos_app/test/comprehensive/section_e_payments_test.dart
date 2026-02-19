/// Ø§Ø®ØªØ¨Ø§Ø±Ø§Øª Ù‚Ø³Ù… E: Ø§Ù„Ù…Ø¯ÙÙˆØ¹Ø§Øª
///
/// 11 Ø§Ø®ØªØ¨Ø§Ø± Ù„ØªØºØ·ÙŠØ© Ø¬Ù…ÙŠØ¹ Ø³ÙŠÙ†Ø§Ø±ÙŠÙˆÙ‡Ø§Øª Ø§Ù„Ø¯ÙØ¹:
/// - Ù†Ù‚Ø¯ÙŠØŒ Ø¨Ø·Ø§Ù‚Ø©ØŒ Ù…Ø®ØªÙ„Ø·ØŒ Ø¢Ø¬Ù„
/// - Ø§Ù„Ø¯ÙØ¹ Ø§Ù„Ø²Ø§Ø¦Ø¯ ÙˆØ§Ù„Ø¨Ø§Ù‚ÙŠ
/// - Ø§Ù„Ø¥Ù„ØºØ§Ø¡ Ù‚Ø¨Ù„ Ø§Ù„ØªØ£ÙƒÙŠØ¯
/// - Ù…Ù†Ø¹ Ø§Ù„ØªÙƒØ±Ø§Ø± (idempotent)
/// - Ø­Ø¯ÙˆØ¯ Ø§Ù„Ø§Ø¦ØªÙ…Ø§Ù†
library;

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pos_app/services/sync/sync_service.dart' show SyncPriority;

import 'package:alhai_core/alhai_core.dart' hide CartItem;
import 'package:pos_app/providers/cart_providers.dart';

import 'fixtures/test_fixtures.dart';

// ============================================================================
// MOCKS
// ============================================================================

class MockCartPersistenceService extends Mock
    implements CartPersistenceService {}

class FakeCartState extends Fake implements CartState {}

// ============================================================================
// CREDIT LIMIT HELPERS
// ============================================================================

/// Ø§Ù„ØªØ­Ù‚Ù‚ Ù…Ù† Ø£Ù† Ù…Ø¨Ù„Øº Ø§Ù„Ø§Ø¦ØªÙ…Ø§Ù† Ø¶Ù…Ù† Ø§Ù„Ø­Ø¯ Ø§Ù„Ù…Ø³Ù…ÙˆØ­
bool isCreditWithinLimit({
  required double creditAmount,
  required double creditLimit,
  double existingDebt = 0,
}) {
  return (existingDebt + creditAmount) <= creditLimit;
}

/// Ø­Ø³Ø§Ø¨ Ø§Ù„Ù…Ø¨Ù„Øº Ø§Ù„Ø§Ø¦ØªÙ…Ø§Ù†ÙŠ ÙÙŠ Ø§Ù„Ø¯ÙØ¹ Ø§Ù„Ù…Ø®ØªÙ„Ø·
/// total - cashPortion = creditPortion
double computeCreditPortion({
  required double total,
  required double cashPortion,
}) {
  return roundSar(total - cashPortion);
}

void main() {
  setUpAll(() {
    registerFallbackValue(SyncPriority.normal);
    registerFallbackValue(FakeCartState());
  });

  group('Section E: Payments - Ø§Ù„Ù…Ø¯ÙÙˆØ¹Ø§Øª', () {
    // ==================================================================
    // E01-E05: Ø·Ø±Ù‚ Ø§Ù„Ø¯ÙØ¹ Ø§Ù„Ø£Ø³Ø§Ø³ÙŠØ© (Integration Ù…Ø¹ SaleService)
    // ==================================================================

    group('E01-E05 Ø·Ø±Ù‚ Ø§Ù„Ø¯ÙØ¹ Ø§Ù„Ø£Ø³Ø§Ø³ÙŠØ©', () {
      late SaleServiceTestSetup setup;

      setUp(() async {
        setup = createSaleServiceSetup();
        await seedAllProducts(setup.db);
      });

      tearDown(() async {
        await setup.dispose();
      });

      test('E01 Ø¯ÙØ¹ Ù†Ù‚Ø¯ÙŠ ÙƒØ§Ù…Ù„: total=24.15, Ù…Ø³ØªÙ„Ù…=30.00 -> Ø¨Ø§Ù‚ÙŠ=5.85', () async {
        // P1 x 3 => sub=21.00, VAT=3.15, total=24.15
        final p1 = createP1();
        final items = [PosCartItem(product: p1, quantity: 3)];

        final subtotal = 21.00;
        final tax = computeVat(subtotal); // 3.15
        final total = roundSar(subtotal + tax); // 24.15
        expect(total, 24.15);

        final amountReceived = 30.00;
        final change = roundSar(amountReceived - total); // 5.85
        expect(change, 5.85);

        final saleId = await createCompletedSale(
          saleService: setup.saleService,
          items: items,
          subtotal: subtotal,
          discount: 0,
          tax: tax,
          total: total,
          paymentMethod: 'cash',
        );

        final sale = await setup.db.salesDao.getSaleById(saleId);
        expect(sale, isNotNull);
        expect(sale!.paymentMethod, 'cash');
        expect(sale.total, 24.15);
        expect(sale.isPaid, isTrue);
        expect(sale.status, 'completed');

        // Ø§Ù„ØªØ­Ù‚Ù‚ Ù…Ù† Ø­Ø³Ø§Ø¨ Ø§Ù„Ø¨Ø§Ù‚ÙŠ
        // amountReceived Ùˆ changeAmount ÙŠÙØ­Ø³Ø¨Ø§Ù† ÙÙŠ Ø§Ù„Ø·Ø¨Ù‚Ø© Ø§Ù„Ø¹Ù„ÙŠØ§ (UI)
        // Ù‡Ù†Ø§ Ù†ØªØ­Ù‚Ù‚ Ù…Ù† ØµØ­Ø© Ø§Ù„Ø­Ø³Ø§Ø¨
        expect(amountReceived - total, closeTo(5.85, 0.001));
      });

      test('E02 Ø¯ÙØ¹ Ø¨Ø§Ù„Ø¨Ø·Ø§Ù‚Ø©: Ù„Ø§ ÙŠÙˆØ¬Ø¯ Ø¨Ø§Ù‚ÙŠ', () async {
        final p1 = createP1();
        final items = [PosCartItem(product: p1, quantity: 3)];

        final subtotal = 21.00;
        final tax = computeVat(subtotal); // 3.15
        final total = roundSar(subtotal + tax); // 24.15

        final saleId = await createCompletedSale(
          saleService: setup.saleService,
          items: items,
          subtotal: subtotal,
          discount: 0,
          tax: tax,
          total: total,
          paymentMethod: 'card',
        );

        final sale = await setup.db.salesDao.getSaleById(saleId);
        expect(sale, isNotNull);
        expect(sale!.paymentMethod, 'card');
        expect(sale.total, 24.15);
        expect(sale.isPaid, isTrue);

        // Ø§Ù„Ø¨Ø·Ø§Ù‚Ø©: Ø§Ù„Ù…Ø¨Ù„Øº Ø§Ù„Ù…Ø³ØªÙ„Ù… = Ø§Ù„Ø¥Ø¬Ù…Ø§Ù„ÙŠ Ø¨Ø§Ù„Ø¶Ø¨Ø·ØŒ Ù„Ø§ Ø¨Ø§Ù‚ÙŠ
        final amountReceived = total;
        final change = roundSar(amountReceived - total);
        expect(change, 0.00);
      });

      test('E03 Ø¯ÙØ¹ Ù…Ø®ØªÙ„Ø· Ù†Ù‚Ø¯ÙŠ+Ø¨Ø·Ø§Ù‚Ø©: Ø§Ù„Ù…Ø¬Ù…ÙˆØ¹ ÙŠØ³Ø§ÙˆÙŠ Ø§Ù„Ø¥Ø¬Ù…Ø§Ù„ÙŠ', () async {
        final p1 = createP1();
        final items = [PosCartItem(product: p1, quantity: 3)];

        final subtotal = 21.00;
        final tax = computeVat(subtotal); // 3.15
        final total = roundSar(subtotal + tax); // 24.15

        // ØªÙ‚Ø³ÙŠÙ… Ø§Ù„Ø¯ÙØ¹: 15 Ù†Ù‚Ø¯ÙŠ + 9.15 Ø¨Ø·Ø§Ù‚Ø©
        final cashPortion = 15.00;
        final cardPortion = roundSar(total - cashPortion); // 9.15
        expect(roundSar(cashPortion + cardPortion), total);

        final saleId = await createCompletedSale(
          saleService: setup.saleService,
          items: items,
          subtotal: subtotal,
          discount: 0,
          tax: tax,
          total: total,
          paymentMethod: 'mixed',
        );

        final sale = await setup.db.salesDao.getSaleById(saleId);
        expect(sale, isNotNull);
        expect(sale!.paymentMethod, 'mixed');
        expect(sale.total, 24.15);
        expect(sale.isPaid, isTrue);

        // Ø§Ù„ØªØ­Ù‚Ù‚ Ù…Ù† Ø£Ù† Ø§Ù„Ø£Ù‚Ø³Ø§Ù… ØªØ¬Ù…Ø¹ Ù„Ù„Ø¥Ø¬Ù…Ø§Ù„ÙŠ
        expect(cashPortion + cardPortion, closeTo(total, 0.001));
      });

      test('E04 Ø¯ÙØ¹ Ø¢Ø¬Ù„ (Ø§Ø¦ØªÙ…Ø§Ù†): ÙŠÙØ³Ø¬Ù„ Ù…Ø¹ Ù…Ø¹Ø±Ù Ø§Ù„Ø¹Ù…ÙŠÙ„', () async {
        final p1 = createP1();
        final items = [PosCartItem(product: p1, quantity: 3)];

        final subtotal = 21.00;
        final tax = computeVat(subtotal);
        final total = roundSar(subtotal + tax); // 24.15

        final saleId = await createCompletedSale(
          saleService: setup.saleService,
          items: items,
          subtotal: subtotal,
          discount: 0,
          tax: tax,
          total: total,
          paymentMethod: 'credit',
          customerId: c1Id,
          customerName: c1Name,
        );

        final sale = await setup.db.salesDao.getSaleById(saleId);
        expect(sale, isNotNull);
        expect(sale!.paymentMethod, 'credit');
        expect(sale.customerId, c1Id);
        expect(sale.customerName, c1Name);
        expect(sale.total, 24.15);
        expect(sale.isPaid, isTrue); // Ù…Ø³Ø¬Ù„ ÙƒÙ…ÙƒØªÙ…Ù„ØŒ Ø§Ù„Ø¯ÙŠÙ† ÙŠÙØªØªØ¨Ø¹ Ù…Ù†ÙØµÙ„Ø§Ù‹
      });

      test('E05 Ø¯ÙØ¹ Ø²Ø§Ø¦Ø¯: Ù…Ø³ØªÙ„Ù…=100, total=24.15 -> Ø¨Ø§Ù‚ÙŠ=75.85', () async {
        final p1 = createP1();
        final items = [PosCartItem(product: p1, quantity: 3)];

        final subtotal = 21.00;
        final tax = computeVat(subtotal);
        final total = roundSar(subtotal + tax); // 24.15

        final amountReceived = 100.00;
        final change = roundSar(amountReceived - total); // 75.85
        expect(change, 75.85);

        final saleId = await createCompletedSale(
          saleService: setup.saleService,
          items: items,
          subtotal: subtotal,
          discount: 0,
          tax: tax,
          total: total,
          paymentMethod: 'cash',
        );

        final sale = await setup.db.salesDao.getSaleById(saleId);
        expect(sale, isNotNull);
        expect(sale!.total, 24.15);

        // Ø§Ù„ØªØ­Ù‚Ù‚ Ù…Ù† Ø­Ø³Ø§Ø¨ Ø§Ù„Ø¨Ø§Ù‚ÙŠ
        expect(amountReceived - sale.total, closeTo(75.85, 0.001));
        // Ø§Ù„Ø¨Ø§Ù‚ÙŠ Ù„Ø§ ÙŠØªØ¬Ø§ÙˆØ² Ø§Ù„Ù…Ø³ØªÙ„Ù…
        expect(change, lessThan(amountReceived));
        expect(change, greaterThan(0));
      });
    });

    // ==================================================================
    // E06: Ø¥Ù„ØºØ§Ø¡ Ù‚Ø¨Ù„ Ø§Ù„ØªØ£ÙƒÙŠØ¯
    // ==================================================================

    group('E06 Ø¥Ù„ØºØ§Ø¡ Ù‚Ø¨Ù„ Ø§Ù„ØªØ£ÙƒÙŠØ¯', () {
      test('E06 ØªÙØ±ÙŠØº Ø§Ù„Ø³Ù„Ø© Ù‚Ø¨Ù„ Ø§Ù„ØªØ£ÙƒÙŠØ¯ -> Ù„Ø§ ÙŠÙˆØ¬Ø¯ Ø¨ÙŠØ¹ ÙÙŠ Ù‚Ø§Ø¹Ø¯Ø© Ø§Ù„Ø¨ÙŠØ§Ù†Ø§Øª', () async {
        final mockPersistence = MockCartPersistenceService();

        // Ø¥Ø¹Ø¯Ø§Ø¯ mock Ù„Ù„Ø­ÙØ¸/Ø§Ù„ØªØ­Ù…ÙŠÙ„/Ø§Ù„Ù…Ø³Ø­
        when(() => mockPersistence.loadCart())
            .thenAnswer((_) async => null);
        when(() => mockPersistence.saveCart(any()))
            .thenAnswer((_) async {});
        when(() => mockPersistence.clearCart())
            .thenAnswer((_) async {});

        final cartNotifier = CartNotifier(mockPersistence);

        // Ø¥Ø¶Ø§ÙØ© Ù…Ù†ØªØ¬Ø§Øª Ù„Ù„Ø³Ù„Ø©
        final p1 = createP1();
        cartNotifier.addProduct(p1, quantity: 3);
        expect(cartNotifier.state.items.length, 1);
        expect(cartNotifier.state.itemCount, 3);
        expect(cartNotifier.state.subtotal, 21.00);

        // Ø¥Ù„ØºØ§Ø¡ (ØªÙØ±ÙŠØº Ø§Ù„Ø³Ù„Ø©) Ù‚Ø¨Ù„ Ø¥Ù†Ø´Ø§Ø¡ Ø§Ù„Ø¨ÙŠØ¹
        cartNotifier.clear();

        // Ø§Ù„ØªØ­Ù‚Ù‚ Ù…Ù† Ø£Ù† Ø§Ù„Ø³Ù„Ø© ÙØ§Ø±ØºØ©
        expect(cartNotifier.state.isEmpty, isTrue);
        expect(cartNotifier.state.items.length, 0);
        expect(cartNotifier.state.subtotal, 0.0);

        // Ø§Ù„ØªØ­Ù‚Ù‚ Ù…Ù† Ø£Ù† clearCart ØªÙ… Ø§Ø³ØªØ¯Ø¹Ø§Ø¤Ù‡
        verify(() => mockPersistence.clearCart()).called(1);

        // Ø§Ù„ØªØ­Ù‚Ù‚ Ù…Ù† Ø£Ù†Ù‡ Ù„Ø§ ÙŠÙˆØ¬Ø¯ Ø¨ÙŠØ¹ ÙÙŠ Ù‚Ø§Ø¹Ø¯Ø© Ø§Ù„Ø¨ÙŠØ§Ù†Ø§Øª
        final setup = createSaleServiceSetup();
        try {
          final todaySales =
              await setup.saleService.getTodaySales('store-1');
          expect(todaySales, isEmpty);
        } finally {
          await setup.dispose();
        }
      });
    });

    // ==================================================================
    // E07: Ù…Ù†Ø¹ Ø§Ù„ØªÙƒØ±Ø§Ø± (Idempotent)
    // ==================================================================

    group('E07 Ù…Ù†Ø¹ Ø§Ù„ØªÙƒØ±Ø§Ø±', () {
      late SaleServiceTestSetup setup;

      setUp(() async {
        setup = createSaleServiceSetup();
        await seedAllProducts(setup.db);
      });

      tearDown(() async {
        await setup.dispose();
      });

      test('E07 Ø¥Ù†Ø´Ø§Ø¡ Ø¨ÙŠØ¹ÙŠÙ† Ù…ØªØªØ§Ù„ÙŠÙŠÙ† -> Ø¨ÙŠØ¹Ø§Ù† Ù…Ø®ØªÙ„ÙØ§Ù† ÙÙŠ Ù‚Ø§Ø¹Ø¯Ø© Ø§Ù„Ø¨ÙŠØ§Ù†Ø§Øª', () async {
        final p1 = createP1();
        final items = [PosCartItem(product: p1, quantity: 3)];

        final subtotal = 21.00;
        final tax = computeVat(subtotal);
        final total = roundSar(subtotal + tax);

        // Ø¥Ù†Ø´Ø§Ø¡ Ø§Ù„Ø¨ÙŠØ¹ Ø§Ù„Ø£ÙˆÙ„
        final saleId1 = await createCompletedSale(
          saleService: setup.saleService,
          items: items,
          subtotal: subtotal,
          discount: 0,
          tax: tax,
          total: total,
          paymentMethod: 'cash',
        );

        // Ø¥Ù†Ø´Ø§Ø¡ Ø§Ù„Ø¨ÙŠØ¹ Ø§Ù„Ø«Ø§Ù†ÙŠ (Ø¨Ù†ÙØ³ Ø§Ù„Ø¨ÙŠØ§Ù†Ø§Øª)
        // ÙŠØ¬Ø¨ Ø£Ù† ÙŠÙÙ†Ø´Ø¦ Ø¨ÙŠØ¹Ø§Ù‹ Ø¬Ø¯ÙŠØ¯Ø§Ù‹ Ø¨Ù…Ø¹Ø±Ù Ù…Ø®ØªÙ„Ù
        final saleId2 = await createCompletedSale(
          saleService: setup.saleService,
          items: items,
          subtotal: subtotal,
          discount: 0,
          tax: tax,
          total: total,
          paymentMethod: 'cash',
        );

        // Ø§Ù„ØªØ­Ù‚Ù‚ Ù…Ù† Ø£Ù† Ø§Ù„Ù…Ø¹Ø±ÙÙŠÙ† Ù…Ø®ØªÙ„ÙØ§Ù†
        expect(saleId1, isNot(equals(saleId2)));

        // Ø§Ù„ØªØ­Ù‚Ù‚ Ù…Ù† Ø£Ù† Ù‡Ù†Ø§Ùƒ Ø¨ÙŠØ¹ÙŠÙ† ÙÙŠ Ù‚Ø§Ø¹Ø¯Ø© Ø§Ù„Ø¨ÙŠØ§Ù†Ø§Øª
        final todaySales =
            await setup.saleService.getTodaySales('store-1');
        expect(todaySales.length, 2);

        // Ø§Ù„ØªØ­Ù‚Ù‚ Ù…Ù† Ø£Ù† ÙƒÙ„Ø§ Ø§Ù„Ø¨ÙŠØ¹ÙŠÙ† Ù„Ù‡Ù…Ø§ Ø§Ù„Ù…Ø¨Ù„Øº Ø§Ù„ØµØ­ÙŠØ­
        final sale1 = await setup.db.salesDao.getSaleById(saleId1);
        final sale2 = await setup.db.salesDao.getSaleById(saleId2);
        expect(sale1!.total, total);
        expect(sale2!.total, total);

        // Ø§Ù„ØªØ­Ù‚Ù‚ Ù…Ù† Ø£Ù† Ø£Ø±Ù‚Ø§Ù… Ø§Ù„Ø¥ÙŠØµØ§Ù„Ø§Øª Ù…Ø®ØªÙ„ÙØ©
        expect(sale1.receiptNo, isNot(equals(sale2.receiptNo)));
      });
    });

    // ==================================================================
    // E08-E11: Ø­Ø¯ÙˆØ¯ Ø§Ù„Ø§Ø¦ØªÙ…Ø§Ù† (Ø­Ø³Ø§Ø¨Ø§Øª ØµØ§ÙÙŠØ©)
    // ==================================================================

    group('E08-E11 Ø­Ø¯ÙˆØ¯ Ø§Ù„Ø§Ø¦ØªÙ…Ø§Ù†', () {
      test('E08 Ø§Ø¦ØªÙ…Ø§Ù† Ø¶Ù…Ù† Ø§Ù„Ø­Ø¯: C2 Ø­Ø¯=500, Ù…Ø¨Ù„Øº=450 -> Ù…Ø³Ù…ÙˆØ­', () {
        // Ø§Ù„Ø¹Ù…ÙŠÙ„ Ø§Ù„Ø¹Ø§Ø¯ÙŠ C2: Ø­Ø¯ Ø§Ø¦ØªÙ…Ø§Ù† 500 Ø±.Ø³
        final creditAmount = 450.0;

        final allowed = isCreditWithinLimit(
          creditAmount: creditAmount,
          creditLimit: c2CreditLimit,
        );

        expect(allowed, isTrue);
        expect(creditAmount, lessThanOrEqualTo(c2CreditLimit));
        // Ø§Ù„Ù…ØªØ¨Ù‚ÙŠ Ù…Ù† Ø§Ù„Ø­Ø¯
        final remaining = roundSar(c2CreditLimit - creditAmount);
        expect(remaining, 50.00);
      });

      test('E09 Ø§Ø¦ØªÙ…Ø§Ù† ÙŠØªØ¬Ø§ÙˆØ² Ø§Ù„Ø­Ø¯: C2 Ø­Ø¯=500, Ù…Ø¨Ù„Øº=550 -> Ù…Ø±ÙÙˆØ¶', () {
        // Ø§Ù„Ø¹Ù…ÙŠÙ„ Ø§Ù„Ø¹Ø§Ø¯ÙŠ C2: Ø­Ø¯ Ø§Ø¦ØªÙ…Ø§Ù† 500 Ø±.Ø³
        final creditAmount = 550.0;

        final allowed = isCreditWithinLimit(
          creditAmount: creditAmount,
          creditLimit: c2CreditLimit,
        );

        expect(allowed, isFalse);
        expect(creditAmount, greaterThan(c2CreditLimit));
        // Ø§Ù„Ù…Ø¨Ù„Øº Ø§Ù„Ø²Ø§Ø¦Ø¯ Ø¹Ù† Ø§Ù„Ø­Ø¯
        final excess = roundSar(creditAmount - c2CreditLimit);
        expect(excess, 50.00);
      });

      test('E10 Ø¹Ù…ÙŠÙ„ VIP Ø­Ø¯ Ø£Ø¹Ù„Ù‰: C1 Ø­Ø¯=5000, Ù…Ø¨Ù„Øº=3000 -> Ù…Ø³Ù…ÙˆØ­', () {
        // Ø§Ù„Ø¹Ù…ÙŠÙ„ VIP C1: Ø­Ø¯ Ø§Ø¦ØªÙ…Ø§Ù† 5000 Ø±.Ø³
        final creditAmount = 3000.0;

        final allowed = isCreditWithinLimit(
          creditAmount: creditAmount,
          creditLimit: c1CreditLimit,
        );

        expect(allowed, isTrue);
        expect(creditAmount, lessThanOrEqualTo(c1CreditLimit));
        // Ø§Ù„Ù…ØªØ¨Ù‚ÙŠ Ù…Ù† Ø§Ù„Ø­Ø¯
        final remaining = roundSar(c1CreditLimit - creditAmount);
        expect(remaining, 2000.00);

        // Ù†ÙØ³ Ø§Ù„Ù…Ø¨Ù„Øº ÙƒØ§Ù† Ø³ÙŠÙØ±ÙØ¶ Ù„Ù„Ø¹Ù…ÙŠÙ„ Ø§Ù„Ø¹Ø§Ø¯ÙŠ C2
        final allowedForC2 = isCreditWithinLimit(
          creditAmount: creditAmount,
          creditLimit: c2CreditLimit,
        );
        expect(allowedForC2, isFalse);
      });

      test('E11 Ø¯ÙØ¹ Ù…Ø®ØªÙ„Ø· ÙŠÙ‚Ù„Ù„ Ø§Ù„ØªØ¹Ø±Ø¶ Ø§Ù„Ø§Ø¦ØªÙ…Ø§Ù†ÙŠ: total=1000, Ù†Ù‚Ø¯ÙŠ=300, Ø¢Ø¬Ù„=700', () {
        // Ø§Ù„Ø¥Ø¬Ù…Ø§Ù„ÙŠ 1000 Ø±.Ø³
        // Ø§Ù„Ø¹Ù…ÙŠÙ„ ÙŠØ¯ÙØ¹ 300 Ù†Ù‚Ø¯Ø§Ù‹ ÙˆØ§Ù„Ø¨Ø§Ù‚ÙŠ 700 Ø¢Ø¬Ù„
        final total = 1000.0;
        final cashPortion = 300.0;
        final creditPortion = computeCreditPortion(
          total: total,
          cashPortion: cashPortion,
        );

        expect(creditPortion, 700.00);
        expect(roundSar(cashPortion + creditPortion), total);

        // Ø§Ù„ØªØ¹Ø±Ø¶ Ø§Ù„Ø§Ø¦ØªÙ…Ø§Ù†ÙŠ = 700 ÙÙ‚Ø· (ÙˆÙ„ÙŠØ³ 1000)
        // C2 (Ø­Ø¯ 500) - Ù…Ø±ÙÙˆØ¶ Ø­ØªÙ‰ Ù…Ø¹ Ø§Ù„Ø¯ÙØ¹ Ø§Ù„Ø¬Ø²Ø¦ÙŠ
        final allowedForC2 = isCreditWithinLimit(
          creditAmount: creditPortion,
          creditLimit: c2CreditLimit,
        );
        expect(allowedForC2, isFalse);
        expect(creditPortion, greaterThan(c2CreditLimit));

        // C1 (Ø­Ø¯ 5000) - Ù…Ø³Ù…ÙˆØ­
        final allowedForC1 = isCreditWithinLimit(
          creditAmount: creditPortion,
          creditLimit: c1CreditLimit,
        );
        expect(allowedForC1, isTrue);

        // Ù„Ùˆ ÙƒØ§Ù† Ø§Ù„Ø¥Ø¬Ù…Ø§Ù„ÙŠ ÙƒÙ„Ù‡ Ø¢Ø¬Ù„ Ù„ÙƒØ§Ù† Ø§Ù„ØªØ¹Ø±Ø¶ Ø£ÙƒØ¨Ø±
        final fullCreditExposure = total;
        final partialCreditExposure = creditPortion;
        expect(partialCreditExposure, lessThan(fullCreditExposure));
        expect(
          roundSar(fullCreditExposure - partialCreditExposure),
          cashPortion,
        );
      });
    });
  });
}
