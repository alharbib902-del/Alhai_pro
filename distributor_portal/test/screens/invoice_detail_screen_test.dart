import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:distributor_portal/data/distributor_datasource.dart';
import 'package:distributor_portal/data/models.dart';
import 'package:distributor_portal/providers/distributor_datasource_provider.dart';
import 'package:distributor_portal/screens/invoices/invoice_detail_screen.dart';

// ─── Fake datasource ────────────────────────────────────────────

class _FakeInvoiceDatasource extends DistributorDatasource {
  final DistributorInvoice? invoice;
  final List<DistributorOrderItem> orderItems;

  _FakeInvoiceDatasource({this.invoice, this.orderItems = const []});

  @override
  Future<DistributorInvoice?> getInvoiceById(String invoiceId) async {
    return invoice;
  }

  @override
  Future<List<DistributorOrderItem>> getOrderItems(String orderId) async {
    return orderItems;
  }
}

// ─── Test data ──────────────────────────────────────────────────

final _sampleInvoice = DistributorInvoice(
  id: 'inv-1',
  storeId: 'store-1',
  invoiceNumber: 'INV-2026-0001',
  invoiceType: 'standard_tax',
  status: 'issued',
  saleId: 'order-1',
  customerName: 'متجر الرياض',
  customerVatNumber: '300000000000003',
  customerAddress: 'الرياض، حي الملز',
  customerPhone: '0501234567',
  subtotal: 1000,
  taxRate: 15,
  taxAmount: 150,
  total: 1150,
  createdAt: DateTime(2026, 4, 16),
  issuedAt: DateTime(2026, 4, 16),
  cashierName: 'شركة الموزع',
);

final _invoiceWithQr = DistributorInvoice(
  id: 'inv-2',
  storeId: 'store-1',
  invoiceNumber: 'INV-2026-0002',
  invoiceType: 'standard_tax',
  status: 'paid',
  saleId: 'order-2',
  customerName: 'متجر جدة',
  subtotal: 500,
  taxRate: 15,
  taxAmount: 75,
  total: 575,
  createdAt: DateTime(2026, 4, 16),
  zatcaQr: 'AQ1HZXJtYW4gU2VsbGVyAg8zMDAwMDAwMDAwMDAwMDMD',
);

final _invoiceWithDiscount = DistributorInvoice(
  id: 'inv-3',
  storeId: 'store-1',
  invoiceNumber: 'INV-2026-0003',
  invoiceType: 'standard_tax',
  status: 'issued',
  customerName: 'متجر الخبر',
  subtotal: 2000,
  discount: 200,
  taxRate: 15,
  taxAmount: 270,
  total: 2070,
  createdAt: DateTime(2026, 4, 16),
);

final _sampleItems = [
  DistributorOrderItem(
    id: 'item-1',
    orderId: 'order-1',
    productId: 'prod-1',
    productName: 'شاي الكرك',
    quantity: 10,
    suggestedPrice: 50,
    distributorPrice: 50,
  ),
  DistributorOrderItem(
    id: 'item-2',
    orderId: 'order-1',
    productId: 'prod-2',
    productName: 'قهوة عربية',
    quantity: 20,
    suggestedPrice: 25,
    distributorPrice: 25,
  ),
];

// ─── Helpers ────────────────────────────────────────────────────

