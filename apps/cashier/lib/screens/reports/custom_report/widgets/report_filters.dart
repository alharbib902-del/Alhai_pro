/// بطاقة فلاتر التقرير — المدى الزمني + chips التاريخ السريع
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart' show AlhaiSpacing;

import '../providers/report_config_notifier.dart';

class ReportFiltersCard extends ConsumerWidget {
  final bool isDark;
  final bool isMediumScreen;

  const ReportFiltersCard({
    super.key,
    required this.isDark,
    required this.isMediumScreen,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final config = ref.watch(reportConfigProvider);
    final range = config.dateRange;

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.date_range_rounded,
                  color: AppColors.info,
                  size: 20,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(
                l10n.dateRange,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.mdl),
          _QuickDateChips(
            isDark: isDark,
            onPick: (r) =>
                ref.read(reportConfigProvider.notifier).setDateRange(r),
          ),
          const SizedBox(height: AlhaiSpacing.md),
          InkWell(
            onTap: () => _pickRange(context, ref, range),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(AlhaiSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.getSurfaceVariant(isDark),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.getBorder(isDark)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.fromLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.getTextMuted(isDark),
                          ),
                        ),
                        const SizedBox(height: AlhaiSpacing.xxs),
                        Text(
                          range != null ? _fmt(range.start) : '--/--/----',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.getTextPrimary(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: AppColors.getTextMuted(isDark),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          l10n.toLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.getTextMuted(isDark),
                          ),
                        ),
                        const SizedBox(height: AlhaiSpacing.xxs),
                        Text(
                          range != null ? _fmt(range.end) : '--/--/----',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.getTextPrimary(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (range != null) ...[
            const SizedBox(height: 10),
            Center(
              child: Text(
                '${range.duration.inDays + 1} ${l10n.days}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.getTextMuted(isDark),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickRange(
    BuildContext context,
    WidgetRef ref,
    DateTimeRange? current,
  ) async {
    final picked = await showDateRangePicker(
      context: context,
      // P2 #8 (2026-04-24): 2020 is a conservative lower bound covering all
      // live deployments. Ideally this would come from the store's
      // `createdAt`, but stores table isn't injected here — keep 2020.
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: current,
    );
    if (picked != null) {
      ref.read(reportConfigProvider.notifier).setDateRange(picked);
    }
  }

  String _fmt(DateTime date) => '${date.day}/${date.month}/${date.year}';
}

class _QuickDateChips extends StatelessWidget {
  final bool isDark;
  final ValueChanged<DateTimeRange> onPick;

  const _QuickDateChips({required this.isDark, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final chips = [
      (
        l10n.today,
        DateTimeRange(start: DateTime(now.year, now.month, now.day), end: now),
      ),
      (
        l10n.thisWeek,
        // P2 #7 (2026-04-24): previously `now - (weekday-1) days` without
        // truncating time, so the range start carried HH:MM:SS from "now"
        // and missed early-Monday transactions. Floor to midnight.
        () {
          final weekStart = now.subtract(Duration(days: now.weekday - 1));
          return DateTimeRange(
            start: DateTime(weekStart.year, weekStart.month, weekStart.day),
            end: now,
          );
        }(),
      ),
      (
        l10n.thisMonthPeriod,
        DateTimeRange(start: DateTime(now.year, now.month, 1), end: now),
      ),
      (
        l10n.lastMonth,
        DateTimeRange(
          start: DateTime(now.year, now.month - 1, 1),
          end: DateTime(now.year, now.month, 0),
        ),
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: chips.map((chip) {
          return Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: InkWell(
              onTap: () => onPick(chip.$2),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AlhaiSpacing.sm,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.getSurfaceVariant(isDark),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.getBorder(isDark)),
                ),
                child: Text(
                  chip.$1,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.getTextSecondary(isDark),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
