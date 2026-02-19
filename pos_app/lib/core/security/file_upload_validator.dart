/// File Upload Validator
///
/// التحقق من صحة وأمان الملفات المرفوعة
/// يحمي من:
/// - Malicious file uploads
/// - File type spoofing
/// - Path traversal في أسماء الملفات
/// - Oversized files
library;

import 'package:flutter/foundation.dart';

/// أنواع الملفات المدعومة
enum FileCategory {
  image,
  document,
  archive,
  audio,
  video,
  other,
}

/// نتيجة التحقق من الملف
class FileValidationResult {
  final bool isValid;
  final String? sanitizedFileName;
  final String? detectedMimeType;
  final FileCategory? category;
  final List<String> issues;
  final List<String> warnings;

  const FileValidationResult({
    required this.isValid,
    this.sanitizedFileName,
    this.detectedMimeType,
    this.category,
    this.issues = const [],
    this.warnings = const [],
  });

  factory FileValidationResult.valid({
    required String sanitizedFileName,
    required String detectedMimeType,
    required FileCategory category,
    List<String> warnings = const [],
  }) {
    return FileValidationResult(
      isValid: true,
      sanitizedFileName: sanitizedFileName,
      detectedMimeType: detectedMimeType,
      category: category,
      warnings: warnings,
    );
  }

  factory FileValidationResult.invalid({required List<String> issues}) {
    return FileValidationResult(
      isValid: false,
      issues: issues,
    );
  }

  @override
  String toString() {
    if (isValid) {
      return 'FileValidationResult.valid(file: $sanitizedFileName, type: $detectedMimeType)';
    }
    return 'FileValidationResult.invalid(issues: $issues)';
  }
}

/// تكوين التحقق من الملفات
class FileValidationConfig {
  /// الحد الأقصى لحجم الملف (bytes)
  final int maxFileSize;

  /// أنواع MIME المسموحة
  final List<String> allowedMimeTypes;

  /// امتدادات الملفات المسموحة
  final List<String> allowedExtensions;

  /// التحقق من Magic Bytes
  final bool validateMagicBytes;

  /// السماح بالملفات التنفيذية
  final bool allowExecutables;

  /// الحد الأقصى لطول اسم الملف
  final int maxFileNameLength;

  const FileValidationConfig({
    this.maxFileSize = 10 * 1024 * 1024, // 10 MB
    this.allowedMimeTypes = const [],
    this.allowedExtensions = const [],
    this.validateMagicBytes = true,
    this.allowExecutables = false,
    this.maxFileNameLength = 255,
  });

  /// تكوين للصور فقط
  static const images = FileValidationConfig(
    maxFileSize: 5 * 1024 * 1024, // 5 MB
    allowedMimeTypes: [
      'image/jpeg',
      'image/png',
      'image/gif',
      'image/webp',
    ],
    allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
    validateMagicBytes: true,
    allowExecutables: false,
  );

  /// تكوين للمستندات
  static const documents = FileValidationConfig(
    maxFileSize: 20 * 1024 * 1024, // 20 MB
    allowedMimeTypes: [
      'application/pdf',
      'application/msword',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'application/vnd.ms-excel',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'text/plain',
      'text/csv',
    ],
    allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt', 'csv'],
    validateMagicBytes: true,
    allowExecutables: false,
  );

  /// تكوين عام
  static const general = FileValidationConfig(
    maxFileSize: 50 * 1024 * 1024, // 50 MB
    validateMagicBytes: true,
    allowExecutables: false,
  );
}

/// File Upload Validator
class FileUploadValidator {
  FileUploadValidator._();

  /// Magic Bytes لأنواع الملفات الشائعة
  static const Map<String, List<int>> _magicBytes = {
    // Images
    'image/jpeg': [0xFF, 0xD8, 0xFF],
    'image/png': [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A],
    'image/gif': [0x47, 0x49, 0x46, 0x38], // GIF8
    'image/webp': [0x52, 0x49, 0x46, 0x46], // RIFF (needs WEBP check)
    'image/bmp': [0x42, 0x4D],

    // Documents
    'application/pdf': [0x25, 0x50, 0x44, 0x46], // %PDF
    'application/zip': [0x50, 0x4B, 0x03, 0x04],
    'application/x-rar': [0x52, 0x61, 0x72, 0x21],

    // Office documents (ZIP-based)
    'application/vnd.openxmlformats-officedocument': [0x50, 0x4B, 0x03, 0x04],

    // Executables (to block)
    'application/x-executable': [0x7F, 0x45, 0x4C, 0x46], // ELF
    'application/x-msdos-program': [0x4D, 0x5A], // MZ (Windows EXE)
  };

