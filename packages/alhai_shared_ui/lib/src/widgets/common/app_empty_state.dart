/// حالات الفراغ والتحميل - Empty States & Loading
///
/// مجموعة ويدجتس لحالات الفراغ والتحميل والخطأ
library;

import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';
import 'app_button.dart';

/// حالة الفراغ
class AppEmptyState extends StatelessWidget {
  /// الأيقونة
  final IconData icon;

  /// العنوان
  final String title;

  /// الوصف
  final String? description;

  /// نص الزر
  final String? actionText;

  /// عند الضغط على الزر
  final VoidCallback? onAction;

  /// أيقونة الزر
  final IconData? actionIcon;

  /// حجم الأيقونة
  final double iconSize;

  /// لون الأيقونة
  final Color? iconColor;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.actionText,
    this.onAction,
    this.actionIcon,
    this.iconSize = 80,
    this.iconColor,
  });

  /// لا توجد نتائج بحث
  static AppEmptyState noSearchResults(
    BuildContext context, {
    String? query,
    VoidCallback? onClear,
  }) {
    final l10n = AppLocalizations.of(context);
    final description = query != null && query.isNotEmpty
        ? l10n.noResultsFor(query)
        : l10n.tryDifferentSearch;
    return AppEmptyState(
      icon: Icons.search_off,
      title: l10n.noSearchResultsFound,
      description: description,
      actionText: onClear != null ? l10n.clearSearch : null,
      onAction: onClear,
      actionIcon: Icons.clear,
    );
  }

  /// لا توجد منتجات
  static AppEmptyState noProducts(BuildContext context, {VoidCallback? onAdd}) {
    final l10n = AppLocalizations.of(context);
    return AppEmptyState(
      icon: Icons.inventory_2_outlined,
      title: l10n.noProducts,
      description: l10n.emptyStateStartAddProducts,
      actionText: onAdd != null ? l10n.addProduct : null,
      onAction: onAdd,
      actionIcon: Icons.add,
    );
  }

  /// لا يوجد عملاء
  static AppEmptyState noCustomers(
    BuildContext context, {
    VoidCallback? onAdd,
  }) {
    final l10n = AppLocalizations.of(context);
    return AppEmptyState(
      icon: Icons.people_outline,
      title: l10n.noCustomers,
      description: l10n.emptyStateStartAddCustomers,
      actionText: onAdd != null ? l10n.addCustomer : null,
      onAction: onAdd,
      actionIcon: Icons.person_add,
    );
  }

  /// السلة فارغة
  static AppEmptyState emptyCart(
    BuildContext context, {
    VoidCallback? onBrowse,
  }) {
    final l10n = AppLocalizations.of(context);
    return AppEmptyState(
      icon: Icons.shopping_cart_outlined,
      title: l10n.cartIsEmpty,
      description: l10n.emptyStateAddProductsToCart,
      actionText: onBrowse != null ? l10n.browseProducts : null,
      onAction: onBrowse,
      actionIcon: Icons.storefront,
    );
  }

  /// لا توجد فواتير
  static AppEmptyState noInvoices(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppEmptyState(
      icon: Icons.receipt_long_outlined,
      title: l10n.noInvoices,
      description: l10n.emptyStateInvoicesAppearAfterSale,
    );
  }

  /// لا توجد بيانات
  static AppEmptyState noData(
    BuildContext context, {
    String? title,
    String? description,
  }) {
    final l10n = AppLocalizations.of(context);
    return AppEmptyState(
      icon: Icons.folder_open,
      title: title ?? l10n.noData,
      description: description,
    );
  }

  /// لا توجد طلبات
  static AppEmptyState noOrders(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppEmptyState(
      icon: Icons.shopping_bag_outlined,
      title: l10n.noOrders,
      description: l10n.emptyStateNewOrdersAppearHere,
    );
  }

  /// لا توجد إشعارات
  static AppEmptyState noNotifications(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppEmptyState(
      icon: Icons.notifications_none,
      title: l10n.noNotifications,
      description: l10n.emptyStateNewNotificationsAppearHere,
    );
  }

  /// لا يوجد اتصال
  static AppEmptyState noConnection(
    BuildContext context, {
    VoidCallback? onRetry,
  }) {
    final l10n = AppLocalizations.of(context);
    return AppEmptyState(
      icon: Icons.wifi_off,
      title: l10n.noConnection,
      description: l10n.emptyStateCheckYourConnection,
      actionText: onRetry != null ? l10n.retry : null,
      onAction: onRetry,
      actionIcon: Icons.refresh,
      iconColor: AppColors.warning,
    );
  }

  /// لا توجد تقارير
  static AppEmptyState noReports(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppEmptyState(
      icon: Icons.assessment_outlined,
      title: l10n.noReports,
      description: l10n.emptyStateReportsAppearAfterSale,
    );
  }

  /// لا يوجد مخزون منخفض
  static AppEmptyState noLowStock(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppEmptyState(
      icon: Icons.inventory_outlined,
      title: l10n.stockGood,
      description: l10n.emptyStateNoNeedToRestock,
      iconColor: AppColors.success,
    );
  }

  /// لا توجد ديون
  static AppEmptyState noDebts(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppEmptyState(
      icon: Icons.account_balance_wallet_outlined,
      title: l10n.noDebts,
      description: l10n.emptyStateAllCustomersPaid,
      iconColor: AppColors.success,
    );
  }

  /// لا توجد مرتجعات
  static AppEmptyState noReturns(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppEmptyState(
      icon: Icons.assignment_return_outlined,
      title: l10n.noReturns,
      description: l10n.emptyStateReturnsAppearHere,
    );
  }

  /// لا توجد عروض
  static AppEmptyState noOffers(BuildContext context, {VoidCallback? onAdd}) {
    final l10n = AppLocalizations.of(context);
    return AppEmptyState(
      icon: Icons.local_offer_outlined,
      title: l10n.noOffers,
      description: l10n.emptyStateAddOffersToAttract,
      actionText: onAdd != null ? l10n.addOffer : null,
      onAction: onAdd,
      actionIcon: Icons.add,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultIconColor = iconColor ?? theme.colorScheme.onSurfaceVariant;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: iconSize * 1.5,
              height: iconSize * 1.5,
              decoration: BoxDecoration(
                color: defaultIconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: iconSize, color: defaultIconColor),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Title
            Text(
              title,
              style: AppTypography.titleLarge.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            // Description
            if (description != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                description!,
                style: AppTypography.bodyMedium.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // Action Button
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xl),
              AppButton.primary(
                label: actionText!,
                onPressed: onAction,
                icon: actionIcon,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// حالة الخطأ
class AppErrorState extends StatelessWidget {
  /// رسالة الخطأ
  final String message;

  /// تفاصيل الخطأ
  final String? details;

  /// عند إعادة المحاولة
  final VoidCallback? onRetry;

  /// الأيقونة
  final IconData icon;

  const AppErrorState({
    super.key,
    required this.message,
    this.details,
    this.onRetry,
    this.icon = Icons.error_outline,
  });

  /// خطأ الشبكة
  static AppErrorState network(BuildContext context, {VoidCallback? onRetry}) {
    final l10n = AppLocalizations.of(context);
    return AppErrorState(
      icon: Icons.wifi_off,
      message: l10n.errorNoInternetConnection,
      details: l10n.errorCheckConnectionAndRetry,
      onRetry: onRetry,
    );
  }

  /// خطأ الخادم
  static AppErrorState server(BuildContext context, {VoidCallback? onRetry}) {
    final l10n = AppLocalizations.of(context);
    return AppErrorState(
      icon: Icons.cloud_off,
      message: l10n.errorServerError,
      details: l10n.errorServerConnectionFailed,
      onRetry: onRetry,
    );
  }

  /// خطأ عام
  static AppErrorState general(
    BuildContext context, {
    String? message,
    VoidCallback? onRetry,
  }) {
    final l10n = AppLocalizations.of(context);
    return AppErrorState(
      message: message ?? l10n.errorUnexpectedError,
      onRetry: onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 56, color: AppColors.error),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Message
            Text(
              message,
              style: AppTypography.titleLarge.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            // Details
            if (details != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                details!,
                style: AppTypography.bodyMedium.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // Retry Button
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: AppLocalizations.of(context).retry,
                onPressed: onRetry,
                icon: Icons.refresh,
                color: AppColors.error,
                variant: AppButtonVariant.outlined,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// حالة التحميل
class AppLoadingState extends StatelessWidget {
  /// رسالة التحميل
  final String? message;

  /// حجم المؤشر
  final double size;

  /// لون المؤشر
  final Color? color;

  const AppLoadingState({super.key, this.message, this.size = 40, this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(color ?? AppColors.primary),
              strokeWidth: 3,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              message!,
              style: AppTypography.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Shimmer Loading
///
/// Delegates to [AlhaiShimmer] from the design system to avoid duplicated
/// shimmer animation logic. [AlhaiShimmer] provides the same shimmer gradient
/// effect with RTL-safe direction, token-based duration, and dark mode support.
///
/// This class is kept for backward compatibility - new code should use
/// [AlhaiShimmer] directly from `alhai_design_system`.
class AppShimmer extends StatelessWidget {
  /// الطفل
  final Widget child;

  /// مفعل
  final bool enabled;

  const AppShimmer({super.key, required this.child, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return child;
    }

    return AlhaiShimmer(
      enabled: enabled,
      duration: AlhaiDurations.shimmer,
      child: child,
    );
  }
}

/// Skeleton Loading Box
class AppSkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const AppSkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = AppRadius.sm,
  });

  /// سطر نص
  factory AppSkeletonBox.text({double width = 100}) {
    return AppSkeletonBox(width: width, height: 16, borderRadius: AppRadius.xs);
  }

  /// دائرة (Avatar)
  factory AppSkeletonBox.circle({double size = 40}) {
    return AppSkeletonBox(width: size, height: size, borderRadius: size / 2);
  }

  /// كارد
  factory AppSkeletonBox.card({double? width, double height = 150}) {
    return AppSkeletonBox(
      width: width,
      height: height,
      borderRadius: AppRadius.lg,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.shimmerBase,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Skeleton لبطاقة منتج
class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder (flex 3)
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.shimmerBase,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppRadius.lg - 1),
                  ),
                ),
              ),
            ),

            // Content (flex 2)
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.shimmerBase,
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      width: 80,
                      height: 18,
                      decoration: BoxDecoration(
                        color: AppColors.shimmerBase,
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton لعنصر قائمة
class ListItemSkeleton extends StatelessWidget {
  final bool showAvatar;
  final bool showSubtitle;

  const ListItemSkeleton({
    super.key,
    this.showAvatar = true,
    this.showSubtitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            if (showAvatar) ...[
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.shimmerBase,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.shimmerBase,
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                  ),
                  if (showSubtitle) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      width: 120,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.shimmerBase,
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
