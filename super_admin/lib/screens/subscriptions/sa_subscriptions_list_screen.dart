import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

/// All active subscriptions list with filtering.
class SASubscriptionsListScreen extends StatefulWidget {
  const SASubscriptionsListScreen({super.key});

  @override
  State<SASubscriptionsListScreen> createState() =>
      _SASubscriptionsListScreenState();
}

class _SASubscriptionsListScreenState
    extends State<SASubscriptionsListScreen> {
  String _statusFilter = 'all';

  final List<_SubRow> _subscriptions = [
    _SubRow('Grocery Plus', 'Professional', 'active', '2024-01-15', '2025-01-15', 499),
    _SubRow('Tech Zone', 'Advanced', 'active', '2024-02-20', '2025-02-20', 249),
    _SubRow('Fashion Hub', 'Basic', 'trial', '2024-11-01', '2024-12-01', 0),
    _SubRow('Home Essentials', 'Basic', 'active', '2024-03-10', '2025-03-10', 99),
    _SubRow('Beauty Corner', 'Advanced', 'expired', '2024-04-05', '2024-10-05', 249),
    _SubRow('Auto Parts KSA', 'Professional', 'active', '2024-05-18', '2025-05-18', 499),
    _SubRow('Book Haven', 'Basic', 'trial', '2024-12-01', '2025-01-01', 0),
    _SubRow('Fresh Market', 'Advanced', 'active', '2024-06-22', '2025-06-22', 249),
  ];

  List<_SubRow> get _filtered {
    if (_statusFilter == 'all') return _subscriptions;
    return _subscriptions.where((s) => s.status == _statusFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

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
            Wrap(
              spacing: AlhaiSpacing.sm,
              runSpacing: AlhaiSpacing.sm,
              children: [
                _SummaryChip(
                  label: l10n.activeSubscriptions,
                  count: '5',
                  color: Colors.green,
                  isSelected: _statusFilter == 'active',
                  onTap: () => setState(() => _statusFilter =
                      _statusFilter == 'active' ? 'all' : 'active'),
                ),
                _SummaryChip(
                  label: l10n.trialSubscriptions,
                  count: '2',
                  color: Colors.amber,
                  isSelected: _statusFilter == 'trial',
                  onTap: () => setState(() => _statusFilter =
                      _statusFilter == 'trial' ? 'all' : 'trial'),
                ),
                _SummaryChip(
                  label: l10n.expiredSubscriptions,
                  count: '1',
                  color: Colors.red,
                  isSelected: _statusFilter == 'expired',
                  onTap: () => setState(() => _statusFilter =
                      _statusFilter == 'expired' ? 'all' : 'expired'),
                ),
              ],
            ),
            const SizedBox(height: AlhaiSpacing.md),

            // Table
            Expanded(
              child: Card(
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
                    rows: _filtered.map((sub) {
                      return DataRow(cells: [
                        DataCell(Text(sub.storeName)),
                        DataCell(Text(sub.plan)),
                        DataCell(_StatusChip(status: sub.status)),
                        DataCell(Text(sub.startDate)),
                        DataCell(Text(sub.endDate)),
                        DataCell(Text(
                          sub.price > 0
                              ? '${sub.price} ${l10n.sar}'
                              : l10n.trial,
                        )),
                      ]);
                    }).toList(),
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

class _SubRow {
  final String storeName;
  final String plan;
  final String status;
  final String startDate;
  final String endDate;
  final int price;

  const _SubRow(
    this.storeName,
    this.plan,
    this.status,
    this.startDate,
    this.endDate,
    this.price,
  );
}
