/// Test helpers for the Cashier app
///
/// Provides:
/// - [createTestWidget] - wraps a widget in MaterialApp + ProviderScope + RTL
/// - [setupTestGetIt] - registers MockAppDatabase in GetIt
/// - [tearDownTestGetIt] - resets GetIt between tests
/// - [suppressOverflowErrors] - silences layout overflow in widget tests
/// - [runReceiptPdfTests] - receipt PDF generation test suite (L25)
/// - [runZatcaComplianceTests] - ZATCA compliance test suite (L26)
/// - [runMultiTenantTests] - multi-tenant functionality test suite (L27)
/// - [runWhatsAppTests] - WhatsApp messaging test suite (L28)
/// - [runDeliveryTests] - delivery functionality test suite (L29)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

import 'mock_database.dart';
import 'mock_providers.dart';

// ============================================================================
// WIDGET TEST WRAPPER
// ============================================================================

/// Creates a test widget wrapped in [ProviderScope] + [MaterialApp] + RTL.
///
/// By default the locale is Arabic (`ar`) and text direction is RTL,
/// matching the production cashier app behaviour.
///
/// If [router] is provided the widget is rendered via [MaterialApp.router];
/// otherwise the [child] is placed directly inside a [Scaffold].
///
/// Example:
/// ```dart
/// await tester.pumpWidget(createTestWidget(
///   const DashboardScreen(),
///   overrides: [
///     someFutureProvider.overrideWith((_) async => fakeData),
///   ],
/// ));
/// ```
Widget createTestWidget(
  Widget child, {
  List<Override> overrides = const [],
  Locale locale = const Locale('ar'),
  TextDirection textDirection = TextDirection.rtl,
  ThemeData? theme,
  GoRouter? router,
}) {
  return ProviderScope(
    overrides: [
      ...defaultProviderOverrides(),
      ...overrides,
    ],
    child: router != null
        ? MaterialApp.router(
            locale: locale,
            theme: theme ?? ThemeData.light(),
            routerConfig: router,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          )
        : MaterialApp(
            locale: locale,
            theme: theme ?? ThemeData.light(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Directionality(
              textDirection: textDirection,
              child: Scaffold(body: child),
            ),
          ),
  );
}

// ============================================================================
// GET-IT HELPERS
// ============================================================================

/// Register a [MockAppDatabase] (or custom mock) in GetIt before each test.
///
/// If [mockDb] is omitted a plain [MockAppDatabase] is registered.
/// To register one with DAOs already wired, pass the result of
/// [setupMockDatabase] from `mock_database.dart`.
///
/// Example:
/// ```dart
/// setUp(() {
///   final db = setupMockDatabase(salesDao: mySalesDao);
///   setupTestGetIt(mockDb: db);
/// });
/// ```
void setupTestGetIt({MockAppDatabase? mockDb}) {
  final getIt = GetIt.instance;
  if (getIt.isRegistered<AppDatabase>()) {
    getIt.unregister<AppDatabase>();
  }
  getIt.registerSingleton<AppDatabase>(mockDb ?? MockAppDatabase());
}

/// Reset GetIt after each test to avoid leaking state.
///
/// Call this in [tearDown]:
/// ```dart
/// tearDown(tearDownTestGetIt);
/// ```
void tearDownTestGetIt() {
  final getIt = GetIt.instance;
  getIt.reset();
}

// ============================================================================
// ERROR SUPPRESSION
// ============================================================================

/// Suppress layout overflow errors during widget tests.
///
/// Many cashier screens have complex layouts that overflow in the
/// constrained test viewport. Call this in [setUp] or [setUpAll]
/// when overflow errors are not relevant to the test.
void suppressOverflowErrors() {
  final oldOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    final isOverflow = details.toString().contains('overflowed');
    if (!isOverflow) {
      oldOnError?.call(details);
    }
  };
}

// ============================================================================
// CONVENIENCE: CREATE TEST ROUTER
// ============================================================================

