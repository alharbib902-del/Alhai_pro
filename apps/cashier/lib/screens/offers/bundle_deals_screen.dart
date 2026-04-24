/// Bundle Deals Screen - Read-only list of active bundles
///
/// List of active bundle deals with included products, bundle price
/// vs individual total, savings amount. Read-only for cashier.
/// Supports: RTL Arabic, dark/light theme, responsive layout.
library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_design_system/alhai_design_system.dart'
    show AlhaiBreakpoints, AlhaiSpacing;
// alhai_design_system is re-exported via alhai_shared_ui
import '../../core/services/sentry_service.dart';

/// شاشة عروض الباقات
class BundleDealsScreen extends ConsumerStatefulWidget {
  const BundleDealsScreen({super.key});

  @override
  ConsumerState<BundleDealsScreen> createState() => _BundleDealsScreenState();
}

class _BundleDealsScreenState extends ConsumerState<BundleDealsScreen> {
  final _db = GetIt.I<AppDatabase>();

  List<DiscountsTableData> _bundles = [];
  // Bundle-id → resolved product rows (looked up via productIds JSON on
  // the discount). Missing / mis-parsed ids simply drop from the list
  // rather than rendering a bogus label.
  final Map<String, List<ProductsTableData>> _bundleProducts = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBundles();
  }

  Future<void> _loadBundles() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;
      final discounts = await _db.discountsDao.getActiveDiscounts(storeId);
      final filtered = discounts
          .where((d) => d.type == 'bundle' || d.type == 'buy_x_get_y')
          .toList();

      // Resolve the JSON-encoded productIds on each bundle into real
      // product rows so the UI can render actual names + prices.
      // Silently skip unparseable entries — a bad JSON blob on one
      // bundle must not blank the screen.
      final resolved = <String, List<ProductsTableData>>{};
      for (final bundle in filtered) {
        final raw = bundle.productIds;
        if (raw == null || raw.isEmpty) continue;
        List<String> ids = const [];
        try {
          final decoded = jsonDecode(raw);
          if (decoded is List) {
            ids = decoded.whereType<String>().toList();
          }
        } catch (_) {
          continue;
        }
        if (ids.isEmpty) continue;
        final products = <ProductsTableData>[];
        for (final id in ids) {
          final p = await _db.productsDao.getProductById(id);
          if (p != null) products.add(p);
        }
        if (products.isNotEmpty) resolved[bundle.id] = products;
      }

      if (mounted) {
        setState(() {
          _bundles = filtered;
          _bundleProducts
            ..clear()
            ..addAll(resolved);
          _isLoading = false;
        });
      }
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Load bundle deals');
      if (mounted) {
        setState(() {
          _error = '$e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width >= AlhaiBreakpoints.desktop;
    final isMediumScreen = size.width >= AlhaiBreakpoints.tablet;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider);

    return Column(
      children: [
        AppHeader(
          title: l10n.bundleDeals,
          subtitle:
              '${_bundles.length} ${l10n.activeOffers} \u2022 ${l10n.mainBranch}',
          showSearch: false,
          searchHint: l10n.searchPlaceholder,
          onMenuTap: isWideScreen
              ? null
              : () => Scaffold.of(context).openDrawer(),
          onNotificationsTap: () => context.push('/notifications'),
          notificationsCount: 3,
          userName: user?.name ?? l10n.cashCustomer,
          userRole: l10n.branchManager,
          onUserTap: () {},
        ),
        Expanded(
          child: _isLoading
              ? const AppLoadingState()
              : _error != null
              ? AppErrorState.general(
                  context,
                  message: _error!,
                  onRetry: _loadBundles,
                )
              : _bundles.isEmpty
              ? _buildEmptyState(isDark, l10n)
              : _buildBundlesList(isMediumScreen, isDark, l10n),
        ),
      ],
    );
  }

  Widget _buildBundlesList(
    bool isMediumScreen,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return RefreshIndicator(
      onRefresh: _loadBundles,
      child: ListView.separated(
        padding: EdgeInsets.all(
          isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md,
        ),
        itemCount: _bundles.length,
        separatorBuilder: (_, __) => const SizedBox(height: AlhaiSpacing.md),
        itemBuilder: (context, index) =>
            _buildBundleCard(_bundles[index], index, isDark, l10n),
      ),
    );
  }

  Widget _buildBundleCard(
    DiscountsTableData bundle,
    int index,
    bool isDark,
    AppLocalizations l10n,
  ) {
    // C-4 Stage A migrated money to int cents; divide by 100 to
    // display SAR. `value` is the bundle sale price (int cents).
    final double bundlePriceSar = bundle.value / 100.0;
    final products = _bundleProducts[bundle.id] ?? const <ProductsTableData>[];

    // Compute the honest individualTotal by summing member product
    // prices — the old code multiplied the bundle by 1.4, which
    // literally invented a discount percentage. If we can't resolve
    // the member products we suppress the comparison rather than
    // fabricating numbers.
    double individualTotalSar = 0.0;
    for (final p in products) {
      individualTotalSar += p.price / 100.0;
    }
    final bool hasValidComparison =
        products.isNotEmpty && individualTotalSar > bundlePriceSar;
    final double savings =
        hasValidComparison ? individualTotalSar - bundlePriceSar : 0.0;
    final String savingsPercent = hasValidComparison
        ? (savings / individualTotalSar * 100).toStringAsFixed(0)
        : '0';

    final colors = [
      AppColors.info,
      AppColors.purple,
      AppColors.secondary,
      AppColors.cyan,
      AppColors.success,
      AppColors.pink,
    ];
    final color = colors[index % colors.length];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header with gradient
          Container(
            padding: const EdgeInsets.all(AlhaiSpacing.mdl),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: isDark ? 0.2 : 0.1),
                  color.withValues(alpha: isDark ? 0.08 : 0.03),
                ],
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    bundle.type == 'buy_x_get_y'
                        ? Icons.card_giftcard_rounded
                        : Icons.inventory_2_rounded,
                    color: color,
                    size: 26,
                  ),
                ),
                const SizedBox(width: AlhaiSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bundle.name,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.getTextPrimary(isDark),
                        ),
                      ),
                      const SizedBox(height: AlhaiSpacing.xxs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AlhaiSpacing.xs,
                          vertical: AlhaiSpacing.xxxs,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          bundle.type == 'buy_x_get_y'
                              ? l10n.buyXGetY
                              : l10n.bundle,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Savings badge — only render when we have a real
                // comparison. Showing "save 0%" or "save NaN" when
                // products can't be resolved is worse than silence.
                if (hasValidComparison)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AlhaiSpacing.sm,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Column(
                      children: [
                        Text(
                          l10n.save,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: AppColors.success,
                          ),
                        ),
                        Text(
                          '$savingsPercent%',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          // Bundle contents
          Padding(
            padding: const EdgeInsets.all(AlhaiSpacing.mdl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.includedProducts,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.getTextSecondary(isDark),
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.sm),
                // Real bundle members — resolved from productIds JSON in
                // _loadBundles. When resolution fails (bad JSON, missing
                // products) we show a terse hint instead of fake rows.
                if (products.isEmpty)
                  Text(
                    l10n.comingSoon,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.getTextMuted(isDark),
                    ),
                  )
                else ...[
                  for (int i = 0; i < products.length; i++) ...[
                    _buildBundleProductRow(products[i], isDark),
                    if (i < products.length - 1) const SizedBox(height: 6),
                  ],
                ],
                const SizedBox(height: AlhaiSpacing.md),
                // Price comparison — only when we actually computed a
                // truthful individualTotal. Otherwise fall back to just
                // showing the bundle price so we never lie to the user.
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.getSurfaceVariant(isDark),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      if (hasValidComparison) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.individualTotal,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.getTextSecondary(isDark),
                              ),
                            ),
                            Text(
                              '${individualTotalSar.toStringAsFixed(2)} ${l10n.sar}',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.getTextSecondary(isDark),
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AlhaiSpacing.xs),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.bundlePrice,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.getTextPrimary(isDark),
                            ),
                          ),
                          Text(
                            '${bundlePriceSar.toStringAsFixed(2)} ${l10n.sar}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      if (hasValidComparison) ...[
                        Divider(height: 20, color: AppColors.getBorder(isDark)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.youSave,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.success,
                              ),
                            ),
                            Text(
                              '${savings.toStringAsFixed(2)} ${l10n.sar}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                // Validity
                if (bundle.endDate != null) ...[
                  const SizedBox(height: AlhaiSpacing.sm),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 14,
                        color: AppColors.getTextMuted(isDark),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l10n.validUntilDate(
                          '${bundle.endDate!.day}/${bundle.endDate!.month}/${bundle.endDate!.year}',
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.getTextMuted(isDark),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBundleProductRow(ProductsTableData product, bool isDark) {
    final priceSar = (product.price / 100.0).toStringAsFixed(2);
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            product.name,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
        ),
        Text(
          priceSar,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.getTextSecondary(isDark),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: AppColors.getTextMuted(isDark).withValues(alpha: 0.4),
          ),
          const SizedBox(height: AlhaiSpacing.md),
          Text(
            l10n.noBundleDeals,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.getTextMuted(isDark),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xs),
          Text(
            l10n.bundleDealsWillAppear,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.getTextMuted(isDark),
            ),
          ),
        ],
      ),
    );
  }
}
