/// User role resolver - Maps DB role strings to [UserRole] enum.
///
/// Source of truth for role: `public.users.role` column in Supabase.
/// The DB stores snake_case values ('super_admin', 'store_owner', etc.)
/// while the Dart enum uses camelCase. This helper maps between them
/// and returns a safe default when the value is missing/unknown.
library;

import 'package:alhai_core/alhai_core.dart';

/// Default role used when the DB row is missing, the column is null,
/// or the string value cannot be mapped. `employee` is the safest
/// fallback because it grants the fewest privileges — any super_admin
/// gating will still refuse these users.
const UserRole kDefaultUserRole = UserRole.employee;

/// Parse a role string from the `public.users.role` column into a
/// [UserRole] enum value.
///
/// Accepts both snake_case (DB canonical) and camelCase (Dart JSON)
/// spellings to be robust against callers that already normalized the
/// value. Unknown / null values fall back to [kDefaultUserRole].
UserRole parseUserRoleFromDb(Object? raw) {
  if (raw == null) return kDefaultUserRole;
  final value = raw.toString().trim().toLowerCase();
  if (value.isEmpty) return kDefaultUserRole;

  switch (value) {
    case 'super_admin':
    case 'superadmin':
      return UserRole.superAdmin;
    case 'store_owner':
    case 'storeowner':
    case 'owner':
      return UserRole.storeOwner;
    case 'employee':
    case 'cashier':
    case 'staff':
      return UserRole.employee;
    case 'delivery':
    case 'driver':
      return UserRole.delivery;
    case 'customer':
      return UserRole.customer;
    default:
      return kDefaultUserRole;
  }
}
