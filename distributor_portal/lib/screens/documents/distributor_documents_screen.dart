/// Distributor Documents Screen - manage legal documents (CR, VAT, ID).
///
/// Upload, view, and track verification status of legal documents.
/// Supports: RTL Arabic, dark/light theme, responsive layout.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import '../../core/utils/open_url.dart';
import '../../data/models.dart';
import '../../providers/distributor_providers.dart';
import '../../ui/skeleton_loading.dart';
import 'upload_document_dialog.dart';

class DistributorDocumentsScreen extends ConsumerWidget {
  const DistributorDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docsAsync = ref.watch(distributorDocumentsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      body: docsAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(AlhaiSpacing.lg),
          child: TableSkeleton(),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.getTextSecondary(isDark),
              ),
              const SizedBox(height: AlhaiSpacing.sm),
              Text(
                'فشل تحميل الوثائق',
                style: TextStyle(color: AppColors.getTextSecondary(isDark)),
              ),
              const SizedBox(height: AlhaiSpacing.sm),
              FilledButton.tonal(
                onPressed: () => ref.invalidate(distributorDocumentsProvider),
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
        data: (docs) => _DocumentsBody(documents: docs),
      ),
    );
  }
}

class _DocumentsBody extends ConsumerWidget {
  final List<DistributorDocument> documents;

  const _DocumentsBody({required this.documents});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= AlhaiBreakpoints.desktop;

    // Group documents by type for easy lookup
    final docsByType = <DocumentType, DistributorDocument>{};
    for (final doc in documents) {
      // Keep the most recent (first, since ordered DESC)
      docsByType.putIfAbsent(doc.documentType, () => doc);
    }

    // Types with active docs (can't upload duplicate)
    final disabledTypes = documents
        .where(
          (d) =>
              d.status == DocumentStatus.underReview ||
              d.status == DocumentStatus.approved,
        )
        .map((d) => d.documentType)
        .toList();