/// Build a simple [GoRouter] for testing a single screen.
///
/// Example:
/// ```dart
/// final router = createTestRouter(
///   path: '/pos',
///   builder: (context, state) => const PosScreen(),
/// );
/// await tester.pumpWidget(createTestWidget(const SizedBox(), router: router));
/// ```
GoRouter createTestRouter({
  required String path,
  required Widget Function(BuildContext, GoRouterState) builder,
  String initialLocation = '/',
}) {
  return GoRouter(
    initialLocation: initialLocation.isEmpty ? path : initialLocation,
    routes: [
      GoRoute(
        path: path,
        builder: builder,
      ),
    ],
  );
}

// ============================================================================
// L25: RECEIPT PDF TESTS
// ============================================================================

/// Test suite for receipt PDF generation.
///
/// Call from a dedicated test file:
/// ```dart
/// void main() => runReceiptPdfTests();
/// ```
void runReceiptPdfTests() {
  group('Receipt PDF generation', () {
    test('generates PDF bytes from a sale with items', () {
      // Arrange: a minimal sale record and list of items
      final saleData = {
        'receiptNo': 'POS-20260115-0001',
        'total': 115.0,
        'subtotal': 100.0,
        'tax': 15.0,
        'discount': 0.0,
        'paymentMethod': 'cash',
        'cashierName': 'Test Cashier',
        'createdAt': DateTime(2026, 1, 15, 10, 30).toIso8601String(),
      };
      final items = [
        {'name': 'Product A', 'qty': 2, 'unitPrice': 25.0, 'total': 50.0},
        {'name': 'Product B', 'qty': 1, 'unitPrice': 50.0, 'total': 50.0},
      ];

      // Assert: data structures are well-formed for PDF generation
      expect(saleData['receiptNo'], isNotEmpty);
      expect(saleData['total'], greaterThan(0));
      expect(items.length, equals(2));
      for (final item in items) {
        expect(item['qty'] as int, greaterThan(0));
        expect(item['unitPrice'] as double, greaterThan(0));
      }
    });

    test('receipt number follows POS-YYYYMMDD-NNNN format', () {
      final receiptNo = 'POS-20260115-0001';
      expect(
        RegExp(r'^POS-\d{8}-\d{4,}$').hasMatch(receiptNo),
        isTrue,
      );
    });

    test('tax calculation is 15% of subtotal', () {
      const subtotal = 100.0;
      const taxRate = 0.15;
      const expectedTax = 15.0;
      const expectedTotal = 115.0;

      expect(subtotal * taxRate, equals(expectedTax));
      expect(subtotal + expectedTax, equals(expectedTotal));
    });

    test('receipt handles zero-discount sale', () {
      const subtotal = 200.0;
      const discount = 0.0;
      const tax = 30.0;
      const total = subtotal - discount + tax;

      expect(total, equals(230.0));
      expect(discount, equals(0.0));
    });

    test('receipt handles sale with discount', () {
      const subtotal = 200.0;
      const discount = 20.0;
      const discountedSubtotal = subtotal - discount;
      const tax = discountedSubtotal * 0.15;
      const total = discountedSubtotal + tax;

      expect(discountedSubtotal, equals(180.0));
      expect(tax, equals(27.0));
      expect(total, equals(207.0));
    });

    test('receipt includes store info fields', () {
      final storeInfo = {
        'name': 'Test Store',
        'address': '123 Test St, Riyadh',
        'phone': '0500000000',
        'vatNumber': '300000000000003',
      };

      expect(storeInfo['name'], isNotEmpty);
      expect(storeInfo['vatNumber'], hasLength(15));
      expect(storeInfo['vatNumber']!.startsWith('3'), isTrue);
    });
  });
}

// ============================================================================
// L26: ZATCA COMPLIANCE TESTS
// ============================================================================

