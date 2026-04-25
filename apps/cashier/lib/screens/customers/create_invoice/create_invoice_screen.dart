/// Create Invoice Screen — Container (post-3.4)
///
/// كان ملفاً واحداً (~1050 سطر، 35 setState). تم تقسيمه إلى:
/// - providers/invoice_draft_notifier.dart (الحالة)
/// - widgets/customer_picker.dart
/// - widgets/items_editor.dart
/// - widgets/invoice_summary.dart
/// - widgets/payment_terms_selector.dart
///
/// الـ container مسؤول فقط عن:
/// 1. Layout (single / wide / medium)
/// 2. Header (AppHeader)
/// 3. Actions (Finalize + Save as draft)
/// 4. Feedback hooks (HapticShim + SoundService) — Phase 2
/// 5. معالجة `ZatcaComplianceException` عند تكامل invoice_service
///
/// ملاحظة عن ZATCA (Phase 1):
/// - حالياً `_saveInvoice` يحاكي الحفظ (كما في النسخة السابقة) ولا يستدعي
///   `invoice_service.upsertInvoice` بعد؛ عند التكامل الفعلي يجب:
///     * تحويل السعر من SAR (double) إلى cents (int) قبل الاستدعاء.
///     * التقاط `ZatcaComplianceException` — يعني القيمة لم تُحفظ لأن
///       توليد QR فشل؛ نعرض حواراً واضحاً ونستدعي `reportError`.
/// - حافظنا على Feedback hooks كما في الأصل (:995-1013 سابقاً).
///
/// Supports: RTL Arabic, dark/light theme, responsive layout.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_core/alhai_core.dart' show Product;
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_pos/alhai_pos.dart'
    show
        CreditCheckExceeded,
        CreditCheckWarning,
        CreditLimitEnforcer,
        PosCartItem,
        ZatcaComplianceException,
        saleServiceProvider,
        showCreditLimitExceededDialog,
        showCreditLimitWarning;
import 'package:alhai_design_system/alhai_design_system.dart'
    show AlhaiBreakpoints, AlhaiSnackbar, AlhaiSpacing;

import '../../../core/services/sentry_service.dart';
import '../../../core/services/audit_service.dart';
import '../../../core/services/haptic_shim.dart';
import '../../../core/services/sound_service.dart';

import 'providers/invoice_draft_notifier.dart';
import 'widgets/customer_picker.dart';
import 'widgets/items_editor.dart';
import 'widgets/invoice_summary.dart';
import 'widgets/payment_terms_selector.dart';

