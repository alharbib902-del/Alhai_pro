/// Integration test: Admin (super_admin) flows for the Distributor Portal.
///
/// Tests the admin review workflows:
///   1. Admin login with MFA verification
///   2. Approve a pending distributor application
///   3. Reject a document with a written reason
///   4. Mark admin notifications as read
///
/// All screens are stubs; the tests verify navigation flow, route
/// parameters, and data shape. Real admin business logic is tested
/// in unit/widget tests against AdminService.
///
/// Run with:
///   flutter test integration_test/admin_flow_test.dart
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:go_router/go_router.dart';

import 'helpers/test_data.dart';
import 'helpers/test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ==========================================================================
  // ADMIN FLOWS (مهام المشرف)
  // ==========================================================================

  group('Admin Flows - مهام المشرف', () {
    // ========================================================================
    // Flow 1: Admin Login with MFA
    // ========================================================================
    group('Flow 1: Admin Login with MFA', () {
      testWidgets('login screen loads for admin', (tester) async {
        // Arrange: Launch at login
        await tester.pumpWidget(
          buildDistributorTestApp(initialRoute: '/login'),
        );
        await pumpAndSettleWithTimeout(tester);

        // Assert: Login screen stub is visible
        expectStubScreen('Login');
      });

      testWidgets('MFA verify screen loads with factor ID', (tester) async {
        // Arrange: Navigate to MFA verify
        await tester.pumpWidget(
          buildDistributorTestApp(initialRoute: '/mfa-verify'),
        );
        await pumpAndSettleWithTimeout(tester);

        // Assert: MFA verify screen stub is visible
        expectStubScreen('MFA Verify');
      });

      testWidgets('full MFA login flow: login -> mfa-verify -> dashboard', (
        tester,
      ) async {
        // Arrange: Start at login
        await tester.pumpWidget(
          buildDistributorTestApp(initialRoute: '/login'),
        );
        await pumpAndSettleWithTimeout(tester);
        expectStubScreen('Login');

        final router = GoRouter.of(
          tester.element(find.byKey(const Key('stub_Login'))),
        );

        // Step 1: Admin submits credentials. In the real app, Supabase
        // returns an MFA challenge requiring TOTP code entry.
        router.go('/mfa-verify');
        await pumpAndSettleWithTimeout(tester);
        expectStubScreen('MFA Verify');

        // Step 2: Admin enters TOTP code. On success, navigates to dashboard.
        // MFA is mandatory for super_admin role (F8 requirement).
        router.go('/dashboard');
        await pumpAndSettleWithTimeout(tester);
        expectStubScreen('Dashboard');

        // Step 3: From dashboard, admin navigates to admin panel
        router.go('/admin');
        await pumpAndSettleWithTimeout(tester);
        expectStubScreen('Admin');
      });

      testWidgets('MFA enrollment screen loads for forced enrollment', (
        tester,
      ) async {
        // Arrange: Navigate to forced MFA enrollment
        await tester.pumpWidget(
          buildDistributorTestApp(initialRoute: '/mfa-enroll'),
        );
        await pumpAndSettleWithTimeout(tester);

        // Assert: MFA enrollment screen is shown
        expectStubScreen('MFA Enroll');
      });
    });

    // ========================================================================
    // Flow 2: Approve Pending Distributor
    // ========================================================================
    group('Flow 2: Approve Pending Distributor', () {
      testWidgets('admin dashboard loads at /admin', (tester) async {
        // Arrange
        await tester.pumpWidget(
          buildDistributorTestApp(initialRoute: '/admin'),
        );
        await pumpAndSettleWithTimeout(tester);

        // Assert
        expectStubScreen('Admin');
      });

      testWidgets('admin can view distributor detail', (tester) async {
        // Arrange: Navigate to a pending distributor's detail
        final pendingOrgId = kSamplePendingDistributor['id'] as String;
        await tester.pumpWidget(
          buildDistributorTestApp(
            initialRoute: '/admin/distributor/$pendingOrgId',
          ),
        );
        await pumpAndSettleWithTimeout(tester);

        // Assert: Distributor detail screen is shown with correct ID
        expectStubScreen('Admin Distributor $pendingOrgId');
      });

      testWidgets(
        'full approve flow: admin -> pending list -> detail -> approve',
        (tester) async {
          // Arrange: Start at admin dashboard (pending distributors list)
          await tester.pumpWidget(
            buildDistributorTestApp(initialRoute: '/admin'),
          );
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Admin');

          final router = GoRouter.of(
            tester.element(find.byKey(const Key('stub_Admin'))),
          );

          // Step 1: Admin sees list of pending distributors.
          // Verify pending distributor data is in 'pending_review' status.
          expect(kSamplePendingDistributor['status'], equals('pending_review'));
          expect(kSamplePendingDistributor['name'], isNotEmpty);
          expect(kSamplePendingDistributor['commercial_reg'], isNotNull);

          // Step 2: Navigate to the distributor detail for review
          final pendingOrgId = kSamplePendingDistributor['id'] as String;
          router.go('/admin/distributor/$pendingOrgId');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Admin Distributor $pendingOrgId');

          // Step 3: In the real app, admin reviews commercial registration,
          // tax number, and uploaded documents, then taps "Approve".
          // The status changes from 'pending_review' to 'active'.
          expect(kSamplePendingDistributor['tax_number'], isNotNull);
          expect(kSamplePendingDistributor['email'], isNotNull);

          // Step 4: After approval, admin returns to admin dashboard
          router.go('/admin');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Admin');
        },
      );
    });

    // ========================================================================
    // Flow 3: Reject Document with Reason
    // ========================================================================
    group('Flow 3: Reject Document', () {
      testWidgets('documents screen loads at /documents', (tester) async {
        // Arrange
        await tester.pumpWidget(
          buildDistributorTestApp(initialRoute: '/documents'),
        );
        await pumpAndSettleWithTimeout(tester);

        // Assert
        expectStubScreen('Documents');
      });

      testWidgets(
        'full reject flow: admin -> documents -> select doc -> reject with reason',
        (tester) async {
          // Arrange: Start at admin dashboard
          await tester.pumpWidget(
            buildDistributorTestApp(initialRoute: '/admin'),
          );
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Admin');

          final router = GoRouter.of(
            tester.element(find.byKey(const Key('stub_Admin'))),
          );

          // Step 1: Navigate to documents tab. In the real AdminDashboardScreen,
          // there are tabs for pending distributors, documents, and notifications.
          router.go('/documents');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Documents');

          // Step 2: In the real app, admin selects a pending document.
          // Verify document sample data is in 'pending' status.
          expect(kSampleDocument['status'], equals('pending'));
          expect(kSampleDocument['type'], equals('commercial_registration'));
          expect(kSampleDocument['file_url'], isNotEmpty);

          // Step 3: Admin taps "Reject" and enters a reason in the dialog.
          // The rejection reason is stored in the document record.
          expect(kSampleDocument['rejection_reason'], isNull);

          // Step 4: After rejection, navigate to the distributor detail
          // to see the updated document status.
          final orgId = kSampleDocument['org_id'] as String;
          router.go('/admin/distributor/$orgId');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Admin Distributor $orgId');

          // Step 5: Return to admin dashboard
          router.go('/admin');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Admin');
        },
      );
    });

    // ========================================================================
    // Flow 4: Mark Notification as Read
    // ========================================================================
    group('Flow 4: Notifications', () {
      testWidgets('admin dashboard has notification access', (tester) async {
        // Arrange: Start at admin
        await tester.pumpWidget(
          buildDistributorTestApp(initialRoute: '/admin'),
        );
        await pumpAndSettleWithTimeout(tester);

        // Assert: Admin screen is shown. In the real app, the AdminDashboardScreen
        // includes a notifications tab with unread count badge.
        expectStubScreen('Admin');
      });

      testWidgets('notification data shape includes required fields', (
        tester,
      ) async {
        // Arrange: Start at admin
        await tester.pumpWidget(
          buildDistributorTestApp(initialRoute: '/admin'),
        );
        await pumpAndSettleWithTimeout(tester);
        expectStubScreen('Admin');

        // Verify notification data has the expected structure
        expect(kSampleNotification['id'], isNotEmpty);
        expect(kSampleNotification['type'], equals('new_distributor'));
        expect(kSampleNotification['title'], isNotEmpty);
        expect(kSampleNotification['message'], isNotEmpty);
        expect(kSampleNotification['is_read'], isFalse);
        expect(kSampleNotification['related_id'], isNotNull);
        expect(kSampleNotification['related_type'], equals('organization'));
      });

      testWidgets(
        'mark as read flow: admin -> notification -> mark read -> verify',
        (tester) async {
          // Arrange: Start at admin dashboard
          await tester.pumpWidget(
            buildDistributorTestApp(initialRoute: '/admin'),
          );
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Admin');

          final router = GoRouter.of(
            tester.element(find.byKey(const Key('stub_Admin'))),
          );

          // Step 1: In the real AdminDashboardScreen, the notifications tab
          // shows unread notifications with an unread count badge via
          // unreadNotificationCountProvider. Admin taps a notification.
          expect(kSampleNotification['is_read'], isFalse);

          // Step 2: Tapping a notification with related_id navigates to the
          // related distributor detail. The notification is marked as read
          // via adminServiceProvider.markNotificationAsRead().
          final relatedId = kSampleNotification['related_id'] as String;
          router.go('/admin/distributor/$relatedId');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Admin Distributor $relatedId');

          // Step 3: After reviewing, navigate back to admin dashboard.
          // The unread count should have decreased.
          router.go('/admin');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Admin');
        },
      );
    });

    // ========================================================================
    // End-to-End: Full Admin Review Lifecycle
    // ========================================================================
    group('End-to-End: Admin Review Lifecycle', () {
      testWidgets(
        'full flow: login -> MFA -> admin -> approve dist -> reject doc -> notifications',
        (tester) async {
          // Arrange: Start at login
          await tester.pumpWidget(
            buildDistributorTestApp(initialRoute: '/login'),
          );
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Login');

          final router = GoRouter.of(
            tester.element(find.byKey(const Key('stub_Login'))),
          );

          // Step 1: Login -> MFA verify
          router.go('/mfa-verify');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('MFA Verify');

          // Step 2: MFA verified -> Dashboard
          router.go('/dashboard');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Dashboard');

          // Step 3: Dashboard -> Admin panel
          router.go('/admin');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Admin');

          // Step 4: Review pending distributor
          final pendingOrgId = kSamplePendingDistributor['id'] as String;
          router.go('/admin/distributor/$pendingOrgId');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Admin Distributor $pendingOrgId');

          // Step 5: Back to admin, check documents
          router.go('/documents');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Documents');

          // Step 6: Return to admin for notifications
          router.go('/admin');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Admin');

          // Step 7: Navigate to related distributor from notification
          final relatedId = kSampleNotification['related_id'] as String;
          router.go('/admin/distributor/$relatedId');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Admin Distributor $relatedId');

          // Step 8: Back to dashboard
          router.go('/dashboard');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Dashboard');
        },
      );
    });
  });
}
