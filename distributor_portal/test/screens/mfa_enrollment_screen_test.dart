import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

import 'package:distributor_portal/screens/auth/mfa_enrollment_screen.dart';

// ─── Test Helpers ────────────────────────────────────────────────

Widget _buildTestWidget({bool forced = false}) {
  return ProviderScope(
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
      home: MfaEnrollmentScreen(forced: forced),
    ),
  );
}

void main() {
  // ─── Intro Step Rendering ────────────────────────────────────────

  group('MfaEnrollmentScreen intro step', () {
    testWidgets('renders intro step by default', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      expect(find.byType(MfaEnrollmentScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows security icon', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      expect(find.byIcon(Icons.security_rounded), findsOneWidget);
    });

    testWidgets('shows title', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      expect(find.text('تعزيز أمان حسابك'), findsOneWidget);
    });

    testWidgets('shows description', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      expect(
        find.textContaining('المصادقة الثنائية تضيف طبقة حماية'),
        findsOneWidget,
      );
    });

    testWidgets('lists authenticator apps', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      expect(find.text('Google Authenticator'), findsOneWidget);
      expect(find.text('Authy'), findsOneWidget);
      expect(find.text('1Password'), findsOneWidget);
    });

    testWidgets('shows start button', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      expect(find.text('البدء'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('has AppBar with MFA title', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      expect(find.text('المصادقة الثنائية'), findsOneWidget);
    });
  });

  // ─── Widget Structure ────────────────────────────────────────────

  group('MfaEnrollmentScreen widget structure', () {
    testWidgets('has a SingleChildScrollView for overflow', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('uses proper container constraints', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      final constrainedBox = tester.widgetList<Container>(
        find.byType(Container),
      );
      expect(constrainedBox, isNotEmpty);
    });

    testWidgets('shows Microsoft Authenticator', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      expect(find.text('Microsoft Authenticator'), findsOneWidget);
    });
  });

  // ─── Back Navigation ─────────────────────────────────────────────

  group('MfaEnrollmentScreen navigation', () {
    testWidgets('has back button in intro step', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });
  });

  // ─── Forced Enrollment (super_admin MFA mandatory) ─────────────

  group('MfaEnrollmentScreen forced enrollment', () {
    testWidgets('forced mode shows mandatory notice banner', (tester) async {
      await tester.pumpWidget(_buildTestWidget(forced: true));
      await tester.pump();

      expect(
        find.textContaining('كأدمن عام، المصادقة الثنائية إلزامية'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.shield_rounded), findsOneWidget);
    });

    testWidgets('forced mode hides back button on intro step', (tester) async {
      await tester.pumpWidget(_buildTestWidget(forced: true));
      await tester.pump();

      expect(find.byIcon(Icons.arrow_back), findsNothing);
    });

    testWidgets('non-forced mode does not show mandatory notice', (
      tester,
    ) async {
      await tester.pumpWidget(_buildTestWidget(forced: false));
      await tester.pump();

      expect(
        find.textContaining('كأدمن عام، المصادقة الثنائية إلزامية'),
        findsNothing,
      );
    });

    testWidgets('non-forced mode shows back button', (tester) async {
      await tester.pumpWidget(_buildTestWidget(forced: false));
      await tester.pump();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });
  });
}
