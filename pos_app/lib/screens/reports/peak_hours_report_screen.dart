/// شاشة تقرير ساعات الذروة - Peak Hours Report Screen
///
/// تحليل أوقات الذروة والنشاط خلال اليوم والأسبوع
library;

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';

/// شاشة تقرير ساعات الذروة
class PeakHoursReportScreen extends StatefulWidget {
  const PeakHoursReportScreen({super.key});

  @override
  State<PeakHoursReportScreen> createState() => _PeakHoursReportScreenState();
}

class _PeakHoursReportScreenState extends State<PeakHoursReportScreen> {
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );

  String _viewMode = 'hourly'; // hourly, daily, weekly

  // بيانات ساعات اليوم
  final List<HourlyData> _hourlyData = [
    HourlyData(hour: 8, transactions: 15, revenue: 850.0),
    HourlyData(hour: 9, transactions: 25, revenue: 1450.0),
    HourlyData(hour: 10, transactions: 45, revenue: 2800.0),
    HourlyData(hour: 11, transactions: 65, revenue: 4200.0),
    HourlyData(hour: 12, transactions: 85, revenue: 5500.0),
    HourlyData(hour: 13, transactions: 55, revenue: 3600.0),
    HourlyData(hour: 14, transactions: 35, revenue: 2200.0),
    HourlyData(hour: 15, transactions: 40, revenue: 2500.0),
    HourlyData(hour: 16, transactions: 50, revenue: 3100.0),
    HourlyData(hour: 17, transactions: 75, revenue: 4800.0),
    HourlyData(hour: 18, transactions: 90, revenue: 5800.0),
    HourlyData(hour: 19, transactions: 70, revenue: 4500.0),
    HourlyData(hour: 20, transactions: 55, revenue: 3500.0),
    HourlyData(hour: 21, transactions: 35, revenue: 2200.0),
    HourlyData(hour: 22, transactions: 20, revenue: 1200.0),
  ];

  // بيانات أيام الأسبوع
  final List<DailyData> _dailyData = [
    DailyData(day: 'السبت', transactions: 450, revenue: 28500.0),
    DailyData(day: 'الأحد', transactions: 380, revenue: 24200.0),
    DailyData(day: 'الاثنين', transactions: 320, revenue: 20500.0),
    DailyData(day: 'الثلاثاء', transactions: 340, revenue: 21800.0),
    DailyData(day: 'الأربعاء', transactions: 360, revenue: 23000.0),
    DailyData(day: 'الخميس', transactions: 420, revenue: 26800.0),
    DailyData(day: 'الجمعة', transactions: 480, revenue: 30500.0),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقرير ساعات الذروة'),
        actions: [
          IconButton(
            onPressed: _selectDateRange,
            icon: const Icon(Icons.date_range),
            tooltip: 'تحديد الفترة',
          ),
          IconButton(
            onPressed: _exportReport,
            icon: const Icon(Icons.download),
            tooltip: 'تصدير',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.lg),
        children: [
          // شريط الفترة والعرض
          _buildHeaderBar(),
          const SizedBox(height: AppSizes.lg),

          // ملخص الذروة
          _buildPeakSummary(),
          const SizedBox(height: AppSizes.lg),

          // الرسم البياني الرئيسي
          _buildMainChart(),
          const SizedBox(height: AppSizes.lg),

          // خريطة الحرارة
          _buildHeatmap(),
          const SizedBox(height: AppSizes.lg),

          // توصيات
          _buildRecommendations(),
        ],
      ),
    );
  }

  Widget _buildHeaderBar() {
    return Row(
      children: [
        // الفترة
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                const SizedBox(width: AppSizes.sm),
                Text(
                  '${_formatDate(_dateRange.start)} - ${_formatDate(_dateRange.end)}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSizes.md),

        // نوع العرض
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(
              value: 'hourly',
              label: Text('ساعي'),
              icon: Icon(Icons.access_time, size: 16),
            ),
            ButtonSegment(
              value: 'daily',
              label: Text('يومي'),
              icon: Icon(Icons.today, size: 16),
            ),
          ],
          selected: {_viewMode},
          onSelectionChanged: (value) {
            setState(() {
              _viewMode = value.first;
            });
          },
        ),
      ],
    );
  }

  Widget _buildPeakSummary() {
    // حساب أوقات الذروة
    final peakHour = _hourlyData.reduce(
      (a, b) => a.transactions > b.transactions ? a : b,
    );
    final peakDay = _dailyData.reduce(
      (a, b) => a.transactions > b.transactions ? a : b,
    );
    final avgTransactions = _hourlyData.fold(0, (sum, h) => sum + h.transactions) ~/ _hourlyData.length;

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'ساعة الذروة',
            '${peakHour.hour}:00',
            '${peakHour.transactions} معاملة',
            Icons.schedule,
            AppColors.error,
          ),
        ),
        const SizedBox(width: AppSizes.md),
        Expanded(
          child: _buildSummaryCard(
            'يوم الذروة',
            peakDay.day,
            '${peakDay.transactions} معاملة',
            Icons.event,
            AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSizes.md),
        Expanded(
          child: _buildSummaryCard(
            'متوسط/ساعة',
            avgTransactions.toString(),
            'معاملة',
            Icons.bar_chart,
            AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String label,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.sm),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              value,
              style: AppTypography.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _viewMode == 'hourly'
                  ? 'المعاملات حسب الساعة'
                  : 'المعاملات حسب اليوم',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.lg),

            if (_viewMode == 'hourly')
              _buildHourlyChart()
            else
              _buildDailyChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildHourlyChart() {
    final maxTransactions = _hourlyData
        .map((h) => h.transactions)
        .reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 250,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: _hourlyData.map((data) {
          final height = data.transactions / maxTransactions * 180;
          final isPeak = data.transactions == maxTransactions;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${data.transactions}',
                    style: AppTypography.labelSmall.copyWith(
                      color: isPeak ? AppColors.error : AppColors.textMuted,
                      fontWeight: isPeak ? FontWeight.bold : FontWeight.normal,
                      fontSize: 9,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: height,
                    decoration: BoxDecoration(
                      color: isPeak
                          ? AppColors.error
                          : AppColors.primary.withValues(alpha: 0.7),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${data.hour}',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDailyChart() {
    final maxTransactions = _dailyData
        .map((d) => d.transactions)
        .reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 250,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: _dailyData.map((data) {
          final height = data.transactions / maxTransactions * 180;
          final isPeak = data.transactions == maxTransactions;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${data.transactions}',
                    style: AppTypography.labelSmall.copyWith(
                      color: isPeak ? AppColors.error : AppColors.textMuted,
                      fontWeight: isPeak ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: height,
                    decoration: BoxDecoration(
                      color: isPeak
                          ? AppColors.error
                          : AppColors.primary.withValues(alpha: 0.7),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data.day.substring(0, 3),
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHeatmap() {
    // بيانات خريطة الحرارة (ساعة × يوم)
    final heatmapData = [
      [15, 25, 20, 22, 24, 30, 35], // 8:00
      [20, 30, 28, 25, 30, 38, 42], // 9:00
      [35, 45, 40, 42, 45, 55, 60], // 10:00
      [50, 60, 55, 58, 60, 70, 75], // 11:00
      [65, 80, 72, 75, 78, 85, 90], // 12:00
      [45, 55, 50, 52, 55, 60, 65], // 13:00
      [30, 35, 32, 34, 36, 42, 45], // 14:00
      [35, 40, 38, 40, 42, 48, 52], // 15:00
      [45, 50, 48, 50, 52, 58, 62], // 16:00
      [60, 72, 68, 70, 72, 80, 85], // 17:00
      [75, 88, 82, 85, 88, 95, 98], // 18:00
      [55, 68, 62, 65, 68, 75, 80], // 19:00
      [40, 52, 48, 50, 52, 58, 62], // 20:00
      [25, 35, 32, 34, 36, 42, 45], // 21:00
      [15, 20, 18, 19, 20, 25, 28], // 22:00
    ];

    final hours = List.generate(15, (i) => '${8 + i}:00');
    final days = ['سبت', 'أحد', 'اثن', 'ثلا', 'أرب', 'خمي', 'جمع'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'خريطة النشاط الحراري',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                _buildLegend(),
              ],
            ),
            const SizedBox(height: AppSizes.lg),

            // Header (أيام الأسبوع)
            Row(
              children: [
                const SizedBox(width: 40),
                ...days.map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Grid
            ...List.generate(heatmapData.length, (hourIndex) {
              return Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: Text(
                      hours[hourIndex],
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  ...List.generate(7, (dayIndex) {
                    final value = heatmapData[hourIndex][dayIndex];
                    return Expanded(
                      child: Container(
                        height: 20,
                        margin: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: _getHeatmapColor(value),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      children: [
        Text(
          'منخفض',
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textMuted,
            fontSize: 10,
          ),
        ),
        const SizedBox(width: 4),
        Container(
          width: 60,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: LinearGradient(
              colors: [
                AppColors.success.withValues(alpha: 0.2),
                AppColors.success.withValues(alpha: 0.5),
                AppColors.warning.withValues(alpha: 0.7),
                AppColors.error.withValues(alpha: 0.9),
              ],
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          'عالي',
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textMuted,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Color _getHeatmapColor(int value) {
    if (value < 30) {
      return AppColors.success.withValues(alpha: 0.2 + value / 100);
    } else if (value < 50) {
      return AppColors.success.withValues(alpha: 0.5 + (value - 30) / 100);
    } else if (value < 70) {
      return AppColors.warning.withValues(alpha: 0.5 + (value - 50) / 100);
    } else {
      return AppColors.error.withValues(alpha: 0.6 + (value - 70) / 150);
    }
  }

  Widget _buildRecommendations() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb, color: AppColors.warning),
                const SizedBox(width: AppSizes.sm),
                Text(
                  'توصيات بناءً على التحليل',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),
            const Divider(),

            _buildRecommendationItem(
              'الموظفين',
              'زيادة عدد الكاشير في الفترة 12:00-13:00 و 17:00-19:00 (ذروة المبيعات)',
              Icons.people,
              AppColors.primary,
            ),
            _buildRecommendationItem(
              'العروض',
              'تقديم عروض خاصة في الفترة 14:00-16:00 لزيادة المبيعات في الفترة الهادئة',
              Icons.local_offer,
              AppColors.success,
            ),
            _buildRecommendationItem(
              'المخزون',
              'تجهيز المخزون قبل يومي الخميس والجمعة (أعلى أيام المبيعات)',
              Icons.inventory,
              AppColors.info,
            ),
            _buildRecommendationItem(
              'الورديات',
              'توزيع الورديات: صباحية 8-15، مسائية 15-22 مع تداخل في الذروة',
              Icons.schedule,
              AppColors.warning,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.sm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );

    if (picked != null) {
      setState(() {
        _dateRange = picked;
      });
    }
  }

  void _exportReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('جاري تصدير التقرير...'),
      ),
    );
  }
}

/// بيانات ساعية
class HourlyData {
  final int hour;
  final int transactions;
  final double revenue;

  HourlyData({
    required this.hour,
    required this.transactions,
    required this.revenue,
  });
}

/// بيانات يومية
class DailyData {
  final String day;
  final int transactions;
  final double revenue;

  DailyData({
    required this.day,
    required this.transactions,
    required this.revenue,
  });
}
