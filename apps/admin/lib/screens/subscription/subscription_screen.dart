import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:alhai_core/alhai_core.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

/// Subscription management screen showing current plan, usage, and available plans.
class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  bool _isLoading = true;
  String? _error;
  OrganizationsTableData? _organization;
  SubscriptionsTableData? _subscription;
  int _storesCount = 0;
  int _usersCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final db = getIt<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) {
        setState(() {
          _isLoading = false;
          _error = 'No store selected';
        });
        return;
      }

      // Try to get organization ID from settings
      final orgRow =
          await (db.select(db.settingsTable)..where(
                (s) =>
                    s.storeId.equals(storeId) & s.key.equals('organization_id'),
              ))
              .getSingleOrNull();
      final orgId = orgRow?.value;

      OrganizationsTableData? org;
      SubscriptionsTableData? sub;

      if (orgId != null) {
        org = await db.organizationsDao.getOrganizationById(orgId);
        sub = await db.organizationsDao.getActiveSubscription(orgId);
        sub ??= await db.organizationsDao.getSubscription(orgId);
      }

      // Get usage stats
      final stores = await db.storesDao.getAllStores();
      final users = await db.usersDao.getAllUsers(storeId);

      if (mounted) {
        setState(() {
          _organization = org;
          _subscription = sub;
          _storesCount = stores.length;
          _usersCount = users.length;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Error loading subscription data: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        AppHeader(
          title: l10n.subscription,
          onMenuTap: isWide ? null : () => Scaffold.of(context).openDrawer(),
          onNotificationsTap: () => smartNotificationsPush(context, ref, lowStockRoute: AppRoutes.inventoryAlerts),
          notificationsCount: 0,
          userName: l10n.defaultUserName,
          userRole: l10n.branchManager,
        ),
        Expanded(child: _buildBody(isDark, l10n)),
      ],
    );
  }

  Widget _buildBody(bool isDark, AppLocalizations l10n) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error.withValues(alpha: 0.7),
            ),
            const SizedBox(height: AlhaiSpacing.md),
            Text(
              _error!,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AlhaiSpacing.md),
            FilledButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current plan card
          _buildCurrentPlanCard(isDark),
          const SizedBox(height: AlhaiSpacing.lg),
          // Usage stats
          _buildUsageStats(isDark, l10n),
          const SizedBox(height: AlhaiSpacing.lg),
          // Features list
          if (_subscription != null) ...[
            _buildFeaturesSection(isDark),
            const SizedBox(height: AlhaiSpacing.lg),
          ],
          Text(
            'Available Plans',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.md),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossCount = constraints.maxWidth > 800
                  ? 4
                  : (constraints.maxWidth > 500 ? 2 : 1);
              final plans = [
                (
                  'Free',
                  '0',
                  ['10 products', '1 branch', '1 employee', 'Basic reports'],
                  false,
                ),
                (
                  'Basic',
                  '99',
                  [
                    '100 products',
                    '3 branches',
                    '5 employees',
                    'Advanced reports',
                    'Email support',
                  ],
                  false,
                ),
                (
                  'Professional',
                  '199',
                  [
                    'Unlimited products',
                    '10 branches',
                    '20 employees',
                    'All reports',
                    'Live support',
                    'AI features',
                  ],
                  true,
                ),
                (
                  'Enterprise',
                  '499',
                  [
                    'Everything unlimited',
                    'Unlimited branches',
                    'Unlimited employees',
                    'Advanced API',
                    'Dedicated manager',
                    'Full customization',
                  ],
                  false,
                ),
              ];
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemCount: plans.length,
                itemBuilder: (context, index) {
                  final plan = plans[index];
                  return _buildPlanCard(
                    plan.$1,
                    plan.$2,
                    plan.$3,
                    plan.$4,
                    isDark,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPlanCard(bool isDark) {
    if (_subscription == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AlhaiSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.outlineVariant,
              Theme.of(context).colorScheme.outline,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Current Plan',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'No Subscription',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AlhaiSpacing.md),
            const Text(
              'No active subscription',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AlhaiSpacing.xs),
            const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white70, size: 18),
                SizedBox(width: 6),
                Text(
                  'Choose a plan to get started',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      );
    }

    final sub = _subscription!;
    final planName = sub.plan;
    final status = sub.status;
    final isActive = status == 'active';
    final endDate = sub.currentPeriodEnd;
    final startDate = sub.currentPeriodStart;
    final price = sub.amount;
    final currency = sub.currency == 'SAR' ? 'SAR' : sub.currency;

    // Calculate remaining days
    final totalDays = endDate.difference(startDate).inDays;
    int remainingDays = endDate.difference(DateTime.now()).inDays;
    if (remainingDays < 0) remainingDays = 0;
    double progress = 0.0;
    if (totalDays > 0) {
      progress = 1.0 - (remainingDays / totalDays);
      if (progress < 0) progress = 0;
      if (progress > 1) progress = 1;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AlhaiSpacing.lg),
      decoration: BoxDecoration(
        gradient: AppColors.getPrimaryGradient(isDark),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Current Plan',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isActive ? 'Active' : status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.md),
          Text(
            planName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (price > 0) ...[
            const SizedBox(height: AlhaiSpacing.xxs),
            Text(
              '${price.toStringAsFixed(0)} $currency / month',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
          const SizedBox(height: AlhaiSpacing.xs),
          Row(
            children: [
              const Icon(Icons.timer_outlined, color: Colors.white70, size: 18),
              const SizedBox(width: 6),
              Text(
                '$remainingDays days remaining',
                style: TextStyle(
                  color: remainingDays <= 7
                      ? Colors.orange.shade200
                      : Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.md),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white24,
            color: remainingDays <= 7
                ? Colors.orange.shade300
                : Colors.greenAccent,
            minHeight: 6,
          ),
          const SizedBox(height: AlhaiSpacing.sm),
          Row(
            children: [
              Text(
                'From: ${_formatDate(startDate)}',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(width: AlhaiSpacing.md),
              Text(
                'To: ${_formatDate(endDate)}',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsageStats(bool isDark, AppLocalizations l10n) {
    final maxStores = _organization?.maxStores;
    final maxUsers = _organization?.maxUsers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Usage Statistics',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AlhaiSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _buildUsageTile(
                'Branches',
                '$_storesCount',
                maxStores != null ? 'of $maxStores' : 'Unlimited',
                Icons.store_outlined,
                maxStores != null && _storesCount >= maxStores
                    ? AppColors.error
                    : AppColors.info,
                isDark,
              ),
            ),
            const SizedBox(width: AlhaiSpacing.sm),
            Expanded(
              child: _buildUsageTile(
                'Employees',
                '$_usersCount',
                maxUsers != null ? 'of $maxUsers' : 'Unlimited',
                Icons.people_outlined,
                maxUsers != null && _usersCount >= maxUsers
                    ? AppColors.error
                    : AppColors.success,
                isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUsageTile(
    String title,
    String value,
    String limit,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  limit,
                  style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.sm),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xxs),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(bool isDark) {
    final featuresRaw = _subscription?.features ?? '';
    List<String> features = [];
    if (featuresRaw.isNotEmpty && featuresRaw != '{}') {
      if (featuresRaw.startsWith('[')) {
        features = featuresRaw
            .replaceAll('[', '')
            .replaceAll(']', '')
            .replaceAll('"', '')
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
      } else {
        features = featuresRaw
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
      }
    }

    if (features.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Subscription Features',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AlhaiSpacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AlhaiSpacing.md),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            children: features
                .map(
                  (f) => Padding(
                    padding: const EdgeInsets.only(bottom: AlhaiSpacing.xs),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                          size: 18,
                        ),
                        const SizedBox(width: AlhaiSpacing.xs),
                        Expanded(
                          child: Text(
                            f,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard(
    String name,
    String price,
    List<String> features,
    bool isPopular,
    bool isDark,
  ) {
    final isCurrentPlan =
        _subscription?.plan.toLowerCase() == name.toLowerCase();

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPopular
              ? AppColors.primary
              : (isCurrentPlan
                    ? AppColors.success
                    : (Theme.of(context).dividerColor)),
          width: isPopular || isCurrentPlan ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isPopular)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              margin: const EdgeInsets.only(bottom: AlhaiSpacing.xs),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Most Popular',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (isCurrentPlan)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              margin: const EdgeInsets.only(bottom: AlhaiSpacing.xs),
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Current Plan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Text(
            name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xxs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.xxs),
              Text(
                '/month',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.sm),
          ...features.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      f,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isCurrentPlan
                  ? null
                  : () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(
                            AppLocalizations.of(ctx).upgradeToPlan(name),
                          ),
                          content: Text(
                            AppLocalizations.of(
                              ctx,
                            ).upgradePlanPriceBody(price),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: Text(AppLocalizations.of(ctx).cancel),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      AppLocalizations.of(
                                        context,
                                      ).upgradeContactMsg,
                                    ),
                                  ),
                                );
                              },
                              child: Text(AppLocalizations.of(ctx).confirm),
                            ),
                          ],
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: isCurrentPlan
                    ? Theme.of(context).colorScheme.outline
                    : (isPopular
                          ? AppColors.primary
                          : Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest),
                foregroundColor: isCurrentPlan
                    ? Colors.white
                    : (isPopular
                          ? Colors.white
                          : (Theme.of(context).colorScheme.onSurface)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(isCurrentPlan ? 'Current Plan' : 'Select'),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }
}
