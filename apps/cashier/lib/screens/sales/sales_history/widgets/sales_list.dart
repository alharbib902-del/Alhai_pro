/// Sales list widget: infinite-scroll list + empty state + card rendering.
///
/// All monetary fields on [SalesTableData] are stored as int cents (C-4)
/// and converted to SAR at render time.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_design_system/alhai_design_system.dart' show AlhaiSpacing;

import '../providers/sales_history_providers.dart';
import 'sale_detail_sheet.dart';

/// قائمة المبيعات مع pagination لا نهائية.
class SalesListView extends ConsumerStatefulWidget {
  const SalesListView({
    super.key,
    required this.orders,
    required this.hasMore,
    required this.isLoadingMore,
    required this.isMediumScreen,
    required this.scrollController,
  });

  final List<SalesTableData> orders;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isMediumScreen;
  final ScrollController scrollController;

  @override
  ConsumerState<SalesListView> createState() => _SalesListViewState();
}

class _SalesListViewState extends ConsumerState<SalesListView> {
  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    // Infinite scroll: حمّل المزيد عند الاقتراب من النهاية.
    if (widget.scrollController.position.pixels >=
            widget.scrollController.position.maxScrollExtent - 200 &&
        !widget.isLoadingMore &&
        widget.hasMore) {
      ref.read(salesHistoryNotifierProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.orders.isEmpty) {
      return const _EmptyState();
    }

    final l10n = AppLocalizations.of(context);
    return RefreshIndicator(
      onRefresh: () => ref.read(salesHistoryNotifierProvider.notifier).reload(),
      color: AppColors.primary,
      child: ListView.separated(
        controller: widget.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: widget.isMediumScreen ? 24 : 16,
          vertical: AlhaiSpacing.xs,
        ),
        itemCount:
            widget.orders.length +
            (widget.isLoadingMore || widget.hasMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: AlhaiSpacing.xs),
        itemBuilder: (context, index) {
          if (index < widget.orders.length) {
            final order = widget.orders[index];
            return _OrderCard(
              order: order,
              onTap: () => showSaleDetailSheet(context, order),
            );
          }
          if (widget.isLoadingMore) return const _SkeletonRow();
          if (widget.hasMore) {
            return Padding(
              padding: const EdgeInsets.all(AlhaiSpacing.md),
              child: Center(
                child: OutlinedButton.icon(
                  onPressed: () => ref
                      .read(salesHistoryNotifierProvider.notifier)
                      .loadMore(),
                  icon: const Icon(Icons.expand_more),
                  label: Text(l10n.loadMoreBtn),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ============================================================================
// ORDER CARD
// ============================================================================

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.onTap});

  final SalesTableData order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final utc = order.createdAt.toUtc();
    final time =
        '${utc.hour.toString().padLeft(2, '0')}:${utc.minute.toString().padLeft(2, '0')}';
    final date = '${utc.day}/${utc.month}/${utc.year}';

    // C-4: order.total int cents → SAR للعرض فقط.
    final totalSar = (order.total / 100.0).toStringAsFixed(2);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(AlhaiSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.getSurface(isDark),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.getBorder(isDark)),
        ),
        child: Row(
          children: [
            _PaymentIconBadge(method: order.paymentMethod),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '#${order.id.length > 8 ? order.id.substring(0, 8) : order.id}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.getTextPrimary(isDark),
                        ),
                      ),
                      const SizedBox(width: AlhaiSpacing.xs),
                      _PaymentMethodChip(
                        method: order.paymentMethod,
                        l10n: l10n,
                      ),
                    ],
                  ),
                  const SizedBox(height: AlhaiSpacing.xxs),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline_rounded,
                        size: 13,
                        color: AppColors.getTextMuted(isDark),
                      ),
                      const SizedBox(width: AlhaiSpacing.xxs),
                      Flexible(
                        child: Text(
                          order.customerName ??
                              order.customerId ??
                              l10n.cashCustomer,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.getTextSecondary(isDark),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AlhaiSpacing.sm),
                      Icon(
                        Icons.access_time_rounded,
                        size: 13,
                        color: AppColors.getTextMuted(isDark),
                      ),
                      const SizedBox(width: AlhaiSpacing.xxs),
                      Text(
                        '$date $time',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.getTextMuted(isDark),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$totalSar ${l10n.sar}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.xxs),
                _PaymentDetails(order: order),
                const SizedBox(height: AlhaiSpacing.xxs),
                _StatusChip(status: order.status, l10n: l10n),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentIconBadge extends StatelessWidget {
  const _PaymentIconBadge({required this.method});
  final String method;

  @override
  Widget build(BuildContext context) {
    final color = paymentMethodColor(method);
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Icon(paymentMethodIcon(method), color: color, size: 22),
    );
  }
}

class _PaymentMethodChip extends StatelessWidget {
  const _PaymentMethodChip({required this.method, required this.l10n});
  final String method;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final color = paymentMethodColor(method);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: AlhaiSpacing.xxxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        paymentMethodLabel(method, l10n),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, required this.l10n});
  final String status;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AlhaiSpacing.xs,
        vertical: AlhaiSpacing.xxxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _statusLabel(status, l10n),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ============================================================================
// PAYMENT DETAILS (amounts already in cents → convert to SAR for display)
// ============================================================================

class _PaymentDetails extends StatelessWidget {
  const _PaymentDetails({required this.order});
  final SalesTableData order;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final method = order.paymentMethod;
    final totalCents = order.total;
    final color = paymentMethodColor(method);

