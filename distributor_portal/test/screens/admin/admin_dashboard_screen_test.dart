import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

import 'package:distributor_portal/data/models/pending_distributor.dart';
import 'package:distributor_portal/data/models/admin_notification.dart';
import 'package:distributor_portal/data/models/distributor_document.dart';
import 'package:distributor_portal/providers/admin_providers.dart';
import 'package:distributor_portal/screens/admin/admin_dashboard_screen.dart';

// ─── Test Data ───────────────────────────────────────────────────

final _sampleDistributor = PendingDistributor.fromJson({
  'id': 'org-001',
  'name': 'شركة الابتكار',
  'name_en': 'Innovation Co',
  'phone': '+966501234567',
  'email': 'info@innovation.sa',
  'city': 'الرياض',
  'commercial_reg': '1010123456',
  'tax_number': '310123456789003',
  'status': 'pending_review',
  'created_at': '2026-04-15T10:00:00.000Z',
});

final _sampleNotification = AdminNotification.fromJson({
  'id': 'notif-001',
  'type': 'new_distributor',
  'title': 'موزع جديد سجّل',
  'message': 'شركة الابتكار سجّلت للمراجعة',
  'related_id': 'org-001',
  'related_type': 'organization',
  'is_read': false,
  'created_at': '2026-04-15T12:00:00.000Z',
});

final _sampleDocument = DistributorDocument.fromJson({
  'id': 'doc-001',
  'org_id': 'org-001',
  'document_type': 'commercial_registration',
  'file_url': 'org-1/cr.pdf',
  'file_name': 'cr.pdf',
  'file_size': 2400000,
  'mime_type': 'application/pdf',
  'status': 'under_review',
  'reviewed_by': null,
  'reviewed_at': null,
  'rejection_reason': null,
  'uploaded_at': '2026-04-16T10:00:00.000Z',
  'updated_at': null,
  'expiry_date': null,
});

// ─── Test Widget Builder ─────────────────────────────────────────

