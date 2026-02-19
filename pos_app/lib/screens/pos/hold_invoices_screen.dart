/// شاشة الفواتير المعلقة - Hold Invoices Screen
///
/// تعرض قائمة الفواتير المعلقة الحقيقية من [heldInvoicesProvider] مع إمكانية:
/// - استئناف الفاتورة (تُستعاد في السلة)
/// - حذف الفاتورة المعلقة
/// - عرض تفاصيل الفاتورة (عدد العناصر، الإجمالي، الوقت)
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/cart_providers.dart';
import '../../widgets/common/app_empty_state.dart';

/// شاشة الفواتير المعلقة
class HoldInvoicesScreen extends ConsumerWidget {
  const HoldInvoicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heldInvoices = ref.watch(heldInvoicesProvider);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('الفواتير المعلقة'),
            if (heldInvoices.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${heldInvoices.length}',
                  style: const TextStyle(
                    color: AppColors.warning,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        centerTitle: true,
        actions: [
          if (heldInvoices.isNotEmpty)
            TextButton.icon(
              onPressed: () => _showClearAllDialog(context, ref),
              icon: const Icon(Icons.delete_sweep, size: 20),
              label: const Text('مسح الكل'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
              ),
            ),
        ],
      ),
      body: heldInvoices.isEmpty
          ? const AppEmptyState(
              icon: Icons.pause_circle_outline,
              title: 'لا توجد فواتير معلقة',
              description: 'عند تعليق فاتورة من نقطة البيع ستظهر هنا\nيمكنك تعليق عدة فواتير واستئنافها لاحقاً',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSizes.md),
              itemCount: heldInvoices.length,
              itemBuilder: (context, index) {
                final invoice = heldInvoices[index];
                return _HoldInvoiceCard(
                  invoice: invoice,
                  onResume: () => _resumeInvoice(context, ref, invoice),
                  onDelete: () => _deleteInvoice(context, ref, invoice),
                );
              },
            ),
    );
  }

  void _resumeInvoice(BuildContext context, WidgetRef ref, HeldInvoice invoice) {
    HapticFeedback.mediumImpact();
    // استعادة الفاتورة المعلقة إلى السلة
    ref.read(cartStateProvider.notifier).restoreInvoice(invoice);
    // تحديث قائمة الفواتير المعلقة
    ref.read(heldInvoicesProvider.notifier).refresh();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text('تم استئناف: ${invoice.description}'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.success,
      ),
    );
    Navigator.pop(context, true); // true = تم استعادة فاتورة
  }

  void _deleteInvoice(BuildContext context, WidgetRef ref, HeldInvoice invoice) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('حذف الفاتورة'),
        content: Text('هل تريد حذف "${invoice.description}"?\nهذا الإجراء لا يمكن التراجع عنه.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(heldInvoicesProvider.notifier).delete(invoice.id);
              Navigator.pop(dialogCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم حذف الفاتورة'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog(BuildContext context, WidgetRef ref) {
    final count = ref.read(heldInvoicesProvider).length;
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('حذف جميع الفواتير'),
        content: Text('هل تريد حذف جميع الفواتير المعلقة ($count فاتورة)?\nهذا الإجراء لا يمكن التراجع عنه.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final invoices = ref.read(heldInvoicesProvider);
              for (final inv in invoices) {
                await ref.read(heldInvoicesProvider.notifier).delete(inv.id);
              }
              if (dialogCtx.mounted) Navigator.pop(dialogCtx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم حذف جميع الفواتير'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('حذف الكل'),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// HOLD INVOICE CARD
// =============================================================================

class _HoldInvoiceCard extends StatelessWidget {
  final HeldInvoice invoice;
  final VoidCallback onResume;
  final VoidCallback onDelete;

  const _HoldInvoiceCard({
    required this.invoice,
    required this.onResume,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final timeDiff = DateTime.now().difference(invoice.createdAt);
    final timeText = _formatTimeDiff(timeDiff);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cart = invoice.cart;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      color: isDark ? AppColors.surfaceDark : null,
      child: InkWell(
        onTap: onResume,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSizes.sm),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                    child: const Icon(
                      Icons.pause_circle_filled,
                      color: AppColors.warning,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          invoice.description,
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textPrimaryDark : null,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          timeText,
                          style: AppTypography.labelSmall.copyWith(
                            color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${cart.total.toStringAsFixed(2)} ر.س',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${cart.itemCount} عنصر',
                        style: AppTypography.labelSmall.copyWith(
                          color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // عناصر الفاتورة (أول 3 فقط)
              if (cart.items.isNotEmpty) ...[
                const Divider(height: AppSizes.xl),
                ...cart.items.take(3).map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.grey600 : AppColors.grey400,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.product.name,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '×${item.quantity}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            item.total.toStringAsFixed(2),
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )),
                if (cart.items.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '+${cart.items.length - 3} عناصر أخرى',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],

              // ملاحظة (اسم مخصص)
              if (invoice.name != null && invoice.name!.isNotEmpty) ...[
                const SizedBox(height: AppSizes.sm),
                Container(
                  padding: const EdgeInsets.all(AppSizes.sm),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceVariantDark : AppColors.grey100,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.note_outlined,
                        size: 16,
                        color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
                      ),
                      const SizedBox(width: AppSizes.xs),
                      Expanded(
                        child: Text(
                          invoice.name!,
                          style: AppTypography.bodySmall.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // معلومات العميل
              if (cart.customerName != null) ...[
                const SizedBox(height: AppSizes.sm),
                Row(
                  children: [
                    Icon(Icons.person_outline,
                        size: 16,
                        color: isDark ? AppColors.textMutedDark : AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      cart.customerName!,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: AppSizes.md),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('حذف'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: onResume,
                      icon: const Icon(Icons.play_arrow, size: 18),
                      label: const Text('استئناف'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimeDiff(Duration diff) {
    if (diff.inMinutes < 1) {
      return 'الآن';
    } else if (diff.inMinutes < 60) {
      return 'منذ ${diff.inMinutes} دقيقة';
    } else if (diff.inHours < 24) {
      return 'منذ ${diff.inHours} ساعة';
    } else {
      return 'منذ ${diff.inDays} يوم';
    }
  }
}
