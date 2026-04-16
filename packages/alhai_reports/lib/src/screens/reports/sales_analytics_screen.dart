import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart' show AlhaiSpacing;
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import '../../utils/csv_export_helper.dart';

/// شاشة تحليلات المبيعات - بيانات حقيقية من قاعدة البيانات
class SalesAnalyticsScreen extends ConsumerStatefulWidget {
  const SalesAnalyticsScreen({super.key});

  @override
  ConsumerState<SalesAnalyticsScreen> createState() =>
      _SalesAnalyticsScreenState();
}

class _SalesAnalyticsScreenState extends ConsumerState<SalesAnalyticsScreen> {
  String _selectedPeriod = 'week';

  DateRange? get _dateRange {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'today':
        final start = DateTime(now.year, now.month, now.day);
        return DateRange(start: start, end: now);
      case 'week':
        return DateRange(
          start: now.subtract(const Duration(days: 7)),
          end: now,
        );
      case 'month':
        return DateRange(
          start: now.subtract(const Duration(days: 30)),
          end: now,
        );
      default:
        return null;
    }
  }

  Future<void> _exportCsv(AppLocalizations l10n) async {
    final statsAsync = ref.read(salesAnalyticsProvider(_dateRange));
    final stats = statsAsync.valueOrNull;
    if (stats == null) return;
    final result = await CsvExportHelper.exportAndShare(
      context: context,
      fileName: l10n.salesAnalytics,
      headers: ['البند', 'القيمة'],
      rows: [
        [l10n.totalSales, stats.total.toStringAsFixed(2)],
        [l10n.invoices, '${stats.count}'],
        [l10n.averageSale, stats.average.toStringAsFixed(2)],
        ['أعلى فاتورة', stats.maxSale.toStringAsFixed(2)],
        ['أقل فاتورة', stats.minSale.toStringAsFixed(2)],
      ],
    );
    if (mounted) CsvExportHelper.showResultSnackBar(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statsAsync = ref.watch(salesAnalyticsProvider(_dateRange));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.salesAnalytics),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.date_range),
            onSelected: (v) => setState(() => _selectedPeriod = v),
            itemBuilder: (context) => [
              PopupMenuItem(value: 'today', child: Text(l10n.today)),
              PopupMenuItem(value: 'week', child: Text(l10n.thisWeek)),
              PopupMenuItem(value: 'month', child: Text(l10n.thisMonth)),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'CSV',
            onPressed: () => _exportCsv(l10n),
          ),
        ],
      ),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${l10n.errorOccurred}: $e')),
        data: (stats) => ResponsiveBuilder(
          builder: (context, deviceType, width) {
            final padding = getResponsiveValue<double>(
              context,
              mobile: 16,
              desktop: 24,
            );
            return SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AlhaiSpacing.xs,
                      vertical: AlhaiSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _selectedPeriod == 'today'
                          ? l10n.today
                          : _selectedPeriod == 'week'
                          ? l10n.thisWeek
                          : l10n.thisMonth,
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.md),
                  _buildMetricGrid(context, l10n, stats, deviceType),
                  const SizedBox(height: AlhaiSpacing.lg),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AlhaiSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.salesAnalytics,
                            style: theme.textTheme.titleMedium,
                          ),
                          const Divider(),
                          _SummaryRow(
                            label: l10n.totalSales,
                            value:
                                '${stats.total.toStringAsFixed(2)} ${l10n.sar}',
                          ),
                          _SummaryRow(
                            label: l10n.invoices,
                            value: '${stats.count}',
                          ),
                          _SummaryRow(
                            label: l10n.averageSale,
                            value:
                                '${stats.average.toStringAsFixed(2)} ${l10n.sar}',
                          ),
                          _SummaryRow(
                            label: l10n.totalSales,
                            value:
                                '${stats.maxSale.toStringAsFixed(2)} ${l10n.sar}',
                          ),
                          _SummaryRow(
                            label: l10n.averageSale,
                            value:
                                '${stats.minSale.toStringAsFixed(2)} ${l10n.sar}',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMetricGrid(
    BuildContext context,
    AppLocalizations l10n,
    dynamic stats,
    DeviceType deviceType,
  ) {
    final cards = [
      _MetricCard(
        icon: Icons.attach_money,
        title: l10n.totalSales,
        value: '${stats.total.toStringAsFixed(0)} ${l10n.sar}',
        color: Colors.green,
      ),
      _MetricCard(
        icon: Icons.receipt_long,
        title: l10n.invoices,
        value: '${stats.count}',
        color: Colors.blue,
      ),
      _MetricCard(
        icon: Icons.shopping_cart,
        title: l10n.averageSale,
        value: '${stats.average.toStringAsFixed(0)} ${l10n.sar}',
        color: Colors.orange,
      ),
      _MetricCard(
        icon: Icons.trending_up,
        title: l10n.totalSales,
        value: '${stats.maxSale.toStringAsFixed(0)} ${l10n.sar}',
        color: Colors.purple,
      ),
    ];

    if (deviceType == DeviceType.desktop) {
      return Row(
        children: cards
            .map(
              (c) => Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(
                    end: AlhaiSpacing.sm,
                  ),
                  child: c,
                ),
              ),
            )
            .toList(),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: cards[0]),
            const SizedBox(width: AlhaiSpacing.sm),
            Expanded(child: cards[1]),
          ],
        ),
        const SizedBox(height: AlhaiSpacing.sm),
        Row(
          children: [
            Expanded(child: cards[2]),
            const SizedBox(width: AlhaiSpacing.sm),
            Expanded(child: cards[3]),
          ],
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _MetricCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AlhaiSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: AlhaiSpacing.xs),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AlhaiSpacing.xs),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