Widget _buildTestWidget({
  List<PendingDistributor> distributors = const [],
  List<DistributorDocument> documents = const [],
  List<AdminNotification> notifications = const [],
  int unreadCount = 0,
}) {
  return ProviderScope(
    overrides: [
      pendingDistributorsProvider.overrideWith(
        (ref) async => distributors,
      ),
      pendingDocumentsProvider.overrideWith(
        (ref) async => documents,
      ),
      adminNotificationsProvider.overrideWith(
        (ref, unreadOnly) async => unreadOnly
            ? notifications.where((n) => !n.isRead).toList()
            : notifications,
      ),
      unreadNotificationCountProvider.overrideWith(
        (ref) async => unreadCount,
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
      home: const AdminDashboardScreen(),
    ),
  );
}

void main() {
  // ─── Structure ─────────────────────────────────────────────────

  group('AdminDashboardScreen structure', () {
    testWidgets('renders 3 tabs', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('موزعون قيد المراجعة'), findsOneWidget);
      expect(find.text('وثائق'), findsOneWidget);
      expect(find.text('تنبيهات'), findsOneWidget);
    });

    testWidgets('renders AppBar with title', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('لوحة الإدارة'), findsOneWidget);
    });
  });

  // ─── Pending Distributors Tab ──────────────────────────────────

  group('Pending distributors tab', () {
    testWidgets('shows empty state when no pending distributors',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      expect(
        find.text('لا يوجد موزعون بانتظار المراجعة'),
        findsOneWidget,
      );
    });

    testWidgets('shows distributor card with info', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        distributors: [_sampleDistributor],
      ));
      await tester.pumpAndSettle();

      expect(find.text('شركة الابتكار (Innovation Co)'), findsOneWidget);
      expect(find.text('الرياض'), findsOneWidget);
    });

    testWidgets('shows approve and reject buttons', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        distributors: [_sampleDistributor],
      ));
      await tester.pumpAndSettle();

      expect(find.text('قبول'), findsOneWidget);
      expect(find.text('رفض'), findsOneWidget);
      expect(find.text('معاينة'), findsOneWidget);
    });

    testWidgets('approve button shows confirmation dialog', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        distributors: [_sampleDistributor],
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('قبول'));
      await tester.pumpAndSettle();

      expect(find.text('تأكيد الاعتماد'), findsOneWidget);
      expect(find.text('إلغاء'), findsOneWidget);
      expect(find.text('نعم، اعتماد'), findsOneWidget);
    });

    testWidgets('reject button shows reason dialog', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        distributors: [_sampleDistributor],
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('رفض'));
      await tester.pumpAndSettle();

      expect(find.text('رفض الموزع'), findsOneWidget);
      // Predefined reasons
      expect(find.text('وثائق غير مكتملة'), findsOneWidget);
      expect(find.text('معلومات غير صحيحة'), findsOneWidget);
      expect(find.text('السجل التجاري منتهي'), findsOneWidget);
    });

    testWidgets('reject dialog has disabled button when reason too short',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        distributors: [_sampleDistributor],
      ));
      await tester.pumpAndSettle();

      // Tap the reject button on the card (FilledButton.tonal)
      await tester.tap(find.widgetWithText(FilledButton, 'رفض').first);
      await tester.pumpAndSettle();

      // In the dialog, the FilledButton "رفض" should be disabled
      // Find all FilledButtons with text "رفض" — dialog has 2nd one
      final rejectButtons = find.widgetWithText(FilledButton, 'رفض');
      expect(rejectButtons, findsNWidgets(2));
      // The dialog button is the last one
      final dialogButton =
          tester.widget<FilledButton>(rejectButtons.last);
      expect(dialogButton.onPressed, isNull);
    });

    testWidgets('shows multiple distributor cards', (tester) async {
      final d2 = PendingDistributor.fromJson({
        'id': 'org-002',
        'name': 'شركة التقنية',
        'status': 'pending_review',
        'created_at': '2026-04-14T08:00:00.000Z',
      });

      await tester.pumpWidget(_buildTestWidget(
        distributors: [_sampleDistributor, d2],
      ));
      await tester.pumpAndSettle();

      expect(find.text('شركة الابتكار (Innovation Co)'), findsOneWidget);
      expect(find.text('شركة التقنية'), findsOneWidget);
    });
  });

  // ─── Documents Tab ─────────────────────────────────────────────

  group('Documents tab', () {
    testWidgets('shows empty state when no pending documents',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      // Switch to documents tab
      await tester.tap(find.text('وثائق'));
      await tester.pumpAndSettle();

      expect(
        find.text('لا توجد وثائق بانتظار المراجعة'),
        findsOneWidget,
      );
    });

    testWidgets('shows document card with info', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        documents: [_sampleDocument],
      ));
      await tester.pumpAndSettle();

      // Switch to documents tab
      await tester.tap(find.text('وثائق'));
      await tester.pumpAndSettle();

      expect(find.text('السجل التجاري'), findsOneWidget);
      expect(find.text('cr.pdf'), findsOneWidget);
    });

    testWidgets('shows approve and reject buttons for documents',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        documents: [_sampleDocument],
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('وثائق'));
      await tester.pumpAndSettle();

      expect(find.text('موافق'), findsOneWidget);
    });
  });

  // ─── Notifications Tab ─────────────────────────────────────────

  group('Notifications tab', () {
    testWidgets('shows empty state when no notifications', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      // Switch to notifications tab
      await tester.tap(find.text('تنبيهات'));
      await tester.pumpAndSettle();

      expect(find.text('لا توجد تنبيهات'), findsOneWidget);
    });

    testWidgets('shows notification tile', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        notifications: [_sampleNotification],
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('تنبيهات'));
      await tester.pumpAndSettle();

      expect(find.text('موزع جديد سجّل'), findsOneWidget);
      expect(
        find.text('شركة الابتكار سجّلت للمراجعة'),
        findsOneWidget,
      );
    });

    testWidgets('shows filter chips (all vs unread)', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        notifications: [_sampleNotification],
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('تنبيهات'));
      await tester.pumpAndSettle();

      expect(find.text('الكل'), findsOneWidget);
      expect(find.text('غير مقروءة'), findsOneWidget);
    });

    testWidgets('unread notification shows mark-as-read button',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        notifications: [_sampleNotification],
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('تنبيهات'));
      await tester.pumpAndSettle();

      expect(
        find.byTooltip('تعيين كمقروء'),
        findsOneWidget,
      );
    });

    testWidgets('read notification does not show mark-as-read button',
        (tester) async {
      final readNotif = AdminNotification.fromJson({
        ...Map<String, dynamic>.from({
          'id': 'notif-002',
          'type': 'distributor_approved',
          'title': 'تم اعتماد موزع',
          'is_read': true,
          'read_by': 'admin-001',
          'read_at': '2026-04-15T14:00:00.000Z',
          'created_at': '2026-04-15T12:00:00.000Z',
        }),
      });

      await tester.pumpWidget(_buildTestWidget(
        notifications: [readNotif],
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('تنبيهات'));
      await tester.pumpAndSettle();

      expect(find.byTooltip('تعيين كمقروء'), findsNothing);
    });
  });

  // ─── Notification badge ────────────────────────────────────────

  group('Notification badge', () {
    testWidgets('shows badge when unread count > 0', (tester) async {
      await tester.pumpWidget(_buildTestWidget(unreadCount: 3));
      await tester.pumpAndSettle();

      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('hides badge when unread count is 0', (tester) async {
      await tester.pumpWidget(_buildTestWidget(unreadCount: 0));
      await tester.pumpAndSettle();

      // No badge number
      expect(find.byType(Badge), findsNothing);
    });
  });
}
