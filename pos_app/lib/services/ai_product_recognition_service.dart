/// خدمة التعرف على المنتجات - AI Product Recognition Service
///
/// التعرف على المنتجات من الصور والكاميرا
/// - نتائج التعرف الوهمية
/// - استخراج OCR
/// - مسح الأرفف
library;

// ============================================================================
// MODELS
// ============================================================================

/// نتيجة التعرف
class RecognitionResult {
  final String id;
  final List<RecognizedProduct> products;
  final DateTime scannedAt;
  final String sourceType;
  final int totalDetected;
  final int totalMatched;
  final double avgConfidence;

  const RecognitionResult({
    required this.id,
    required this.products,
    required this.scannedAt,
    required this.sourceType,
    required this.totalDetected,
    required this.totalMatched,
    required this.avgConfidence,
  });
}

/// منتج تم التعرف عليه
class RecognizedProduct {
  final String? matchedId;
  final String name;
  final String nameAr;
  final double confidence;
  final BoundingBox boundingBox;
  final String? barcode;
  final double? suggestedPrice;
  final String? category;
  final bool isNewProduct;
  final RecognitionStatus status;

  const RecognizedProduct({
    this.matchedId,
    required this.name,
    required this.nameAr,
    required this.confidence,
    required this.boundingBox,
    this.barcode,
    this.suggestedPrice,
    this.category,
    this.isNewProduct = false,
    this.status = RecognitionStatus.matched,
  });
}

/// إطار التحديد
class BoundingBox {
  final double x;
  final double y;
  final double width;
  final double height;

  const BoundingBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });
}

/// حالة التعرف
enum RecognitionStatus {
  matched,
  partialMatch,
  unrecognized,
  newProduct,
}

/// نتيجة مسح الرف
class ShelfScanResult {
  final int totalSlots;
  final int filledSlots;
  final int emptySlots;
  final List<String> outOfStockProducts;
  final List<String> misplacedProducts;
  final double fillRate;

  const ShelfScanResult({
    required this.totalSlots,
    required this.filledSlots,
    required this.emptySlots,
    required this.outOfStockProducts,
    required this.misplacedProducts,
    required this.fillRate,
  });
}

/// استخراج OCR
class OcrExtraction {
  final String? productName;
  final String? barcode;
  final double? price;
  final String? expiryDate;
  final String? brand;
  final String? weight;
  final double confidence;
  final String rawText;

  const OcrExtraction({
    this.productName,
    this.barcode,
    this.price,
    this.expiryDate,
    this.brand,
    this.weight,
    required this.confidence,
    required this.rawText,
  });
}

/// نوع المسح
enum ScanMode {
  singleProduct,
  shelfScan,
  barcodeOcr,
  priceTag,
}

// ============================================================================
// SERVICE
// ============================================================================

/// خدمة التعرف على المنتجات
class AiProductRecognitionService {
  /// نتائج التعرف الوهمية
  static RecognitionResult getMockRecognitionResult() {
    final now = DateTime.now();
    final products = [
      const RecognizedProduct(
        matchedId: 'p001',
        name: 'Almarai Milk 1L',
        nameAr: 'حليب المراعي 1 لتر',
        confidence: 0.96,
        boundingBox: BoundingBox(x: 0.1, y: 0.15, width: 0.2, height: 0.35),
        barcode: '6281007028479',
        suggestedPrice: 6.50,
        category: 'ألبان',
        status: RecognitionStatus.matched,
      ),
      const RecognizedProduct(
        matchedId: 'p002',
        name: 'Goody Tuna 185g',
        nameAr: 'تونة قودي 185 جم',
        confidence: 0.91,
        boundingBox: BoundingBox(x: 0.35, y: 0.2, width: 0.15, height: 0.25),
        barcode: '6281014100112',
        suggestedPrice: 8.25,
        category: 'معلبات',
        status: RecognitionStatus.matched,
      ),
      const RecognizedProduct(
        matchedId: null,
        name: 'Unknown Juice Box',
        nameAr: 'عصير غير معروف',
        confidence: 0.45,
        boundingBox: BoundingBox(x: 0.55, y: 0.1, width: 0.18, height: 0.3),
        category: 'مشروبات',
        isNewProduct: true,
        status: RecognitionStatus.unrecognized,
      ),
      const RecognizedProduct(
        matchedId: 'p004',
        name: 'Rabea Tea 200 bags',
        nameAr: 'شاي ربيع 200 كيس',
        confidence: 0.88,
        boundingBox: BoundingBox(x: 0.75, y: 0.25, width: 0.2, height: 0.28),
        barcode: '6281007131208',
        suggestedPrice: 22.00,
        category: 'مشروبات',
        status: RecognitionStatus.matched,
      ),
      const RecognizedProduct(
        matchedId: 'p005',
        name: 'Basmati Rice 5kg',
        nameAr: 'أرز بسمتي 5 كجم',
        confidence: 0.72,
        boundingBox: BoundingBox(x: 0.1, y: 0.55, width: 0.22, height: 0.3),
        barcode: '6281100520016',
        suggestedPrice: 32.00,
        category: 'أرز وحبوب',
        status: RecognitionStatus.partialMatch,
      ),
    ];

    final matched = products.where((p) => p.status == RecognitionStatus.matched).length;
    final avgConf = products.map((p) => p.confidence).reduce((a, b) => a + b) / products.length;

    return RecognitionResult(
      id: 'scan_${now.millisecondsSinceEpoch}',
      products: products,
      scannedAt: now,
      sourceType: 'كاميرا',
      totalDetected: products.length,
      totalMatched: matched,
      avgConfidence: double.parse(avgConf.toStringAsFixed(2)),
    );
  }

  /// استخراج OCR وهمي
  static OcrExtraction getMockOcrExtraction() {
    return const OcrExtraction(
      productName: 'حليب المراعي كامل الدسم',
      barcode: '6281007028479',
      price: 6.50,
      expiryDate: '2026-05-15',
      brand: 'المراعي',
      weight: '1 لتر',
      confidence: 0.92,
      rawText: 'حليب المراعي كامل الدسم\n1 لتر\nSAR 6.50\nEXP: 2026/05/15\nBarcode: 6281007028479',
    );
  }

  /// نتيجة مسح الرف الوهمية
  static ShelfScanResult getMockShelfScan() {
    return const ShelfScanResult(
      totalSlots: 48,
      filledSlots: 39,
      emptySlots: 9,
      outOfStockProducts: ['حليب المراعي 2 لتر', 'زبادي قليل الدسم', 'عصير تروبيكانا'],
      misplacedProducts: ['شاي ربيع (يجب أن يكون في رف المشروبات)', 'صابون لوكس (في رف الأغذية)'],
      fillRate: 81.25,
    );
  }

  /// ألوان حالة التعرف
  static String getStatusLabel(RecognitionStatus status) {
    switch (status) {
      case RecognitionStatus.matched:
        return 'تم المطابقة';
      case RecognitionStatus.partialMatch:
        return 'مطابقة جزئية';
      case RecognitionStatus.unrecognized:
        return 'غير معروف';
      case RecognitionStatus.newProduct:
        return 'منتج جديد';
    }
  }
}
