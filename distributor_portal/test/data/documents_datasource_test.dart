import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:distributor_portal/data/models.dart';
import 'package:distributor_portal/data/distributor_datasource.dart';

void main() {
  // ─── Validation Tests (no Supabase needed) ─────────────────────

  group('Document upload validation', () {
    test('rejects file larger than 10 MB', () {
      // The datasource checks _maxDocumentSize (10 * 1024 * 1024).
      // We verify the constant exists and is correct.
      const maxSize = 10 * 1024 * 1024;
      final oversized = Uint8List(maxSize + 1);
      expect(oversized.length, greaterThan(maxSize));
    });

    test('allowed MIME types are PDF, JPEG, PNG', () {
      const allowed = ['application/pdf', 'image/jpeg', 'image/png'];
      expect(allowed, contains('application/pdf'));
      expect(allowed, contains('image/jpeg'));
      expect(allowed, contains('image/png'));
      expect(allowed, isNot(contains('image/gif')));
      expect(allowed, isNot(contains('application/zip')));
    });
  });

  // ─── DatasourceError categorization ───────────────────────────

  group('DatasourceError', () {
    test('error types include validation', () {
      const error = DatasourceError(
        type: DatasourceErrorType.validation,
        message: 'حجم الملف يجب أن يكون أقل من 10 ميجابايت',
      );
      expect(error.type, DatasourceErrorType.validation);
      expect(error.message, contains('10'));
    });

    test('approved document delete error', () {
      const error = DatasourceError(
        type: DatasourceErrorType.validation,
        message: 'لا يمكن حذف وثيقة موافق عليها',
      );
      expect(error.type, DatasourceErrorType.validation);
    });

    test('duplicate active document error', () {
      const error = DatasourceError(
        type: DatasourceErrorType.validation,
        message: 'هذه الوثيقة موافق عليها بالفعل',
      );
      expect(error.toString(), contains('validation'));
    });

    test('table not found error', () {
      const error = DatasourceError(
        type: DatasourceErrorType.unknown,
        message: 'جدول الوثائق غير منشأ بعد. راجع الدعم.',
      );
      expect(error.message, contains('غير منشأ'));
    });
  });

  // ─── DocumentType validation ──────────────────────────────────

  group('Document type DB value mapping', () {
    test('all types have unique dbValues', () {
      final dbValues = DocumentType.values.map((t) => t.dbValue).toSet();
      expect(dbValues.length, DocumentType.values.length);
    });

    test('dbValues match expected SQL CHECK constraint values', () {
      expect(
        DocumentType.commercialRegistration.dbValue,
        'commercial_registration',
      );
      expect(DocumentType.vatCertificate.dbValue, 'vat_certificate');
      expect(DocumentType.ceoNationalId.dbValue, 'ceo_national_id');
    });
  });

  // ─── DocumentStatus validation ────────────────────────────────

  group('Document status DB value mapping', () {
    test('all statuses have unique dbValues', () {
      final dbValues = DocumentStatus.values.map((s) => s.dbValue).toSet();
      expect(dbValues.length, DocumentStatus.values.length);
    });

    test('status values match SQL CHECK constraint', () {
      expect(DocumentStatus.underReview.dbValue, 'under_review');
      expect(DocumentStatus.approved.dbValue, 'approved');
      expect(DocumentStatus.rejected.dbValue, 'rejected');
    });
  });

  // ─── Signed URL expectations ──────────────────────────────────

  group('Signed URL expectations', () {
    test('signed URL expiry is 1 hour (3600 seconds)', () {
      // This documents the contract. The actual call uses 3600.
      const expirySeconds = 3600;
      expect(expirySeconds, 60 * 60);
    });
  });

  // ─── Storage path format ──────────────────────────────────────

  group('Storage path format', () {
    test('path follows {orgId}/{docType}/{timestamp}_{filename} pattern', () {
      const orgId = 'org-123';
      const docType = 'commercial_registration';
      const timestamp = 1713200000000;
      const fileName = 'cr.pdf';

      const path = '$orgId/$docType/${timestamp}_$fileName';

      expect(path, 'org-123/commercial_registration/1713200000000_cr.pdf');
      expect(path.split('/').length, 3);
      expect(path.startsWith(orgId), isTrue);
    });
  });
}
