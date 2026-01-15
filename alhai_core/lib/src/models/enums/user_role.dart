/// Enums for user roles in the system (unified with backend)
enum UserRole {
  /// Super administrator with full system access
  superAdmin,

  /// Store owner/administrator
  storeOwner,

  /// Store employee/cashier
  employee,

  /// Delivery driver
  delivery,

  /// End customer
  customer,
}
