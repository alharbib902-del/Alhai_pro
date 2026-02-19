import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/layout/app_header.dart';

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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isMediumScreen = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

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
        const SizedBox(height: 20),

        // General discounts
        _buildSettingsGroup(
            l10n.generalDiscounts, Icons.local_offer_rounded,
            const Color(0xFFEF4444), isDark, [
          SwitchListTile(
            title: Text(l10n.enableDiscountsOption,
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            subtitle: Text(l10n.enableDiscountsDesc),
            value: _enableDiscounts,
            onChanged: (v) => setState(() => _enableDiscounts = v),
          ),
          if (_enableDiscounts) ...[
            const Divider(indent: 16, endIndent: 16),
            SwitchListTile(
              title: Text(l10n.manualDiscount,
                  style: TextStyle(
                      color: isDark ? Colors.white : AppColors.textPrimary)),
              subtitle: Text(l10n.manualDiscountDesc),
              value: _allowManualDiscount,
              onChanged: (v) => setState(() => _allowManualDiscount = v),
            ),
            if (_allowManualDiscount) ...[
              ListTile(
                title: Text(l10n.maxDiscountLimit,
                    style: TextStyle(
                        color:
                            isDark ? Colors.white : AppColors.textPrimary)),
                subtitle: Text('${_maxDiscountPercent.toInt()}%'),
                trailing: SizedBox(
                  width: 200,
                  child: Slider(
                    value: _maxDiscountPercent,
                    min: 5,
                    max: 100,
                    divisions: 19,
                    label: '${_maxDiscountPercent.toInt()}%',
                    onChanged: (v) =>
                        setState(() => _maxDiscountPercent = v),
                  ),
                ),
              ),
              SwitchListTile(
                title: Text(l10n.requireApproval,
                    style: TextStyle(
                        color:
                            isDark ? Colors.white : AppColors.textPrimary)),
                subtitle: Text(l10n.requireApprovalDesc),
                value: _requireApproval,
                onChanged: (v) => setState(() => _requireApproval = v),
              ),
            ],
          ],
          const SizedBox(height: 8),
        ]),

        // VIP discount
        _buildSettingsGroup(l10n.vipCustomerDiscount, Icons.star_rounded,
            const Color(0xFFF59E0B), isDark, [
          SwitchListTile(
            title: Text(l10n.vipDiscount,
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            subtitle: Text(l10n.vipDiscountDesc),
            value: _enableVipDiscount,
            onChanged: (v) => setState(() => _enableVipDiscount = v),
          ),
          if (_enableVipDiscount)
            ListTile(
              title: Text(l10n.vipDiscountRate,
                  style: TextStyle(
                      color: isDark ? Colors.white : AppColors.textPrimary)),
              subtitle: Text('${_vipDiscountRate.toInt()}%'),
              trailing: SizedBox(
                width: 200,
                child: Slider(
                  value: _vipDiscountRate,
                  min: 5,
                  max: 30,
                  divisions: 5,
                  label: '${_vipDiscountRate.toInt()}%',
                  onChanged: (v) => setState(() => _vipDiscountRate = v),
                ),
              ),
            ),
          const SizedBox(height: 8),
        ]),

        // Other discounts
        _buildSettingsGroup(l10n.otherDiscounts, Icons.sell_rounded,
            AppColors.info, isDark, [
          SwitchListTile(
            title: Text(l10n.volumeDiscount,
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            subtitle:
                Text(l10n.volumeDiscountDesc),
            value: _enableVolumeDiscount,
            onChanged: (v) => setState(() => _enableVolumeDiscount = v),
          ),
          const Divider(indent: 16, endIndent: 16),
          SwitchListTile(
            title: Text(l10n.couponsOption,
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            subtitle: Text(l10n.couponsDesc),
            value: _enableCoupons,
            onChanged: (v) => setState(() => _enableCoupons = v),
          ),
          const SizedBox(height: 8),
        ]),

        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.discountSettingsSaved),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.save_rounded),
            label: Text(l10n.saveSettings),
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
            color: const Color(0xFFEF4444).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.local_offer_rounded,
              color: Color(0xFFEF4444), size: 24),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.discountSettingsTitle,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            Text(l10n.discountSettingsSubtitle,
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
