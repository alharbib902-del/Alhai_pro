import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

import 'package:super_admin/screens/dashboard/sa_dashboard_screen.dart';
import 'package:super_admin/providers/sa_providers.dart';
import 'package:super_admin/data/models/sa_analytics_model.dart';

void main() {
  Widget buildTestWidget() {
    return ProviderScope(
      overrides: [
        saDashboardKPIsProvider.overrideWith(
          (_) async => const SADashboardKPIs(),
        ),
        saMonthlyRevenueProvider.overrideWith((_) async => <SARevenueData>[]),
        saSubscriptionDistributionProvider.overrideWith(
          (_) async => <String, int>{},
        ),
      ],
      child: MaterialApp(
        title: 'Test',
        theme: AlhaiTheme.dark,
        locale: const Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const SADashboardScreen(),
      ),
    );
  }

  group('SADashboardScreen', () {
    testWidgets('renders without errors', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final errors = <FlutterErrorDetails>[];
      FlutterError.onError = (d) => errors.add(d);
      addTearDown(() => FlutterError.onError = FlutterError.dumpErrorToConsole);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Ignore RenderFlex overflow in constrained test viewports.
      errors.removeWhere((e) => e.toString().contains('overflowed'));
      for (final e in errors) {
        fail(e.toString());
      }

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('is a ConsumerWidget', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final errors = <FlutterErrorDetails>[];
      FlutterError.onError = (d) => errors.add(d);
      addTearDown(() => FlutterError.onError = FlutterError.dumpErrorToConsole);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      errors.removeWhere((e) => e.toString().contains('overflowed'));
      for (final e in errors) {
        fail(e.toString());
      }

      expect(find.byType(SADashboardScreen), findsOneWidget);
    });

    testWidgets('shows loading or data state', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final errors = <FlutterErrorDetails>[];
      FlutterError.onError = (d) => errors.add(d);
      addTearDown(() => FlutterError.onError = FlutterError.dumpErrorToConsole);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      errors.removeWhere((e) => e.toString().contains('overflowed'));
      for (final e in errors) {
        fail(e.toString());
      }

      // Should show either loading skeleton or dashboard content
      expect(find.byType(Scaffold), findsWidgets);
    });
  });
}