  /// امتدادات خطيرة
  static const List<String> _dangerousExtensions = [
    'exe', 'dll', 'bat', 'cmd', 'com', 'msi', 'scr', 'pif',
    'vbs', 'vbe', 'js', 'jse', 'ws', 'wsf', 'wsc', 'wsh',
    'ps1', 'psm1', 'psd1', 'reg', 'inf', 'scf', 'lnk',
    'sh', 'bash', 'csh', 'zsh', 'app', 'dmg', 'pkg',
    'php', 'phtml', 'php3', 'php4', 'php5', 'phps',
    'asp', 'aspx', 'cer', 'cgi', 'jar', 'war',
  ];

  /// التحقق من ملف
  static FileValidationResult validate(
    Uint8List bytes,
    String fileName, {
    String? declaredMimeType,
    FileValidationConfig config = const FileValidationConfig(),
  }) {
    final issues = <String>[];
    final warnings = <String>[];

    // 1. التحقق من الحجم
    if (bytes.length > config.maxFileSize) {
      final maxMB = config.maxFileSize / (1024 * 1024);
      final actualMB = bytes.length / (1024 * 1024);
      issues.add(
        'File size (${actualMB.toStringAsFixed(2)} MB) exceeds maximum '
        'allowed (${maxMB.toStringAsFixed(2)} MB)',
      );
    }

    // 2. تنظيف اسم الملف
    final sanitizedName = _sanitizeFileName(fileName, issues);
    if (sanitizedName == null) {
      return FileValidationResult.invalid(issues: issues);
    }

    // 3. التحقق من طول الاسم
    if (sanitizedName.length > config.maxFileNameLength) {
      issues.add('File name exceeds maximum length of ${config.maxFileNameLength}');
    }

    // 4. استخراج الامتداد
    final extension = _getExtension(sanitizedName).toLowerCase();

    // 5. التحقق من الامتدادات الخطيرة
    if (!config.allowExecutables && _dangerousExtensions.contains(extension)) {
      issues.add('File type "$extension" is not allowed for security reasons');
    }

    // 6. التحقق من الامتدادات المسموحة
    if (config.allowedExtensions.isNotEmpty &&
        !config.allowedExtensions.contains(extension)) {
      issues.add(
        'File extension "$extension" is not in allowed list: '
        '${config.allowedExtensions.join(", ")}',
      );
    }

    // 7. كشف MIME type من Magic Bytes
    String? detectedMimeType;
    if (config.validateMagicBytes && bytes.isNotEmpty) {
      detectedMimeType = _detectMimeType(bytes);

      // التحقق من تطابق MIME type المعلن
      if (declaredMimeType != null && detectedMimeType != null) {
        if (!_mimeTypesMatch(declaredMimeType, detectedMimeType)) {
          warnings.add(
            'Declared MIME type ($declaredMimeType) does not match '
            'detected type ($detectedMimeType)',
          );
        }
      }

      // التحقق من MIME types المسموحة
      if (config.allowedMimeTypes.isNotEmpty && detectedMimeType != null) {
        final isAllowed = config.allowedMimeTypes.any(
          (allowed) => _mimeTypesMatch(allowed, detectedMimeType!),
        );
        if (!isAllowed) {
          issues.add(
            'Detected MIME type ($detectedMimeType) is not in allowed list',
          );
        }
      }
    }

    // 8. فحص محتوى خطير في الصور
    if (_isImageMimeType(detectedMimeType ?? declaredMimeType ?? '')) {
      _checkForEmbeddedScripts(bytes, warnings);
    }

    // 9. تحديد فئة الملف
    final category = _categorizeFile(detectedMimeType ?? declaredMimeType, extension);

    if (issues.isNotEmpty) {
      return FileValidationResult.invalid(issues: issues);
    }

    return FileValidationResult.valid(
      sanitizedFileName: sanitizedName,
      detectedMimeType: detectedMimeType ?? declaredMimeType ?? 'application/octet-stream',
      category: category,
      warnings: warnings,
    );
  }

  /// تنظيف اسم الملف
  static String? _sanitizeFileName(String fileName, List<String> issues) {
    // إزالة path traversal
    var sanitized = fileName
        .replaceAll(RegExp(r'\.\.'), '')
        .replaceAll(RegExp(r'[/\\]'), '_');

    // إزالة null bytes
    sanitized = sanitized.replaceAll('\x00', '');

    // إزالة أحرف خاصة
    sanitized = sanitized.replaceAll(RegExp(r'[<>:"|?*]'), '_');

    // التحقق من أن الاسم غير فارغ
    if (sanitized.isEmpty || sanitized == '.') {
      issues.add('Invalid file name');
      return null;
    }

    // منع الملفات المخفية
    if (sanitized.startsWith('.')) {
      sanitized = '_${sanitized.substring(1)}';
    }

    return sanitized;
  }

  /// استخراج امتداد الملف
  static String _getExtension(String fileName) {
    final parts = fileName.split('.');
    if (parts.length < 2) return '';
    return parts.last;
  }