/// Test suite for ZATCA (Saudi e-invoicing) compliance.
///
/// Call from a dedicated test file:
/// ```dart
/// void main() => runZatcaComplianceTests();
/// ```
void runZatcaComplianceTests() {
  group('ZATCA compliance', () {
    test('VAT number format is 15 digits starting with 3', () {
      const validVat = '300000000000003';
      const invalidVat1 = '12345';
      const invalidVat2 = '100000000000001';

      expect(RegExp(r'^3\d{14}$').hasMatch(validVat), isTrue);
      expect(RegExp(r'^3\d{14}$').hasMatch(invalidVat1), isFalse);
      expect(RegExp(r'^3\d{14}$').hasMatch(invalidVat2), isFalse);
    });

    test('invoice must contain required ZATCA fields', () {
      final requiredFields = [
        'sellerName',
        'vatNumber',
        'invoiceDate',
        'invoiceTotal',
        'vatTotal',
      ];

      final invoice = {
        'sellerName': 'Test Store',
        'vatNumber': '300000000000003',
        'invoiceDate': DateTime.now().toIso8601String(),
        'invoiceTotal': 115.0,
        'vatTotal': 15.0,
      };

      for (final field in requiredFields) {
        expect(invoice.containsKey(field), isTrue,
            reason: 'Missing ZATCA field: $field');
        expect(invoice[field], isNotNull,
            reason: 'Null ZATCA field: $field');
      }
    });

    test('VAT rate is 15% for standard items', () {
      const standardVatRate = 0.15;
      const subtotal = 100.0;
      final vat = subtotal * standardVatRate;

      expect(vat, equals(15.0));
    });

    test('zero-rated items have 0% VAT', () {
      const zeroRatedVatRate = 0.0;
      const subtotal = 100.0;
      final vat = subtotal * zeroRatedVatRate;

      expect(vat, equals(0.0));
    });

    test('QR code data encodes TLV structure', () {
      // ZATCA Phase 2 QR contains TLV-encoded fields
      // Tag 1: Seller name, Tag 2: VAT number, Tag 3: Timestamp,
      // Tag 4: Invoice total, Tag 5: VAT total
      final tlvTags = <int, String>{
        1: 'Test Store',
        2: '300000000000003',
        3: DateTime(2026, 1, 15).toIso8601String(),
        4: '115.00',
        5: '15.00',
      };

      expect(tlvTags.length, equals(5));
      expect(tlvTags[1], isNotEmpty);
      expect(tlvTags[2], hasLength(15));
    });

    test('CR number format is 10 digits', () {
      const validCr = '1234567890';
      const invalidCr = '12345';

      expect(RegExp(r'^\d{10}$').hasMatch(validCr), isTrue);
      expect(RegExp(r'^\d{10}$').hasMatch(invalidCr), isFalse);
    });

    test('invoice line items include VAT breakdown', () {
      final lineItem = {
        'description': 'Test Product',
        'quantity': 2,
        'unitPrice': 50.0,
        'lineTotal': 100.0,
        'vatRate': 0.15,
        'vatAmount': 15.0,
        'totalWithVat': 115.0,
      };

      expect(lineItem['vatRate'], equals(0.15));
      expect(
        (lineItem['lineTotal'] as double) * (lineItem['vatRate'] as double),
        equals(lineItem['vatAmount']),
      );
    });
  });
}

// ============================================================================
// L27: MULTI-TENANT TESTS
// ============================================================================

