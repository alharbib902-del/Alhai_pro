import 'package:drift/drift.dart' hide Column;
import 'package:alhai_database/alhai_database.dart' show CustomersTableCompanion;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../providers/cart_providers.dart';
import '../../widgets/pos/customer_search_dialog.dart';
import '../../widgets/pos/sale_note_dialog.dart';
import '../../providers/held_invoices_providers.dart';
import '../../services/manager_approval_service.dart';

// M160: Locale-aware currency formatting helper for this file
String _fmtCurrency(BuildContext context, double amount) =>
    CurrencyFormatter.formatWithContext(context, amount);

// =============================================================================
// CART PANEL
// =============================================================================

class PosCartPanel extends ConsumerWidget {
  final bool isBottomSheet;
  final String? orderNumber;
  final Function(double total)? onPayTap;
  final VoidCallback? onHoldInvoice;
  final VoidCallback? onShowHeldInvoices;

  const PosCartPanel({
    super.key,
    this.isBottomSheet = false,
    this.orderNumber,
    this.onPayTap,
    this.onHoldInvoice,
    this.onShowHeldInvoices,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // M93: Watch the full cart state but use it efficiently.
    // The cart panel must react to all cart mutations (items, discount,
    // customer, notes) so a single watch is appropriate here.
    // The parent POS screen is optimized to NOT rebuild from cart changes
    // via .select((s) => s.itemCount).
    final cartState = ref.watch(cartStateProvider);
    final items = cartState.items;
    final subtotal = cartState.subtotal;
    final tax = subtotal * 0.15;
    final total = subtotal + tax - cartState.discount;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: isBottomSheet
            ? null
            : BorderDirectional(
                start: BorderSide(
                  color: colorScheme.outlineVariant,
                ),
              ),
      ),
      child: Column(
        children: [
          // Cart header
          _buildCartHeader(context, ref, cartState, isDark, l10n),

          // Customer input
          _buildCustomerInput(context, ref, cartState, isDark, l10n),

          // Divider
          Divider(
            height: 1,
            color: colorScheme.outlineVariant,
          ),

          // Cart items
          Expanded(
            child: items.isEmpty
                ? _buildEmptyCart(context, isDark, l10n)
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 16,
                      color: colorScheme.surfaceContainerLow,
                    ),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Dismissible(
                        key: ValueKey(item.product.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: AlignmentDirectional.centerEnd,
                          padding: const EdgeInsetsDirectional.only(end: 16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.error,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.delete_outline, color: Colors.white),
                        ),
                        // L32: Confirmation dialog before dismissing
                        confirmDismiss: (_) async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text(l10n.deleteConfirmTitle),
                              content: Text(
                                '${l10n.removeFromCart}: ${item.product.name}?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: Text(l10n.cancel),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: Theme.of(ctx).colorScheme.error,
                                  ),
                                  child: Text(l10n.confirm),
                                ),
                              ],
                            ),
                          );
                          return confirmed ?? false;
                        },
                        onDismissed: (_) {
                          ref.read(cartStateProvider.notifier).removeProduct(item.product.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.itemDeletedMsg),
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: PosCartItemTile(item: item),
                      );
                    },
                  ),
          ),

          // Discount + Coupon links
          if (items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  // زر تطبيق خصم
                  TextButton.icon(
                    onPressed: () => _showDiscountDialog(context, ref, subtotal),
                    icon: const Icon(Icons.percent_rounded, size: 16, color: AppColors.success),
                    label: Text(
                      l10n.discount,
                      style: const TextStyle(
                        color: AppColors.success,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 32),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // كوبون
                  TextButton.icon(
                    onPressed: () {
                      final codeController = TextEditingController();
                      showDialog<void>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(l10n.applyCoupon),
                          content: TextField(
                            controller: codeController,
                            autofocus: true,
                            textDirection: TextDirection.ltr,
                            decoration: InputDecoration(
                              hintText: l10n.enterCouponCode,
                              prefixIcon: const Icon(Icons.discount_outlined),
                              border: const OutlineInputBorder(),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: Text(l10n.cancel),
                            ),
                            FilledButton(
                              onPressed: () async {
                                final code = codeController.text.trim().toUpperCase();
                                if (code.isEmpty) return;
                                Navigator.pop(ctx);
                                final db = ref.read(appDatabaseProvider);
                                final storeId = ref.read(currentStoreIdProvider) ?? kDefaultStoreId;
                                try {
                                  final coupon = await db.discountsDao.getCouponByCode(code, storeId);
                                  if (!context.mounted) return;
                                  if (coupon == null || !coupon.isActive) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.invalidCoupon), backgroundColor: AppColors.error));
                                    return;
                                  }
                                  if (coupon.expiresAt != null && coupon.expiresAt!.isBefore(DateTime.now())) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.couponExpired), backgroundColor: AppColors.error));
                                    return;
                                  }
                                  final currentSubtotal = ref.read(cartStateProvider).subtotal;
                                  if (coupon.minPurchase > 0 && currentSubtotal < coupon.minPurchase) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.minimumPurchaseRequired(AppNumberFormatter.currency(coupon.minPurchase, locale: Localizations.localeOf(context).toString()))), backgroundColor: AppColors.warning));
                                    return;
                                  }
                                  final discount = coupon.type == 'percentage' ? currentSubtotal * (coupon.value / 100) : coupon.value;
                                  ref.read(cartStateProvider.notifier).setDiscount(discount);
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.couponDiscountApplied(CurrencyFormatter.formatWithContext(context, discount))), backgroundColor: AppColors.success));
                                } catch (_) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.couponInvalid), backgroundColor: AppColors.error));
                                }
                              },
                              child: Text(l10n.apply),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Text('\uD83C\uDFF7\uFE0F', style: TextStyle(fontSize: 14)),
                    label: Text(
                      l10n.haveCoupon,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 32),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // ملاحظة
                  TextButton.icon(
                    onPressed: () async {
                      final result = await SaleNoteDialog.show(
                        context,
                        initialNote: cartState.notes,
                      );
                      if (result != null) {
                        ref.read(cartStateProvider.notifier).setNotes(
                              result.isEmpty ? null : result,
                            );
                      }
                    },
                    icon: Icon(
                      cartState.notes != null && cartState.notes!.isNotEmpty
                          ? Icons.note_rounded
                          : Icons.note_add_outlined,
                      size: 16,
                      color: cartState.notes != null && cartState.notes!.isNotEmpty
                          ? AppColors.warning
                          : AppColors.info,
                    ),
                    label: Text(
                      l10n.noteLabel,
                      style: TextStyle(
                        color: cartState.notes != null && cartState.notes!.isNotEmpty
                            ? AppColors.warning
                            : AppColors.info,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 32),
                    ),
                  ),
                ],
              ),
            ),

          // Note indicator chip
          if (cartState.notes != null && cartState.notes!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.note_rounded,
                        size: 16, color: AppColors.warning),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        cartState.notes!,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    InkWell(
                      onTap: () => ref
                          .read(cartStateProvider.notifier)
                          .setNotes(null),
                      child: const Icon(Icons.close,
                          size: 16, color: AppColors.warning),
                    ),
                  ],
                ),
              ),
            ),

          // Totals + action buttons
          _buildCartFooter(context, ref, cartState, subtotal, tax, total,
              isDark, l10n, items.isNotEmpty),
        ],
      ),
    );
  }

  Widget _buildCartHeader(BuildContext context, WidgetRef ref,
      CartState cartState, bool isDark, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.shopping_cart_rounded,
              size: 20,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              l10n.shoppingCart,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
          ),
          if (cartState.items.isNotEmpty) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${cartState.itemCount}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          const Spacer(),
          if (orderNumber != null)
            Flexible(
              child: Text(
                '#$orderNumber',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          if (cartState.items.isNotEmpty) ...[
            const SizedBox(width: 8),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => ref.read(cartStateProvider.notifier).clear(),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(Icons.delete_outline_rounded,
                      size: 20, color: AppColors.error.withValues(alpha: 0.7)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCustomerInput(BuildContext context, WidgetRef ref,
      CartState cartState, bool isDark, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final result = await CustomerSearchDialog.show(context);
                if (result != null) {
                  ref.read(cartStateProvider.notifier).setCustomer(
                        result.id,
                        customerName: result.name,
                      );
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: colorScheme.outlineVariant,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.person_outline_rounded,
                        size: 18,
                        color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        cartState.customerName ?? l10n.selectOrSearchCustomer,
                        style: TextStyle(
                          fontSize: 13,
                          color: cartState.customerName != null
                              ? colorScheme.onSurface
                              : colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () {
              final nameCtrl = TextEditingController();
              final phoneCtrl = TextEditingController();
              showDialog<void>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(l10n.addNewCustomer),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameCtrl,
                        autofocus: true,
                        decoration: InputDecoration(
                          labelText: l10n.nameRequired,
                          prefixIcon: const Icon(Icons.person_outline),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: phoneCtrl,
                        keyboardType: TextInputType.phone,
                        textDirection: TextDirection.ltr,
                        decoration: InputDecoration(
                          labelText: l10n.mobileNumber,
                          prefixIcon: const Icon(Icons.phone_outlined),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
                    FilledButton(
                      onPressed: () async {
                        final name = nameCtrl.text.trim();
                        if (name.isEmpty) return;
                        Navigator.pop(ctx);
                        final db = ref.read(appDatabaseProvider);
                        final storeId = ref.read(currentStoreIdProvider) ?? kDefaultStoreId;
                        try {
                          final customerId = 'cust_${DateTime.now().millisecondsSinceEpoch}';
                          final phone = phoneCtrl.text.trim();
                          await db.customersDao.insertCustomer(
                            CustomersTableCompanion.insert(
                              id: customerId,
                              storeId: storeId,
                              name: name,
                              phone: phone.isEmpty ? const Value.absent() : Value(phone),
                              createdAt: DateTime.now(),
                            ),
                          );
                          ref.read(cartStateProvider.notifier).setCustomer(customerId, customerName: name);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.customerAddedSuccess(name)), backgroundColor: AppColors.success));
                        } catch (e) {
                          debugPrint('Error adding customer: $e');
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.customerAddFailed), backgroundColor: AppColors.error));
                          }
                        }
                      },
                      child: Text(l10n.save),
                    ),
                  ],
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              minimumSize: const Size(0, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text('+${l10n.newCustomer}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart(
      BuildContext context, bool isDark, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.cartEmpty,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.addProductsToStart,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartFooter(
      BuildContext context,
      WidgetRef ref,
      CartState cartState,
      double subtotal,
      double tax,
      double total,
      bool isDark,
      AppLocalizations l10n,
      bool hasItems) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border(
          top: BorderSide(
              color: colorScheme.outlineVariant),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Subtotal
          PosTotalRow(
            label: l10n.subtotal,
            value: _fmtCurrency(context, subtotal),
            isDark: isDark,
          ),
          const SizedBox(height: 6),

          // Tax
          PosTotalRow(
            label: '${l10n.tax} (15%)',
            value: _fmtCurrency(context, tax),
            isDark: isDark,
          ),

          // Discount
          if (cartState.discount > 0) ...[
            const SizedBox(height: 6),
            PosTotalRow(
              label: l10n.discount,
              value: '-${_fmtCurrency(context, cartState.discount)}',
              isDark: isDark,
              valueColor: AppColors.success,
            ),
          ],

          Divider(
            height: 20,
            color: colorScheme.outlineVariant,
          ),

          // Grand total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  l10n.grandTotal,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Text(
                _fmtCurrency(context, total),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Action buttons: Draft + Pay
          Row(
            children: [
              // Draft button with held invoices badge
              Expanded(
                flex: 1,
                child: PosDraftButton(
                  hasItems: hasItems,
                  isDark: isDark,
                  label: l10n.draft,
                  onTap: hasItems ? onHoldInvoice : null,
                  onLongPress: onShowHeldInvoices,
                ),
              ),
              const SizedBox(width: 8),

              // Pay button
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: hasItems ? AppColors.primaryGradient : null,
                    color: hasItems ? null : colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: hasItems ? AppShadows.primarySm : null,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: hasItems
                          ? () {
                              if (onPayTap != null) {
                                onPayTap!(total);
                              }
                            }
                          : null,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l10n.pay,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: hasItems
                                    ? colorScheme.onPrimary
                                    : colorScheme.onSurfaceVariant,
                              ),
                            ),
                            if (hasItems) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _fmtCurrency(context, total),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// حوار إدخال خصم مع حماية PIN للخصومات > 20%
  void _showDiscountDialog(BuildContext context, WidgetRef ref, double subtotal) {
    final discountController = TextEditingController();
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.percent_rounded, color: AppColors.success, size: 22),
              const SizedBox(width: 8),
              Expanded(child: Text(l10n.discount, overflow: TextOverflow.ellipsis, maxLines: 1)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: discountController,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l10n.discount,
                  hintText: '0 - 100',
                  suffixText: '%',
                  prefixIcon: const Icon(Icons.percent),
                  border: const OutlineInputBorder(),
                ),
                onSubmitted: (_) => _applyDiscount(
                  dialogContext, context, ref, discountController, subtotal,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => _applyDiscount(
                dialogContext, context, ref, discountController, subtotal,
              ),
              child: Text(l10n.confirm),
            ),
          ],
        );
      },
    ).then((_) => discountController.dispose());
  }

  /// تطبيق الخصم مع التحقق من PIN إذا تجاوز 20%
  Future<void> _applyDiscount(
    BuildContext dialogContext,
    BuildContext parentContext,
    WidgetRef ref,
    TextEditingController controller,
    double subtotal,
  ) async {
    final percent = double.tryParse(controller.text);
    if (percent == null || percent < 0 || percent > 100) return;

    Navigator.pop(dialogContext);

    // إذا الخصم أكثر من 20%: طلب موافقة المشرف
    if (percent > 20) {
      if (!parentContext.mounted) return;
      final approved = await ManagerApprovalService.requestPinApproval(
        context: parentContext,
        action: 'discount_over_20',
      );
      if (!approved) return;
    }

    final discountAmount = subtotal * (percent / 100);
    ref.read(cartStateProvider.notifier).setDiscount(discountAmount);
  }
}

