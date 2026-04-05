/// شاشة تقرير ساعات الذروة - Peak Hours Report Screen
///
/// تحليل أوقات الذروة والنشاط خلال اليوم والأسبوع
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_design_system/alhai_design_system.dart' show AlhaiSpacing;
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

/// شاشة تقرير ساعات الذروة
class PeakHoursReportScreen extends ConsumerStatefulWidget {
  const PeakHoursReportScreen({super.key});

  @override
  ConsumerState<PeakHoursReportScreen> createState() =>
      _PeakHoursReportScreenState();
}

class _PeakHoursReportScreenState extends ConsumerState<PeakHoursReportScreen> {
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );

  String _viewMode = 'hourly'; // hourly, daily, weekly
  bool _isLoading = true;

  // بيانات ساعات اليوم
  List<HourlyData> _hourlyData = [];

  // بيانات أيام الأسبوع
  List<DailyData> _dailyData = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final db = GetIt.I<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider) ?? kDefaultStoreId;

      // Load hourly data for today
      final hourlySales =
          await db.salesDao.getHourlySales(storeId, DateTime.now());
      _hourlyData = hourlySales
          .map((h) => HourlyData(
                hour: h.hour,
                transactions: h.count,
                revenue: h.total,
              ))
          .toList();

      // Load daily data by iterating last 7 days
      // Day indices: 0=Saturday, 1=Sunday, ..., 6=Friday
      // Names will be resolved with l10n at display time
      final dayNames = ['sat', 'sun', 'mon', 'tue', 'wed', 'thu', 'fri'];
      final dailyList = <DailyData>[];
      for (int i = 6; i >= 0; i--) {
        final date = DateTime.now().subtract(Duration(days: i));
        try {
          final daySales = await db.salesDao.getSalesStats(
            storeId,
            startDate: DateTime(date.year, date.month, date.day),
            endDate: DateTime(date.year, date.month, date.day + 1),
          );
          // weekday: 1=Monday ... 7=Sunday; map to Arabic week starting Saturday
          final arabicDayIndex = (date.weekday + 1) % 7; // Saturday=0
          dailyList.add(DailyData(
            day: dayNames[arabicDayIndex],
            transactions: daySales.count,
            revenue: daySales.total,
          ));
        } catch (_) {
          // Skip days that fail
        }
      }
      _dailyData = dailyList;

      setState(() => _isLoading = false);
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).reports),
        actions: [
          IconButton(
            onPressed: _selectDateRange,
            icon: const Icon(Icons.date_range),
            tooltip: AppLocalizations.of(context).date,
          ),
          IconButton(
            onPressed: _exportReport,
            icon: const Icon(Icons.download),
            tooltip: AppLocalizations.of(context).exportAction,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppSizes.lg),
              children: [
                // شريط الفترة والعرض
                _buildHeaderBar(),
                const SizedBox(height: AppSizes.lg),

                // ملخص الذروة
                if (_hourlyData.isNotEmpty && _dailyData.isNotEmpty)
                  _buildPeakSummary(),
                if (_hourlyData.isNotEmpty && _dailyData.isNotEmpty)
                  const SizedBox(height: AppSizes.lg),

                // الرسم البياني الرئيسي
                if (_hourlyData.isNotEmpty || _dailyData.isNotEmpty)
                  _buildMainChart(),
                if (_hourlyData.isNotEmpty || _dailyData.isNotEmpty)
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
                const Icon(Icons.calendar_today,
                    size: 16, color: AppColors.primary),
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
          segments: [
            ButtonSegment(
              value: 'hourly',
              label: Text(AppLocalizations.of(context).hourlyView),
              icon: const Icon(Icons.access_time, size: 16),
            ),
            ButtonSegment(
              value: 'daily',
              label: Text(AppLocalizations.of(context).dailyView),
              icon: const Icon(Icons.today, size: 16),
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
    final avgTransactions =
        _hourlyData.fold(0, (sum, h) => sum + h.transactions) ~/
            _hourlyData.length;

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            AppLocalizations.of(context).peakHourLabel,
            '${peakHour.hour}:00',
            AppLocalizations.of(context)
                .transactionsWithCount(peakHour.transactions),
            Icons.schedule,
            AppColors.error,
          ),
        ),
        const SizedBox(width: AppSizes.md),
        Expanded(
          child: _buildSummaryCard(
            AppLocalizations.of(context).peakDayLabel,
            peakDay.day,
            AppLocalizations.of(context)
                .transactionsWithCount(peakDay.transactions),
            Icons.event,
            AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSizes.md),
        Expanded(
          child: _buildSummaryCard(
            AppLocalizations.of(context).avgPerHour,
            avgTransactions.toString(),
            AppLocalizations.of(context).transactionWord,
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
            const SizedBox(height: AlhaiSpacing.xxs),
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
                  ? AppLocalizations.of(context).transactionsByHour
                  : AppLocalizations.of(context).transactionsByDay,
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
    if (_hourlyData.isEmpty) return const SizedBox.shrink();
    final maxTransactions = _hourlyData
        .map((h) => h.transactions)
        .reduce((a, b) => a > b ? a : b)
        .clamp(1, double.maxFinite.toInt());

    return SizedBox(
      height: 250,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: _hourlyData.map((data) {
          final height = data.transactions / maxTransactions * 180;
          final isPeak = data.transactions == maxTransactions;

          return Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AlhaiSpacing.xxxs),
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
                  const SizedBox(height: AlhaiSpacing.xxs),
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
                  const SizedBox(height: AlhaiSpacing.xs),
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
    if (_dailyData.isEmpty) return const SizedBox.shrink();
    final maxTransactions = _dailyData
        .map((d) => d.transactions)
        .reduce((a, b) => a > b ? a : b)
        .clamp(1, double.maxFinite.toInt());

    return SizedBox(
      height: 250,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: _dailyData.map((data) {
          final height = data.transactions / maxTransactions * 180;
          final isPeak = data.transactions == maxTransactions;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.xxs),
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
                  const SizedBox(height: AlhaiSpacing.xxs),
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
                  const SizedBox(height: AlhaiSpacing.xs),
                  Text(
                    _getDayShort(context, data.day),
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
    final l10n = AppLocalizations.of(context);
    final days = [
      l10n.satShort,
      l10n.sunShort,
      l10n.monShort,
      l10n.tueShort,
      l10n.wedShort,
      l10n.thuShort,
      l10n.friShort
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  AppLocalizations.of(context).activityHeatmap,
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
            const SizedBox(height: AlhaiSpacing.xxs),

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
          AppLocalizations.of(context).lowLabel,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textMuted,
            fontSize: 10,
          ),
        ),
        const SizedBox(width: AlhaiSpacing.xxs),
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
        const SizedBox(width: AlhaiSpacing.xxs),
        Text(
          AppLocalizations.of(context).highLabel,
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
                  AppLocalizations.of(context).analysisRecommendations,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),
            const Divider(),
            _buildRecommendationItem(
              AppLocalizations.of(context).staffRecommendation,
              AppLocalizations.of(context).staffRecommendationDesc,
              Icons.people,
              AppColors.primary,
            ),
            _buildRecommendationItem(
              AppLocalizations.of(context).offersRecommendation,
              AppLocalizations.of(context).offersRecommendationDesc,
              Icons.local_offer,
              AppColors.success,
            ),
            _buildRecommendationItem(
              AppLocalizations.of(context).inventoryRecommendation,
              AppLocalizations.of(context).inventoryRecommendationDesc,
              Icons.inventory,
              AppColors.info,
            ),
            _buildRecommendationItem(
              AppLocalizations.of(context).shiftsRecommendation,
              AppLocalizations.of(context).shiftsRecommendationDesc,
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

  // ignore: unused_element
  String _getDayName(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context);
    switch (key) {
      case 'sat':
        return l10n.saturdayDay;
      case 'sun':
        return l10n.sundayDay;
      case 'mon':
        return l10n.mondayDay;
      case 'tue':
        return l10n.tuesdayDay;
      case 'wed':
        return l10n.wednesdayDay;
      case 'thu':
        return l10n.thursdayDay;
      case 'fri':
        return l10n.fridayDay;
      default:
        return key;
    }
  }

  String _getDayShort(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context);
    switch (key) {
      case 'sat':
        return l10n.satShort;
      case 'sun':
        return l10n.sunShort;
      case 'mon':
        return l10n.monShort;
      case 'tue':
        return l10n.tueShort;
      case 'wed':
        return l10n.wedShort;
      case 'thu':
        return l10n.thuShort;
      case 'fri':
        return l10n.friShort;
      default:
        return key;
    }
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
        _isLoading = true;
      });
      _loadData();
    }
  }

  void _exportReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).exportingReport),
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
