import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../providers/sa_providers.dart';

/// All active subscriptions list with real Supabase data.
class SASubscriptionsListScreen extends ConsumerWidget {
  const SASubscriptionsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final filter = ref.watch(saSubsFilterProvider);
    final subsAsync = ref.watch(saSubscriptionsListProvider);
    final countsAsync = ref.watch(saSubscriptionCountsProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(AlhaiSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.subscriptionList,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AlhaiSpacing.lg),

            // Summary chips
            countsAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (counts) => Wrap(
                spacing: AlhaiSpacing.sm,
                runSpacing: AlhaiSpacing.sm,
                children: [
                  _SummaryChip(
                    label: l10n.activeSubscriptions,
                    count: '${counts['active'] ?? 0}',
                    color: Colors.green,
                    isSelected: filter == 'active',
                    onTap: () => ref.read(saSubsFilterProvider.notifier).state =
                        filter == 'active' ? 'all' : 'active',
                  ),
                  _SummaryChip(
                    label: l10n.trialSubscriptions,
                    count: '${counts['trial'] ?? 0}',
                    color: Colors.amber,
                    isSelected: filter == 'trial',
                    onTap: () => ref.read(saSubsFilterProvider.notifier).state =
                        filter == 'trial' ? 'all' : 'trial',
                  ),
                  _SummaryChip(
                    label: l10n.expiredSubscriptions,
                    count: '${counts['expired'] ?? 0}',
                    color: Colors.red,
                    isSelected: filter == 'expired',
                    onTap: () => ref.read(saSubsFilterProvider.notifier).state =
                        filter == 'expired' ? 'all' : 'expired',
                  ),
                ],
              ),
            ),
            const SizedBox(height: AlhaiSpacing.md),

            // Table
            Expanded(
              child: subsAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (subs) => Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AlhaiRadius.card),
                    side: BorderSide(
                      color: theme.colorScheme.outlineVariant,
                      width: AlhaiSpacing.strokeXs,
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: DataTable(
                      columnSpacing: AlhaiSpacing.lg,
                      headingRowHeight: 48,
                      dataRowMinHeight: 52,
                      dataRowMaxHeight: 52,
                      columns: [
                        DataColumn(label: Text(l10n.storeName)),
                        DataColumn(label: Text(l10n.storePlan)),
                        DataColumn(label: Text(l10n.storeStatus)),
                        const DataColumn(label: Text('Start')),
                        const DataColumn(label: Text('End')),
                        DataColumn(
                          label: Text(l10n.planPrice),
                          numeric: true,
                        ),
                      ],
                      rows: subs.map((sub) {
                        final store =
                            sub['stores'] as Map<String, dynamic>?;
                        final plan =
                            sub['plans'] as Map<String, dynamic>?;
                        final storeName =
                            store?['name'] as String? ?? '-';
                        final planName =
                            plan?['name'] as String? ?? '-';
                        final status =
                            sub['status'] as String? ?? 'unknown';
                        final startDate = _fmtDate(
                            sub['start_date'] as String?);
                        final endDate = _fmtDate(
                            sub['end_date'] as String?);
                        final price =
                            (plan?['monthly_price'] as num?)
                                    ?.toInt() ??
                                0;

                        return DataRow(cells: [
                          DataCell(Text(storeName)),
                          DataCell(Text(planName)),
                          DataCell(_StatusChip(status: status)),
                          DataCell(Text(startDate)),
                          DataCell(Text(endDate)),
                          DataCell(Text(
                            price > 0
                                ? '$price ${l10n.sar}'
                                : l10n.trial,
                          )),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmtDate(String? date) {
    if (date == null) return '-';
    return date.length >= 10 ? date.substring(0, 10) : date;
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String count;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _SummaryChip({
    required this.label,
    required this.count,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: color.withValues(alpha: 0.15),
      checkmarkColor: color,
      side: BorderSide(
        color: isSelected ? color : Colors.transparent,
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, bgColor) = switch (status) {
      'active' => (Colors.green.shade700, Colors.green.shade50),
      'trial' => (Colors.amber.shade700, Colors.amber.shade50),
      'expired' => (Colors.red.shade700, Colors.red.shade50),
      _ => (Colors.grey.shade700, Colors.grey.shade50),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AlhaiSpacing.xs,
        vertical: AlhaiSpacing.xxxs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AlhaiRadius.chip),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
