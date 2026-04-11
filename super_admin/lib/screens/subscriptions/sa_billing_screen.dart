import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../providers/sa_providers.dart';

/// Billing & invoices screen -- real Supabase data.
class SABillingScreen extends ConsumerWidget {
  const SABillingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= AlhaiBreakpoints.desktop;

    final summaryAsync = ref.watch(saBillingSummaryProvider);
    final invoicesAsync = ref.watch(saBillingInvoicesProvider);

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
            summaryAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
              data: (summary) {
                final paid = summary['paid'] ?? 0.0;
                final unpaid = summary['unpaid'] ?? 0.0;
                final overdue = summary['overdue'] ?? 0.0;

                return GridView.count(
                  crossAxisCount: isWide ? 3 : 1,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: AlhaiSpacing.md,
                  crossAxisSpacing: AlhaiSpacing.md,
                  childAspectRatio: isWide ? 2.5 : 3.0,
                  children: [
                    _BillingStat(
                      title: l10n.paid,
                      value: '${paid.toInt()} ${l10n.sar}',
                      icon: Icons.check_circle_rounded,
                      color: isDark
                          ? const Color(0xFF4ADE80)
                          : const Color(0xFF16A34A),
                    ),
                    _BillingStat(
                      title: l10n.unpaid,
                      value: '${unpaid.toInt()} ${l10n.sar}',
                      icon: Icons.pending_rounded,
                      color: isDark
                          ? const Color(0xFFFBBF24)
                          : const Color(0xFFD97706),
                    ),
                    _BillingStat(
                      title: l10n.overdue,
                      value: '${overdue.toInt()} ${l10n.sar}',
                      icon: Icons.error_rounded,
                      color: isDark
                          ? const Color(0xFFF87171)
                          : const Color(0xFFB91C1C),
                    ),
                  ],
                );
              },
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
            invoicesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error loading invoices: $e'),
              data: (invoices) {
                if (invoices.isEmpty) {
                  return Card(
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(AlhaiSpacing.xl),
                      child: Center(
                        child: Text(
                          'No invoices found',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return Card(
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
                      rows: invoices.map((inv) {
                        return DataRow(
                          cells: [
                            DataCell(Text(inv.invoiceNumber ?? '-')),
                            DataCell(Text(inv.storeName)),
                            DataCell(Text(inv.planName)),
                            DataCell(Text(_fmtDate(inv.issuedAt))),
                            DataCell(
                              Text('${inv.amount?.toInt() ?? 0} ${l10n.sar}'),
                            ),
                            DataCell(
                              _InvoiceStatusChip(
                                status: inv.status ?? 'unknown',
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (color, bgColor) = switch (status) {
      'paid' => (
        isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D),
        isDark ? const Color(0xFF1B3A2A) : const Color(0xFFDCFCE7),
      ),
      'unpaid' => (
        isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309),
        isDark ? const Color(0xFF3A2F1B) : const Color(0xFFFEF3C7),
      ),
      'overdue' => (
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
