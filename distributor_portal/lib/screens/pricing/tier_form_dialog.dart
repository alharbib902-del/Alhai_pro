/// Dialog for creating/editing a pricing tier.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import '../../data/models.dart';

/// Shows a form dialog for creating or editing a pricing tier.
/// Returns the form values if submitted, or null if cancelled.
Future<PricingTierFormResult?> showTierFormDialog(
  BuildContext context, {
  PricingTier? existing,
}) {
  return showDialog<PricingTierFormResult>(
    context: context,
    builder: (ctx) => _TierFormDialog(existing: existing),
  );
}

/// Result from the tier form dialog.
class PricingTierFormResult {
  final String name;
  final String? nameAr;
  final double discountPercent;
  final bool isDefault;

  const PricingTierFormResult({
    required this.name,
    this.nameAr,
    required this.discountPercent,
    required this.isDefault,
  });
}

class _TierFormDialog extends StatefulWidget {
  final PricingTier? existing;
  const _TierFormDialog({this.existing});

  @override
  State<_TierFormDialog> createState() => _TierFormDialogState();
}

class _TierFormDialogState extends State<_TierFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _nameArController;
  late final TextEditingController _discountController;
  late bool _isDefault;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existing?.name ?? '');
    _nameArController = TextEditingController(
      text: widget.existing?.nameAr ?? '',
    );
    _discountController = TextEditingController(
      text: widget.existing?.discountPercent.toString() ?? '',
    );
    _isDefault = widget.existing?.isDefault ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameArController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop(
      PricingTierFormResult(
        name: _nameController.text.trim(),
        nameAr: _nameArController.text.trim().isEmpty
            ? null
            : _nameArController.text.trim(),
        discountPercent: double.parse(_discountController.text.trim()),
        isDefault: _isDefault,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      title: Text(
        _isEditing ? 'تعديل الفئة' : 'فئة سعرية جديدة',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'اسم الفئة (إنجليزي) *',
                  hintText: 'Gold, Silver, Regular...',
                  filled: true,
                  fillColor: AppColors.getSurfaceVariant(isDark),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AlhaiRadius.sm + 2),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'مطلوب';
                  if (v.trim().length < 2) return 'حرفين على الأقل';
                  if (v.trim().length > 50) return '50 حرف كحد أقصى';
                  return null;
                },
              ),
              const SizedBox(height: AlhaiSpacing.md),
              TextFormField(
                controller: _nameArController,
                decoration: InputDecoration(
                  labelText: 'اسم الفئة (عربي)',
                  hintText: 'ذهبي، فضي، عادي...',
                  filled: true,
                  fillColor: AppColors.getSurfaceVariant(isDark),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AlhaiRadius.sm + 2),
                  ),
                ),
                validator: (v) {
                  if (v != null && v.trim().length > 50) {
                    return '50 حرف كحد أقصى';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AlhaiSpacing.md),
              TextFormField(
                controller: _discountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^\d{0,3}\.?\d{0,2}'),
                  ),
                ],
                decoration: InputDecoration(
                  labelText: 'نسبة الخصم (%) *',
                  hintText: '0 - 100',
                  suffixText: '%',
                  filled: true,
                  fillColor: AppColors.getSurfaceVariant(isDark),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AlhaiRadius.sm + 2),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'مطلوب';
                  final val = double.tryParse(v.trim());
                  if (val == null) return 'رقم غير صالح';
                  if (val < 0 || val > 100) return 'بين 0 و 100';
                  return null;
                },
              ),
              const SizedBox(height: AlhaiSpacing.md),
              SwitchListTile.adaptive(
                title: const Text('فئة افتراضية'),
                subtitle: const Text(
                  'تُطبق تلقائياً على المتاجر الجديدة',
                  style: TextStyle(fontSize: 12),
                ),
                value: _isDefault,
                onChanged: (v) => setState(() => _isDefault = v),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          onPressed: _submit,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
          ),
          child: Text(_isEditing ? 'حفظ' : 'إنشاء'),
        ),
      ],
    );
  }
}
