/// Lite Daily Sales Summary Screen
///
/// Shows today's sales breakdown with totals, payment methods,
/// top items, and hourly distribution. Lightweight version
/// for the Admin Lite app.
/// Supports RTL, dark mode, and responsive layouts.
library;

import 'package:flutter/material.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

/// Daily sales summary for Admin Lite
class LiteDailySalesScreen extends StatelessWidget {
  const LiteDailySalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dailyReport),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.calendar_today),
            tooltip: l10n.today,
          ),
          const SizedBox(width: AlhaiSpacing.xs),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(isMobile ? AlhaiSpacing.md : AlhaiSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date header
              _buildDateHeader(isDark, l10n),
              const SizedBox(height: AlhaiSpacing.md),

              // Totals row
              _buildTotalsRow(context, isDark, isMobile, l10n),
              const SizedBox(height: AlhaiSpacing.lg),

              // Payment methods breakdown
              _buildSection(context, l10n.paymentMethod, Icons.payment, isDark, [
                _BreakdownRow(l10n.cash, '8,420', '68%', AlhaiColors.success),
                _BreakdownRow(l10n.card, '2,850', '23%', AlhaiColors.info),
                _BreakdownRow(l10n.credit, '1,180', '9%', AlhaiColors.warning),
              ]),
              const SizedBox(height: AlhaiSpacing.lg),

              // Top selling items
              _buildSection(context, l10n.products, Icons.star_rounded, isDark, [
                _BreakdownRow('Rice 10kg', '45', '', AlhaiColors.primary),
                _BreakdownRow('Sugar 5kg', '38', '', AlhaiColors.primary),
                _BreakdownRow('Cooking Oil 2L', '32', '', AlhaiColors.primary),
                _BreakdownRow('Milk 1L', '28', '', AlhaiColors.primary),
                _BreakdownRow('Bread', '25', '', AlhaiColors.primary),
              ]),
              const SizedBox(height: AlhaiSpacing.lg),

              // Hourly distribution placeholder
              _buildHourlyChart(context, isDark, l10n),

              const SizedBox(height: AlhaiSpacing.lg),
            ],
          ),
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

  Widget _buildTotalsRow(BuildContext context, bool isDark, bool isMobile, AppLocalizations l10n) {
    final items = [
      _TotalItem(l10n.totalSales, '12,450', AlhaiColors.success, Icons.trending_up),
      _TotalItem(l10n.orders, '186', AlhaiColors.info, Icons.receipt),
      _TotalItem(l10n.refund, '320', AlhaiColors.error, Icons.undo),
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

  Widget _buildHourlyChart(BuildContext context, bool isDark, AppLocalizations l10n) {
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
              children: [0.2, 0.3, 0.5, 0.8, 0.6, 0.9, 1.0, 0.7, 0.4, 0.3, 0.2, 0.1].map((v) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: Container(
                      height: 120 * v,
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
