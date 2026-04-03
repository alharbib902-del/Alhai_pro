/// Lite Cash Flow Summary Screen
///
/// Shows cash inflows, outflows, and net cash position
/// with a simple breakdown by category.
/// Supports RTL, dark mode, and responsive layouts.
library;

import 'package:flutter/material.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

/// Cash flow summary for Admin Lite
class LiteCashFlowScreen extends StatelessWidget {
  const LiteCashFlowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.cash),
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? AlhaiSpacing.md : AlhaiSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Net cash card
            _buildNetCashCard(context, isDark, l10n),
            const SizedBox(height: AlhaiSpacing.lg),

            // Inflow / Outflow row
            _buildFlowCards(context, isDark, isMobile, l10n),
            const SizedBox(height: AlhaiSpacing.lg),

            // Inflows breakdown
            _buildBreakdownSection(
              context, isDark, l10n,
              title: l10n.sales,
              icon: Icons.arrow_downward,
              iconColor: AlhaiColors.success,
              items: [
                _FlowItem(l10n.cash, '8,420'),
                _FlowItem(l10n.card, '2,850'),
                _FlowItem(l10n.transfer, '1,180'),
              ],
            ),
            const SizedBox(height: AlhaiSpacing.lg),

            // Outflows breakdown
            _buildBreakdownSection(
              context, isDark, l10n,
              title: l10n.expenses,
              icon: Icons.arrow_upward,
              iconColor: AlhaiColors.error,
              items: [
                _FlowItem(l10n.refund, '320'),
                _FlowItem(l10n.expenses, '1,200'),
                _FlowItem(l10n.suppliers, '2,500'),
              ],
            ),
            const SizedBox(height: AlhaiSpacing.lg),

            // Daily trend
            _buildDailyTrend(context, isDark, l10n),

            const SizedBox(height: AlhaiSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildNetCashCard(BuildContext context, bool isDark, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AlhaiSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AlhaiColors.primary, AlhaiColors.primary.withValues(alpha: 0.7)],
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.balance,
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: AlhaiSpacing.xs),
          const Text(
            '8,430 SAR',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: AlhaiSpacing.xs),
          Row(
            children: [
              const Icon(Icons.arrow_upward, size: 14, color: Colors.white70),
              const Text(
                '+12.3% ',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white70),
              ),
              Text(
                l10n.thisWeek,
                style: const TextStyle(fontSize: 13, color: Colors.white54),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFlowCards(BuildContext context, bool isDark, bool isMobile, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(AlhaiSpacing.md),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.06) : AlhaiColors.success.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? Colors.white12 : AlhaiColors.success.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.arrow_downward, size: 18, color: AlhaiColors.success),
                    const SizedBox(width: AlhaiSpacing.xxs),
                    Text(
                      l10n.sales,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AlhaiSpacing.xs),
                Text(
                  '12,450',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AlhaiColors.success,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AlhaiSpacing.sm),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(AlhaiSpacing.md),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.06) : AlhaiColors.error.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? Colors.white12 : AlhaiColors.error.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.arrow_upward, size: 18, color: AlhaiColors.error),
                    const SizedBox(width: AlhaiSpacing.xxs),
                    Text(
                      l10n.expenses,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AlhaiSpacing.xs),
                Text(
                  '4,020',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AlhaiColors.error,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBreakdownSection(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<_FlowItem> items,
  }) {
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
              Icon(icon, size: 18, color: iconColor),
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
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: AlhaiSpacing.sm),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    Text(
                      item.amount,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildDailyTrend(BuildContext context, bool isDark, AppLocalizations l10n) {
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
          Text(
            l10n.thisWeek,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : null,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.md),
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [0.5, 0.7, 0.4, 0.8, 0.6, 0.9, 0.55].asMap().entries.map((entry) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.xxxs),
                    child: Container(
                      height: 100 * entry.value,
                      decoration: BoxDecoration(
                        color: AlhaiColors.success.withValues(alpha: entry.key == 5 ? 1.0 : 0.5),
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
            children: ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'].map((d) {
              return Expanded(
                child: Text(
                  d,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: isDark ? Colors.white38 : Colors.black38),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _FlowItem {
  final String label;
  final String amount;
  const _FlowItem(this.label, this.amount);
}
