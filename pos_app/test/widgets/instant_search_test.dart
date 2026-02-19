import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/widgets/pos/instant_search.dart';

void main() {
  group('InstantSearch Provider Tests', () {
    test('instantSearchQueryProvider يبدأ بقيمة فارغة', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final query = container.read(instantSearchQueryProvider);
      expect(query, '');
    });

    test('يمكن تحديث قيمة البحث', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(instantSearchQueryProvider.notifier).state = 'test';

      expect(container.read(instantSearchQueryProvider), 'test');
    });

    test('يمكن مسح قيمة البحث', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(instantSearchQueryProvider.notifier).state = 'بحث';
      expect(container.read(instantSearchQueryProvider), 'بحث');

      container.read(instantSearchQueryProvider.notifier).state = '';
      expect(container.read(instantSearchQueryProvider), '');
    });
  });

  group('Search Logic', () {
    group('filterProducts', () {
      final testProducts = [
        _TestProduct(id: '1', name: 'حليب طازج', barcode: '6281234567890'),
        _TestProduct(id: '2', name: 'خبز أبيض', barcode: '6281234567891'),
        _TestProduct(id: '3', name: 'زيت ذرة', barcode: '6281234567892'),
        _TestProduct(id: '4', name: 'أرز بسمتي', barcode: '6281234567893'),
        _TestProduct(id: '5', name: 'سكر أبيض', barcode: '6281234567894'),
      ];

      List<_TestProduct> filterProducts(
          List<_TestProduct> products, String query) {
        if (query.isEmpty) return products;

        final lowerQuery = query.toLowerCase();
        return products.where((p) {
          return p.name.toLowerCase().contains(lowerQuery) ||
              p.barcode.toLowerCase().contains(lowerQuery) ||
              p.id.toLowerCase().contains(lowerQuery);
        }).toList();
      }

      test('يُرجع كل المنتجات عندما يكون البحث فارغاً', () {
        final result = filterProducts(testProducts, '');
        expect(result.length, 5);
      });

      test('يبحث بالاسم العربي', () {
        final result = filterProducts(testProducts, 'حليب');
        expect(result.length, 1);
        expect(result.first.name, 'حليب طازج');
      });

      test('يبحث بالباركود', () {
        final result = filterProducts(testProducts, '6281234567891');
        expect(result.length, 1);
        expect(result.first.name, 'خبز أبيض');
      });

      test('يبحث بجزء من الباركود', () {
        final result = filterProducts(testProducts, '628123');
        expect(result.length, 5); // كلهم يبدأون بنفس الباركود
      });

      test('يبحث بالـ ID الفريد', () {
        // البحث بـ ID فريد (لا يتكرر في الباركود)
        final productsWithUniqueIds = [
          _TestProduct(id: 'PRD001', name: 'حليب طازج', barcode: '6281234567890'),
          _TestProduct(id: 'PRD002', name: 'خبز أبيض', barcode: '6281234567891'),
          _TestProduct(id: 'PRD003', name: 'زيت ذرة', barcode: '6281234567892'),
        ];
        final result = filterProducts(productsWithUniqueIds, 'PRD003');
        expect(result.length, 1);
        expect(result.first.name, 'زيت ذرة');
      });

      test('يُرجع قائمة فارغة إذا لم يجد نتائج', () {
        final result = filterProducts(testProducts, 'منتج غير موجود');
        expect(result, isEmpty);
      });

      test('البحث غير حساس لحالة الأحرف (case insensitive)', () {
        final productsWithEnglish = [
          _TestProduct(id: '1', name: 'Milk', barcode: '123'),
          _TestProduct(id: '2', name: 'milk', barcode: '456'),
          _TestProduct(id: '3', name: 'MILK', barcode: '789'),
        ];

        final result = filterProducts(productsWithEnglish, 'milk');
        expect(result.length, 3);
      });

      test('يبحث في كلمة "أبيض" ويجد منتجين', () {
        final result = filterProducts(testProducts, 'أبيض');
        expect(result.length, 2);
        expect(result.map((p) => p.name),
            containsAll(['خبز أبيض', 'سكر أبيض']));
      });
    });

    group('highlightText', () {
      test('يُرجع النص كما هو إذا كان البحث فارغاً', () {
        final result = _highlightText('حليب طازج', '');
        expect(result.spans.length, 1);
        expect(result.spans.first.text, 'حليب طازج');
        expect(result.spans.first.isHighlighted, false);
      });

      test('يُبرز الكلمة المطابقة', () {
        final result = _highlightText('حليب طازج', 'طازج');
        expect(result.spans.length, 3);
        expect(result.spans[0].text, 'حليب ');
        expect(result.spans[0].isHighlighted, false);
        expect(result.spans[1].text, 'طازج');
        expect(result.spans[1].isHighlighted, true);
        expect(result.spans[2].text, '');
      });

      test('يُرجع النص كما هو إذا لم تُوجد مطابقة', () {
        final result = _highlightText('حليب طازج', 'خبز');
        expect(result.spans.length, 1);
        expect(result.spans.first.text, 'حليب طازج');
      });

      test('يُبرز في بداية النص', () {
        final result = _highlightText('حليب طازج', 'حليب');
        expect(result.spans[0].text, '');
        expect(result.spans[1].text, 'حليب');
        expect(result.spans[1].isHighlighted, true);
        expect(result.spans[2].text, ' طازج');
      });
    });
  });
}

// Test helper class
class _TestProduct {
  final String id;
  final String name;
  final String barcode;

  _TestProduct({
    required this.id,
    required this.name,
    required this.barcode,
  });
}

// Highlight result for testing
class _HighlightResult {
  final List<_TextSpan> spans;
  _HighlightResult(this.spans);
}

class _TextSpan {
  final String text;
  final bool isHighlighted;
  _TextSpan(this.text, this.isHighlighted);
}

_HighlightResult _highlightText(String text, String highlight) {
  if (highlight.isEmpty) {
    return _HighlightResult([_TextSpan(text, false)]);
  }

  final lowerText = text.toLowerCase();
  final lowerHighlight = highlight.toLowerCase();
  final startIndex = lowerText.indexOf(lowerHighlight);

  if (startIndex == -1) {
    return _HighlightResult([_TextSpan(text, false)]);
  }

  final endIndex = startIndex + highlight.length;

  return _HighlightResult([
    _TextSpan(text.substring(0, startIndex), false),
    _TextSpan(text.substring(startIndex, endIndex), true),
    _TextSpan(text.substring(endIndex), false),
  ]);
}
