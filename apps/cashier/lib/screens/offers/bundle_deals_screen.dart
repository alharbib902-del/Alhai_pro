/// Bundle Deals Screen - Read-only list of active bundles
///
/// List of active bundle deals with included products, bundle price
/// vs individual total, savings amount. Read-only for cashier.
/// Supports: RTL Arabic, dark/light theme, responsive layout.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
// alhai_design_system is re-exported via alhai_shared_ui
import '../../core/services/sentry_service.dart';

/// شاشة عروض الباقات
class BundleDealsScreen extends ConsumerStatefulWidget {
  const BundleDealsScreen({super.key});

  @override
  ConsumerState<BundleDealsScreen> createState() =>
      _BundleDealsScreenState();
}

class _BundleDealsScreenState extends ConsumerState<BundleDealsScreen> {
  final _db = GetIt.I<AppDatabase>();

  List<DiscountsTableData> _bundles = [];
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
      if (mounted) {
        setState(() {
          _bundles = discounts
              .where((d) => d.type == 'bundle' || d.type == 'buy_x_get_y')
              .toList();
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
    final isWideScreen = size.width > 900;
    final isMediumScreen = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider);

    return Column(
      children: [
        AppHeader(
          title: 'Bundle Deals',
          subtitle: '${_bundles.length} ${l10n.activeOffers} \u2022 ${l10n.mainBranch}',
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
                  ? AppErrorState.general(message: _error!, onRetry: _loadBundles)
                  : _bundles.isEmpty
                      ? _buildEmptyState(isDark, l10n)
                      : _buildBundlesList(isMediumScreen, isDark, l10n),
        ),
      ],
    );
  }

  Widget _buildBundlesList(
      bool isMediumScreen, bool isDark, AppLocalizations l10n) {
    return RefreshIndicator(
      onRefresh: _loadBundles,
      child: ListView.separated(
        padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
        itemCount: _bundles.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) =>
            _buildBundleCard(_bundles[index], index, isDark, l10n),
      ),
    );
  }

  Widget _buildBundleCard(
      DiscountsTableData bundle, int index, bool isDark, AppLocalizations l10n) {
    // Simulate bundle product details
    final bundlePrice = bundle.value;
    final individualTotal = bundlePrice * 1.4; // Simulate higher individual price
    final savings = individualTotal - bundlePrice;
    final savingsPercent = (savings / individualTotal * 100).toStringAsFixed(0);

    final colors = [
      const Color(0xFF3B82F6),
      const Color(0xFF8B5CF6),
      const Color(0xFFF97316),
      const Color(0xFF06B6D4),
      AppColors.success,
      const Color(0xFFEC4899),
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
            padding: const EdgeInsets.all(20),
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
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(bundle.name,
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700,
                              color: AppColors.getTextPrimary(isDark))),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          bundle.type == 'buy_x_get_y'
                              ? l10n.buyXGetY
                              : l10n.bundle,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                              color: color),
                        ),
                      ),
                    ],
                  ),
                ),
                // Savings badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Column(
                    children: [
                      Text(l10n.save,
                          style: const TextStyle(fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: AppColors.success)),
                      Text('$savingsPercent%',
                          style: const TextStyle(fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.success)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Bundle contents
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Included Products',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                        color: AppColors.getTextSecondary(isDark))),
                const SizedBox(height: 12),
                // Simulated products in bundle
                _buildBundleProduct(l10n.product, 1, isDark),
                const SizedBox(height: 6),
                _buildBundleProduct(l10n.product, 2, isDark),
                const SizedBox(height: 6),
                _buildBundleProduct(l10n.product, 3, isDark),
                const SizedBox(height: 16),
                // Price comparison
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.getSurfaceVariant(isDark),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Individual Total',
                              style: TextStyle(fontSize: 13,
                                  color: AppColors.getTextSecondary(isDark))),
                          Text(
                            '${individualTotal.toStringAsFixed(0)} ${l10n.sar}',
                            style: TextStyle(fontSize: 14,
                                color: AppColors.getTextSecondary(isDark),
                                decoration: TextDecoration.lineThrough),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Bundle Price',
                              style: TextStyle(fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.getTextPrimary(isDark))),
                          Text(
                            '${bundlePrice.toStringAsFixed(0)} ${l10n.sar}',
                            style: const TextStyle(fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary),
                          ),
                        ],
                      ),
                      Divider(height: 20, color: AppColors.getBorder(isDark)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('You Save',
                              style: TextStyle(fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.success)),
                          Text(
                            '${savings.toStringAsFixed(0)} ${l10n.sar}',
                            style: const TextStyle(fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.success),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Validity
                if (bundle.endDate != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.schedule_rounded, size: 14,
                          color: AppColors.getTextMuted(isDark)),
                      const SizedBox(width: 6),
                      Text(
                        'Valid Until: ${bundle.endDate!.day}/${bundle.endDate!.month}/${bundle.endDate!.year}',
                        style: TextStyle(fontSize: 12,
                            color: AppColors.getTextMuted(isDark)),
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

  Widget _buildBundleProduct(String baseLabel, int index, bool isDark) {
    return Row(
      children: [
        Container(
          width: 6, height: 6,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text('$baseLabel $index',
              style: TextStyle(fontSize: 13,
                  color: AppColors.getTextPrimary(isDark))),
        ),
        Text('x1',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                color: AppColors.getTextSecondary(isDark))),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64,
              color: AppColors.getTextMuted(isDark).withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text('No bundle deals',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500,
                  color: AppColors.getTextMuted(isDark))),
          const SizedBox(height: 8),
          Text('Bundle deals will appear here',
              style: TextStyle(fontSize: 13,
                  color: AppColors.getTextMuted(isDark))),
        ],
      ),
    );
  }
}
