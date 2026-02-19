import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/layout/app_sidebar.dart';
import '../../widgets/layout/app_header.dart';

/// شاشة إعدادات الباركود والماسح الضوئي
class BarcodeSettingsScreen extends ConsumerStatefulWidget {
  const BarcodeSettingsScreen({super.key});

  @override
  ConsumerState<BarcodeSettingsScreen> createState() =>
      _BarcodeSettingsScreenState();
}

class _BarcodeSettingsScreenState extends ConsumerState<BarcodeSettingsScreen> {
  bool _sidebarCollapsed = false;
  String _selectedNavId = 'settings';

  bool _enableBarcodeScanner = true;
  bool _enableCameraScanner = true;
  bool _enableBluetoothScanner = false;
  bool _beepOnScan = true;
  bool _vibrateOnScan = false;
  bool _autoAddToCart = true;
  String _barcodeFormat = 'all';

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
                  title: 'إعدادات الباركود',
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

        // Scanner activation
        _buildSettingsGroup('تفعيل الماسح', Icons.qr_code_scanner_rounded,
            const Color(0xFFF59E0B), isDark, [
          SwitchListTile(
            title: Text('الماسح الضوئي',
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            subtitle:
                const Text('استخدام ماسح الباركود لإضافة المنتجات'),
            secondary: const Icon(Icons.qr_code_scanner),
            value: _enableBarcodeScanner,
            onChanged: (v) => setState(() => _enableBarcodeScanner = v),
          ),
          if (_enableBarcodeScanner) ...[
            const Divider(indent: 16, endIndent: 16),
            SwitchListTile(
              title: Text('كاميرا الجهاز',
                  style: TextStyle(
                      color: isDark ? Colors.white : AppColors.textPrimary)),
              secondary: const Icon(Icons.camera_alt),
              value: _enableCameraScanner,
              onChanged: (v) => setState(() => _enableCameraScanner = v),
            ),
            SwitchListTile(
              title: Text('ماسح Bluetooth',
                  style: TextStyle(
                      color: isDark ? Colors.white : AppColors.textPrimary)),
              subtitle: const Text('ماسح خارجي متصل'),
              secondary: const Icon(Icons.bluetooth),
              value: _enableBluetoothScanner,
              onChanged: (v) => setState(() => _enableBluetoothScanner = v),
            ),
          ],
          const SizedBox(height: 8),
        ]),

        // Feedback settings
        _buildSettingsGroup(
            'التنبيهات', Icons.notifications_active_rounded,
            AppColors.info, isDark, [
          SwitchListTile(
            title: Text('صوت عند المسح',
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            secondary: const Icon(Icons.volume_up),
            value: _beepOnScan,
            onChanged: (v) => setState(() => _beepOnScan = v),
          ),
          SwitchListTile(
            title: Text('اهتزاز عند المسح',
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            secondary: const Icon(Icons.vibration),
            value: _vibrateOnScan,
            onChanged: (v) => setState(() => _vibrateOnScan = v),
          ),
          const SizedBox(height: 8),
        ]),

        // Behavior settings
        _buildSettingsGroup('السلوك', Icons.tune_rounded,
            AppColors.success, isDark, [
          SwitchListTile(
            title: Text('إضافة تلقائية للسلة',
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            subtitle: const Text('عند مسح منتج موجود'),
            secondary: const Icon(Icons.add_shopping_cart),
            value: _autoAddToCart,
            onChanged: (v) => setState(() => _autoAddToCart = v),
          ),
          const Divider(indent: 16, endIndent: 16),
          ListTile(
            leading: const Icon(Icons.format_list_numbered),
            title: Text('صيغ الباركود',
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            subtitle: Text(_getBarcodeFormatName()),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showBarcodeFormatPicker,
          ),
          const SizedBox(height: 8),
        ]),

        // Test scanner
        _buildSettingsGroup('الاختبار', Icons.bug_report_rounded,
            AppColors.primary, isDark, [
          ListTile(
            leading: const Icon(Icons.bug_report, color: AppColors.primary),
            title: Text('اختبار الماسح',
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            subtitle: const Text('تجربة مسح باركود'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _testScanner,
          ),
          const SizedBox(height: 8),
        ]),
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
            color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.qr_code_scanner_rounded,
              color: Color(0xFFF59E0B), size: 24),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('إعدادات الباركود',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            Text('الماسح الضوئي، التنبيهات، الصيغ',
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

  String _getBarcodeFormatName() {
    switch (_barcodeFormat) {
      case 'all':
        return 'جميع الصيغ';
      case 'ean':
        return 'EAN-8, EAN-13';
      case 'upc':
        return 'UPC-A, UPC-E';
      case 'qr':
        return 'QR Code';
      default:
        return 'غير محدد';
    }
  }

  void _showBarcodeFormatPicker() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('صيغ الباركود'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('جميع الصيغ'),
              value: 'all',
              groupValue: _barcodeFormat,
              onChanged: (v) {
                setState(() => _barcodeFormat = v!);
                Navigator.pop(ctx);
              },
            ),
            RadioListTile<String>(
              title: const Text('EAN-8, EAN-13'),
              value: 'ean',
              groupValue: _barcodeFormat,
              onChanged: (v) {
                setState(() => _barcodeFormat = v!);
                Navigator.pop(ctx);
              },
            ),
            RadioListTile<String>(
              title: const Text('UPC-A, UPC-E'),
              value: 'upc',
              groupValue: _barcodeFormat,
              onChanged: (v) {
                setState(() => _barcodeFormat = v!);
                Navigator.pop(ctx);
              },
            ),
            RadioListTile<String>(
              title: const Text('QR Code فقط'),
              value: 'qr',
              groupValue: _barcodeFormat,
              onChanged: (v) {
                setState(() => _barcodeFormat = v!);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _testScanner() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        height: 400,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            Icon(Icons.qr_code_scanner,
                size: 64,
                color: isDark ? Colors.white70 : AppColors.primary),
            const SizedBox(height: 16),
            Text('وجه الكاميرا نحو الباركود',
                style: TextStyle(
                    fontSize: 18,
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text('منطقة المسح',
                      style: TextStyle(
                          color: isDark ? Colors.white38 : Colors.grey)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('إلغاء'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
