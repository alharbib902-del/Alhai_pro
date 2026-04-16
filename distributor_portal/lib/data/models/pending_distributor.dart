/// Model representing a distributor organization pending admin review.
///
/// Maps to `organizations` table rows where company_type='distributor'.
library;

import 'distributor_account_status.dart';

class PendingDistributor {
  final String id;
  final String name;
  final String? nameEn;
  final String? phone;
  final String? email;
  final String? city;
  final String? address;
  final String? commercialReg;
  final String? taxNumber;
  final DistributorAccountStatus status;
  final String? ownerId;
  final String? companyType;
  final DateTime? termsAcceptedAt;
  final DateTime createdAt;

  const PendingDistributor({
    required this.id,
    required this.name,
    this.nameEn,
    this.phone,
    this.email,
    this.city,
    this.address,
    this.commercialReg,
    this.taxNumber,
    this.status = DistributorAccountStatus.pendingReview,
    this.ownerId,
    this.companyType,
    this.termsAcceptedAt,
    required this.createdAt,
  });

  factory PendingDistributor.fromJson(Map<String, dynamic> json) {
    return PendingDistributor(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      nameEn: json['name_en'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      city: json['city'] as String?,
      address: json['address'] as String?,
      commercialReg: json['commercial_reg'] as String?,
      taxNumber: json['tax_number'] as String?,
      status: DistributorAccountStatus.fromDbValue(
        json['status'] as String? ?? 'pending_review',
      ),
      ownerId: json['owner_id'] as String?,
      companyType: json['company_type'] as String?,
      termsAcceptedAt: _tryParseDate(json['terms_accepted_at']),
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  /// Display name: Arabic name first, English in parentheses if available.
  String get displayName {
    if (nameEn != null && nameEn!.isNotEmpty && nameEn != name) {
      return '$name ($nameEn)';
    }
    return name;
  }

  /// Time elapsed since signup.
  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inDays > 0) return 'منذ ${diff.inDays} يوم';
    if (diff.inHours > 0) return 'منذ ${diff.inHours} ساعة';
    if (diff.inMinutes > 0) return 'منذ ${diff.inMinutes} دقيقة';
    return 'الآن';
  }

  static DateTime? _tryParseDate(Object? value) {
    if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PendingDistributor &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          status == other.status;

  @override
  int get hashCode => Object.hash(id, status);
}
