import 'package:flutter/material.dart';

/// Widget موحد لعرض الحالات الفارغة
class EmptyState extends StatelessWidget {
  /// أيقونة الحالة
  final IconData icon;
  
  /// العنوان الرئيسي
  final String title;
  
  /// الوصف (اختياري)
  final String? description;
  
  /// نص الزر (اختياري)
  final String? actionLabel;
  
  /// حدث الزر
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.actionLabel,
    this.onAction,
  });

  /// حالة سلة فارغة
  factory EmptyState.cart({VoidCallback? onAction}) {
    return EmptyState(
      icon: Icons.shopping_cart_outlined,
      title: 'السلة فارغة',
      description: 'أضف منتجات للبدء',
      actionLabel: onAction != null ? 'تصفح المنتجات' : null,
      onAction: onAction,
    );
  }

  /// حالة لا توجد منتجات
  factory EmptyState.products({VoidCallback? onRefresh}) {
    return EmptyState(
      icon: Icons.inventory_2_outlined,
      title: 'لا توجد منتجات',
      description: 'لم يتم العثور على منتجات',
      actionLabel: onRefresh != null ? 'تحديث' : null,
      onAction: onRefresh,
    );
  }

  /// حالة لا توجد نتائج بحث
  factory EmptyState.search({String? query}) {
    return EmptyState(
      icon: Icons.search_off,
      title: 'لا توجد نتائج',
      description: query != null ? 'لم يتم العثور على نتائج لـ "$query"' : 'جرب البحث بكلمات مختلفة',
    );
  }

  /// حالة لا توجد بيانات
  factory EmptyState.noData({String? message}) {
    return EmptyState(
      icon: Icons.inbox_outlined,
      title: 'لا توجد بيانات',
      description: message ?? 'لم يتم العثور على أي بيانات',
    );
  }

  /// حالة لا يوجد اتصال
  factory EmptyState.offline({VoidCallback? onRetry}) {
    return EmptyState(
      icon: Icons.wifi_off,
      title: 'لا يوجد اتصال',
      description: 'تحقق من اتصالك بالإنترنت',
      actionLabel: onRetry != null ? 'إعادة المحاولة' : null,
      onAction: onRetry,
    );
  }

  /// حالة عملاء فارغة
  factory EmptyState.customers({VoidCallback? onAdd}) {
    return EmptyState(
      icon: Icons.people_outline,
      title: 'لا يوجد عملاء',
      description: 'أضف عملاء جدد للبدء',
      actionLabel: onAdd != null ? 'إضافة عميل' : null,
      onAction: onAdd,
    );
  }

  /// حالة طلبات فارغة
  factory EmptyState.orders() {
    return const EmptyState(
      icon: Icons.receipt_long_outlined,
      title: 'لا توجد طلبات',
      description: 'لم تقم بأي طلبات بعد',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
