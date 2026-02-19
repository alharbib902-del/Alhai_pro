import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../widgets/layout/app_header.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/router/routes.dart';
import '../../services/ai_invoice_service.dart';

/// شاشة استيراد الفاتورة بالذكاء الاصطناعي
class AiInvoiceImportScreen extends ConsumerStatefulWidget {
  const AiInvoiceImportScreen({super.key});

  @override
  ConsumerState<AiInvoiceImportScreen> createState() =>
      _AiInvoiceImportScreenState();
}

class _AiInvoiceImportScreenState
    extends ConsumerState<AiInvoiceImportScreen> {

  final _picker = ImagePicker();
  bool _isProcessing = false;
  String? _imagePath;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isMediumScreen = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Column(
              children: [
                AppHeader(
                  title: l10n.aiInvoiceImport,
                  onMenuTap: isWideScreen
                      ? null
                      : () => Scaffold.of(context).openDrawer(),
                  onNotificationsTap: () => context.push('/notifications'),
                  notificationsCount: 3,
                  userName: '\u0623\u062D\u0645\u062F \u0645\u062D\u0645\u062F',
                  userRole: l10n.branchManager,
                ),
                Expanded(
                  child: _isProcessing
                      ? _buildProcessingView(isDark)
                      : _imagePath == null
                          ? _buildUploadView(
                              isWideScreen, isMediumScreen, isDark)
                          : _buildPreviewView(isDark),
                ),
              ],
            );
  }
  Widget _buildUploadView(bool isWideScreen, bool isMediumScreen, bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
      child: Column(
        children: [
          // Back button
          Row(
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: Icon(Icons.arrow_back_rounded,
                    color: isDark ? Colors.white : AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Upload area
          Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(48),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : AppColors.border,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.info.withValues(alpha: 0.15),
                        AppColors.info.withValues(alpha: 0.05),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.document_scanner,
                      size: 56,
                      color: isDark ? AppColors.info : AppColors.info),
                ),
                const SizedBox(height: 32),
                Text(
                  l10n.importSupplierInvoice,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.captureOrSelectPhoto,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.6)
                        : AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FilledButton.icon(
                      onPressed: _captureImage,
                      icon: const Icon(Icons.camera_alt),
                      label: Text(l10n.captureImage),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                      ),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton.icon(
                      onPressed: _pickFromGallery,
                      icon: const Icon(Icons.photo_library),
                      label: Text(l10n.galleryPick),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                      ),
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
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : AppColors.border,
                ),
              ),
              child: _imagePath != null && File(_imagePath!).existsSync()
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        File(_imagePath!),
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    )
                  : Center(
                      child: Icon(Icons.image,
                          size: 100,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.2)
                              : AppColors.textTertiary),
                    ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            border: Border(
              top: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : AppColors.border,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => _imagePath = null),
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.anotherImage),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _processImage,
                  icon: const Icon(Icons.auto_awesome),
                  label: Text(l10n.aiProcessingBtn),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProcessingView(bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Container(
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : AppColors.border,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 56,
              height: 56,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.processingInvoice,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.extractingDataWithAi,
              style: TextStyle(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.6)
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _captureImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 2000,
      );
      if (image != null && mounted) {
        setState(() => _imagePath = image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.failedCapture(e)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 2000,
      );
      if (image != null && mounted) {
        setState(() => _imagePath = image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.failedPickImage(e)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _processImage() async {
    if (_imagePath == null) return;

    setState(() => _isProcessing = true);

    try {
      final imageFile = File(_imagePath!);
      final result = await AiInvoiceService.extractInvoiceData(imageFile);

      if (!mounted) return;
      setState(() => _isProcessing = false);

      // Navigate to review screen with extracted data
      context.push(AppRoutes.aiInvoiceReview, extra: result);
    } on AiInvoiceException catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.failedProcessInvoice(e)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}
