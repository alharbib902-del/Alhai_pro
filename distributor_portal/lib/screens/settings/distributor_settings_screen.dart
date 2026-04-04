/// Distributor Settings Screen
///
/// Company info, notification settings, and delivery settings.
/// Wired to real Supabase data via orgSettingsProvider.
/// Supports: RTL Arabic, dark/light theme, responsive layout.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import '../../data/models.dart';
import '../../providers/distributor_providers.dart';

// ─── Screen ──────────────────────────────────────────────────────

/// شاشة الإعدادات للموزع
class DistributorSettingsScreen extends ConsumerStatefulWidget {
  const DistributorSettingsScreen({super.key});

  @override
  ConsumerState<DistributorSettingsScreen> createState() =>
      _DistributorSettingsScreenState();
}

class _DistributorSettingsScreenState
    extends ConsumerState<DistributorSettingsScreen> {
  // Company info controllers
  final _companyNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  // Notification settings
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _smsNotifications = false;
  bool _newOrderNotification = true;
  bool _orderStatusNotification = true;
  bool _paymentNotification = true;

  // Delivery settings
  final _deliveryZonesController = TextEditingController();
  final _minOrderController = TextEditingController();
  final _deliveryFeeController = TextEditingController();
  final _freeDeliveryMinController = TextEditingController();
  bool _freeDeliveryEnabled = true;

  bool _isSaving = false;

  /// The org ID loaded from Supabase, needed for saving back.
  String? _orgId;

  /// Whether we have already populated controllers from fetched data.
  bool _didPopulate = false;

  void _populateFromSettings(OrgSettings settings) {
    if (_didPopulate) return;
    _didPopulate = true;

    _orgId = settings.id;
    _companyNameController.text = settings.companyName;
    _phoneController.text = settings.phone ?? '';
    _emailController.text = settings.email ?? '';
    _addressController.text = settings.address ?? '';
    _deliveryZonesController.text = settings.deliveryZones ?? '';
    _minOrderController.text =
        settings.minOrderAmount?.toStringAsFixed(0) ?? '';
    _deliveryFeeController.text =
        settings.deliveryFee?.toStringAsFixed(0) ?? '';
    _freeDeliveryMinController.text =
        settings.freeDeliveryMin?.toStringAsFixed(0) ?? '';

    _emailNotifications = settings.emailNotifications;
    _pushNotifications = settings.pushNotifications;
    _smsNotifications = settings.smsNotifications;
    _freeDeliveryEnabled = settings.freeDeliveryEnabled;
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _deliveryZonesController.dispose();
    _minOrderController.dispose();
    _deliveryFeeController.dispose();
    _freeDeliveryMinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;
    final isMedium = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    final settingsAsync = ref.watch(orgSettingsProvider);

    return Scaffold(
      backgroundColor: AppColors.getBackground(isDark),
      appBar: AppBar(
        title: Text(
          'الإعدادات',
          style: TextStyle(fontWeight: FontWeight.bold, color: cs.onSurface),
        ),
        centerTitle: false,
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline,
                  size: 48, color: AppColors.getTextMuted(isDark)),
              const SizedBox(height: AlhaiSpacing.md),
              Text(
                'حدث خطأ في تحميل الإعدادات',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.getTextSecondary(isDark),
                ),
              ),
              const SizedBox(height: AlhaiSpacing.md),
              FilledButton.icon(
                onPressed: () => ref.invalidate(orgSettingsProvider),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('إعادة المحاولة'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        data: (settings) {
          if (settings == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.business_rounded,
                      size: 48, color: AppColors.getTextMuted(isDark)),
                  const SizedBox(height: AlhaiSpacing.md),
                  Text(
                    'لم يتم العثور على بيانات المنشأة',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.getTextSecondary(isDark),
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.md),
                  FilledButton.icon(
                    onPressed: () => ref.invalidate(orgSettingsProvider),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('إعادة المحاولة'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          // Populate controllers once from fetched data
          _populateFromSettings(settings);

          return SingleChildScrollView(
            padding:
                EdgeInsets.all(isMedium ? AlhaiSpacing.lg : AlhaiSpacing.md),
            child: isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            _buildCompanyInfoSection(isDark),
                            const SizedBox(height: AlhaiSpacing.lg),
                            _buildDeliverySection(isDark),
                          ],
                        ),
                      ),
                      const SizedBox(width: AlhaiSpacing.lg),
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            _buildNotificationsSection(isDark),
                            const SizedBox(height: AlhaiSpacing.lg),
                            _buildSaveButton(isDark),
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildCompanyInfoSection(isDark),
                      SizedBox(
                          height:
                              isMedium ? AlhaiSpacing.lg : AlhaiSpacing.md),
                      _buildNotificationsSection(isDark),
                      SizedBox(
                          height:
                              isMedium ? AlhaiSpacing.lg : AlhaiSpacing.md),
                      _buildDeliverySection(isDark),
                      const SizedBox(height: AlhaiSpacing.lg),
                      _buildSaveButton(isDark),
                      const SizedBox(height: AlhaiSpacing.xl),
                    ],
                  ),
          );
        },
      ),
    );
  }

  // ─── Company Info Section ──────────────────────────────────────

  Widget _buildCompanyInfoSection(bool isDark) {
    return _sectionCard(
      icon: Icons.business_rounded,
      iconColor: AppColors.primary,
      title: 'معلومات الشركة',
      isDark: isDark,
      children: [
        _buildField(
          label: 'اسم الشركة',
          controller: _companyNameController,
          icon: Icons.badge_rounded,
          isDark: isDark,
        ),
        const SizedBox(height: AlhaiSpacing.md),
        _buildField(
          label: 'رقم الهاتف',
          controller: _phoneController,
          icon: Icons.phone_rounded,
          keyboardType: TextInputType.phone,
          isDark: isDark,
        ),
        const SizedBox(height: AlhaiSpacing.md),
        _buildField(
          label: 'البريد الإلكتروني',
          controller: _emailController,
          icon: Icons.email_rounded,
          keyboardType: TextInputType.emailAddress,
          isDark: isDark,
        ),
        const SizedBox(height: AlhaiSpacing.md),
        _buildField(
          label: 'العنوان',
          controller: _addressController,
          icon: Icons.location_on_rounded,
          maxLines: 2,
          isDark: isDark,
        ),
      ],
    );
  }

  // ─── Notifications Section ─────────────────────────────────────

  Widget _buildNotificationsSection(bool isDark) {
    return _sectionCard(
      icon: Icons.notifications_rounded,
      iconColor: AppColors.info,
      title: 'إعدادات الإشعارات',
      isDark: isDark,
      children: [
        Text(
          'قنوات الإشعارات',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.getTextSecondary(isDark),
          ),
        ),
        const SizedBox(height: AlhaiSpacing.xs),
        _switchTile(
          'البريد الإلكتروني',
          Icons.email_outlined,
          _emailNotifications,
          (v) => setState(() => _emailNotifications = v),
          isDark,
        ),
        _switchTile(
          'إشعارات الجوال',
          Icons.phone_android_rounded,
          _pushNotifications,
          (v) => setState(() => _pushNotifications = v),
          isDark,
        ),
        _switchTile(
          'رسائل SMS',
          Icons.sms_rounded,
          _smsNotifications,
          (v) => setState(() => _smsNotifications = v),
          isDark,
        ),
        const SizedBox(height: AlhaiSpacing.md),
        Divider(color: AppColors.getBorder(isDark)),
        const SizedBox(height: AlhaiSpacing.sm),
        Text(
          'أنواع الإشعارات',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.getTextSecondary(isDark),
          ),
        ),
        const SizedBox(height: AlhaiSpacing.xs),
        _switchTile(
          'طلبات جديدة',
          Icons.fiber_new_rounded,
          _newOrderNotification,
          (v) => setState(() => _newOrderNotification = v),
          isDark,
        ),
        _switchTile(
          'تحديث حالة الطلب',
          Icons.update_rounded,
          _orderStatusNotification,
          (v) => setState(() => _orderStatusNotification = v),
          isDark,
        ),
        _switchTile(
          'إشعارات الدفع',
          Icons.payment_rounded,
          _paymentNotification,
          (v) => setState(() => _paymentNotification = v),
          isDark,
        ),
      ],
    );
  }

  // ─── Delivery Section ──────────────────────────────────────────

  Widget _buildDeliverySection(bool isDark) {
    return _sectionCard(
      icon: Icons.local_shipping_rounded,
      iconColor: AppColors.secondary,
      title: 'إعدادات التسليم',
      isDark: isDark,
      children: [
        _buildField(
          label: 'مناطق التوصيل',
          controller: _deliveryZonesController,
          icon: Icons.map_rounded,
          maxLines: 2,
          hintText: 'أدخل المدن مفصولة بفاصلة',
          isDark: isDark,
        ),
        const SizedBox(height: AlhaiSpacing.md),
        Row(
          children: [
            Expanded(
              child: _buildField(
                label: 'الحد الأدنى للطلب (ر.س)',
                controller: _minOrderController,
                icon: Icons.shopping_cart_rounded,
                keyboardType: TextInputType.number,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: AlhaiSpacing.md),
            Expanded(
              child: _buildField(
                label: 'رسوم التوصيل (ر.س)',
                controller: _deliveryFeeController,
                icon: Icons.delivery_dining_rounded,
                keyboardType: TextInputType.number,
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: AlhaiSpacing.md),
        _switchTile(
          'توصيل مجاني',
          Icons.local_offer_rounded,
          _freeDeliveryEnabled,
          (v) => setState(() => _freeDeliveryEnabled = v),
          isDark,
        ),
        if (_freeDeliveryEnabled) ...[
          const SizedBox(height: AlhaiSpacing.sm),
          _buildField(
            label: 'الحد الأدنى للتوصيل المجاني (ر.س)',
            controller: _freeDeliveryMinController,
            icon: Icons.attach_money_rounded,
            keyboardType: TextInputType.number,
            isDark: isDark,
          ),
        ],
      ],
    );
  }

  // ─── Save Button ───────────────────────────────────────────────

  Widget _buildSaveButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _isSaving ? null : _saveSettings,
        icon: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.save_rounded, size: 20),
        label: const Text('حفظ الإعدادات',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.md),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────

  Widget _sectionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required bool isDark,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.mdl),
          ...children,
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool isDark,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.getTextSecondary(isDark),
          ),
        ),
        const SizedBox(height: AlhaiSpacing.xs),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: TextStyle(color: AppColors.getTextPrimary(isDark)),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: AppColors.getTextMuted(isDark)),
            prefixIcon: maxLines == 1
                ? Icon(icon, color: AppColors.getTextMuted(isDark))
                : null,
            filled: true,
            fillColor: AppColors.getSurfaceVariant(isDark),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.getBorder(isDark)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.getBorder(isDark)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: AlhaiSpacing.md, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _switchTile(String label, IconData icon, bool value,
      ValueChanged<bool> onChanged, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xxs),
      child: Row(
        children: [
          Icon(icon, color: AppColors.getTextMuted(isDark), size: 20),
          const SizedBox(width: AlhaiSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.getTextPrimary(isDark),
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Future<void> _saveSettings() async {
    if (_orgId == null) return;

    setState(() => _isSaving = true);

    final updated = OrgSettings(
      id: _orgId!,
      companyName: _companyNameController.text,
      phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
      email: _emailController.text.isNotEmpty ? _emailController.text : null,
      address:
          _addressController.text.isNotEmpty ? _addressController.text : null,
      deliveryZones: _deliveryZonesController.text.isNotEmpty
          ? _deliveryZonesController.text
          : null,
      minOrderAmount: double.tryParse(_minOrderController.text),
      deliveryFee: double.tryParse(_deliveryFeeController.text),
      freeDeliveryMin: double.tryParse(_freeDeliveryMinController.text),
      freeDeliveryEnabled: _freeDeliveryEnabled,
      emailNotifications: _emailNotifications,
      pushNotifications: _pushNotifications,
      smsNotifications: _smsNotifications,
    );

    final ds = ref.read(distributorDatasourceProvider);
    final success = await ds.updateOrgSettings(updated);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      // Refresh the provider so next build picks up the saved data
      ref.invalidate(orgSettingsProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ الإعدادات بنجاح'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حدث خطأ أثناء حفظ الإعدادات'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
