/// Distributor Settings Screen
///
/// Company info, notification settings, and delivery settings.
/// All fields editable but non-functional (UI only for now).
/// Supports: RTL Arabic, dark/light theme, responsive layout.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

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
  final _companyNameController =
      TextEditingController(text: 'شركة المورد المتحد');
  final _phoneController = TextEditingController(text: '+966 55 123 4567');
  final _emailController =
      TextEditingController(text: 'info@united-distributor.sa');
  final _addressController =
      TextEditingController(text: 'الرياض، حي العليا، شارع التحلية');

  // Notification settings
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _smsNotifications = false;
  bool _newOrderNotification = true;
  bool _orderStatusNotification = true;
  bool _paymentNotification = true;

  // Delivery settings
  final _deliveryZonesController =
      TextEditingController(text: 'الرياض، جدة، الدمام');
  final _minOrderController = TextEditingController(text: '500');
  final _deliveryFeeController = TextEditingController(text: '50');
  final _freeDeliveryMinController = TextEditingController(text: '2000');
  bool _freeDeliveryEnabled = true;

  bool _isSaving = false;

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

    return Scaffold(
        backgroundColor: AppColors.getBackground(isDark),
        appBar: AppBar(
          title: Text(
            'الإعدادات',
            style: TextStyle(fontWeight: FontWeight.bold, color: cs.onSurface),
          ),
          centerTitle: false,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(isMedium ? 24 : 16),
          child: isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          _buildCompanyInfoSection(isDark),
                          const SizedBox(height: 24),
                          _buildDeliverySection(isDark),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          _buildNotificationsSection(isDark),
                          const SizedBox(height: 24),
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
                    SizedBox(height: isMedium ? 24 : 16),
                    _buildNotificationsSection(isDark),
                    SizedBox(height: isMedium ? 24 : 16),
                    _buildDeliverySection(isDark),
                    const SizedBox(height: 24),
                    _buildSaveButton(isDark),
                    const SizedBox(height: 32),
                  ],
                ),
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
        const SizedBox(height: 16),
        _buildField(
          label: 'رقم الهاتف',
          controller: _phoneController,
          icon: Icons.phone_rounded,
          keyboardType: TextInputType.phone,
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        _buildField(
          label: 'البريد الإلكتروني',
          controller: _emailController,
          icon: Icons.email_rounded,
          keyboardType: TextInputType.emailAddress,
          isDark: isDark,
        ),
        const SizedBox(height: 16),
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
        const SizedBox(height: 8),
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
        const SizedBox(height: 16),
        Divider(color: AppColors.getBorder(isDark)),
        const SizedBox(height: 12),
        Text(
          'أنواع الإشعارات',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.getTextSecondary(isDark),
          ),
        ),
        const SizedBox(height: 8),
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
        const SizedBox(height: 16),
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
            const SizedBox(width: 16),
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
        const SizedBox(height: 16),
        _switchTile(
          'توصيل مجاني',
          Icons.local_offer_rounded,
          _freeDeliveryEnabled,
          (v) => setState(() => _freeDeliveryEnabled = v),
          isDark,
        ),
        if (_freeDeliveryEnabled) ...[
          const SizedBox(height: 12),
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
          padding: const EdgeInsets.symmetric(vertical: 16),
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
      padding: const EdgeInsets.all(20),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
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
          const SizedBox(height: 20),
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
        const SizedBox(height: 8),
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
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _switchTile(String label, IconData icon, bool value,
      ValueChanged<bool> onChanged, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: AppColors.getTextMuted(isDark), size: 20),
          const SizedBox(width: 12),
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
    setState(() => _isSaving = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حفظ الإعدادات بنجاح'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