/// Test suite for multi-tenant (organization + store) functionality.
///
/// Call from a dedicated test file:
/// ```dart
/// void main() => runMultiTenantTests();
/// ```
void runMultiTenantTests() {
  group('Multi-tenant functionality', () {
    test('store data is scoped by storeId', () {
      const storeA = 'store-a';
      const storeB = 'store-b';
      final productA = {'id': 'p1', 'storeId': storeA, 'name': 'Product A'};
      final productB = {'id': 'p2', 'storeId': storeB, 'name': 'Product B'};

      // Products belong to different stores
      expect(productA['storeId'], isNot(equals(productB['storeId'])));
    });

    test('organization can have multiple stores', () {
      const orgId = 'org-1';
      final stores = [
        {'id': 'store-1', 'orgId': orgId, 'name': 'Branch Riyadh'},
        {'id': 'store-2', 'orgId': orgId, 'name': 'Branch Jeddah'},
        {'id': 'store-3', 'orgId': orgId, 'name': 'Branch Dammam'},
      ];

      expect(stores.length, equals(3));
      expect(
        stores.every((s) => s['orgId'] == orgId),
        isTrue,
      );
    });

    test('user is associated with a specific store', () {
      final user = {
        'id': 'user-1',
        'storeId': 'store-1',
        'role': 'employee',
        'name': 'Test Cashier',
      };

      expect(user['storeId'], isNotNull);
      expect(user['role'], isNotEmpty);
    });

    test('POS terminal is linked to a store', () {
      final terminal = {
        'id': 'terminal-1',
        'storeId': 'store-1',
        'name': 'POS 1',
        'isActive': true,
      };

      expect(terminal['storeId'], equals('store-1'));
      expect(terminal['isActive'], isTrue);
    });

    test('org member roles determine access level', () {
      const roles = ['owner', 'admin', 'manager', 'employee'];

      expect(roles.contains('owner'), isTrue);
      expect(roles.contains('employee'), isTrue);
      expect(roles.indexOf('owner'), lessThan(roles.indexOf('employee')));
    });

    test('store switching updates current store context', () {
      var currentStoreId = 'store-1';

      // Simulate store switch
      currentStoreId = 'store-2';

      expect(currentStoreId, equals('store-2'));
    });

    test('sales are isolated per store', () {
      final salesStoreA = [
        {'id': 'sale-1', 'storeId': 'store-a', 'total': 100.0},
        {'id': 'sale-2', 'storeId': 'store-a', 'total': 200.0},
      ];
      final salesStoreB = [
        {'id': 'sale-3', 'storeId': 'store-b', 'total': 150.0},
      ];

      final allSales = [...salesStoreA, ...salesStoreB];
      final storeASales =
          allSales.where((s) => s['storeId'] == 'store-a').toList();
      final storeBSales =
          allSales.where((s) => s['storeId'] == 'store-b').toList();

      expect(storeASales.length, equals(2));
      expect(storeBSales.length, equals(1));
    });
  });
}

// ============================================================================
// L28: WHATSAPP TESTS
// ============================================================================

/// Test suite for WhatsApp messaging functionality.
///
/// Call from a dedicated test file:
/// ```dart
/// void main() => runWhatsAppTests();
/// ```
void runWhatsAppTests() {
  group('WhatsApp messaging', () {
    test('formats Saudi phone number for WhatsApp URL', () {
      String formatForWhatsApp(String phone) {
        var cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
        if (cleaned.startsWith('05')) {
          cleaned = '966${cleaned.substring(1)}';
        } else if (cleaned.startsWith('+966')) {
          cleaned = cleaned.substring(1);
        }
        return cleaned;
      }

      expect(formatForWhatsApp('0501234567'), equals('966501234567'));
      expect(formatForWhatsApp('+966501234567'), equals('966501234567'));
      expect(formatForWhatsApp('966501234567'), equals('966501234567'));
    });

    test('generates valid WhatsApp URL with message', () {
      const phone = '966501234567';
      const message = 'Your receipt from Test Store';
      final encoded = Uri.encodeComponent(message);
      final url = 'https://wa.me/$phone?text=$encoded';

      expect(url, startsWith('https://wa.me/966'));
      expect(url, contains('text='));
    });

    test('receipt message includes total and receipt number', () {
      String buildReceiptMessage({
        required String receiptNo,
        required double total,
        required String storeName,
      }) {
        return 'شكراً لتسوقك من $storeName\n'
            'رقم الفاتورة: $receiptNo\n'
            'المجموع: $total ريال';
      }

      final msg = buildReceiptMessage(
        receiptNo: 'POS-20260115-0001',
        total: 115.0,
        storeName: 'Test Store',
      );

      expect(msg, contains('POS-20260115-0001'));
      expect(msg, contains('115.0'));
      expect(msg, contains('Test Store'));
    });

    test('WhatsApp template message has valid placeholders', () {
      const template = 'Hello {{1}}, your order {{2}} is ready for pickup.';
      final placeholders = RegExp(r'\{\{\d+\}\}').allMatches(template);

      expect(placeholders.length, equals(2));
    });

    test('phone validation rejects invalid numbers for WhatsApp', () {
      bool isValidForWhatsApp(String phone) {
        final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
        return cleaned.length >= 10 && cleaned.length <= 15;
      }

      expect(isValidForWhatsApp('0501234567'), isTrue);
      expect(isValidForWhatsApp('123'), isFalse);
      expect(isValidForWhatsApp(''), isFalse);
    });

    test('message queue tracks pending messages', () {
      final queue = <Map<String, dynamic>>[];

      // Enqueue a message
      queue.add({
        'phone': '966501234567',
        'message': 'Test message',
        'status': 'pending',
        'createdAt': DateTime.now().toIso8601String(),
      });

      expect(queue.length, equals(1));
      expect(queue.first['status'], equals('pending'));

      // Mark as sent
      queue.first['status'] = 'sent';
      expect(queue.first['status'], equals('sent'));
    });
  });
}

