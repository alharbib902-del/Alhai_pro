/// Centralized constants for the driver app.
///
/// Avoids magic strings scattered across datasources, providers and widgets.
library;

// ─── Supabase table names ─────────────────────────────────────────────────

/// Table names used in Supabase queries.
abstract final class Tables {
  static const String deliveries = 'deliveries';
  static const String deliveryProofs = 'delivery_proofs';
  static const String driverShifts = 'driver_shifts';
  static const String driverLocations = 'driver_locations';
  static const String chatMessages = 'chat_messages';
  static const String users = 'users';
  static const String drivers = 'drivers';
  static const String orderItems = 'order_items';
}

// ─── Supabase storage bucket names ────────────────────────────────────────

abstract final class StorageBuckets {
  static const String deliveryProofs = 'delivery-proofs';
}

// ─── Delivery status values ───────────────────────────────────────────────

/// All possible delivery status strings used in the `status` column.
abstract final class DeliveryStatus {
  static const String assigned = 'assigned';
  static const String accepted = 'accepted';
  static const String headingToPickup = 'heading_to_pickup';
  static const String arrivedAtPickup = 'arrived_at_pickup';
  static const String pickedUp = 'picked_up';
  static const String headingToCustomer = 'heading_to_customer';
  static const String arrivedAtCustomer = 'arrived_at_customer';
  static const String delivered = 'delivered';
  static const String failed = 'failed';
  static const String cancelled = 'cancelled';

  /// Statuses that represent a completed delivery (no further actions).
  static const Set<String> terminal = {delivered, failed, cancelled};

  /// Returns `true` if [status] is a terminal (completed) status.
  static bool isTerminal(String status) => terminal.contains(status);

  /// Returns `true` if [status] is active (not terminal).
  static bool isActive(String status) => !terminal.contains(status);
}

// ─── Shift status values ──────────────────────────────────────────────────

abstract final class ShiftStatus {
  static const String active = 'active';
  static const String ended = 'ended';
}

// ─── User roles ───────────────────────────────────────────────────────────

abstract final class UserRoles {
  static const String delivery = 'delivery';
}

// ─── RPC function names ───────────────────────────────────────────────────

abstract final class RpcFunctions {
  static const String updateDeliveryStatus = 'update_delivery_status';
  static const String getDriverDashboardStats = 'get_driver_dashboard_stats';
}

// ─── Pagination defaults ──────────────────────────────────────────────────

abstract final class PaginationDefaults {
  static const int defaultPageSize = 50;
  static const int shiftHistoryLimit = 30;
}
