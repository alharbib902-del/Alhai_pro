import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_ai/src/services/ai_staff_analytics_service.dart';

void main() {
  group('getStaffPerformance', () {
    test('returns staff performance data', () {
      final staff = AiStaffAnalyticsService.getStaffPerformance();
      expect(staff, isNotEmpty);
      expect(staff.length, 5);
    });

    test('each staff has required fields', () {
      final staff = AiStaffAnalyticsService.getStaffPerformance();

      for (final s in staff) {
        expect(s.cashierId, isNotEmpty);
        expect(s.name, isNotEmpty);
        expect(s.nameAr, isNotEmpty);
        expect(s.role, isNotEmpty);
        expect(s.avatarInitial, isNotEmpty);
      }
    });

    test('scores are within 0-100 range', () {
      final staff = AiStaffAnalyticsService.getStaffPerformance();

      for (final s in staff) {
        expect(s.score, greaterThanOrEqualTo(0));
        expect(s.score, lessThanOrEqualTo(100));
      }
    });

    test('void rate is within reasonable range', () {
      final staff = AiStaffAnalyticsService.getStaffPerformance();

      for (final s in staff) {
        expect(s.voidRate, greaterThanOrEqualTo(0));
        expect(s.voidRate, lessThan(10));
      }
    });

    test('customer satisfaction is within 0-5 range', () {
      final staff = AiStaffAnalyticsService.getStaffPerformance();

      for (final s in staff) {
        expect(s.customerSatisfaction, greaterThanOrEqualTo(0));
        expect(s.customerSatisfaction, lessThanOrEqualTo(5));
      }
    });

    test('attendance rate is within 0-100 range', () {
      final staff = AiStaffAnalyticsService.getStaffPerformance();

      for (final s in staff) {
        expect(s.attendanceRate, greaterThanOrEqualTo(0));
        expect(s.attendanceRate, lessThanOrEqualTo(100));
      }
    });

    test('weekly scores have 7 entries', () {
      final staff = AiStaffAnalyticsService.getStaffPerformance();

      for (final s in staff) {
        expect(s.weeklyScores.length, 7);
      }
    });

    test('staff have unique IDs', () {
      final staff = AiStaffAnalyticsService.getStaffPerformance();
      final ids = staff.map((s) => s.cashierId).toSet();
      expect(ids.length, staff.length);
    });
  });

  group('getStaffRankings', () {
    test('returns rankings', () {
      final rankings = AiStaffAnalyticsService.getStaffRankings();
      expect(rankings, isNotEmpty);
      expect(rankings.length, 5);
    });

    test('rankings are sorted by score descending', () {
      final rankings = AiStaffAnalyticsService.getStaffRankings();

      for (int i = 0; i < rankings.length - 1; i++) {
        expect(rankings[i].score, greaterThanOrEqualTo(rankings[i + 1].score));
      }
    });

    test('ranks are sequential starting from 1', () {
      final rankings = AiStaffAnalyticsService.getStaffRankings();

      for (int i = 0; i < rankings.length; i++) {
        expect(rankings[i].rank, i + 1);
      }
    });

    test('each ranking has a badge', () {
      final rankings = AiStaffAnalyticsService.getStaffRankings();

      for (final r in rankings) {
        expect(r.badge, isNotEmpty);
        expect(r.nameAr, isNotEmpty);
      }
    });
  });

  group('getShiftHeatmap', () {
    test('returns heatmap data', () {
      final heatmap = AiStaffAnalyticsService.getShiftHeatmap();

      expect(heatmap.days, isNotEmpty);
      expect(heatmap.days.length, 7);
      expect(heatmap.hours, isNotEmpty);
      expect(heatmap.hours.length, 14);
    });

    test('intensity grid has correct dimensions', () {
      final heatmap = AiStaffAnalyticsService.getShiftHeatmap();

      expect(heatmap.intensity.length, 7);
      for (final row in heatmap.intensity) {
        expect(row.length, 14);
      }
    });

    test('intensity values are between 0 and 1', () {
      final heatmap = AiStaffAnalyticsService.getShiftHeatmap();

      for (final row in heatmap.intensity) {
        for (final value in row) {
          expect(value, greaterThanOrEqualTo(0));
          expect(value, lessThanOrEqualTo(1));
        }
      }
    });

    test('hours start at 7 AM', () {
      final heatmap = AiStaffAnalyticsService.getShiftHeatmap();
      expect(heatmap.hours.first, 7);
    });
  });

  group('getShiftOptimizations', () {
    test('returns shift optimizations', () {
      final optimizations = AiStaffAnalyticsService.getShiftOptimizations();
      expect(optimizations, isNotEmpty);
      expect(optimizations.length, 2);
    });

    test('each optimization has required fields', () {
      final optimizations = AiStaffAnalyticsService.getShiftOptimizations();

      for (final o in optimizations) {
        expect(o.day, isNotEmpty);
        expect(o.dayAr, isNotEmpty);
        expect(o.suggestion, isNotEmpty);
        expect(o.hourlyNeeds, isNotEmpty);
      }
    });

    test('suggested staff is greater than or equal to current', () {
      final optimizations = AiStaffAnalyticsService.getShiftOptimizations();

      for (final o in optimizations) {
        expect(o.suggestedStaff, greaterThanOrEqualTo(o.currentStaff));
      }
    });

    test('hourly needs have valid traffic intensity', () {
      final optimizations = AiStaffAnalyticsService.getShiftOptimizations();

      for (final o in optimizations) {
        for (final need in o.hourlyNeeds) {
          expect(need.trafficIntensity, greaterThan(0));
          expect(need.trafficIntensity, lessThanOrEqualTo(1));
        }
      }
    });
  });

  group('getTeamSummary', () {
    test('returns team summary', () {
      final summary = AiStaffAnalyticsService.getTeamSummary();

      expect(summary.avgScore, greaterThan(0));
      expect(summary.totalSales, greaterThan(0));
      expect(summary.totalTransactions, greaterThan(0));
      expect(summary.avgVoidRate, greaterThanOrEqualTo(0));
      expect(summary.topPerformer, isNotEmpty);
      expect(summary.teamGrowth, isNotNull);
    });

    test('avg score is consistent with individual scores', () {
      final staff = AiStaffAnalyticsService.getStaffPerformance();
      final summary = AiStaffAnalyticsService.getTeamSummary();

      final expectedAvg =
          staff.map((s) => s.score).reduce((a, b) => a + b) / staff.length;
      expect(summary.avgScore, closeTo(expectedAvg, 0.1));
    });

    test('total sales is sum of individual sales', () {
      final staff = AiStaffAnalyticsService.getStaffPerformance();
      final summary = AiStaffAnalyticsService.getTeamSummary();

      final expectedTotal =
          staff.map((s) => s.salesVolume).reduce((a, b) => a + b);
      expect(summary.totalSales, expectedTotal);
    });

    test('top performer is the highest scored staff member', () {
      final staff = AiStaffAnalyticsService.getStaffPerformance();
      final summary = AiStaffAnalyticsService.getTeamSummary();

      final top = staff.reduce((a, b) => a.score > b.score ? a : b);
      expect(summary.topPerformer, top.nameAr);
    });
  });
}
