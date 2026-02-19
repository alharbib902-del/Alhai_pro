import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// خدمة الذكاء الاصطناعي لاستخراج بيانات الفواتير
class AiInvoiceService {
  // ignore: unused_field
  static const String _baseUrl = 'https://api.alhai.app/v1/ai';
  
  /// استخراج بيانات الفاتورة من الصورة
  static Future<AiInvoiceResult> extractInvoiceData(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      // ignore: unused_local_variable
      final base64Image = base64Encode(bytes);

      // بيانات وهمية للتطوير فقط
      if (kDebugMode) {
        return _getMockData();
      }

      // TODO: Enable when API endpoint is ready
      // final response = await http.post(
      //   Uri.parse('$_baseUrl/extract-invoice'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode({'image': base64Image}),
      // );

      // In production, throw until the API is ready
      throw AiInvoiceException(
        'خدمة استخراج الفواتير بالذكاء الاصطناعي غير متاحة حالياً. '
        'يرجى إدخال البيانات يدوياً.',
      );
    } catch (e) {
      if (e is AiInvoiceException) rethrow;
      throw AiInvoiceException('فشل في استخراج البيانات: $e');
    }
  }
  
  /// بيانات وهمية للتطوير
  static AiInvoiceResult _getMockData() {
    return AiInvoiceResult(
      supplierName: 'شركة الأغذية المتحدة',
      invoiceNumber: 'INV-2024-001',
      invoiceDate: DateTime.now().subtract(const Duration(days: 2)),
      totalAmount: 5750.0,
      taxAmount: 862.5,
      items: [
        AiInvoiceItem(
          rawName: 'أرز بسمتي 5 كجم',
          quantity: 50,
          unitPrice: 35.0,
          total: 1750.0,
          confidence: 95,
          matchedProductId: null,
        ),
        AiInvoiceItem(
          rawName: 'زيت نباتي 2 لتر',
          quantity: 30,
          unitPrice: 28.0,
          total: 840.0,
          confidence: 88,
          matchedProductId: null,
        ),
        AiInvoiceItem(
          rawName: 'سكر أبيض 10 كجم',
          quantity: 25,
          unitPrice: 45.0,
          total: 1125.0,
          confidence: 92,
          matchedProductId: null,
        ),
        AiInvoiceItem(
          rawName: 'دقيق فاخر 25 كجم',
          quantity: 15,
          unitPrice: 65.0,
          total: 975.0,
          confidence: 60,
          matchedProductId: null,
        ),
        AiInvoiceItem(
          rawName: 'ملح طعام 1 كجم',
          quantity: 100,
          unitPrice: 3.5,
          total: 350.0,
          confidence: 45,
          matchedProductId: null,
        ),
      ],
    );
  }
}

/// نتيجة استخراج الفاتورة
class AiInvoiceResult {
  final String? supplierName;
  final String? invoiceNumber;
  final DateTime? invoiceDate;
  final double totalAmount;
  final double taxAmount;
  final List<AiInvoiceItem> items;

  AiInvoiceResult({
    this.supplierName,
    this.invoiceNumber,
    this.invoiceDate,
    required this.totalAmount,
    required this.taxAmount,
    required this.items,
  });

  factory AiInvoiceResult.fromJson(Map<String, dynamic> json) {
    return AiInvoiceResult(
      supplierName: json['supplier_name'],
      invoiceNumber: json['invoice_number'],
      invoiceDate: json['invoice_date'] != null 
          ? DateTime.parse(json['invoice_date']) 
          : null,
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      taxAmount: (json['tax_amount'] ?? 0).toDouble(),
      items: (json['items'] as List?)
          ?.map((e) => AiInvoiceItem.fromJson(e))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'supplier_name': supplierName,
      'invoice_number': invoiceNumber,
      'invoice_date': invoiceDate?.toIso8601String(),
      'total_amount': totalAmount,
      'tax_amount': taxAmount,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}

/// عنصر في الفاتورة المستخرجة
class AiInvoiceItem {
  final String rawName;
  final double quantity;
  final double unitPrice;
  final double total;
  final int confidence; // 0-100
  String? matchedProductId;
  String? matchedProductName;
  bool isConfirmed;

  AiInvoiceItem({
    required this.rawName,
    required this.quantity,
    required this.unitPrice,
    required this.total,
    required this.confidence,
    this.matchedProductId,
    this.matchedProductName,
    this.isConfirmed = false,
  });

  bool get needsReview => confidence < 70;

  factory AiInvoiceItem.fromJson(Map<String, dynamic> json) {
    return AiInvoiceItem(
      rawName: json['raw_name'] ?? '',
      quantity: (json['quantity'] ?? 0).toDouble(),
      unitPrice: (json['unit_price'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      confidence: json['confidence'] ?? 0,
      matchedProductId: json['matched_product_id'],
      matchedProductName: json['matched_product_name'],
      isConfirmed: json['is_confirmed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'raw_name': rawName,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total': total,
      'confidence': confidence,
      'matched_product_id': matchedProductId,
      'matched_product_name': matchedProductName,
      'is_confirmed': isConfirmed,
    };
  }
}

/// استثناء خدمة AI
class AiInvoiceException implements Exception {
  final String message;
  AiInvoiceException(this.message);
  
  @override
  String toString() => message;
}
