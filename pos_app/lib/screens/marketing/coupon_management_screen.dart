import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/layout/app_sidebar.dart';
import '../../widgets/layout/app_header.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/router/routes.dart';

/// شاشة إدارة الكوبونات
class CouponManagementScreen extends ConsumerStatefulWidget {
  const CouponManagementScreen({super.key});

  @override
  ConsumerState<CouponManagementScreen> createState() => _CouponManagementScreenState();
}

class _CouponManagementScreenState extends ConsumerState<CouponManagementScreen> {
  bool _sidebarCollapsed = false;
  String _selectedNavId = 'loyalty';

  final List<_Coupon> _coupons = [
    _Coupon(id: '1', code: 'WELCOME10', type: 'percentage', value: 10, minOrder: 100, maxUses: 100, usedCount: 45, active: true, expiryDate: DateTime.now().add(const Duration(days: 30))),
    _Coupon(id: '2', code: 'SAVE50', type: 'fixed', value: 50, minOrder: 200, maxUses: 50, usedCount: 20, active: true, expiryDate: DateTime.now().add(const Duration(days: 15))),
    _Coupon(id: '3', code: 'FREESHIP', type: 'freeDelivery', value: 0, minOrder: 150, maxUses: 200, usedCount: 180, active: true, expiryDate: DateTime.now().add(const Duration(days: 7))),
    _Coupon(id: '4', code: 'OLD25', type: 'percentage', value: 25, minOrder: 0, maxUses: 30, usedCount: 30, active: false, expiryDate: DateTime.now().subtract(const Duration(days: 5))),
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
                  title: 'إدارة الكوبونات', // TODO: localize
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
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subtextColor = isDark ? Colors.white70 : AppColors.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('الكوبونات', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)), // TODO: localize
            FilledButton.icon(
              onPressed: _addCoupon,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('كوبون جديد'), // TODO: localize
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Stats
        Row(
          children: [
            Expanded(child: _buildStatCard(Icons.confirmation_number, 'الكوبونات', '${_coupons.length}', AppColors.info, isDark)),
            SizedBox(width: isMediumScreen ? 16 : 12),
            Expanded(child: _buildStatCard(Icons.check_circle, 'نشط', '${_coupons.where((c) => c.active).length}', AppColors.success, isDark)),
            SizedBox(width: isMediumScreen ? 16 : 12),
            Expanded(child: _buildStatCard(Icons.analytics, 'الاستخدامات', '${_coupons.fold(0, (sum, c) => sum + c.usedCount)}', AppColors.secondary, isDark)),
          ],
        ),
        const SizedBox(height: 20),

        // Coupons list
        ..._coupons.map((coupon) {
          final isExpired = coupon.expiryDate.isBefore(DateTime.now());
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: !coupon.active || isExpired ? (isDark ? const Color(0xFF1E293B).withValues(alpha: 0.5) : Colors.grey.shade100) : cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getTypeColor(coupon.type).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_getTypeIcon(coupon.type), color: _getTypeColor(coupon.type)),
              ),
              title: Row(
                children: [
                  Text(coupon.code, style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace', color: textColor)),
                  const SizedBox(width: 8),
                  if (!coupon.active || isExpired)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.textSecondary, borderRadius: BorderRadius.circular(4)),
                      child: Text(isExpired ? 'منتهي' : 'معطل', style: const TextStyle(color: Colors.white, fontSize: 10)),
                    ),
                ],
              ),
              subtitle: Text(
                '${_getTypeLabel(coupon)} - ${coupon.usedCount}/${coupon.maxUses} استخدام', // TODO: localize
                style: TextStyle(color: subtextColor, fontSize: 12),
              ),
              trailing: Switch(
                value: coupon.active && !isExpired,
                onChanged: isExpired ? null : (v) => setState(() => coupon.active = v),
                activeColor: AppColors.primary,
              ),
              onTap: () => _showDetails(coupon),
            ),
          );
        }),
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

  String _getTypeLabel(_Coupon c) {
    switch (c.type) {
      case 'percentage': return 'خصم ${c.value.toInt()}%';
      case 'fixed': return 'خصم ${c.value.toInt()} ر.س';
      case 'freeDelivery': return 'توصيل مجاني';
      default: return '';
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'percentage': return AppColors.success;
      case 'fixed': return AppColors.info;
      case 'freeDelivery': return AppColors.secondary;
      default: return AppColors.textSecondary;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'percentage': return Icons.percent;
      case 'fixed': return Icons.attach_money;
      case 'freeDelivery': return Icons.local_shipping;
      default: return Icons.confirmation_number;
    }
  }

  void _addCoupon() {
    final codeController = TextEditingController();
    final valueController = TextEditingController();
    String type = 'percentage';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('كوبون جديد'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: codeController,
                  decoration: const InputDecoration(labelText: 'كود الكوبون', prefixIcon: Icon(Icons.confirmation_number)),
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: type,
                  decoration: const InputDecoration(labelText: 'النوع', prefixIcon: Icon(Icons.category)),
                  items: const [
                    DropdownMenuItem(value: 'percentage', child: Text('خصم نسبة')),
                    DropdownMenuItem(value: 'fixed', child: Text('خصم ثابت')),
                    DropdownMenuItem(value: 'freeDelivery', child: Text('توصيل مجاني')),
                  ],
                  onChanged: (v) => setDialogState(() => type = v!),
                ),
                if (type != 'freeDelivery') ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: valueController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: type == 'percentage' ? 'النسبة %' : 'المبلغ',
                      prefixIcon: Icon(type == 'percentage' ? Icons.percent : Icons.attach_money),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            FilledButton(
              onPressed: () {
                if (codeController.text.isNotEmpty) {
                  setState(() {
                    _coupons.add(_Coupon(
                      id: 'new_${_coupons.length}',
                      code: codeController.text.toUpperCase(),
                      type: type,
                      value: double.tryParse(valueController.text) ?? 0,
                      minOrder: 0,
                      maxUses: 100,
                      usedCount: 0,
                      active: true,
                      expiryDate: DateTime.now().add(const Duration(days: 30)),
                    ));
                  });
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

  void _showDetails(_Coupon c) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(c.code, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'monospace', color: isDark ? Colors.white : AppColors.textPrimary)),
            const SizedBox(height: 16),
            _DetailRow(label: 'النوع', value: _getTypeLabel(c), isDark: isDark),
            _DetailRow(label: 'الحد الأدنى للطلب', value: '${c.minOrder.toInt()} ر.س', isDark: isDark),
            _DetailRow(label: 'الاستخدامات', value: '${c.usedCount}/${c.maxUses}', isDark: isDark),
            _DetailRow(label: 'تاريخ الانتهاء', value: '${c.expiryDate.day}/${c.expiryDate.month}/${c.expiryDate.year}', isDark: isDark),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () { Navigator.pop(context); setState(() => _coupons.remove(c)); },
                    icon: const Icon(Icons.delete, color: AppColors.error),
                    label: const Text('حذف', style: TextStyle(color: AppColors.error)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.copy),
                  label: const Text('نسخ الكود'),
                  style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Coupon {
  final String id;
  final String code;
  final String type;
  final double value;
  final double minOrder;
  final int maxUses;
  final int usedCount;
  bool active;
  final DateTime expiryDate;

  _Coupon({required this.id, required this.code, required this.type, required this.value, required this.minOrder, required this.maxUses, required this.usedCount, required this.active, required this.expiryDate});
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  const _DetailRow({required this.label, required this.value, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isDark ? Colors.white60 : AppColors.textSecondary)),
          Text(value, style: TextStyle(fontWeight: FontWeight.w500, color: isDark ? Colors.white : AppColors.textPrimary)),
        ],
      ),
    );
  }
}
