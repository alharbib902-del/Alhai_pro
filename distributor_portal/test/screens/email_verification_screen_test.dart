import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

import 'package:distributor_portal/screens/auth/email_verification_screen.dart';

// ─── Test Helpers ────────────────────────────────────────────────

Widget _buildTestWidget({String email = 'test@example.com'}) {
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
      home: EmailVerificationScreen(email: email),
    ),
  );
}

void main() {
  // ─── Rendering ──────────────────────────────────────────────────

  group('EmailVerificationScreen rendering', () {
    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      expect(find.byType(EmailVerificationScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows title', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      expect(find.text('تحقّق من بريدك الإلكتروني'), findsOneWidget);
    });

    testWidgets('shows instructions', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      expect(find.text('أرسلنا رسالة تأكيد إلى:'), findsOneWidget);
    });

    testWidgets('displays provided email', (tester) async {
      await tester.pumpWidget(_buildTestWidget(email: 'user@example.com'));
      await tester.pump();

      expect(find.text('user@example.com'), findsOneWidget);
    });

    testWidgets('shows email icon', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      expect(find.byIcon(Icons.mark_email_unread_outlined), findsOneWidget);
    });

    testWidgets('shows info box with instructions', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('shows check verification button', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      expect(find.text('تحقّقت بالفعل؟ اضغط هنا'), findsOneWidget);
    });
  });

  // ─── Resend button ──────────────────────────────────────────────

  group('resend button', () {
    testWidgets('shows resend button', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      expect(find.text('لم يصلك البريد؟ إعادة الإرسال'), findsOneWidget);
    });

    testWidgets('shows back to login link', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      expect(find.text('العودة لتسجيل الدخول'), findsOneWidget);
    });
  });
}
