/// Lite Employee Schedule Screen
///
/// Shows employee shift schedules for the current week
/// with a simple timeline/calendar view.
/// Supports RTL, dark mode, and responsive layouts.
library;

import 'package:flutter/material.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

/// Employee schedule view for Admin Lite
class LiteEmployeeScheduleScreen extends StatelessWidget {
  const LiteEmployeeScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.employees),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? AlhaiSpacing.md : AlhaiSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Week selector
            _buildWeekSelector(context, isDark),
            const SizedBox(height: AlhaiSpacing.lg),

            // Today's schedule
            _buildSectionTitle(l10n.today, Icons.today, isDark),
            const SizedBox(height: AlhaiSpacing.sm),
            ..._todaySchedule.map((s) => _buildScheduleCard(context, s, isDark)),

            const SizedBox(height: AlhaiSpacing.lg),

            // Upcoming shifts
            _buildSectionTitle(l10n.next, Icons.schedule, isDark),
            const SizedBox(height: AlhaiSpacing.sm),
            ..._upcomingSchedule.map((s) => _buildScheduleCard(context, s, isDark)),

            const SizedBox(height: AlhaiSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekSelector(BuildContext context, bool isDark) {
    final days = ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
    final today = 3; // Tuesday

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white12 : Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: days.asMap().entries.map((entry) {
          final isToday = entry.key == today;
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
                      color: isToday ? Colors.white : (isDark ? Colors.white54 : Colors.black54),
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.xxxs),
                  Text(
                    '${entry.key + 29}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isToday ? Colors.white : (isDark ? Colors.white : Colors.black87),
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

  Widget _buildScheduleCard(BuildContext context, _ScheduleEntry entry, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: AlhaiSpacing.xs),
      padding: const EdgeInsets.all(AlhaiSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white12 : Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          // Time column
          Container(
            width: 52,
            padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xxs),
            decoration: BoxDecoration(
              color: entry.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  entry.startTime,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: entry.color,
                  ),
                ),
                Text(
                  entry.endTime,
                  style: TextStyle(
                    fontSize: 11,
                    color: entry.color.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AlhaiSpacing.sm),
          // Employee info
          CircleAvatar(
            radius: 18,
            backgroundColor: AlhaiColors.primary.withValues(alpha: 0.15),
            child: Text(
              entry.employeeName.substring(0, 1),
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
                  entry.employeeName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  entry.role,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white38 : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.xs, vertical: AlhaiSpacing.xxxs),
            decoration: BoxDecoration(
              color: entry.isActive ? AlhaiColors.success.withValues(alpha: 0.12) : (isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade100),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              entry.isActive ? 'Active' : entry.day ?? 'Scheduled',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: entry.isActive ? AlhaiColors.success : (isDark ? Colors.white54 : Colors.black54),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const _todaySchedule = [
    _ScheduleEntry('Ahmed Al-Salem', 'Cashier', '08:00', '16:00', AlhaiColors.primary, true, null),
    _ScheduleEntry('Mohammed Ali', 'Cashier', '08:00', '16:00', AlhaiColors.primary, true, null),
    _ScheduleEntry('Sara Ibrahim', 'Cashier', '14:00', '22:00', AlhaiColors.info, false, null),
    _ScheduleEntry('Khalid Omar', 'Senior Cashier', '14:00', '22:00', AlhaiColors.info, false, null),
  ];

  static const _upcomingSchedule = [
    _ScheduleEntry('Fatima Hassan', 'Cashier', '08:00', '16:00', AlhaiColors.primary, false, 'Wed'),
    _ScheduleEntry('Omar Nasser', 'Cashier', '08:00', '16:00', AlhaiColors.primary, false, 'Wed'),
    _ScheduleEntry('Ahmed Al-Salem', 'Cashier', '14:00', '22:00', AlhaiColors.info, false, 'Thu'),
  ];
}

class _ScheduleEntry {
  final String employeeName;
  final String role;
  final String startTime;
  final String endTime;
  final Color color;
  final bool isActive;
  final String? day;

  const _ScheduleEntry(this.employeeName, this.role, this.startTime, this.endTime, this.color, this.isActive, this.day);
}
