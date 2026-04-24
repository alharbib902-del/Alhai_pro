/// Active Offers Screen - Read-only list of current promotions
///
/// List of active offers/promotions with type, validity dates,
/// auto-applied indicator. Read-only for cashier.
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
import 'package:alhai_design_system/alhai_design_system.dart'
    show AlhaiBreakpoints, AlhaiSpacing;
// alhai_design_system is re-exported via alhai_shared_ui
import '../../core/services/sentry_service.dart';

/// شاشة العروض النشطة
class ActiveOffersScreen extends ConsumerStatefulWidget {
  const ActiveOffersScreen({super.key});

  @override
  ConsumerState<ActiveOffersScreen> createState() => _ActiveOffersScreenState();
}

class _ActiveOffersScreenState extends ConsumerState<ActiveOffersScreen> {
  final _db = GetIt.I<AppDatabase>();

  List<DiscountsTableData> _offers = [];
  bool _isLoading = true;
  String? _error;
  String _filterType = 'all';

  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;
      final discounts = await _db.discountsDao.getActiveDiscounts(storeId);
      // P2: DAO returns every offer flagged active, including ones whose
      // endDate has already passed (legacy rows that weren't deactivated
      // on schedule). Filter them out client-side so the cashier never
      // sees an expired "active" offer. A null endDate means the offer
      // never expires and is kept.
      final now = DateTime.now();
      final fresh = discounts
          .where((d) => d.endDate == null || d.endDate!.isAfter(now))
          .toList();
      if (mounted) {
        setState(() {
          _offers = fresh;
          _isLoading = false;
        });
      }
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Load active offers');
      if (mounted) {
        setState(() {
          _error = '$e';
          _isLoading = false;
        });
      }
    }
  }

  List<DiscountsTableData> get _filteredOffers {
    if (_filterType == 'all') return _offers;
    return _offers.where((o) => o.type == _filterType).toList();
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
          title: l10n.activeOffers,
          subtitle:
              '${_offers.length} ${l10n.activeOffers} \u2022 ${l10n.mainBranch}',
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
                  onRetry: _loadOffers,
                )
              : Column(
                  children: [
                    // Filter chips
                    Padding(
                      padding: EdgeInsets.all(
                        isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md,
                      ),
                      child: _buildFilterChips(isDark, l10n),
                    ),
                    // Offers list
                    Expanded(
                      child: _filteredOffers.isEmpty
                          ? _buildEmptyState(isDark, l10n)
                          : ListView.separated(
                              padding: EdgeInsets.symmetric(
                                horizontal: isMediumScreen ? 24 : 16,
                                vertical: AlhaiSpacing.xs,
                              ),
                              itemCount: _filteredOffers.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: AlhaiSpacing.sm),
                              itemBuilder: (context, index) => _buildOfferCard(
                                _filteredOffers[index],
                                isDark,
                                l10n,
                              ),
                            ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChips(bool isDark, AppLocalizations l10n) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip(
            l10n.allPeriods,
            _filterType == 'all',
            () => setState(() => _filterType = 'all'),
            isDark,
          ),
          const SizedBox(width: AlhaiSpacing.xs),
          _buildChip(
            l10n.percentageOff,
            _filterType == 'percentage',
            () => setState(() => _filterType = 'percentage'),
            isDark,
          ),
          const SizedBox(width: AlhaiSpacing.xs),
          _buildChip(
            l10n.fixedAmount,
            _filterType == 'fixed',
            () => setState(() => _filterType = 'fixed'),
            isDark,
          ),
          const SizedBox(width: AlhaiSpacing.xs),
          _buildChip(
            l10n.buyXGetY,
            _filterType == 'buy_x_get_y',
            () => setState(() => _filterType = 'buy_x_get_y'),
            isDark,
          ),
          const SizedBox(width: AlhaiSpacing.xs),
          _buildChip(
            l10n.bundle,
            _filterType == 'bundle',
            () => setState(() => _filterType = 'bundle'),
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildChip(
    String label,
    bool isSelected,
    VoidCallback onTap,
    bool isDark,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: AlhaiSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : AppColors.getSurfaceVariant(isDark),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.getBorder(isDark),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? AppColors.textOnPrimary
                : AppColors.getTextSecondary(isDark),
          ),
        ),
      ),
    );
  }

  Widget _buildOfferCard(
    DiscountsTableData offer,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final typeColor = _getTypeColor(offer.type);
    final isAutoApplied = offer.appliesTo == 'all';

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(
                  _getTypeIcon(offer.type),
                  color: typeColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer.name,
                      style: TextStyle(
                        fontSize: 16,
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
                        color: typeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        _getTypeLabel(offer.type, l10n),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: typeColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isAutoApplied)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: AlhaiSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.auto_awesome_rounded,
                        size: 14,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: AlhaiSpacing.xxs),
                      Text(
                        l10n.autoApplied,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.md),
          // Discount value
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.getSurfaceVariant(isDark),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.local_offer_rounded, size: 18, color: typeColor),
                const SizedBox(width: 10),
                Text(
                  _getDiscountValue(offer, l10n),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: typeColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AlhaiSpacing.sm),
          // Validity dates
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 14,
                color: AppColors.getTextMuted(isDark),
              ),
              const SizedBox(width: AlhaiSpacing.xs),
              if (offer.startDate != null)
                Text(
                  l10n.validFromDate(_formatDate(offer.startDate!)),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.getTextSecondary(isDark),
                  ),
                ),
              if (offer.endDate != null) ...[
                const SizedBox(width: AlhaiSpacing.md),
                Icon(
                  Icons.event_rounded,
                  size: 14,
                  color: AppColors.getTextMuted(isDark),
                ),
                const SizedBox(width: AlhaiSpacing.xs),
                Text(
                  l10n.validUntilDate(_formatDate(offer.endDate!)),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.getTextSecondary(isDark),
                  ),
                ),
              ],
            ],
          ),
          if (offer.nameEn != null && offer.nameEn!.isNotEmpty) ...[
            const SizedBox(height: AlhaiSpacing.sm),
            Text(
              offer.nameEn!,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.getTextSecondary(isDark),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_offer_outlined,
            size: 64,
            color: AppColors.getTextMuted(isDark).withValues(alpha: 0.4),
          ),
          const SizedBox(height: AlhaiSpacing.md),
          Text(
            l10n.noActiveOffers,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.getTextMuted(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'percentage':
        return AppColors.success;
      case 'fixed':
        return AppColors.info;
      case 'buy_x_get_y':
        return AppColors.purple;
      case 'bundle':
        return AppColors.secondary;
      default:
        return AppColors.primary;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'percentage':
        return Icons.percent_rounded;
      case 'fixed':
        return Icons.attach_money_rounded;
      case 'buy_x_get_y':
        return Icons.card_giftcard_rounded;
      case 'bundle':
        return Icons.inventory_2_rounded;
      default:
        return Icons.local_offer_rounded;
    }
  }

  String _getTypeLabel(String type, AppLocalizations l10n) {
    switch (type) {
      case 'percentage':
        return l10n.percentageOff;
      case 'fixed':
        return l10n.fixedAmount;
      case 'buy_x_get_y':
        return l10n.buyXGetY;
      case 'bundle':
        return l10n.bundle;
      default:
        return type;
    }
  }

  String _getDiscountValue(DiscountsTableData offer, AppLocalizations l10n) {
    // discounts.value is int cents for fixed-amount offers (C-4 schema).
    // For percentage offers it is a plain integer percentage (e.g. 15).
    if (offer.type == 'percentage') {
      return l10n.discountOff(offer.value.toString());
    } else if (offer.type == 'fixed') {
      return l10n.sarDiscountOff(
        CurrencyFormatter.fromCents(offer.value, decimalDigits: 2),
      );
    }
    return '${offer.value}';
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}
