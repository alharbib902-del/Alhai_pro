/// Riverpod providers for admin review features.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/supabase/supabase_client.dart';
import '../data/models/admin_notification.dart';
import '../data/models/distributor_account_status.dart';
import '../data/models/distributor_document.dart';
import '../data/models/pending_distributor.dart';
import '../data/services/admin_service.dart';

/// Admin service singleton.
final adminServiceProvider = Provider<AdminService>((ref) {
  return AdminService(AppSupabase.client);
});

/// Whether the current user is super_admin.
final isSuperAdminProvider = Provider<bool>((ref) {
  return ref.read(adminServiceProvider).isSuperAdmin;
});

/// Pending distributors awaiting review.
final pendingDistributorsProvider =
    FutureProvider.autoDispose<List<PendingDistributor>>((ref) {
      return ref.read(adminServiceProvider).listPendingDistributors();
    });

/// Distributors filtered by status.
final distributorsByStatusProvider = FutureProvider.autoDispose
    .family<List<PendingDistributor>, DistributorAccountStatus>((ref, status) {
      return ref.read(adminServiceProvider).listDistributorsByStatus(status);
    });

/// Single distributor detail.
final distributorDetailProvider = FutureProvider.autoDispose
    .family<PendingDistributor, String>((ref, orgId) {
      return ref.read(adminServiceProvider).getDistributor(orgId);
    });

/// Documents for a specific org.
final orgDocumentsProvider = FutureProvider.autoDispose
    .family<List<DistributorDocument>, String>((ref, orgId) {
      return ref.read(adminServiceProvider).listDocumentsForOrg(orgId);
    });

/// Pending documents for review.
final pendingDocumentsProvider =
    FutureProvider.autoDispose<List<DistributorDocument>>((ref) {
      return ref.read(adminServiceProvider).listPendingDocuments();
    });

/// Admin notifications (parameterized by unreadOnly filter).
final adminNotificationsProvider = FutureProvider.autoDispose
    .family<List<AdminNotification>, bool>((ref, unreadOnly) {
      return ref
          .read(adminServiceProvider)
          .listNotifications(unreadOnly: unreadOnly);
    });

/// Count of unread admin notifications.
final unreadNotificationCountProvider = FutureProvider.autoDispose<int>((ref) {
  return ref.read(adminServiceProvider).getUnreadCount();
});
