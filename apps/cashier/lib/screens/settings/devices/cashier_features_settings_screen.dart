/// Cashier Features Settings Screen - إعدادات الميزات
///
/// يتيح تفعيل/تعطيل الميزات الإضافية:
/// - شاشة العميل الثانية
/// - طلب رقم الجوال قبل الدفع
/// - الدفع اللاتلامسي NFC
/// - مهلة انتظار NFC
///
/// يحفظ الإعدادات في settings_table عبر قاعدة البيانات.
library;

import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_design_system/alhai_design_system.dart'
    show AlhaiBreakpoints, AlhaiSpacing;
import 'package:alhai_pos/alhai_pos.dart';

/// شاشة إعدادات الميزات والأجهزة
class CashierFeaturesSettingsScreen extends ConsumerStatefulWidget {
  const CashierFeaturesSettingsScreen({super.key});

  @override
  ConsumerState<CashierFeaturesSettingsScreen> createState() =>
      _CashierFeaturesSettingsScreenState();
}

class _CashierFeaturesSettingsScreenState
    extends ConsumerState<CashierFeaturesSettingsScreen> {
  final _db = GetIt.I<AppDatabase>();
  bool _isLoading = true;

  // حالة الإعدادات
  bool _enableCustomerDisplay = false;
  bool _enablePhoneCollection = true;
  bool _enableNfcPayment = false;
  int _nfcTimeoutSeconds = 30;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// تحميل الإعدادات من قاعدة البيانات
  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      final storeId = ref.read(currentStoreIdProvider)!;
      final settings = await (_db.select(
        _db.settingsTable,
      )..where((s) => s.storeId.equals(storeId))).get();

      final settingsMap = <String, String>{};
      for (final s in settings) {
        settingsMap[s.key] = s.value;
      }

      if (mounted) {
        setState(() {
          _enableCustomerDisplay =
              settingsMap['feature_customer_display'] == 'true';
          _enablePhoneCollection =
              settingsMap['feature_phone_collection'] != 'false';
          _enableNfcPayment = settingsMap['feature_nfc_payment'] == 'true';
          _nfcTimeoutSeconds =
              int.tryParse(settingsMap['nfc_timeout_seconds'] ?? '') ?? 30;
        });
      }
    } catch (e) {
      // استخدام القيم الافتراضية عند الخطأ — مع تسجيل الخطأ لتسهيل التتبع
      debugPrint(
        '[CashierFeaturesSettings] Failed to load settings, using defaults: $e',
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// حفظ إعداد واحد في قاعدة البيانات
  Future<void> _saveSetting(String key, String value) async {
    final storeId = ref.read(currentStoreIdProvider);
    if (storeId == null) return;

    await _db
        .into(_db.settingsTable)
        .insertOnConflictUpdate(
          SettingsTableCompanion.insert(
            id: '${storeId}_$key',
            storeId: storeId,
            key: key,
            value: value,
            updatedAt: DateTime.now(),
          ),
        );

    // تحديث مزود الإعدادات
    ref.invalidate(cashierFeatureSettingsProvider);
  }

  /// تبديل تفعيل شاشة العميل
  Future<void> _toggleCustomerDisplay(bool enabled) async {
    setState(() => _enableCustomerDisplay = enabled);
    await _saveSetting('feature_customer_display', enabled ? 'true' : 'false');
  }

  /// تبديل جمع رقم الجوال
  Future<void> _togglePhoneCollection(bool enabled) async {
    setState(() => _enablePhoneCollection = enabled);
    await _saveSetting('feature_phone_collection', enabled ? 'true' : 'false');
  }

  /// تبديل الدفع بـ NFC
  Future<void> _toggleNfcPayment(bool enabled) async {
    setState(() => _enableNfcPayment = enabled);
    await _saveSetting('feature_nfc_payment', enabled ? 'true' : 'false');
  }

  /// تحديث مهلة NFC
  Future<void> _updateNfcTimeout(double value) async {
    final seconds = value.round();
    setState(() => _nfcTimeoutSeconds = seconds);
    await _saveSetting('nfc_timeout_seconds', '$seconds');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width >= AlhaiBreakpoints.desktop;
    final isMediumScreen = size.width >= AlhaiBreakpoints.tablet;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        AppHeader(
          title: 'إعدادات الميزات',
          subtitle: 'شاشة العميل، NFC، ميزات متقدمة',
          showSearch: false,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: AppColors.getTextPrimary(isDark),
            ),
            onPressed: () => context.pop(),
            tooltip: l10n.back,
          ),
          onNotificationsTap: () => context.push(AppRoutes.notificationsCenter),
          userName: ref.watch(currentUserProvider)?.name ?? l10n.cashCustomer,
          userRole: l10n.cashier,
          onUserTap: () => context.push(AppRoutes.profile),
        ),
        Expanded(
          child: _isLoading
              ? const AppLoadingState()
              : SingleChildScrollView(
                  padding: EdgeInsets.all(
                    isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md,
                  ),
                  child: _buildContent(isWideScreen, isDark),
                ),
        ),
      ],
    );
  }

  Widget _buildContent(bool isWideScreen, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── شاشة العميل الثانية ──
        _buildSectionCard(
          isDark: isDark,
          icon: Icons.monitor_rounded,
          iconColor: AppColors.info,
          title: 'شاشة العميل',
          children: [
            SwitchListTile(
              title: Text(
                'تفعيل شاشة العميل الثانية',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
              subtitle: Text(
                'عرض تفاصيل الطلب والمبلغ للعميل على شاشة منفصلة',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.getTextMuted(isDark),
                ),
              ),
              value: _enableCustomerDisplay,
              onChanged: _toggleCustomerDisplay,
              activeThumbColor: AppColors.primary,
            ),
            if (_enableCustomerDisplay) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(AlhaiSpacing.md),
                child: FilledButton.icon(
                  onPressed: () {
                    if (kIsWeb) {
                      // Open in a new browser window for second monitor
                      openCustomerDisplayWindow('/#/customer-display');
                    } else {
                      // On non-web, navigate within the app
                      context.push('/customer-display');
                    }
                  },
                  icon: Icon(
                    kIsWeb ? Icons.open_in_new_rounded : Icons.monitor_rounded,
                    size: 18,
                  ),
                  label: Text(
                    kIsWeb ? 'فتح في نافذة جديدة' : 'فتح شاشة العميل',
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.info,
                    foregroundColor: AppColors.textOnPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AlhaiSpacing.md,
                      vertical: AlhaiSpacing.xs,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AlhaiSpacing.md),

        // ── جمع رقم الجوال ──
        _buildSectionCard(
          isDark: isDark,
          icon: Icons.phone_android_rounded,
          iconColor: AppColors.success,
          title: 'رقم الجوال',
          children: [
            SwitchListTile(
              title: Text(
                'طلب رقم الجوال قبل الدفع',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
              subtitle: Text(
                'يطلب من الكاشير إدخال رقم جوال العميل لإرسال الفاتورة',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.getTextMuted(isDark),
                ),
              ),
              value: _enablePhoneCollection,
              onChanged: _togglePhoneCollection,
              activeThumbColor: AppColors.primary,
            ),
          ],
        ),
        const SizedBox(height: AlhaiSpacing.md),

        // ── الدفع بـ NFC ──
        _buildSectionCard(
          isDark: isDark,
          icon: Icons.contactless_rounded,
          iconColor: AppColors.warning,
          title: 'الدفع اللاتلامسي NFC',
          children: [
            SwitchListTile(
              title: Text(
                'تفعيل الدفع اللاتلامسي NFC',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
              subtitle: Text(
                'استقبال المدفوعات عبر البطاقات اللاتلامسية والأجهزة المحمولة',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.getTextMuted(isDark),
                ),
              ),
              value: _enableNfcPayment,
              onChanged: _toggleNfcPayment,
              activeThumbColor: AppColors.primary,
            ),
            if (_enableNfcPayment) ...[
              const Divider(height: 1),
              // حالة أجهزة NFC
              Consumer(
                builder: (context, ref, _) {
                  final capability = ref.watch(nfcCapabilityProvider);
                  return capability.when(
                    data: (cap) => ListTile(
                      leading: Icon(
                        cap.isReady ? Icons.check_circle : Icons.warning,
                        color: cap.isReady
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                      title: Text(
                        cap.isReady ? 'NFC جاهز للاستخدام' : 'NFC غير متاح',
                      ),
                      subtitle: cap.unavailableReason != null
                          ? Text(cap.unavailableReason!)
                          : null,
                      dense: true,
                    ),
                    loading: () => const ListTile(
                      leading: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      title: Text('جاري فحص NFC...'),
                      dense: true,
                    ),
                    error: (_, __) => const ListTile(
                      leading: Icon(Icons.error, color: Colors.red),
                      title: Text('فشل فحص NFC'),
                      dense: true,
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AlhaiSpacing.md,
                  vertical: AlhaiSpacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'مهلة انتظار NFC',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.getTextPrimary(isDark),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AlhaiSpacing.sm,
                            vertical: AlhaiSpacing.xxs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(
                              alpha: isDark ? 0.2 : 0.1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$_nfcTimeoutSeconds ثانية',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AlhaiSpacing.xs),
                    Slider(
                      value: _nfcTimeoutSeconds.toDouble(),
                      min: 5,
                      max: 60,
                      divisions: 11,
                      activeColor: AppColors.warning,
                      label: '$_nfcTimeoutSeconds ثانية',
                      onChanged: (value) =>
                          setState(() => _nfcTimeoutSeconds = value.round()),
                      onChangeEnd: _updateNfcTimeout,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '5 ثوانٍ',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.getTextMuted(isDark),
                          ),
                        ),
                        Text(
                          '60 ثانية',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.getTextMuted(isDark),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  /// بناء بطاقة قسم بأيقونة وعنوان
  Widget _buildSectionCard({
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // عنوان القسم
          Padding(
            padding: const EdgeInsets.all(AlhaiSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
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
          ),
          const Divider(height: 1),
          // محتوى القسم
          ...children,
        ],
      ),
    );
  }
}
