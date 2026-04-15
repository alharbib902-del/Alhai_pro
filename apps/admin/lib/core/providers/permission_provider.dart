/// Runtime permission provider for Admin app.
///
/// Derives the user's permission set from their role using
/// [AdminPermissions] defaults. Screens use [userPermissionsProvider]
/// and [hasPermissionProvider] for defense-in-depth runtime checks
/// beyond the GoRouter guards.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_auth/alhai_auth.dart' show userRoleProvider;
import 'package:alhai_core/alhai_core.dart' show UserRole;
import '../constants/admin_permissions.dart';

/// Returns the permission list for the current user based on role.
final userPermissionsProvider = Provider<List<String>>((ref) {
  final role = ref.watch(userRoleProvider);
  return switch (role) {
    UserRole.superAdmin || UserRole.storeOwner => AdminPermissions.ownerDefaults,
    UserRole.employee => AdminPermissions.cashierDefaults,
    _ => const <String>[],
  };
});

/// Returns true if the current user has the given [permission].
final hasPermissionProvider = Provider.family<bool, String>((ref, permission) {
  final permissions = ref.watch(userPermissionsProvider);
  return permissions.contains(permission);
});
