import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

import 'package:distributor_portal/data/distributor_datasource.dart';
import 'package:distributor_portal/data/models.dart';
import 'package:distributor_portal/providers/distributor_datasource_provider.dart';
import 'package:distributor_portal/screens/invoices/invoice_list_screen.dart';

// ─── Fake datasource ────────────────────────────────────────────

class _FakeInvoiceDatasource extends DistributorDatasource {
  final List<DistributorInvoice> invoices;

  _FakeInvoiceDatasource({this.invoices = const []});

  @override
  Future<List<DistributorInvoice>> getInvoices({
    String? status,
    int limit = 50,
    int offset = 0,
  }) async {
    if (status == null) return invoices;
    return invoices.where((inv) => inv.status == status).toList();
  }
}

// ─── Test data ──────────────────────────────────────────────────

final _sampleInvoices = [
  DistributorInvoice(
    id: 'inv-1',
    storeId: 'store-1',
    invoiceNumber: 'INV-2026-0001',
    invoiceType: 'standard_tax',
    status: 'issued',
    customerName: 'متجر الرياض',
    subtotal: 1000,
    taxAmount: 150,
    total: 1150,
    createdAt: DateTime(2026, 4, 16),
    issuedAt: DateTime(2026, 4, 16),
  ),
  DistributorInvoice(
    id: 'inv-2',
    storeId: 'store-2',
    invoiceNumber: 'INV-2026-0002',
    invoiceType: 'standard_tax',
    status: 'draft',
    customerName: 'متجر جدة',
    subtotal: 500,
    taxAmount: 75,
    total: 575,
    createdAt: DateTime(2026, 4, 15),
  ),
  DistributorInvoice(
    id: 'inv-3',
    storeId: 'store-3',
    invoiceNumber: 'INV-2026-0003',
    invoiceType: 'standard_tax',
    status: 'paid',
    customerName: 'متجر الدمام',
    subtotal: 2000,
    taxAmount: 300,
    total: 2300,
    createdAt: DateTime(2026, 4, 14),
    issuedAt: DateTime(2026, 4, 14),
  ),
];

// ─── Helpers ────────────────────────────────────────────────────

Widget _buildTestWidget({List<DistributorInvoice> invoices = const []}) {
  return ProviderScope(
    overrides: [
      distributorDatasourceProvider.overrideWithValue(
        _FakeInvoiceDatasource(invoices: invoices),
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
      home: const InvoiceListScreen(),
    ),
  );
}

// ─── Tests ──────────────────────────────────────────────────────

void main() {
  group('InvoiceListScreen', () {
    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      expect(find.byType(InvoiceListScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('shows header with title', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      expect(find.text('الفواتير'), findsOneWidget);
      expect(find.byIcon(Icons.receipt_long), findsOneWidget);
    });

    testWidgets('shows filter tabs', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      expect(find.byType(FilterChip), findsWidgets);
      expect(find.text('الكل'), findsOneWidget);
      expect(find.text('مسودة'), findsOneWidget);
    });

    testWidgets('shows search bar', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('shows empty state when no invoices', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      // Allow async provider to resolve
      await tester.pumpAndSettle();

      expect(find.text('لا توجد فواتير بعد'), findsOneWidget);
    });

    testWidgets('shows invoice data when invoices exist', (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(invoices: _sampleInvoices),
      );
      await tester.pumpAndSettle();

      expect(find.text('INV-2026-0001'), findsOneWidget);
      expect(find.text('متجر الرياض'), findsOneWidget);
      expect(find.text('INV-2026-0002'), findsOneWidget);
    });

    testWidgets('shows currency formatted amounts', (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(invoices: _sampleInvoices),
      );
      await tester.pumpAndSettle();

      // Check for formatted amounts with ر.س
      expect(find.textContaining('ر.س'), findsWidgets);
    });

    testWidgets('shows status badges', (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(invoices: _sampleInvoices),
      );
      await tester.pumpAndSettle();

      expect(find.text('صادرة'), findsWidgets);
      expect(find.text('مدفوعة'), findsWidgets);
    });

    testWidgets('search filters results', (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(invoices: _sampleInvoices),
      );
      await tester.pumpAndSettle();

      // Type in search field
      await tester.enterText(find.byType(TextField), 'الرياض');
      await tester.pump();

      expect(find.text('متجر الرياض'), findsOneWidget);
      // Other invoices should be filtered out
      expect(find.text('متجر جدة'), findsNothing);
    });

    testWidgets('search shows no results message', (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(invoices: _sampleInvoices),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'غير موجود');
      await tester.pump();

      expect(find.text('لا توجد نتائج للبحث'), findsOneWidget);
    });
  });
}
