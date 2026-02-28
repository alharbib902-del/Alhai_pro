import 'dart:typed_data';

/// خدمة الذكاء الاصطناعي
/// تستخدم من: cashier, admin_pos
///
/// تحتاج: Google Cloud Vision API أو OpenAI API
class AIService {
  final String? _visionApiKey;
  final String? _openAiApiKey;

  AIService({
    String? visionApiKey,
    String? openAiApiKey,
  })  : _visionApiKey = visionApiKey,
        _openAiApiKey = openAiApiKey;

  /// التحقق من تكوين OCR
  bool get isOcrConfigured => _visionApiKey != null && _visionApiKey.isNotEmpty;

  /// التحقق من تكوين AI
  bool get isAiConfigured => _openAiApiKey != null && _openAiApiKey.isNotEmpty;

  // ==================== OCR - التعرف على النص ====================

  /// استخراج النص من صورة
  Future<OcrResult> extractText(Uint8List imageBytes) async {
    if (!isOcrConfigured) {
      return const OcrResult(
        success: false,
        error: 'خدمة OCR غير مكونة',
      );
    }

    try {
      // TODO: Implement Google Cloud Vision API call
      // POST https://vision.googleapis.com/v1/images:annotate

      await Future.delayed(const Duration(seconds: 1));

      return const OcrResult(
        success: true,
        text: 'نص مستخرج من الصورة',
        confidence: 0.95,
      );
    } catch (e) {
      return OcrResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// استخراج معلومات المنتج من صورة
  Future<ProductOcrResult> extractProductInfo(Uint8List imageBytes) async {
    if (!isOcrConfigured) {
      return const ProductOcrResult(
        success: false,
        error: 'خدمة OCR غير مكونة',
      );
    }

    try {
      // TODO: Implement OCR with product-specific parsing
      await Future.delayed(const Duration(seconds: 1));

      return const ProductOcrResult(
        success: true,
        productName: null,
        barcode: null,
        price: null,
      );
    } catch (e) {
      return ProductOcrResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// استخراج الباركود من بيانات نصية (صورة مرمزة أو بيانات خام)
  /// Uses regex-based pattern detection to find barcode-like sequences
  /// in raw byte data. For actual image-based barcode scanning, use
  /// Google Cloud Vision API or a dedicated barcode scanning package.
  Future<BarcodeOcrResult> extractBarcode(Uint8List imageBytes) async {
    try {
      // Convert image bytes to string representation for pattern matching.
      // This works on text-encoded data (e.g., base64-decoded barcode images
      // that contain embedded text, or raw text streams).
      final textContent = String.fromCharCodes(imageBytes);

      final barcodes = <String>[];

      // EAN-13: exactly 13 digits (most common retail barcode worldwide)
      // Includes GTIN-13 used in Saudi Arabia (beginning with 628)
      final ean13Pattern = RegExp(r'(?<!\d)(\d{13})(?!\d)');
      for (final match in ean13Pattern.allMatches(textContent)) {
        final code = match.group(1)!;
        if (_isValidEan13(code)) {
          barcodes.add(code);
        }
      }

      // EAN-8: exactly 8 digits
      final ean8Pattern = RegExp(r'(?<!\d)(\d{8})(?!\d)');
      for (final match in ean8Pattern.allMatches(textContent)) {
        final code = match.group(1)!;
        // Skip if already matched as part of EAN-13
        if (!barcodes.any((b) => b.contains(code)) && _isValidEan8(code)) {
          barcodes.add(code);
        }
      }

      // UPC-A: exactly 12 digits
      final upcAPattern = RegExp(r'(?<!\d)(\d{12})(?!\d)');
      for (final match in upcAPattern.allMatches(textContent)) {
        final code = match.group(1)!;
        if (!barcodes.any((b) => b.contains(code)) && _isValidUpcA(code)) {
          barcodes.add(code);
        }
      }

      // Code 128 / Code 39: alphanumeric sequences between common delimiters
      // Code 39 uses start/stop character '*'
      final code39Pattern = RegExp(r'\*([A-Z0-9\-\. \$/+%]+)\*');
      for (final match in code39Pattern.allMatches(textContent)) {
        final code = match.group(1)!;
        if (code.length >= 3) {
          barcodes.add(code);
        }
      }

      // ISBN patterns (ISBN-13 starting with 978 or 979)
      final isbnPattern = RegExp(r'ISBN[:\s-]*((?:978|979)[\d-]{10,})');
      for (final match in isbnPattern.allMatches(textContent)) {
        final rawIsbn = match.group(1)!.replaceAll('-', '');
        if (rawIsbn.length == 13 && _isValidEan13(rawIsbn)) {
          barcodes.add(rawIsbn);
        }
      }

      return BarcodeOcrResult(
        success: true,
        barcodes: barcodes.toSet().toList(), // deduplicate
      );
    } catch (e) {
      return BarcodeOcrResult(
        success: false,
        error: 'فشل استخراج الباركود: $e',
      );
    }
  }

  // ==================== التوقعات ====================

  /// توقع المبيعات
  Future<SalesPredictionResult> predictSales({
    required String storeId,
    required int daysAhead,
    List<Map<String, dynamic>>? historicalData,
  }) async {
    if (!isAiConfigured) {
      return const SalesPredictionResult(
        success: false,
        error: 'خدمة AI غير مكونة',
      );
    }

    try {
      // TODO: Implement sales prediction using AI
      await Future.delayed(const Duration(seconds: 1));

      return SalesPredictionResult(
        success: true,
        predictions: List.generate(daysAhead, (i) {
          final date = DateTime.now().add(Duration(days: i + 1));
          return SalesPrediction(
            date: date,
            predictedSales: 1000 + (i * 100),
            confidence: 0.85 - (i * 0.05),
          );
        }),
      );
    } catch (e) {
      return SalesPredictionResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// توقع المخزون المطلوب
  Future<InventoryPredictionResult> predictInventoryNeeds({
    required String storeId,
    required String productId,
    required int daysAhead,
  }) async {
    if (!isAiConfigured) {
      return const InventoryPredictionResult(
        success: false,
        error: 'خدمة AI غير مكونة',
      );
    }

    try {
      // TODO: Implement inventory prediction
      await Future.delayed(const Duration(seconds: 1));

      return InventoryPredictionResult(
        success: true,
        productId: productId,
        predictedDemand: 50,
        recommendedReorderQty: 100,
        confidence: 0.8,
      );
    } catch (e) {
      return InventoryPredictionResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  // ==================== التوصيات ====================

  /// توصيات المنتجات للعميل
  Future<ProductRecommendationsResult> getProductRecommendations({
    required String customerId,
    int limit = 10,
  }) async {
    if (!isAiConfigured) {
      return const ProductRecommendationsResult(
        success: false,
        error: 'خدمة AI غير مكونة',
      );
    }

    try {
      // TODO: Implement product recommendations
      await Future.delayed(const Duration(seconds: 1));

      return const ProductRecommendationsResult(
        success: true,
        recommendations: [],
      );
    } catch (e) {
      return ProductRecommendationsResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// تحليل ملاحظات العملاء باستخدام تحليل مشاعر قائم على الكلمات المفتاحية
  /// Performs keyword-based sentiment analysis for Arabic and English text.
  /// Scores range from -1.0 (very negative) to +1.0 (very positive).
  /// For production-grade NLP, integrate with OpenAI or Google NLP APIs.
  Future<SentimentResult> analyzeSentiment(String text) async {
    try {
      if (text.trim().isEmpty) {
        return const SentimentResult(
          success: false,
          error: 'النص فارغ',
        );
      }

      final lowerText = text.toLowerCase();
      double score = 0.0;
      int matchCount = 0;

      // Score positive keywords
      for (final entry in _positiveKeywords.entries) {
        if (lowerText.contains(entry.key)) {
          score += entry.value;
          matchCount++;
        }
      }

      // Score negative keywords
      for (final entry in _negativeKeywords.entries) {
        if (lowerText.contains(entry.key)) {
          score += entry.value; // values are already negative
          matchCount++;
        }
      }

      // Check for negation patterns that flip sentiment
      for (final negator in _negationPatterns) {
        if (lowerText.contains(negator)) {
          // Negation flips the polarity partially
          score *= -0.5;
          break; // Only apply once
        }
      }

      // Check for intensifiers
      for (final intensifier in _intensifiers) {
        if (lowerText.contains(intensifier)) {
          score *= 1.5;
          break;
        }
      }

      // Normalize score to [-1.0, 1.0] range
      if (matchCount > 0) {
        score = score / matchCount;
      }
      score = score.clamp(-1.0, 1.0);

      // Determine sentiment category
      final Sentiment sentiment;
      if (score > 0.15) {
        sentiment = Sentiment.positive;
      } else if (score < -0.15) {
        sentiment = Sentiment.negative;
      } else {
        sentiment = Sentiment.neutral;
      }

      // Calculate confidence based on how many keywords matched
      final confidence = matchCount > 0
          ? (matchCount / (matchCount + 2)).clamp(0.3, 0.95)
          : 0.3; // Low confidence when no keywords matched

      return SentimentResult(
        success: true,
        sentiment: sentiment,
        score: (score + 1.0) / 2.0, // Convert to 0.0-1.0 scale for compatibility
        confidence: confidence,
        matchedKeywords: matchCount,
      );
    } catch (e) {
      return SentimentResult(
        success: false,
        error: 'فشل تحليل المشاعر: $e',
      );
    }
  }

  // ==================== Barcode validation helpers ====================

  /// Validates EAN-13 check digit
  bool _isValidEan13(String code) {
    if (code.length != 13) return false;
    if (!RegExp(r'^\d{13}$').hasMatch(code)) return false;

    int sum = 0;
    for (int i = 0; i < 12; i++) {
      final digit = int.parse(code[i]);
      sum += (i % 2 == 0) ? digit : digit * 3;
    }
    final checkDigit = (10 - (sum % 10)) % 10;
    return checkDigit == int.parse(code[12]);
  }

  /// Validates EAN-8 check digit
  bool _isValidEan8(String code) {
    if (code.length != 8) return false;
    if (!RegExp(r'^\d{8}$').hasMatch(code)) return false;

    int sum = 0;
    for (int i = 0; i < 7; i++) {
      final digit = int.parse(code[i]);
      sum += (i % 2 == 0) ? digit * 3 : digit;
    }
    final checkDigit = (10 - (sum % 10)) % 10;
    return checkDigit == int.parse(code[7]);
  }

  /// Validates UPC-A check digit
  bool _isValidUpcA(String code) {
    if (code.length != 12) return false;
    if (!RegExp(r'^\d{12}$').hasMatch(code)) return false;

    int sum = 0;
    for (int i = 0; i < 11; i++) {
      final digit = int.parse(code[i]);
      sum += (i % 2 == 0) ? digit * 3 : digit;
    }
    final checkDigit = (10 - (sum % 10)) % 10;
    return checkDigit == int.parse(code[11]);
  }

  // ==================== Sentiment keyword dictionaries ====================

  /// Positive keywords with weight scores (Arabic + English)
  static const Map<String, double> _positiveKeywords = {
    // Arabic positive words
    'ممتاز': 0.9,
    'رائع': 0.85,
    'جيد': 0.6,
    'حلو': 0.5,
    'سريع': 0.5,
    'نظيف': 0.5,
    'شكرا': 0.4,
    'شكراً': 0.4,
    'أحسنت': 0.7,
    'مبدع': 0.8,
    'محترم': 0.6,
    'منظم': 0.5,
    'مرتب': 0.5,
    'أفضل': 0.7,
    'عظيم': 0.85,
    'جميل': 0.7,
    'سعيد': 0.6,
    'راضي': 0.7,
    'مريح': 0.5,
    'مفيد': 0.6,
    'مذهل': 0.9,
    'احترافي': 0.7,
    'موصى': 0.6,
    'أنصح': 0.6,
    'يستاهل': 0.7,
    'الله يعطيك العافية': 0.6,
    'ما شاء الله': 0.7,
    'تبارك الله': 0.7,
    // English positive words
    'excellent': 0.9,
    'great': 0.8,
    'good': 0.6,
    'amazing': 0.9,
    'wonderful': 0.85,
    'fantastic': 0.9,
    'love': 0.7,
    'best': 0.8,
    'perfect': 0.95,
    'happy': 0.6,
    'satisfied': 0.7,
    'recommend': 0.6,
    'fast': 0.5,
    'clean': 0.5,
    'friendly': 0.6,
    'professional': 0.7,
    'helpful': 0.6,
    'thank': 0.4,
    'awesome': 0.85,
    'outstanding': 0.9,
  };

  /// Negative keywords with weight scores (Arabic + English)
  static const Map<String, double> _negativeKeywords = {
    // Arabic negative words
    'سيء': -0.8,
    'سيئ': -0.8,
    'بطيء': -0.6,
    'غالي': -0.5,
    'وسخ': -0.7,
    'قذر': -0.7,
    'زفت': -0.9,
    'فاشل': -0.85,
    'مقرف': -0.85,
    'سرقة': -0.9,
    'نصب': -0.9,
    'غش': -0.9,
    'كذب': -0.8,
    'ضعيف': -0.6,
    'متأخر': -0.5,
    'خراب': -0.7,
    'عيب': -0.6,
    'مكسور': -0.6,
    'تالف': -0.7,
    'منتهي': -0.6,
    'خرب': -0.7,
    'ما ينفع': -0.6,
    'ما يصلح': -0.6,
    'بايخ': -0.6,
    'حرام': -0.5,
    'ظلم': -0.8,
    'إهمال': -0.7,
    // English negative words
    'bad': -0.7,
    'terrible': -0.9,
    'horrible': -0.9,
    'awful': -0.85,
    'worst': -0.95,
    'hate': -0.8,
    'poor': -0.6,
    'slow': -0.5,
    'expensive': -0.5,
    'dirty': -0.7,
    'rude': -0.7,
    'broken': -0.6,
    'damaged': -0.7,
    'expired': -0.6,
    'disappointed': -0.7,
    'disgusting': -0.85,
    'scam': -0.9,
    'fraud': -0.9,
    'waste': -0.7,
    'never again': -0.8,
    'unacceptable': -0.8,
  };

  /// Negation patterns that can flip sentiment
  static const List<String> _negationPatterns = [
    // Arabic
    'ليس', 'لا', 'مو', 'ما كان', 'غير', 'بدون', 'مش',
    // English
    'not', "n't", 'no', 'never', 'neither', 'without',
  ];

  /// Intensifier words that amplify sentiment
  static const List<String> _intensifiers = [
    // Arabic
    'جداً', 'جدا', 'كثير', 'أبداً', 'للغاية', 'بشدة', 'تماماً',
    // English
    'very', 'extremely', 'absolutely', 'totally', 'completely', 'really',
  ];
}

// ==================== نتائج OCR ====================

/// نتيجة استخراج النص
class OcrResult {
  final bool success;
  final String? text;
  final double? confidence;
  final String? error;

  const OcrResult({
    required this.success,
    this.text,
    this.confidence,
    this.error,
  });
}

/// نتيجة استخراج معلومات المنتج
class ProductOcrResult {
  final bool success;
  final String? productName;
  final String? barcode;
  final double? price;
  final String? error;

  const ProductOcrResult({
    required this.success,
    this.productName,
    this.barcode,
    this.price,
    this.error,
  });
}

/// نتيجة استخراج الباركود
class BarcodeOcrResult {
  final bool success;
  final List<String>? barcodes;
  final String? error;

  const BarcodeOcrResult({
    required this.success,
    this.barcodes,
    this.error,
  });
}

// ==================== نتائج التوقعات ====================

/// نتيجة توقع المبيعات
class SalesPredictionResult {
  final bool success;
  final List<SalesPrediction>? predictions;
  final String? error;

  const SalesPredictionResult({
    required this.success,
    this.predictions,
    this.error,
  });
}

/// توقع مبيعات يوم واحد
class SalesPrediction {
  final DateTime date;
  final double predictedSales;
  final double confidence;

  const SalesPrediction({
    required this.date,
    required this.predictedSales,
    required this.confidence,
  });
}

/// نتيجة توقع المخزون
class InventoryPredictionResult {
  final bool success;
  final String? productId;
  final int? predictedDemand;
  final int? recommendedReorderQty;
  final double? confidence;
  final String? error;

  const InventoryPredictionResult({
    required this.success,
    this.productId,
    this.predictedDemand,
    this.recommendedReorderQty,
    this.confidence,
    this.error,
  });
}

// ==================== نتائج التوصيات ====================

/// نتيجة توصيات المنتجات
class ProductRecommendationsResult {
  final bool success;
  final List<ProductRecommendation>? recommendations;
  final String? error;

  const ProductRecommendationsResult({
    required this.success,
    this.recommendations,
    this.error,
  });
}

/// توصية منتج
class ProductRecommendation {
  final String productId;
  final String productName;
  final double score;
  final String reason;

  const ProductRecommendation({
    required this.productId,
    required this.productName,
    required this.score,
    required this.reason,
  });
}

/// نتيجة تحليل المشاعر
class SentimentResult {
  final bool success;
  final Sentiment? sentiment;
  final double? score;
  final double? confidence;
  final int? matchedKeywords;
  final String? error;

  const SentimentResult({
    required this.success,
    this.sentiment,
    this.score,
    this.confidence,
    this.matchedKeywords,
    this.error,
  });
}

/// أنواع المشاعر
enum Sentiment { positive, neutral, negative }