  /// كشف MIME type من Magic Bytes
  static String? _detectMimeType(Uint8List bytes) {
    if (bytes.length < 8) return null;

    for (final entry in _magicBytes.entries) {
      final mimeType = entry.key;
      final magic = entry.value;

      if (bytes.length >= magic.length) {
        var matches = true;
        for (var i = 0; i < magic.length; i++) {
          if (bytes[i] != magic[i]) {
            matches = false;
            break;
          }
        }
        if (matches) {
          // للـ WEBP، تحقق إضافي
          if (mimeType == 'image/webp') {
            if (bytes.length >= 12 &&
                bytes[8] == 0x57 && // W
                bytes[9] == 0x45 && // E
                bytes[10] == 0x42 && // B
                bytes[11] == 0x50) { // P
              return 'image/webp';
            }
            continue;
          }
          return mimeType;
        }
      }
    }

    return null;
  }

  /// التحقق من تطابق MIME types
  static bool _mimeTypesMatch(String type1, String type2) {
    final normalized1 = type1.split(';').first.trim().toLowerCase();
    final normalized2 = type2.split(';').first.trim().toLowerCase();

    if (normalized1 == normalized2) return true;

    // Office documents special case
    if ((normalized1.contains('openxmlformats') ||
            normalized2.contains('openxmlformats')) &&
        (normalized1 == 'application/zip' || normalized2 == 'application/zip')) {
      return true;
    }

    return false;
  }

  /// هل هو نوع صورة؟
  static bool _isImageMimeType(String mimeType) {
    return mimeType.startsWith('image/');
  }

  /// فحص للـ scripts مضمنة في الصور
  static void _checkForEmbeddedScripts(Uint8List bytes, List<String> warnings) {
    // تحويل bytes لـ string للبحث
    final content = String.fromCharCodes(bytes.take(10000));

    final suspiciousPatterns = [
      '<script',
      'javascript:',
      '<?php',
      '<%',
      'eval(',
      'onclick=',
      'onerror=',
    ];

    for (final pattern in suspiciousPatterns) {
      if (content.toLowerCase().contains(pattern)) {
        warnings.add('Suspicious content detected in file: possible embedded script');
        break;
      }
    }
  }

  /// تصنيف الملف
  static FileCategory _categorizeFile(String? mimeType, String extension) {
    if (mimeType != null) {
      if (mimeType.startsWith('image/')) return FileCategory.image;
      if (mimeType.startsWith('audio/')) return FileCategory.audio;
      if (mimeType.startsWith('video/')) return FileCategory.video;
      if (mimeType.contains('pdf') ||
          mimeType.contains('document') ||
          mimeType.contains('text/')) {
        return FileCategory.document;
      }
      if (mimeType.contains('zip') ||
          mimeType.contains('rar') ||
          mimeType.contains('tar')) {
        return FileCategory.archive;
      }
    }

    // Fallback to extension
    const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'svg'];
    const documentExtensions = ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt', 'csv'];
    const archiveExtensions = ['zip', 'rar', 'tar', 'gz', '7z'];

    if (imageExtensions.contains(extension)) return FileCategory.image;
    if (documentExtensions.contains(extension)) return FileCategory.document;
    if (archiveExtensions.contains(extension)) return FileCategory.archive;

    return FileCategory.other;
  }

  /// التحقق السريع من نوع الملف
  static bool isValidImage(Uint8List bytes, String fileName) {
    final result = validate(
      bytes,
      fileName,
      config: FileValidationConfig.images,
    );
    return result.isValid;
  }

  /// التحقق السريع من مستند
  static bool isValidDocument(Uint8List bytes, String fileName) {
    final result = validate(
      bytes,
      fileName,
      config: FileValidationConfig.documents,
    );
    return result.isValid;
  }

  /// طباعة تقرير التحقق
  static void printValidationReport(FileValidationResult result) {
    if (!kDebugMode) return;

    debugPrint('╔═══════════════════════════════════════════════════════════════╗');
    debugPrint('║              File Validation Report                           ║');
    debugPrint('╠═══════════════════════════════════════════════════════════════╣');
    debugPrint('║  Status: ${result.isValid ? "✅ VALID" : "❌ INVALID"}${" " * 43}║');
    if (result.sanitizedFileName != null) {
      debugPrint('║  File: ${result.sanitizedFileName?.padRight(52)}║');
    }
    if (result.detectedMimeType != null) {
      debugPrint('║  MIME: ${result.detectedMimeType?.padRight(52)}║');
    }
    if (result.category != null) {
      debugPrint('║  Category: ${result.category!.name.padRight(49)}║');
    }

    if (result.issues.isNotEmpty) {
      debugPrint('╠═══════════════════════════════════════════════════════════════╣');
      debugPrint('║  Issues:');
      for (final issue in result.issues) {
        debugPrint('║    ❌ $issue');
      }
    }

    if (result.warnings.isNotEmpty) {
      debugPrint('╠═══════════════════════════════════════════════════════════════╣');
      debugPrint('║  Warnings:');
      for (final warning in result.warnings) {
        debugPrint('║    ⚠️ $warning');
      }
    }

    debugPrint('╚═══════════════════════════════════════════════════════════════╝');
  }
}
