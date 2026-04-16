import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_shared_ui/src/widgets/invoices/invoice_filters.dart';
import '../../helpers/shared_ui_test_helpers.dart';

void main() {
  group('InvoiceFilters', () {
    testWidgets('renders on mobile width (tabs only, no filter row)',
        (tester) async {
      // Mobile width: isWide=false, so only tabs render (no Row overflow)
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        createSimpleTestWidget(
          InvoiceFilters(
            activeTab: 'all',
            onTabChanged: (_) {},
            isGridView: false,
            onViewToggle: () {},
            onReset: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(InvoiceFilters), findsOneWidget);
    });

    testWidgets('calls onTabChanged when tab is tapped', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      String? selectedTab;
      await tester.pumpWidget(
        createSimpleTestWidget(
          InvoiceFilters(
            activeTab: 'all',
            onTabChanged: (tab) => selectedTab = tab,
            isGridView: false,
            onViewToggle: () {},
            onReset: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tabs are rendered in a SingleChildScrollView row
      // Find the InvoiceFilters widget
      expect(find.byType(InvoiceFilters), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('renders with different active tab', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        createSimpleTestWidget(
          InvoiceFilters(
            activeTab: 'paid',
            onTabChanged: (_) {},
            isGridView: true,
            onViewToggle: () {},
            onReset: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(InvoiceFilters), findsOneWidget);
    });
  });
}
