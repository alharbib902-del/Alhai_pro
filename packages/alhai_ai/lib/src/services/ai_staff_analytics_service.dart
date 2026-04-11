/// خدمة تحليلات الموظفين - AI Staff Analytics Service
///
/// تحليل أداء الموظفين واقتراحات جدولة الورديات
/// - مقاييس الأداء لكل موظف
/// - ترتيب الموظفين
/// - تحسين الورديات
library;

import 'dart:math';

// ============================================================================
// MODELS
// ============================================================================

/// أداء الموظف
class StaffPerformance {
  final String cashierId;
  final String name;
  final String nameAr;
  final String role;
  final double score;
  final double salesVolume;
  final double avgTicket;
  final double transactionsPerHour;
  final double voidRate;
  final List<int> peakHours;
  final int totalTransactions;
  final double customerSatisfaction;
  final double attendanceRate;
  final List<double> weeklyScores;
  final String avatarInitial;

  const StaffPerformance({
    required this.cashierId,
    required this.name,
    required this.nameAr,
    required this.role,
    required this.score,
    required this.salesVolume,
    required this.avgTicket,
    required this.transactionsPerHour,
    required this.voidRate,
    required this.peakHours,
    required this.totalTransactions,
    required this.customerSatisfaction,
    required this.attendanceRate,
    required this.weeklyScores,
    required this.avatarInitial,
  });
}

/// تحسين الوردية
class ShiftOptimization {
  final String day;
  final String dayAr;
  final List<HourlyStaffNeed> hourlyNeeds;
  final int currentStaff;
  final int suggestedStaff;
  final String suggestion;

  const ShiftOptimization({
    required this.day,
    required this.dayAr,
    required this.hourlyNeeds,
    required this.currentStaff,
    required this.suggestedStaff,
    required this.suggestion,
  });
}

/// حاجة الموظفين بالساعة
class HourlyStaffNeed {
  final int hour;
  final double trafficIntensity;
  final int currentStaff;
  final int suggestedStaff;

  const HourlyStaffNeed({
    required this.hour,
    required this.trafficIntensity,
    required this.currentStaff,
    required this.suggestedStaff,
  });
}

/// ترتيب الموظفين
class StaffRanking {
  final String cashierId;
  final String nameAr;
  final int rank;
  final double score;
  final double changeFromLastWeek;
  final String badge;

  const StaffRanking({
    required this.cashierId,
    required this.nameAr,
    required this.rank,
    required this.score,
    required this.changeFromLastWeek,
    required this.badge,
  });
}

/// خريطة حرارية للورديات
class ShiftHeatmapData {
  final List<String> days;
  final List<int> hours;
  final List<List<double>> intensity;

  const ShiftHeatmapData({
    required this.days,
    required this.hours,
    required this.intensity,
  });
}

/// ملخص أداء الفريق
class TeamPerformanceSummary {
  final double avgScore;
  final double totalSales;
  final int totalTransactions;
  final double avgVoidRate;
  final String topPerformer;
  final double teamGrowth;

  const TeamPerformanceSummary({
    required this.avgScore,
    required this.totalSales,
    required this.totalTransactions,
    required this.avgVoidRate,
    required this.topPerformer,
    required this.teamGrowth,
  });
}

// ============================================================================
// SERVICE
// ============================================================================

/// خدمة تحليلات الموظفين
class AiStaffAnalyticsService {
  static final _random = Random(42);

  /// بيانات أداء الموظفين الوهمية
  static List<StaffPerformance> getStaffPerformance() {
    return [
      const StaffPerformance(
        cashierId: 'emp_001',
        name: 'Ahmed Al-Rashid',
        nameAr: 'أحمد الراشد',
        role: 'كاشير أول',
        score: 92.5,
        salesVolume: 45200,
        avgTicket: 85.50,
        transactionsPerHour: 18.5,
        voidRate: 1.2,
        peakHours: [10, 11, 12, 13],
        totalTransactions: 528,
        customerSatisfaction: 4.8,
        attendanceRate: 98.5,
        weeklyScores: [88, 90, 91, 93, 92, 94, 92.5],
        avatarInitial: 'أ',
      ),
      const StaffPerformance(
        cashierId: 'emp_002',
        name: 'Fatima Al-Zahrani',
        nameAr: 'فاطمة الزهراني',
        role: 'كاشير',
        score: 88.0,
        salesVolume: 38500,
        avgTicket: 72.30,
        transactionsPerHour: 16.2,
        voidRate: 1.8,
        peakHours: [14, 15, 16, 17],
        totalTransactions: 465,
        customerSatisfaction: 4.6,
        attendanceRate: 96.0,
        weeklyScores: [85, 86, 87, 88, 87, 89, 88],
        avatarInitial: 'ف',
      ),
      const StaffPerformance(
        cashierId: 'emp_003',
        name: 'Mohammad Al-Ghamdi',
        nameAr: 'محمد الغامدي',
        role: 'كاشير',
        score: 85.5,
        salesVolume: 35800,
        avgTicket: 68.90,
        transactionsPerHour: 15.0,
        voidRate: 2.1,
        peakHours: [9, 10, 11],
        totalTransactions: 412,
        customerSatisfaction: 4.5,
        attendanceRate: 94.5,
        weeklyScores: [82, 84, 85, 86, 84, 87, 85.5],
        avatarInitial: 'م',
      ),
      const StaffPerformance(
        cashierId: 'emp_004',
        name: 'Noura Al-Otaibi',
        nameAr: 'نورة العتيبي',
        role: 'مشرف ورديات',
        score: 95.0,
        salesVolume: 52300,
        avgTicket: 92.10,
        transactionsPerHour: 20.0,
        voidRate: 0.8,
        peakHours: [11, 12, 13, 14, 15],
        totalTransactions: 580,
        customerSatisfaction: 4.9,
        attendanceRate: 99.0,
        weeklyScores: [93, 94, 94, 95, 95, 96, 95],
        avatarInitial: 'ن',
      ),
      const StaffPerformance(
        cashierId: 'emp_005',
        name: 'Khalid Al-Mutairi',
        nameAr: 'خالد المطيري',
        role: 'كاشير',
        score: 78.0,
        salesVolume: 28900,
        avgTicket: 55.20,
        transactionsPerHour: 12.5,
        voidRate: 3.5,
        peakHours: [16, 17, 18, 19],
        totalTransactions: 348,
        customerSatisfaction: 4.2,
        attendanceRate: 91.0,
        weeklyScores: [75, 76, 77, 78, 77, 79, 78],
        avatarInitial: 'خ',
      ),
    ];
  }

