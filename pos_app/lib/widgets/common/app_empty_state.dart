/// حالات الفراغ والتحميل - Empty States & Loading
///
/// مجموعة ويدجتس لحالات الفراغ والتحميل والخطأ
library;

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
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
  factory AppEmptyState.noSearchResults({
    String? query,
    VoidCallback? onClear,
  }) {
    final description = query != null && query.isNotEmpty
        ? 'لا توجد نتائج لـ "$query"'
        : 'جرب البحث بكلمات مختلفة';
    return AppEmptyState(
      icon: Icons.search_off,
      title: 'لا توجد نتائج',
      description: description,
      actionText: onClear != null ? 'مسح البحث' : null,
      onAction: onClear,
      actionIcon: Icons.clear,
    );
  }

  /// لا توجد منتجات
  factory AppEmptyState.noProducts({
    VoidCallback? onAdd,
  }) {
    return AppEmptyState(
      icon: Icons.inventory_2_outlined,
      title: 'لا توجد منتجات',
      description: 'ابدأ بإضافة منتجاتك الآن',
      actionText: onAdd != null ? 'إضافة منتج' : null,
      onAction: onAdd,
      actionIcon: Icons.add,
    );
  }

  /// لا يوجد عملاء
  factory AppEmptyState.noCustomers({
    VoidCallback? onAdd,
  }) {
    return AppEmptyState(
      icon: Icons.people_outline,
      title: 'لا يوجد عملاء',
      description: 'ابدأ بإضافة عملائك الآن',
      actionText: onAdd != null ? 'إضافة عميل' : null,
      onAction: onAdd,
      actionIcon: Icons.person_add,
    );
  }

  /// السلة فارغة
  factory AppEmptyState.emptyCart({
    VoidCallback? onBrowse,
  }) {
    return AppEmptyState(
      icon: Icons.shopping_cart_outlined,
      title: 'السلة فارغة',
      description: 'أضف منتجات للسلة لبدء البيع',
      actionText: onBrowse != null ? 'تصفح المنتجات' : null,
      onAction: onBrowse,
      actionIcon: Icons.storefront,
    );
  }

  /// لا توجد فواتير
  factory AppEmptyState.noInvoices() {
    return const AppEmptyState(
      icon: Icons.receipt_long_outlined,
      title: 'لا توجد فواتير',
      description: 'ستظهر الفواتير هنا بعد إتمام عمليات البيع',
    );
  }

  /// لا توجد بيانات
  factory AppEmptyState.noData({
    String? title,
    String? description,
  }) {
    return AppEmptyState(
      icon: Icons.folder_open,
      title: title ?? 'لا توجد بيانات',
      description: description,
    );
  }

  /// لا توجد طلبات
  factory AppEmptyState.noOrders() {
    return const AppEmptyState(
      icon: Icons.shopping_bag_outlined,
      title: 'لا توجد طلبات',
      description: 'ستظهر الطلبات الجديدة هنا',
    );
  }

  /// لا توجد إشعارات
  factory AppEmptyState.noNotifications() {
    return const AppEmptyState(
      icon: Icons.notifications_none,
      title: 'لا توجد إشعارات',
      description: 'ستظهر الإشعارات الجديدة هنا',
    );
  }

  /// لا يوجد اتصال
  factory AppEmptyState.noConnection({VoidCallback? onRetry}) {
    return AppEmptyState(
      icon: Icons.wifi_off,
      title: 'لا يوجد اتصال',
      description: 'تحقق من اتصالك بالإنترنت',
      actionText: onRetry != null ? 'إعادة المحاولة' : null,
      onAction: onRetry,
      actionIcon: Icons.refresh,
      iconColor: AppColors.warning,
    );
  }

  /// لا توجد تقارير
  factory AppEmptyState.noReports() {
    return const AppEmptyState(
      icon: Icons.assessment_outlined,
      title: 'لا توجد تقارير',
      description: 'ستظهر التقارير بعد إتمام عمليات البيع',
    );
  }

  /// لا يوجد مخزون منخفض
  factory AppEmptyState.noLowStock() {
    return const AppEmptyState(
      icon: Icons.inventory_outlined,
      title: 'المخزون في حالة جيدة',
      description: 'لا توجد منتجات تحتاج إعادة تعبئة',
      iconColor: AppColors.success,
    );
  }

  /// لا توجد ديون
  factory AppEmptyState.noDebts() {
    return const AppEmptyState(
      icon: Icons.account_balance_wallet_outlined,
      title: 'لا توجد ديون',
      description: 'جميع العملاء قاموا بالسداد',
      iconColor: AppColors.success,
    );
  }

  /// لا توجد مرتجعات
  factory AppEmptyState.noReturns() {
    return const AppEmptyState(
      icon: Icons.assignment_return_outlined,
      title: 'لا توجد مرتجعات',
      description: 'ستظهر المرتجعات هنا',
    );
  }

  /// لا توجد عروض
  factory AppEmptyState.noOffers({VoidCallback? onAdd}) {
    return AppEmptyState(
      icon: Icons.local_offer_outlined,
      title: 'لا توجد عروض',
      description: 'أضف عروضاً لجذب المزيد من العملاء',
      actionText: onAdd != null ? 'إضافة عرض' : null,
      onAction: onAdd,
      actionIcon: Icons.add,
    );
  }

  @override
  Widget build(BuildContext context) {
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
                color: (iconColor ?? AppColors.grey400).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: iconSize,
                color: iconColor ?? AppColors.grey400,
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Title
            Text(
              title,
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            // Description
            if (description != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                description!,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
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
  factory AppErrorState.network({VoidCallback? onRetry}) {
    return AppErrorState(
      icon: Icons.wifi_off,
      message: 'لا يوجد اتصال بالإنترنت',
      details: 'تحقق من اتصالك بالإنترنت وحاول مرة أخرى',
      onRetry: onRetry,
    );
  }

  /// خطأ الخادم
  factory AppErrorState.server({VoidCallback? onRetry}) {
    return AppErrorState(
      icon: Icons.cloud_off,
      message: 'خطأ في الخادم',
      details: 'حدث خطأ أثناء الاتصال بالخادم',
      onRetry: onRetry,
    );
  }

  /// خطأ عام
  factory AppErrorState.general({
    String? message,
    VoidCallback? onRetry,
  }) {
    return AppErrorState(
      message: message ?? 'حدث خطأ غير متوقع',
      onRetry: onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
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
              child: Icon(
                icon,
                size: 56,
                color: AppColors.error,
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Message
            Text(
              message,
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            // Details
            if (details != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                details!,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // Retry Button
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: 'إعادة المحاولة',
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

  const AppLoadingState({
    super.key,
    this.message,
    this.size = 40,
    this.color,
  });

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
              valueColor: AlwaysStoppedAnimation(
                color ?? AppColors.primary,
              ),
              strokeWidth: 3,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              message!,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Shimmer Loading
class AppShimmer extends StatefulWidget {
  /// الطفل
  final Widget child;

  /// مفعل
  final bool enabled;

  const AppShimmer({
    super.key,
    required this.child,
    this.enabled = true,
  });

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.enabled) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(AppShimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.enabled && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: const [
                AppColors.shimmerBase,
                AppColors.shimmerHighlight,
                AppColors.shimmerBase,
              ],
              stops: [
                _animation.value - 1,
                _animation.value,
                _animation.value + 1,
              ].map((s) => s.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
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
    return AppSkeletonBox(
      width: width,
      height: 16,
      borderRadius: AppRadius.xs,
    );
  }

  /// دائرة (Avatar)
  factory AppSkeletonBox.circle({double size = 40}) {
    return AppSkeletonBox(
      width: size,
      height: size,
      borderRadius: size / 2,
    );
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
