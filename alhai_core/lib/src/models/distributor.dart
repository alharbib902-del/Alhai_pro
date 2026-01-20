import 'package:freezed_annotation/freezed_annotation.dart';

part 'distributor.freezed.dart';
part 'distributor.g.dart';

/// Distributor status enum (v2.6.0)
enum DistributorStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('APPROVED')
  approved,
  @JsonValue('SUSPENDED')
  suspended,
  @JsonValue('REJECTED')
  rejected,
}

/// Extension for DistributorStatus
extension DistributorStatusExt on DistributorStatus {
  String get displayNameAr {
    switch (this) {
      case DistributorStatus.pending:
        return 'قيد المراجعة';
      case DistributorStatus.approved:
        return 'معتمد';
      case DistributorStatus.suspended:
        return 'موقوف';
      case DistributorStatus.rejected:
        return 'مرفوض';
    }
  }

  bool get isActive => this == DistributorStatus.approved;
}

/// Distributor tier enum
enum DistributorTier {
  @JsonValue('FREE')
  free,
  @JsonValue('PRO')
  pro,
  @JsonValue('ENTERPRISE')
  enterprise,
}

/// Extension for DistributorTier
extension DistributorTierExt on DistributorTier {
  String get displayNameAr {
    switch (this) {
      case DistributorTier.free:
        return 'مجاني';
      case DistributorTier.pro:
        return 'احترافي';
      case DistributorTier.enterprise:
        return 'مؤسسي';
    }
  }

  double get monthlyFee {
    switch (this) {
      case DistributorTier.free:
        return 0;
      case DistributorTier.pro:
        return 500;
      case DistributorTier.enterprise:
        return 1000;
    }
  }

  double get transactionFeePercent {
    switch (this) {
      case DistributorTier.free:
        return 3.0;
      case DistributorTier.pro:
        return 2.0;
      case DistributorTier.enterprise:
        return 1.5;
    }
  }
}

/// Distributor domain model (v2.6.0)
/// B2B wholesaler/distributor for the platform
/// Referenced by: distributor_portal
@freezed
class Distributor with _$Distributor {
  const Distributor._();

  const factory Distributor({
    required String id,
    required String userId,
    required String companyName,
    String? companyNameEn,
    required String commercialRegister,
    required String vatNumber,
    String? logoUrl,
    String? address,
    String? city,
    String? phone,
    String? email,
    String? website,
    @Default(DistributorStatus.pending) DistributorStatus status,
    @Default(DistributorTier.free) DistributorTier tier,
    @Default(0) int totalProducts,
    @Default(0) int totalOrders,
    @Default(0.0) double totalRevenue,
    @Default(0.0) double avgRating,
    @Default(0) int ratingCount,
    @Default(false) bool isFeatured,
    DateTime? approvedAt,
    String? approvedBy,
    String? rejectionReason,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Distributor;

  factory Distributor.fromJson(Map<String, dynamic> json) =>
      _$DistributorFromJson(json);

  /// Check if distributor can sell
  bool get canSell => status == DistributorStatus.approved;

  /// Check if pending approval
  bool get isPending => status == DistributorStatus.pending;

  /// Get display rating
  String get displayRating =>
      ratingCount > 0 ? avgRating.toStringAsFixed(1) : '-';
}
