import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../providers/sa_providers.dart';

/// Plans management -- real plan data from Supabase.
class SAPlansScreen extends ConsumerWidget {
  const SAPlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= AlhaiBreakpoints.desktop;

    final plansAsync = ref.watch(saPlansListProvider);
    final subCountsAsync = ref.watch(saSubscriberCountByPlanProvider);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AlhaiSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.plansManagement,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => _showPlanDialog(context, ref),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(l10n.createPlan),
                ),
              ],
            ),
            const SizedBox(height: AlhaiSpacing.lg),

            plansAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (plans) {
                final subCounts = subCountsAsync.valueOrNull ?? {};

                final planColors = {
                  'basic': isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
                  'advanced': isDark ? const Color(0xFFA78BFA) : const Color(0xFF7C3AED),
                  'professional': isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0D9488),
                };

                final planCards = plans.map((plan) {
                  final slug = plan['slug'] as String? ?? '';
                  final name = plan['name'] as String? ?? slug;
                  final monthlyPrice =
                      (plan['monthly_price'] as num?)?.toInt() ?? 0;
                  final yearlyPrice =
                      (plan['yearly_price'] as num?)?.toInt() ??
                          (monthlyPrice * 10);
                  final maxBranches =
                      plan['max_branches'] as int? ?? 0;
                  final maxProducts =
                      plan['max_products'] as int? ?? 0;
                  final maxUsers = plan['max_users'] as int? ?? 0;
                  final features = (plan['features'] as List<dynamic>?)
                          ?.cast<String>() ??
                      [];
                  final subscribers = subCounts[slug] ?? 0;
                  final color = planColors[slug] ?? (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563));

                  return _PlanCard(
                    name: name,
                    monthlyPrice: '$monthlyPrice',
                    yearlyPrice: _fmt(yearlyPrice),
                    maxBranches:
                        maxBranches == 0 ? 'Unlimited' : '$maxBranches',
                    maxProducts:
                        maxProducts == 0 ? 'Unlimited' : _fmt(maxProducts),
                    maxUsers:
                        maxUsers == 0 ? 'Unlimited' : '$maxUsers',
                    color: color,
                    subscribers: subscribers,
                    isPopular: slug == 'advanced',
                    features: features,
                  );
                }).toList();

                if (isWide && planCards.length >= 2) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: planCards.map((card) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsetsDirectional.only(
                              end: AlhaiSpacing.md),
                          child: card,
                        ),
                      );
                    }).toList(),
                  );
                }

                return Column(
                  children: planCards.map((card) {
                    return Padding(
                      padding: const EdgeInsets.only(
                          bottom: AlhaiSpacing.md),
                      child: card,
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(int n) {
    if (n >= 1000) {
      final s = n.toString();
      final buffer = StringBuffer();
      for (int i = 0; i < s.length; i++) {
        if (i > 0 && (s.length - i) % 3 == 0) buffer.write(',');
        buffer.write(s[i]);
      }
      return buffer.toString();
    }
    return n.toString();
  }

  void _showPlanDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final branchCtrl = TextEditingController();
    final productCtrl = TextEditingController();
    final userCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.createPlan),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(labelText: l10n.planName),
              ),
              const SizedBox(height: AlhaiSpacing.md),
              TextField(
                controller: priceCtrl,
                decoration:
                    InputDecoration(labelText: l10n.monthlyPrice),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AlhaiSpacing.md),
              TextField(
                controller: branchCtrl,
                decoration:
                    InputDecoration(labelText: l10n.maxBranches),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AlhaiSpacing.md),
              TextField(
                controller: productCtrl,
                decoration:
                    InputDecoration(labelText: l10n.maxProducts),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AlhaiSpacing.md),
              TextField(
                controller: userCtrl,
                decoration: InputDecoration(labelText: l10n.maxUsers),
                keyboardType: TextInputType.number,
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
              final ds = ref.read(saSubscriptionsDatasourceProvider);
              final name = nameCtrl.text.trim();
              final slug = name.toLowerCase().replaceAll(' ', '_');
              final price =
                  double.tryParse(priceCtrl.text) ?? 0;
              await ds.createPlan(
                name: name,
                slug: slug,
                monthlyPrice: price,
                yearlyPrice: price * 10,
                maxBranches:
                    int.tryParse(branchCtrl.text) ?? 0,
                maxProducts:
                    int.tryParse(productCtrl.text) ?? 0,
                maxUsers: int.tryParse(userCtrl.text) ?? 0,
              );
              ref.invalidate(saPlansListProvider);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(l10n.createPlan),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String name;
  final String monthlyPrice;
  final String yearlyPrice;
  final String maxBranches;
  final String maxProducts;
  final String maxUsers;
  final Color color;
  final int subscribers;
  final bool isPopular;
  final List<String> features;

  const _PlanCard({
    required this.name,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.maxBranches,
    required this.maxProducts,
    required this.maxUsers,
    required this.color,
    required this.subscribers,
    this.isPopular = false,
    required this.features,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AlhaiRadius.card),
        side: BorderSide(
          color: isPopular ? color : theme.colorScheme.outlineVariant,
          width: isPopular ? 2 : AlhaiSpacing.strokeXs,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AlhaiSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AlhaiSpacing.xs),
                Text(
                  name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isPopular) ...[
                  const SizedBox(width: AlhaiSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AlhaiSpacing.xs,
                      vertical: AlhaiSpacing.xxxs,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(AlhaiRadius.chip),
                    ),
                    child: Text(
                      'POPULAR',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AlhaiSpacing.md),

            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  monthlyPrice,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    ' ${l10n.sar}${l10n.perMonth}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              '$yearlyPrice ${l10n.sar}${l10n.perYear}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: AlhaiSpacing.md),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AlhaiSpacing.sm,
                vertical: AlhaiSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AlhaiRadius.sm),
              ),
              child: Text(
                '$subscribers ${l10n.activeSubscriptions}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Divider(height: AlhaiSpacing.xl),

            _LimitRow(label: l10n.maxBranches, value: maxBranches),
            _LimitRow(label: l10n.maxProducts, value: maxProducts),
            _LimitRow(label: l10n.maxUsers, value: maxUsers),

            if (features.isNotEmpty) ...[
              const Divider(height: AlhaiSpacing.xl),
              Text(
                l10n.planFeatures,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AlhaiSpacing.xs),
              ...features.map((f) => Padding(
                    padding:
                        const EdgeInsets.only(bottom: AlhaiSpacing.xxs),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_rounded,
                            size: 16, color: color),
                        const SizedBox(width: AlhaiSpacing.xs),
                        Expanded(
                          child: Text(f,
                              style: theme.textTheme.bodySmall),
                        ),
                      ],
                    ),
                  )),
            ],
            const SizedBox(height: AlhaiSpacing.md),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.edit_rounded, size: 16),
                label: Text(l10n.editPlan),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LimitRow extends StatelessWidget {
  final String label;
  final String value;
  const _LimitRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AlhaiSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
