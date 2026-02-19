/// Hold Invoices Screen
///
/// يعرض قائمة الفواتير المعلقة المحفوظة في قاعدة البيانات (DB-backed)
/// بدلاً من الذاكرة المؤقتة، مع دعم:
/// - استعادة الفاتورة إلى السلة
/// - حذف فاتورة معلقة
/// - عرض تفاصيل الفاتورة (عدد العناصر، الإجمالي، الوقت)
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/cart_providers.dart';
import '../../providers/held_invoices_providers.dart';
import '../../widgets/common/app_empty_state.dart';
import '../../widgets/responsive/responsive_builder.dart';

/// Hold Invoices Screen
class HoldInvoicesScreen extends ConsumerWidget {
  const HoldInvoicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heldInvoicesAsync = ref.watch(dbHeldInvoicesListProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.holdInvoices),
            // عرض عدد الفواتير عند التحميل الناجح
            heldInvoicesAsync.maybeWhen(
              data: (invoices) => invoices.isNotEmpty
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${invoices.length}',
                            style: const TextStyle(
                              color: AppColors.warning,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
              orElse: () => const SizedBox.shrink(),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          heldInvoicesAsync.maybeWhen(
            data: (invoices) => invoices.isNotEmpty
                ? TextButton.icon(
                    onPressed: () =>
                        _showClearAllDialog(context, ref, l10n, invoices.length),
                    icon: const Icon(Icons.delete_sweep, size: 20),
                    label: Text(l10n.clearAll),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: heldInvoicesAsync.when(
        // حالة التحميل
        loading: () => const Center(child: CircularProgressIndicator()),
        // حالة الخطأ
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: AppSizes.md),
              const Text(
                'خطأ في تحميل الفواتير المعلقة',
                style: AppTypography.titleMedium,
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                error.toString(),
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.textMuted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.lg),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(dbHeldInvoicesListProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
        // حالة البيانات
        data: (heldInvoices) => heldInvoices.isEmpty
            ? AppEmptyState(
                icon: Icons.pause_circle_outline,
                title: l10n.noHoldInvoices,
                description: l10n.holdInvoicesDesc,
              )
            : ResponsiveBuilder(
                builder: (context, deviceType, width) {
                  if (deviceType.isMobile) {
                    return ListView.builder(
                      padding: const EdgeInsets.all(AppSizes.md),
                      itemCount: heldInvoices.length,
                      itemBuilder: (context, index) {
                        final invoice = heldInvoices[index];
                        return _HoldInvoiceCard(
                          invoice: invoice,
                          onResume: () =>
                              _resumeInvoice(context, ref, invoice, l10n),
                          onDelete: () =>
                              _deleteInvoice(context, ref, invoice, l10n),
                        );
                      },
                    );
                  }
                  // Tablet/Desktop: 2-column grid
                  return GridView.builder(
                    padding: const EdgeInsets.all(AppSizes.md),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: deviceType.isTablet ? 2 : 3,
                      crossAxisSpacing: AppSizes.md,
                      mainAxisSpacing: AppSizes.md,
                      childAspectRatio: 1.4,
                    ),
                    itemCount: heldInvoices.length,
                    itemBuilder: (context, index) {
                      final invoice = heldInvoices[index];
                      return _HoldInvoiceCard(
                        invoice: invoice,
                        onResume: () =>
                            _resumeInvoice(context, ref, invoice, l10n),
                        onDelete: () =>
                            _deleteInvoice(context, ref, invoice, l10n),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }

  void _resumeInvoice(BuildContext context, WidgetRef ref,
      HeldInvoice invoice, AppLocalizations l10n) async {
    HapticFeedback.mediumImpact();

    // استعادة الفاتورة من قاعدة البيانات إلى السلة
    await resumeHeldInvoice(ref, invoice);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.play_arrow_rounded,
                color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(l10n.resumedInvoice(invoice.description)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.success,
      ),
    );
    Navigator.pop(context, true); // true = تم استعادة الفاتورة
  }

  void _deleteInvoice(BuildContext context, WidgetRef ref,
      HeldInvoice invoice, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l10n.deleteInvoiceTitle),
        content: Text(l10n.deleteInvoiceConfirmMsg(invoice.description)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              // حذف من قاعدة البيانات
              await deleteHeldInvoice(ref, invoice.id);
              if (dialogCtx.mounted) Navigator.pop(dialogCtx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.invoiceDeletedMsg),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog(
      BuildContext context, WidgetRef ref, AppLocalizations l10n, int count) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l10n.deleteAllInvoices),
        content: Text(l10n.deleteAllInvoicesConfirm(count)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              // حذف جميع الفواتير من قاعدة البيانات
              await deleteAllHeldInvoices(ref);
              if (dialogCtx.mounted) Navigator.pop(dialogCtx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.allInvoicesDeleted),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.deleteAllLabel),
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
    final l10n = AppLocalizations.of(context)!;
    final timeDiff = DateTime.now().difference(invoice.createdAt);
    final timeText = _formatTimeDiff(timeDiff, l10n);
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
                            color: isDark
                                ? AppColors.textMutedDark
                                : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        l10n.debtAmountWithCurrency(
                            cart.total.toStringAsFixed(2)),
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.itemLabel(cart.itemCount),
                        style: AppTypography.labelSmall.copyWith(
                          color: isDark
                              ? AppColors.textMutedDark
                              : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Invoice items (first 3 only)
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
                              color:
                                  isDark ? AppColors.grey600 : AppColors.grey400,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.product.name,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '\u00d7${item.quantity}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.textMutedDark
                                  : AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            item.total.toStringAsFixed(2),
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )),
                if (cart.items.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      l10n.moreItems(cart.items.length - 3),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textMuted,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],

              // Note (custom name)
              if (invoice.name != null && invoice.name!.isNotEmpty) ...[
                const SizedBox(height: AppSizes.sm),
                Container(
                  padding: const EdgeInsets.all(AppSizes.sm),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceVariantDark
                        : AppColors.grey100,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.note_outlined,
                        size: 16,
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textMuted,
                      ),
                      const SizedBox(width: AppSizes.xs),
                      Expanded(
                        child: Text(
                          invoice.name!,
                          style: AppTypography.bodySmall.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Customer info
              if (cart.customerName != null) ...[
                const SizedBox(height: AppSizes.sm),
                Row(
                  children: [
                    Icon(Icons.person_outline,
                        size: 16,
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      cart.customerName!,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
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
                      label: Text(l10n.delete),
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
                      label: Text(l10n.resume),
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

  String _formatTimeDiff(Duration diff, AppLocalizations l10n) {
    if (diff.inMinutes < 1) {
      return l10n.justNowTime;
    } else if (diff.inMinutes < 60) {
      return l10n.minutesAgoTime(diff.inMinutes);
    } else if (diff.inHours < 24) {
      return l10n.hoursAgoTime(diff.inHours);
    } else {
      return l10n.daysAgoTime(diff.inDays);
    }
  }
}
