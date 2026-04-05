import 'package:admin/screens/purchases/ai_invoice_import_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_helpers.dart';

void main() {
  setUpAll(() {
    suppressOverflowErrors();
    registerAdminFallbackValues();
  });

  setUp(() {
    final mockDb = setupMockDatabase();
    setupTestGetIt(mockDb: mockDb);
  });

  tearDown(() {
    tearDownTestGetIt();
  });

  group('AiInvoiceImportScreen', () {
    testWidgets('renders the screen', (tester) async {
      await tester.pumpWidget(createTestWidget(const AiInvoiceImportScreen()));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(AiInvoiceImportScreen), findsOneWidget);
    });

    testWidgets('shows upload area by default', (tester) async {
      await tester.pumpWidget(createTestWidget(const AiInvoiceImportScreen()));
      await tester.pump(const Duration(milliseconds: 500));

      // Upload view shows camera and gallery icons
      expect(find.byIcon(Icons.camera_alt), findsWidgets);
    });

    testWidgets('has back navigation', (tester) async {
      await tester.pumpWidget(createTestWidget(const AiInvoiceImportScreen()));
      await tester.pump(const Duration(milliseconds: 500));

      // RTL locale uses arrow_forward_rounded for back navigation
      expect(find.byIcon(Icons.arrow_forward_rounded), findsWidgets);
    });

    testWidgets('shows document scanner icon in upload view', (tester) async {
      await tester.pumpWidget(createTestWidget(const AiInvoiceImportScreen()));
      await tester.pump(const Duration(milliseconds: 500));

      // Upload view shows document scanner icon
      expect(find.byIcon(Icons.document_scanner), findsWidgets);
    });
  });
}
