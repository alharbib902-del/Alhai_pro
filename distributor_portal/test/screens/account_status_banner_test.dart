import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

import 'package:distributor_portal/data/models/distributor_account_status.dart';
import 'package:distributor_portal/providers/distributor_onboarding_providers.dart';
import 'package:distributor_portal/ui/widgets/account_status_banner.dart';

// ─── Test Helpers ────────────────────────────────────────────────

Widget _buildTestWidget(DistributorAccountStatus? status) {
  return ProviderScope(
    overrides: [
      distributorAccountStatusProvider.overrideWith(
        (ref) async => status,
      ),
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
      home: const Scaffold(body: AccountStatusBanner()),
    ),
  );
}

void main() {
  // ─── Banner visibility ──────────────────────────────────────────

  group('AccountStatusBanner visibility', () {
    testWidgets('shows nothing for active status', (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(DistributorAccountStatus.active),
      );
      await tester.pumpAndSettle();

      // SizedBox.shrink renders but has no visual content
      expect(find.text('حسابك قيد المراجعة'), findsNothing);
      expect(find.text('يرجى تأكيد بريدك الإلكتروني'), findsNothing);
    });

    testWidgets('shows nothing for null status', (tester) async {
      await tester.pumpWidget(_buildTestWidget(null));
      await tester.pumpAndSettle();

      expect(find.text('حسابك قيد المراجعة'), findsNothing);
    });

    testWidgets('shows amber banner for pendingEmailVerification',
        (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(DistributorAccountStatus.pendingEmailVerification),
      );
      await tester.pumpAndSettle();

      expect(find.text('يرجى تأكيد بريدك الإلكتروني'), findsOneWidget);
      expect(
        find.text('تحقّق من صندوق الوارد لتأكيد حسابك'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
    });

    testWidgets('shows blue banner for pendingReview', (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(DistributorAccountStatus.pendingReview),
      );
      await tester.pumpAndSettle();

      expect(find.text('حسابك قيد المراجعة'), findsOneWidget);
      expect(find.byIcon(Icons.hourglass_top), findsOneWidget);
    });

    testWidgets('shows red banner for rejected', (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(DistributorAccountStatus.rejected),
      );
      await tester.pumpAndSettle();

      expect(find.text('تم رفض حسابك'), findsOneWidget);
      expect(find.byIcon(Icons.cancel_outlined), findsOneWidget);
    });

    testWidgets('shows red banner for suspended', (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(DistributorAccountStatus.suspended),
      );
      await tester.pumpAndSettle();

      expect(find.text('حسابك موقوف'), findsOneWidget);
      expect(find.byIcon(Icons.block), findsOneWidget);
    });
  });

  // ─── Banner content ─────────────────────────────────────────────

  group('AccountStatusBanner content', () {
    testWidgets('pendingReview shows review subtitle', (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(DistributorAccountStatus.pendingReview),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('فريق الإدارة يراجع طلبك. عادة 1-3 أيام عمل.'),
        findsOneWidget,
      );
    });

    testWidgets('suspended shows support subtitle', (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(DistributorAccountStatus.suspended),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('تواصل مع الدعم لإعادة التفعيل'),
        findsOneWidget,
      );
    });

    testWidgets('rejected shows contact subtitle', (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(DistributorAccountStatus.rejected),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('يرجى التواصل مع الدعم لمعرفة السبب'),
        findsOneWidget,
      );
    });
  });
}
