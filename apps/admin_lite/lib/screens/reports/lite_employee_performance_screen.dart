/// Lite Employee Performance Summary Screen
///
/// Shows employee sales performance metrics grouped by cashier,
/// queried from salesDao JOIN users. Supports RTL, dark mode,
/// and responsive layouts.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import '../../providers/lite_screen_providers.dart';

/// Employee performance summary for Admin Lite
class LiteEmployeePerformanceScreen extends ConsumerWidget {
  const LiteEmployeePerformanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final l10n = AppLocalizations.of(context);
    final dataAsync = ref.watch(liteEmployeePerformanceProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.employees), centerTitle: true),
      body: dataAsync.when(
        data: (employees) {
          if (employees.isEmpty) {
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
          final activeCount = employees.length;
          return SingleChildScrollView(
            padding: EdgeInsets.all(
              isMobile ? AlhaiSpacing.md : AlhaiSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOverviewCards(
                  context,
                  isDark,
                  isMobile,
                  l10n,
                  employees.length,
                  activeCount,
                ),
                const SizedBox(height: AlhaiSpacing.lg),
                _buildSectionTitle(
                  l10n.performanceOverview,
                  Icons.leaderboard,
                  isDark,
                ),
                const SizedBox(height: AlhaiSpacing.sm),
                ...employees.asMap().entries.map((entry) {
                  return _buildEmployeeTile(
                    context,
                    entry.value,
                    entry.key,
                    isDark,
                  );
                }),
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
                onPressed: () =>
                    ref.invalidate(liteEmployeePerformanceProvider),
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l10n.tryAgain),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCards(
    BuildContext context,
    bool isDark,
    bool isMobile,
    AppLocalizations l10n,
    int total,
    int active,
  ) {
    final items = [
      _OverviewItem(
        l10n.employees,
        '$total',
        Icons.people,
        AlhaiColors.primary,
      ),
      _OverviewItem(
        l10n.active,
        '$active',
        Icons.check_circle,
        AlhaiColors.success,
      ),
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
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark
                      ? Colors.white12
                      : Theme.of(context).colorScheme.outlineVariant,
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
                      color: isDark
                          ? Colors.white54
                          : Theme.of(context).colorScheme.onSurfaceVariant,
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

  Widget _buildEmployeeTile(
    BuildContext context,
    EmployeePerformanceData emp,
    int index,
    bool isDark,
  ) {
    final rank = index + 1;
    final rankColor = rank <= 3 ? AlhaiColors.warning : Colors.transparent;

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
          CircleAvatar(
            radius: 18,
            backgroundColor: AlhaiColors.primary.withValues(alpha: 0.15),
            child: Text(
              emp.name.isNotEmpty ? emp.name.substring(0, 1) : '?',
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
                    color: isDark
                        ? Colors.white38
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                emp.totalSales.toStringAsFixed(0),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                '${emp.transactionCount} txn',
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
}

class _OverviewItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _OverviewItem(this.label, this.value, this.icon, this.color);
}
