/// Payment Terms Selector — اختيار شروط الدفع + تاريخ الاستحقاق
///
/// يعرض chips لاختيار المدة (فوري / صافي 15 / 30 / 60) ويحسب تاريخ
/// الاستحقاق تلقائياً؛ يمكن للمستخدم تعديل التاريخ يدوياً عبر
/// `showDatePicker`. لا يُنفّذ `setState` محلّي — كل الحالة في
/// [invoiceDraftProvider].
///
/// ملاحظة: هذه UI إضافية فوق الشاشة الأصلية؛ `paymentTerm` و`dueDate`
/// سيُمرّران إلى `invoice_service.upsertInvoice` عند التكامل، لكن حالياً
/// يبقى الحفظ simulated كما في النسخة السابقة.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_design_system/alhai_design_system.dart' show AlhaiSpacing;

import '../providers/invoice_draft_notifier.dart';

class PaymentTermsSelector extends ConsumerWidget {
  const PaymentTermsSelector({super.key});

  /// نصوص شروط الدفع inline (لا توجد مفاتيح l10n لها بعد؛ تجنّباً لتعديل
  /// packages في إطار هذه المهمة نستخدم عربي مباشر كباقي الشاشة).
  String _dueLabel(PaymentTerm term) {
    switch (term) {
      case PaymentTerm.immediate:
        return 'فوري';
      case PaymentTerm.net15:
        return 'صافي 15 يوم';
      case PaymentTerm.net30:
        return 'صافي 30 يوم';
      case PaymentTerm.net60:
        return 'صافي 60 يوم';
    }
  }

  String _fmtDate(DateTime d) =>
      '${d.day}/${d.month}/${d.year}';

  Future<void> _pickDate(BuildContext context, WidgetRef ref) async {
    final current = ref.read(invoiceDraftProvider).dueDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      ref.read(invoiceDraftProvider.notifier).setDueDate(picked);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final term = ref.watch(invoiceDraftProvider.select((s) => s.paymentTerm));
    final dueDate = ref.watch(invoiceDraftProvider.select((s) => s.dueDate));

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.schedule_rounded,
                  color: AppColors.info,
                  size: 20,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(
                l10n.paymentTerms,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.md),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: PaymentTerm.values.map((t) {
              final selected = t == term;
              return InkWell(
                onTap: () => ref
                    .read(invoiceDraftProvider.notifier)
                    .setPaymentTerm(t),
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AlhaiSpacing.md,
                    vertical: AlhaiSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: selected
                          ? AppColors.primary
                          : colorScheme.outlineVariant,
                    ),
                  ),
                  child: Text(
                    _dueLabel(t),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: selected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: selected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (term != PaymentTerm.immediate) ...[
            const SizedBox(height: AlhaiSpacing.md),
            InkWell(
              onTap: () => _pickDate(context, ref),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(AlhaiSpacing.md),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.event_rounded,
                      size: 20,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AlhaiSpacing.sm),
                    Text(
                      l10n.dueDate,
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      dueDate != null ? _fmtDate(dueDate) : '--/--/----',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
