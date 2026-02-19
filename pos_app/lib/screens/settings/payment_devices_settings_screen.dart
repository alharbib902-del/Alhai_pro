/// شاشة إعدادات أجهزة الدفع - Payment Devices Settings Screen
///
/// شاشة لإدارة أجهزة الدفع المتصلة
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/layout/app_sidebar.dart';
import '../../widgets/layout/app_header.dart';

/// شاشة إعدادات أجهزة الدفع
class PaymentDevicesSettingsScreen extends ConsumerStatefulWidget {
  const PaymentDevicesSettingsScreen({super.key});

  @override
  ConsumerState<PaymentDevicesSettingsScreen> createState() =>
      _PaymentDevicesSettingsScreenState();
}

class _PaymentDevicesSettingsScreenState
    extends ConsumerState<PaymentDevicesSettingsScreen> {
  bool _sidebarCollapsed = false;
  String _selectedNavId = 'settings';

  bool _enableMada = true;
  bool _enableVisa = true;
  bool _enableStcPay = false;
  bool _enableApplePay = false;
  String _terminalType = 'ingenico';
  bool _autoSettle = true;

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
                  title: 'أجهزة الدفع',
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

        // Payment methods
        _buildSettingsGroup('طرق الدفع المدعومة', Icons.payment_rounded,
            const Color(0xFF06B6D4), isDark, [
          SwitchListTile(
            title: Text('مدى (mada)',
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            subtitle: const Text('بطاقات مدى المحلية'),
            secondary: const Icon(Icons.credit_card),
            value: _enableMada,
            onChanged: (v) => setState(() => _enableMada = v),
          ),
          SwitchListTile(
            title: Text('Visa / Mastercard',
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            subtitle: const Text('البطاقات الدولية'),
            secondary: const Icon(Icons.credit_card),
            value: _enableVisa,
            onChanged: (v) => setState(() => _enableVisa = v),
          ),
          const Divider(indent: 16, endIndent: 16),
          SwitchListTile(
            title: Text('STC Pay',
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            subtitle: const Text('محفظة STC الرقمية'),
            secondary: const Icon(Icons.phone_android),
            value: _enableStcPay,
            onChanged: (v) => setState(() => _enableStcPay = v),
          ),
          SwitchListTile(
            title: Text('Apple Pay',
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            secondary: const Icon(Icons.apple),
            value: _enableApplePay,
            onChanged: (v) => setState(() => _enableApplePay = v),
          ),
          const SizedBox(height: 8),
        ]),

        // Terminal
        _buildSettingsGroup('جهاز الدفع', Icons.contactless_rounded,
            AppColors.primary, isDark, [
          RadioListTile<String>(
            title: Text('Ingenico',
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            subtitle: const Text('أجهزة Ingenico'),
            value: 'ingenico',
            groupValue: _terminalType,
            onChanged: (v) => setState(() => _terminalType = v!),
          ),
          RadioListTile<String>(
            title: Text('Verifone',
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            subtitle: const Text('أجهزة Verifone'),
            value: 'verifone',
            groupValue: _terminalType,
            onChanged: (v) => setState(() => _terminalType = v!),
          ),
          RadioListTile<String>(
            title: Text('PAX',
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            subtitle: const Text('أجهزة PAX'),
            value: 'pax',
            groupValue: _terminalType,
            onChanged: (v) => setState(() => _terminalType = v!),
          ),
          const SizedBox(height: 8),
        ]),

        // Settlement
        _buildSettingsGroup('التسوية', Icons.account_balance_rounded,
            AppColors.success, isDark, [
          SwitchListTile(
            title: Text('التسوية التلقائية',
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            subtitle: const Text('تسوية نهاية اليوم تلقائياً'),
            value: _autoSettle,
            onChanged: (v) => setState(() => _autoSettle = v),
          ),
          ListTile(
            leading: const Icon(Icons.sync, color: AppColors.info),
            title: Text('تسوية يدوية',
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            subtitle: const Text('تنفيذ التسوية الآن'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('جاري التسوية...')),
              );
            },
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
                  content: Text('تم حفظ إعدادات أجهزة الدفع'),
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
            Text('أجهزة الدفع',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            Text('mada, STC Pay, Apple Pay',
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
