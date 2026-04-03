import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_core/alhai_core.dart';
import '../../providers/settings_db_providers.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

// مفاتيح إعدادات الخصومات
const String _kDiscountEnabled = 'discount_enabled';
const String _kDiscountAllowManual = 'discount_allow_manual';
const String _kDiscountMaxPercent = 'discount_max_percent';
const String _kDiscountRequireApproval = 'discount_require_approval';
const String _kDiscountVipEnabled = 'discount_vip_enabled';
const String _kDiscountVipRate = 'discount_vip_rate';
const String _kDiscountVolumeEnabled = 'discount_volume_enabled';
const String _kDiscountCouponsEnabled = 'discount_coupons_enabled';

/// شاشة إعدادات الخصومات
class DiscountsSettingsScreen extends ConsumerStatefulWidget {
  const DiscountsSettingsScreen({super.key});

  @override
  ConsumerState<DiscountsSettingsScreen> createState() =>
      _DiscountsSettingsScreenState();
}

class _DiscountsSettingsScreenState
    extends ConsumerState<DiscountsSettingsScreen> {
  bool _enableDiscounts = true;
  bool _allowManualDiscount = true;
  double _maxDiscountPercent = 50.0;
  bool _requireApproval = false;
  bool _enableVipDiscount = true;
  double _vipDiscountRate = 10.0;
  bool _enableVolumeDiscount = false;
  bool _enableCoupons = true;
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
      final settings = await getSettingsByPrefix(db, storeId, 'discount_');

      if (mounted) {
        setState(() {
          _enableDiscounts = settings[_kDiscountEnabled] != 'false';
          _allowManualDiscount = settings[_kDiscountAllowManual] != 'false';
          _maxDiscountPercent = double.tryParse(settings[_kDiscountMaxPercent] ?? '') ?? 50.0;
          _requireApproval = settings[_kDiscountRequireApproval] == 'true';
          _enableVipDiscount = settings[_kDiscountVipEnabled] != 'false';
          _vipDiscountRate = double.tryParse(settings[_kDiscountVipRate] ?? '') ?? 10.0;
          _enableVolumeDiscount = settings[_kDiscountVolumeEnabled] == 'true';
          _enableCoupons = settings[_kDiscountCouponsEnabled] != 'false';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;

      final db = getIt<AppDatabase>();

      await saveSettingsBatch(
        db: db,
        storeId: storeId,
        settings: {
          _kDiscountEnabled: _enableDiscounts.toString(),
          _kDiscountAllowManual: _allowManualDiscount.toString(),
          _kDiscountMaxPercent: _maxDiscountPercent.toString(),
          _kDiscountRequireApproval: _requireApproval.toString(),
          _kDiscountVipEnabled: _enableVipDiscount.toString(),
          _kDiscountVipRate: _vipDiscountRate.toString(),
          _kDiscountVolumeEnabled: _enableVolumeDiscount.toString(),
          _kDiscountCouponsEnabled: _enableCoupons.toString(),
        },
        ref: ref,
      );

      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.discountSettingsSaved),
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
      return Column(
        children: [
          AppHeader(
            title: l10n.discountSettingsTitle,
            onMenuTap: isWideScreen ? null : () => Scaffold.of(context).openDrawer(),
            onNotificationsTap: () => context.push('/notifications'),
            notificationsCount: 3,
            userName: l10n.defaultUserName,
            userRole: l10n.branchManager,
          ),
          const Expanded(child: Center(child: CircularProgressIndicator())),
        ],
      );
    }

    return Column(
      children: [
        AppHeader(
          title: l10n.discountSettingsTitle,
          onMenuTap: isWideScreen ? null : () => Scaffold.of(context).openDrawer(),
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
        const SizedBox(height: AlhaiSpacing.mdl),

        _buildSettingsGroup(l10n.generalDiscounts, Icons.local_offer_rounded,
            const Color(0xFFEF4444), isDark, [
          SwitchListTile(
            title: Text(l10n.enableDiscountsOption, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
            subtitle: Text(l10n.enableDiscountsDesc),
            value: _enableDiscounts,
            onChanged: (v) => setState(() => _enableDiscounts = v),
          ),
          if (_enableDiscounts) ...[
            const Divider(indent: 16, endIndent: 16),
            SwitchListTile(
              title: Text(l10n.manualDiscount, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
              subtitle: Text(l10n.manualDiscountDesc),
              value: _allowManualDiscount,
              onChanged: (v) => setState(() => _allowManualDiscount = v),
            ),
            if (_allowManualDiscount) ...[
              ListTile(
                title: Text(l10n.maxDiscountLimit, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                subtitle: Text('${_maxDiscountPercent.toInt()}%'),
                trailing: SizedBox(
                  width: 200,
                  child: Slider(value: _maxDiscountPercent, min: 5, max: 100, divisions: 19, label: '${_maxDiscountPercent.toInt()}%',
                      onChanged: (v) => setState(() => _maxDiscountPercent = v)),
                ),
              ),
              SwitchListTile(
                title: Text(l10n.requireApproval, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                subtitle: Text(l10n.requireApprovalDesc),
                value: _requireApproval,
                onChanged: (v) => setState(() => _requireApproval = v),
              ),
            ],
          ],
          const SizedBox(height: AlhaiSpacing.xs),
        ]),

        _buildSettingsGroup(l10n.vipCustomerDiscount, Icons.star_rounded,
            const Color(0xFFF59E0B), isDark, [
          SwitchListTile(
            title: Text(l10n.vipDiscount, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
            subtitle: Text(l10n.vipDiscountDesc),
            value: _enableVipDiscount,
            onChanged: (v) => setState(() => _enableVipDiscount = v),
          ),
          if (_enableVipDiscount)
            ListTile(
              title: Text(l10n.vipDiscountRate, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
              subtitle: Text('${_vipDiscountRate.toInt()}%'),
              trailing: SizedBox(
                width: 200,
                child: Slider(value: _vipDiscountRate, min: 5, max: 30, divisions: 5, label: '${_vipDiscountRate.toInt()}%',
                    onChanged: (v) => setState(() => _vipDiscountRate = v)),
              ),
            ),
          const SizedBox(height: AlhaiSpacing.xs),
        ]),

        _buildSettingsGroup(l10n.otherDiscounts, Icons.sell_rounded,
            AppColors.info, isDark, [
          SwitchListTile(
            title: Text(l10n.volumeDiscount, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
            subtitle: Text(l10n.volumeDiscountDesc),
            value: _enableVolumeDiscount,
            onChanged: (v) => setState(() => _enableVolumeDiscount = v),
          ),
          const Divider(indent: 16, endIndent: 16),
          SwitchListTile(
            title: Text(l10n.couponsOption, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
            subtitle: Text(l10n.couponsDesc),
            value: _enableCoupons,
            onChanged: (v) => setState(() => _enableCoupons = v),
          ),
          const SizedBox(height: AlhaiSpacing.xs),
        ]),

        const SizedBox(height: AlhaiSpacing.md),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _isSaving ? null : _saveSettings,
            icon: _isSaving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.save_rounded),
            label: Text(l10n.saveSettings),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.md),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPageHeader(bool isDark, AppLocalizations l10n) {
    return Row(children: [
      IconButton(onPressed: () => context.pop(), icon: Icon(Icons.arrow_back_rounded, color: Theme.of(context).colorScheme.onSurface)),
      const SizedBox(width: AlhaiSpacing.xs),
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: const Color(0xFFEF4444).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.local_offer_rounded, color: Color(0xFFEF4444), size: 24),
      ),
      const SizedBox(width: AlhaiSpacing.sm),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l10n.discountSettingsTitle, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
        Text(l10n.discountSettingsSubtitle, style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ]),
    ]);
  }

  Widget _buildSettingsGroup(String title, IconData icon, Color color, bool isDark, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(AlhaiSpacing.mdl, AlhaiSpacing.md, AlhaiSpacing.mdl, AlhaiSpacing.xs),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(AlhaiSpacing.xs),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: AlhaiSpacing.sm),
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
          ]),
        ),
        ...children,
      ]),
    );
  }
}
