/// شاشة إعدادات نقطة البيع - POS Settings Screen
///
/// شاشة لإدارة إعدادات نقطة البيع
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/layout/app_sidebar.dart';
import '../../widgets/layout/app_header.dart';

/// شاشة إعدادات نقطة البيع
class PosSettingsScreen extends ConsumerStatefulWidget {
  const PosSettingsScreen({super.key});

  @override
  ConsumerState<PosSettingsScreen> createState() => _PosSettingsScreenState();
}

class _PosSettingsScreenState extends ConsumerState<PosSettingsScreen> {
  bool _sidebarCollapsed = false;
  String _selectedNavId = 'settings';

  // إعدادات العرض
  String _productDisplay = 'grid';
  int _gridColumns = 4;
  bool _showProductImages = true;
  bool _showProductPrices = true;
  bool _showStockLevel = true;

  // إعدادات السلة
  bool _autoFocusBarcode = true;
  bool _allowNegativeStock = false;
  bool _confirmBeforeDelete = true;
  bool _showItemNotes = true;

  // إعدادات الدفع
  bool _enableCashPayment = true;
  bool _enableCardPayment = true;
  bool _enableCreditPayment = true;
  bool _enableBankTransfer = true;
  bool _enableSplitPayment = true;
  bool _requireCustomerForCredit = true;

  // إعدادات الإيصال
  bool _autoPrintReceipt = true;
  bool _emailReceipt = false;
  bool _smsReceipt = false;
  int _receiptCopies = 1;

