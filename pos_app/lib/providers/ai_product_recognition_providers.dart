/// مزودات التعرف على المنتجات - AI Product Recognition Providers
///
/// إدارة حالة المسح والنتائج وبيانات OCR
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ai_product_recognition_service.dart';

// ============================================================================
// PROVIDERS
// ============================================================================

/// مزود نتيجة التعرف
final recognitionResultProvider = StateNotifierProvider<RecognitionResultNotifier, AsyncValue<RecognitionResult?>>((ref) {
  return RecognitionResultNotifier();
});

/// مزود بيانات OCR
final ocrExtractionProvider = StateNotifierProvider<OcrExtractionNotifier, OcrExtraction?>((ref) {
  return OcrExtractionNotifier();
});

/// مزود نتيجة مسح الرف
final shelfScanProvider = StateNotifierProvider<ShelfScanNotifier, AsyncValue<ShelfScanResult?>>((ref) {
  return ShelfScanNotifier();
});

/// مزود وضع المسح
final scanModeProvider = StateProvider<ScanMode>((ref) => ScanMode.singleProduct);

/// مزود حالة الكاميرا
final cameraActiveProvider = StateProvider<bool>((ref) => false);

/// مزود المنتج المحدد من نتائج التعرف
final selectedRecognizedProductProvider = StateProvider<RecognizedProduct?>((ref) => null);

// ============================================================================
// NOTIFIERS
// ============================================================================

/// إدارة نتائج التعرف
class RecognitionResultNotifier extends StateNotifier<AsyncValue<RecognitionResult?>> {
  RecognitionResultNotifier() : super(const AsyncValue.data(null));

  Future<void> startScan() async {
    state = const AsyncValue.loading();
    // Simulate scanning delay
    await Future.delayed(const Duration(milliseconds: 1500));
    state = AsyncValue.data(AiProductRecognitionService.getMockRecognitionResult());
  }

  void acceptProduct(String productId) {
    final current = state.valueOrNull;
    if (current == null) return;
    // In production, this would update the database
    state = AsyncValue.data(current);
  }

  void rejectProduct(String productName) {
    final current = state.valueOrNull;
    if (current == null) return;
    final updated = current.products.where((p) => p.nameAr != productName).toList();
    state = AsyncValue.data(RecognitionResult(
      id: current.id,
      products: updated,
      scannedAt: current.scannedAt,
      sourceType: current.sourceType,
      totalDetected: current.totalDetected,
      totalMatched: updated.where((p) => p.status == RecognitionStatus.matched).length,
      avgConfidence: updated.isEmpty
          ? 0
          : updated.map((p) => p.confidence).reduce((a, b) => a + b) / updated.length,
    ));
  }

  void clear() {
    state = const AsyncValue.data(null);
  }
}

/// إدارة بيانات OCR
class OcrExtractionNotifier extends StateNotifier<OcrExtraction?> {
  OcrExtractionNotifier() : super(null);

  Future<void> extractFromImage() async {
    await Future.delayed(const Duration(milliseconds: 800));
    state = AiProductRecognitionService.getMockOcrExtraction();
  }

  void updateField(String field, String value) {
    if (state == null) return;
    switch (field) {
      case 'name':
        state = OcrExtraction(
          productName: value,
          barcode: state!.barcode,
          price: state!.price,
          expiryDate: state!.expiryDate,
          brand: state!.brand,
          weight: state!.weight,
          confidence: state!.confidence,
          rawText: state!.rawText,
        );
      case 'barcode':
        state = OcrExtraction(
          productName: state!.productName,
          barcode: value,
          price: state!.price,
          expiryDate: state!.expiryDate,
          brand: state!.brand,
          weight: state!.weight,
          confidence: state!.confidence,
          rawText: state!.rawText,
        );
      case 'price':
        state = OcrExtraction(
          productName: state!.productName,
          barcode: state!.barcode,
          price: double.tryParse(value),
          expiryDate: state!.expiryDate,
          brand: state!.brand,
          weight: state!.weight,
          confidence: state!.confidence,
          rawText: state!.rawText,
        );
      case 'expiry':
        state = OcrExtraction(
          productName: state!.productName,
          barcode: state!.barcode,
          price: state!.price,
          expiryDate: value,
          brand: state!.brand,
          weight: state!.weight,
          confidence: state!.confidence,
          rawText: state!.rawText,
        );
    }
  }

  void clear() {
    state = null;
  }
}

/// إدارة مسح الرف
class ShelfScanNotifier extends StateNotifier<AsyncValue<ShelfScanResult?>> {
  ShelfScanNotifier() : super(const AsyncValue.data(null));

  Future<void> startShelfScan() async {
    state = const AsyncValue.loading();
    await Future.delayed(const Duration(milliseconds: 2000));
    state = AsyncValue.data(AiProductRecognitionService.getMockShelfScan());
  }

  void clear() {
    state = const AsyncValue.data(null);
  }
}
