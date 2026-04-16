import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:driver_app/core/providers/app_providers.dart';
import 'package:driver_app/features/deliveries/widgets/sos_button.dart';

// ─── Mocks ──────────────────────────────────────────────────────────────────

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockUser extends Mock implements User {}

class MockUrlLauncherPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements UrlLauncherPlatform {
  final List<String> launchedUrls = [];

  @override
  Future<bool> canLaunch(String url) async => true;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    launchedUrls.add(url);
    return true;
  }
}

void main() {
  late MockSupabaseClient mockClient;
  late MockGoTrueClient mockAuth;
  late MockUser mockUser;
  late MockUrlLauncherPlatform mockUrlLauncher;

  setUpAll(() {
    registerFallbackValue(Uri());
    registerFallbackValue(const LaunchOptions());
  });

  setUp(() {
    mockClient = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    mockUser = MockUser();
    mockUrlLauncher = MockUrlLauncherPlatform();

    when(() => mockClient.auth).thenReturn(mockAuth);
    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.id).thenReturn('driver-001');

    // Mock sa_audit_log: let `from()` throw so the try/catch in SOS handles
    // it gracefully. This verifies the best-effort pattern works.
    // (Post-v40: the SOS flow now routes through DriverAuditService which
    // uses Supabase.instance.client — not the mocked provider — so this
    // mock is primarily documentation; the real singleton swallows errors.)
    when(() => mockClient.from('sa_audit_log')).thenThrow(
      Exception('sa_audit_log mock — expected in test'),
    );

    // Set mock url_launcher platform.
    UrlLauncherPlatform.instance = mockUrlLauncher;
  });

  Widget buildTestWidget({bool showSos = true}) {
    return ProviderScope(
      overrides: [
        supabaseClientProvider.overrideWithValue(mockClient),
      ],
      child: MaterialApp(
        theme: AlhaiTheme.light,
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(
          floatingActionButton: showSos
              ? const SosButton(activeDeliveryId: 'delivery-001')
              : null,
          body: const Center(child: Text('Home')),
        ),
      ),
    );
  }

  group('H4 — SOS Button', () {
    testWidgets('SOS button is visible when provided', (tester) async {
      await tester.pumpWidget(buildTestWidget(showSos: true));
      await tester.pump();

      expect(find.byType(SosButton), findsOneWidget);
      expect(find.byIcon(Icons.sos), findsOneWidget);
    });

    testWidgets('SOS button is NOT visible when not provided', (tester) async {
      await tester.pumpWidget(buildTestWidget(showSos: false));
      await tester.pump();

      expect(find.byType(SosButton), findsNothing);
    });

    testWidgets('tapping SOS shows confirmation dialog', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      await tester.tap(find.byType(SosButton));
      await tester.pumpAndSettle();

      expect(find.text('إشارة استغاثة'), findsOneWidget);
      expect(
        find.text('هل تريد إرسال إشارة استغاثة والاتصال بالطوارئ (999)؟'),
        findsOneWidget,
      );
      expect(find.text('إلغاء'), findsOneWidget);
      expect(find.text('تأكيد الاستغاثة'), findsOneWidget);
    });

    testWidgets('cancel in dialog does NOT trigger SOS', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      await tester.tap(find.byType(SosButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text('إلغاء'));
      await tester.pumpAndSettle();

      // Dialog dismissed, no URL launched.
      expect(find.text('إشارة استغاثة'), findsNothing);
      expect(mockUrlLauncher.launchedUrls, isEmpty);
    });

    testWidgets('confirming dialog launches dialer to 999', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      await tester.tap(find.byType(SosButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text('تأكيد الاستغاثة'));
      await tester.pumpAndSettle();

      // Verify dialer was opened with 999.
      expect(mockUrlLauncher.launchedUrls, contains('tel:999'));

      // Verify confirmation SnackBar.
      expect(find.text('تم إرسال إشارة الاستغاثة'), findsOneWidget);
    });
  });
}