  /// ترتيب الموظفين
  static List<StaffRanking> getStaffRankings() {
    final staff = getStaffPerformance();
    staff.sort((a, b) => b.score.compareTo(a.score));

    final badges = ['نجم المتجر', 'متميز', 'جيد جداً', 'جيد', 'يحتاج تطوير'];
    return staff.asMap().entries.map((e) {
      return StaffRanking(
        cashierId: e.value.cashierId,
        nameAr: e.value.nameAr,
        rank: e.key + 1,
        score: e.value.score,
        changeFromLastWeek: (_random.nextDouble() * 6 - 2),
        badge: badges[min(e.key, badges.length - 1)],
      );
    }).toList();
  }

  /// بيانات خريطة حرارية للورديات
  static ShiftHeatmapData getShiftHeatmap() {
    final days = [
      'السبت',
      'الأحد',
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
    ];
    final hours = List.generate(14, (i) => 7 + i); // 7 AM to 8 PM

    final intensity = List.generate(7, (dayIndex) {
      return List.generate(14, (hourIndex) {
        final hour = 7 + hourIndex;
        double base;

        // Friday/Saturday are busier
        if (dayIndex == 5 || dayIndex == 6) {
          base = 0.6;
        } else {
          base = 0.3;
        }

        // Peak hours
        if (hour >= 11 && hour <= 14) {
          base += 0.3;
        } else if (hour >= 17 && hour <= 20) {
          base += 0.25;
        }

        // Add randomness
        base += (_random.nextDouble() * 0.15 - 0.05);
        return min(1.0, max(0.0, base));
      });
    });

    return ShiftHeatmapData(days: days, hours: hours, intensity: intensity);
  }

  /// تحسينات الورديات
  static List<ShiftOptimization> getShiftOptimizations() {
    return const [
      ShiftOptimization(
        day: 'Friday',
        dayAr: 'الجمعة',
        hourlyNeeds: [
          HourlyStaffNeed(
            hour: 11,
            trafficIntensity: 0.9,
            currentStaff: 3,
            suggestedStaff: 5,
          ),
          HourlyStaffNeed(
            hour: 12,
            trafficIntensity: 0.95,
            currentStaff: 3,
            suggestedStaff: 5,
          ),
          HourlyStaffNeed(
            hour: 13,
            trafficIntensity: 0.85,
            currentStaff: 3,
            suggestedStaff: 4,
          ),
        ],
        currentStaff: 3,
        suggestedStaff: 5,
        suggestion:
            'يوم الجمعة يحتاج موظفين إضافيين خلال فترة الظهر (11-13). اقتراح: إضافة أحمد ومحمد للوردية.',
      ),
      ShiftOptimization(
        day: 'Thursday',
        dayAr: 'الخميس',
        hourlyNeeds: [
          HourlyStaffNeed(
            hour: 17,
            trafficIntensity: 0.85,
            currentStaff: 2,
            suggestedStaff: 4,
          ),
          HourlyStaffNeed(
            hour: 18,
            trafficIntensity: 0.9,
            currentStaff: 2,
            suggestedStaff: 4,
          ),
          HourlyStaffNeed(
            hour: 19,
            trafficIntensity: 0.8,
            currentStaff: 2,
            suggestedStaff: 3,
          ),
        ],
        currentStaff: 2,
        suggestedStaff: 4,
        suggestion:
            'مساء الخميس يشهد ضغطاً عالياً (17-19). اقتراح: تأخير وردية فاطمة لتغطية المساء.',
      ),
    ];
  }

  /// ملخص أداء الفريق
  static TeamPerformanceSummary getTeamSummary() {
    final staff = getStaffPerformance();
    final avgScore =
        staff.map((s) => s.score).reduce((a, b) => a + b) / staff.length;
    final totalSales = staff.map((s) => s.salesVolume).reduce((a, b) => a + b);
    final totalTxn = staff
        .map((s) => s.totalTransactions)
        .reduce((a, b) => a + b);
    final avgVoid =
        staff.map((s) => s.voidRate).reduce((a, b) => a + b) / staff.length;
    final top = staff.reduce((a, b) => a.score > b.score ? a : b);

    return TeamPerformanceSummary(
      avgScore: double.parse(avgScore.toStringAsFixed(1)),
      totalSales: totalSales,
      totalTransactions: totalTxn,
      avgVoidRate: double.parse(avgVoid.toStringAsFixed(1)),
      topPerformer: top.nameAr,
      teamGrowth: 5.2,
    );
  }
}
