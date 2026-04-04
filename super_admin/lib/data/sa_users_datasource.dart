import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/sa_user_model.dart';

/// Datasource for platform user management.
/// Queries: users (platform-level admins/support), plus store-level users.
class SAUsersDatasource {
  final SupabaseClient _client;

  SAUsersDatasource(this._client);

  /// Fetch platform-level admin/support users.
  /// These are users with role = super_admin, support, or viewer
  /// stored in the users table (or a dedicated platform_users table).
  Future<List<SAUser>> getPlatformUsers({
    String? search,
  }) async {
    var query = _client
        .from('users')
        .select('id, name, phone, email, role, created_at, last_login_at')
        .inFilter('role', ['super_admin', 'support', 'viewer'])
        .order('created_at', ascending: false);

    if (search != null && search.isNotEmpty) {
      // Escape special PostgREST wildcard characters to prevent injection
      final sanitized = search.replaceAll('%', r'\%').replaceAll('_', r'\_');
      query = query.or('name.ilike.%$sanitized%,email.ilike.%$sanitized%');
    }

    final data = await query;
    return (data as List)
        .map((e) => SAUser.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetch a single user by ID.
  Future<SAUser> getUser(String userId) async {
    final data = await _client
        .from('users')
        .select('*')
        .eq('id', userId)
        .single();
    return SAUser.fromJson(data);
  }

  /// Update user role.
  Future<void> updateUserRole(String userId, String role) async {
    await _client
        .from('users')
        .update({'role': role})
        .eq('id', userId);
  }

  /// Get total platform user count (all roles across all stores).
  Future<int> getTotalUserCount() async {
    final result = await _client
        .from('users')
        .select('id')
        .count(CountOption.exact);
    return result.count;
  }

  /// Get active user count (users who signed in within last 30 days).
  Future<int> getActiveUserCount() async {
    final thirtyDaysAgo =
        DateTime.now().subtract(const Duration(days: 30)).toIso8601String();
    final result = await _client
        .from('users')
        .select('id')
        .gte('last_login_at', thirtyDaysAgo)
        .count(CountOption.exact);
    return result.count;
  }

  /// Get new signups in the last 30 days.
  Future<int> getNewSignupsCount() async {
    final thirtyDaysAgo =
        DateTime.now().subtract(const Duration(days: 30)).toIso8601String();
    final result = await _client
        .from('users')
        .select('id')
        .gte('created_at', thirtyDaysAgo)
        .count(CountOption.exact);
    return result.count;
  }

  /// Soft delete a user (set is_active = false).
  Future<void> softDeleteUser(String userId) async {
    await _client
        .from('users')
        .update({'is_active': false})
        .eq('id', userId);
  }

  /// Restore a soft-deleted user.
  Future<void> restoreUser(String userId) async {
    await _client
        .from('users')
        .update({'is_active': true})
        .eq('id', userId);
  }

  /// Check if a user is currently online (last_sign_in within 5 minutes).
  ///
  /// Prefer using [SAUser.isOnline] directly on the model instead.
  bool isUserOnline(SAUser user) {
    return user.isOnline;
  }

  /// Format "last active" as a human-readable relative time.
  ///
  /// Prefer using [SAUser.lastActiveFormatted] directly on the model instead.
  String formatLastActive(String? lastSignIn) {
    if (lastSignIn == null) return 'Never';
    final dt = DateTime.tryParse(lastSignIn);
    if (dt == null) return 'Unknown';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 5) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}
