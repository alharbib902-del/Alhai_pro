import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

import 'package:distributor_portal/screens/auth/distributor_signup_screen.dart';

// ─── Test Helpers ────────────────────────────────────────────────

Widget _buildTestWidget() {
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
      home: const DistributorSignupScreen(),
    ),
  );
}

void main() {
  // ─── Rendering ──────────────────────────────────────────────────

  group('DistributorSignupScreen rendering', () {
    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      expect(find.byType(DistributorSignupScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows title', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      expect(find.text('إنشاء حساب موزّع جديد'), findsOneWidget);
    });

    testWidgets('shows account section header', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      expect(find.text('بيانات الحساب'), findsOneWidget);
    });

    testWidgets('shows company section header', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      expect(find.text('بيانات الشركة'), findsOneWidget);
    });

    testWidgets('shows submit button', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      expect(find.text('إنشاء الحساب'), findsWidgets); // button + semantics
    });

    testWidgets('shows login link', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      expect(find.text('أملك حساب بالفعل؟ تسجيل دخول'), findsOneWidget);
    });

    testWidgets('shows terms checkbox', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      expect(
        find.text('أوافق على الشروط والأحكام وسياسة الخصوصية'),
        findsOneWidget,
      );
      expect(find.byType(CheckboxListTile), findsOneWidget);
    });

    testWidgets('shows logo icon', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      expect(find.byIcon(Icons.store), findsOneWidget);
    });
  });

  // ─── Form fields ───────────────────────────────────────────────

  group('form fields', () {
    testWidgets('has all required TextFormField inputs', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      // Count form fields: email, password, confirm, company, companyEn,
      // phone, cr, vat, address = 9 TextFormField
      expect(find.byType(TextFormField), findsNWidgets(9));
    });

    testWidgets('has city dropdown', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      expect(
        find.byType(DropdownButtonFormField<String>),
        findsOneWidget,
      );
    });
  });

  // ─── Validation ─────────────────────────────────────────────────

  group('form validation', () {
    testWidgets('shows error when email is empty and submit tapped',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      // Scroll to button and tap
      await tester.ensureVisible(find.text('إنشاء الحساب').first);
      await tester.tap(find.text('إنشاء الحساب').first);
      await tester.pumpAndSettle();

      expect(find.text('البريد الإلكتروني مطلوب'), findsOneWidget);
    });

    testWidgets('shows error for invalid email format', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      // Enter invalid email
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'not-an-email');

      // Submit
      await tester.ensureVisible(find.text('إنشاء الحساب').first);
      await tester.tap(find.text('إنشاء الحساب').first);
      await tester.pumpAndSettle();

      expect(find.text('صيغة البريد غير صحيحة'), findsOneWidget);
    });

    testWidgets('shows error for short password', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      // Enter valid email
      await tester.enterText(find.byType(TextFormField).first, 'a@b.com');

      // Enter short password (second TextFormField)
      await tester.enterText(find.byType(TextFormField).at(1), '1234');

      // Submit
      await tester.ensureVisible(find.text('إنشاء الحساب').first);
      await tester.tap(find.text('إنشاء الحساب').first);
      await tester.pumpAndSettle();

      expect(
        find.text('كلمة المرور يجب أن تكون 8 أحرف على الأقل'),
        findsOneWidget,
      );
    });

    testWidgets('shows error for password without digit', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      await tester.enterText(find.byType(TextFormField).first, 'a@b.com');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'abcdefgh',
      );

      await tester.ensureVisible(find.text('إنشاء الحساب').first);
      await tester.tap(find.text('إنشاء الحساب').first);
      await tester.pumpAndSettle();

      expect(
        find.text('كلمة المرور يجب أن تحتوي على رقم واحد على الأقل'),
        findsOneWidget,
      );
    });

    testWidgets('shows error for mismatched passwords', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      await tester.enterText(find.byType(TextFormField).first, 'a@b.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'pass1234');
      await tester.enterText(find.byType(TextFormField).at(2), 'different');

      await tester.ensureVisible(find.text('إنشاء الحساب').first);
      await tester.tap(find.text('إنشاء الحساب').first);
      await tester.pumpAndSettle();

      expect(find.text('كلمتا المرور غير متطابقتين'), findsOneWidget);
    });
  });

  // ─── Saudi validations ─────────────────────────────────────────

  group('Saudi-specific validations', () {
    testWidgets('saudiCities list is not empty', (tester) async {
      expect(saudiCities, isNotEmpty);
      expect(saudiCities.length, greaterThanOrEqualTo(15));
    });

    testWidgets('saudiCities contains Riyadh and Jeddah', (tester) async {
      expect(saudiCities, contains('الرياض'));
      expect(saudiCities, contains('جدة'));
    });
  });
}
