import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_core/src/repositories/activity_logs_repository.dart';

/// Tests for ActivitySummary helper class defined in activity_logs_repository.dart.
/// ActivityLogsRepository is an abstract interface - no implementation to test yet.
void main() {
  group('ActivitySummary', () {
    test('should construct with all required fields', () {
      final summary = ActivitySummary(
        action: 'create_order',
        count: 50,
        lastOccurrence: DateTime(2026, 1, 15, 14, 30),
      );

      expect(summary.action, equals('create_order'));
      expect(summary.count, equals(50));
      expect(summary.lastOccurrence, equals(DateTime(2026, 1, 15, 14, 30)));
    });

    test('should handle single occurrence', () {
      final summary = ActivitySummary(
        action: 'login',
        count: 1,
        lastOccurrence: DateTime(2026, 1, 15),
      );

      expect(summary.count, equals(1));
    });

    test('should handle different action types', () {
      final actions = [
        'login',
        'logout',
        'create_order',
        'refund',
        'open_shift'
      ];

      for (final action in actions) {
        final summary = ActivitySummary(
          action: action,
          count: 10,
          lastOccurrence: DateTime(2026, 1, 15),
        );
        expect(summary.action, equals(action));
      }
    });
  });
}
