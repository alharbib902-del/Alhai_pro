/// Dialog for creating a new distributor product.
///
/// Handles image upload, form validation, and Supabase persistence.
library;

import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models.dart';
import '../../providers/distributor_providers.dart';

class CreateProductDialog extends ConsumerStatefulWidget {
  const CreateProductDialog({super.key});

  static Future<DistributorProduct?> show(BuildContext context) {
    return showDialog<DistributorProduct?>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const CreateProductDialog(),
    );
  }

  @override
  ConsumerState<CreateProductDialog> createState() =>
      _CreateProductDialogState();
}

class _CreateProductDialogState extends ConsumerState<CreateProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _skuController = TextEditingController();
  final _stockController = TextEditingController();

  String? _selectedCategoryId;
  Uint8List? _imageBytes;
  String? _imageFilename;
  bool _isLoading = false;
  String? _imageError;

  static const _maxImageSize = 5 * 1024 * 1024; // 5 MB
  static const _allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _barcodeController.dispose();
    _skuController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _allowedExtensions,
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final bytes = file.bytes;

      if (bytes == null) {
        setState(() => _imageError = 'تعذّر قراءة الملف');
        return;
      }

      if (bytes.length > _maxImageSize) {
        setState(() => _imageError = 'الصورة يجب أن تكون أقل من 5 ميجابايت');
        return;
      }

      setState(() {
        _imageBytes = bytes;
        _imageFilename = file.name;
        _imageError = null;
      });
    } catch (e) {
      setState(() => _imageError = 'خطأ في اختيار الصورة');
    }
  }

  Future<void> _submit() async {
    // Image validation
    if (_imageBytes == null) {
      setState(() => _imageError = 'صورة المنتج إجبارية');
      return;
    }

    // Form validation
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      // Category validation is handled in the dropdown validator
      return;
    }

    setState(() => _isLoading = true);

    try {
      final ds = ref.read(distributorDatasourceProvider);
      final product = await ds.createProduct(
        name: _nameController.text.trim(),
        price: double.parse(_priceController.text),
        categoryId: _selectedCategoryId!,
        imageBytes: _imageBytes!,
        imageFilename: _imageFilename!,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        barcode: _barcodeController.text.trim().isEmpty
            ? null
            : _barcodeController.text.trim(),
        sku: _skuController.text.trim().isEmpty
            ? null
            : _skuController.text.trim(),
        stockQty: int.tryParse(_stockController.text),
      );

      // Invalidate products list so it refreshes
      ref.invalidate(productsProvider);

      if (mounted) {
        Navigator.of(context).pop(product);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إنشاء المنتج "${product.name}" بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل إنشاء المنتج: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoriesAsync = ref.watch(categoriesWithIdsProvider);

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'إضافة منتج جديد',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Image picker
                  _buildImagePicker(isDark),
                  const SizedBox(height: 16),

                  // Name
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'اسم المنتج *',
                      border: OutlineInputBorder(),
                    ),
                    textDirection: TextDirection.rtl,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'الاسم إجباري';
                      if (v.trim().length < 3) {
                        return 'الاسم قصير جداً (3 أحرف على الأقل)';
                      }
                      if (v.trim().length > 100) {
                        return 'الاسم طويل جداً (100 حرف كحد أقصى)';
                      }
                      return null;
                    },
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 12),

                  // Price
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'السعر (ريال) *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                    ],
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'السعر إجباري';
                      final price = double.tryParse(v);
                      if (price == null || price <= 0) {
                        return 'أدخل سعراً صحيحاً أكبر من صفر';
                      }
                      if (price > 999999.99) {
                        return 'السعر يتجاوز الحد الأقصى';
                      }
                      return null;
                    },
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 12),

                  // Category dropdown
                  categoriesAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text(
                      'خطأ في تحميل التصنيفات',
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                    data: (categories) {
                      return DropdownButtonFormField<String>(
                        initialValue: _selectedCategoryId,
                        decoration: const InputDecoration(
                          labelText: 'التصنيف *',
                          border: OutlineInputBorder(),
                        ),
                        items: categories
                            .map(
                              (c) => DropdownMenuItem(
                                value: c.id,
                                child: Text(c.name),
                              ),
                            )
                            .toList(),
                        onChanged: _isLoading
                            ? null
                            : (v) => setState(() => _selectedCategoryId = v),
                        validator: (v) =>
                            v == null ? 'اختر تصنيفاً للمنتج' : null,
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Description (optional)
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'وصف المنتج',
                      border: OutlineInputBorder(),
                    ),
                    textDirection: TextDirection.rtl,
                    maxLines: 2,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 12),

                  // Barcode + SKU row
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _barcodeController,
                          decoration: const InputDecoration(
                            labelText: 'الباركود',
                            border: OutlineInputBorder(),
                          ),
                          enabled: !_isLoading,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _skuController,
                          decoration: const InputDecoration(
                            labelText: 'SKU',
                            border: OutlineInputBorder(),
                          ),
                          enabled: !_isLoading,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Stock quantity
                  TextFormField(
                    controller: _stockController,
                    decoration: const InputDecoration(
                      labelText: 'الكمية المتوفرة',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 24),

                  // Submit button
                  SizedBox(
                    height: 48,
                    child: FilledButton(
                      onPressed: _isLoading ? null : _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textOnPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AlhaiRadius.sm + 2,
                          ),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'إنشاء المنتج',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: _isLoading ? null : _pickImage,
          borderRadius: BorderRadius.circular(AlhaiRadius.md),
          child: Container(
            height: 140,
            decoration: BoxDecoration(
              color: AppColors.getSurfaceVariant(isDark),
              borderRadius: BorderRadius.circular(AlhaiRadius.md),
              border: Border.all(
                color: _imageError != null
                    ? Colors.red
                    : AppColors.getBorder(isDark),
                width: _imageError != null ? 2 : 1,
              ),
            ),
            child: _imageBytes != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(AlhaiRadius.md - 1),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.memory(_imageBytes!, fit: BoxFit.contain),
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _imageFilename ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton.filled(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    setState(() {
                                      _imageBytes = null;
                                      _imageFilename = null;
                                    });
                                  },
                            icon: const Icon(Icons.close, size: 16),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black54,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(32, 32),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_rounded,
                        size: 40,
                        color: AppColors.getTextMuted(isDark),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'اضغط لاختيار صورة المنتج *',
                        style: TextStyle(
                          color: AppColors.getTextSecondary(isDark),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'JPG, PNG, WebP — حد أقصى 5 MB',
                        style: TextStyle(
                          color: AppColors.getTextMuted(isDark),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        if (_imageError != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, right: 12),
            child: Text(
              _imageError!,
              style: TextStyle(color: Colors.red.shade700, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
