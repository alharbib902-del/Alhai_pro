/// Lite Daily Sales Summary Screen
///
/// Shows today's sales breakdown with totals, payment methods,
/// top items, and hourly distribution. Queries real data from
/// salesDao via Riverpod providers.
/// Supports RTL, dark mode, and responsive layouts.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import '../../providers/lite_screen_providers.dart';

/// Daily sales summary for Admin Lite
class LiteDailySalesScreen extends ConsumerWidget {
  const LiteDailySalesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final l10n = AppLocalizations.of(context)!;
    final dataAsync = ref.watch(liteDailySalesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dailyReport),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(liteDailySalesProvider),
            icon: const Icon(Icons.calendar_today),
            tooltip: l10n.today,
          ),
          const SizedBox(width: AlhaiSpacing.xs),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(liteDailySalesProvider),
        child: dataAsync.when(
          data: (data) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(isMobile ? AlhaiSpacing.md : AlhaiSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDateHeader(isDark, l10n),
                const SizedBox(height: AlhaiSpacing.md),
                _buildTotalsRow(context, isDark, isMobile, l10n, data),
                const SizedBox(height: AlhaiSpacing.lg),
                _buildSection(context, l10n.paymentMethod, Icons.payment, isDark,
                  data.paymentMethods.map((pm) {
                    final pct = data.todayStats.total > 0
                        ? '${(pm.total / data.todayStats.total * 100).toStringAsFixed(0)}%'
                        : '';
                    return _BreakdownRow(pm.method, pm.total.toStringAsFixed(0), pct, AlhaiColors.info);
                  }).toList(),
                ),
                const SizedBox(height: AlhaiSpacing.lg),
                _buildSection(context, l10n.products, Icons.star_rounded, isDark,
                  data.topProducts.map((p) {
                    return _BreakdownRow(p.name, p.price.toStringAsFixed(0), '', AlhaiColors.primary);
                  }).toList(),
                ),
                const SizedBox(height: AlhaiSpacing.lg),
                _buildHourlyChart(context, isDark, l10n, data.hourlySales),
                const SizedBox(height: AlhaiSpacing.lg),
              ],
            ),
          ),
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(AlhaiSpacing.massive),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (_, __) => _buildError(context, ref, isDark, l10n),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, bool isDark, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AlhaiSpacing.massive),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: isDark ? Colors.white30 : Theme.of(context).colorScheme.outlineVariant),
            const SizedBox(height: AlhaiSpacing.md),
            Text(l10n.errorOccurred, style: TextStyle(color: isDark ? Colors.white54 : Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: AlhaiSpacing.sm),
            TextButton.icon(
              onPressed: () => ref.invalidate(liteDailySalesProvider),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.tryAgain),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateHeader(bool isDark, AppLocalizations l10n) {
    final now = DateTime.now();
    return Text(
      '${l10n.today} \u2022 ${now.day}/${now.month}/${now.year}',
      style: TextStyle(
        fontSize: 14,
        color: isDark ? Colors.white54 : Colors.black54,
      ),
    );
  }

  Widget _buildTotalsRow(BuildContext context, bool isDark, bool isMobile, AppLocalizations l10n, DailySalesData data) {
    final items = [
      _TotalItem(l10n.totalSales, data.todayStats.total.toStringAsFixed(0), AlhaiColors.success, Icons.trending_up),
      _TotalItem(l10n.orders, '${data.todayStats.count}', AlhaiColors.info, Icons.receipt),
      _TotalItem(l10n.refund, data.refundStats.total.toStringAsFixed(0), AlhaiColors.error, Icons.undo),
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
                      fontSize: 20,
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

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    bool isDark,
    List<_BreakdownRow> rows,
  ) {
    if (rows.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AlhaiColors.primary),
              const SizedBox(width: AlhaiSpacing.xs),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.md),
          ...rows.map((row) => Padding(
                padding: const EdgeInsets.only(bottom: AlhaiSpacing.sm),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        color: row.color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: AlhaiSpacing.sm),
                    Expanded(
                      child: Text(
                        row.label,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    Text(
                      row.value,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    if (row.extra.isNotEmpty) ...[
                      const SizedBox(width: AlhaiSpacing.xs),
                      Text(
                        row.extra,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white38 : Colors.black45,
                        ),
                      ),
                    ],
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildHourlyChart(BuildContext context, bool isDark, AppLocalizations l10n, List<dynamic> hourlySales) {
    // Build normalized bars from hourly sales data
    final maxTotal = hourlySales.isEmpty ? 1.0 :
        hourlySales.fold<double>(0, (max, h) => h.total > max ? h.total : max);
    final bars = hourlySales.isEmpty
        ? List.filled(12, 0.0)
        : List.generate(12, (i) {
            final hour = 8 + i;
            final match = hourlySales.where((h) => h.hour == hour);
            if (match.isEmpty) return 0.0;
            return maxTotal > 0 ? match.first.total / maxTotal : 0.0;
          });

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.access_time, size: 18, color: AlhaiColors.primary),
              const SizedBox(width: AlhaiSpacing.xs),
              Text(
                l10n.sales,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.md),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: bars.map((v) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: Container(
                      height: 120 * v.clamp(0.0, 1.0),
                      decoration: BoxDecoration(
                        color: AlhaiColors.info.withValues(alpha: 0.6),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['8AM', '10', '12PM', '2', '4', '6PM'].map((h) {
              return Text(
                h,
                style: TextStyle(fontSize: 10, color: isDark ? Colors.white38 : Colors.black38),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _TotalItem {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _TotalItem(this.label, this.value, this.color, this.icon);
}

class _BreakdownRow {
  final String label;
  final String value;
  final String extra;
  final Color color;
  const _BreakdownRow(this.label, this.value, this.extra, this.color);
}
