import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_ai/alhai_ai.dart'
    show AiInvoiceService, AiInvoiceException;
import 'package:alhai_design_system/alhai_design_system.dart';

/// AI Invoice Import Screen - شاشة استيراد الفاتورة بالذكاء الاصطناعي
class AiInvoiceImportScreen extends ConsumerStatefulWidget {
  const AiInvoiceImportScreen({super.key});

  @override
  ConsumerState<AiInvoiceImportScreen> createState() =>
      _AiInvoiceImportScreenState();
}

class _AiInvoiceImportScreenState extends ConsumerState<AiInvoiceImportScreen> {
  final _picker = ImagePicker();
  bool _isProcessing = false;
  String? _imagePath;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = AlhaiBreakpoints.isDesktop(size.width);
    final isMediumScreen = size.width >= AlhaiBreakpoints.tablet;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        AppHeader(
          title: l10n.aiInvoiceImport,
          onMenuTap:
              isWideScreen ? null : () => Scaffold.of(context).openDrawer(),
          onNotificationsTap: () => context.push('/notifications'),
          notificationsCount: 3,
          userName: l10n.cashCustomer,
          userRole: l10n.branchManager,
        ),
        Expanded(
          child: _isProcessing
              ? _buildProcessingView(isDark)
              : _imagePath == null
                  ? _buildUploadView(isWideScreen, isMediumScreen, isDark)
                  : _buildPreviewView(isDark),
        ),
      ],
    );
  }

  Widget _buildUploadView(bool isWideScreen, bool isMediumScreen, bool isDark) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
      child: Column(
        children: [
          Row(children: [
            IconButton(
              onPressed: () => context.pop(),
              icon: Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.arrow_forward_rounded
                    : Icons.arrow_back_rounded,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              tooltip: AppLocalizations.of(context).back,
            ),
          ]),
          const SizedBox(height: AlhaiSpacing.lg),
          Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(AlhaiSpacing.xxxl),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border:
                  Border.all(color: Theme.of(context).dividerColor, width: 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final iconSize = constraints.maxWidth < 400 ? 80.0 : 120.0;
                    return Container(
                      width: iconSize,
                      height: iconSize,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          AppColors.info.withValues(alpha: 0.15),
                          AppColors.info.withValues(alpha: 0.05)
                        ]),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.document_scanner,
                          size: iconSize * 0.47, color: AppColors.info),
                    );
                  },
                ),
                const SizedBox(height: AlhaiSpacing.xl),
                Text(l10n.importSupplierInvoice,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: AlhaiSpacing.sm),
                Text(
                  l10n.captureOrSelectPhoto,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.6),
                ),
                const SizedBox(height: AlhaiSpacing.xl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FilledButton.icon(
                      onPressed: _captureImage,
                      icon: const Icon(Icons.camera_alt),
                      label: Text(l10n.captureImage),
                      style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14)),
                    ),
                    const SizedBox(width: AlhaiSpacing.md),
                    OutlinedButton.icon(
                      onPressed: _pickFromGallery,
                      icon: const Icon(Icons.photo_library),
                      label: Text(l10n.galleryPick),
                      style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewView(bool isDark) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(AlhaiSpacing.lg),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: _imagePath != null && File(_imagePath!).existsSync()
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(File(_imagePath!),
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: double.infinity),
                    )
                  : Center(
                      child: Icon(Icons.image,
                          size: 100,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant
                              .withValues(alpha: 0.5))),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(AlhaiSpacing.mdl),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border:
                Border(top: BorderSide(color: Theme.of(context).dividerColor)),
          ),
          child: Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => setState(() => _imagePath = null),
                icon: const Icon(Icons.refresh),
                label: Text(l10n.anotherImage),
                style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ),
            const SizedBox(width: AlhaiSpacing.md),
            Expanded(
              child: FilledButton.icon(
                onPressed: _processImage,
                icon: const Icon(Icons.auto_awesome),
                label: Text(l10n.aiProcessingBtn),
                style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ),
          ]),
        ),
      ],
    );
  }

  Widget _buildProcessingView(bool isDark) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Container(
        padding: const EdgeInsets.all(AlhaiSpacing.xxxl),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
                width: 56,
                height: 56,
                child: CircularProgressIndicator(strokeWidth: 3)),
            const SizedBox(height: AlhaiSpacing.lg),
            Text(l10n.processingInvoice,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: AlhaiSpacing.xs),
            Text(l10n.extractingDataWithAi,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  Future<void> _captureImage() async {
    try {
      final XFile? image = await _picker.pickImage(
          source: ImageSource.camera, imageQuality: 85, maxWidth: 2000);
      if (image != null && mounted) {
        setState(() => _imagePath = image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context).failedCapture(e)),
              backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery, imageQuality: 85, maxWidth: 2000);
      if (image != null && mounted) {
        setState(() => _imagePath = image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context).failedPickImage(e)),
              backgroundColor: AppColors.error),
        );
      }
    }
  }

  /// Maximum allowed file size for AI invoice images (10 MB)
  static const _maxFileSizeBytes = 10 * 1024 * 1024;

  void _processImage() async {
    if (_imagePath == null) return;

    final imageFile = File(_imagePath!);

    // M112: Validate file size before processing
    final fileSize = await imageFile.length();
    if (fileSize > _maxFileSizeBytes) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorWithDetails('File exceeds 10MB limit')),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final result = await AiInvoiceService.extractInvoiceData(imageFile);

      if (!mounted) return;
      setState(() => _isProcessing = false);

      context.push(AppRoutes.aiInvoiceReview, extra: result);
    } on AiInvoiceException catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(e.message),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context).failedProcessInvoice(e)),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4)),
      );
    }
  }
}
