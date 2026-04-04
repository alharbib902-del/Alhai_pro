import 'package:supabase_flutter/supabase_flutter.dart';

/// Datasource for platform user management.
/// Queries: app_users (platform-level admins/support), plus store-level users.
class SAUsersDatasource {
  final SupabaseClient _client;

  SAUsersDatasource(this._client);

  /// Fetch platform-level admin/support users.
  /// These are users with role = super_admin, support, or viewer
  /// stored in the app_users table (or a dedicated platform_users table).
  Future<List<Map<String, dynamic>>> getPlatformUsers({
    String? search,
  }) async {
    var query = _client
        .from('app_users')
        .select('id, name, phone, email, role, created_at, last_sign_in_at')
        .inFilter('role', ['super_admin', 'support', 'viewer'])
        .order('created_at', ascending: false);

    if (search != null && search.isNotEmpty) {
      query = query.or('name.ilike.%$search%,email.ilike.%$search%');
    }

    final data = await query;
    return List<Map<String, dynamic>>.from(data as List);
  }

  /// Fetch a single user by ID.
  Future<Map<String, dynamic>> getUser(String userId) async {
    final data = await _client
        .from('app_users')
        .select('*')
        .eq('id', userId)
        .single();
    return data;
  }

  /// Update user role.
  Future<void> updateUserRole(String userId, String role) async {
    await _client
        .from('app_users')
        .update({'role': role})
        .eq('id', userId);
  }

  /// Get total platform user count (all roles across all stores).
  Future<int> getTotalUserCount() async {
    final result = await _client
        .from('app_users')
        .select('id')
        .count(CountOption.exact);
    return result.count;
  }

  /// Get active user count (users who signed in within last 30 days).
  Future<int> getActiveUserCount() async {
    final thirtyDaysAgo =
        DateTime.now().subtract(const Duration(days: 30)).toIso8601String();
    final result = await _client
        .from('app_users')
        .select('id')
        .gte('last_sign_in_at', thirtyDaysAgo)
        .count(CountOption.exact);
    return result.count;
  }

  /// Get new signups in the last 30 days.
  Future<int> getNewSignupsCount() async {
    final thirtyDaysAgo =
        DateTime.now().subtract(const Duration(days: 30)).toIso8601String();
    final result = await _client
        .from('app_users')
        .select('id')
        .gte('created_at', thirtyDaysAgo)
        .count(CountOption.exact);
    return result.count;
  }

  /// Check if a user is currently online (last_sign_in within 5 minutes).
  bool isUserOnline(Map<String, dynamic> user) {
    final lastSignIn = user['last_sign_in_at'] as String?;
    if (lastSignIn == null) return false;
    final dt = DateTime.tryParse(lastSignIn);
    if (dt == null) return false;
    return DateTime.now().difference(dt).inMinutes < 5;
  }

  /// Format "last active" as a human-readable relative time.
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
