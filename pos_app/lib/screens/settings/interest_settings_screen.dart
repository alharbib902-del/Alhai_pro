import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/layout/app_sidebar.dart';
import '../../widgets/layout/app_header.dart';

/// شاشة إعدادات الفوائد الشهرية
class InterestSettingsScreen extends ConsumerStatefulWidget {
  const InterestSettingsScreen({super.key});

  @override
  ConsumerState<InterestSettingsScreen> createState() =>
      _InterestSettingsScreenState();
}

class _InterestSettingsScreenState
    extends ConsumerState<InterestSettingsScreen> {
  bool _sidebarCollapsed = false;
  String _selectedNavId = 'settings';

  bool _enableInterest = true;
  double _monthlyRate = 2.0;
  int _gracePeriodDays = 30;
  bool _compoundInterest = false;
  bool _autoCalculate = true;
  bool _notifyCustomer = true;
  double _maxInterestRate = 5.0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _enableInterest = prefs.getBool('interest_enabled') ?? true;
      _monthlyRate = prefs.getDouble('interest_monthly_rate') ?? 2.0;
      _gracePeriodDays = prefs.getInt('interest_grace_days') ?? 30;
      _compoundInterest = prefs.getBool('interest_compound') ?? false;
      _autoCalculate = prefs.getBool('interest_auto_calculate') ?? true;
      _notifyCustomer = prefs.getBool('interest_notify_customer') ?? true;
      _maxInterestRate = prefs.getDouble('interest_max_rate') ?? 5.0;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('interest_enabled', _enableInterest);
    await prefs.setDouble('interest_monthly_rate', _monthlyRate);
    await prefs.setInt('interest_grace_days', _gracePeriodDays);
    await prefs.setBool('interest_compound', _compoundInterest);
    await prefs.setBool('interest_auto_calculate', _autoCalculate);
    await prefs.setBool('interest_notify_customer', _notifyCustomer);
    await prefs.setDouble('interest_max_rate', _maxInterestRate);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ إعدادات الفوائد'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
                  title: 'إعدادات الفوائد',
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

        // Interest settings
        _buildSettingsGroup('الفوائد الشهرية', Icons.trending_up_rounded,
            const Color(0xFFF97316), isDark, [
          SwitchListTile(
            title: Text('تفعيل الفوائد',
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            subtitle:
                const Text('تطبيق فوائد على الديون الآجلة'),
            value: _enableInterest,
            onChanged: (v) => setState(() => _enableInterest = v),
          ),
          if (_enableInterest) ...[
            const Divider(indent: 16, endIndent: 16),
            ListTile(
              title: Text('نسبة الفائدة الشهرية',
                  style: TextStyle(
                      color: isDark ? Colors.white : AppColors.textPrimary)),
              subtitle: Text('${_monthlyRate.toStringAsFixed(1)}%'),
              trailing: SizedBox(
                width: 200,
                child: Slider(
                  value: _monthlyRate,
                  min: 0.5,
                  max: _maxInterestRate,
                  divisions: ((_maxInterestRate - 0.5) * 2).toInt(),
                  label: '${_monthlyRate.toStringAsFixed(1)}%',
                  onChanged: (v) => setState(() => _monthlyRate = v),
                ),
              ),
            ),
            ListTile(
              title: Text('الحد الأقصى للفائدة',
                  style: TextStyle(
                      color: isDark ? Colors.white : AppColors.textPrimary)),
              subtitle: Text('${_maxInterestRate.toStringAsFixed(1)}%'),
              trailing: SizedBox(
                width: 200,
                child: Slider(
                  value: _maxInterestRate,
                  min: 2,
                  max: 10,
                  divisions: 16,
                  label: '${_maxInterestRate.toStringAsFixed(1)}%',
                  onChanged: (v) {
                    setState(() {
                      _maxInterestRate = v;
                      if (_monthlyRate > v) _monthlyRate = v;
                    });
                  },
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
        ]),

        // Grace period
        if (_enableInterest)
          _buildSettingsGroup('فترة السماح', Icons.schedule_rounded,
              AppColors.info, isDark, [
            ListTile(
              title: Text('أيام السماح',
                  style: TextStyle(
                      color: isDark ? Colors.white : AppColors.textPrimary)),
              subtitle: Text('$_gracePeriodDays يوم قبل احتساب الفائدة'),
              trailing: SizedBox(
                width: 200,
                child: Slider(
                  value: _gracePeriodDays.toDouble(),
                  min: 0,
                  max: 90,
                  divisions: 9,
                  label: '$_gracePeriodDays يوم',
                  onChanged: (v) =>
                      setState(() => _gracePeriodDays = v.toInt()),
                ),
              ),
            ),
            SwitchListTile(
              title: Text('الفائدة المركبة',
                  style: TextStyle(
                      color: isDark ? Colors.white : AppColors.textPrimary)),
              subtitle: const Text('احتساب فائدة على الفائدة'),
              value: _compoundInterest,
              onChanged: (v) => setState(() => _compoundInterest = v),
            ),
            const SizedBox(height: 8),
          ]),

        // Auto & Notifications
        if (_enableInterest)
          _buildSettingsGroup('الحساب والتنبيهات', Icons.notifications_rounded,
              AppColors.success, isDark, [
            SwitchListTile(
              title: Text('الحساب التلقائي',
                  style: TextStyle(
                      color: isDark ? Colors.white : AppColors.textPrimary)),
              subtitle:
                  const Text('احتساب الفوائد تلقائياً نهاية كل شهر'),
              value: _autoCalculate,
              onChanged: (v) => setState(() => _autoCalculate = v),
            ),
            SwitchListTile(
              title: Text('إشعار العميل',
                  style: TextStyle(
                      color: isDark ? Colors.white : AppColors.textPrimary)),
              subtitle: const Text('إرسال إشعار عند احتساب الفائدة'),
              value: _notifyCustomer,
              onChanged: (v) => setState(() => _notifyCustomer = v),
            ),
            const SizedBox(height: 8),
          ]),

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
            color: const Color(0xFFF97316).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.trending_up_rounded,
              color: Color(0xFFF97316), size: 24),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('إعدادات الفوائد',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary)),
            Text('النسبة، فترة السماح، الحساب التلقائي',
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
