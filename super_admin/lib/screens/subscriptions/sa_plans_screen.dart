import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

/// Plans management -- create/edit the 3 tiers: Basic, Advanced, Professional.
class SAPlansScreen extends StatelessWidget {
  const SAPlansScreen({super.key});

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
                  onPressed: () => _showPlanDialog(context),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(l10n.createPlan),
                ),
              ],
            ),
            const SizedBox(height: AlhaiSpacing.lg),

            // Plan cards
            if (isWide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _PlanCard(
                      name: l10n.basicPlan,
                      monthlyPrice: '99',
                      yearlyPrice: '990',
                      maxBranches: '1',
                      maxProducts: '500',
                      maxUsers: '3',
                      color: Colors.blue,
                      subscribers: 531,
                      features: const [
                        'POS System',
                        'Basic Reports',
                        'Email Support',
                      ],
                    ),
                  ),
                  const SizedBox(width: AlhaiSpacing.md),
                  Expanded(
                    child: _PlanCard(
                      name: l10n.advancedPlan,
                      monthlyPrice: '249',
                      yearlyPrice: '2,490',
                      maxBranches: '3',
                      maxProducts: '2,000',
                      maxUsers: '10',
                      color: Colors.deepPurple,
                      subscribers: 413,
                      isPopular: true,
                      features: const [
                        'POS System',
                        'Advanced Reports',
                        'Multi-branch',
                        'Inventory Management',
                        'WhatsApp Integration',
                        'Priority Support',
                      ],
                    ),
                  ),
                  const SizedBox(width: AlhaiSpacing.md),
                  Expanded(
                    child: _PlanCard(
                      name: l10n.professionalPlan,
                      monthlyPrice: '499',
                      yearlyPrice: '4,990',
                      maxBranches: 'Unlimited',
                      maxProducts: 'Unlimited',
                      maxUsers: 'Unlimited',
                      color: Colors.teal,
                      subscribers: 236,
                      features: const [
                        'POS System',
                        'AI Analytics',
                        'Unlimited Branches',
                        'E-commerce Integration',
                        'API Access',
                        'ZATCA Compliance',
                        'Dedicated Support',
                      ],
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  _PlanCard(
                    name: l10n.basicPlan,
                    monthlyPrice: '99',
                    yearlyPrice: '990',
                    maxBranches: '1',
                    maxProducts: '500',
                    maxUsers: '3',
                    color: Colors.blue,
                    subscribers: 531,
                    features: const [
                      'POS System',
                      'Basic Reports',
                      'Email Support',
                    ],
                  ),
                  const SizedBox(height: AlhaiSpacing.md),
                  _PlanCard(
                    name: l10n.advancedPlan,
                    monthlyPrice: '249',
                    yearlyPrice: '2,490',
                    maxBranches: '3',
                    maxProducts: '2,000',
                    maxUsers: '10',
                    color: Colors.deepPurple,
                    subscribers: 413,
                    isPopular: true,
                    features: const [
                      'POS System',
                      'Advanced Reports',
                      'Multi-branch',
                      'Inventory Management',
                      'WhatsApp Integration',
                      'Priority Support',
                    ],
                  ),
                  const SizedBox(height: AlhaiSpacing.md),
                  _PlanCard(
                    name: l10n.professionalPlan,
                    monthlyPrice: '499',
                    yearlyPrice: '4,990',
                    maxBranches: 'Unlimited',
                    maxProducts: 'Unlimited',
                    maxUsers: 'Unlimited',
                    color: Colors.teal,
                    subscribers: 236,
                    features: const [
                      'POS System',
                      'AI Analytics',
                      'Unlimited Branches',
                      'E-commerce Integration',
                      'API Access',
                      'ZATCA Compliance',
                      'Dedicated Support',
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _showPlanDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
                decoration: InputDecoration(labelText: l10n.planName),
              ),
              const SizedBox(height: AlhaiSpacing.md),
              TextField(
                decoration: InputDecoration(labelText: l10n.monthlyPrice),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AlhaiSpacing.md),
              TextField(
                decoration: InputDecoration(labelText: l10n.maxBranches),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AlhaiSpacing.md),
              TextField(
                decoration: InputDecoration(labelText: l10n.maxProducts),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AlhaiSpacing.md),
              TextField(
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
            onPressed: () => Navigator.pop(ctx),
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
            // Header
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
                      style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AlhaiSpacing.md),

            // Price
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

            // Subscribers count
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

            // Limits
            _LimitRow(
              label: l10n.maxBranches,
              value: maxBranches,
            ),
            _LimitRow(
              label: l10n.maxProducts,
              value: maxProducts,
            ),
            _LimitRow(label: l10n.maxUsers, value: maxUsers),
            const Divider(height: AlhaiSpacing.xl),

            // Features
            Text(
              l10n.planFeatures,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AlhaiSpacing.xs),
            ...features.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: AlhaiSpacing.xxs),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_rounded,
                          size: 16, color: color),
                      const SizedBox(width: AlhaiSpacing.xs),
                      Expanded(
                        child: Text(
                          f,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: AlhaiSpacing.md),

            // Edit button
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
