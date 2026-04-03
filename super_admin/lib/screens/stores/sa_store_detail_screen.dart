import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

/// Store detail screen: info, subscription, usage stats.
class SAStoreDetailScreen extends StatelessWidget {
  final String storeId;
  const SAStoreDetailScreen({super.key, required this.storeId});

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
            // Back + title
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => context.go('/stores'),
                ),
                const SizedBox(width: AlhaiSpacing.xs),
                Expanded(
                  child: Text(
                    '${l10n.storeDetail} - $storeId',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Actions
                OutlinedButton.icon(
                  onPressed: () =>
                      context.go('/stores/$storeId/settings'),
                  icon: const Icon(Icons.settings_rounded, size: 18),
                  label: Text(l10n.storeSettings),
                ),
              ],
            ),
            const SizedBox(height: AlhaiSpacing.lg),

            // Info + Subscription side by side on desktop
            if (isWide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _StoreInfoCard(l10n: l10n, storeId: storeId)),
                  const SizedBox(width: AlhaiSpacing.md),
                  Expanded(child: _SubscriptionCard(l10n: l10n)),
                ],
              )
            else ...[
              _StoreInfoCard(l10n: l10n, storeId: storeId),
              const SizedBox(height: AlhaiSpacing.md),
              _SubscriptionCard(l10n: l10n),
            ],

            const SizedBox(height: AlhaiSpacing.lg),

            // Usage stats
            Text(
              l10n.storeUsageStats,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AlhaiSpacing.md),
            GridView.count(
              crossAxisCount: isWide ? 4 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AlhaiSpacing.md,
              crossAxisSpacing: AlhaiSpacing.md,
              childAspectRatio: 2.0,
              children: [
                _UsageTile(
                  icon: Icons.receipt_long_rounded,
                  label: l10n.storeTransactions,
                  value: '4,520',
                ),
                _UsageTile(
                  icon: Icons.inventory_2_rounded,
                  label: l10n.storeProducts,
                  value: '1,832',
                ),
                _UsageTile(
                  icon: Icons.people_rounded,
                  label: l10n.storeEmployees,
                  value: '12',
                ),
                _UsageTile(
                  icon: Icons.store_rounded,
                  label: l10n.branchCountLabel,
                  value: '3',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StoreInfoCard extends StatelessWidget {
  final AppLocalizations l10n;
  final String storeId;
  const _StoreInfoCard({required this.l10n, required this.storeId});

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
        padding: const EdgeInsets.all(AlhaiSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(Icons.store_rounded,
                      color: theme.colorScheme.primary),
                ),
                const SizedBox(width: AlhaiSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Grocery Plus',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        storeId,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: AlhaiSpacing.xl),
            _InfoRow(label: l10n.storeOwner, value: 'Ahmed Ali'),
            _InfoRow(label: l10n.ownerPhone, value: '+966 50 123 4567'),
            _InfoRow(label: l10n.ownerEmail, value: 'ahmed@grocery.sa'),
            _InfoRow(label: l10n.businessType, value: 'Grocery'),
            _InfoRow(label: l10n.storeCreatedAt, value: '2024-01-15'),
            _InfoRow(label: l10n.branchCountLabel, value: '3'),
          ],
        ),
      ),
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  final AppLocalizations l10n;
  const _SubscriptionCard({required this.l10n});

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
        padding: const EdgeInsets.all(AlhaiSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.subscriptionManagement,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Divider(height: AlhaiSpacing.xl),
            _InfoRow(label: l10n.storePlan, value: 'Professional'),
            _InfoRow(
                label: l10n.monthlyPrice, value: '499 ${l10n.sar}'),
            _InfoRow(label: l10n.storeStatus, value: 'Active'),
            _InfoRow(
                label: 'Renewal', value: '2025-01-15'),
            const SizedBox(height: AlhaiSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: Text(l10n.upgradePlan),
                  ),
                ),
                const SizedBox(width: AlhaiSpacing.sm),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: Text(l10n.downgradePlan),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AlhaiSpacing.sm),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UsageTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _UsageTile({
    required this.icon,
    required this.label,
    required this.value,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 24),
            const Spacer(),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AlhaiSpacing.xxxs),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