// =============================================================================
// TOTAL ROW
// =============================================================================

class PosTotalRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  final Color? valueColor;

  const PosTotalRow({
    super.key,
    required this.label,
    required this.value,
    required this.isDark,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: valueColor ??
                (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// CART ITEM TILE - Redesigned
// =============================================================================

class PosCartItemTile extends ConsumerWidget {
  final PosCartItem item;

  const PosCartItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Product image
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 56,
            height: 56,
            child: item.product.imageThumbnail != null
                ? CachedNetworkImage(
                    imageUrl: item.product.imageThumbnail!,
                    fit: BoxFit.cover,
                    memCacheWidth: 112,
                    memCacheHeight: 112,
                    placeholder: (_, __) => Container(
                      color: colorScheme.surfaceContainerLow,
                      child: Icon(Icons.image, size: 20,
                          color: colorScheme.onSurfaceVariant),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: colorScheme.surfaceContainerLow,
                      child: Icon(Icons.image, size: 20,
                          color: colorScheme.onSurfaceVariant),
                    ),
                  )
                : Container(
                    color: colorScheme.surfaceContainerLow,
                    child: Icon(Icons.image, size: 20,
                        color: colorScheme.onSurfaceVariant),
                  ),
          ),
        ),
        const SizedBox(width: 10),

        // Name + price
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.product.name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                _fmtCurrency(context, item.effectivePrice),
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),

        // Quantity controls
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Decrease button
            PosQtyButton(
              icon: Icons.remove,
              isDark: isDark,
              isPrimary: false,
              onTap: () {
                if (item.quantity > 1) {
                  ref
                      .read(cartStateProvider.notifier)
                      .decrementQuantity(item.product.id);
                } else {
                  ref
                      .read(cartStateProvider.notifier)
                      .removeProduct(item.product.id);
                }
              },
            ),
            SizedBox(
              width: 28,
              child: Text(
                '${item.quantity}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
            ),
            // Increase button
            PosQtyButton(
              icon: Icons.add,
              isDark: isDark,
              isPrimary: true,
              onTap: () {
                ref
                    .read(cartStateProvider.notifier)
                    .incrementQuantity(item.product.id);
              },
            ),
          ],
        ),

        const SizedBox(width: 6),

        // Edit button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              int qty = item.quantity;
              final priceCtrl = TextEditingController(
                text: (item.customPrice ?? item.product.price).toStringAsFixed(2),
              );
              showDialog<void>(
                context: context,
                builder: (ctx) => StatefulBuilder(
                  builder: (ctx, setDialogState) => AlertDialog(
                    title: Text(item.product.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(child: Text(l10n.quantityColon, style: const TextStyle(fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis, maxLines: 1)),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: qty > 1 ? () => setDialogState(() => qty--) : null,
                                ),
                                Text('$qty', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () => setDialogState(() => qty++),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: priceCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textDirection: TextDirection.ltr,
                          decoration: InputDecoration(
                            labelText: l10n.price,
                            suffixText: l10n.riyal,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
                      FilledButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          ref.read(cartStateProvider.notifier).updateQuantity(item.product.id, qty);
                          final newPrice = double.tryParse(priceCtrl.text.trim());
                          if (newPrice != null && newPrice > 0 && newPrice != item.product.price) {
                            ref.read(cartStateProvider.notifier).setCustomPrice(item.product.id, newPrice);
                          }
                        },
                        child: Text(l10n.confirm),
                      ),
                    ],
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.edit_outlined,
                size: 18,
                color: AppColors.info.withValues(alpha: 0.7),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// QUANTITY BUTTON
// =============================================================================

class PosQtyButton extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final bool isPrimary;
  final VoidCallback onTap;

  const PosQtyButton({
    super.key,
    required this.icon,
    required this.isDark,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: isPrimary
          ? AppColors.primary
          : colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: isPrimary
            ? BorderSide.none
            : BorderSide(
                color: colorScheme.outlineVariant,
                width: 0.5,
              ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 28,
          height: 28,
          child: Icon(
            icon,
            size: 16,
            color: isPrimary
                ? colorScheme.onPrimary
                : isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// DRAFT BUTTON WITH BADGE
// =============================================================================

class PosDraftButton extends ConsumerWidget {
  final bool hasItems;
  final bool isDark;
  final String label;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const PosDraftButton({
    super.key,
    required this.hasItems,
    required this.isDark,
    required this.label,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heldCount = ref.watch(dbHeldInvoicesCountProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onLongPress: onLongPress,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          OutlinedButton(
            onPressed: hasItems ? onTap : (heldCount > 0 ? onLongPress : null),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(
                color: heldCount > 0
                    ? AppColors.warning
                    : colorScheme.outlineVariant,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (heldCount > 0) ...[
                  const Icon(Icons.pause_circle_outline, size: 16, color: AppColors.warning),
                  const SizedBox(width: 4),
                ],
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: heldCount > 0
                          ? AppColors.warning
                          : isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          // Badge
          if (heldCount > 0)
            PositionedDirectional(
              top: -6,
              end: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                decoration: const BoxDecoration(
                  color: AppColors.warning,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$heldCount',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
