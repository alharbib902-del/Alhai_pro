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

// مفاتيح إعدادات الإشعارات
const String _kNotifPushEnabled = 'notif_push_enabled';
const String _kNotifEmailEnabled = 'notif_email_enabled';
const String _kNotifSmsEnabled = 'notif_sms_enabled';
const String _kNotifSalesAlert = 'notif_sales_alert';
const String _kNotifLowStockAlert = 'notif_low_stock_alert';
const String _kNotifSecurityAlert = 'notif_security_alert';
const String _kNotifReportAlert = 'notif_report_alert';

/// شاشة إعدادات الإشعارات
class NotificationsSettingsScreen extends ConsumerStatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  ConsumerState<NotificationsSettingsScreen> createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends ConsumerState<NotificationsSettingsScreen> {

  bool _pushEnabled = true;
  bool _emailEnabled = false;
  bool _smsEnabled = false;
  bool _salesAlerts = true;
  bool _inventoryAlerts = true;
  bool _securityAlerts = true;
  bool _reportAlerts = false;
  bool _isLoading = true;

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
      final settings = await getSettingsByPrefix(db, storeId, 'notif_');

      if (mounted) {
        setState(() {
          _pushEnabled = settings[_kNotifPushEnabled] != 'false';
          _emailEnabled = settings[_kNotifEmailEnabled] == 'true';
          _smsEnabled = settings[_kNotifSmsEnabled] == 'true';
          _salesAlerts = settings[_kNotifSalesAlert] != 'false';
          _inventoryAlerts = settings[_kNotifLowStockAlert] != 'false';
          _securityAlerts = settings[_kNotifSecurityAlert] != 'false';
          _reportAlerts = settings[_kNotifReportAlert] == 'true';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// حفظ إعداد فردي في قاعدة البيانات مع المزامنة
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
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.settingsSaved),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      // الخطأ اختياري
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
            title: l10n.notificationSettings,
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

    return Column(children: [
          AppHeader(
            title: l10n.notificationSettings,
            onMenuTap: isWideScreen
                      ? null
                      : () => Scaffold.of(context).openDrawer(),
            onNotificationsTap: () => context.push('/notifications'),
            notificationsCount: 3, userName: l10n.defaultUserName, userRole: l10n.branchManager,
          ),
          Expanded(child: SingleChildScrollView(
            padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
            child: _buildContent(isDark, l10n),
          )),
        ]);
  }
  Widget _buildContent(bool isDark, AppLocalizations l10n) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Channels
      _buildGroup(l10n.notificationChannels, [
        _switchTile(Icons.notifications_active_rounded, l10n.pushNotifications,
            l10n.instantNotifications, _pushEnabled,
            (v) {
              setState(() => _pushEnabled = v);
              _saveSingleSetting(_kNotifPushEnabled, v.toString());
            }, isDark),
        _switchTile(Icons.email_rounded, l10n.emailNotifications,
            l10n.emailNotificationsDesc, _emailEnabled,
            (v) {
              setState(() => _emailEnabled = v);
              _saveSingleSetting(_kNotifEmailEnabled, v.toString());
            }, isDark),
        _switchTile(Icons.sms_rounded, l10n.smsNotifications,
            l10n.smsNotificationsDesc, _smsEnabled,
            (v) {
              setState(() => _smsEnabled = v);
              _saveSingleSetting(_kNotifSmsEnabled, v.toString());
            }, isDark),
      ], isDark),

      // Alert types
      _buildGroup(l10n.alertTypes, [
        _switchTile(Icons.receipt_long_rounded, l10n.salesAlerts,
            l10n.salesAlertsDesc, _salesAlerts,
            (v) {
              setState(() => _salesAlerts = v);
              _saveSingleSetting(_kNotifSalesAlert, v.toString());
            }, isDark),
        _switchTile(Icons.inventory_2_rounded, l10n.inventoryAlerts,
            l10n.inventoryAlertsDesc, _inventoryAlerts,
            (v) {
              setState(() => _inventoryAlerts = v);
              _saveSingleSetting(_kNotifLowStockAlert, v.toString());
            }, isDark),
        _switchTile(Icons.security_rounded, l10n.securityAlerts,
            l10n.securityAlertsDesc, _securityAlerts,
            (v) {
              setState(() => _securityAlerts = v);
              _saveSingleSetting(_kNotifSecurityAlert, v.toString());
            }, isDark),
        _switchTile(Icons.analytics_rounded, l10n.reportAlerts,
            l10n.reportAlertsDesc, _reportAlerts,
            (v) {
              setState(() => _reportAlerts = v);
              _saveSingleSetting(_kNotifReportAlert, v.toString());
            }, isDark),
      ], isDark),
    ]);
  }

  Widget _buildGroup(String title, List<Widget> children, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary))),
        ...children,
      ]),
    );
  }

  Widget _switchTile(IconData icon, String title, String subtitle, bool value,
      ValueChanged<bool> onChanged, bool isDark) {
    return SwitchListTile(
      secondary: Container(padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: value ? AppColors.primary : AppColors.textSecondary, size: 20)),
      title: Text(title, style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: TextStyle(
          color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textSecondary, fontSize: 12)),
      value: value, onChanged: onChanged,
    );
  }
}
