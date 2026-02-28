/// شاشة التعرف على المنتجات - AI Product Recognition Screen
///
/// منطقة الكاميرا، زر المسح، قائمة النتائج، لوحة OCR
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import '../../providers/ai_product_recognition_providers.dart';
import '../../services/ai_product_recognition_service.dart';
import '../../widgets/ai/recognition_result_card.dart';
import '../../widgets/ai/ocr_data_panel.dart';

class AiProductRecognitionScreen extends ConsumerStatefulWidget {
  const AiProductRecognitionScreen({super.key});

  @override
  ConsumerState<AiProductRecognitionScreen> createState() => _AiProductRecognitionScreenState();
}

class _AiProductRecognitionScreenState extends ConsumerState<AiProductRecognitionScreen> {

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Column(
              children: [
                AppHeader(
                  title: l10n.aiProductRecognition,
                  onMenuTap: !isWideScreen ? () => Scaffold.of(context).openDrawer() : null,
                ),
                Expanded(child: _buildContent(isDark, isWideScreen)),
              ],
            );
  }

  Widget _buildContent(bool isDark, bool isWideScreen) {
    final scanMode = ref.watch(scanModeProvider);
    final recognitionResult = ref.watch(recognitionResultProvider);
    final ocrExtraction = ref.watch(ocrExtractionProvider);

    return Column(
      children: [
        // Mode selector
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 0),
          child: _buildModeSelector(scanMode, isDark),
        ),

        // Main content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: isWideScreen
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Camera + scan area
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            _buildCameraArea(isDark, scanMode),
                            const SizedBox(height: 16),
                            Expanded(
                              child: _buildResultsList(recognitionResult, isDark),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      // OCR panel
                      SizedBox(
                        width: 360,
                        child: OcrDataPanel(
                          extraction: ocrExtraction,
                          onExtract: () => ref.read(ocrExtractionProvider.notifier).extractFromImage(),
                          onFieldChanged: (entry) => ref.read(ocrExtractionProvider.notifier).updateField(entry.key, entry.value),
                          onSave: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AppLocalizations.of(context)!.aiProductSaved),
                                backgroundColor: AppColors.success,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildCameraArea(isDark, scanMode),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 300,
                          child: _buildResultsList(recognitionResult, isDark),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 500,
                          child: OcrDataPanel(
                            extraction: ocrExtraction,
                            onExtract: () => ref.read(ocrExtractionProvider.notifier).extractFromImage(),
                            onFieldChanged: (entry) => ref.read(ocrExtractionProvider.notifier).updateField(entry.key, entry.value),
                            onSave: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildModeSelector(ScanMode mode, bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    final modes = [
      _ModeOption(ScanMode.singleProduct, Icons.center_focus_strong_rounded, l10n.aiSingleProduct),
      _ModeOption(ScanMode.shelfScan, Icons.view_column_rounded, l10n.aiShelfScan),
      _ModeOption(ScanMode.barcodeOcr, Icons.qr_code_scanner_rounded, l10n.aiBarcodeOcr),
      _ModeOption(ScanMode.priceTag, Icons.sell_rounded, l10n.aiPriceTag),
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border,
        ),
      ),
      child: Row(
        children: modes.map((m) {
          final isSelected = m.mode == mode;
          return Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => ref.read(scanModeProvider.notifier).state = m.mode,
                borderRadius: BorderRadius.circular(10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                          )
                        : null,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(m.icon, size: 16,
                        color: isSelected ? Colors.white : (isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textSecondary)),
                      const SizedBox(width: 6),
                      Text(
                        m.label,
                        style: TextStyle(
                          color: isSelected ? Colors.white : (isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textSecondary),
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCameraArea(bool isDark, ScanMode mode) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : AppColors.grey100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border,
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          // Camera placeholder
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    size: 40,
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.aiCameraArea,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textSecondary,
                  ),
                ),
                Text(
                  l10n.aiPointCameraAtProduct,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white.withValues(alpha: 0.3) : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          // Corner guides
          ..._buildCornerGuides(isDark),

          // Scan button
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  ref.read(recognitionResultProvider.notifier).startScan();
                  ref.read(ocrExtractionProvider.notifier).extractFromImage();
                },
                icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
                label: Text(l10n.aiStartScan),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  elevation: 4,
                  shadowColor: const Color(0xFF3B82F6).withValues(alpha: 0.4),
                ),
              ),
            ),
          ),

          // Mode label
          PositionedDirectional(
            top: 12,
            end: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _getModeLabel(mode),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCornerGuides(bool isDark) {
    const guideColor = Color(0xFF3B82F6);
    const size = 30.0;
    const thickness = 3.0;

    return [
      // Top-left
      Positioned(
        top: 20,
        left: 20,
        child: CustomPaint(size: const Size(size, size), painter: _CornerPainter(guideColor, thickness, Corner.topLeft)),
      ),
      // Top-right
      Positioned(
        top: 20,
        right: 20,
        child: CustomPaint(size: const Size(size, size), painter: _CornerPainter(guideColor, thickness, Corner.topRight)),
      ),
      // Bottom-left
      Positioned(
        bottom: 60,
        left: 20,
        child: CustomPaint(size: const Size(size, size), painter: _CornerPainter(guideColor, thickness, Corner.bottomLeft)),
      ),
      // Bottom-right
      Positioned(
        bottom: 60,
        right: 20,
        child: CustomPaint(size: const Size(size, size), painter: _CornerPainter(guideColor, thickness, Corner.bottomRight)),
      ),
    ];
  }

  Widget _buildResultsList(AsyncValue<RecognitionResult?> result, bool isDark) {
    return result.when(
      loading: () => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.border),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation(Color(0xFF3B82F6)),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context)!.aiAnalyzingImage,
                style: TextStyle(
                  color: isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
      error: (e, _) => Center(child: Text(AppLocalizations.of(context)!.aiErrorWithMessage(e.toString()))),
      data: (data) {
        if (data == null) {
          return Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.border),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_search_rounded, size: 48,
                    color: isDark ? Colors.white.withValues(alpha: 0.2) : AppColors.textMuted),
                  const SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(context)!.aiStartScanToSeeResults,
                    style: TextStyle(
                      color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.border),
          ),
          child: Column(
            children: [
              // Summary header
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.aiScanResults,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    _buildResultBadge(AppLocalizations.of(context)!.aiDetectedCount(data.totalDetected), AppColors.info, isDark),
                    const SizedBox(width: 8),
                    _buildResultBadge(AppLocalizations.of(context)!.aiMatchedCount(data.totalMatched), AppColors.success, isDark),
                    const SizedBox(width: 8),
                    _buildResultBadge(AppLocalizations.of(context)!.aiAccuracyPercent('${(data.avgConfidence * 100).toInt()}'), AppColors.primary, isDark),
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: isDark ? Colors.white.withValues(alpha: 0.06) : AppColors.grey100,
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(14),
                  itemCount: data.products.length,
                  itemBuilder: (context, index) {
                    final product = data.products[index];
                    return RecognitionResultCard(
                      product: product,
                      onAccept: () {
                        if (product.matchedId != null) {
                          ref.read(recognitionResultProvider.notifier).acceptProduct(product.matchedId!);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context)!.aiProductAccepted(product.nameAr)),
                              backgroundColor: AppColors.success,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        }
                      },
                      onReject: () {
                        ref.read(recognitionResultProvider.notifier).rejectProduct(product.nameAr);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResultBadge(String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  String _getModeLabel(ScanMode mode) {
    switch (mode) {
      case ScanMode.singleProduct: return AppLocalizations.of(context)!.aiSingleProduct;
      case ScanMode.shelfScan: return AppLocalizations.of(context)!.aiShelfScan;
      case ScanMode.barcodeOcr: return AppLocalizations.of(context)!.aiBarcodeOcr;
      case ScanMode.priceTag: return AppLocalizations.of(context)!.aiPriceTag;
    }
  }
}

enum Corner { topLeft, topRight, bottomLeft, bottomRight }

class _CornerPainter extends CustomPainter {
  final Color color;
  final double thickness;
  final Corner corner;

  _CornerPainter(this.color, this.thickness, this.corner);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    switch (corner) {
      case Corner.topLeft:
        canvas.drawLine(Offset.zero, Offset(size.width, 0), paint);
        canvas.drawLine(Offset.zero, Offset(0, size.height), paint);
      case Corner.topRight:
        canvas.drawLine(Offset(size.width, 0), Offset.zero, paint);
        canvas.drawLine(Offset(size.width, 0), Offset(size.width, size.height), paint);
      case Corner.bottomLeft:
        canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), paint);
        canvas.drawLine(Offset(0, size.height), Offset.zero, paint);
      case Corner.bottomRight:
        canvas.drawLine(Offset(size.width, size.height), Offset(0, size.height), paint);
        canvas.drawLine(Offset(size.width, size.height), Offset(size.width, 0), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ModeOption {
  final ScanMode mode;
  final IconData icon;
  final String label;

  const _ModeOption(this.mode, this.icon, this.label);
}