    // Missing required types
    final missingRequired = DocumentType.values
        .where((t) => t.isRequired && !docsByType.containsKey(t))
        .toList();

    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? AlhaiSpacing.xl : AlhaiSpacing.md),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الوثائق والشهادات',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: AlhaiSpacing.xxs),
                        Text(
                          'ارفع الوثائق المطلوبة للتحقق من حسابك',
                          style: TextStyle(
                            color: AppColors.getTextSecondary(isDark),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () async {
                      final result = await showUploadDocumentDialog(
                        context,
                        disabledTypes: disabledTypes,
                      );
                      if (result != null) {
                        ref.invalidate(distributorDocumentsProvider);
                      }
                    },
                    icon: const Icon(Icons.upload_file, size: 18),
                    label: const Text('رفع وثيقة جديدة'),
                  ),
                ],
              ),

              // Missing documents warning
              if (missingRequired.isNotEmpty) ...[
                const SizedBox(height: AlhaiSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AlhaiSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.warning,
                        size: 22,
                      ),
                      const SizedBox(width: AlhaiSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'وثائق مطلوبة',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: AlhaiSpacing.xxs),
                            ...missingRequired.map(
                              (t) => Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AlhaiSpacing.xxs,
                                ),
                                child: Text(
                                  '• ${t.arabicName}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.getTextSecondary(isDark),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: AlhaiSpacing.lg),

              // Document list
              if (documents.isEmpty)
                _EmptyState(isDark: isDark)
              else
                ...documents.map(
                  (doc) => Padding(
                    padding: const EdgeInsets.only(bottom: AlhaiSpacing.sm),
                    child: _DocumentCard(document: doc),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isDark;
  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xxl),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(
            Icons.description_outlined,
            size: 56,
            color: AppColors.getTextSecondary(isDark),
          ),
          const SizedBox(height: AlhaiSpacing.md),
          Text(
            'لا توجد وثائق مرفوعة',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xs),
          Text(
            'ارفع السجل التجاري وشهادة الضريبة للتحقق من حسابك',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentCard extends ConsumerWidget {
  final DistributorDocument document;
  const _DocumentCard({required this.document});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // File type icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _getStatusColor(document.status).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              document.mimeType == 'application/pdf'
                  ? Icons.picture_as_pdf
                  : Icons.image,
              color: _getStatusColor(document.status),
              size: 24,
            ),
          ),
          const SizedBox(width: AlhaiSpacing.md),

          // Document info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.documentType.arabicName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.xxs),
                Text(
                  '${document.fileName} (${document.fileSizeFormatted})',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.getTextSecondary(isDark),
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.xs),
                Row(
                  children: [
                    _StatusBadge(status: document.status),
                    if (document.expiryDate != null) ...[
                      const SizedBox(width: AlhaiSpacing.sm),
                      _ExpiryBadge(
                        expiryDate: document.expiryDate!,
                        isDark: isDark,
                      ),
                    ],
                  ],
                ),
                if (document.status == DocumentStatus.rejected &&
                    document.rejectionReason != null) ...[
                  const SizedBox(height: AlhaiSpacing.xs),
                  Container(
                    padding: const EdgeInsets.all(AlhaiSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 16,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: AlhaiSpacing.xs),
                        Expanded(
                          child: Text(
                            'سبب الرفض: ${document.rejectionReason}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: AlhaiSpacing.xxs),
                Text(
                  'رُفع: ${_formatDate(document.uploadedAt)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.getTextSecondary(isDark),
                  ),
                ),
              ],
            ),
          ),

          // Actions
          Column(
            children: [
              // View button
              IconButton(
                onPressed: () => _viewDocument(context, ref),
                icon: const Icon(Icons.open_in_new, size: 20),
                tooltip: 'عرض',
                style: IconButton.styleFrom(foregroundColor: AppColors.primary),
              ),
              // Delete button (only if not approved)
              if (document.canDelete)
                IconButton(
                  onPressed: () => _confirmDelete(context, ref),
                  icon: const Icon(Icons.delete_outline, size: 20),
                  tooltip: 'حذف',
                  style: IconButton.styleFrom(foregroundColor: AppColors.error),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _viewDocument(BuildContext context, WidgetRef ref) async {
    try {
      final ds = ref.read(distributorDatasourceProvider);
      final url = await ds.getDocumentSignedUrl(document.fileUrl);
      openUrlInNewTab(url);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل فتح الملف: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف الوثيقة'),
        content: Text('هل تريد حذف "${document.documentType.arabicName}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text(
              'حذف',
              style: TextStyle(color: AppColors.textOnPrimary),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final ds = ref.read(distributorDatasourceProvider);
      await ds.deleteDocument(document.id);
      ref.invalidate(distributorDocumentsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم حذف الوثيقة')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل حذف الوثيقة: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Color _getStatusColor(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.underReview:
        return AppColors.warning;
      case DocumentStatus.approved:
        return AppColors.success;
      case DocumentStatus.rejected:
        return AppColors.error;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _StatusBadge extends StatelessWidget {
  final DocumentStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (status) {
      DocumentStatus.underReview => (AppColors.warning, Icons.schedule),
      DocumentStatus.approved => (AppColors.success, Icons.check_circle),
      DocumentStatus.rejected => (AppColors.error, Icons.cancel),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AlhaiSpacing.sm,
        vertical: AlhaiSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            status.arabicName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpiryBadge extends StatelessWidget {
  final DateTime expiryDate;
  final bool isDark;
  const _ExpiryBadge({required this.expiryDate, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isExpired = expiryDate.isBefore(now);
    final isNearExpiry =
        !isExpired && expiryDate.isBefore(now.add(const Duration(days: 30)));
    final color = isExpired
        ? AppColors.error
        : isNearExpiry
        ? AppColors.warning
        : AppColors.getTextSecondary(isDark);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AlhaiSpacing.sm,
        vertical: AlhaiSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isExpired
            ? 'منتهية الصلاحية'
            : 'انتهاء: ${expiryDate.year}-${expiryDate.month.toString().padLeft(2, '0')}-${expiryDate.day.toString().padLeft(2, '0')}',
        style: TextStyle(fontSize: 11, color: color),
      ),
    );
  }
}
