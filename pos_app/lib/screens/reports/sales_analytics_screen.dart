import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/settings_providers.dart';
import '../../widgets/responsive/responsive_builder.dart';
import '../../core/responsive/responsive_utils.dart';
import '../../core/constants/breakpoints.dart';

/// شاشة تحليلات المبيعات - بيانات حقيقية من قاعدة البيانات
class SalesAnalyticsScreen extends ConsumerStatefulWidget {
  const SalesAnalyticsScreen({super.key});

  @override
  ConsumerState<SalesAnalyticsScreen> createState() => _SalesAnalyticsScreenState();
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
        return DateRange(start: now.subtract(const Duration(days: 7)), end: now);
      case 'month':
        return DateRange(start: now.subtract(const Duration(days: 30)), end: now);
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
        ],
      ),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${l10n.errorOccurred}: $e')),
        data: (stats) => ResponsiveBuilder(
          builder: (context, deviceType, width) {
            final padding = getResponsiveValue<double>(context, mobile: 16, desktop: 24);
            return SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _selectedPeriod == 'today' ? l10n.today : _selectedPeriod == 'week' ? l10n.thisWeek : l10n.thisMonth,
                      style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMetricGrid(context, l10n, stats, deviceType),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.salesAnalytics, style: theme.textTheme.titleMedium),
                          const Divider(),
                          _SummaryRow(label: l10n.totalSales, value: '${stats.total.toStringAsFixed(2)} ${l10n.sar}'),
                          _SummaryRow(label: l10n.invoices, value: '${stats.count}'),
                          _SummaryRow(label: l10n.averageSale, value: '${stats.average.toStringAsFixed(2)} ${l10n.sar}'),
                          _SummaryRow(label: l10n.totalSales, value: '${stats.maxSale.toStringAsFixed(2)} ${l10n.sar}'),
                          _SummaryRow(label: l10n.averageSale, value: '${stats.minSale.toStringAsFixed(2)} ${l10n.sar}'),
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

  Widget _buildMetricGrid(BuildContext context, AppLocalizations l10n, dynamic stats, DeviceType deviceType) {
    final cards = [
      _MetricCard(icon: Icons.attach_money, title: l10n.totalSales, value: '${stats.total.toStringAsFixed(0)} ${l10n.sar}', color: Colors.green),
      _MetricCard(icon: Icons.receipt_long, title: l10n.invoices, value: '${stats.count}', color: Colors.blue),
      _MetricCard(icon: Icons.shopping_cart, title: l10n.averageSale, value: '${stats.average.toStringAsFixed(0)} ${l10n.sar}', color: Colors.orange),
      _MetricCard(icon: Icons.trending_up, title: l10n.totalSales, value: '${stats.maxSale.toStringAsFixed(0)} ${l10n.sar}', color: Colors.purple),
    ];

    if (deviceType == DeviceType.desktop) {
      return Row(
        children: cards.map((c) => Expanded(child: Padding(
          padding: const EdgeInsetsDirectional.only(end: 12),
          child: c,
        ))).toList(),
      );
    }

    return Column(
      children: [
        Row(children: [Expanded(child: cards[0]), const SizedBox(width: 12), Expanded(child: cards[1])]),
        const SizedBox(height: 12),
        Row(children: [Expanded(child: cards[2]), const SizedBox(width: 12), Expanded(child: cards[3])]),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _MetricCard({required this.icon, required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant))),
            ]),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
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
          Text(label, style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
