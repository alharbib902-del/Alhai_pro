import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

/// Billing & invoices screen.
class SABillingScreen extends StatelessWidget {
  const SABillingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= AlhaiBreakpoints.desktop;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AlhaiSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.billingAndInvoices,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AlhaiSpacing.lg),

            // Summary cards
            GridView.count(
              crossAxisCount: isWide ? 3 : 1,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AlhaiSpacing.md,
              crossAxisSpacing: AlhaiSpacing.md,
              childAspectRatio: isWide ? 2.5 : 3.0,
              children: [
                _BillingStat(
                  title: l10n.paid,
                  value: '234,500 ${l10n.sar}',
                  icon: Icons.check_circle_rounded,
                  color: Colors.green,
                ),
                _BillingStat(
                  title: l10n.unpaid,
                  value: '12,300 ${l10n.sar}',
                  icon: Icons.pending_rounded,
                  color: Colors.amber,
                ),
                _BillingStat(
                  title: l10n.overdue,
                  value: '3,200 ${l10n.sar}',
                  icon: Icons.error_rounded,
                  color: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: AlhaiSpacing.xl),

            // Invoice table
            Text(
              l10n.billingHistory,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AlhaiSpacing.md),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AlhaiRadius.card),
                side: BorderSide(
                  color: theme.colorScheme.outlineVariant,
                  width: AlhaiSpacing.strokeXs,
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: AlhaiSpacing.xl,
                  headingRowHeight: 48,
                  dataRowMinHeight: 52,
                  dataRowMaxHeight: 52,
                  columns: [
                    DataColumn(label: Text(l10n.invoiceNumber)),
                    DataColumn(label: Text(l10n.storeName)),
                    DataColumn(label: Text(l10n.storePlan)),
                    DataColumn(label: Text(l10n.invoiceDate)),
                    DataColumn(
                      label: Text(l10n.invoiceAmount),
                      numeric: true,
                    ),
                    DataColumn(label: Text(l10n.invoiceStatus)),
                  ],
                  rows: _invoices.map((inv) {
                    return DataRow(cells: [
                      DataCell(Text(inv.number)),
                      DataCell(Text(inv.store)),
                      DataCell(Text(inv.plan)),
                      DataCell(Text(inv.date)),
                      DataCell(Text('${inv.amount} ${l10n.sar}')),
                      DataCell(_InvoiceStatusChip(status: inv.status)),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final _invoices = [
  _InvoiceRow('INV-2024-001', 'Grocery Plus', 'Professional', '2024-12-01', 499, 'paid'),
  _InvoiceRow('INV-2024-002', 'Tech Zone', 'Advanced', '2024-12-01', 249, 'paid'),
  _InvoiceRow('INV-2024-003', 'Home Essentials', 'Basic', '2024-12-01', 99, 'paid'),
  _InvoiceRow('INV-2024-004', 'Auto Parts KSA', 'Professional', '2024-12-01', 499, 'paid'),
  _InvoiceRow('INV-2024-005', 'Fresh Market', 'Advanced', '2024-12-01', 249, 'unpaid'),
  _InvoiceRow('INV-2024-006', 'Beauty Corner', 'Advanced', '2024-10-01', 249, 'overdue'),
];

class _BillingStat extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _BillingStat({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AlhaiRadius.card),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant,
          width: AlhaiSpacing.strokeXs,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AlhaiSpacing.md),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AlhaiRadius.sm),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: AlhaiSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.xxxs),
                  Text(
                    value,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InvoiceStatusChip extends StatelessWidget {
  final String status;
  const _InvoiceStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, bgColor) = switch (status) {
      'paid' => (Colors.green.shade700, Colors.green.shade50),
      'unpaid' => (Colors.amber.shade700, Colors.amber.shade50),
      'overdue' => (Colors.red.shade700, Colors.red.shade50),
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

class _InvoiceRow {
  final String number;
  final String store;
  final String plan;
  final String date;
  final int amount;
  final String status;

  const _InvoiceRow(
    this.number,
    this.store,
    this.plan,
    this.date,
    this.amount,
    this.status,
  );
}
