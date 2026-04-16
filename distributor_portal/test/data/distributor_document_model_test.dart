import 'package:flutter_test/flutter_test.dart';

import 'package:distributor_portal/data/models.dart';

void main() {
  // ─── Sample JSON matching distributor_documents table schema ───

  final sampleJson = <String, dynamic>{
    'id': 'doc-001',
    'org_id': 'org-1',
    'document_type': 'commercial_registration',
    'file_url': 'org-1/commercial_registration/1713200000000_cr.pdf',
    'file_name': 'cr.pdf',
    'file_size': 2400000,
    'mime_type': 'application/pdf',
    'status': 'under_review',
    'reviewed_by': null,
    'reviewed_at': null,
    'rejection_reason': null,
    'uploaded_at': '2026-04-16T10:00:00.000Z',
    'updated_at': null,
    'expiry_date': '2027-03-15',
  };

  // ─── DocumentType enum ────────────────────────────────────────

  group('DocumentType', () {
    test('dbValue returns correct snake_case values', () {
      expect(
        DocumentType.commercialRegistration.dbValue,
        'commercial_registration',
      );
      expect(DocumentType.vatCertificate.dbValue, 'vat_certificate');
      expect(DocumentType.ceoNationalId.dbValue, 'ceo_national_id');
    });

    test('arabicName returns Arabic labels', () {
      expect(
        DocumentType.commercialRegistration.arabicName,
        'السجل التجاري',
      );
      expect(
        DocumentType.vatCertificate.arabicName,
        'شهادة ضريبة القيمة المضافة',
      );
      expect(DocumentType.ceoNationalId.arabicName, 'هوية المدير العام');
    });

    test('isRequired: CR and VAT required, CEO ID optional', () {
      expect(DocumentType.commercialRegistration.isRequired, isTrue);
      expect(DocumentType.vatCertificate.isRequired, isTrue);
      expect(DocumentType.ceoNationalId.isRequired, isFalse);
    });

    test('fromDbValue round-trips all values', () {
      for (final type in DocumentType.values) {
        expect(DocumentType.fromDbValue(type.dbValue), type);
      }
    });

    test('fromDbValue throws on unknown value', () {
      expect(
        () => DocumentType.fromDbValue('unknown'),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  // ─── DocumentStatus enum ───────────────────────────────────────

  group('DocumentStatus', () {
    test('dbValue returns correct snake_case values', () {
      expect(DocumentStatus.underReview.dbValue, 'under_review');
      expect(DocumentStatus.approved.dbValue, 'approved');
      expect(DocumentStatus.rejected.dbValue, 'rejected');
    });

    test('arabicName returns Arabic labels', () {
      expect(DocumentStatus.underReview.arabicName, 'قيد المراجعة');
      expect(DocumentStatus.approved.arabicName, 'موافق عليه');
      expect(DocumentStatus.rejected.arabicName, 'مرفوض');
    });

    test('fromDbValue round-trips all values', () {
      for (final status in DocumentStatus.values) {
        expect(DocumentStatus.fromDbValue(status.dbValue), status);
      }
    });

    test('fromDbValue defaults to underReview for unknown value', () {
      expect(
        DocumentStatus.fromDbValue('unknown'),
        DocumentStatus.underReview,
      );
    });
  });

  // ─── DistributorDocument ────────────────────────────────────────

  group('DistributorDocument.fromJson', () {
    test('parses all fields correctly', () {
      final doc = DistributorDocument.fromJson(sampleJson);

      expect(doc.id, 'doc-001');
      expect(doc.orgId, 'org-1');
      expect(doc.documentType, DocumentType.commercialRegistration);
      expect(
        doc.fileUrl,
        'org-1/commercial_registration/1713200000000_cr.pdf',
      );
      expect(doc.fileName, 'cr.pdf');
      expect(doc.fileSize, 2400000);
      expect(doc.mimeType, 'application/pdf');
      expect(doc.status, DocumentStatus.underReview);
      expect(doc.reviewedBy, isNull);
      expect(doc.reviewedAt, isNull);
      expect(doc.rejectionReason, isNull);
      expect(doc.uploadedAt.year, 2026);
      expect(doc.updatedAt, isNull);
      expect(doc.expiryDate, isNotNull);
      expect(doc.expiryDate!.year, 2027);
      expect(doc.expiryDate!.month, 3);
      expect(doc.expiryDate!.day, 15);
    });

    test('handles null optional fields', () {
      final minJson = <String, dynamic>{
        'id': 'doc-002',
        'org_id': 'org-1',
        'document_type': 'vat_certificate',
        'file_url': 'path/to/file.jpg',
        'file_name': 'vat.jpg',
        'file_size': 500000,
        'mime_type': 'image/jpeg',
        'status': 'approved',
        'reviewed_by': 'admin-1',
        'reviewed_at': '2026-04-17T12:00:00.000Z',
        'rejection_reason': null,
        'uploaded_at': '2026-04-16T10:00:00.000Z',
        'updated_at': null,
        'expiry_date': null,
      };

      final doc = DistributorDocument.fromJson(minJson);

      expect(doc.documentType, DocumentType.vatCertificate);
      expect(doc.status, DocumentStatus.approved);
      expect(doc.reviewedBy, 'admin-1');
      expect(doc.reviewedAt, isNotNull);
      expect(doc.expiryDate, isNull);
    });

    test('handles rejected status with reason', () {
      final rejectedJson = Map<String, dynamic>.from(sampleJson)
        ..['status'] = 'rejected'
        ..['rejection_reason'] = 'الوثيقة غير واضحة';

      final doc = DistributorDocument.fromJson(rejectedJson);

      expect(doc.status, DocumentStatus.rejected);
      expect(doc.rejectionReason, 'الوثيقة غير واضحة');
    });

    test('defaults status to underReview for unknown value', () {
      final unknownStatusJson = Map<String, dynamic>.from(sampleJson)
        ..['status'] = 'something_else';

      final doc = DistributorDocument.fromJson(unknownStatusJson);
      expect(doc.status, DocumentStatus.underReview);
    });
  });

  group('DistributorDocument.toInsertJson', () {
    test('produces correct snake_case keys', () {
      final doc = DistributorDocument.fromJson(sampleJson);
      final json = doc.toInsertJson();

      expect(json['id'], 'doc-001');
      expect(json['org_id'], 'org-1');
      expect(json['document_type'], 'commercial_registration');
      expect(json['file_url'], contains('cr.pdf'));
      expect(json['file_name'], 'cr.pdf');
      expect(json['file_size'], 2400000);
      expect(json['mime_type'], 'application/pdf');
      expect(json['status'], 'under_review');
      expect(json['expiry_date'], '2027-03-15');
      expect(json['uploaded_at'], isNotNull);
    });

    test('expiry_date is null when not set', () {
      final noExpiryJson = Map<String, dynamic>.from(sampleJson)
        ..['expiry_date'] = null;
      final doc = DistributorDocument.fromJson(noExpiryJson);
      final json = doc.toInsertJson();

      expect(json['expiry_date'], isNull);
    });
  });

  group('DistributorDocument helpers', () {
    test('canDelete is true for under_review', () {
      final doc = DistributorDocument.fromJson(sampleJson);
      expect(doc.canDelete, isTrue);
    });

    test('canDelete is true for rejected', () {
      final rejectedJson = Map<String, dynamic>.from(sampleJson)
        ..['status'] = 'rejected';
      final doc = DistributorDocument.fromJson(rejectedJson);
      expect(doc.canDelete, isTrue);
    });

    test('canDelete is false for approved', () {
      final approvedJson = Map<String, dynamic>.from(sampleJson)
        ..['status'] = 'approved';
      final doc = DistributorDocument.fromJson(approvedJson);
      expect(doc.canDelete, isFalse);
    });

    test('fileSizeFormatted returns human-readable size', () {
      // 2.4 MB
      final doc = DistributorDocument.fromJson(sampleJson);
      expect(doc.fileSizeFormatted, '2.3 MB');

      // Small file
      final smallJson = Map<String, dynamic>.from(sampleJson)
        ..['file_size'] = 500;
      final smallDoc = DistributorDocument.fromJson(smallJson);
      expect(smallDoc.fileSizeFormatted, '500 B');

      // KB range
      final kbJson = Map<String, dynamic>.from(sampleJson)
        ..['file_size'] = 150000;
      final kbDoc = DistributorDocument.fromJson(kbJson);
      expect(kbDoc.fileSizeFormatted, '146.5 KB');
    });

    test('equality is based on id and status', () {
      final doc1 = DistributorDocument.fromJson(sampleJson);
      final doc2 = DistributorDocument.fromJson(sampleJson);
      expect(doc1, equals(doc2));
      expect(doc1.hashCode, equals(doc2.hashCode));

      // Different status => not equal
      final differentJson = Map<String, dynamic>.from(sampleJson)
        ..['status'] = 'approved';
      final doc3 = DistributorDocument.fromJson(differentJson);
      expect(doc1, isNot(equals(doc3)));
    });
  });
}
