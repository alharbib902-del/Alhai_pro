/// Model for distributor legal documents (CR, VAT certificate, etc.).
///
/// Maps to the `distributor_documents` table.
library;

/// Types of legal documents a distributor can upload.
enum DocumentType {
  commercialRegistration,
  vatCertificate,
  ceoNationalId;

  String get dbValue {
    switch (this) {
      case DocumentType.commercialRegistration:
        return 'commercial_registration';
      case DocumentType.vatCertificate:
        return 'vat_certificate';
      case DocumentType.ceoNationalId:
        return 'ceo_national_id';
    }
  }

  String get arabicName {
    switch (this) {
      case DocumentType.commercialRegistration:
        return 'السجل التجاري';
      case DocumentType.vatCertificate:
        return 'شهادة ضريبة القيمة المضافة';
      case DocumentType.ceoNationalId:
        return 'هوية المدير العام';
    }
  }

  bool get isRequired {
    switch (this) {
      case DocumentType.commercialRegistration:
      case DocumentType.vatCertificate:
        return true;
      case DocumentType.ceoNationalId:
        return false;
    }
  }

  static DocumentType fromDbValue(String value) {
    return DocumentType.values.firstWhere(
      (e) => e.dbValue == value,
      orElse: () => throw ArgumentError('Unknown document type: $value'),
    );
  }
}

/// Verification status of a document.
enum DocumentStatus {
  underReview,
  approved,
  rejected;

  String get dbValue {
    switch (this) {
      case DocumentStatus.underReview:
        return 'under_review';
      case DocumentStatus.approved:
        return 'approved';
      case DocumentStatus.rejected:
        return 'rejected';
    }
  }

  String get arabicName {
    switch (this) {
      case DocumentStatus.underReview:
        return 'قيد المراجعة';
      case DocumentStatus.approved:
        return 'موافق عليه';
      case DocumentStatus.rejected:
        return 'مرفوض';
    }
  }

  static DocumentStatus fromDbValue(String value) {
    return DocumentStatus.values.firstWhere(
      (e) => e.dbValue == value,
      orElse: () => DocumentStatus.underReview,
    );
  }
}

/// A distributor's uploaded legal document.
class DistributorDocument {
  final String id;
  final String orgId;
  final DocumentType documentType;
  final String fileUrl; // storage path (not public URL)
  final String fileName;
  final int fileSize;
  final String mimeType;
  final DocumentStatus status;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? rejectionReason;
  final DateTime uploadedAt;
  final DateTime? updatedAt;
  final DateTime? expiryDate;

  const DistributorDocument({
    required this.id,
    required this.orgId,
    required this.documentType,
    required this.fileUrl,
    required this.fileName,
    required this.fileSize,
    required this.mimeType,
    this.status = DocumentStatus.underReview,
    this.reviewedBy,
    this.reviewedAt,
    this.rejectionReason,
    required this.uploadedAt,
    this.updatedAt,
    this.expiryDate,
  });

  factory DistributorDocument.fromJson(Map<String, dynamic> json) {
    return DistributorDocument(
      id: json['id'] as String,
      orgId: json['org_id'] as String,
      documentType: DocumentType.fromDbValue(
        json['document_type'] as String,
      ),
      fileUrl: json['file_url'] as String,
      fileName: json['file_name'] as String,
      fileSize: (json['file_size'] as num).toInt(),
      mimeType: json['mime_type'] as String,
      status: DocumentStatus.fromDbValue(
        json['status'] as String? ?? 'under_review',
      ),
      reviewedBy: json['reviewed_by'] as String?,
      reviewedAt: _tryParseDate(json['reviewed_at']),
      rejectionReason: json['rejection_reason'] as String?,
      uploadedAt:
          DateTime.tryParse(json['uploaded_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: _tryParseDate(json['updated_at']),
      expiryDate: _tryParseDate(json['expiry_date']),
    );
  }

  Map<String, dynamic> toInsertJson() => {
    'id': id,
    'org_id': orgId,
    'document_type': documentType.dbValue,
    'file_url': fileUrl,
    'file_name': fileName,
    'file_size': fileSize,
    'mime_type': mimeType,
    'status': status.dbValue,
    'expiry_date': expiryDate?.toIso8601String().split('T')[0],
    'uploaded_at': uploadedAt.toIso8601String(),
  };

  static DateTime? _tryParseDate(Object? value) {
    if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
    return null;
  }

  /// Whether this document can be deleted (only non-approved).
  bool get canDelete => status != DocumentStatus.approved;

  /// Human-readable file size.
  String get fileSizeFormatted {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DistributorDocument &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          status == other.status;

  @override
  int get hashCode => Object.hash(id, status);
}
