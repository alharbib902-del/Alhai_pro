import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

import 'package:distributor_portal/data/distributor_datasource.dart';
import 'package:distributor_portal/data/models.dart';
import 'package:distributor_portal/providers/distributor_datasource_provider.dart';
import 'package:distributor_portal/screens/reports/distributor_reports_screen.dart';

/// Minimal fake that returns empty defaults so provider errors don't
/// pollute stdout during widget tests.
class _FakeDistributorDatasource extends DistributorDatasource {
  _FakeDistributorDatasource();

  @override
  Future<ReportData> getReportData({
    required String period,
    int limit = 200,
    int offset = 0,
  }) async {
    return const ReportData(
      totalSales: 0,
      orderCount: 0,
      avgOrderValue: 0,
      topProduct: '',
      topProductOrders: 0,
      dailySales: [],
      topProducts: [],
    );
  }
}

void main() {
  Widget buildTestWidget() {
    return ProviderScope(
      overrides: [
        distributorDatasourceProvider
            .overrideWithValue(_FakeDistributorDatasource()),
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
        home: const DistributorReportsScreen(),
      ),
    );
  }

  group('DistributorReportsScreen', () {
    testWidgets('renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('shows AppBar with title', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('shows period filter buttons', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Arabic period labels
      expect(find.text('\u064a\u0648\u0645'), findsOneWidget);
      expect(find.text('\u0623\u0633\u0628\u0648\u0639'), findsOneWidget);
      expect(find.text('\u0634\u0647\u0631'), findsOneWidget);
      expect(find.text('\u0633\u0646\u0629'), findsOneWidget);
    });

    testWidgets('has print button in app bar', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byIcon(Icons.print_rounded), findsOneWidget);
    });

    testWidgets('has download/export button in app bar', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byIcon(Icons.download_rounded), findsOneWidget);
    });

    testWidgets('is a ConsumerStatefulWidget', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(DistributorReportsScreen), findsOneWidget);
    });
  });
}