Widget _buildTestWidget({
  DistributorInvoice? invoice,
  List<DistributorOrderItem> items = const [],
  String invoiceId = 'inv-1',
}) {
  return ProviderScope(
    overrides: [
      distributorDatasourceProvider.overrideWithValue(
        _FakeInvoiceDatasource(invoice: invoice, orderItems: items),
      ),
    ],
    child: MaterialApp(
      title: 'Test',
      theme: AlhaiTheme.light,
      locale: const Locale('ar'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: InvoiceDetailScreen(invoiceId: invoiceId),
    ),
  );
}

// ─── Tests ──────────────────────────────────────────────────────

void main() {
  group('InvoiceDetailScreen', () {
    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(invoice: _sampleInvoice, items: _sampleItems),
      );
      await tester.pump();

      expect(find.byType(InvoiceDetailScreen), findsOneWidget);
    });

    testWidgets('shows invoice number in action bar', (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(invoice: _sampleInvoice, items: _sampleItems),
      );
      await tester.pumpAndSettle();

      // Invoice number appears in action bar and in meta section
      expect(find.textContaining('INV-2026-0001'), findsWidgets);
    });

    testWidgets('shows print button', (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(invoice: _sampleInvoice, items: _sampleItems),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.print), findsOneWidget);
      expect(find.text('طباعة'), findsOneWidget);
    });

    testWidgets('shows invoice type header', (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(invoice: _sampleInvoice, items: _sampleItems),
      );
      await tester.pumpAndSettle();

      expect(find.text('فاتورة ضريبية'), findsOneWidget);
      expect(find.text('Tax Invoice'), findsOneWidget);
    });

    testWidgets('shows seller info', (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(invoice: _sampleInvoice, items: _sampleItems),
      );
      await tester.pumpAndSettle();

      expect(find.text('البائع / Seller'), findsOneWidget);
      expect(find.text('شركة الموزع'), findsOneWidget);
    });

    testWidgets('shows buyer info', (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(invoice: _sampleInvoice, items: _sampleItems),
      );
      await tester.pumpAndSettle();

      expect(find.text('المشتري / Buyer'), findsOneWidget);
      expect(find.text('متجر الرياض'), findsOneWidget);
      expect(find.textContaining('300000000000003'), findsOneWidget);
      expect(find.text('الرياض، حي الملز'), findsOneWidget);
    });

    testWidgets('shows invoice meta (number, date, status)', (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(invoice: _sampleInvoice, items: _sampleItems),
      );
      await tester.pumpAndSettle();

      expect(find.text('رقم الفاتورة: '), findsOneWidget);
      expect(find.text('صادرة'), findsWidgets);
    });

    testWidgets('shows line items table', (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(invoice: _sampleInvoice, items: _sampleItems),
      );
      await tester.pumpAndSettle();

      expect(find.text('البنود / Items'), findsOneWidget);
      expect(find.text('شاي الكرك'), findsOneWidget);
      expect(find.text('قهوة عربية'), findsOneWidget);
    });

    testWidgets('shows totals section', (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(invoice: _sampleInvoice, items: _sampleItems),
      );
      await tester.pumpAndSettle();

      expect(find.text('المجموع الفرعي'), findsOneWidget);
      expect(find.textContaining('15%'), findsOneWidget);
      // "الإجمالي" appears in table column header and totals section
      expect(find.text('الإجمالي'), findsWidgets);
    });

    testWidgets('shows QR placeholder when no zatcaQr', (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(invoice: _sampleInvoice, items: _sampleItems),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('ZATCA'), findsWidgets);
      expect(find.byIcon(Icons.qr_code_2), findsOneWidget);
    });

    testWidgets('shows QR image when zatcaQr present', (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(invoice: _invoiceWithQr),
      );
      await tester.pumpAndSettle();

      expect(find.byType(QrImageView), findsOneWidget);
    });

    testWidgets('shows discount row when discount > 0', (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(invoice: _invoiceWithDiscount),
      );
      await tester.pumpAndSettle();

      expect(find.text('الخصم'), findsOneWidget);
    });

    testWidgets('shows not found for null invoice', (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(invoice: null),
      );
      await tester.pumpAndSettle();

      expect(find.text('الفاتورة غير موجودة'), findsOneWidget);
    });

    testWidgets('shows fallback when no line items', (tester) async {
      final invoiceNoOrder = DistributorInvoice(
        id: 'inv-no-order',
        storeId: 'store-1',
        invoiceNumber: 'INV-2026-0099',
        subtotal: 100,
        taxAmount: 15,
        total: 115,
        createdAt: DateTime(2026, 4, 16),
        // saleId is null so no order items are fetched
      );
      await tester.pumpWidget(
        _buildTestWidget(invoice: invoiceNoOrder),
      );
      await tester.pumpAndSettle();

      expect(find.text('تفاصيل البنود غير متاحة'), findsOneWidget);
    });
  });
}
