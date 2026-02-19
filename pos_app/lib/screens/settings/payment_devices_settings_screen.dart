/// شاشة إعدادات أجهزة الدفع - Payment Devices Settings Screen
///
/// شاشة لإدارة أجهزة الدفع المتصلة
library;

import 'package:pos_app/widgets/common/adaptive_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../data/local/app_database.dart';
import '../../di/injection.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/products_providers.dart';
import '../../providers/settings_db_providers.dart';
import '../../widgets/layout/app_header.dart';

// مفاتيح إعدادات أجهزة الدفع
const String _kEnableMada = 'payment_enable_mada';
const String _kEnableVisa = 'payment_enable_visa';
const String _kEnableStcPay = 'payment_enable_stc_pay';
const String _kEnableApplePay = 'payment_enable_apple_pay';
const String _kTerminalType = 'payment_terminal_type';
const String _kAutoSettle = 'payment_auto_settle';

/// شاشة إعدادات أجهزة الدفع
class PaymentDevicesSettingsScreen extends ConsumerStatefulWidget {
  const PaymentDevicesSettingsScreen({super.key});

  @override
  ConsumerState<PaymentDevicesSettingsScreen> createState() =>
      _PaymentDevicesSettingsScreenState();
}

class _PaymentDevicesSettingsScreenState
    extends ConsumerState<PaymentDevicesSettingsScreen> {
  bool _enableMada = true;
  bool _enableVisa = true;
  bool _enableStcPay = false;
  bool _enableApplePay = false;
  String _terminalType = 'ingenico';
  bool _autoSettle = true;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// تحميل الإعدادات من قاعدة البيانات
  Future<void> _loadSettings() async {
    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final db = getIt<AppDatabase>();
      final settings = await getSettingsByPrefix(db, storeId, 'payment_');

      if (mounted) {
        setState(() {
          _enableMada = settings[_kEnableMada] != 'false';
          _enableVisa = settings[_kEnableVisa] != 'false';
          _enableStcPay = settings[_kEnableStcPay] == 'true';
          _enableApplePay = settings[_kEnableApplePay] == 'true';
          _terminalType = settings[_kTerminalType] ?? 'ingenico';
          _autoSettle = settings[_kAutoSettle] != 'false';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// حفظ إعداد واحد في قاعدة البيانات مع المزامنة
  Future<void> _saveSingleSetting(String key, String value) async {
    final storeId = ref.read(currentStoreIdProvider);
    if (storeId == null) return;

    final db = getIt<AppDatabase>();
    try {
      await saveSettingWithSync(
        db: db,
        storeId: storeId,
        key: key,
        value: value,
        ref: ref,
      );
    } catch (e) {
      // الخطأ اختياري - لا نوقف التفاعل بسببه
    }
  }

  /// حفظ جميع الإعدادات دفعة واحدة
  Future<void> _saveAllSettings() async {
    setState(() => _isSaving = true);
    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;

      final db = getIt<AppDatabase>();

      await saveSettingsBatch(
        db: db,
        storeId: storeId,
        settings: {
          _kEnableMada: _enableMada.toString(),
          _kEnableVisa: _enableVisa.toString(),
          _kEnableStcPay: _enableStcPay.toString(),
          _kEnableApplePay: _enableApplePay.toString(),
          _kTerminalType: _terminalType,
          _kAutoSettle: _autoSettle.toString(),
        },
        ref: ref,
      );

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.paymentDevicesSettingsSaved),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في الحفظ: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isMediumScreen = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Column(
        children: [
          AppHeader(
            title: l10n.paymentDevicesSettings,
            onMenuTap: isWideScreen
                ? null
                : () => Scaffold.of(context).openDrawer(),
            onNotificationsTap: () => context.push('/notifications'),
            notificationsCount: 3,
            userName: l10n.defaultUserName,
            userRole: l10n.branchManager,
          ),
          const Expanded(
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      );
    }

    return Column(
      children: [
        AppHeader(
          title: l10n.paymentDevicesSettings,
          onMenuTap: isWideScreen
              ? null
              : () => Scaffold.of(context).openDrawer(),
          onNotificationsTap: () => context.push('/notifications'),
          notificationsCount: 3,
          userName: l10n.defaultUserName,
          userRole: l10n.branchManager,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
            child: _buildContent(isDark, l10n),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(bool isDark, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPageHeader(isDark, l10n),
        const SizedBox(height: 20),

        // Payment methods
        _buildSettingsGroup(l10n.supportedPaymentMethods, Icons.payment_rounded,
            const Color(0xFF06B6D4), isDark, [
          SwitchListTile(
            title: Text('mada',
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            subtitle: Text(l10n.madaLocalCards),
            secondary: const Icon(Icons.credit_card),
            value: _enableMada,
            onChanged: (v) {
              setState(() => _enableMada = v);
              _saveSingleSetting(_kEnableMada, v.toString());
            },
          ),
          SwitchListTile(
            title: Text('Visa / Mastercard',
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            subtitle: Text(l10n.internationalCards),
            secondary: const Icon(Icons.credit_card),
            value: _enableVisa,
            onChanged: (v) {
              setState(() => _enableVisa = v);
              _saveSingleSetting(_kEnableVisa, v.toString());
            },
          ),
          const Divider(indent: 16, endIndent: 16),
          SwitchListTile(
            title: Text('STC Pay',
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            subtitle: Text(l10n.stcDigitalWallet),
            secondary: const Icon(Icons.phone_android),
            value: _enableStcPay,
            onChanged: (v) {
              setState(() => _enableStcPay = v);
              _saveSingleSetting(_kEnableStcPay, v.toString());
            },
          ),
          SwitchListTile(
            title: Text('Apple Pay',
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            secondary: const Icon(Icons.apple),
            value: _enableApplePay,
            onChanged: (v) {
              setState(() => _enableApplePay = v);
              _saveSingleSetting(_kEnableApplePay, v.toString());
            },
          ),
          const SizedBox(height: 8),
        ]),

        // Terminal
        _buildSettingsGroup(l10n.paymentTerminal, Icons.contactless_rounded,
            AppColors.primary, isDark, [
          RadioListTile<String>(
            title: Text('Ingenico',
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            subtitle: Text(l10n.ingenicoDevices),
            value: 'ingenico',
            // ignore: deprecated_member_use
            groupValue: _terminalType,
            // ignore: deprecated_member_use
            onChanged: (v) {
              setState(() => _terminalType = v!);
              _saveSingleSetting(_kTerminalType, v!);
            },
          ),
          RadioListTile<String>(
            title: Text('Verifone',
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            subtitle: Text(l10n.verifoneDevices),
            value: 'verifone',
            // ignore: deprecated_member_use
            groupValue: _terminalType,
            // ignore: deprecated_member_use
            onChanged: (v) {
              setState(() => _terminalType = v!);
              _saveSingleSetting(_kTerminalType, v!);
            },
          ),
          RadioListTile<String>(
            title: Text('PAX',
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            subtitle: Text(l10n.paxDevices),
            value: 'pax',
            // ignore: deprecated_member_use
            groupValue: _terminalType,
            // ignore: deprecated_member_use
            onChanged: (v) {
              setState(() => _terminalType = v!);
              _saveSingleSetting(_kTerminalType, v!);
            },
          ),
          const SizedBox(height: 8),
        ]),

        // Settlement
        _buildSettingsGroup(l10n.settlement, Icons.account_balance_rounded,
            AppColors.success, isDark, [
          SwitchListTile(
            title: Text(l10n.autoSettlement,
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            subtitle: Text(l10n.autoSettlementDesc),
            value: _autoSettle,
            onChanged: (v) {
              setState(() => _autoSettle = v);
              _saveSingleSetting(_kAutoSettle, v.toString());
            },
          ),
          ListTile(
            leading: const Icon(Icons.sync, color: AppColors.info),
            title: Text(l10n.manualSettlement,
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            subtitle: Text(l10n.executeSettlementNow),
            trailing: const AdaptiveIcon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.settlingInProgress)),
              );
            },
          ),
          const SizedBox(height: 8),
        ]),

        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _isSaving ? null : _saveAllSettings,
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save_rounded),
            label: Text(_isSaving ? 'جاري الحفظ...' : l10n.saveSettings),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPageHeader(bool isDark, AppLocalizations l10n) {
    return Row(
      children: [
        IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back_rounded,
              color: isDark ? Colors.white : AppColors.textPrimary),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF06B6D4).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.payment_rounded,
              color: Color(0xFF06B6D4), size: 24),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.paymentDevicesSettings,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            Text(l10n.paymentDevicesSubtitle,
                style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.5)
                        : AppColors.textSecondary)),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingsGroup(String title, IconData icon, Color color,
      bool isDark, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(title,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color:
                            isDark ? Colors.white : AppColors.textPrimary)),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}
