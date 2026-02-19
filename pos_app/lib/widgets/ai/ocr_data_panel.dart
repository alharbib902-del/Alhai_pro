/// لوحة بيانات OCR - OCR Data Panel Widget
///
/// الحقول المستخرجة: الاسم، السعر، الباركود، تاريخ الانتهاء
/// حقول نصية قابلة للتعديل
library;

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/ai_product_recognition_service.dart';

/// لوحة بيانات OCR
class OcrDataPanel extends StatefulWidget {
  final OcrExtraction? extraction;
  final ValueChanged<MapEntry<String, String>>? onFieldChanged;
  final VoidCallback? onSave;
  final VoidCallback? onExtract;

  const OcrDataPanel({
    super.key,
    this.extraction,
    this.onFieldChanged,
    this.onSave,
    this.onExtract,
  });

  @override
  State<OcrDataPanel> createState() => _OcrDataPanelState();
}

class _OcrDataPanelState extends State<OcrDataPanel> {
  late TextEditingController _nameController;
  late TextEditingController _barcodeController;
  late TextEditingController _priceController;
  late TextEditingController _expiryController;
  late TextEditingController _brandController;
  late TextEditingController _weightController;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  @override
  void didUpdateWidget(OcrDataPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.extraction != widget.extraction) {
      _initControllers();
    }
  }

  void _initControllers() {
    _nameController = TextEditingController(text: widget.extraction?.productName ?? '');
    _barcodeController = TextEditingController(text: widget.extraction?.barcode ?? '');
    _priceController = TextEditingController(text: widget.extraction?.price?.toStringAsFixed(2) ?? '');
    _expiryController = TextEditingController(text: widget.extraction?.expiryDate ?? '');
    _brandController = TextEditingController(text: widget.extraction?.brand ?? '');
    _weightController = TextEditingController(text: widget.extraction?.weight ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _barcodeController.dispose();
    _priceController.dispose();
    _expiryController.dispose();
    _brandController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.document_scanner_rounded, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'استخراج بيانات OCR',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      if (widget.extraction != null)
                        Text(
                          'دقة الاستخراج: ${(widget.extraction!.confidence * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textMuted,
                          ),
                        ),
                    ],
                  ),
                ),
                if (widget.extraction != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_rounded, size: 14, color: AppColors.success),
                        SizedBox(width: 4),
                        Text(
                          'تم الاستخراج',
                          style: TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          Divider(
            height: 1,
            color: isDark ? Colors.white.withValues(alpha: 0.06) : AppColors.grey100,
          ),

          if (widget.extraction == null)
            // Empty state
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.document_scanner_rounded, size: 48,
                      color: isDark ? Colors.white.withValues(alpha: 0.2) : AppColors.textMuted),
                    const SizedBox(height: 12),
                    Text(
                      'التقط صورة لاستخراج البيانات',
                      style: TextStyle(
                        color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: widget.onExtract,
                      icon: const Icon(Icons.camera_alt_rounded, size: 18),
                      label: const Text('استخراج بيانات'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            // Fields
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _OcrField(
                      label: 'اسم المنتج',
                      icon: Icons.inventory_2_rounded,
                      controller: _nameController,
                      isDark: isDark,
                      onChanged: (v) => widget.onFieldChanged?.call(MapEntry('name', v)),
                    ),
                    const SizedBox(height: 12),
                    _OcrField(
                      label: 'الباركود',
                      icon: Icons.qr_code_rounded,
                      controller: _barcodeController,
                      isDark: isDark,
                      onChanged: (v) => widget.onFieldChanged?.call(MapEntry('barcode', v)),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _OcrField(
                            label: 'السعر (ر.س)',
                            icon: Icons.attach_money_rounded,
                            controller: _priceController,
                            isDark: isDark,
                            keyboardType: TextInputType.number,
                            onChanged: (v) => widget.onFieldChanged?.call(MapEntry('price', v)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _OcrField(
                            label: 'تاريخ الانتهاء',
                            icon: Icons.calendar_today_rounded,
                            controller: _expiryController,
                            isDark: isDark,
                            onChanged: (v) => widget.onFieldChanged?.call(MapEntry('expiry', v)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _OcrField(
                            label: 'العلامة التجارية',
                            icon: Icons.branding_watermark_rounded,
                            controller: _brandController,
                            isDark: isDark,
                            onChanged: (v) => widget.onFieldChanged?.call(MapEntry('brand', v)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _OcrField(
                            label: 'الوزن/الحجم',
                            icon: Icons.scale_rounded,
                            controller: _weightController,
                            isDark: isDark,
                            onChanged: (v) => widget.onFieldChanged?.call(MapEntry('weight', v)),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Raw text
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0F172A)
                            : AppColors.grey50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.06) : AppColors.grey200,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'النص الخام المستخرج',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white.withValues(alpha: 0.4) : AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.extraction!.rawText,
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'monospace',
                              color: isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: widget.onSave,
                        icon: const Icon(Icons.save_rounded, size: 18),
                        label: const Text('حفظ المنتج'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
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
}

/// حقل OCR
class _OcrField extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final bool isDark;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  const _OcrField({
    required this.label,
    required this.icon,
    required this.controller,
    required this.isDark,
    this.keyboardType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14,
              color: isDark ? Colors.white.withValues(alpha: 0.4) : AppColors.textMuted),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: keyboardType,
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.textPrimary,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark ? const Color(0xFF0F172A) : AppColors.grey50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
