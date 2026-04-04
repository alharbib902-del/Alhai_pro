/// Status of a ZATCA invoice submission
enum ReportingStatus {
  /// Invoice created locally, not yet submitted
  pending,

  /// Invoice submitted and accepted by ZATCA
  reported,

  /// Invoice cleared (approved) by ZATCA (standard invoices)
  cleared,

  /// Invoice was rejected by ZATCA
  rejected,

  /// Submission failed (network error, timeout, etc.)
  failed,

  /// Queued for offline retry
  queued,
}

/// Extension helpers for ReportingStatus
extension ReportingStatusX on ReportingStatus {
  /// Whether the invoice has been successfully processed by ZATCA
  bool get isSuccess =>
      this == ReportingStatus.reported || this == ReportingStatus.cleared;

  /// Whether the invoice needs to be resubmitted
  bool get needsRetry =>
      this == ReportingStatus.failed || this == ReportingStatus.queued;

  /// Human-readable Arabic label
  String get labelAr {
    switch (this) {
      case ReportingStatus.pending:
        return 'بانتظار الإرسال';
      case ReportingStatus.reported:
        return 'تم الإبلاغ';
      case ReportingStatus.cleared:
        return 'تم الاعتماد';
      case ReportingStatus.rejected:
        return 'مرفوض';
      case ReportingStatus.failed:
        return 'فشل الإرسال';
      case ReportingStatus.queued:
        return 'في قائمة الانتظار';
    }
  }
}
