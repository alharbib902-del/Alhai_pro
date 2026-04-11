import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_ai/src/providers/ai_staff_analytics_providers.dart';
import 'package:alhai_ai/src/services/ai_staff_analytics_service.dart';

void main() {
  group('selectedStaffProvider', () {
    test('initial value is null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(selectedStaffProvider), isNull);
    });

    test('can be updated to a staff id', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(selectedStaffProvider.notifier).state = 'staff-123';
      expect(container.read(selectedStaffProvider), 'staff-123');
    });

    test('can be cleared back to null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(selectedStaffProvider.notifier).state = 'staff-123';
      container.read(selectedStaffProvider.notifier).state = null;
      expect(container.read(selectedStaffProvider), isNull);
    });
  });

  group('staffPeriodFilterProvider', () {
    test('initial value is thisWeek', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(staffPeriodFilterProvider), StaffPeriod.thisWeek);
    });

    test('can be updated to today', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(staffPeriodFilterProvider.notifier).state =
          StaffPeriod.today;
      expect(container.read(staffPeriodFilterProvider), StaffPeriod.today);
    });

    test('can be updated to thisMonth', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(staffPeriodFilterProvider.notifier).state =
          StaffPeriod.thisMonth;
      expect(container.read(staffPeriodFilterProvider), StaffPeriod.thisMonth);
    });
  });

  group('StaffPeriod', () {
    test('has all expected values', () {
      expect(StaffPeriod.values.length, 4);
      expect(StaffPeriod.values, contains(StaffPeriod.today));
      expect(StaffPeriod.values, contains(StaffPeriod.thisWeek));
      expect(StaffPeriod.values, contains(StaffPeriod.thisMonth));
      expect(StaffPeriod.values, contains(StaffPeriod.lastMonth));
    });
  });

  group('staffRankingsProvider', () {
    test('returns rankings list', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final rankings = container.read(staffRankingsProvider);
      expect(rankings, isA<List<StaffRanking>>());
      expect(rankings, isNotEmpty);
    });
  });

  group('shiftHeatmapProvider', () {
    test('returns heatmap data', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final heatmap = container.read(shiftHeatmapProvider);
      expect(heatmap, isA<ShiftHeatmapData>());
    });
  });

  group('teamSummaryProvider', () {
    test('returns team summary', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final summary = container.read(teamSummaryProvider);
      expect(summary, isA<TeamPerformanceSummary>());
    });
  });

  group('shiftOptimizationsProvider', () {
    test('returns optimization suggestions', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final optimizations = container.read(shiftOptimizationsProvider);
      expect(optimizations, isA<List<ShiftOptimization>>());
    });
  });
}
