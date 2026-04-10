import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_ai/src/providers/ai_product_recognition_providers.dart';
import 'package:alhai_ai/src/services/ai_product_recognition_service.dart';

void main() {
  group('scanModeProvider', () {
    test('initial value is singleProduct', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(
        container.read(scanModeProvider),
        ScanMode.singleProduct,
      );
    });

    test('can be updated to shelf', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(scanModeProvider.notifier).state = ScanMode.shelfScan;
      expect(container.read(scanModeProvider), ScanMode.shelfScan);
    });
  });

  group('cameraActiveProvider', () {
    test('initial value is false', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(cameraActiveProvider), isFalse);
    });

    test('can be updated to true', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(cameraActiveProvider.notifier).state = true;
      expect(container.read(cameraActiveProvider), isTrue);
    });
  });

  group('selectedRecognizedProductProvider', () {
    test('initial value is null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(selectedRecognizedProductProvider), isNull);
    });
  });

  group('RecognitionResultNotifier', () {
    test('initial state is data null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final result = container.read(recognitionResultProvider);
      expect(result.valueOrNull, isNull);
    });

    test('clear sets state to data null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(recognitionResultProvider.notifier).clear();
      final result = container.read(recognitionResultProvider);
      expect(result.valueOrNull, isNull);
    });
  });

  group('OcrExtractionNotifier', () {
    test('initial state is null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(ocrExtractionProvider), isNull);
    });

    test('clear sets state to null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(ocrExtractionProvider.notifier).clear();
      expect(container.read(ocrExtractionProvider), isNull);
    });
  });

  group('ShelfScanNotifier', () {
    test('initial state is data null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final result = container.read(shelfScanProvider);
      expect(result.valueOrNull, isNull);
    });

    test('clear sets state to data null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(shelfScanProvider.notifier).clear();
      final result = container.read(shelfScanProvider);
      expect(result.valueOrNull, isNull);
    });
  });
}
