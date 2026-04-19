import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

import '../../providers/sa_dashboard_providers.dart';
import '../../providers/sa_subscriptions_providers.dart';

/// Platform reports screen.
/// Shows summary reports and export options.
class SAReportsScreen extends ConsumerWidget {
  const SAReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final kpis = ref.watch(saDashboardKPIsProvider);
    final subCounts = ref.watch(saSubscriptionCountsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.saReportsTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Stats Section
            Text(
              l10n.saPlatformSummary,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            kpis.when(
              data: (data) => Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _StatCard(
                    title: l10n.saActiveStores,
                    value: '${data.activeStores}',
                    icon: Icons.store_rounded,
                    color: Colors.blue,
                  ),
                  _StatCard(
                    title: l10n.saActiveSubscriptions,
                    value: '${data.activeSubscriptions}',
                    icon: Icons.card_membership_rounded,
                    color: Colors.green,
                  ),
                  _StatCard(
                    title: l10n.saTrialSubscriptions,
                    value: '${data.trialSubscriptions}',
                    icon: Icons.hourglass_top_rounded,
                    color: Colors.orange,
                  ),
                  _StatCard(
                    title: l10n.saNewSignups30d,
                    value: '${data.newSignups}',
                    icon: Icons.person_add_rounded,
                    color: Colors.purple,
                  ),
                  _StatCard(
                    title: 'MRR',
                    value: '${data.mrr.toStringAsFixed(0)} SAR',
                    icon: Icons.trending_up_rounded,
                    color: Colors.teal,
                  ),
                  _StatCard(
                    title: 'ARR',
                    value: '${data.arr.toStringAsFixed(0)} SAR',
                    icon: Icons.calendar_month_rounded,
                    color: Colors.indigo,
                  ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error loading KPIs: $e'),
            ),

            const SizedBox(height: 32),

            // Subscription breakdown
            Text(
              l10n.saSubscriptionStatus,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            subCounts.when(
              data: (counts) => Wrap(
                spacing: 16,
                runSpacing: 16,
                children: counts.entries.map((e) {
                  final color = switch (e.key) {
                    'active' => Colors.green,
                    'trial' => Colors.orange,
                    'expired' => Colors.red,
                    _ => Colors.grey,
                  };
                  return _StatCard(
                    title: e.key,
                    value: '${e.value}',
                    icon: Icons.circle,
                    color: color,
                  );
                }).toList(),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Text(l10n.saErrorLoading),
            ),

            const SizedBox(height: 32),

            // Export Section
            Text(
              l10n.saExportData,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _ExportButton(
                  label: l10n.saStoresReport,
                  icon: Icons.store_rounded,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.saExportComingSoon)),
                    );
                  },
                ),
                _ExportButton(
                  label: l10n.saUsersReport,
                  icon: Icons.people_rounded,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.saExportComingSoon)),
                    );
                  },
                ),
                _ExportButton(
                  label: l10n.saRevenueReport,
                  icon: Icons.attach_money_rounded,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.saExportComingSoon)),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 180,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 12),
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExportButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _ExportButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
