import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/layout/app_sidebar.dart';
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
  bool _sidebarCollapsed = false;
  String _selectedNavId = 'settings';

  bool _enableDiscounts = true;
  bool _allowManualDiscount = true;
  double _maxDiscountPercent = 50.0;
  bool _requireApproval = false;
  bool _enableVipDiscount = true;
  double _vipDiscountRate = 10.0;
  bool _enableVolumeDiscount = false;
  bool _enableCoupons = true;

  void _handleNavigation(AppSidebarItem item) {
    setState(() => _selectedNavId = item.id);
    switch (item.id) {
      case 'dashboard':
        context.go(AppRoutes.dashboard);
        break;
      case 'pos':
        context.go(AppRoutes.pos);
        break;
      case 'products':
        context.push(AppRoutes.products);
        break;
      case 'categories':
        context.push(AppRoutes.categories);
        break;
      case 'inventory':
        context.push(AppRoutes.inventory);
        break;
      case 'customers':
        context.push(AppRoutes.customers);
        break;
      case 'invoices':
        context.push(AppRoutes.invoices);
        break;
      case 'orders':
        context.push(AppRoutes.orders);
        break;
      case 'sales':
        context.push(AppRoutes.invoices);
        break;
      case 'returns':
        context.push(AppRoutes.returns);
        break;
      case 'reports':
        context.push(AppRoutes.reports);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isMediumScreen = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : AppColors.backgroundSecondary,
      drawer: isWideScreen ? null : _buildDrawer(l10n),
      body: Row(
        children: [
          if (isWideScreen)
            AppSidebar(
              storeName: l10n.brandName,
              groups: DefaultSidebarItems.getGroups(context),
              selectedId: _selectedNavId,
              onItemTap: _handleNavigation,
              onSettingsTap: () => context.push(AppRoutes.settings),
              onSupportTap: () {},
              onLogoutTap: () => context.go('/login'),
              collapsed: _sidebarCollapsed,
              userName: 'أحمد محمد',
              userRole: l10n.branchManager,
              onUserTap: () {},
            ),
          Expanded(
            child: Column(
              children: [
                AppHeader(
                  title: 'إعدادات الخصومات',
                  onMenuTap: isWideScreen
                      ? () => setState(
                          () => _sidebarCollapsed = !_sidebarCollapsed)
                      : () => Scaffold.of(context).openDrawer(),
                  onNotificationsTap: () => context.push('/notifications'),
                  notificationsCount: 3,
                  userName: 'أحمد محمد',
                  userRole: l10n.branchManager,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
                    child: _buildContent(isDark),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(AppLocalizations l10n) {
    return Drawer(
      child: AppSidebar(
        storeName: l10n.brandName,
        groups: DefaultSidebarItems.getGroups(context),
        selectedId: _selectedNavId,
        onItemTap: (item) {
          Navigator.pop(context);
          _handleNavigation(item);
        },
        onSettingsTap: () {
          Navigator.pop(context);
          context.push(AppRoutes.settings);
        },
        onSupportTap: () => Navigator.pop(context),
        onLogoutTap: () {
          Navigator.pop(context);
          context.go('/login');
        },
        userName: 'أحمد محمد',
        userRole: l10n.branchManager,
        onUserTap: () {},
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPageHeader(isDark),
        const SizedBox(height: 20),

        // General discounts
        _buildSettingsGroup(
            'الخصومات العامة', Icons.local_offer_rounded,
            const Color(0xFFEF4444), isDark, [
          SwitchListTile(
            title: Text('تفعيل الخصومات',
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            subtitle: const Text('السماح بتطبيق الخصومات'),
            value: _enableDiscounts,
            onChanged: (v) => setState(() => _enableDiscounts = v),
          ),
          if (_enableDiscounts) ...[
            const Divider(indent: 16, endIndent: 16),
            SwitchListTile(
              title: Text('الخصم اليدوي',
                  style: TextStyle(
                      color: isDark ? Colors.white : AppColors.textPrimary)),
              subtitle: const Text('السماح للكاشير بإدخال خصم يدوي'),
              value: _allowManualDiscount,
              onChanged: (v) => setState(() => _allowManualDiscount = v),
            ),
            if (_allowManualDiscount) ...[
              ListTile(
                title: Text('الحد الأقصى للخصم',
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
                title: Text('اشتراط الموافقة',
                    style: TextStyle(
                        color:
                            isDark ? Colors.white : AppColors.textPrimary)),
                subtitle: const Text('طلب موافقة المدير للخصم'),
                value: _requireApproval,
                onChanged: (v) => setState(() => _requireApproval = v),
              ),
            ],
          ],
          const SizedBox(height: 8),
        ]),

        // VIP discount
        _buildSettingsGroup('خصم العملاء المميزين', Icons.star_rounded,
            const Color(0xFFF59E0B), isDark, [
          SwitchListTile(
            title: Text('خصم VIP',
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            subtitle: const Text('خصم تلقائي للعملاء المميزين'),
            value: _enableVipDiscount,
            onChanged: (v) => setState(() => _enableVipDiscount = v),
          ),
          if (_enableVipDiscount)
            ListTile(
              title: Text('نسبة خصم VIP',
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
        _buildSettingsGroup('خصومات أخرى', Icons.sell_rounded,
            AppColors.info, isDark, [
          SwitchListTile(
            title: Text('خصم الكمية',
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            subtitle:
                const Text('خصم تلقائي عند شراء كمية معينة'),
            value: _enableVolumeDiscount,
            onChanged: (v) => setState(() => _enableVolumeDiscount = v),
          ),
          const Divider(indent: 16, endIndent: 16),
          SwitchListTile(
            title: Text('الكوبونات',
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            subtitle: const Text('دعم كوبونات الخصم'),
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
                const SnackBar(
                  content: Text('تم حفظ إعدادات الخصومات'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.save_rounded),
            label: const Text('حفظ الإعدادات'),
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

  Widget _buildPageHeader(bool isDark) {
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
            Text('إعدادات الخصومات',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            Text('الخصم اليدوي، VIP، الكمية، الكوبونات',
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
