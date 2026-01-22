import 'dart:convert';
import 'package:alhai_core/alhai_core.dart';

/// خدمة الاستيراد
/// تستخدم من: admin_pos
class ImportService {
  /// استيراد المنتجات من CSV
  ImportResult<Product> importProductsFromCsv(String csvContent) {
    final lines = const LineSplitter().convert(csvContent);
    if (lines.isEmpty) {
      return ImportResult(
        success: false,
        error: 'الملف فارغ',
        imported: [],
        failed: [],
      );
    }

    final imported = <Product>[];
    final failed = <ImportError>[];

    // Skip header row
    for (int i = 1; i < lines.length; i++) {
      try {
        final values = _parseCsvLine(lines[i]);
        if (values.length < 3) {
          failed.add(ImportError(line: i + 1, error: 'عدد الأعمدة غير كافٍ'));
          continue;
        }

        // Expected format: barcode,name,price,stockQty,categoryId
        final product = Product(
          id: '', // Will be generated
          storeId: '', // Will be set by caller
          name: values[1].trim(),
          price: double.tryParse(values[2].trim()) ?? 0,
          barcode: values[0].trim().isNotEmpty ? values[0].trim() : null,
          stockQty: values.length > 3 ? (int.tryParse(values[3].trim()) ?? 0) : 0,
          categoryId: values.length > 4 && values[4].trim().isNotEmpty ? values[4].trim() : null,
          isActive: true,
          createdAt: DateTime.now(),
        );

        if (product.name.isEmpty) {
          failed.add(ImportError(line: i + 1, error: 'اسم المنتج مطلوب'));
          continue;
        }

        if (product.price <= 0) {
          failed.add(ImportError(line: i + 1, error: 'السعر يجب أن يكون أكبر من صفر'));
          continue;
        }

        imported.add(product);
      } catch (e) {
        failed.add(ImportError(line: i + 1, error: e.toString()));
      }
    }

    return ImportResult(
      success: failed.isEmpty,
      imported: imported,
      failed: failed,
    );
  }

  /// استيراد العملاء من CSV
  ImportResult<Map<String, String>> importCustomersFromCsv(String csvContent) {
    final lines = const LineSplitter().convert(csvContent);
    if (lines.isEmpty) {
      return ImportResult(
        success: false,
        error: 'الملف فارغ',
        imported: [],
        failed: [],
      );
    }

    final imported = <Map<String, String>>[];
    final failed = <ImportError>[];

    // Skip header row
    for (int i = 1; i < lines.length; i++) {
      try {
        final values = _parseCsvLine(lines[i]);
        if (values.length < 2) {
          failed.add(ImportError(line: i + 1, error: 'عدد الأعمدة غير كافٍ'));
          continue;
        }

        // Expected format: name,phone,address
        final customer = {
          'name': values[0].trim(),
          'phone': values[1].trim(),
          'address': values.length > 2 ? values[2].trim() : '',
        };

        if (customer['name']!.isEmpty) {
          failed.add(ImportError(line: i + 1, error: 'اسم العميل مطلوب'));
          continue;
        }

        if (customer['phone']!.isEmpty) {
          failed.add(ImportError(line: i + 1, error: 'رقم الهاتف مطلوب'));
          continue;
        }

        imported.add(customer);
      } catch (e) {
        failed.add(ImportError(line: i + 1, error: e.toString()));
      }
    }

    return ImportResult(
      success: failed.isEmpty,
      imported: imported,
      failed: failed,
    );
  }

  /// تحليل ملف JSON
  ImportResult<Map<String, dynamic>> importFromJson(String jsonContent) {
    try {
      final data = jsonDecode(jsonContent);
      if (data is List) {
        return ImportResult(
          success: true,
          imported: data.cast<Map<String, dynamic>>(),
          failed: [],
        );
      } else if (data is Map<String, dynamic>) {
        return ImportResult(
          success: true,
          imported: [data],
          failed: [],
        );
      } else {
        return ImportResult(
          success: false,
          error: 'صيغة JSON غير صالحة',
          imported: [],
          failed: [],
        );
      }
    } catch (e) {
      return ImportResult(
        success: false,
        error: 'خطأ في تحليل JSON: $e',
        imported: [],
        failed: [],
      );
    }
  }

  /// التحقق من صحة ملف CSV
  CsvValidationResult validateCsv(String csvContent, List<String> requiredColumns) {
    final lines = const LineSplitter().convert(csvContent);
    if (lines.isEmpty) {
      return CsvValidationResult(
        isValid: false,
        error: 'الملف فارغ',
        rowCount: 0,
        columnCount: 0,
        columns: [],
      );
    }

    final headerValues = _parseCsvLine(lines[0]);
    final missingColumns = requiredColumns.where((col) => !headerValues.contains(col)).toList();

    return CsvValidationResult(
      isValid: missingColumns.isEmpty,
      error: missingColumns.isNotEmpty ? 'أعمدة مفقودة: ${missingColumns.join(', ')}' : null,
      rowCount: lines.length - 1, // Exclude header
      columnCount: headerValues.length,
      columns: headerValues,
    );
  }

  /// توليد قالب CSV للمنتجات
  String generateProductsTemplate() {
    return 'الباركود,اسم المنتج,السعر,المخزون,الفئة\n628XXXXXXXXX,منتج تجريبي,10.00,100,';
  }

  /// توليد قالب CSV للعملاء
  String generateCustomersTemplate() {
    return 'الاسم,الهاتف,العنوان\nعميل تجريبي,0500000000,الرياض';
  }

  // ==================== Helpers ====================

  List<String> _parseCsvLine(String line) {
    final result = <String>[];
    var current = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < line.length; i++) {
      final char = line[i];

      if (char == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          current.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        result.add(current.toString());
        current = StringBuffer();
      } else {
        current.write(char);
      }
    }
    result.add(current.toString());

    return result;
  }
}

/// نتيجة الاستيراد
class ImportResult<T> {
  final bool success;
  final String? error;
  final List<T> imported;
  final List<ImportError> failed;

  const ImportResult({
    required this.success,
    this.error,
    required this.imported,
    required this.failed,
  });

  int get totalRows => imported.length + failed.length;
  int get successCount => imported.length;
  int get failedCount => failed.length;
}

/// خطأ استيراد
class ImportError {
  final int line;
  final String error;

  const ImportError({
    required this.line,
    required this.error,
  });
}

/// نتيجة التحقق من CSV
class CsvValidationResult {
  final bool isValid;
  final String? error;
  final int rowCount;
  final int columnCount;
  final List<String> columns;

  const CsvValidationResult({
    required this.isValid,
    this.error,
    required this.rowCount,
    required this.columnCount,
    required this.columns,
  });
}
