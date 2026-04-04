/// Distributor Settings Screen
///
/// Company info, notification settings, and delivery settings.
/// Wired to real Supabase data via orgSettingsProvider.
/// Supports: RTL Arabic, dark/light theme, responsive layout.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

import '../../data/models.dart';
import '../../providers/distributor_providers.dart';
import '../../ui/skeleton_loading.dart';

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
  bool _hasChanges = false;

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
    final isWide = size.width >= AlhaiBreakpoints.desktop;
    final isMedium = size.width >= AlhaiBreakpoints.tablet;
    final isMobile = size.width < AlhaiBreakpoints.tablet;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    final l10n = AppLocalizations.of(context);
    final settingsAsync = ref.watch(orgSettingsProvider);

    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _showUnsavedDialog();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: CallbackShortcuts(
        bindings: <ShortcutActivator, VoidCallback>{
          const SingleActivator(LogicalKeyboardKey.keyS, control: true): () {
            if (!_isSaving) _saveSettings();
          },
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
      backgroundColor: AppColors.getBackground(isDark),
      appBar: AppBar(
        title: Text(
          l10n?.distributorSettings ?? 'الإعدادات',
          style: TextStyle(fontWeight: FontWeight.bold, color: cs.onSurface),
        ),
        centerTitle: false,
      ),
      body: settingsAsync.when(
        loading: () => const TableSkeleton(rows: 6, columns: 2),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline,
                  size: 48, color: AppColors.getTextMuted(isDark)),
              const SizedBox(height: AlhaiSpacing.md),
              Text(
                l10n?.distributorLoadError ?? 'حدث خطأ في تحميل الإعدادات',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.getTextSecondary(isDark),
                ),
              ),
              const SizedBox(height: AlhaiSpacing.md),
              FilledButton.icon(
                onPressed: () => ref.invalidate(orgSettingsProvider),
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(l10n?.distributorRetry ?? 'إعادة المحاولة'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
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
                    label: Text(l10n?.distributorRetry ?? 'إعادة المحاولة'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textOnPrimary,
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
                            _buildDeliverySection(isDark, isMobile: isMobile),
                          ],
                        ),
                      ),
                      const SizedBox(width: AlhaiSpacing.lg),
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            _buildAppearanceSection(isDark, ref),
                            const SizedBox(height: AlhaiSpacing.lg),
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
                      _buildAppearanceSection(isDark, ref),
                      SizedBox(
                          height:
                              isMedium ? AlhaiSpacing.lg : AlhaiSpacing.md),
                      _buildCompanyInfoSection(isDark),
                      SizedBox(
                          height:
                              isMedium ? AlhaiSpacing.lg : AlhaiSpacing.md),
                      _buildNotificationsSection(isDark),
                      SizedBox(
                          height:
                              isMedium ? AlhaiSpacing.lg : AlhaiSpacing.md),
                      _buildDeliverySection(isDark, isMobile: isMobile),
                      const SizedBox(height: AlhaiSpacing.lg),
                      _buildSaveButton(isDark),
                      const SizedBox(height: AlhaiSpacing.xl),
                    ],
                  ),
          );
        },
      ),
    ),
        ),
      ),
    );
  }

  Future<bool> _showUnsavedDialog() async {
    final l10n = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.distributorUnsavedChanges ?? 'تغييرات غير محفوظة'),
        content: Text(
            l10n?.distributorUnsavedChangesMessage ?? 'لديك تغييرات غير محفوظة. هل تريد المغادرة بدون حفظ؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n?.distributorStay ?? 'البقاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.textOnPrimary,
            ),
            child: Text(l10n?.distributorLeave ?? 'مغادرة'),
          ),
        ],
      ),
    );
    return result ?? false;
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

  Widget _buildDeliverySection(bool isDark, {bool isMobile = false}) {
    return _sectionCard(
      icon: Icons.local_shipping_rounded,
      iconColor: AppColors.secondary,
      title: 'إعدادات التسليم',
      isDark: isDark,
      children: [
        _buildFieldWithHelp(
          label: 'مناطق التوصيل',
          helpText: 'أدخل أسماء المدن أو المناطق مفصولة بفاصلة. مثال: الرياض، جدة، الدمام',
          controller: _deliveryZonesController,
          icon: Icons.map_rounded,
          maxLines: 2,
          maxLength: 200,
          hintText: 'أدخل المدن مفصولة بفاصلة',
          isDark: isDark,
        ),
        const SizedBox(height: AlhaiSpacing.md),
        if (isMobile)
          ...[
            _buildFieldWithHelp(
              label: 'الحد الأدنى للطلب (ر.س)',
              helpText: 'أقل مبلغ مطلوب لقبول الطلب. الطلبات الأقل من هذا المبلغ لن تُقبل تلقائياً',
              controller: _minOrderController,
              icon: Icons.shopping_cart_rounded,
              keyboardType: TextInputType.number,
              isDark: isDark,
            ),
            const SizedBox(height: AlhaiSpacing.md),
            _buildFieldWithHelp(
              label: 'رسوم التوصيل (ر.س)',
              helpText: 'المبلغ الذي يُضاف على كل طلب كرسوم توصيل. يظهر للمتاجر عند تقديم الطلب',
              controller: _deliveryFeeController,
              icon: Icons.delivery_dining_rounded,
              keyboardType: TextInputType.number,
              isDark: isDark,
            ),
          ]
        else
          Row(
            children: [
              Expanded(
                child: _buildFieldWithHelp(
                  label: 'الحد الأدنى للطلب (ر.س)',
                  helpText: 'أقل مبلغ مطلوب لقبول الطلب. الطلبات الأقل من هذا المبلغ لن تُقبل تلقائياً',
                  controller: _minOrderController,
                  icon: Icons.shopping_cart_rounded,
                  keyboardType: TextInputType.number,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.md),
              Expanded(
                child: _buildFieldWithHelp(
                  label: 'رسوم التوصيل (ر.س)',
                  helpText: 'المبلغ الذي يُضاف على كل طلب كرسوم توصيل. يظهر للمتاجر عند تقديم الطلب',
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

  // ─── Appearance Section (Dark Mode Toggle) ─────────────────────

  Widget _buildAppearanceSection(bool isDark, WidgetRef ref) {
    final currentMode = ref.watch(themeModeProvider);

    return _sectionCard(
      icon: Icons.palette_rounded,
      iconColor: AppColors.purple,
      title: 'المظهر',
      isDark: isDark,
      children: [
        _themeTile(
          'تلقائي (حسب النظام)',
          Icons.brightness_auto_rounded,
          currentMode == ThemeMode.system,
          () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system),
          isDark,
        ),
        _themeTile(
          'الوضع الفاتح',
          Icons.light_mode_rounded,
          currentMode == ThemeMode.light,
          () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light),
          isDark,
        ),
        _themeTile(
          'الوضع الداكن',
          Icons.dark_mode_rounded,
          currentMode == ThemeMode.dark,
          () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark),
          isDark,
        ),
      ],
    );
  }

  Widget _themeTile(String label, IconData icon, bool isSelected,
      VoidCallback onTap, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xxs),
      child: InkWell(
        borderRadius: BorderRadius.circular(AlhaiRadius.sm),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              vertical: AlhaiSpacing.xs, horizontal: AlhaiSpacing.xs),
          child: Row(
            children: [
              Icon(icon,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.getTextMuted(isDark),
                  size: 20),
              const SizedBox(width: AlhaiSpacing.sm),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.getTextPrimary(isDark),
                  ),
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.primary, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Save Button ───────────────────────────────────────────────

  Widget _buildSaveButton(bool isDark) {
    return Semantics(
      button: true,
      label: 'Save settings (Ctrl+S)',
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: _isSaving ? null : _saveSettings,
        icon: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.textOnPrimary),
              )
            : const Icon(Icons.save_rounded, size: 20),
        label: const Text('حفظ الإعدادات',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.md),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AlhaiRadius.md)),
          ),
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
        borderRadius: BorderRadius.circular(AlhaiRadius.lg),
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
                  color: iconColor.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(AlhaiRadius.sm + 2),
                ),
                child: ExcludeSemantics(
                  child: Icon(icon, color: iconColor, size: 20),
                ),
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
    int? maxLength,
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
          maxLength: maxLength,
          onChanged: (_) => setState(() => _hasChanges = true),
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
              borderRadius: BorderRadius.circular(AlhaiRadius.md),
              borderSide: BorderSide(color: AppColors.getBorder(isDark)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AlhaiRadius.md),
              borderSide: BorderSide(color: AppColors.getBorder(isDark)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AlhaiRadius.md),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: AlhaiSpacing.md, vertical: AlhaiSpacing.sm),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldWithHelp({
    required String label,
    required String helpText,
    required TextEditingController controller,
    required IconData icon,
    required bool isDark,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    int? maxLength,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.getTextSecondary(isDark),
              ),
            ),
            const SizedBox(width: AlhaiSpacing.xxs),
            Tooltip(
              message: helpText,
              preferBelow: false,
              child: Semantics(
                label: 'Help: $helpText',
                child: Icon(
                  Icons.help_outline_rounded,
                  size: 16,
                  color: AppColors.getTextMuted(isDark),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AlhaiSpacing.xs),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          maxLength: maxLength,
          onChanged: (_) => setState(() => _hasChanges = true),
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
              borderRadius: BorderRadius.circular(AlhaiRadius.md),
              borderSide: BorderSide(color: AppColors.getBorder(isDark)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AlhaiRadius.md),
              borderSide: BorderSide(color: AppColors.getBorder(isDark)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AlhaiRadius.md),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: AlhaiSpacing.md, vertical: AlhaiSpacing.sm),
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
          ExcludeSemantics(
            child: Icon(icon, color: AppColors.getTextMuted(isDark), size: 20),
          ),
          const SizedBox(width: AlhaiSpacing.sm),
          Expanded(
            child: Semantics(
              toggled: value,
              label: label,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: (v) { onChanged(v); _hasChanges = true; },
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Future<void> _saveSettings() async {
    if (_orgId == null) return;

    // Client-side validation before saving
    final emailText = _emailController.text.trim();
    if (emailText.isNotEmpty) {
      final emailRegex = RegExp(r'^[\w\-\.+]+@([\w\-]+\.)+[\w\-]{2,}$');
      if (!emailRegex.hasMatch(emailText)) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.distributorInvalidEmail ?? 'يرجى إدخال بريد إلكتروني صحيح'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    final phoneText = _phoneController.text.trim();
    if (phoneText.isNotEmpty) {
      final phoneRegex = RegExp(r'^[\d\s\-\+\(\)]{7,20}$');
      if (!phoneRegex.hasMatch(phoneText)) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.distributorInvalidPhone ?? 'يرجى إدخال رقم هاتف صحيح'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

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

    try {
      final ds = ref.read(distributorDatasourceProvider);
      await ds.updateOrgSettings(updated);

      if (!mounted) return;
      setState(() => _isSaving = false);

      // Refresh the provider so next build picks up the saved data
      ref.invalidate(orgSettingsProvider);
      _hasChanges = false;

      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.distributorSettingsSaved ?? 'تم حفظ الإعدادات بنجاح'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);

      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.distributorSaveError ?? 'حدث خطأ أثناء حفظ الإعدادات'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
