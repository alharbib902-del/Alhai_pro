/// Distributor detail admin screen — full review before approve/reject.
///
/// Shows company info, uploaded documents, and action buttons.
/// super_admin only.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/distributor_account_status.dart';
import '../../data/models/distributor_document.dart';
import '../../providers/admin_providers.dart';

class DistributorDetailAdminScreen extends ConsumerWidget {
  final String orgId;

  const DistributorDetailAdminScreen({super.key, required this.orgId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncDistributor = ref.watch(distributorDetailProvider(orgId));
    final asyncDocs = ref.watch(orgDocumentsProvider(orgId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الموزع'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin'),
        ),
      ),
      body: asyncDistributor.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('فشل تحميل البيانات: $error'),
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: () =>
                    ref.invalidate(distributorDetailProvider(orgId)),
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
        data: (distributor) {
          final theme = Theme.of(context);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Company Info Card ──
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: theme.colorScheme.primary
                                      .withValues(alpha: 0.1),
                                  child: Icon(
                                    Icons.business,
                                    color: theme.colorScheme.primary,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        distributor.displayName,
                                        style: theme.textTheme.headlineSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      _StatusChip(status: distributor.status),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 32),
                            _DetailRow(
                              label: 'السجل التجاري',
                              value: distributor.commercialReg,
                            ),
                            _DetailRow(
                              label: 'الرقم الضريبي',
                              value: distributor.taxNumber,
                            ),
                            _DetailRow(
                              label: 'المدينة',
                              value: distributor.city,
                            ),
                            _DetailRow(
                              label: 'العنوان',
                              value: distributor.address,
                            ),
                            _DetailRow(
                              label: 'الهاتف',
                              value: distributor.phone,
                            ),
                            _DetailRow(
                              label: 'البريد',
                              value: distributor.email,
                            ),
                            if (distributor.termsAcceptedAt != null)
                              _DetailRow(
                                label: 'قبول الشروط',
                                value: _formatDate(
                                  distributor.termsAcceptedAt!,
                                ),
                              ),
                            _DetailRow(
                              label: 'تاريخ التسجيل',
                              value: _formatDate(distributor.createdAt),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Documents Section ──
                    Text(
                      'الوثائق المرفوعة',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    asyncDocs.when(
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (error, _) => Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text('فشل تحميل الوثائق: $error'),
                        ),
                      ),
                      data: (docs) {
                        if (docs.isEmpty) {
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.folder_open,
                                      size: 48,
                                      color: theme.colorScheme.outline,
                                    ),
                                    const SizedBox(height: 8),
                                    const Text('لا توجد وثائق مرفوعة'),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                        return Column(
                          children: docs
                              .map(
                                (doc) => _DocumentReviewCard(
                                  document: doc,
                                  orgId: orgId,
                                ),
                              )
                              .toList(),
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // ── Action Buttons ──
                    if (distributor.status ==
                        DistributorAccountStatus.pendingReview) ...[
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () =>
                                  _approveDistributor(context, ref),
                              icon: const Icon(Icons.check),
                              label: const Text('اعتماد الموزع'),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () => _rejectDistributor(context, ref),
                              icon: const Icon(Icons.close),
                              label: const Text('رفض الموزع'),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (distributor.status ==
                        DistributorAccountStatus.active) ...[
                      FilledButton.icon(
                        onPressed: () => _suspendDistributor(context, ref),
                        icon: const Icon(Icons.block),
                        label: const Text('إيقاف الموزع'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                    ],
                    if (distributor.status ==
                        DistributorAccountStatus.suspended) ...[
                      FilledButton.icon(
                        onPressed: () => _reinstateDistributor(context, ref),
                        icon: const Icon(Icons.restore),
                        label: const Text('إعادة تفعيل الموزع'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/'
        '${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _approveDistributor(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الاعتماد'),
        content: const Text(
          'هل تريد اعتماد هذا الموزع؟\n\n'
          'سيتمكن من الوصول الكامل للمنصة فوراً.\n'
          'هذا الإجراء يُسجّل في سجل المراجعات.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('نعم، اعتماد'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(adminServiceProvider).approveDistributor(orgId);
      ref.invalidate(distributorDetailProvider(orgId));
      ref.invalidate(pendingDistributorsProvider);
      ref.invalidate(unreadNotificationCountProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم اعتماد الموزع بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل الاعتماد: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rejectDistributor(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('رفض الموزع'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('هذا الإجراء يُسجّل في سجل المراجعات.'),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: 'سبب الرفض (مطلوب)',
                    hintText: '10 أحرف على الأقل',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  maxLength: 500,
                  onChanged: (_) => setDialogState(() {}),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: controller.text.trim().length >= 10
                  ? () => Navigator.of(ctx).pop(controller.text.trim())
                  : null,
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('رفض'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();

    if (result == null || result.isEmpty || !context.mounted) return;

    try {
      await ref.read(adminServiceProvider).rejectDistributor(orgId, result);
      ref.invalidate(distributorDetailProvider(orgId));
      ref.invalidate(pendingDistributorsProvider);
      ref.invalidate(unreadNotificationCountProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم رفض الموزع'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _suspendDistributor(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('إيقاف الموزع'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('سيتم إيقاف وصول الموزع للمنصة فوراً.'),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: 'سبب الإيقاف (مطلوب)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  maxLength: 500,
                  onChanged: (_) => setDialogState(() {}),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: controller.text.trim().length >= 10
                  ? () => Navigator.of(ctx).pop(controller.text.trim())
                  : null,
              style: FilledButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('إيقاف'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();

    if (result == null || result.isEmpty || !context.mounted) return;

    try {
      await ref.read(adminServiceProvider).suspendDistributor(orgId, result);
      ref.invalidate(distributorDetailProvider(orgId));
      ref.invalidate(pendingDistributorsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إيقاف الموزع'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _reinstateDistributor(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إعادة تفعيل الموزع'),
        content: const Text('هل تريد إعادة تفعيل هذا الموزع؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('إعادة تفعيل'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(adminServiceProvider).reinstateDistributor(orgId);
      ref.invalidate(distributorDetailProvider(orgId));
      ref.invalidate(pendingDistributorsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إعادة تفعيل الموزع'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// Helper widgets
// ═══════════════════════════════════════════════════════════════

class _StatusChip extends StatelessWidget {
  final DistributorAccountStatus status;

  const _StatusChip({required this.status});

  Color get _color {
    switch (status) {
      case DistributorAccountStatus.pendingEmailVerification:
        return Colors.blue;
      case DistributorAccountStatus.pendingReview:
        return Colors.orange;
      case DistributorAccountStatus.active:
        return Colors.green;
      case DistributorAccountStatus.rejected:
        return Colors.red;
      case DistributorAccountStatus.suspended:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.arabicLabel,
        style: TextStyle(
          color: _color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String? value;

  const _DetailRow({required this.label, this.value});

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(value!, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _DocumentReviewCard extends ConsumerWidget {
  final DistributorDocument document;
  final String orgId;

  const _DocumentReviewCard({required this.document, required this.orgId});

  Color get _statusColor {
    switch (document.status) {
      case DocumentStatus.underReview:
        return Colors.orange;
      case DocumentStatus.approved:
        return Colors.green;
      case DocumentStatus.rejected:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.description_outlined,
              color: theme.colorScheme.primary,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document.documentType.arabicName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${document.fileName} (${document.fileSizeFormatted})',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      document.status.arabicName,
                      style: TextStyle(color: _statusColor, fontSize: 11),
                    ),
                  ),
                  if (document.rejectionReason != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'سبب الرفض: ${document.rejectionReason}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.red.shade700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Actions for documents under review
            if (document.status == DocumentStatus.underReview) ...[
              IconButton(
                icon: const Icon(Icons.check_circle_outline),
                color: Colors.green,
                tooltip: 'موافقة',
                onPressed: () => _approveDoc(context, ref),
              ),
              IconButton(
                icon: const Icon(Icons.cancel_outlined),
                color: Colors.red,
                tooltip: 'رفض',
                onPressed: () => _rejectDoc(context, ref),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _approveDoc(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(adminServiceProvider).approveDocument(document.id);
      ref.invalidate(orgDocumentsProvider(orgId));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم الموافقة على المستند'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _rejectDoc(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('رفض المستند'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'سبب الرفض',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
            onChanged: (_) => setDialogState(() {}),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: controller.text.trim().length >= 5
                  ? () => Navigator.of(ctx).pop(controller.text.trim())
                  : null,
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('رفض'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();

    if (result == null || !context.mounted) return;

    try {
      await ref.read(adminServiceProvider).rejectDocument(document.id, result);
      ref.invalidate(orgDocumentsProvider(orgId));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم رفض المستند'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
