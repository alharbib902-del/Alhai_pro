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
import 'package:go_router/go_router.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
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

  String _getDateSubtitle(AppLocalizations l10n) {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year} \u2022 ${l10n.mainBranch}';
  }

  Future<void> _saveInvoice(bool isDraft, AppLocalizations l10n) async {
    final draft = ref.read(invoiceDraftProvider);
    if (!draft.canSubmit) return;

    setState(() => _isSubmitting = true);

    try {
      // Simulate saving invoice (unchanged from pre-3.4 behaviour).
      //
      // TODO(c-4/zatca): استدعاء `invoice_service.upsertInvoice` الفعلي هنا
      // مع تحويل الأسعار SAR→cents. ارفع `ZatcaComplianceException` عند
      // فشل توليد QR (Phase 1 fix) ومعالجته في catch block أدناه.
      await Future.delayed(const Duration(seconds: 1));

      // Audit log (only for finalized invoices)
      if (!isDraft) {
        final user = ref.read(currentUserProvider);
        final storeId = ref.read(currentStoreIdProvider);
        if (storeId == null) return;
        auditService.logSaleCreate(
          storeId: storeId,
          userId: user?.id ?? 'unknown',
          userName: user?.name ?? 'unknown',
          saleId: 'invoice-${DateTime.now().millisecondsSinceEpoch}',
          total: draft.total,
          paymentMethod: 'credit',
        );
      }

      addBreadcrumb(
        message: isDraft ? 'Invoice saved as draft' : 'Invoice finalized',
        category: 'sale',
        data: {
          'items': draft.items.length,
          'customer': draft.selectedCustomer?.name,
        },
      );

      if (!mounted) return;
      // Phase 2 Feedback hooks — success.
      HapticShim.heavyImpact();
      SoundService.instance.saleSuccess();
      AlhaiSnackbar.success(
        context,
        isDraft ? 'Invoice saved as draft' : 'Invoice finalized successfully',
      );

      if (!isDraft) {
        // Reset form via provider (single action instead of setState).
        ref.read(invoiceDraftProvider.notifier).reset();
      }
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Save invoice');
      if (!mounted) return;
      // Phase 2 Feedback hooks — failure.
      HapticShim.vibrate();
      SoundService.instance.errorBuzz();
      // Note: when invoice_service integration lands, catch
      // `ZatcaComplianceException` explicitly to show a dedicated dialog
      // ("QR generation failed — invoice NOT saved").
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
          title: 'Create Invoice',
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
