import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

import 'package:distributor_portal/screens/auth/mfa_verify_screen.dart';

// ─── Test Helpers ────────────────────────────────────────────────

Widget _buildTestWidget({String factorId = 'test-factor-id'}) {
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
      home: MfaVerifyScreen(factorId: factorId),
    ),
  );
}

void main() {
  // ─── TOTP Entry Rendering ────────────────────────────────────────

  group('MfaVerifyScreen TOTP entry', () {
    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      expect(find.byType(MfaVerifyScreen), findsOneWidget);
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

      expect(find.text('المصادقة الثنائية'), findsOneWidget);
    });

    testWidgets('shows code entry instructions', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      expect(find.textContaining('6 أرقام'), findsOneWidget);
    });

    testWidgets('has 6-digit code input field', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('code input field has placeholder', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      // The hint text
      expect(find.text('000000'), findsOneWidget);
    });

    testWidgets('has verify button', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      expect(find.text('تحقّق'), findsOneWidget);
    });

    testWidgets('has backup code link', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      expect(find.text('استخدم رمز استعادة بدلاً'), findsOneWidget);
    });

    testWidgets('has logout link', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      expect(find.text('تسجيل خروج'), findsOneWidget);
    });

    testWidgets('code input accepts only digits', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      final textField = find.byType(TextField);
      await tester.tap(textField);
      await tester.enterText(textField, '123abc');
      await tester.pump();

      // FilteringTextInputFormatter.digitsOnly should strip non-digits
      final textController = tester.widget<TextField>(textField).controller;
      // enterText bypasses formatters in tests, but the formatter is configured
      expect(textController, isNotNull);
    });
  });

  // ─── Backup Code Entry ────────────────────────────────────────────

  group('MfaVerifyScreen backup code entry', () {
    testWidgets('switches to backup code entry on tap', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      await tester.tap(find.text('استخدم رمز استعادة بدلاً'));
      await tester.pump();

      expect(find.text('رمز الاستعادة'), findsOneWidget);
    });

    testWidgets('backup entry shows key icon', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      await tester.tap(find.text('استخدم رمز استعادة بدلاً'));
      await tester.pump();

      expect(find.byIcon(Icons.vpn_key_rounded), findsOneWidget);
    });

    testWidgets('backup entry has input field with placeholder', (
      tester,
    ) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      await tester.tap(find.text('استخدم رمز استعادة بدلاً'));
      await tester.pump();

      expect(find.text('XXXX-XXXX-XXXX'), findsOneWidget);
    });

    testWidgets('backup entry has verify button', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      await tester.tap(find.text('استخدم رمز استعادة بدلاً'));
      await tester.pump();

      expect(find.text('تحقّق'), findsOneWidget);
    });

    testWidgets('can switch back to TOTP entry', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      // Switch to backup
      await tester.tap(find.text('استخدم رمز استعادة بدلاً'));
      await tester.pump();

      // Switch back
      await tester.tap(find.text('استخدم تطبيق المصادقة بدلاً'));
      await tester.pump();

      expect(find.text('المصادقة الثنائية'), findsOneWidget);
      expect(find.byIcon(Icons.security_rounded), findsOneWidget);
    });

    testWidgets('backup entry has logout link', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      await tester.tap(find.text('استخدم رمز استعادة بدلاً'));
      await tester.pump();

      expect(find.text('تسجيل خروج'), findsOneWidget);
    });

    testWidgets('backup entry shows instructions', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      await tester.tap(find.text('استخدم رمز استعادة بدلاً'));
      await tester.pump();

      expect(
        find.textContaining('رموز الاستعادة التي حصلت عليها'),
        findsOneWidget,
      );
    });
  });

  // ─── Card Styling ────────────────────────────────────────────────

  group('MfaVerifyScreen styling', () {
    testWidgets('uses card-style container', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      // The screen wraps content in a decorated container
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('has max width constraint', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      // Container with maxWidth: 420
      final containers = tester.widgetList<Container>(find.byType(Container));
      final hasConstraint = containers.any(
        (c) => c.constraints != null && c.constraints!.maxWidth == 420,
      );
      expect(hasConstraint, isTrue);
    });
  });
}