    // دفع بسيط (غير مختلط) — اعرض الإجمالي بصيغة SAR.
    if (method != 'mixed') {
      final sar = (totalCents / 100.0).toStringAsFixed(2);
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(paymentMethodIcon(method), size: 11, color: color),
          const SizedBox(width: 3),
          Text(
            '$sar ${l10n.sar}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      );
    }

    // مختلط — استخدم الأعمدة الجديدة عند وجود قيمة موجبة واحدة على الأقل.
    // الفحص الصريح لـ cashAmount/cardAmount/creditAmount يمنع fallback
    // خاطئ (double-debit) عند مبيعات mixed حديثة كل قيمها 0 من خطأ مستخدم.
    final cashCents = order.cashAmount ?? 0;
    final cardCents = order.cardAmount ?? 0;
    final creditCents = order.creditAmount ?? 0;
    final hasExplicitSplits =
        cashCents > 0 || cardCents > 0 || creditCents > 0;
    if (hasExplicitSplits) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (cashCents > 0)
            _SplitAmountLine(
              icon: Icons.payments_outlined,
              color: AppColors.success,
              amountCents: cashCents,
            ),
          if (cardCents > 0)
            _SplitAmountLine(
              icon: Icons.credit_card_rounded,
              color: AppColors.info,
              amountCents: cardCents,
            ),
          if (creditCents > 0)
            _SplitAmountLine(
              icon: Icons.account_balance_wallet_outlined,
              color: AppColors.warning,
              amountCents: creditCents,
            ),
        ],
      );
    }

    // Fallback للمبيعات القديمة مع amountReceived فقط (legacy rows).
    // تشديد: لا نفترض "card" للمتبقي إلا عندما تكون isPaid=true AND
    // amountReceived < total (بيع مختلط قديم). إذا كانت isPaid=true
    // و amountReceived == total، لا يوجد متبقٍ — نعرض سطر cash واحد.
    // إذا كانت isPaid=false، المتبقي credit (ديون).
    if (order.amountReceived != null && order.amountReceived! > 0) {
      final paidCents = order.amountReceived!;
      final remainingCents = totalCents - paidCents;
      // Guard: إذا كانت isPaid=true لكن amountReceived أقل من total،
      // افترِض أن الفارق legacy rounding (< ريال واحد) ولا تُظهر سطر
      // card مزدوج. وإلا فهو mixed قديم فعلي.
      final isMixedLegacy = remainingCents > 100; // > ريال واحد
      final isCredit = !order.isPaid && remainingCents > 0;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _SplitAmountLine(
            icon: Icons.payments_outlined,
            color: AppColors.success,
            amountCents: paidCents,
          ),
          if (remainingCents > 0 && (isCredit || isMixedLegacy))
            _SplitAmountLine(
              icon: isCredit
                  ? Icons.account_balance_wallet_outlined
                  : Icons.credit_card_rounded,
              color: isCredit ? AppColors.warning : AppColors.info,
              amountCents: remainingCents,
            ),
        ],
      );
    }

    // مختلط بدون تفاصيل.
    final totalSar = (totalCents / 100.0).toStringAsFixed(2);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.swap_horiz_rounded, size: 11, color: color),
        const SizedBox(width: 3),
        Text(
          '$totalSar ${l10n.sar}',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _SplitAmountLine extends StatelessWidget {
  const _SplitAmountLine({
    required this.icon,
    required this.color,
    required this.amountCents,
  });

  final IconData icon;
  final Color color;
  final int amountCents;

  @override
  Widget build(BuildContext context) {
    // C-4: cents → SAR للعرض.
    final sar = (amountCents / 100.0).toStringAsFixed(2);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 3),
        Text(
          sar,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// EMPTY STATE + SKELETON
// ============================================================================

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: AppColors.getTextMuted(isDark).withValues(alpha: 0.4),
          ),
          const SizedBox(height: AlhaiSpacing.md),
          Text(
            l10n.noTransactions,
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
}

class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Shimmer.fromColors(
      baseColor: scheme.surfaceContainerHighest,
      highlightColor: scheme.surfaceContainer,
      child: Container(
        height: 64,
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

// ============================================================================
// HELPERS (module-private but exposed at library level for tests/widgets)
// ============================================================================

/// لون طريقة الدفع.
Color paymentMethodColor(String method) {
  switch (method) {
    case 'cash':
      return AppColors.success;
    case 'card':
      return AppColors.info;
    case 'mixed':
      return AppColors.purple;
    case 'credit':
      return AppColors.warning;
    default:
      return AppColors.info;
  }
}

/// أيقونة طريقة الدفع.
IconData paymentMethodIcon(String method) {
  switch (method) {
    case 'cash':
      return Icons.payments_outlined;
    case 'card':
      return Icons.credit_card_rounded;
    case 'mixed':
      return Icons.swap_horiz_rounded;
    case 'credit':
      return Icons.account_balance_wallet_outlined;
    default:
      return Icons.receipt_long_rounded;
  }
}

/// اسم طريقة الدفع بالـ l10n الحالية.
String paymentMethodLabel(String method, AppLocalizations l10n) {
  switch (method) {
    case 'cash':
      return l10n.cash;
    case 'card':
      return l10n.card;
    case 'mixed':
      return l10n.mixed;
    case 'credit':
      return l10n.credit;
    default:
      return method;
  }
}

Color _statusColor(String status) {
  switch (status) {
    case 'completed':
      return AppColors.success;
    case 'created':
      return AppColors.warning;
    case 'cancelled':
      return AppColors.error;
    case 'refunded':
      return AppColors.purple;
    default:
      return AppColors.info;
  }
}

String _statusLabel(String status, AppLocalizations l10n) {
  switch (status) {
    case 'completed':
      return l10n.completed;
    case 'created':
      return l10n.pending;
    case 'cancelled':
      return l10n.cancelled;
    case 'refunded':
      return l10n.refunded;
    default:
      return status;
  }
}
