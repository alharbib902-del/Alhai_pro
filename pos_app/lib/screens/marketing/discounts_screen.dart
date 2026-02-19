import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/layout/app_sidebar.dart';
import '../../widgets/layout/app_header.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/router/routes.dart';

/// شاشة الخصومات
class DiscountsScreen extends ConsumerStatefulWidget {
  const DiscountsScreen({super.key});

  @override
  ConsumerState<DiscountsScreen> createState() => _DiscountsScreenState();
}

class _DiscountsScreenState extends ConsumerState<DiscountsScreen> {
  bool _sidebarCollapsed = false;
  String _selectedNavId = 'loyalty';

  final List<_Discount> _discounts = [
    _Discount(id: '1', name: 'خصم نهاية الأسبوع', type: 'percentage', value: 15, appliesTo: 'all', isActive: true, startDate: DateTime.now(), endDate: DateTime.now().add(const Duration(days: 2))),
    _Discount(id: '2', name: 'خصم منتجات الألبان', type: 'percentage', value: 10, appliesTo: 'category', isActive: true, startDate: DateTime.now().subtract(const Duration(days: 5)), endDate: DateTime.now().add(const Duration(days: 10))),
    _Discount(id: '3', name: 'خصم ثابت 5 ر.س', type: 'fixed', value: 5, appliesTo: 'all', isActive: false, startDate: DateTime.now().subtract(const Duration(days: 30)), endDate: DateTime.now().subtract(const Duration(days: 15))),
  ];

  void _handleNavigation(AppSidebarItem item) {
    setState(() => _selectedNavId = item.id);
    switch (item.id) {
      case 'dashboard': context.go(AppRoutes.dashboard); break;
      case 'pos': context.go(AppRoutes.pos); break;
      case 'products': context.push(AppRoutes.products); break;
      case 'categories': context.push(AppRoutes.categories); break;
      case 'inventory': context.push(AppRoutes.inventory); break;
      case 'customers': context.push(AppRoutes.customers); break;
      case 'invoices': context.push(AppRoutes.invoices); break;
      case 'orders': context.push(AppRoutes.orders); break;
      case 'sales': context.push(AppRoutes.invoices); break;
      case 'returns': context.push(AppRoutes.returns); break;
      case 'reports': context.push(AppRoutes.reports); break;
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
      backgroundColor: isDark ? const Color(0xFF0F172A) : AppColors.backgroundSecondary,
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
                  title: 'الخصومات', // TODO: localize
                  onMenuTap: isWideScreen
                      ? () => setState(() => _sidebarCollapsed = !_sidebarCollapsed)
                      : () => Scaffold.of(context).openDrawer(),
                  onNotificationsTap: () => context.push('/notifications'),
                  notificationsCount: 3,
                  userName: 'أحمد محمد',
                  userRole: l10n.branchManager,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
                    child: _buildContent(isWideScreen, isMediumScreen, isDark, l10n),
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
        onItemTap: (item) { Navigator.pop(context); _handleNavigation(item); },
        onSettingsTap: () { Navigator.pop(context); context.push(AppRoutes.settings); },
        onSupportTap: () => Navigator.pop(context),
        onLogoutTap: () { Navigator.pop(context); context.go('/login'); },
        userName: 'أحمد محمد',
        userRole: l10n.branchManager,
        onUserTap: () {},
      ),
    );
  }

  Widget _buildContent(bool isWideScreen, bool isMediumScreen, bool isDark, AppLocalizations l10n) {
    final active = _discounts.where((d) => d.isActive).length;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subtextColor = isDark ? Colors.white70 : AppColors.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row with title and add button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'إدارة الخصومات', // TODO: localize
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
            ),
            FilledButton.icon(
              onPressed: _addDiscount,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('خصم جديد'), // TODO: localize
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Stats cards
        Row(
          children: [
            Expanded(child: _buildStatCard(Icons.local_offer, 'إجمالي', '${_discounts.length}', AppColors.info, isDark)),
            SizedBox(width: isMediumScreen ? 16 : 12),
            Expanded(child: _buildStatCard(Icons.check_circle, 'نشط', '$active', AppColors.success, isDark)),
            SizedBox(width: isMediumScreen ? 16 : 12),
            Expanded(child: _buildStatCard(Icons.pause_circle, 'متوقف', '${_discounts.length - active}', AppColors.textSecondary, isDark)),
          ],
        ),
        const SizedBox(height: 20),

        // Discounts list
        ..._discounts.map((discount) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: !discount.isActive ? (isDark ? const Color(0xFF1E293B).withValues(alpha: 0.5) : Colors.grey.shade100) : cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (discount.isActive ? AppColors.success : AppColors.textSecondary).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.local_offer, color: discount.isActive ? AppColors.success : AppColors.textSecondary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(discount.name, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                          Text(
                            discount.type == 'percentage' ? '${discount.value.toInt()}% خصم' : '${discount.value.toStringAsFixed(0)} ر.س خصم',
                            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    Switch(value: discount.isActive, onChanged: (v) => setState(() => discount.isActive = v), activeColor: AppColors.primary),
                  ],
                ),
                Divider(height: 24, color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
                Row(
                  children: [
                    Icon(Icons.category, size: 14, color: subtextColor),
                    const SizedBox(width: 4),
                    Text(discount.appliesTo == 'all' ? 'جميع المنتجات' : 'تصنيف محدد', style: TextStyle(fontSize: 12, color: subtextColor)),
                    const Spacer(),
                    Icon(Icons.calendar_today, size: 14, color: subtextColor),
                    const SizedBox(width: 4),
                    Text('${_formatDate(discount.startDate)} - ${_formatDate(discount.endDate)}', style: TextStyle(fontSize: 11, color: subtextColor)),
                  ],
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String label, String value, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 20)),
          Text(label, style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : AppColors.textSecondary)),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}';

  void _addDiscount() {
    final nameController = TextEditingController();
    final valueController = TextEditingController();
    String type = 'percentage';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('خصم جديد'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'اسم الخصم', prefixIcon: Icon(Icons.local_offer))),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: const Text('نسبة %'),
                        leading: Icon(type == 'percentage' ? Icons.radio_button_checked : Icons.radio_button_off, color: AppColors.primary),
                        onTap: () => setDialogState(() => type = 'percentage'),
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: const Text('مبلغ ثابت'),
                        leading: Icon(type == 'fixed' ? Icons.radio_button_checked : Icons.radio_button_off, color: AppColors.primary),
                        onTap: () => setDialogState(() => type = 'fixed'),
                      ),
                    ),
                  ],
                ),
                TextField(controller: valueController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: type == 'percentage' ? 'النسبة' : 'المبلغ', prefixIcon: Icon(type == 'percentage' ? Icons.percent : Icons.attach_money))),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            FilledButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && valueController.text.isNotEmpty) {
                  setState(() => _discounts.add(_Discount(
                    id: 'new_${_discounts.length}',
                    name: nameController.text,
                    type: type,
                    value: double.tryParse(valueController.text) ?? 0,
                    appliesTo: 'all',
                    isActive: true,
                    startDate: DateTime.now(),
                    endDate: DateTime.now().add(const Duration(days: 30)),
                  )));
                }
                Navigator.pop(context);
              },
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Discount {
  final String id, name, type, appliesTo;
  final double value;
  bool isActive;
  final DateTime startDate, endDate;
  _Discount({required this.id, required this.name, required this.type, required this.value, required this.appliesTo, required this.isActive, required this.startDate, required this.endDate});
}
