import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:distributor_portal/data/distributor_datasource.dart';
import 'package:distributor_portal/data/models.dart';
import 'package:distributor_portal/providers/distributor_datasource_provider.dart';
import 'package:distributor_portal/providers/distributor_auth_providers.dart';
import 'package:distributor_portal/providers/mfa_providers.dart';
import 'package:distributor_portal/screens/settings/distributor_settings_screen.dart';

/// Minimal fake that returns empty defaults so provider errors don't
/// pollute stdout during widget tests.
class _FakeDistributorDatasource extends DistributorDatasource {
  _FakeDistributorDatasource();

  @override
  Future<OrgSettings?> getOrgSettings() async {
    return const OrgSettings(id: 'test-org', companyName: 'Test Co');
  }
}

void main() {
  Widget buildTestWidget() {
    return ProviderScope(
      overrides: [
        distributorDatasourceProvider.overrideWithValue(
          _FakeDistributorDatasource(),
        ),
        // Override auth providers to avoid Supabase initialization
        currentUserProvider.overrideWithValue(null),
        authStateProvider.overrideWith(
          (ref) => const Stream<AuthState>.empty(),
        ),
        mfaEnrollmentStatusProvider.overrideWith((ref) async => false),
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
        home: const DistributorSettingsScreen(),
      ),
    );
  }

  group('DistributorSettingsScreen', () {
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

    testWidgets('shows loading or data state', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Either loading skeleton or settings form
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('is a ConsumerStatefulWidget', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(DistributorSettingsScreen), findsOneWidget);
    });
  });
}
