/// Dart enums matching Supabase ENUM types for status columns.
///
/// Provides type-safe status values with database string conversion.
/// Use these enums instead of raw strings when reading/writing status columns.

// ---------------------------------------------------------------------------
// OrderStatus
// ---------------------------------------------------------------------------

/// Order status enum matching Supabase order_status_type.
///
/// Values: created, confirmed, preparing, ready, out_for_delivery,
/// delivered, picked_up, completed, cancelled, refunded.
enum OrderStatus {
  created,
  confirmed,
  preparing,
  ready,
  outForDelivery,
  delivered,
  pickedUp,
  completed,
  cancelled,
  refunded;

  /// Returns the database string representation (snake_case).
  String get value {
    switch (this) {
      case OrderStatus.outForDelivery:
        return 'out_for_delivery';
      case OrderStatus.pickedUp:
        return 'picked_up';
      default:
        return name;
    }
  }

  /// Parses a database string into an [OrderStatus], or null if invalid.
  static OrderStatus? fromString(String? value) {
    if (value == null || value.isEmpty) return null;
    return OrderStatus.values.where((e) => e.value == value).firstOrNull;
  }

  /// All valid database string values.
  static List<String> get validValues =>
      OrderStatus.values.map((e) => e.value).toList();
}

// ---------------------------------------------------------------------------
// PaymentStatus
// ---------------------------------------------------------------------------

/// Payment status enum matching Supabase payment_status_type.
///
/// Values: pending, paid, refunded.
enum PaymentStatus {
  pending,
  paid,
  refunded;

  /// Returns the database string representation.
  String get value => name;

  /// Parses a database string into a [PaymentStatus], or null if invalid.
  static PaymentStatus? fromString(String? value) {
    if (value == null || value.isEmpty) return null;
    return PaymentStatus.values.where((e) => e.value == value).firstOrNull;
  }

  /// All valid database string values.
  static List<String> get validValues =>
      PaymentStatus.values.map((e) => e.value).toList();
}

// ---------------------------------------------------------------------------
// SaleStatus
// ---------------------------------------------------------------------------

/// Sale status enum matching Supabase sale_status_type.
///
/// Values: completed, voided, refunded.
enum SaleStatus {
  completed,
  voided,
  refunded;

  /// Returns the database string representation.
  String get value => name;

  /// Parses a database string into a [SaleStatus], or null if invalid.
  static SaleStatus? fromString(String? value) {
    if (value == null || value.isEmpty) return null;
    return SaleStatus.values.where((e) => e.value == value).firstOrNull;
  }

  /// All valid database string values.
  static List<String> get validValues =>
      SaleStatus.values.map((e) => e.value).toList();
}

// ---------------------------------------------------------------------------
// PaymentMethod
// ---------------------------------------------------------------------------

/// Payment method enum matching Supabase payment_method_type.
///
/// Values: cash, card, mixed, credit.
enum PaymentMethod {
  cash,
  card,
  mixed,
  credit;

  /// Returns the database string representation.
  String get value => name;

  /// Parses a database string into a [PaymentMethod], or null if invalid.
  static PaymentMethod? fromString(String? value) {
    if (value == null || value.isEmpty) return null;
    return PaymentMethod.values.where((e) => e.value == value).firstOrNull;
  }

  /// All valid database string values.
  static List<String> get validValues =>
      PaymentMethod.values.map((e) => e.value).toList();
}

// ---------------------------------------------------------------------------
// ShiftStatus
// ---------------------------------------------------------------------------

/// Shift status enum matching Supabase shift_status_type.
///
/// Values: open, closed.
enum ShiftStatus {
  open,
  closed;

  /// Returns the database string representation.
  String get value => name;

  /// Parses a database string into a [ShiftStatus], or null if invalid.
  static ShiftStatus? fromString(String? value) {
    if (value == null || value.isEmpty) return null;
    return ShiftStatus.values.where((e) => e.value == value).firstOrNull;
  }

  /// All valid database string values.
  static List<String> get validValues =>
      ShiftStatus.values.map((e) => e.value).toList();
}

// ---------------------------------------------------------------------------
// PurchaseStatus
// ---------------------------------------------------------------------------

/// Purchase status enum matching Supabase purchase_status_type.
///
/// Values: draft, ordered, partial, received, cancelled.
enum PurchaseStatus {
  draft,
  ordered,
  partial,
  received,
  cancelled;

  /// Returns the database string representation.
  String get value => name;

  /// Parses a database string into a [PurchaseStatus], or null if invalid.
  static PurchaseStatus? fromString(String? value) {
    if (value == null || value.isEmpty) return null;
    return PurchaseStatus.values.where((e) => e.value == value).firstOrNull;
  }

  /// All valid database string values.
  static List<String> get validValues =>
      PurchaseStatus.values.map((e) => e.value).toList();
}

// ---------------------------------------------------------------------------
// SyncQueueStatus
// ---------------------------------------------------------------------------

/// Sync queue status enum matching Supabase sync_status_type.
///
/// Values: pending, syncing, synced, failed.
enum SyncQueueStatus {
  pending,
  syncing,
  synced,
  failed;

  /// Returns the database string representation.
  String get value => name;

  /// Parses a database string into a [SyncQueueStatus], or null if invalid.
  static SyncQueueStatus? fromString(String? value) {
    if (value == null || value.isEmpty) return null;
    return SyncQueueStatus.values.where((e) => e.value == value).firstOrNull;
  }

  /// All valid database string values.
  static List<String> get validValues =>
      SyncQueueStatus.values.map((e) => e.value).toList();
}

// ---------------------------------------------------------------------------
// TransferStatus
// ---------------------------------------------------------------------------

/// Stock transfer status enum matching Supabase transfer_status_type.
///
/// Values: pending, approved, in_transit, completed, cancelled.
enum TransferStatus {
  pending,
  approved,
  inTransit,
  completed,
  cancelled;

  /// Returns the database string representation (snake_case).
  String get value {
    switch (this) {
      case TransferStatus.inTransit:
        return 'in_transit';
      default:
        return name;
    }
  }

  /// Parses a database string into a [TransferStatus], or null if invalid.
  static TransferStatus? fromString(String? value) {
    if (value == null || value.isEmpty) return null;
    return TransferStatus.values.where((e) => e.value == value).firstOrNull;
  }

  /// All valid database string values.
  static List<String> get validValues =>
      TransferStatus.values.map((e) => e.value).toList();
}