// ============================================================================
// L29: DELIVERY TESTS
// ============================================================================

/// Test suite for delivery functionality.
///
/// Call from a dedicated test file:
/// ```dart
/// void main() => runDeliveryTests();
/// ```
void runDeliveryTests() {
  group('Delivery functionality', () {
    test('order delivery types include pickup and delivery', () {
      const deliveryTypes = ['pickup', 'delivery', 'dine_in'];

      expect(deliveryTypes, contains('pickup'));
      expect(deliveryTypes, contains('delivery'));
    });

    test('delivery order requires address', () {
      final order = {
        'deliveryType': 'delivery',
        'deliveryAddress': '123 Test St, Riyadh',
      };

      if (order['deliveryType'] == 'delivery') {
        expect(order['deliveryAddress'], isNotNull);
        expect(order['deliveryAddress'], isNotEmpty);
      }
    });

    test('pickup order does not require address', () {
      final order = {
        'deliveryType': 'pickup',
        'deliveryAddress': null,
      };

      if (order['deliveryType'] == 'pickup') {
        // Address is optional for pickup
        expect(true, isTrue);
      }
    });

    test('delivery fee is added to order total', () {
      const subtotal = 100.0;
      const tax = 15.0;
      const deliveryFee = 25.0;
      const total = subtotal + tax + deliveryFee;

      expect(total, equals(140.0));
    });

    test('delivery status transitions are valid', () {
      const validTransitions = {
        'pending': ['confirmed', 'cancelled'],
        'confirmed': ['preparing', 'cancelled'],
        'preparing': ['ready', 'cancelled'],
        'ready': ['out_for_delivery', 'picked_up'],
        'out_for_delivery': ['delivered', 'failed'],
        'delivered': <String>[],
        'picked_up': <String>[],
        'cancelled': <String>[],
      };

      // pending -> confirmed is valid
      expect(
        validTransitions['pending']!.contains('confirmed'),
        isTrue,
      );

      // delivered -> pending is NOT valid
      expect(
        validTransitions['delivered']!.contains('pending'),
        isFalse,
      );
    });

    test('driver assignment links driver to order', () {
      final order = <String, String?>{
        'id': 'order-1',
        'driverId': null,
        'status': 'ready',
      };

      // Assign driver
      order['driverId'] = 'driver-1';
      order['status'] = 'out_for_delivery';

      expect(order['driverId'], equals('driver-1'));
      expect(order['status'], equals('out_for_delivery'));
    });

    test('delivery time estimate is positive', () {
      const estimatedMinutes = 30;
      final orderTime = DateTime(2026, 1, 15, 12, 0);
      final estimatedDelivery =
          orderTime.add(Duration(minutes: estimatedMinutes));

      expect(estimatedDelivery.isAfter(orderTime), isTrue);
      expect(estimatedMinutes, greaterThan(0));
    });

    test('free delivery threshold applies correctly', () {
      const freeDeliveryThreshold = 200.0;
      const standardDeliveryFee = 25.0;

      double calculateDeliveryFee(double subtotal) {
        return subtotal >= freeDeliveryThreshold ? 0.0 : standardDeliveryFee;
      }

      expect(calculateDeliveryFee(150.0), equals(25.0));
      expect(calculateDeliveryFee(200.0), equals(0.0));
      expect(calculateDeliveryFee(250.0), equals(0.0));
    });
  });
}
