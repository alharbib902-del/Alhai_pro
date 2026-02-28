import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_ai/src/services/ai_product_recognition_service.dart';

void main() {
  group('RecognitionStatus', () {
    test('has all values', () {
      expect(RecognitionStatus.values.length, 4);
    });
  });

  group('ScanMode', () {
    test('has all values', () {
      expect(ScanMode.values.length, 4);
    });
  });

  group('getMockRecognitionResult', () {
    test('returns recognition result', () {
      final result = AiProductRecognitionService.getMockRecognitionResult();

      expect(result.id, isNotEmpty);
      expect(result.products, isNotEmpty);
      expect(result.totalDetected, greaterThan(0));
      expect(result.sourceType, isNotEmpty);
    });

    test('total detected matches products count', () {
      final result = AiProductRecognitionService.getMockRecognitionResult();
      expect(result.totalDetected, result.products.length);
    });

    test('total matched is less than or equal to total detected', () {
      final result = AiProductRecognitionService.getMockRecognitionResult();
      expect(result.totalMatched, lessThanOrEqualTo(result.totalDetected));
    });

    test('avg confidence is between 0 and 1', () {
      final result = AiProductRecognitionService.getMockRecognitionResult();
      expect(result.avgConfidence, greaterThan(0));
      expect(result.avgConfidence, lessThanOrEqualTo(1));
    });

    test('each product has required fields', () {
      final result = AiProductRecognitionService.getMockRecognitionResult();

      for (final p in result.products) {
        expect(p.name, isNotEmpty);
        expect(p.nameAr, isNotEmpty);
        expect(p.confidence, greaterThan(0));
        expect(p.confidence, lessThanOrEqualTo(1));
      }
    });

    test('bounding boxes have valid dimensions', () {
      final result = AiProductRecognitionService.getMockRecognitionResult();

      for (final p in result.products) {
        expect(p.boundingBox.x, greaterThanOrEqualTo(0));
        expect(p.boundingBox.y, greaterThanOrEqualTo(0));
        expect(p.boundingBox.width, greaterThan(0));
        expect(p.boundingBox.height, greaterThan(0));
      }
    });

    test('contains different recognition statuses', () {
      final result = AiProductRecognitionService.getMockRecognitionResult();
      final statuses = result.products.map((p) => p.status).toSet();
      expect(statuses.length, greaterThanOrEqualTo(2));
    });

    test('matched products have matchedId', () {
      final result = AiProductRecognitionService.getMockRecognitionResult();
      final matched = result.products
          .where((p) => p.status == RecognitionStatus.matched)
          .toList();

      for (final p in matched) {
        expect(p.matchedId, isNotNull);
        expect(p.matchedId, isNotEmpty);
      }
    });

    test('unrecognized products are marked as new', () {
      final result = AiProductRecognitionService.getMockRecognitionResult();
      final unrecognized = result.products
          .where((p) => p.status == RecognitionStatus.unrecognized)
          .toList();

      for (final p in unrecognized) {
        expect(p.isNewProduct, isTrue);
      }
    });
  });

  group('getMockOcrExtraction', () {
    test('returns OCR extraction', () {
      final ocr = AiProductRecognitionService.getMockOcrExtraction();

      expect(ocr.productName, isNotNull);
      expect(ocr.barcode, isNotNull);
      expect(ocr.price, isNotNull);
      expect(ocr.confidence, greaterThan(0));
      expect(ocr.rawText, isNotEmpty);
    });

    test('confidence is between 0 and 1', () {
      final ocr = AiProductRecognitionService.getMockOcrExtraction();
      expect(ocr.confidence, greaterThanOrEqualTo(0));
      expect(ocr.confidence, lessThanOrEqualTo(1));
    });

    test('has all optional fields populated', () {
      final ocr = AiProductRecognitionService.getMockOcrExtraction();
      expect(ocr.brand, isNotNull);
      expect(ocr.weight, isNotNull);
      expect(ocr.expiryDate, isNotNull);
    });
  });

  group('getMockShelfScan', () {
    test('returns shelf scan result', () {
      final scan = AiProductRecognitionService.getMockShelfScan();

      expect(scan.totalSlots, greaterThan(0));
      expect(scan.filledSlots, greaterThan(0));
      expect(scan.emptySlots, greaterThan(0));
    });

    test('filled plus empty equals total', () {
      final scan = AiProductRecognitionService.getMockShelfScan();
      expect(scan.filledSlots + scan.emptySlots, scan.totalSlots);
    });

    test('fill rate is consistent with slots', () {
      final scan = AiProductRecognitionService.getMockShelfScan();
      final expectedRate = scan.filledSlots / scan.totalSlots * 100;
      expect(scan.fillRate, closeTo(expectedRate, 0.1));
    });

    test('has out of stock products', () {
      final scan = AiProductRecognitionService.getMockShelfScan();
      expect(scan.outOfStockProducts, isNotEmpty);
    });

    test('has misplaced products', () {
      final scan = AiProductRecognitionService.getMockShelfScan();
      expect(scan.misplacedProducts, isNotEmpty);
    });
  });

  group('getStatusLabel', () {
    test('returns label for each status', () {
      for (final status in RecognitionStatus.values) {
        expect(
            AiProductRecognitionService.getStatusLabel(status), isNotEmpty);
      }
    });

    test('labels are unique', () {
      final labels = RecognitionStatus.values
          .map((s) => AiProductRecognitionService.getStatusLabel(s))
          .toSet();
      expect(labels.length, RecognitionStatus.values.length);
    });
  });
}
