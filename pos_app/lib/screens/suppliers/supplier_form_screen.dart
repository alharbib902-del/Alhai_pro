/// شاشة نموذج المورد - Supplier Form Screen
///
/// شاشة لإضافة وتعديل بيانات الموردين
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';
import '../../core/router/routes.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/layout/app_sidebar.dart';
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
  bool _sidebarCollapsed = false;
  String _selectedNavId = 'suppliers';

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

  void _loadSupplierData() {
    // محاكاة تحميل البيانات
    _nameController.text = 'محمد العلي';
    _companyNameController.text = 'شركة الأغذية المتحدة';
    _phoneController.text = '0501234567';
    _emailController.text = 'supplier@food.com';
    _addressController.text = 'الرياض، حي الملز';
    _vatNumberController.text = '300000000000003';
    _crNumberController.text = '1234567890';
    _bankNameController.text = 'بنك الراجحي';
    _ibanController.text = 'SA0380000000608010167519';
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

  void _handleNavigation(AppSidebarItem item) {
    setState(() => _selectedNavId = item.id);
    switch (item.id) {
      case 'dashboard':
        context.go(AppRoutes.dashboard);
        break;
      case 'pos':
        context.go(AppRoutes.pos);
        break;
      case 'products':
        context.go(AppRoutes.products);
        break;
      case 'categories':
        context.go(AppRoutes.categories);
        break;
      case 'inventory':
        context.go(AppRoutes.inventory);
        break;
      case 'customers':
        context.go(AppRoutes.customers);
        break;
      case 'suppliers':
        context.go(AppRoutes.suppliers);
        break;
      case 'invoices':
        context.go(AppRoutes.invoices);
        break;
      case 'orders':
        context.go(AppRoutes.orders);
        break;
      case 'sales':
        context.go(AppRoutes.invoices);
        break;
      case 'returns':
        context.go(AppRoutes.returns);
        break;
      case 'void-transaction':
        context.go(AppRoutes.voidTransaction);
        break;
      case 'reports':
        context.go(AppRoutes.reports);
        break;
      case 'employees':
        context.go(AppRoutes.settings);
        break;
      case 'loyalty':
        context.go(AppRoutes.loyalty);
        break;
      case 'expenses':
        context.go(AppRoutes.expenses);
        break;
      case 'shifts':
        context.go(AppRoutes.shifts);
        break;
      case 'purchases':
        context.go(AppRoutes.purchaseForm);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 900;
    final isMediumScreen = screenWidth > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : AppColors.backgroundSecondary,
      drawer: isWideScreen ? null : _buildDrawer(l10n),
      body: Row(
        children: [
          // Sidebar - only on wide screens
          if (isWideScreen)
            AppSidebar(
              storeName: 'Al-Hai POS',
              groups: DefaultSidebarItems.getGroups(context),
              selectedId: _selectedNavId,
              onItemTap: _handleNavigation,
              collapsed: _sidebarCollapsed,
              userName: 'أحمد محمد',
              userRole: l10n.dashboard,
              onSettingsTap: () => context.go(AppRoutes.settings),
              onSupportTap: () {},
              onLogoutTap: () => context.go(AppRoutes.login),
            ),

          // Main content
          Expanded(
            child: Column(
              children: [
                // Header
                AppHeader(
                  title: widget.isEditing
                      ? 'تعديل المورد' // TODO: localize
                      : 'إضافة مورد جديد', // TODO: localize
                  onMenuTap: isWideScreen
                      ? () => setState(
                          () => _sidebarCollapsed = !_sidebarCollapsed)
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
            ),
          ),
        ],
      ),
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
                _buildBasicInfoSection(isDark),
                const SizedBox(height: 20),
                _buildContactSection(isDark),
                const SizedBox(height: 20),
                _buildBusinessSection(isDark),
              ],
            ),
          ),
        ),

        // Right column: financial + additional + save
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(0, 24, 24, 24),
            child: Column(
              children: [
                _buildFinancialSection(isDark),
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
          _buildBasicInfoSection(isDark),
          const SizedBox(height: 16),
          _buildContactSection(isDark),
          const SizedBox(height: 16),
          _buildBusinessSection(isDark),
          const SizedBox(height: 16),
          _buildFinancialSection(isDark),
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

  Widget _buildBasicInfoSection(bool isDark) {
    return _buildSectionCard(
      isDark: isDark,
      title: 'المعلومات الأساسية', // TODO: localize
      icon: Icons.person,
      color: AppColors.primary,
      children: [
        // اسم المورد
        _buildTextField(
          controller: _nameController,
          label: 'اسم المورد / جهة الاتصال *', // TODO: localize
          hint: 'مثال: محمد العلي', // TODO: localize
          icon: Icons.person_outline,
          isDark: isDark,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'يرجى إدخال اسم المورد'; // TODO: localize
            }
            return null;
          },
        ),
        const SizedBox(height: AppSizes.md),

        // اسم الشركة
        _buildTextField(
          controller: _companyNameController,
          label: 'اسم الشركة *', // TODO: localize
          hint: 'مثال: شركة الأغذية المتحدة', // TODO: localize
          icon: Icons.business,
          isDark: isDark,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'يرجى إدخال اسم الشركة'; // TODO: localize
            }
            return null;
          },
        ),
        const SizedBox(height: AppSizes.md),

        // التصنيف
        _buildDropdown(
          label: 'التصنيف', // TODO: localize
          icon: Icons.category,
          value: _category,
          isDark: isDark,
          items: const [
            DropdownMenuItem(value: 'general', child: Text('عام')),
            DropdownMenuItem(value: 'food', child: Text('مواد غذائية')),
            DropdownMenuItem(value: 'beverages', child: Text('مشروبات')),
            DropdownMenuItem(value: 'dairy', child: Text('ألبان')),
            DropdownMenuItem(value: 'meat', child: Text('لحوم')),
            DropdownMenuItem(
                value: 'vegetables', child: Text('خضروات وفواكه')),
            DropdownMenuItem(value: 'equipment', child: Text('معدات')),
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

  Widget _buildContactSection(bool isDark) {
    return _buildSectionCard(
      isDark: isDark,
      title: 'معلومات التواصل', // TODO: localize
      icon: Icons.contact_phone,
      color: AppColors.info,
      children: [
        // رقم الهاتف
        _buildTextField(
          controller: _phoneController,
          label: 'رقم الهاتف الأساسي *', // TODO: localize
          hint: '05xxxxxxxx',
          icon: Icons.phone,
          isDark: isDark,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          prefixText: '+966 ',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'يرجى إدخال رقم الهاتف'; // TODO: localize
            }
            if (value.length != 10 || !value.startsWith('05')) {
              return 'رقم هاتف غير صحيح'; // TODO: localize
            }
            return null;
          },
        ),
        const SizedBox(height: AppSizes.md),

        // رقم هاتف ثانوي
        _buildTextField(
          controller: _phone2Controller,
          label: 'رقم هاتف ثانوي (اختياري)', // TODO: localize
          hint: '05xxxxxxxx',
          icon: Icons.phone_android,
          isDark: isDark,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          prefixText: '+966 ',
        ),
        const SizedBox(height: AppSizes.md),

        // البريد الإلكتروني
        _buildTextField(
          controller: _emailController,
          label: 'البريد الإلكتروني', // TODO: localize
          hint: 'example@company.com',
          icon: Icons.email,
          isDark: isDark,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value)) {
                return 'بريد إلكتروني غير صحيح'; // TODO: localize
              }
            }
            return null;
          },
        ),
        const SizedBox(height: AppSizes.md),

        // العنوان
        _buildTextField(
          controller: _addressController,
          label: 'العنوان', // TODO: localize
          hint: 'المدينة، الحي، الشارع', // TODO: localize
          icon: Icons.location_on,
          isDark: isDark,
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildBusinessSection(bool isDark) {
    return _buildSectionCard(
      isDark: isDark,
      title: 'المعلومات التجارية', // TODO: localize
      icon: Icons.business_center,
      color: AppColors.warning,
      children: [
        // الرقم الضريبي
        _buildTextField(
          controller: _vatNumberController,
          label: 'الرقم الضريبي (VAT)', // TODO: localize
          hint: '15 رقم', // TODO: localize
          icon: Icons.receipt_long,
          isDark: isDark,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(15),
          ],
        ),
        const SizedBox(height: AppSizes.md),

        // السجل التجاري
        _buildTextField(
          controller: _crNumberController,
          label: 'رقم السجل التجاري (CR)', // TODO: localize
          hint: '10 أرقام', // TODO: localize
          icon: Icons.article,
          isDark: isDark,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
        ),
      ],
    );
  }

  Widget _buildFinancialSection(bool isDark) {
    return _buildSectionCard(
      isDark: isDark,
      title: 'المعلومات المالية', // TODO: localize
      icon: Icons.account_balance,
      color: AppColors.success,
      children: [
        // شروط الدفع
        _buildDropdown(
          label: 'شروط الدفع', // TODO: localize
          icon: Icons.calendar_today,
          value: _paymentTerms,
          isDark: isDark,
          items: const [
            DropdownMenuItem(value: 'cod', child: Text('الدفع عند الاستلام')),
            DropdownMenuItem(value: '7', child: Text('7 أيام')),
            DropdownMenuItem(value: '14', child: Text('14 يوم')),
            DropdownMenuItem(value: '30', child: Text('30 يوم')),
            DropdownMenuItem(value: '45', child: Text('45 يوم')),
            DropdownMenuItem(value: '60', child: Text('60 يوم')),
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
          label: 'اسم البنك', // TODO: localize
          hint: 'مثال: بنك الراجحي', // TODO: localize
          icon: Icons.account_balance,
          isDark: isDark,
        ),
        const SizedBox(height: AppSizes.md),

        // IBAN
        _buildTextField(
          controller: _ibanController,
          label: 'رقم الحساب IBAN', // TODO: localize
          hint: 'SAxx xxxx xxxx xxxx xxxx xxxx',
          icon: Icons.credit_card,
          isDark: isDark,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
            LengthLimitingTextInputFormatter(24),
          ],
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              if (value.length != 24 || !value.startsWith('SA')) {
                return 'رقم IBAN غير صحيح'; // TODO: localize
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAdditionalSection(bool isDark) {
    return _buildSectionCard(
      isDark: isDark,
      title: 'إعدادات إضافية', // TODO: localize
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
              'المورد نشط', // TODO: localize
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              'يمكن إنشاء طلبات شراء من هذا المورد', // TODO: localize
              style: TextStyle(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.5)
                    : AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            value: _isActive,
            activeColor: AppColors.primary,
            onChanged: (value) {
              setState(() => _isActive = value);
            },
          ),
        ),
        const SizedBox(height: AppSizes.md),

        // ملاحظات
        _buildTextField(
          controller: _notesController,
          label: 'ملاحظات', // TODO: localize
          hint: 'أي ملاحظات إضافية عن المورد...', // TODO: localize
          icon: Icons.note,
          isDark: isDark,
          maxLines: 3,
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
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      maxLines: maxLines,
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
      value: value,
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
              ? 'جاري الحفظ...' // TODO: localize
              : (widget.isEditing
                  ? 'تحديث المورد' // TODO: localize
                  : 'إضافة المورد'), // TODO: localize
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
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _showDeleteConfirmation,
        icon: const Icon(Icons.delete_outline_rounded),
        label: const Text('حذف المورد'), // TODO: localize
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

  Widget _buildDrawer(AppLocalizations l10n) {
    return Drawer(
      child: AppSidebar(
        storeName: 'Al-Hai POS',
        groups: DefaultSidebarItems.getGroups(context),
        selectedId: _selectedNavId,
        onItemTap: (item) {
          Navigator.pop(context);
          _handleNavigation(item);
        },
        userName: 'أحمد محمد',
        userRole: l10n.dashboard,
        onSettingsTap: () {
          Navigator.pop(context);
          context.go(AppRoutes.settings);
        },
        onSupportTap: () => Navigator.pop(context),
        onLogoutTap: () {
          Navigator.pop(context);
          context.go(AppRoutes.login);
        },
      ),
    );
  }

  void _saveSupplier() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // محاكاة الحفظ
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      HapticFeedback.heavyImpact();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing
                ? 'تم تحديث بيانات المورد' // TODO: localize
                : 'تم إضافة المورد بنجاح', // TODO: localize
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      context.pop();
    }
  }

  void _showDeleteConfirmation() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'حذف المورد', // TODO: localize
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        content: Text(
          'هل أنت متأكد من حذف هذا المورد؟ سيتم حذف جميع البيانات المرتبطة به.', // TODO: localize
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
              'إلغاء', // TODO: localize
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
            child: const Text('حذف'), // TODO: localize
          ),
        ],
      ),
    );
  }

  void _deleteSupplier() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      HapticFeedback.mediumImpact();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم حذف المورد'), // TODO: localize
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      context.pop();
    }
  }
}
