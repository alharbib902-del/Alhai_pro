import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/layout/app_sidebar.dart';
import '../../widgets/layout/app_header.dart';

/// شاشة إعدادات المتجر - بتصميم Sidebar + Header
class StoreSettingsScreen extends ConsumerStatefulWidget {
  const StoreSettingsScreen({super.key});

  @override
  ConsumerState<StoreSettingsScreen> createState() =>
      _StoreSettingsScreenState();
}

class _StoreSettingsScreenState extends ConsumerState<StoreSettingsScreen> {
  bool _sidebarCollapsed = false;
  String _selectedNavId = 'settings';

  final _nameController = TextEditingController(text: 'متجر الإيمان');
  final _addressController = TextEditingController(text: 'الرياض - حي النزهة');
  final _phoneController = TextEditingController(text: '0501234567');
  final _vatController = TextEditingController(text: '310123456700003');
  final _crController = TextEditingController(text: '1010123456');

  String _currency = 'SAR';
  String _language = 'ar';
  bool _enableVat = true;
  double _vatRate = 15.0;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _vatController.dispose();
    _crController.dispose();
    super.dispose();
  }

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
                  title: 'إعدادات المتجر',
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
                    child: _buildContent(
                        isWideScreen, isMediumScreen, isDark, l10n),
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

  Widget _buildContent(
      bool isWideScreen, bool isMediumScreen, bool isDark, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPageHeader(isDark),
        const SizedBox(height: 20),

        // Store Info
        _buildSettingsGroup('معلومات المتجر', Icons.store_rounded,
            AppColors.primary, isDark, [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'اسم المتجر',
                prefixIcon: const Icon(Icons.badge),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'العنوان',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'رقم الهاتف',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ]),

        // Tax Info
        _buildSettingsGroup('المعلومات الضريبية', Icons.receipt_long_rounded,
            AppColors.success, isDark, [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: TextField(
              controller: _vatController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'الرقم الضريبي (VAT)',
                prefixIcon: const Icon(Icons.numbers),
                helperText: '15 رقم يبدأ بـ 3',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: TextField(
              controller: _crController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'السجل التجاري',
                prefixIcon: const Icon(Icons.business),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          SwitchListTile(
            title: Text('تفعيل ضريبة القيمة المضافة',
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            value: _enableVat,
            onChanged: (v) => setState(() => _enableVat = v),
          ),
          if (_enableVat)
            ListTile(
              title: Text('نسبة الضريبة',
                  style: TextStyle(
                      color: isDark ? Colors.white : AppColors.textPrimary)),
              subtitle: Text('${_vatRate.toInt()}%'),
              trailing: SizedBox(
                width: 150,
                child: Slider(
                  value: _vatRate,
                  min: 5,
                  max: 20,
                  divisions: 3,
                  label: '${_vatRate.toInt()}%',
                  onChanged: (v) => setState(() => _vatRate = v),
                ),
              ),
            ),
          const SizedBox(height: 8),
        ]),

        // Locale
        _buildSettingsGroup('اللغة والعملة', Icons.language_rounded,
            const Color(0xFFF97316), isDark, [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: DropdownButtonFormField<String>(
              value: _language,
              decoration: InputDecoration(
                labelText: 'اللغة',
                prefixIcon: const Icon(Icons.translate),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              items: const [
                DropdownMenuItem(value: 'ar', child: Text('العربية')),
                DropdownMenuItem(value: 'en', child: Text('English')),
              ],
              onChanged: (v) => setState(() => _language = v!),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: DropdownButtonFormField<String>(
              value: _currency,
              decoration: InputDecoration(
                labelText: 'العملة',
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              items: const [
                DropdownMenuItem(
                    value: 'SAR', child: Text('ريال سعودي (SAR)')),
                DropdownMenuItem(
                    value: 'AED', child: Text('درهم إماراتي (AED)')),
                DropdownMenuItem(
                    value: 'KWD', child: Text('دينار كويتي (KWD)')),
                DropdownMenuItem(
                    value: 'USD', child: Text('دولار أمريكي (USD)')),
              ],
              onChanged: (v) => setState(() => _currency = v!),
            ),
          ),
        ]),

        // Logo
        _buildSettingsGroup('شعار المتجر', Icons.image_rounded,
            const Color(0xFFEC4899), isDark, [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.grey.shade200,
              child: Icon(Icons.image,
                  color: isDark ? Colors.white54 : Colors.grey),
            ),
            title: Text('شعار المتجر',
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            subtitle: Text('يظهر في الفواتير والإيصالات',
                style: TextStyle(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.5)
                        : AppColors.textSecondary)),
            trailing: TextButton(
              onPressed: () {},
              child: const Text('تغيير'),
            ),
          ),
        ]),

        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _saveSettings,
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
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.store_rounded,
              color: AppColors.primary, size: 24),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('إعدادات المتجر',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            Text('الاسم، العنوان، المعلومات الضريبية',
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

  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حفظ الإعدادات'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
