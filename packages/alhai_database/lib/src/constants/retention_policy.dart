/// Data retention policies per Saudi regulations.
///
/// Legal reference: Saudi VAT Law (Royal Decree M/113), Executive Regulations
/// Article 66 — accounting and tax records must be retained for a minimum of
/// 6 years from the end of the tax period.  ZATCA may impose financial
/// penalties on violators.
class RetentionPolicy {
  RetentionPolicy._();

  // ---------------------------------------------------------------------------
  // Legally-protected records — minimum 6 years (2 190 days)
  // ---------------------------------------------------------------------------

  /// Audit log retention — 6 years.
  /// DO NOT reduce without legal review.
  static const Duration auditLogRetention = Duration(days: 2190);

  /// Sales / invoices retention — 6 years (ZATCA + VAT).
  static const Duration salesRetention = Duration(days: 2190);

  /// Shift records retention — 6 years.
  static const Duration shiftsRetention = Duration(days: 2190);

  /// Signed ZATCA XML retention — 6 years.
  static const Duration zatcaXmlRetention = Duration(days: 2190);

  // ---------------------------------------------------------------------------
  // Internal / operational records — shorter retention is acceptable
  // ---------------------------------------------------------------------------

  /// Completed sync-queue items — 30 days.
  /// These are internal queue-tracking entries, not legal records.
  static const Duration syncQueueRetention = Duration(days: 30);

  /// Synced stock deltas — 7 days.
  static const Duration stockDeltasRetention = Duration(days: 7);

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Whether an audit-log entry is old enough to be legally deletable.
  static bool canDeleteAuditLog(DateTime createdAt) {
    return DateTime.now().difference(createdAt) > auditLogRetention;
  }

  /// Whether a sale record is old enough to be legally deletable.
  static bool canDeleteSale(DateTime createdAt) {
    return DateTime.now().difference(createdAt) > salesRetention;
  }
}
