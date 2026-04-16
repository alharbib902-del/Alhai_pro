/// Distributor Signup Screen
///
/// Self-service registration for new distributors.
/// Multi-section form: account info + company info + terms acceptance.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

import '../../data/models.dart';
import '../../providers/distributor_onboarding_providers.dart';

/// Saudi cities for dropdown.
const saudiCities = [
  'الرياض',
  'جدة',
  'مكة المكرمة',
  'المدينة المنورة',
  'الدمام',
  'الخبر',
  'الظهران',
  'تبوك',
  'بريدة',
  'خميس مشيط',
  'أبها',
  'الطائف',
  'حائل',
  'نجران',
  'جازان',
  'ينبع',
  'الجبيل',
  'الأحساء',
  'القطيف',
  'حفر الباطن',
];

class DistributorSignupScreen extends ConsumerStatefulWidget {
  const DistributorSignupScreen({super.key});

  @override
  ConsumerState<DistributorSignupScreen> createState() =>
      _DistributorSignupScreenState();
}

class _DistributorSignupScreenState
    extends ConsumerState<DistributorSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _companyNameEnController = TextEditingController();
  final _phoneController = TextEditingController();
  final _crController = TextEditingController();
  final _vatController = TextEditingController();
  final _addressController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptedTerms = false;
  String? _selectedCity;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _companyNameController.dispose();
    _companyNameEnController.dispose();
    _phoneController.dispose();
    _crController.dispose();
    _vatController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب الموافقة على الشروط والأحكام'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final params = SignupParams(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      companyName: _companyNameController.text.trim(),
      companyNameEn: _companyNameEnController.text.trim().isEmpty
          ? null
          : _companyNameEnController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      commercialRegister: _crController.text.trim(),
      vatNumber: _vatController.text.trim(),
      city: _selectedCity ?? '',
      address: _addressController.text.trim(),
      acceptedTerms: _acceptedTerms,
    );

    await ref.read(signupProvider.notifier).signUp(params);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final size = MediaQuery.sizeOf(context);
    final isWide = size.width >= AlhaiBreakpoints.tablet;
    final signupState = ref.watch(signupProvider);

    // Navigate on success
    ref.listen<SignupState>(signupProvider, (prev, next) {
      if (next.result != null) {
        context.go('/verify-email', extra: next.result!.email);
      }
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isWide ? AlhaiSpacing.xl : AlhaiSpacing.lg),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 520),
            padding:
                EdgeInsets.all(isWide ? AlhaiSpacing.xl : AlhaiSpacing.lg),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: isDark
                  ? Border.all(color: AppColors.getBorder(true))
                  : null,
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .shadow
                            .withValues(alpha: 0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Center(
                    child: ExcludeSemantics(
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.store,
                          color: AppColors.textOnPrimary,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.mdl),

                  // Title
                  Center(
                    child: Text(
                      'إنشاء حساب موزّع جديد',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.xl),

                  // ── Section: Account Info ──
                  _SectionHeader(title: 'بيانات الحساب'),
                  const SizedBox(height: AlhaiSpacing.sm),

                  _buildTextField(
                    controller: _emailController,
                    label: '${l10n.distributorEmailLabel} *',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: _validateEmail,
                    isDark: isDark,
                  ),
                  const SizedBox(height: AlhaiSpacing.md),

                  _buildTextField(
                    controller: _passwordController,
                    label: 'كلمة المرور *',
                    icon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    validator: _validatePassword,
                    isDark: isDark,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.md),

                  _buildTextField(
                    controller: _confirmPasswordController,
                    label: 'تأكيد كلمة المرور *',
                    icon: Icons.lock_outline,
                    obscureText: _obscureConfirmPassword,
                    textInputAction: TextInputAction.next,
                    validator: _validateConfirmPassword,
                    isDark: isDark,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () => setState(
                        () =>
                            _obscureConfirmPassword = !_obscureConfirmPassword,
                      ),
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.lg),

                  // ── Section: Company Info ──
                  _SectionHeader(title: 'بيانات الشركة'),
                  const SizedBox(height: AlhaiSpacing.sm),

                  _buildTextField(
                    controller: _companyNameController,
                    label: 'اسم الشركة (عربي) *',
                    icon: Icons.business_outlined,
                    textInputAction: TextInputAction.next,
                    validator: (v) => _validateLength(v, 'اسم الشركة', 3, 100),
                    isDark: isDark,
                  ),
                  const SizedBox(height: AlhaiSpacing.md),

                  _buildTextField(
                    controller: _companyNameEnController,
                    label: 'Company Name (English)',
                    icon: Icons.business_outlined,
                    textInputAction: TextInputAction.next,
                    isDark: isDark,
                  ),
                  const SizedBox(height: AlhaiSpacing.md),

                  _buildTextField(
                    controller: _phoneController,
                    label: 'رقم الجوال *',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    validator: _validatePhone,
                    isDark: isDark,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d\+]')),
                    ],
                  ),
                  const SizedBox(height: AlhaiSpacing.md),

                  _buildTextField(
                    controller: _crController,
                    label: 'السجل التجاري (10 أرقام) *',
                    icon: Icons.description_outlined,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    validator: _validateCR,
                    isDark: isDark,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                  ),
                  const SizedBox(height: AlhaiSpacing.md),

                  _buildTextField(
                    controller: _vatController,
                    label: 'الرقم الضريبي (15 رقم) *',
                    icon: Icons.receipt_outlined,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    validator: _validateVAT,
                    isDark: isDark,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(15),
                    ],
                  ),
                  const SizedBox(height: AlhaiSpacing.md),

                  // City dropdown
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCity,
                    decoration: _inputDecoration(
                      label: 'المدينة *',
                      icon: Icons.location_city_outlined,
                      isDark: isDark,
                    ),
                    items: saudiCities
                        .map(
                          (city) => DropdownMenuItem(
                            value: city,
                            child: Text(city),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedCity = v),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'يرجى اختيار المدينة' : null,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    dropdownColor: Theme.of(context).colorScheme.surface,
                  ),
                  const SizedBox(height: AlhaiSpacing.md),

                  _buildTextField(
                    controller: _addressController,
                    label: 'العنوان التفصيلي *',
                    icon: Icons.location_on_outlined,
                    maxLines: 2,
                    textInputAction: TextInputAction.done,
                    validator: (v) =>
                        _validateLength(v, 'العنوان', 10, 200),
                    isDark: isDark,
                  ),
                  const SizedBox(height: AlhaiSpacing.lg),

                  // ── Terms Checkbox ──
                  CheckboxListTile(
                    value: _acceptedTerms,
                    onChanged: (v) =>
                        setState(() => _acceptedTerms = v ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'أوافق على الشروط والأحكام وسياسة الخصوصية',
                      style: TextStyle(fontSize: 14),
                    ),
                    activeColor: AppColors.primary,
                  ),
                  const SizedBox(height: AlhaiSpacing.lg),

                  // ── Submit Button ──
                  Semantics(
                    button: true,
                    label: 'إنشاء الحساب',
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: signupState.isLoading ? null : _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textOnPrimary,
                          padding: const EdgeInsets.symmetric(
                            vertical: AlhaiSpacing.md,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: signupState.isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.textOnPrimary,
                                ),
                              )
                            : const Text(
                                'إنشاء الحساب',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.md),

                  // ── Login Link ──
                  Center(
                    child: TextButton(
                      onPressed: () => context.go('/login'),
                      child: Text(
                        'أملك حساب بالفعل؟ تسجيل دخول',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
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

  // ─── Field Builder ──────────────────────────────────────────────

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    String? Function(String?)? validator,
    bool obscureText = false,
    Widget? suffixIcon,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      maxLines: maxLines,
      validator: validator,
      inputFormatters: inputFormatters,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
      ),
      decoration: _inputDecoration(
        label: label,
        icon: icon,
        isDark: isDark,
        suffixIcon: suffixIcon,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    required bool isDark,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(
        icon,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: isDark
          ? Theme.of(context).colorScheme.surfaceContainerHighest
          : AppColors.backgroundSecondary,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }

  // ─── Validators ─────────────────────────────────────────────────

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'البريد الإلكتروني مطلوب';
    final emailRegex = RegExp(r'^[\w\-\.+]+@([\w\-]+\.)+[\w\-]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) return 'صيغة البريد غير صحيحة';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'كلمة المرور مطلوبة';
    if (value.length < 8) return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    if (!RegExp(r'\d').hasMatch(value)) {
      return 'كلمة المرور يجب أن تحتوي على رقم واحد على الأقل';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'تأكيد كلمة المرور مطلوب';
    if (value != _passwordController.text) return 'كلمتا المرور غير متطابقتين';
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return 'رقم الجوال مطلوب';
    final phone = value.trim();
    // Accept +966XXXXXXXXX or 05XXXXXXXX
    final phoneRegex = RegExp(r'^(\+966|05)\d{8}$');
    if (!phoneRegex.hasMatch(phone)) {
      return 'صيغة الجوال: +966XXXXXXXXX أو 05XXXXXXXX';
    }
    return null;
  }

  String? _validateCR(String? value) {
    if (value == null || value.trim().isEmpty) return 'السجل التجاري مطلوب';
    final cr = value.trim();
    if (cr.length != 10) return 'السجل التجاري يجب أن يكون 10 أرقام';
    if (!RegExp(r'^[12]\d{9}$').hasMatch(cr)) {
      return 'السجل التجاري يجب أن يبدأ بـ 1 أو 2';
    }
    return null;
  }

  String? _validateVAT(String? value) {
    if (value == null || value.trim().isEmpty) return 'الرقم الضريبي مطلوب';
    final vat = value.trim();
    if (vat.length != 15) return 'الرقم الضريبي يجب أن يكون 15 رقم';
    if (!vat.startsWith('3')) return 'الرقم الضريبي يجب أن يبدأ بـ 3';
    return null;
  }

  String? _validateLength(
    String? value,
    String fieldName,
    int min,
    int max,
  ) {
    if (value == null || value.trim().isEmpty) return '$fieldName مطلوب';
    final trimmed = value.trim();
    if (trimmed.length < min) return '$fieldName يجب أن يكون $min أحرف على الأقل';
    if (trimmed.length > max) return '$fieldName يجب ألا يتجاوز $max حرف';
    return null;
  }
}

// ─── Section Header ──────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AlhaiSpacing.xs),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
