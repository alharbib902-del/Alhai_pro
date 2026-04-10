/// شاشة إعدادات أجهزة الدفع - Payment Devices Settings Screen
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_core/alhai_core.dart';
import '../../../providers/settings_db_providers.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

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
      // الخطأ اختياري
    }
  }

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
        final l10n = AppLocalizations.of(context);
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
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.errorSaving}: $e'),
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
    final l10n = AppLocalizations.of(context);

    if (_isLoading) {
      return SafeArea(
          child: Column(
        children: [
          AppHeader(
            title: l10n.paymentDevicesSettings,
            onMenuTap:
                isWideScreen ? null : () => Scaffold.of(context).openDrawer(),
            onNotificationsTap: () => context.push('/notifications'),
            notificationsCount: 3,
            userName: l10n.defaultUserName,
            userRole: l10n.branchManager,
          ),
          const Expanded(
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      ));
    }

    return SafeArea(
        child: Column(
      children: [
        AppHeader(
          title: l10n.paymentDevicesSettings,
          onMenuTap:
              isWideScreen ? null : () => Scaffold.of(context).openDrawer(),
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
    ));
  }

  Widget _buildContent(bool isDark, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPageHeader(isDark, l10n),
        const SizedBox(height: AlhaiSpacing.mdl),
        _buildSettingsGroup(l10n.supportedPaymentMethods, Icons.payment_rounded,
            const Color(0xFF06B6D4), isDark, [
          SwitchListTile(
            title: Text('mada',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onSurface)),
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
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onSurface)),
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
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onSurface)),
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
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onSurface)),
            secondary: const Icon(Icons.apple),
            value: _enableApplePay,
            onChanged: (v) {
              setState(() => _enableApplePay = v);
              _saveSingleSetting(_kEnableApplePay, v.toString());
            },
          ),
          const SizedBox(height: AlhaiSpacing.xs),
        ]),
        _buildSettingsGroup(l10n.paymentTerminal, Icons.contactless_rounded,
            AppColors.primary, isDark, [
          RadioGroup<String>(
            groupValue: _terminalType,
            onChanged: (v) {
              setState(() => _terminalType = v!);
              _saveSingleSetting(_kTerminalType, v!);
            },
            child: Column(
              children: [
                RadioListTile<String>(
                  title: Text('Ingenico',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface)),
                  subtitle: Text(l10n.ingenicoDevices),
                  value: 'ingenico',
                ),
                RadioListTile<String>(
                  title: Text('Verifone',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface)),
                  subtitle: Text(l10n.verifoneDevices),
                  value: 'verifone',
                ),
                RadioListTile<String>(
                  title: Text('PAX',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface)),
                  subtitle: Text(l10n.paxDevices),
                  value: 'pax',
                ),
              ],
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xs),
        ]),
        _buildSettingsGroup(l10n.settlement, Icons.account_balance_rounded,
            AppColors.success, isDark, [
          SwitchListTile(
            title: Text(l10n.autoSettlement,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onSurface)),
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
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onSurface)),
            subtitle: Text(l10n.executeSettlementNow),
            trailing: const AdaptiveIcon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.settlingInProgress)),
              );
            },
          ),
          const SizedBox(height: AlhaiSpacing.xs),
        ]),
        const SizedBox(height: AlhaiSpacing.md),
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
            label: Text(_isSaving
                ? '\u062C\u0627\u0631\u064A \u0627\u0644\u062D\u0641\u0638...'
                : l10n.saveSettings),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.md),
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
          icon: Icon(
            Directionality.of(context) == TextDirection.rtl
                ? Icons.arrow_forward_rounded
                : Icons.arrow_back_rounded,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          tooltip: l10n.back,
        ),
        const SizedBox(width: AlhaiSpacing.xs),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF06B6D4).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.payment_rounded,
              color: Color(0xFF06B6D4), size: 24),
        ),
        const SizedBox(width: AlhaiSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.paymentDevicesSettings,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface)),
            Text(l10n.paymentDevicesSubtitle,
                style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingsGroup(String title, IconData icon, Color color,
      bool isDark, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(AlhaiSpacing.mdl,
                AlhaiSpacing.md, AlhaiSpacing.mdl, AlhaiSpacing.xs),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AlhaiSpacing.xs),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: AlhaiSpacing.sm),
                Text(title,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface)),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}
