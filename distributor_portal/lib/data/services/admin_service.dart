/// Admin service for super_admin operations: review distributors,
/// manage documents, handle notifications.
///
/// Security: All operations require super_admin role enforced by RLS.
/// Client-side role checks are defense-in-depth only.
library;

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/admin_notification.dart';
import '../models/distributor_account_status.dart';
import '../models/distributor_document.dart';
import '../models/pending_distributor.dart';

class AdminService {
  final SupabaseClient _client;

  AdminService(this._client);

  // ─── Role check ───────────────────────────────────────────────

  /// Whether the current user is super_admin.
  bool get isSuperAdmin {
    final user = _client.auth.currentUser;
    return user?.userMetadata?['role'] == 'super_admin';
  }

  // ─── Distributors ─────────────────────────────────────────────

  /// List pending distributor signups.
  Future<List<PendingDistributor>> listPendingDistributors() async {
    try {
      final response = await _client
          .from('organizations')
          .select(
            'id, name, name_en, phone, email, city, address, '
            'commercial_reg, tax_number, status, owner_id, '
            'terms_accepted_at, created_at, company_type',
          )
          .eq('company_type', 'distributor')
          .eq('status', 'pending_review')
          .order('created_at', ascending: false);

      return (response as List)
          .map((r) =>
              PendingDistributor.fromJson(r as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      // Table may not exist yet in dev environments
      if (e.code == '42P01') return [];
      rethrow;
    }
  }

  /// List distributors by status.
  Future<List<PendingDistributor>> listDistributorsByStatus(
    DistributorAccountStatus status,
  ) async {
    final response = await _client
        .from('organizations')
        .select(
          'id, name, name_en, phone, email, city, address, '
          'commercial_reg, tax_number, status, owner_id, '
          'terms_accepted_at, created_at, company_type',
        )
        .eq('company_type', 'distributor')
        .eq('status', status.dbValue)
        .order('created_at', ascending: false);

    return (response as List)
        .map(
            (r) => PendingDistributor.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  /// Get a single distributor by ID.
  Future<PendingDistributor> getDistributor(String orgId) async {
    final response = await _client
        .from('organizations')
        .select(
          'id, name, name_en, phone, email, city, address, '
          'commercial_reg, tax_number, status, owner_id, '
          'terms_accepted_at, created_at, company_type',
        )
        .eq('id', orgId)
        .single();

    return PendingDistributor.fromJson(response);
  }

  /// Approve distributor — sets status to active.
  Future<void> approveDistributor(String orgId) async {
    await _client.from('organizations').update({
      'status': 'active',
      'is_active': true,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', orgId);

    await _createNotification(
      type: 'distributor_approved',
      title: 'تم اعتماد موزع',
      relatedId: orgId,
    );
  }

  /// Reject distributor with mandatory reason.
  Future<void> rejectDistributor(String orgId, String reason) async {
    if (reason.trim().isEmpty) {
      throw ArgumentError('سبب الرفض مطلوب');
    }

    await _client.from('organizations').update({
      'status': 'rejected',
      'is_active': false,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', orgId);

    await _createNotification(
      type: 'distributor_rejected',
      title: 'تم رفض موزع',
      message: reason,
      relatedId: orgId,
    );
  }

  /// Suspend an active distributor.
  Future<void> suspendDistributor(String orgId, String reason) async {
    if (reason.trim().isEmpty) {
      throw ArgumentError('سبب الإيقاف مطلوب');
    }

    await _client.from('organizations').update({
      'status': 'suspended',
      'is_active': false,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', orgId);

    await _createNotification(
      type: 'distributor_suspended',
      title: 'تم إيقاف موزع',
      message: reason,
      relatedId: orgId,
    );
  }

  /// Reinstate a suspended distributor.
  Future<void> reinstateDistributor(String orgId) async {
    await _client.from('organizations').update({
      'status': 'active',
      'is_active': true,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', orgId);

    await _createNotification(
      type: 'distributor_approved',
      title: 'تم إعادة تفعيل موزع',
      relatedId: orgId,
    );
  }

  // ─── Documents ────────────────────────────────────────────────

  /// List documents pending review.
  Future<List<DistributorDocument>> listPendingDocuments() async {
    try {
      final response = await _client
          .from('distributor_documents')
          .select()
          .eq('status', 'under_review')
          .order('uploaded_at', ascending: false);

      return (response as List)
          .map((r) =>
              DistributorDocument.fromJson(r as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      if (e.code == '42P01') return [];
      rethrow;
    }
  }

  /// List documents for a specific distributor.
  Future<List<DistributorDocument>> listDocumentsForOrg(
    String orgId,
  ) async {
    try {
      final response = await _client
          .from('distributor_documents')
          .select()
          .eq('org_id', orgId)
          .order('uploaded_at', ascending: false);

      return (response as List)
          .map((r) =>
              DistributorDocument.fromJson(r as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      if (e.code == '42P01') return [];
      rethrow;
    }
  }

  /// Approve a document.
  Future<void> approveDocument(String documentId) async {
    final user = _client.auth.currentUser;
    await _client.from('distributor_documents').update({
      'status': 'approved',
      'reviewed_by': user?.id,
      'reviewed_at': DateTime.now().toIso8601String(),
    }).eq('id', documentId);
  }

  /// Reject a document with reason.
  Future<void> rejectDocument(String documentId, String reason) async {
    if (reason.trim().isEmpty) {
      throw ArgumentError('سبب الرفض مطلوب');
    }

    final user = _client.auth.currentUser;
    await _client.from('distributor_documents').update({
      'status': 'rejected',
      'reviewed_by': user?.id,
      'reviewed_at': DateTime.now().toIso8601String(),
      'rejection_reason': reason,
    }).eq('id', documentId);
  }

  /// Get signed URL for viewing a document (expires in 1 hour).
  Future<String> getDocumentSignedUrl(String path) async {
    return _client.storage
        .from('distributor-documents')
        .createSignedUrl(path, 3600);
  }

  // ─── Notifications ────────────────────────────────────────────

  /// List admin notifications.
  Future<List<AdminNotification>> listNotifications({
    bool unreadOnly = false,
    int limit = 50,
  }) async {
    try {
      var query = _client.from('admin_notifications').select();

      if (unreadOnly) {
        query = query.eq('is_read', false);
      }

      final response =
          await query.order('created_at', ascending: false).limit(limit);

      return (response as List)
          .map((r) =>
              AdminNotification.fromJson(r as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      if (e.code == '42P01') return [];
      rethrow;
    }
  }

  /// Mark a notification as read.
  Future<void> markNotificationAsRead(String notificationId) async {
    final user = _client.auth.currentUser;
    await _client.from('admin_notifications').update({
      'is_read': true,
      'read_at': DateTime.now().toIso8601String(),
      'read_by': user?.id,
    }).eq('id', notificationId);
  }

  /// Get count of unread notifications.
  Future<int> getUnreadCount() async {
    try {
      final response = await _client
          .from('admin_notifications')
          .select()
          .eq('is_read', false);

      return (response as List).length;
    } on PostgrestException catch (e) {
      if (e.code == '42P01') return 0;
      rethrow;
    }
  }

  // ─── Internal ─────────────────────────────────────────────────

  Future<void> _createNotification({
    required String type,
    required String title,
    String? message,
    String? relatedId,
  }) async {
    try {
      await _client.from('admin_notifications').insert({
        'type': type,
        'title': title,
        'message': message,
        'related_id': relatedId,
        'related_type': 'organization',
      });
    } on PostgrestException {
      // Non-critical: don't fail the main operation if notification fails
    }
  }
}
