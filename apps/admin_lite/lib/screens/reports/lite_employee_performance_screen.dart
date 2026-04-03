/// Lite Employee Performance Summary Screen
///
/// Shows employee sales performance metrics, rankings,
/// and attendance summary in a compact view.
/// Supports RTL, dark mode, and responsive layouts.
library;

import 'package:flutter/material.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

/// Employee performance summary for Admin Lite
class LiteEmployeePerformanceScreen extends StatelessWidget {
  const LiteEmployeePerformanceScreen({super.key});

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
            // Overview cards
            _buildOverviewCards(context, isDark, isMobile, l10n),
            const SizedBox(height: AlhaiSpacing.lg),

            // Employee rankings
            _buildSectionTitle(l10n.performanceOverview, Icons.leaderboard, isDark),
            const SizedBox(height: AlhaiSpacing.sm),
            ..._employees.asMap().entries.map((entry) {
              return _buildEmployeeTile(context, entry.value, entry.key, isDark);
            }),

            const SizedBox(height: AlhaiSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCards(BuildContext context, bool isDark, bool isMobile, AppLocalizations l10n) {
    final items = [
      _OverviewItem(l10n.employees, '12', Icons.people, AlhaiColors.primary),
      _OverviewItem(l10n.active, '10', Icons.check_circle, AlhaiColors.success),
      _OverviewItem(l10n.shiftsTitle, '4', Icons.access_time, AlhaiColors.info),
    ];

    return Row(
      children: items.asMap().entries.map((entry) {
        return Expanded(
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              end: entry.key < items.length - 1 ? AlhaiSpacing.sm : 0,
            ),
            child: Container(
              padding: const EdgeInsets.all(AlhaiSpacing.md),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? Colors.white12 : Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(entry.value.icon, size: 20, color: entry.value.color),
                  const SizedBox(height: AlhaiSpacing.xs),
                  Text(
                    entry.value.value,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.xxxs),
                  Text(
                    entry.value.label,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white54 : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
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

  Widget _buildEmployeeTile(BuildContext context, _EmployeeData emp, int index, bool isDark) {
    final rank = index + 1;
    final rankColor = rank <= 3 ? AlhaiColors.warning : Colors.transparent;

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
          // Rank badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: rankColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: rank <= 3
                  ? Icon(Icons.star, size: 16, color: AlhaiColors.warning)
                  : Text(
                      '$rank',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: AlhaiSpacing.sm),
          // Avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: AlhaiColors.primary.withValues(alpha: 0.15),
            child: Text(
              emp.name.substring(0, 1),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AlhaiColors.primary,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: AlhaiSpacing.sm),
          // Name and role
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  emp.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  emp.role,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white38 : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // Stats
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                emp.sales,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                '${emp.transactions} txn',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white38 : Colors.black45,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static const _employees = [
    _EmployeeData('Ahmed Al-Salem', 'Cashier', '18,200', 245),
    _EmployeeData('Mohammed Ali', 'Cashier', '15,800', 210),
    _EmployeeData('Sara Ibrahim', 'Cashier', '14,500', 195),
    _EmployeeData('Khalid Omar', 'Senior Cashier', '12,300', 168),
    _EmployeeData('Fatima Hassan', 'Cashier', '10,100', 142),
    _EmployeeData('Omar Nasser', 'Cashier', '8,700', 115),
  ];
}

class _OverviewItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _OverviewItem(this.label, this.value, this.icon, this.color);
}

class _EmployeeData {
  final String name;
  final String role;
  final String sales;
  final int transactions;
  const _EmployeeData(this.name, this.role, this.sales, this.transactions);
}
