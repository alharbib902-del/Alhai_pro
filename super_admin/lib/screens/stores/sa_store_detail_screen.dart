import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../providers/sa_providers.dart';

/// Store detail screen: real store info, subscription, usage stats from Supabase.
class SAStoreDetailScreen extends ConsumerWidget {
  final String storeId;
  const SAStoreDetailScreen({super.key, required this.storeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= AlhaiBreakpoints.desktop;

    final storeAsync = ref.watch(saStoreDetailProvider(storeId));
    final usageAsync = ref.watch(saStoreUsageStatsProvider(storeId));
    final ownerAsync = ref.watch(saStoreOwnerProvider(storeId));

    return Scaffold(
      body: storeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (store) {
          final name = store.name.isEmpty ? 'Unnamed' : store.name;
          final email = store.email ?? '-';
          final phone = store.phone ?? '-';
          final businessType = store.businessType ?? '-';
          final createdAt = store.createdAt ?? '';
          final dateStr =
              createdAt.length >= 10 ? createdAt.substring(0, 10) : createdAt;

          // Extract subscription info
          String planName = '-';
          String planPrice = '-';
          String subStatus = store.isActive ? 'Active' : 'Suspended';
          String renewal = '-';
          if (store.subscriptions.isNotEmpty) {
            final sub = store.subscriptions.first;
            planName = sub.planName ?? '-';
            final price = sub.plan?.monthlyPrice?.toInt() ?? 0;
            planPrice = '$price ${l10n.sar}';
            final rawStatus = sub.status ?? subStatus;
            subStatus = rawStatus.isNotEmpty
                ? rawStatus[0].toUpperCase() + rawStatus.substring(1)
                : subStatus;
            renewal = sub.endDate ?? '-';
            if (renewal.length >= 10) renewal = renewal.substring(0, 10);
          }

          // Owner info
          final owner = ownerAsync.valueOrNull;
          final ownerName = owner?.name ?? '-';
          final ownerPhone = owner?.phone ?? phone;
          final ownerEmail = owner?.email ?? email;

          return SingleChildScrollView(
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
                        '${l10n.storeDetail} - $name',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => context.go('/stores/$storeId/settings'),
                      icon: const Icon(Icons.settings_rounded, size: 18),
                      label: Text(l10n.storeSettings),
                    ),
                  ],
                ),
                const SizedBox(height: AlhaiSpacing.lg),

                // Info + Subscription
                if (isWide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _StoreInfoCard(
                          l10n: l10n,
                          name: name,
                          storeId: storeId,
                          ownerName: ownerName,
                          ownerPhone: ownerPhone,
                          ownerEmail: ownerEmail,
                          businessType: businessType,
                          createdAt: dateStr,
                        ),
                      ),
                      const SizedBox(width: AlhaiSpacing.md),
                      Expanded(
                        child: _SubscriptionCard(
                          l10n: l10n,
                          planName: planName,
                          planPrice: planPrice,
                          status: subStatus,
                          renewal: renewal,
                          onUpgrade: () => _showChangePlanDialog(
                            context,
                            ref,
                            storeId,
                            store.subscriptions.isNotEmpty
                                ? store.subscriptions.first.planSlug
                                : null,
                            isUpgrade: true,
                          ),
                          onDowngrade: () => _showChangePlanDialog(
                            context,
                            ref,
                            storeId,
                            store.subscriptions.isNotEmpty
                                ? store.subscriptions.first.planSlug
                                : null,
                            isUpgrade: false,
                          ),
                        ),
                      ),
                    ],
                  )
                else ...[
                  _StoreInfoCard(
                    l10n: l10n,
                    name: name,
                    storeId: storeId,
                    ownerName: ownerName,
                    ownerPhone: ownerPhone,
                    ownerEmail: ownerEmail,
                    businessType: businessType,
                    createdAt: dateStr,
                  ),
                  const SizedBox(height: AlhaiSpacing.md),
                  _SubscriptionCard(
                    l10n: l10n,
                    planName: planName,
                    planPrice: planPrice,
                    status: subStatus,
                    renewal: renewal,
                    onUpgrade: () => _showChangePlanDialog(
                      context,
                      ref,
                      storeId,
                      store.subscriptions.isNotEmpty
                          ? store.subscriptions.first.planSlug
                          : null,
                      isUpgrade: true,
                    ),
                    onDowngrade: () => _showChangePlanDialog(
                      context,
                      ref,
                      storeId,
                      store.subscriptions.isNotEmpty
                          ? store.subscriptions.first.planSlug
                          : null,
                      isUpgrade: false,
                    ),
                  ),
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
                usageAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error: $e'),
                  data: (usage) {
                    return GridView.count(
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
                          value: '${usage.transactions}',
                        ),
                        _UsageTile(
                          icon: Icons.inventory_2_rounded,
                          label: l10n.storeProducts,
                          value: '${usage.products}',
                        ),
                        _UsageTile(
                          icon: Icons.people_rounded,
                          label: l10n.storeEmployees,
                          value: '${usage.employees}',
                        ),
                        _UsageTile(
                          icon: Icons.store_rounded,
                          label: l10n.branchCountLabel,
                          value: '${usage.branches}',
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showChangePlanDialog(
    BuildContext context,
    WidgetRef ref,
    String storeId,
    String? currentPlanSlug, {
    required bool isUpgrade,
  }) {
    final l10n = AppLocalizations.of(context);
    final plansAsync = ref.read(saPlansListProvider);
    final plans = plansAsync.valueOrNull ?? [];

    if (plans.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.noPlansAvailable)),
      );
      return;
    }

    // Filter plans based on upgrade/downgrade relative to current plan
    final currentIndex = plans.indexWhere((p) => p.slug == currentPlanSlug);
    final availablePlans = plans.where((p) {
      if (p.slug == currentPlanSlug) return false;
      if (currentIndex < 0) return true;
      final idx = plans.indexOf(p);
      return isUpgrade ? idx > currentIndex : idx < currentIndex;
    }).toList();

    if (availablePlans.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              isUpgrade ? l10n.alreadyOnHighestPlan : l10n.alreadyOnLowestPlan),
        ),
      );
      return;
    }

    String? selectedSlug = availablePlans.first.slug;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(isUpgrade ? l10n.upgradePlan : l10n.downgradePlan),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l10n.currentPlan}: ${currentPlanSlug?.replaceAll('_', ' ') ?? '-'}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AlhaiSpacing.md),
                DropdownButtonFormField<String>(
                  value: selectedSlug,
                  decoration: InputDecoration(
                    labelText: l10n.selectPlan,
                    border: const OutlineInputBorder(),
                  ),
                  items: availablePlans.map((p) {
                    final price = p.monthlyPrice?.toStringAsFixed(0) ?? '0';
                    return DropdownMenuItem(
                      value: p.slug,
                      child: Text(
                          '${p.name ?? p.slug} - $price ${l10n.sar}${l10n.perMonth}'),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => selectedSlug = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () async {
                if (selectedSlug == null) return;
                final ds = ref.read(saStoresDatasourceProvider);
                await ds.updateStorePlan(storeId, selectedSlug!);
                ref.invalidate(saStoreDetailProvider(storeId));
                ref.invalidate(saStoresListProvider);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Text(l10n.confirm),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoreInfoCard extends StatelessWidget {
  final AppLocalizations l10n;
  final String name;
  final String storeId;
  final String ownerName;
  final String ownerPhone;
  final String ownerEmail;
  final String businessType;
  final String createdAt;

  const _StoreInfoCard({
    required this.l10n,
    required this.name,
    required this.storeId,
    required this.ownerName,
    required this.ownerPhone,
    required this.ownerEmail,
    required this.businessType,
    required this.createdAt,
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
                        name,
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
            _InfoRow(label: l10n.storeOwner, value: ownerName),
            _InfoRow(label: l10n.ownerPhone, value: ownerPhone),
            _InfoRow(label: l10n.ownerEmail, value: ownerEmail),
            _InfoRow(label: l10n.businessType, value: businessType),
            _InfoRow(label: l10n.storeCreatedAt, value: createdAt),
          ],
        ),
      ),
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  final AppLocalizations l10n;
  final String planName;
  final String planPrice;
  final String status;
  final String renewal;
  final VoidCallback? onUpgrade;
  final VoidCallback? onDowngrade;

  const _SubscriptionCard({
    required this.l10n,
    required this.planName,
    required this.planPrice,
    required this.status,
    required this.renewal,
    this.onUpgrade,
    this.onDowngrade,
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
            _InfoRow(label: l10n.storePlan, value: planName),
            _InfoRow(label: l10n.monthlyPrice, value: planPrice),
            _InfoRow(label: l10n.storeStatus, value: status),
            _InfoRow(label: 'Renewal', value: renewal),
            const SizedBox(height: AlhaiSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onUpgrade,
                    child: Text(l10n.upgradePlan),
                  ),
                ),
                const SizedBox(width: AlhaiSpacing.sm),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDowngrade,
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
