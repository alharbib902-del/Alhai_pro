/// Account status for distributor onboarding workflow.
///
/// Separate from [DistributorStatus] in alhai_core which tracks
/// operational status. This enum tracks the onboarding lifecycle:
/// signup → email verify → admin review → active.
enum DistributorAccountStatus {
  pendingEmailVerification,
  pendingReview,
  active,
  rejected,
  suspended;

  String get dbValue {
    switch (this) {
      case DistributorAccountStatus.pendingEmailVerification:
        return 'pending_email_verification';
      case DistributorAccountStatus.pendingReview:
        return 'pending_review';
      case DistributorAccountStatus.active:
        return 'active';
      case DistributorAccountStatus.rejected:
        return 'rejected';
      case DistributorAccountStatus.suspended:
        return 'suspended';
    }
  }

  String get arabicLabel {
    switch (this) {
      case DistributorAccountStatus.pendingEmailVerification:
        return 'بانتظار تأكيد البريد';
      case DistributorAccountStatus.pendingReview:
        return 'قيد المراجعة';
      case DistributorAccountStatus.active:
        return 'نشط';
      case DistributorAccountStatus.rejected:
        return 'مرفوض';
      case DistributorAccountStatus.suspended:
        return 'موقوف';
    }
  }

  bool get canAccessDashboard {
    return this != DistributorAccountStatus.rejected &&
        this != DistributorAccountStatus.suspended;
  }

  bool get canReceiveOrders {
    return this == DistributorAccountStatus.active;
  }

  static DistributorAccountStatus fromDbValue(String value) {
    return DistributorAccountStatus.values.firstWhere(
      (e) => e.dbValue == value,
      orElse: () => DistributorAccountStatus.pendingEmailVerification,
    );
  }
}