/// شاشة إنشاء فاتورة (container)
class CreateInvoiceScreen extends ConsumerStatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  ConsumerState<CreateInvoiceScreen> createState() =>
      _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends ConsumerState<CreateInvoiceScreen> {
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // P2 #3: load the store's configured tax rate so the summary shows the
    // correct VAT (may differ from 15% for non-SA or reduced-rate tenants).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId != null) {
        ref.read(invoiceDraftProvider.notifier).loadTaxRate(storeId);
      }
    });
  }

  String _getDateSubtitle(AppLocalizations l10n) {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year} \u2022 ${l10n.mainBranch}';
  }

  Future<void> _saveInvoice(bool isDraft, AppLocalizations l10n) async {
    final draft = ref.read(invoiceDraftProvider);
    if (!draft.canSubmit) return;

    final storeId = ref.read(currentStoreIdProvider);
    if (storeId == null) {
      AlhaiSnackbar.error(context, l10n.errorOccurred);
      return;
    }
    final user = ref.read(currentUserProvider);

    setState(() => _isSubmitting = true);

    try {
      // Drafts are not persisted yet (no invoices.is_draft column). Until
      // the schema migration lands, surface the gap honestly instead of
      // showing a fake "saved" toast.
      if (isDraft) {
        if (!mounted) return;
        AlhaiSnackbar.warning(
          context,
          'حفظ المسودة غير متاح بعد — أنهِ الفاتورة لتسجيلها',
        );
        return;
      }

      // Resolve each draft item to a live Product row. The draft only
      // carries productId + display price; SaleService.createSale needs
      // the full Product domain object so it can revalidate stock and
      // record cost-of-goods correctly.
      final db = GetIt.I<AppDatabase>();
      final cartItems = <PosCartItem>[];
      for (final item in draft.items) {
        final p = await db.productsDao.getProductById(item.productId);
        if (p == null) {
          throw StateError('المنتج "${item.productName}" لم يعد موجوداً');
        }
        final productModel = Product(
          id: p.id,
          storeId: p.storeId,
          name: p.name,
          sku: p.sku,
          barcode: p.barcode,
          price: p.price,
          costPrice: p.costPrice,
          stockQty: p.stockQty,
          minQty: p.minQty,
          unit: p.unit,
          description: p.description,
          imageThumbnail: p.imageThumbnail,
          imageMedium: p.imageMedium,
          imageLarge: p.imageLarge,
          imageHash: p.imageHash,
          categoryId: p.categoryId,
          isActive: p.isActive,
          trackInventory: p.trackInventory,
          createdAt: p.createdAt,
          updatedAt: p.updatedAt,
        );
        // Honor the price the cashier put on the draft (could differ
        // from the catalog price for negotiated quotes).
        cartItems.add(
          PosCartItem(
            product: productModel,
            quantity: item.qty,
            customPrice: item.price,
          ),
        );
      }

      // P0-13: credit-limit pre-flight. The whole `total` is going to
      // sit on the customer's receivable account, so check the projected
      // balance against the limit before committing.
      var didOverride = false;
      CreditCheckExceeded? overrideContext;
      final customerId = draft.selectedCustomer?.id;
      if (customerId != null && customerId.isNotEmpty) {
        final enforcer = CreditLimitEnforcer(db: db);
        final check = await enforcer.checkByCustomer(
          customerId: customerId,
          storeId: storeId,
          proposedDeltaCents: (draft.total * 100).round(),
        );
        if (check is CreditCheckExceeded) {
          if (!mounted) {
            setState(() => _isSubmitting = false);
            return;
          }
          final approved = await showCreditLimitExceededDialog(context, check);
          if (!approved) {
            setState(() => _isSubmitting = false);
            return;
          }
          didOverride = true;
          overrideContext = check;
        } else if (check is CreditCheckWarning) {
          if (mounted) showCreditLimitWarning(context, check);
        }
      }

      // Credit invoice: customer owes the total, no cash collected upfront.
      // SaleService internally creates the matching invoice row through
      // InvoiceService (ZATCA QR + sync enqueue) — anything that fails
      // there throws ZatcaComplianceException so we can route the user to
      // the right remediation rather than swallow the error.
      final saleService = ref.read(saleServiceProvider);
      final result = await saleService.createSale(
        storeId: storeId,
        cashierId: user?.id ?? '',
        items: cartItems,
        subtotal: draft.subtotal,
        discount: draft.discount,
        tax: draft.tax,
        total: draft.total,
        paymentMethod: 'credit',
        amountReceived: 0,
        creditAmount: draft.total,
        customerId: draft.selectedCustomer?.id,
        customerName: draft.selectedCustomer?.name,
        customerPhone: draft.selectedCustomer?.phone,
        notes: draft.dueDate != null
            ? 'Credit invoice — due ${draft.dueDate!.toIso8601String()}'
            : null,
      );

      auditService.logSaleCreate(
        storeId: storeId,
        userId: user?.id ?? 'unknown',
        userName: user?.name ?? 'unknown',
        saleId: result.saleId,
        total: draft.total,
        paymentMethod: 'credit',
      );

      // P0-13: audit trail for the credit-limit override (if any).
      if (didOverride && overrideContext != null && customerId != null) {
        final accountId = await db.accountsDao
            .getCustomerAccount(customerId, storeId)
            .then((a) => a?.id ?? customerId);
        auditService.logCreditLimitOverride(
          storeId: storeId,
          userId: user?.id ?? 'unknown',
          userName: user?.name ?? 'unknown',
          accountId: accountId,
          accountName: draft.selectedCustomer?.name ?? customerId,
          currentBalanceCents: overrideContext.currentBalanceCents,
          limitCents: overrideContext.limitCents,
          newBalanceCents: overrideContext.newBalanceCents,
          overByCents: overrideContext.overByCents,
          entityType: 'sale',
          entityId: result.saleId,
        );
      }

      addBreadcrumb(
        message: 'Invoice finalized',
        category: 'sale',
        data: {
          'saleId': result.saleId,
          'items': draft.items.length,
          'customer': draft.selectedCustomer?.name,
        },
      );

      if (!mounted) return;
      HapticShim.heavyImpact();
      SoundService.instance.saleSuccess();
      AlhaiSnackbar.success(context, l10n.paymentSuccessful);

      ref.read(invoiceDraftProvider.notifier).reset();
    } on ZatcaComplianceException catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Save invoice (ZATCA)');
      if (!mounted) return;
      HapticShim.vibrate();
      SoundService.instance.errorBuzz();
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 48,
          ),
          title: Text(l10n.error),
          content: Text(
            'فشل توليد رمز ZATCA QR — لم تُحفظ الفاتورة. تحقّق من بيانات المتجر (الاسم، رقم الضريبة) ثم أعد المحاولة.\n\n${e.message}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.close),
            ),
          ],
        ),
      );
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Save invoice');
      if (!mounted) return;
      HapticShim.vibrate();
      SoundService.instance.errorBuzz();
      AlhaiSnackbar.error(context, l10n.errorWithDetails('$e'));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width >= AlhaiBreakpoints.desktop;
    final isMediumScreen = size.width >= AlhaiBreakpoints.tablet;
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider);
    final canSubmit =
        ref.watch(invoiceDraftProvider.select((s) => s.canSubmit));

    return Column(
      children: [
        AppHeader(
          title: l10n.createInvoice,
          subtitle: _getDateSubtitle(l10n),
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
          child: SingleChildScrollView(
            padding: EdgeInsets.all(
              isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md,
            ),
            child: isWideScreen
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            CustomerPicker(),
                            SizedBox(height: AlhaiSpacing.lg),
                            ItemsEditor(),
                          ],
                        ),
                      ),
                      const SizedBox(width: AlhaiSpacing.lg),
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            const InvoiceSummary(),
                            const SizedBox(height: AlhaiSpacing.lg),
                            const PaymentTermsSelector(),
                            const SizedBox(height: AlhaiSpacing.lg),
                            _buildActions(l10n, canSubmit),
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const CustomerPicker(),
                      SizedBox(
                        height: isMediumScreen
                            ? AlhaiSpacing.lg
                            : AlhaiSpacing.md,
                      ),
                      const ItemsEditor(),
                      SizedBox(
                        height: isMediumScreen
                            ? AlhaiSpacing.lg
                            : AlhaiSpacing.md,
                      ),
                      const InvoiceSummary(),
                      const SizedBox(height: AlhaiSpacing.lg),
                      const PaymentTermsSelector(),
                      const SizedBox(height: AlhaiSpacing.lg),
                      _buildActions(l10n, canSubmit),
                      const SizedBox(height: AlhaiSpacing.lg),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(AppLocalizations l10n, bool canSubmit) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _isSubmitting || !canSubmit
                ? null
                : () => _saveInvoice(false, l10n),
            icon: _isSubmitting
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.onPrimary,
                    ),
                  )
                : const Icon(Icons.check_circle_rounded, size: 20),
            label: Text(
              l10n.finalizeInvoice,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: AlhaiSpacing.sm),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isSubmitting || !canSubmit
                ? null
                : () => _saveInvoice(true, l10n),
            icon: const Icon(Icons.save_outlined, size: 20),
            label: Text(
              l10n.saveAsDraft,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.onSurfaceVariant,
              side: BorderSide(color: colorScheme.outlineVariant),
              padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
