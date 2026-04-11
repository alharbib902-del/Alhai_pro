/// Lite Employee Schedule Screen
///
/// Shows employee shift schedules for the current week
/// queried from shiftsDao with cashier names.
/// Supports RTL, dark mode, and responsive layouts.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_database/alhai_database.dart';

import '../../providers/lite_screen_providers.dart';

/// Employee schedule view for Admin Lite
class LiteEmployeeScheduleScreen extends ConsumerWidget {
  const LiteEmployeeScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final l10n = AppLocalizations.of(context);
    final dataAsync = ref.watch(liteEmployeeScheduleProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.employees), centerTitle: true),
      body: dataAsync.when(
        data: (shifts) {
          if (shifts.isEmpty) {
            return Center(
              child: Text(
                l10n.noResults,
                style: TextStyle(
                  color: isDark
                      ? Colors.white54
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }

          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final todayShifts = shifts.where((s) {
            final d = s.shift.openedAt;
            return DateTime(d.year, d.month, d.day) == today;
          }).toList();
          final otherShifts = shifts.where((s) {
            final d = s.shift.openedAt;
            return DateTime(d.year, d.month, d.day) != today;
          }).toList();

          return SingleChildScrollView(
            padding: EdgeInsets.all(
              isMobile ? AlhaiSpacing.md : AlhaiSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWeekSelector(context, isDark),
                const SizedBox(height: AlhaiSpacing.lg),
                if (todayShifts.isNotEmpty) ...[
                  _buildSectionTitle(l10n.today, Icons.today, isDark),
                  const SizedBox(height: AlhaiSpacing.sm),
                  ...todayShifts.map(
                    (s) => _buildScheduleCard(context, s, isDark, true),
                  ),
                  const SizedBox(height: AlhaiSpacing.lg),
                ],
                if (otherShifts.isNotEmpty) ...[
                  _buildSectionTitle(l10n.next, Icons.schedule, isDark),
                  const SizedBox(height: AlhaiSpacing.sm),
                  ...otherShifts.map(
                    (s) => _buildScheduleCard(context, s, isDark, false),
                  ),
                ],
                const SizedBox(height: AlhaiSpacing.lg),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.errorOccurred),
              TextButton.icon(
                onPressed: () => ref.invalidate(liteEmployeeScheduleProvider),
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l10n.tryAgain),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeekSelector(BuildContext context, bool isDark) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final todayWeekday = now.weekday;
    final daysSinceSat = (todayWeekday + 1) % 7;
    final startOfWeek = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: daysSinceSat));
    final days = [
      l10n.sat,
      l10n.sun,
      l10n.mon,
      l10n.tue,
      l10n.wed,
      l10n.thu,
      l10n.fri,
    ];

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white12
              : Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: days.asMap().entries.map((entry) {
          final isToday = entry.key == daysSinceSat;
          final dayDate = startOfWeek.add(Duration(days: entry.key));
          return Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.sm),
              decoration: BoxDecoration(
                color: isToday ? AlhaiColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    entry.value,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      color: isToday
                          ? Colors.white
                          : (isDark ? Colors.white54 : Colors.black54),
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.xxxs),
                  Text(
                    '${dayDate.day}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isToday
                          ? Colors.white
                          : (isDark ? Colors.white : Colors.black87),
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

  Widget _buildSectionTitle(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AlhaiColors.primary),
        const SizedBox(width: AlhaiSpacing.xs),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : null,
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleCard(
    BuildContext context,
    ShiftWithCashier entry,
    bool isDark,
    bool isToday,
  ) {
    final shift = entry.shift;
    final l10n = AppLocalizations.of(context);
    final name = entry.cashierName ?? l10n.unknownUser;
    final isOpen = shift.status == 'open';
    final startTime =
        '${shift.openedAt.hour.toString().padLeft(2, '0')}:${shift.openedAt.minute.toString().padLeft(2, '0')}';
    final endTime = shift.closedAt != null
        ? '${shift.closedAt!.hour.toString().padLeft(2, '0')}:${shift.closedAt!.minute.toString().padLeft(2, '0')}'
        : '--:--';
    final color = isOpen ? AlhaiColors.primary : AlhaiColors.info;

    return Container(
      margin: const EdgeInsets.only(bottom: AlhaiSpacing.xs),
      padding: const EdgeInsets.all(AlhaiSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white12
              : Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xxs),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  startTime,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  endTime,
                  style: TextStyle(
                    fontSize: 11,
                    color: color.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AlhaiSpacing.sm),
          CircleAvatar(
            radius: 18,
            backgroundColor: AlhaiColors.primary.withValues(alpha: 0.15),
            child: Text(
              name.isNotEmpty ? name.substring(0, 1) : '?',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AlhaiColors.primary,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: AlhaiSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  shift.status,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? Colors.white38
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AlhaiSpacing.xs,
              vertical: AlhaiSpacing.xxxs,
            ),
            decoration: BoxDecoration(
              color: isOpen
                  ? AlhaiColors.success.withValues(alpha: 0.12)
                  : (isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.grey.shade100),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isOpen ? l10n.active : l10n.closed,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isOpen
                    ? AlhaiColors.success
                    : (isDark ? Colors.white54 : Colors.black54),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
