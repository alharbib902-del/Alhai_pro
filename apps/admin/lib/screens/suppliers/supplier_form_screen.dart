import 'dart:math' show min;

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import '../../core/providers/unsaved_changes_provider.dart';

/// Admin Supplier Form Screen - Add/Edit supplier
class SupplierFormScreen extends ConsumerStatefulWidget {
  final String? supplierId;

  const SupplierFormScreen({super.key, this.supplierId});

  bool get isEditing => supplierId != null;

  @override
  ConsumerState<SupplierFormScreen> createState() => _SupplierFormScreenState();
}

class _SupplierFormScreenState extends ConsumerState<SupplierFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isLoadingData = false;
  bool _isDirty = false; // M65: unsaved changes tracking

  void _setDirty(bool value) {
    if (_isDirty != value) {
      setState(() => _isDirty = value);
      ref.read(unsavedChangesProvider.notifier).state = value;
    }
  }

  // Controllers
  final _companyNameController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _vatNumberController = TextEditingController();
  final _crNumberController = TextEditingController();
  final _notesController = TextEditingController();

  // Focus nodes for field navigation (M59)
  final _companyNameFocus = FocusNode();
  final _contactNameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _addressFocus = FocusNode();
  final _vatNumberFocus = FocusNode();
  final _crNumberFocus = FocusNode();
  final _notesFocus = FocusNode();

  // Values
  String _paymentTerms = '30';
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _loadSupplierData();
    }
  }

  Future<void> _loadSupplierData() async {
    setState(() => _isLoadingData = true);
    try {
      final db = getIt<AppDatabase>();
      final supplier =
          await db.suppliersDao.getSupplierById(widget.supplierId!);
      if (supplier != null && mounted) {
        setState(() {
          _companyNameController.text = supplier.name;
          _phoneController.text = supplier.phone ?? '';
          _emailController.text = supplier.email ?? '';
          _addressController.text = supplier.address ?? '';
          _vatNumberController.text = supplier.taxNumber ?? '';
          _notesController.text = supplier.notes ?? '';
          _isActive = supplier.isActive;
          if (supplier.paymentTerms != null) {
            _paymentTerms = supplier.paymentTerms!;
          }
          _isLoadingData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingData = false);
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorWithDetails('$e'))),
        );
      }
    }
  }

  @override
  void dispose() {
    ref.read(unsavedChangesProvider.notifier).state = false;
    _companyNameController.dispose();
    _contactNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _vatNumberController.dispose();
    _crNumberController.dispose();
    _notesController.dispose();
    _companyNameFocus.dispose();
    _contactNameFocus.dispose();
    _phoneFocus.dispose();
    _emailFocus.dispose();
    _addressFocus.dispose();
    _vatNumberFocus.dispose();
    _crNumberFocus.dispose();
    _notesFocus.dispose();
    super.dispose();
  }

  Future<bool> _showUnsavedDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: min(
            MediaQuery.of(context).size.width * 0.9,
            400,
          ),
        ),
        child: AlertDialog(
          title: Text(AppLocalizations.of(context).unsavedChanges),
          content: Text(AppLocalizations.of(context).leaveWithoutSaving),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(AppLocalizations.of(context).cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(AppLocalizations.of(context).leave),
            ),
          ],
        ),
      ),
    );
    return result == true;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final isWideScreen = size.width > 900 || (isLandscape && size.width >= 600);
    final isMediumScreen = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS):
            const _SaveIntent(),
        LogicalKeySet(LogicalKeyboardKey.escape): const _DismissFormIntent(),
      },
      child: Actions(
        actions: {
          _SaveIntent: CallbackAction<_SaveIntent>(
            onInvoke: (_) {
              _saveSupplier();
              return null;
            },
          ),
          _DismissFormIntent: CallbackAction<_DismissFormIntent>(
            onInvoke: (_) async {
              if (_isDirty) {
                final shouldLeave = await _showUnsavedDialog();
                if (shouldLeave && mounted) context.pop();
              } else {
                if (mounted) context.pop();
              }
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: PopScope(
            canPop: !_isDirty,
            onPopInvokedWithResult: (didPop, result) async {
              if (didPop) return;
              final shouldPop = await _showUnsavedDialog();
              if (shouldPop && context.mounted) Navigator.pop(context);
            },
            child: SafeArea(
              child: Column(
                children: [
                  AppHeader(
                    title: widget.isEditing
                        ? l10n.editSupplier
                        : l10n.addNewSupplier,
                    onMenuTap: isWideScreen
                        ? null
                        : () => Scaffold.of(context).openDrawer(),
                    onNotificationsTap: () => context.push('/notifications'),
                    notificationsCount: 0,
                    userName: l10n.defaultUserName,
                    userRole: l10n.branchManager,
                  ),
                  Expanded(
                    child: _isLoadingData
                        ? const Center(child: CircularProgressIndicator())
                        : Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 1000),
                              child: Form(
                                key: _formKey,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                child: isWideScreen
                                    ? _buildWideLayout(
                                        isDark, isMediumScreen, l10n)
                                    : _buildNarrowLayout(isDark, l10n),
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

  Widget _buildWideLayout(
      bool isDark, bool isMediumScreen, AppLocalizations l10n) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column: basic info + contact
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AlhaiSpacing.lg),
            child: Column(
              children: [
                _buildBasicInfoSection(isDark, l10n),
                const SizedBox(height: AlhaiSpacing.mdl),
                _buildContactSection(isDark, l10n),
              ],
            ),
          ),
        ),
        // Right column: business + financial + additional + save
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.fromSTEB(AlhaiSpacing.zero,
                AlhaiSpacing.lg, AlhaiSpacing.lg, AlhaiSpacing.lg),
            child: Column(
              children: [
                _buildBusinessSection(isDark, l10n),
                const SizedBox(height: AlhaiSpacing.mdl),
                _buildFinancialSection(isDark, l10n),
                const SizedBox(height: AlhaiSpacing.mdl),
                _buildAdditionalSection(isDark, l10n),
                const SizedBox(height: AlhaiSpacing.lg),
                _buildSaveButton(isDark, l10n),
                if (widget.isEditing) ...[
                  const SizedBox(height: AlhaiSpacing.sm),
                  _buildDeleteButton(isDark, l10n),
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
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      child: Column(
        children: [
          // Back button
          Row(
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: Icon(
                  Directionality.of(context) == TextDirection.rtl
                      ? Icons.arrow_forward_rounded
                      : Icons.arrow_back_rounded,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                tooltip: l10n.back,
              ),
              const SizedBox(width: AlhaiSpacing.xs),
              Expanded(
                child: Text(
                  widget.isEditing ? l10n.editSupplier : l10n.addNewSupplier,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.md),
          _buildBasicInfoSection(isDark, l10n),
          const SizedBox(height: AlhaiSpacing.md),
          _buildContactSection(isDark, l10n),
          const SizedBox(height: AlhaiSpacing.md),
          _buildBusinessSection(isDark, l10n),
          const SizedBox(height: AlhaiSpacing.md),
          _buildFinancialSection(isDark, l10n),
          const SizedBox(height: AlhaiSpacing.md),
          _buildAdditionalSection(isDark, l10n),
          const SizedBox(height: AlhaiSpacing.lg),
          _buildSaveButton(isDark, l10n),
          if (widget.isEditing) ...[
            const SizedBox(height: AlhaiSpacing.sm),
            _buildDeleteButton(isDark, l10n),
          ],
          const SizedBox(height: AlhaiSpacing.lg),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────
  // Section Card
  // ──────────────────────────────────────────────────────────────────────

  Widget _buildSectionCard({
    required bool isDark,
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          ...children,
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────
  // Sections
  // ──────────────────────────────────────────────────────────────────────

  Widget _buildBasicInfoSection(bool isDark, AppLocalizations l10n) {
    return _buildSectionCard(
      isDark: isDark,
      title: l10n.basicInfo,
      icon: Icons.person,
      color: AppColors.primary,
      children: [
        _buildTextField(
          controller: _companyNameController,
          label: l10n.companyNameRequired,
          hint: '',
          icon: Icons.business,
          isDark: isDark,
          maxLength: 150,
          validator: FormValidators.requiredField(maxLength: 150),
          focusNode: _companyNameFocus,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => _contactNameFocus.requestFocus(),
        ),
        const SizedBox(height: AppSizes.md),
        _buildTextField(
          controller: _contactNameController,
          label: l10n.supplierContactName,
          hint: '',
          icon: Icons.person_outline,
          isDark: isDark,
          maxLength: 100,
          validator: FormValidators.name(isRequired: false, maxLength: 100),
          focusNode: _contactNameFocus,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => _phoneFocus.requestFocus(),
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
          validator: FormValidators.phone(),
          focusNode: _phoneFocus,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => _emailFocus.requestFocus(),
        ),
        const SizedBox(height: AppSizes.md),
        _buildTextField(
          controller: _emailController,
          label: l10n.emailField,
          hint: 'example@company.com',
          icon: Icons.email,
          isDark: isDark,
          keyboardType: TextInputType.emailAddress,
          maxLength: 254,
          validator: FormValidators.email(required: false),
          focusNode: _emailFocus,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => _addressFocus.requestFocus(),
        ),
        const SizedBox(height: AppSizes.md),
        _buildTextField(
          controller: _addressController,
          label: l10n.addressField2,
          hint: '',
          icon: Icons.location_on,
          isDark: isDark,
          maxLines: 2,
          maxLength: 300,
          validator: FormValidators.notes(maxLength: 300),
          focusNode: _addressFocus,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => _vatNumberFocus.requestFocus(),
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
        _buildTextField(
          controller: _vatNumberController,
          label: l10n.taxNumberVat,
          hint: '15 digits',
          icon: Icons.receipt_long,
          isDark: isDark,
          keyboardType: TextInputType.number,
          maxLength: 15,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: FormValidators.vatNumber(),
          focusNode: _vatNumberFocus,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => _crNumberFocus.requestFocus(),
        ),
        const SizedBox(height: AppSizes.md),
        _buildTextField(
          controller: _crNumberController,
          label: l10n.commercialRegNumber,
          hint: '10 digits',
          icon: Icons.article,
          isDark: isDark,
          keyboardType: TextInputType.number,
          maxLength: 10,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: FormValidators.crNumber(),
          focusNode: _crNumberFocus,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => _notesFocus.requestFocus(),
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
      ],
    );
  }

  Widget _buildAdditionalSection(bool isDark, AppLocalizations l10n) {
    return _buildSectionCard(
      isDark: isDark,
      title: l10n.additionalSettings,
      icon: Icons.settings,
      color: AppColors.textSecondary,
      children: [
        // Active switch
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AlhaiSpacing.sm, vertical: AlhaiSpacing.xxs),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.03)
                : AppColors.border.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              l10n.supplierActiveLabel,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              l10n.supplierCanCreateOrders,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
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
        // Notes
        _buildTextField(
          controller: _notesController,
          label: l10n.notesLabel,
          hint: l10n.notesFieldHint,
          icon: Icons.note,
          isDark: isDark,
          maxLines: 3,
          maxLength: 500,
          validator: FormValidators.notes(),
          focusNode: _notesFocus,
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────────
  // UI Helpers
  // ──────────────────────────────────────────────────────────────────────

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    int? maxLength,
    String? Function(String?)? validator,
    FocusNode? focusNode,
    TextInputAction? textInputAction,
    ValueChanged<String>? onFieldSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      maxLength: maxLength,
      focusNode: focusNode,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      onChanged: (_) {
        if (!_isDirty) _setDirty(true);
      },
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint.isNotEmpty ? hint : null,
        prefixIcon: Icon(icon),
        labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        hintStyle: TextStyle(
          color: isDark
              ? Colors.white.withValues(alpha: 0.3)
              : AppColors.textTertiary,
        ),
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : AppColors.border.withValues(alpha: 0.15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).dividerColor,
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
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
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
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : AppColors.border.withValues(alpha: 0.15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).dividerColor,
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
      dropdownColor: Theme.of(context).colorScheme.surface,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
      ),
      items: items,
      onChanged: onChanged,
    );
  }

  Widget _buildSaveButton(bool isDark, AppLocalizations l10n) {
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
              : (widget.isEditing ? l10n.updateSupplier : l10n.addSupplierBtn),
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

  Widget _buildDeleteButton(bool isDark, AppLocalizations l10n) {
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

  // ──────────────────────────────────────────────────────────────────────
  // Save Logic
  // ──────────────────────────────────────────────────────────────────────

  Future<void> _saveSupplier() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;

    // Security: Check for dangerous content in text fields
    final fieldsToCheck = [
      _companyNameController.text,
      _contactNameController.text,
      _addressController.text,
      _notesController.text,
    ];
    for (final value in fieldsToCheck) {
      if (value.trim().isNotEmpty &&
          InputSanitizer.containsDangerousContent(value)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.inputContainsDangerousContent),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    final sanitizedName =
        InputSanitizer.sanitize(_companyNameController.text.trim());
    final sanitizedPhone =
        InputSanitizer.sanitize(_phoneController.text.trim());
    final sanitizedEmail =
        InputSanitizer.sanitize(_emailController.text.trim());
    final sanitizedAddress =
        InputSanitizer.sanitize(_addressController.text.trim());
    final sanitizedVat =
        InputSanitizer.sanitize(_vatNumberController.text.trim());
    final sanitizedNotes =
        InputSanitizer.sanitize(_notesController.text.trim());

    try {
      final db = getIt<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider) ?? kDefaultStoreId;

      if (widget.isEditing) {
        final existing =
            await db.suppliersDao.getSupplierById(widget.supplierId!);
        if (existing != null) {
          await db.suppliersDao.updateSupplier(existing.copyWith(
            name: sanitizedName,
            phone: Value(sanitizedPhone.isEmpty ? null : sanitizedPhone),
            email: Value(sanitizedEmail.isEmpty ? null : sanitizedEmail),
            address: Value(sanitizedAddress.isEmpty ? null : sanitizedAddress),
            taxNumber: Value(sanitizedVat.isEmpty ? null : sanitizedVat),
            notes: Value(sanitizedNotes.isEmpty ? null : sanitizedNotes),
            paymentTerms: Value(_paymentTerms),
            isActive: _isActive,
            updatedAt: Value(DateTime.now()),
          ));
        }
      } else {
        final supplierId = 'sup_${DateTime.now().millisecondsSinceEpoch}';

        await db.suppliersDao.insertSupplier(SuppliersTableCompanion(
          id: Value(supplierId),
          storeId: Value(storeId),
          name: Value(sanitizedName),
          phone: Value(sanitizedPhone.isEmpty ? null : sanitizedPhone),
          email: Value(sanitizedEmail.isEmpty ? null : sanitizedEmail),
          address: Value(sanitizedAddress.isEmpty ? null : sanitizedAddress),
          taxNumber: Value(sanitizedVat.isEmpty ? null : sanitizedVat),
          notes: Value(sanitizedNotes.isEmpty ? null : sanitizedNotes),
          paymentTerms: Value(_paymentTerms),
          isActive: Value(_isActive),
          createdAt: Value(DateTime.now()),
        ));
      }

      if (mounted) {
        setState(() => _isLoading = false);
        _setDirty(false);

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
        setState(() => _isLoading = false);
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
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => ConstrainedBox(
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(ctx).size.width > 600
                ? 400
                : MediaQuery.of(ctx).size.width * 0.9),
        child: AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            l10n.deleteSupplier,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
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
      ),
    );
  }

  Future<void> _deleteSupplier() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _isLoading = true);

    try {
      final db = getIt<AppDatabase>();
      await db.suppliersDao.deleteSupplier(widget.supplierId!);

      if (mounted) {
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
        setState(() => _isLoading = false);
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

class _SaveIntent extends Intent {
  const _SaveIntent();
}

class _DismissFormIntent extends Intent {
  const _DismissFormIntent();
}
