import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/sa_users_datasource.dart';
import '../data/models/sa_user_model.dart';

import 'sa_dashboard_providers.dart' show saSupabaseClientProvider;

// ============================================================================
// DATASOURCE
// ============================================================================

final saUsersDatasourceProvider = Provider<SAUsersDatasource>((ref) {
  return SAUsersDatasource(ref.watch(saSupabaseClientProvider));
});

// ============================================================================
// USERS
// ============================================================================

/// User search query.
final saUserSearchProvider = StateProvider<String>((ref) => '');

/// Platform users list.
final saUsersListProvider =
    FutureProvider.autoDispose<List<SAUser>>((ref) async {
  final ds = ref.watch(saUsersDatasourceProvider);
  final search = ref.watch(saUserSearchProvider);
  return ds.getPlatformUsers(search: search.isEmpty ? null : search);
});

/// Single user detail.
final saUserDetailProvider = FutureProvider.autoDispose
    .family<SAUser, String>((ref, userId) async {
  final ds = ref.watch(saUsersDatasourceProvider);
  return ds.getUser(userId);
});

/// Total user count.
final saTotalUserCountProvider =
    FutureProvider.autoDispose<int>((ref) async {
  final ds = ref.watch(saUsersDatasourceProvider);
  return ds.getTotalUserCount();
});