  // إعدادات أخرى
  bool _enableHoldInvoice = true;
  int _maxHoldInvoices = 10;
  bool _enableQuickSale = true;
  bool _soundEffects = true;
  bool _hapticFeedback = true;

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
                  title: 'إعدادات نقطة البيع',
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
        _buildDisplaySettings(isDark),
        _buildCartSettings(isDark),
        _buildPaymentSettings(isDark),
        _buildReceiptSettings(isDark),
        _buildAdvancedSettings(isDark),
        const SizedBox(height: 16),
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
            color: AppColors.info.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.point_of_sale_rounded,
              color: AppColors.info, size: 24),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('إعدادات نقطة البيع',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            Text('العرض، السلة، الدفع، الإيصال',
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
                  padding: const EdgeInsets.all(AppSizes.sm),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: AppSizes.md),
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

  Widget _buildDisplaySettings(bool isDark) {
    return _buildSettingsGroup(
        'إعدادات العرض', Icons.grid_view, AppColors.primary, isDark, [
      ListTile(
        title: Text('طريقة عرض المنتجات',
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary)),
        subtitle: const Text('كيفية عرض المنتجات في شاشة POS'),
        trailing: SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'grid', icon: Icon(Icons.grid_view, size: 18)),
            ButtonSegment(value: 'list', icon: Icon(Icons.list, size: 18)),
          ],
          selected: {_productDisplay},
          onSelectionChanged: (v) =>
              setState(() => _productDisplay = v.first),
        ),
      ),
      if (_productDisplay == 'grid') ...[
        const Divider(indent: 16, endIndent: 16),
        ListTile(
          title: Text('عدد الأعمدة',
              style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textPrimary)),
          subtitle: Text('$_gridColumns أعمدة'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                  onPressed: _gridColumns > 2
                      ? () => setState(() => _gridColumns--)
                      : null,
                  icon: const Icon(Icons.remove)),
              Text('$_gridColumns', style: AppTypography.titleMedium),
              IconButton(
                  onPressed: _gridColumns < 6
                      ? () => setState(() => _gridColumns++)
                      : null,
                  icon: const Icon(Icons.add)),
            ],
          ),
        ),
      ],
      const Divider(indent: 16, endIndent: 16),
      SwitchListTile(
        title: Text('عرض صور المنتجات',
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary)),
        subtitle: const Text('إظهار الصور في بطاقات المنتجات'),
        value: _showProductImages,
        onChanged: (v) => setState(() => _showProductImages = v),
      ),
      SwitchListTile(
        title: Text('عرض الأسعار',
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary)),
        subtitle: const Text('إظهار السعر على بطاقة المنتج'),
        value: _showProductPrices,
        onChanged: (v) => setState(() => _showProductPrices = v),
      ),
      SwitchListTile(
        title: Text('عرض مستوى المخزون',
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary)),
        subtitle: const Text('إظهار الكمية المتاحة'),
        value: _showStockLevel,
        onChanged: (v) => setState(() => _showStockLevel = v),
      ),
      const SizedBox(height: 8),
    ]);
  }

  Widget _buildCartSettings(bool isDark) {
    return _buildSettingsGroup(
        'إعدادات السلة', Icons.shopping_cart, AppColors.success, isDark, [
      SwitchListTile(
        title: Text('التركيز التلقائي على الباركود',
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary)),
        subtitle: const Text('التركيز على حقل الباركود عند فتح الشاشة'),
        value: _autoFocusBarcode,
        onChanged: (v) => setState(() => _autoFocusBarcode = v),
      ),
      SwitchListTile(
        title: Text('السماح بالمخزون السالب',
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary)),
        subtitle: const Text('البيع حتى لو كان المخزون صفر'),
        value: _allowNegativeStock,
        onChanged: (v) => setState(() => _allowNegativeStock = v),
      ),
      SwitchListTile(
        title: Text('تأكيد قبل الحذف',
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary)),
        subtitle: const Text('طلب تأكيد عند حذف منتج من السلة'),
        value: _confirmBeforeDelete,
        onChanged: (v) => setState(() => _confirmBeforeDelete = v),
      ),
      SwitchListTile(
        title: Text('عرض ملاحظات المنتج',
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary)),
        subtitle: const Text('إمكانية إضافة ملاحظات لكل منتج'),
        value: _showItemNotes,
        onChanged: (v) => setState(() => _showItemNotes = v),
      ),
      const SizedBox(height: 8),
    ]);
  }

  Widget _buildPaymentSettings(bool isDark) {
    return _buildSettingsGroup(
        'طرق الدفع', Icons.payment, AppColors.info, isDark, [
      SwitchListTile(
        title: Text('الدفع نقداً',
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary)),
        secondary: const Icon(Icons.money),
        value: _enableCashPayment,
        onChanged: (v) => setState(() => _enableCashPayment = v),
      ),
      SwitchListTile(
        title: Text('الدفع بالبطاقة',
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary)),
        secondary: const Icon(Icons.credit_card),
        value: _enableCardPayment,
        onChanged: (v) => setState(() => _enableCardPayment = v),
      ),
      SwitchListTile(
        title: Text('الدفع الآجل',
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary)),
        secondary: const Icon(Icons.schedule),
        value: _enableCreditPayment,
        onChanged: (v) => setState(() => _enableCreditPayment = v),
      ),
      SwitchListTile(
        title: Text('التحويل البنكي',
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary)),
        secondary: const Icon(Icons.account_balance),
        value: _enableBankTransfer,
        onChanged: (v) => setState(() => _enableBankTransfer = v),
      ),
      const Divider(indent: 16, endIndent: 16),
      SwitchListTile(
        title: Text('السماح بتقسيم الدفع',
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary)),
        subtitle: const Text('الدفع بأكثر من طريقة'),
        value: _enableSplitPayment,
        onChanged: (v) => setState(() => _enableSplitPayment = v),
      ),
      if (_enableCreditPayment)
        SwitchListTile(
          title: Text('اشتراط العميل للدفع الآجل',
              style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textPrimary)),
          subtitle: const Text('يجب تحديد عميل للدفع الآجل'),
          value: _requireCustomerForCredit,
          onChanged: (v) => setState(() => _requireCustomerForCredit = v),
        ),
      const SizedBox(height: 8),
    ]);
  }

  Widget _buildReceiptSettings(bool isDark) {
    return _buildSettingsGroup(
        'إعدادات الإيصال', Icons.receipt, AppColors.warning, isDark, [
      SwitchListTile(
        title: Text('طباعة الإيصال تلقائياً',
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary)),
        subtitle: const Text('طباعة فور إتمام العملية'),
        value: _autoPrintReceipt,
        onChanged: (v) => setState(() => _autoPrintReceipt = v),
      ),
      if (_autoPrintReceipt) ...[
        const Divider(indent: 16, endIndent: 16),
        ListTile(
          title: Text('عدد نسخ الإيصال',
              style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textPrimary)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                  onPressed: _receiptCopies > 1
                      ? () => setState(() => _receiptCopies--)
                      : null,
                  icon: const Icon(Icons.remove)),
              Text('$_receiptCopies', style: AppTypography.titleMedium),
              IconButton(
                  onPressed: _receiptCopies < 3
                      ? () => setState(() => _receiptCopies++)
                      : null,
                  icon: const Icon(Icons.add)),
            ],
          ),
        ),
      ],
      const Divider(indent: 16, endIndent: 16),
      SwitchListTile(
        title: Text('إرسال الإيصال بالإيميل',
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary)),
        subtitle: const Text('إرسال نسخة للعميل'),
        secondary: const Icon(Icons.email),
        value: _emailReceipt,
        onChanged: (v) => setState(() => _emailReceipt = v),
      ),
      SwitchListTile(
        title: Text('إرسال الإيصال برسالة SMS',
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary)),
        subtitle: const Text('رسالة نصية للعميل'),
        secondary: const Icon(Icons.sms),
        value: _smsReceipt,
        onChanged: (v) => setState(() => _smsReceipt = v),
      ),
      const Divider(indent: 16, endIndent: 16),
      ListTile(
        leading: const Icon(Icons.print),
        title: Text('إعدادات الطابعة',
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary)),
        subtitle: const Text('اختيار الطابعة وإعداداتها'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => context.push(AppRoutes.settingsPrinter),
      ),
      ListTile(
        leading: const Icon(Icons.design_services),
        title: Text('تصميم الإيصال',
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary)),
        subtitle: const Text('تخصيص شكل الإيصال'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => context.push(AppRoutes.settingsReceipt),
      ),
      const SizedBox(height: 8),
    ]);
  }

  Widget _buildAdvancedSettings(bool isDark) {
    return _buildSettingsGroup(
        'إعدادات متقدمة', Icons.tune, AppColors.grey600, isDark, [
      SwitchListTile(
        title: Text('السماح بتعليق الفواتير',
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary)),
        subtitle: const Text('حفظ الفاتورة مؤقتاً'),
        value: _enableHoldInvoice,
        onChanged: (v) => setState(() => _enableHoldInvoice = v),
      ),
      if (_enableHoldInvoice)
        ListTile(
          title: Text('الحد الأقصى للفواتير المعلقة',
              style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textPrimary)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                  onPressed: _maxHoldInvoices > 5
                      ? () => setState(() => _maxHoldInvoices -= 5)
                      : null,
                  icon: const Icon(Icons.remove)),
              Text('$_maxHoldInvoices', style: AppTypography.titleMedium),
              IconButton(
                  onPressed: _maxHoldInvoices < 50
                      ? () => setState(() => _maxHoldInvoices += 5)
                      : null,
                  icon: const Icon(Icons.add)),
            ],
          ),
        ),
      const Divider(indent: 16, endIndent: 16),
      SwitchListTile(
        title: Text('وضع البيع السريع',
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary)),
        subtitle: const Text('شاشة مبسطة للبيع السريع'),
        value: _enableQuickSale,
        onChanged: (v) => setState(() => _enableQuickSale = v),
      ),
      const Divider(indent: 16, endIndent: 16),
      SwitchListTile(
        title: Text('المؤثرات الصوتية',
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary)),
        subtitle: const Text('أصوات عند المسح والإضافة'),
        secondary: const Icon(Icons.volume_up),
        value: _soundEffects,
        onChanged: (v) => setState(() => _soundEffects = v),
      ),
      SwitchListTile(
        title: Text('اهتزاز اللمس',
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary)),
        subtitle: const Text('اهتزاز عند الضغط على الأزرار'),
        secondary: const Icon(Icons.vibration),
        value: _hapticFeedback,
        onChanged: (v) => setState(() => _hapticFeedback = v),
      ),
      const Divider(indent: 16, endIndent: 16),
      ListTile(
        leading: const Icon(Icons.keyboard),
        title: Text('اختصارات لوحة المفاتيح',
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary)),
        subtitle: const Text('تخصيص الاختصارات'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: _showKeyboardShortcuts,
      ),
      ListTile(
        leading: const Icon(Icons.restore, color: AppColors.error),
        title: const Text('إعادة ضبط الإعدادات',
            style: TextStyle(color: AppColors.error)),
        subtitle: const Text('إعادة جميع الإعدادات للقيم الافتراضية'),
        onTap: _showResetConfirmation,
      ),
      const SizedBox(height: 8),
    ]);
  }

  void _saveSettings() {
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حفظ الإعدادات'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showKeyboardShortcuts() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اختصارات لوحة المفاتيح'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildShortcutRow('F1', 'البحث عن منتج', isDark),
              _buildShortcutRow('F2', 'البحث عن عميل', isDark),
              _buildShortcutRow('F3', 'تعليق الفاتورة', isDark),
              _buildShortcutRow('F4', 'المفضلة', isDark),
              _buildShortcutRow('F8', 'تطبيق خصم', isDark),
              _buildShortcutRow('F12', 'الدفع', isDark),
              _buildShortcutRow('ESC', 'إلغاء / رجوع', isDark),
              _buildShortcutRow('Delete', 'حذف منتج', isDark),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إغلاق')),
        ],
      ),
    );
  }

  Widget _buildShortcutRow(String key, String action, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.sm, vertical: AppSizes.xs),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : AppColors.grey200,
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Text(key,
                style: AppTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.bold, fontFamily: 'monospace')),
          ),
          const SizedBox(width: AppSizes.md),
          Text(action),
        ],
      ),
    );
  }

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إعادة ضبط الإعدادات'),
        content: const Text(
            'هل أنت متأكد من إعادة جميع إعدادات نقطة البيع للقيم الافتراضية؟'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _resetSettings();
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('إعادة ضبط'),
          ),
        ],
      ),
    );
  }

  void _resetSettings() {
    setState(() {
      _productDisplay = 'grid';
      _gridColumns = 4;
      _showProductImages = true;
      _showProductPrices = true;
      _showStockLevel = true;
      _autoFocusBarcode = true;
      _allowNegativeStock = false;
      _confirmBeforeDelete = true;
      _showItemNotes = true;
      _enableCashPayment = true;
      _enableCardPayment = true;
      _enableCreditPayment = true;
      _enableBankTransfer = true;
      _enableSplitPayment = true;
      _requireCustomerForCredit = true;
      _autoPrintReceipt = true;
      _emailReceipt = false;
      _smsReceipt = false;
      _receiptCopies = 1;
      _enableHoldInvoice = true;
      _maxHoldInvoices = 10;
      _enableQuickSale = true;
      _soundEffects = true;
      _hapticFeedback = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم إعادة ضبط الإعدادات'),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
