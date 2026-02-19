import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/layout/app_sidebar.dart';
import '../../widgets/layout/app_header.dart';

/// شاشة قالب الإيصال
class ReceiptTemplateScreen extends ConsumerStatefulWidget {
  const ReceiptTemplateScreen({super.key});

  @override
  ConsumerState<ReceiptTemplateScreen> createState() =>
      _ReceiptTemplateScreenState();
}

class _ReceiptTemplateScreenState extends ConsumerState<ReceiptTemplateScreen> {
  bool _sidebarCollapsed = false;
  String _selectedNavId = 'settings';

  final _headerController = TextEditingController(text: 'متجر الإيمان');
  final _footerController =
      TextEditingController(text: 'شكراً لزيارتكم - نتمنى لكم تجربة ممتعة');

  bool _showLogo = true;
  bool _showStoreName = true;
  bool _showAddress = true;
  bool _showPhone = true;
  bool _showVatNumber = true;
  bool _showDate = true;
  bool _showCashier = true;
  bool _showBarcode = true;
  bool _showQrCode = false;
  String _paperSize = '80mm';

  @override
  void dispose() {
    _headerController.dispose();
    _footerController.dispose();
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
                  title: 'قالب الإيصال',
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

        // Header / Footer
        _buildSettingsGroup('الرأس والتذييل', Icons.text_fields_rounded,
            const Color(0xFFEC4899), isDark, [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: TextField(
              controller: _headerController,
              decoration: InputDecoration(
                labelText: 'عنوان الإيصال',
                prefixIcon: const Icon(Icons.title),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: TextField(
              controller: _footerController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'نص التذييل',
                prefixIcon: const Icon(Icons.notes),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ]),

        // Fields to show
        _buildSettingsGroup('الحقول المعروضة', Icons.list_rounded,
            AppColors.info, isDark, [
          SwitchListTile(
            title: Text('شعار المتجر',
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            secondary: const Icon(Icons.image),
            value: _showLogo,
            onChanged: (v) => setState(() => _showLogo = v),
          ),
          SwitchListTile(
            title: Text('اسم المتجر',
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            secondary: const Icon(Icons.store),
            value: _showStoreName,
            onChanged: (v) => setState(() => _showStoreName = v),
          ),
          SwitchListTile(
            title: Text('العنوان',
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            secondary: const Icon(Icons.location_on),
            value: _showAddress,
            onChanged: (v) => setState(() => _showAddress = v),
          ),
          SwitchListTile(
            title: Text('رقم الهاتف',
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            secondary: const Icon(Icons.phone),
            value: _showPhone,
            onChanged: (v) => setState(() => _showPhone = v),
          ),
          SwitchListTile(
            title: Text('الرقم الضريبي',
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            secondary: const Icon(Icons.numbers),
            value: _showVatNumber,
            onChanged: (v) => setState(() => _showVatNumber = v),
          ),
          const Divider(indent: 16, endIndent: 16),
          SwitchListTile(
            title: Text('التاريخ والوقت',
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            secondary: const Icon(Icons.access_time),
            value: _showDate,
            onChanged: (v) => setState(() => _showDate = v),
          ),
          SwitchListTile(
            title: Text('اسم الكاشير',
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            secondary: const Icon(Icons.person),
            value: _showCashier,
            onChanged: (v) => setState(() => _showCashier = v),
          ),
          const Divider(indent: 16, endIndent: 16),
          SwitchListTile(
            title: Text('باركود الفاتورة',
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            secondary: const Icon(Icons.qr_code),
            value: _showBarcode,
            onChanged: (v) => setState(() => _showBarcode = v),
          ),
          SwitchListTile(
            title: Text('رمز QR',
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            subtitle: const Text('رمز QR للفاتورة الإلكترونية'),
            secondary: const Icon(Icons.qr_code_2),
            value: _showQrCode,
            onChanged: (v) => setState(() => _showQrCode = v),
          ),
          const SizedBox(height: 8),
        ]),

        // Paper size
        _buildSettingsGroup('حجم الورق', Icons.straighten_rounded,
            AppColors.success, isDark, [
          RadioListTile<String>(
            title: Text('80mm',
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            subtitle: const Text('الحجم القياسي'),
            value: '80mm',
            groupValue: _paperSize,
            onChanged: (v) => setState(() => _paperSize = v!),
          ),
          RadioListTile<String>(
            title: Text('58mm',
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            subtitle: const Text('حجم صغير'),
            value: '58mm',
            groupValue: _paperSize,
            onChanged: (v) => setState(() => _paperSize = v!),
          ),
          RadioListTile<String>(
            title: Text('A4',
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            subtitle: const Text('طباعة عادية'),
            value: 'a4',
            groupValue: _paperSize,
            onChanged: (v) => setState(() => _paperSize = v!),
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
                  content: Text('تم حفظ قالب الإيصال'),
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
            color: const Color(0xFFEC4899).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.receipt_long_rounded,
              color: Color(0xFFEC4899), size: 24),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('قالب الإيصال',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            Text('الرأس، التذييل، الحقول، حجم الورق',
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
