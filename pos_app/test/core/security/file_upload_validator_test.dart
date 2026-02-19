import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/security/file_upload_validator.dart';

void main() {
  // JPEG Magic Bytes
  final jpegBytes = Uint8List.fromList([
    0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46,
    0x49, 0x46, 0x00, 0x01, 0x01, 0x00, 0x00, 0x01,
    ...List.filled(100, 0x00), // padding
  ]);

  // PNG Magic Bytes
  final pngBytes = Uint8List.fromList([
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
    ...List.filled(100, 0x00), // padding
  ]);

  // PDF Magic Bytes
  final pdfBytes = Uint8List.fromList([
    0x25, 0x50, 0x44, 0x46, 0x2D, 0x31, 0x2E, 0x34,
    ...List.filled(100, 0x00), // padding
  ]);

  // ZIP Magic Bytes (for Office documents)
  final zipBytes = Uint8List.fromList([
    0x50, 0x4B, 0x03, 0x04, 0x14, 0x00, 0x06, 0x00,
    ...List.filled(100, 0x00), // padding
  ]);

  // Invalid/Unknown bytes
  final unknownBytes = Uint8List.fromList([
    0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
    ...List.filled(100, 0x00),
  ]);

  group('FileUploadValidator', () {
    group('validate', () {
      test('يقبل صورة JPEG صالحة', () {
        final result = FileUploadValidator.validate(
          jpegBytes,
          'photo.jpg',
          config: FileValidationConfig.images,
        );

        expect(result.isValid, isTrue);
        expect(result.detectedMimeType, equals('image/jpeg'));
        expect(result.category, equals(FileCategory.image));
      });

      test('يقبل صورة PNG صالحة', () {
        final result = FileUploadValidator.validate(
          pngBytes,
          'image.png',
          config: FileValidationConfig.images,
        );

        expect(result.isValid, isTrue);
        expect(result.detectedMimeType, equals('image/png'));
      });

      test('يقبل PDF صالح', () {
        final result = FileUploadValidator.validate(
          pdfBytes,
          'document.pdf',
          config: FileValidationConfig.documents,
        );

        expect(result.isValid, isTrue);
        expect(result.detectedMimeType, equals('application/pdf'));
        expect(result.category, equals(FileCategory.document));
      });

      test('يرفض ملف يتجاوز الحد الأقصى', () {
        final largeFile = Uint8List(6 * 1024 * 1024); // 6 MB
        largeFile.setRange(0, jpegBytes.length, jpegBytes);

        final result = FileUploadValidator.validate(
          largeFile,
          'large.jpg',
          config: FileValidationConfig.images, // max 5 MB
        );

        expect(result.isValid, isFalse);
        expect(result.issues.any((i) => i.contains('exceeds')), isTrue);
      });

      test('يرفض امتدادات خطيرة', () {
        final result = FileUploadValidator.validate(
          unknownBytes,
          'malware.exe',
        );

        expect(result.isValid, isFalse);
        expect(result.issues.any((i) => i.contains('not allowed')), isTrue);
      });

      test('يرفض امتدادات غير مسموحة', () {
        final result = FileUploadValidator.validate(
          pdfBytes,
          'document.pdf',
          config: FileValidationConfig.images, // images only
        );

        expect(result.isValid, isFalse);
        expect(result.issues.any((i) => i.contains('not in allowed list')), isTrue);
      });

      test('يحذر من عدم تطابق MIME type', () {
        final result = FileUploadValidator.validate(
          jpegBytes,
          'image.jpg',
          declaredMimeType: 'image/png', // declared PNG but content is JPEG
        );

        expect(result.isValid, isTrue);
        expect(result.warnings.any((w) => w.contains('does not match')), isTrue);
      });
    });

    group('file name sanitization', () {
      test('يزيل path traversal', () {
        final result = FileUploadValidator.validate(
          jpegBytes,
          '../../../etc/passwd.jpg',
          config: FileValidationConfig.images,
        );

        expect(result.isValid, isTrue);
        expect(result.sanitizedFileName, isNot(contains('..')));
        expect(result.sanitizedFileName, isNot(contains('/')));
      });

      test('يزيل null bytes', () {
        final result = FileUploadValidator.validate(
          jpegBytes,
          'image\x00.exe.jpg',
          config: FileValidationConfig.images,
        );

        expect(result.isValid, isTrue);
        expect(result.sanitizedFileName, isNot(contains('\x00')));
      });

      test('يزيل أحرف خاصة', () {
        final result = FileUploadValidator.validate(
          jpegBytes,
          'image<script>.jpg',
          config: FileValidationConfig.images,
        );

        expect(result.isValid, isTrue);
        expect(result.sanitizedFileName, isNot(contains('<')));
        expect(result.sanitizedFileName, isNot(contains('>')));
      });

      test('يتعامل مع الملفات المخفية', () {
        final result = FileUploadValidator.validate(
          jpegBytes,
          '.hidden.jpg',
          config: FileValidationConfig.images,
        );

        expect(result.isValid, isTrue);
        expect(result.sanitizedFileName, isNot(startsWith('.')));
      });

      test('يرفض اسم ملف فارغ', () {
        final result = FileUploadValidator.validate(
          jpegBytes,
          '',
        );

        expect(result.isValid, isFalse);
        expect(result.issues.any((i) => i.contains('Invalid file name')), isTrue);
      });
    });

    group('magic bytes detection', () {
      test('يكشف JPEG من Magic Bytes', () {
        final result = FileUploadValidator.validate(
          jpegBytes,
          'file_without_extension',
        );

        expect(result.detectedMimeType, equals('image/jpeg'));
      });

      test('يكشف PNG من Magic Bytes', () {
        final result = FileUploadValidator.validate(
          pngBytes,
          'file_without_extension',
        );

        expect(result.detectedMimeType, equals('image/png'));
      });

      test('يكشف PDF من Magic Bytes', () {
        final result = FileUploadValidator.validate(
          pdfBytes,
          'file_without_extension',
        );

        expect(result.detectedMimeType, equals('application/pdf'));
      });

      test('يعيد null لـ bytes غير معروفة', () {
        final result = FileUploadValidator.validate(
          unknownBytes,
          'unknown.dat',
          config: const FileValidationConfig(
            allowedExtensions: ['dat'],
          ),
        );

        expect(result.isValid, isTrue);
        // detectedMimeType is null, fallback to octet-stream
        expect(result.detectedMimeType, equals('application/octet-stream'));
      });
    });

    group('embedded script detection', () {
      test('يحذر من scripts مضمنة في الصور', () {
        final maliciousJpeg = Uint8List.fromList([
          ...jpegBytes,
          ...'<script>alert("xss")</script>'.codeUnits,
        ]);

        final result = FileUploadValidator.validate(
          maliciousJpeg,
          'image.jpg',
          config: FileValidationConfig.images,
        );

        expect(result.warnings.any((w) => w.contains('Suspicious')), isTrue);
      });

      test('يحذر من PHP مضمن', () {
        final maliciousJpeg = Uint8List.fromList([
          ...jpegBytes,
          ...'<?php echo "hack"; ?>'.codeUnits,
        ]);

        final result = FileUploadValidator.validate(
          maliciousJpeg,
          'image.jpg',
          config: FileValidationConfig.images,
        );

        expect(result.warnings.any((w) => w.contains('Suspicious')), isTrue);
      });
    });

    group('file categorization', () {
      test('يصنف الصور بشكل صحيح', () {
        final result = FileUploadValidator.validate(
          jpegBytes,
          'photo.jpg',
        );

        expect(result.category, equals(FileCategory.image));
      });

      test('يصنف المستندات بشكل صحيح', () {
        final result = FileUploadValidator.validate(
          pdfBytes,
          'doc.pdf',
        );

        expect(result.category, equals(FileCategory.document));
      });

      test('يصنف الأرشيفات بشكل صحيح', () {
        final result = FileUploadValidator.validate(
          zipBytes,
          'archive.zip',
          config: const FileValidationConfig(
            allowedExtensions: ['zip'],
          ),
        );

        expect(result.category, equals(FileCategory.archive));
      });
    });

    group('isValidImage', () {
      test('يعيد true لصورة صالحة', () {
        expect(
          FileUploadValidator.isValidImage(jpegBytes, 'photo.jpg'),
          isTrue,
        );
      });

      test('يعيد false لملف غير صورة', () {
        expect(
          FileUploadValidator.isValidImage(pdfBytes, 'doc.pdf'),
          isFalse,
        );
      });
    });

    group('isValidDocument', () {
      test('يعيد true لمستند صالح', () {
        expect(
          FileUploadValidator.isValidDocument(pdfBytes, 'doc.pdf'),
          isTrue,
        );
      });

      test('يعيد false لملف غير مستند', () {
        expect(
          FileUploadValidator.isValidDocument(jpegBytes, 'photo.jpg'),
          isFalse,
        );
      });
    });
  });

  group('FileValidationResult', () {
    test('valid factory يعمل', () {
      final result = FileValidationResult.valid(
        sanitizedFileName: 'file.jpg',
        detectedMimeType: 'image/jpeg',
        category: FileCategory.image,
      );

      expect(result.isValid, isTrue);
      expect(result.sanitizedFileName, equals('file.jpg'));
    });

    test('invalid factory يعمل', () {
      final result = FileValidationResult.invalid(
        issues: ['Error 1', 'Error 2'],
      );

      expect(result.isValid, isFalse);
      expect(result.issues.length, equals(2));
    });

    test('toString يعمل للنتيجة الصالحة', () {
      final result = FileValidationResult.valid(
        sanitizedFileName: 'file.jpg',
        detectedMimeType: 'image/jpeg',
        category: FileCategory.image,
      );

      expect(result.toString(), contains('valid'));
      expect(result.toString(), contains('file.jpg'));
    });

    test('toString يعمل للنتيجة غير الصالحة', () {
      final result = FileValidationResult.invalid(
        issues: ['Test error'],
      );

      expect(result.toString(), contains('invalid'));
    });
  });

  group('FileValidationConfig', () {
    test('images config صحيح', () {
      expect(FileValidationConfig.images.maxFileSize, equals(5 * 1024 * 1024));
      expect(FileValidationConfig.images.allowedExtensions, contains('jpg'));
      expect(FileValidationConfig.images.allowedExtensions, contains('png'));
    });

    test('documents config صحيح', () {
      expect(FileValidationConfig.documents.maxFileSize, equals(20 * 1024 * 1024));
      expect(FileValidationConfig.documents.allowedExtensions, contains('pdf'));
      expect(FileValidationConfig.documents.allowedExtensions, contains('docx'));
    });

    test('general config صحيح', () {
      expect(FileValidationConfig.general.maxFileSize, equals(50 * 1024 * 1024));
      expect(FileValidationConfig.general.allowExecutables, isFalse);
    });
  });
}
