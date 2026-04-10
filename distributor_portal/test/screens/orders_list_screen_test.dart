import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

import 'package:distributor_portal/data/distributor_datasource.dart';
import 'package:distributor_portal/data/models.dart';
import 'package:distributor_portal/providers/distributor_datasource_provider.dart';
import 'package:distributor_portal/screens/orders/distributor_orders_screen.dart';

/// Minimal fake that returns empty defaults so provider errors don't
/// pollute stdout during widget tests.
class _FakeDistributorDatasource extends DistributorDatasource {
  _FakeDistributorDatasource();

  @override
  Future<List<DistributorOrder>> getOrders({
    String? status,
    int limit = 50,
    int offset = 0,
  }) async {
    return <DistributorOrder>[];
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
        home: const DistributorOrdersScreen(),
      ),
    );
  }

  group('DistributorOrdersScreen', () {
    testWidgets('renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('has transparent background', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.backgroundColor, Colors.transparent);
    });

    testWidgets('shows search field', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('has TabBar for status filtering', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(TabBar), findsOneWidget);
    });

    testWidgets('has search icon', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byIcon(Icons.search), findsWidgets);
    });

    testWidgets('is a ConsumerStatefulWidget', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(DistributorOrdersScreen), findsOneWidget);
    });
  });
}
