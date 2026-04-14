import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// Top-level function identical to the one in sync_manager.dart — tests must
/// duplicate it because the original is library-private.
Map<String, dynamic> _decodeJsonPayload(String raw) =>
    jsonDecode(raw) as Map<String, dynamic>;

void main() {
  group('Sync Isolate — JSON offload via compute()', () {
    test('compute decodes small payload correctly', () async {
      final payload = jsonEncode({'id': 'sale-1', 'total': 100.0});
      final result = await compute(_decodeJsonPayload, payload);
      expect(result['id'], 'sale-1');
      expect(result['total'], 100.0);
    });

    test('compute decodes large payload (>50KB) without error', () async {
      // Build a payload larger than 50 KB
      final items = List.generate(
        500,
        (i) => {
          'id': 'item-$i',
          'product_name': 'Product $i with a reasonably long name for size',
          'qty': i * 1.5,
          'unit_price': 9.99 + i,
          'total': (9.99 + i) * (i * 1.5),
        },
      );
      final payload = jsonEncode({'sale_items': items});
      expect(payload.length, greaterThan(50 * 1024));

      final result = await compute(_decodeJsonPayload, payload);
      final decoded = result['sale_items'] as List;
      expect(decoded, hasLength(500));
      expect((decoded.first as Map)['id'], 'item-0');
    });

    test('benchmark: compute vs main thread for 1000 items', () async {
      final items = List.generate(
        1000,
        (i) => {
          'id': 'item-$i',
          'product_name': 'Product $i — description text to inflate size',
          'qty': i.toDouble(),
          'unit_price': 10.0 + i,
          'total': (10.0 + i) * i,
          'store_id': 'store-1',
          'notes': 'Some notes for item $i' * 5,
        },
      );
      final payload = jsonEncode({'items': items});
      final sizeKB = payload.length / 1024;

      // Time main-thread decode
      final swMain = Stopwatch()..start();
      jsonDecode(payload);
      swMain.stop();

      // Time compute decode
      final swIsolate = Stopwatch()..start();
      await compute(_decodeJsonPayload, payload);
      swIsolate.stop();

      // ignore: avoid_print
      print(
        'Payload: ${sizeKB.toStringAsFixed(0)} KB | '
        'Main thread: ${swMain.elapsedMilliseconds}ms | '
        'Isolate: ${swIsolate.elapsedMilliseconds}ms',
      );

      // Both should complete without error — that's the real assertion.
      // The isolate path may be slower for small payloads due to overhead,
      // but the main-thread blocking is what matters for UI jank.
      expect(swMain.elapsedMilliseconds, lessThan(5000));
      expect(swIsolate.elapsedMilliseconds, lessThan(5000));
    });
  });
}
