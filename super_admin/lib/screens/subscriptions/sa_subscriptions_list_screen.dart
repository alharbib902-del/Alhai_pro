import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../providers/sa_providers.dart';
import '../../data/models/sa_subscription_model.dart';
import '../../ui/widgets/sa_skeleton.dart';
import '../../ui/widgets/sa_empty_state.dart';

/// All active subscriptions list with real Supabase data.
class SASubscriptionsListScreen extends ConsumerStatefulWidget {
  const SASubscriptionsListScreen({super.key});

  @override
  ConsumerState<SASubscriptionsListScreen> createState() =>
      _SASubscriptionsListScreenState();
}

class _SASubscriptionsListScreenState
    extends ConsumerState<SASubscriptionsListScreen> {
  int _rowsPerPage = 10;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
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
                    color: isDark
                        ? const Color(0xFF4ADE80)
                        : const Color(0xFF16A34A),
                    isSelected: filter == 'active',
                    onTap: () => ref.read(saSubsFilterProvider.notifier).state =
                        filter == 'active' ? 'all' : 'active',
                  ),
                  _SummaryChip(
                    label: l10n.trialSubscriptions,
                    count: '${counts['trial'] ?? 0}',
                    color: isDark
                        ? const Color(0xFFFBBF24)
                        : const Color(0xFFD97706),
                    isSelected: filter == 'trial',
                    onTap: () => ref.read(saSubsFilterProvider.notifier).state =
                        filter == 'trial' ? 'all' : 'trial',
                  ),
                  _SummaryChip(
                    label: l10n.expiredSubscriptions,
                    count: '${counts['expired'] ?? 0}',
                    color: isDark
                        ? const Color(0xFFF87171)
                        : const Color(0xFFB91C1C),
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
                loading: () => const SATableSkeleton(),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (subs) => Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AlhaiRadius.card),
                    side: BorderSide(
                      color: colorScheme.outlineVariant,
                      width: AlhaiSpacing.strokeXs,
                    ),
                  ),
                  child: PaginatedDataTable2(
                    columnSpacing: 12,
                    horizontalMargin: 12,
                    minWidth: 800,
                    rowsPerPage: _rowsPerPage,
                    availableRowsPerPage: const [10, 25, 50],
                    onRowsPerPageChanged: (value) {
                      if (value != null) setState(() => _rowsPerPage = value);
                    },
                    headingRowHeight: 48,
                    dataRowHeight: 52,
                    empty: SAEmptyState.subscriptions(),
                    columns: [
                      DataColumn2(
                          label: Text(l10n.storeName), size: ColumnSize.L),
                      DataColumn2(label: Text(l10n.storePlan), fixedWidth: 130),
                      DataColumn2(
                          label: Text(l10n.storeStatus), fixedWidth: 120),
                      const DataColumn2(label: Text('Start'), fixedWidth: 120),
                      const DataColumn2(label: Text('End'), fixedWidth: 120),
                      DataColumn2(
                        label: Text(l10n.planPrice),
                        numeric: true,
                        fixedWidth: 120,
                      ),
                    ],
                    source: _SubscriptionsDataSource(
                      subs: subs,
                      l10n: l10n,
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
}

String _fmtDate(String? date) {
  if (date == null) return '-';
  return date.length >= 10 ? date.substring(0, 10) : date;
}

class _SubscriptionsDataSource extends DataTableSource {
  final List<SASubscription> subs;
  final AppLocalizations l10n;

  _SubscriptionsDataSource({
    required this.subs,
    required this.l10n,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= subs.length) return null;
    final sub = subs[index];

    final storeName = sub.storeName;
    final planName = sub.planName;
    final status = sub.status ?? 'unknown';
    final startDate = _fmtDate(sub.startDate);
    final endDate = _fmtDate(sub.endDate);
    final price = sub.monthlyPrice.toInt();

    return DataRow2(
      cells: [
        DataCell(Text(storeName)),
        DataCell(Text(planName)),
        DataCell(_StatusChip(status: status)),
        DataCell(Text(startDate)),
        DataCell(Text(endDate)),
        DataCell(Text(
          price > 0 ? '$price ${l10n.sar}' : l10n.trial,
        )),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => subs.length;

  @override
  int get selectedRowCount => 0;
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (color, bgColor) = switch (status) {
      'active' => (
          isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D),
          isDark ? const Color(0xFF1B3A2A) : const Color(0xFFDCFCE7),
        ),
      'trial' => (
          isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309),
          isDark ? const Color(0xFF3A2F1B) : const Color(0xFFFEF3C7),
        ),
      'expired' => (
          isDark ? const Color(0xFFF87171) : const Color(0xFFB91C1C),
          isDark ? const Color(0xFF3A1B1B) : const Color(0xFFFEE2E2),
        ),
      _ => (
          isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563),
          isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF3F4F6),
        ),
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
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
