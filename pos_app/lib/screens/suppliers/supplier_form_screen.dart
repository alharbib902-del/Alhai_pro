/// شاشة نموذج المورد - Supplier Form Screen
///
/// شاشة لإضافة وتعديل بيانات الموردين
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' show Value;
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';
import '../../core/validators/validators.dart';
import '../../data/local/app_database.dart';
import '../../di/injection.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/suppliers_providers.dart';
import '../../widgets/layout/app_header.dart';

/// شاشة نموذج المورد
class SupplierFormScreen extends ConsumerStatefulWidget {
  final String? supplierId;

  const SupplierFormScreen({
    super.key,
    this.supplierId,
  });

  bool get isEditing => supplierId != null;

  @override
  ConsumerState<SupplierFormScreen> createState() => _SupplierFormScreenState();
}

class _SupplierFormScreenState extends ConsumerState<SupplierFormScreen> {

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers
  final _nameController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _phone2Controller = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _vatNumberController = TextEditingController();
  final _crNumberController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _ibanController = TextEditingController();
  final _notesController = TextEditingController();

  // Values
  String _paymentTerms = '30';
  String _category = 'general';
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _loadSupplierData();
    }
  }

  Future<void> _loadSupplierData() async {
    final db = getIt<AppDatabase>();
    final supplier = await db.suppliersDao.getSupplierById(widget.supplierId!);
    if (supplier != null && mounted) {
      setState(() {
        _nameController.text = supplier.name;
        _phoneController.text = supplier.phone ?? '';
        _emailController.text = supplier.email ?? '';
        _addressController.text = supplier.address ?? '';
        _vatNumberController.text = supplier.taxNumber ?? '';
        _notesController.text = supplier.notes ?? '';
        _isActive = supplier.isActive;
        if (supplier.paymentTerms != null) {
          _paymentTerms = supplier.paymentTerms!;
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyNameController.dispose();
    _phoneController.dispose();
    _phone2Controller.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _vatNumberController.dispose();
    _crNumberController.dispose();
    _bankNameController.dispose();
    _ibanController.dispose();
    _notesController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 900;
    final isMediumScreen = screenWidth > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Column(
              children: [
                // Header
                AppHeader(
                  title: widget.isEditing
                      ? l10n.editSupplier
                      : l10n.addNewSupplier,
                  onMenuTap: isWideScreen
                      ? null
                      : () => Scaffold.of(context).openDrawer(),
                  onNotificationsTap: () {},
                  notificationsCount: 3,
                  userName: 'أحمد',
                  userRole: l10n.dashboard,
                ),

                // Content
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: isWideScreen
                        ? _buildWideLayout(isDark, isMediumScreen, l10n)
                        : _buildNarrowLayout(isDark, l10n),
                  ),
                ),
              ],
            );
  }

  Widget _buildWideLayout(
      bool isDark, bool isMediumScreen, AppLocalizations l10n) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column: form sections
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildBasicInfoSection(isDark, l10n),
                const SizedBox(height: 20),
                _buildContactSection(isDark, l10n),
                const SizedBox(height: 20),
                _buildBusinessSection(isDark, l10n),
              ],
            ),
          ),
        ),

        // Right column: financial + additional + save
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 24, 24),
            child: Column(
              children: [
                _buildFinancialSection(isDark, l10n),
                const SizedBox(height: 20),
                _buildAdditionalSection(isDark),
                const SizedBox(height: 24),
                _buildSaveButton(isDark),
                if (widget.isEditing) ...[
                  const SizedBox(height: 12),
                  _buildDeleteButton(isDark),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(bool isDark, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildBasicInfoSection(isDark, l10n),
          const SizedBox(height: 16),
          _buildContactSection(isDark, l10n),
          const SizedBox(height: 16),
          _buildBusinessSection(isDark, l10n),
          const SizedBox(height: 16),
          _buildFinancialSection(isDark, l10n),
          const SizedBox(height: 16),
          _buildAdditionalSection(isDark),
          const SizedBox(height: 24),
          _buildSaveButton(isDark),
          if (widget.isEditing) ...[
            const SizedBox(height: 12),
            _buildDeleteButton(isDark),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required bool isDark,
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.sm),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: AppSizes.md),
              Text(
                title,
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          ...children,
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection(bool isDark, AppLocalizations l10n) {
    return _buildSectionCard(
      isDark: isDark,
      title: l10n.basicInfo,
      icon: Icons.person,
      color: AppColors.primary,
      children: [
        // اسم المورد
        _buildTextField(
          controller: _nameController,
          label: l10n.supplierContactName,
          hint: 'مثال: محمد العلي',
          icon: Icons.person_outline,
          isDark: isDark,
          maxLength: 100,
          validator: FormValidators.name(maxLength: 100),
        ),
        const SizedBox(height: AppSizes.md),

        // اسم الشركة
        _buildTextField(
          controller: _companyNameController,
          label: l10n.companyNameRequired,
          hint: 'مثال: شركة الأغذية المتحدة',
          icon: Icons.business,
          isDark: isDark,
          maxLength: 150,
          validator: FormValidators.requiredField(maxLength: 150),
        ),
        const SizedBox(height: AppSizes.md),

        // التصنيف
        _buildDropdown(
          label: l10n.categoryLabel,
          icon: Icons.category,
          value: _category,
          isDark: isDark,
          items: [
            DropdownMenuItem(value: 'general', child: Text(l10n.generalCategory)),
            DropdownMenuItem(value: 'food', child: Text(l10n.foodMaterials)),
            DropdownMenuItem(value: 'beverages', child: Text(l10n.beverages)),
            DropdownMenuItem(value: 'dairy', child: Text(l10n.dairy)),
            DropdownMenuItem(value: 'meat', child: Text(l10n.meat)),
            DropdownMenuItem(
                value: 'vegetables', child: Text(l10n.vegetablesFruits)),
            DropdownMenuItem(value: 'equipment', child: Text(l10n.equipment)),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() => _category = value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildContactSection(bool isDark, AppLocalizations l10n) {
    return _buildSectionCard(
      isDark: isDark,
      title: l10n.contactInfo,
      icon: Icons.contact_phone,
      color: AppColors.info,
      children: [
        // رقم الهاتف
        _buildTextField(
          controller: _phoneController,
          label: l10n.primaryPhoneRequired,
          hint: '05xxxxxxxx',
          icon: Icons.phone,
          isDark: isDark,
          keyboardType: TextInputType.phone,
          maxLength: 13,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d+]')),
          ],
          prefixText: '+966 ',
          validator: FormValidators.phone(),
        ),
        const SizedBox(height: AppSizes.md),

        // رقم هاتف ثانوي
        _buildTextField(
          controller: _phone2Controller,
          label: l10n.secondaryPhoneOptional,
          hint: '05xxxxxxxx',
          icon: Icons.phone_android,
          isDark: isDark,
          keyboardType: TextInputType.phone,
          maxLength: 13,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d+]')),
          ],
          prefixText: '+966 ',
          validator: FormValidators.phone(required: false),
        ),
        const SizedBox(height: AppSizes.md),

        // البريد الإلكتروني
        _buildTextField(
          controller: _emailController,
          label: l10n.emailField,
          hint: 'example@company.com',
          icon: Icons.email,
          isDark: isDark,
          keyboardType: TextInputType.emailAddress,
          maxLength: 254,
          validator: FormValidators.email(required: false),
        ),
        const SizedBox(height: AppSizes.md),

        // العنوان
        _buildTextField(
          controller: _addressController,
          label: l10n.addressField2,
          hint: 'المدينة، الحي، الشارع',
          icon: Icons.location_on,
          isDark: isDark,
          maxLines: 2,
          maxLength: 300,
          validator: FormValidators.notes(maxLength: 300),
        ),
      ],
    );
  }

  Widget _buildBusinessSection(bool isDark, AppLocalizations l10n) {
    return _buildSectionCard(
      isDark: isDark,
      title: l10n.commercialInfo,
      icon: Icons.business_center,
      color: AppColors.warning,
      children: [
        // الرقم الضريبي
        _buildTextField(
          controller: _vatNumberController,
          label: l10n.taxNumberVat,
          hint: '15 رقم',
          icon: Icons.receipt_long,
          isDark: isDark,
          keyboardType: TextInputType.number,
          maxLength: 15,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          validator: FormValidators.vatNumber(),
        ),
        const SizedBox(height: AppSizes.md),

        // السجل التجاري
        _buildTextField(
          controller: _crNumberController,
          label: l10n.commercialRegNumber,
          hint: '10 أرقام',
          icon: Icons.article,
          isDark: isDark,
          keyboardType: TextInputType.number,
          maxLength: 10,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          validator: FormValidators.crNumber(),
        ),
      ],
    );
  }

  Widget _buildFinancialSection(bool isDark, AppLocalizations l10n) {
    return _buildSectionCard(
      isDark: isDark,
      title: l10n.financialInfo,
      icon: Icons.account_balance,
      color: AppColors.success,
      children: [
        // شروط الدفع
        _buildDropdown(
          label: l10n.paymentTerms,
          icon: Icons.calendar_today,
          value: _paymentTerms,
          isDark: isDark,
          items: [
            DropdownMenuItem(value: 'cod', child: Text(l10n.payOnDelivery)),
            DropdownMenuItem(value: '7', child: Text(l10n.sevenDays)),
            DropdownMenuItem(value: '14', child: Text(l10n.fourteenDays)),
            DropdownMenuItem(value: '30', child: Text(l10n.thirtyDays)),
            DropdownMenuItem(value: '45', child: Text(l10n.fortyFiveDays)),
            DropdownMenuItem(value: '60', child: Text(l10n.sixtyDays)),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() => _paymentTerms = value);
            }
          },
        ),
        const SizedBox(height: AppSizes.md),

        // اسم البنك
        _buildTextField(
          controller: _bankNameController,
          label: l10n.bankName,
          hint: 'مثال: بنك الراجحي',
          icon: Icons.account_balance,
          isDark: isDark,
          maxLength: 100,
          validator: FormValidators.name(isRequired: false),
        ),
        const SizedBox(height: AppSizes.md),

        // IBAN
        _buildTextField(
          controller: _ibanController,
          label: l10n.ibanLabel,
          hint: 'SAxx xxxx xxxx xxxx xxxx xxxx',
          icon: Icons.credit_card,
          isDark: isDark,
          textCapitalization: TextCapitalization.characters,
          maxLength: 24,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
          ],
          validator: FormValidators.iban(required: false),
        ),
      ],
    );
  }

  Widget _buildAdditionalSection(bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return _buildSectionCard(
      isDark: isDark,
      title: l10n.additionalSettings,
      icon: Icons.settings,
      color: AppColors.grey600,
      children: [
        // حالة المورد
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.03)
                : AppColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              l10n.supplierActiveLabel,
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              l10n.supplierCanCreateOrders,
              style: TextStyle(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.5)
                    : AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            value: _isActive,
            activeThumbColor: AppColors.primary,
            onChanged: (value) {
              setState(() => _isActive = value);
            },
          ),
        ),
        const SizedBox(height: AppSizes.md),

        // ملاحظات
        _buildTextField(
          controller: _notesController,
          label: l10n.notesLabel,
          hint: l10n.notesFieldHint,
          icon: Icons.note,
          isDark: isDark,
          maxLines: 3,
          maxLength: 500,
          validator: FormValidators.notes(),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? prefixText,
    TextCapitalization textCapitalization = TextCapitalization.none,
    int maxLines = 1,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      maxLines: maxLines,
      maxLength: maxLength,
      style: TextStyle(
        color: isDark ? Colors.white : AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        prefixText: prefixText,
        labelStyle: TextStyle(
          color: isDark
              ? Colors.white.withValues(alpha: 0.6)
              : AppColors.textSecondary,
        ),
        hintStyle: TextStyle(
          color: isDark
              ? Colors.white.withValues(alpha: 0.3)
              : AppColors.textTertiary,
        ),
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : AppColors.backgroundSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : AppColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : AppColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.error,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 2,
          ),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String value,
    required bool isDark,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        labelStyle: TextStyle(
          color: isDark
              ? Colors.white.withValues(alpha: 0.6)
              : AppColors.textSecondary,
        ),
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : AppColors.backgroundSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : AppColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : AppColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
      ),
      dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      style: TextStyle(
        color: isDark ? Colors.white : AppColors.textPrimary,
      ),
      items: items,
      onChanged: onChanged,
    );
  }

  Widget _buildSaveButton(bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _isLoading ? null : _saveSupplier,
        icon: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.save_rounded),
        label: Text(
          _isLoading
              ? l10n.savingLabel
              : (widget.isEditing
                  ? l10n.updateSupplier
                  : l10n.addSupplierBtn),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton(bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _showDeleteConfirmation,
        icon: const Icon(Icons.delete_outline_rounded),
        label: Text(l10n.deleteSupplier),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          minimumSize: const Size.fromHeight(52),
          side: BorderSide(
            color: AppColors.error.withValues(alpha: 0.5),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
  void _saveSupplier() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Sanitize values before saving
    final sanitizedName = InputSanitizer.sanitizeName(_nameController.text);
    final sanitizedPhone = InputSanitizer.sanitizePhone(_phoneController.text);
    final sanitizedEmail = InputSanitizer.sanitizeEmail(_emailController.text);
    final sanitizedAddress = InputSanitizer.sanitize(_addressController.text);
    final sanitizedVat = InputSanitizer.sanitizeNumeric(_vatNumberController.text);
    final sanitizedNotes = InputSanitizer.sanitize(_notesController.text);

    try {
      if (widget.isEditing) {
        // تحديث مورد موجود عبر المزود (يشمل SyncQueue)
        final db = getIt<AppDatabase>();
        final existing = await db.suppliersDao.getSupplierById(widget.supplierId!);
        if (existing != null) {
          await updateSupplier(
            ref,
            supplier: existing.copyWith(
              name: sanitizedName,
              phone: Value(sanitizedPhone.isEmpty ? null : sanitizedPhone),
              email: Value(sanitizedEmail.isEmpty ? null : sanitizedEmail),
              address: Value(sanitizedAddress.isEmpty ? null : sanitizedAddress),
              taxNumber: Value(sanitizedVat.isEmpty ? null : sanitizedVat),
              notes: Value(sanitizedNotes.isEmpty ? null : sanitizedNotes),
              paymentTerms: Value(_paymentTerms),
              isActive: _isActive,
              updatedAt: Value(DateTime.now()),
            ),
          );
        }
      } else {
        // إنشاء مورد جديد عبر المزود (يشمل SyncQueue)
        await addSupplier(
          ref,
          name: sanitizedName,
          phone: sanitizedPhone.isEmpty ? null : sanitizedPhone,
          email: sanitizedEmail.isEmpty ? null : sanitizedEmail,
          address: sanitizedAddress.isEmpty ? null : sanitizedAddress,
          taxNumber: sanitizedVat.isEmpty ? null : sanitizedVat,
          notes: sanitizedNotes.isEmpty ? null : sanitizedNotes,
        );
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        HapticFeedback.heavyImpact();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing
                  ? l10n.supplierUpdatedMsg
                  : l10n.supplierAddedSuccess,
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );

        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorOccurredMsg(e)),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  void _showDeleteConfirmation() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.deleteSupplier,
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        content: Text(
          l10n.deleteSupplierConfirm,
          style: TextStyle(
            color: isDark
                ? Colors.white.withValues(alpha: 0.7)
                : AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              l10n.deleteConfirmCancel,
              style: TextStyle(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.7)
                    : AppColors.textSecondary,
              ),
            ),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteSupplier();
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(l10n.deleteConfirmBtn),
          ),
        ],
      ),
    );
  }

  void _deleteSupplier() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isLoading = true;
    });

    try {
      await deleteSupplier(ref, widget.supplierId!);

      if (mounted) {
        HapticFeedback.mediumImpact();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.supplierDeletedMsg),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );

        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorDuringDeleteMsg(e)),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }
}
