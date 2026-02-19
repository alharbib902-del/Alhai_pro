import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/layout/app_sidebar.dart';
import '../../widgets/layout/app_header.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/router/routes.dart';

/// شاشة العروض الخاصة
class SpecialOffersScreen extends ConsumerStatefulWidget {
  const SpecialOffersScreen({super.key});

  @override
  ConsumerState<SpecialOffersScreen> createState() => _SpecialOffersScreenState();
}

class _SpecialOffersScreenState extends ConsumerState<SpecialOffersScreen> {
  bool _sidebarCollapsed = false;
  String _selectedNavId = 'loyalty';

  final List<_Offer> _offers = [
    _Offer(id: '1', name: 'عرض رمضان', type: 'bundle', discount: 20, startDate: DateTime.now(), endDate: DateTime.now().add(const Duration(days: 30)), products: ['أرز', 'زيت', 'سكر'], active: true),
    _Offer(id: '2', name: 'اشتري 2 واحصل على 1', type: 'buy_get', discount: 0, startDate: DateTime.now(), endDate: DateTime.now().add(const Duration(days: 7)), products: ['حليب'], active: true),
    _Offer(id: '3', name: 'خصم نهاية الأسبوع', type: 'percentage', discount: 15, startDate: DateTime.now(), endDate: DateTime.now().add(const Duration(days: 2)), products: [], active: true),
    _Offer(id: '4', name: 'عرض العودة للمدارس', type: 'percentage', discount: 10, startDate: DateTime.now().subtract(const Duration(days: 60)), endDate: DateTime.now().subtract(const Duration(days: 30)), products: [], active: false),
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
                  title: 'العروض الخاصة', // TODO: localize
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
            Text('العروض الخاصة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)), // TODO: localize
            FilledButton.icon(
              onPressed: _addOffer,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('عرض جديد'), // TODO: localize
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Stats
        Row(
          children: [
            Expanded(child: _buildStatCard(Icons.local_offer, 'إجمالي', '${_offers.length}', AppColors.info, isDark)),
            SizedBox(width: isMediumScreen ? 16 : 12),
            Expanded(child: _buildStatCard(Icons.check_circle, 'نشط', '${_offers.where((o) => o.active).length}', AppColors.success, isDark)),
            SizedBox(width: isMediumScreen ? 16 : 12),
            Expanded(child: _buildStatCard(Icons.timer, 'ينتهي قريباً', '${_offers.where((o) => o.active && o.endDate.difference(DateTime.now()).inDays <= 7).length}', AppColors.secondary, isDark)),
          ],
        ),
        const SizedBox(height: 20),

        // Offers list
        ..._offers.map((offer) {
          final isExpired = offer.endDate.isBefore(DateTime.now());
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isExpired ? (isDark ? const Color(0xFF1E293B).withValues(alpha: 0.5) : Colors.grey.shade100) : cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getTypeColor(offer.type).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_getTypeIcon(offer.type), color: _getTypeColor(offer.type)),
              ),
              title: Row(
                children: [
                  Expanded(child: Text(offer.name, style: TextStyle(fontWeight: FontWeight.bold, color: textColor))),
                  if (isExpired) Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.textSecondary, borderRadius: BorderRadius.circular(4)),
                    child: const Text('منتهي', style: TextStyle(color: Colors.white, fontSize: 10)),
                  ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_getTypeLabel(offer), style: TextStyle(color: subtextColor, fontSize: 12)),
                  Text('${offer.endDate.day}/${offer.endDate.month}/${offer.endDate.year}', style: TextStyle(fontSize: 11, color: subtextColor)),
                ],
              ),
              trailing: Switch(
                value: offer.active && !isExpired,
                onChanged: isExpired ? null : (v) => setState(() => offer.active = v),
                activeColor: AppColors.primary,
              ),
              onTap: () => _showOfferDetails(offer),
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

  Color _getTypeColor(String type) => {
    'bundle': const Color(0xFF8B5CF6),
    'buy_get': AppColors.info,
    'percentage': AppColors.success,
    'fixed': AppColors.secondary,
  }[type] ?? AppColors.textSecondary;

  IconData _getTypeIcon(String type) => {
    'bundle': Icons.inventory_2,
    'buy_get': Icons.card_giftcard,
    'percentage': Icons.percent,
    'fixed': Icons.attach_money,
  }[type] ?? Icons.local_offer;

  String _getTypeLabel(_Offer o) {
    switch (o.type) {
      case 'bundle': return 'باقة - خصم ${o.discount}%';
      case 'buy_get': return 'اشتري واحصل مجاناً';
      case 'percentage': return 'خصم ${o.discount}%';
      case 'fixed': return 'خصم ${o.discount} ر.س';
      default: return '';
    }
  }

  void _addOffer() {
    final nameController = TextEditingController();
    String type = 'percentage';
    double discount = 10;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('عرض جديد'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'اسم العرض', prefixIcon: Icon(Icons.local_offer))),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: type,
                  decoration: const InputDecoration(labelText: 'النوع', prefixIcon: Icon(Icons.category)),
                  items: const [
                    DropdownMenuItem(value: 'percentage', child: Text('خصم نسبة')),
                    DropdownMenuItem(value: 'fixed', child: Text('خصم ثابت')),
                    DropdownMenuItem(value: 'bundle', child: Text('باقة')),
                    DropdownMenuItem(value: 'buy_get', child: Text('اشتري واحصل')),
                  ],
                  onChanged: (v) => setDialogState(() => type = v!),
                ),
                if (type != 'buy_get') ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('الخصم:'),
                      Expanded(child: Slider(value: discount, min: 5, max: 50, divisions: 9, label: '${discount.toInt()}', onChanged: (v) => setDialogState(() => discount = v))),
                      Text('${discount.toInt()}%'),
                    ],
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            FilledButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  setState(() => _offers.insert(0, _Offer(id: 'new_${_offers.length}', name: nameController.text, type: type, discount: discount, startDate: DateTime.now(), endDate: DateTime.now().add(const Duration(days: 30)), products: [], active: true)));
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

  void _showOfferDetails(_Offer o) {
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
            Row(children: [
              Icon(_getTypeIcon(o.type), size: 32, color: _getTypeColor(o.type)),
              const SizedBox(width: 12),
              Expanded(child: Text(o.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary))),
            ]),
            const SizedBox(height: 16),
            _DetailRow(label: 'النوع', value: _getTypeLabel(o), isDark: isDark),
            _DetailRow(label: 'البداية', value: '${o.startDate.day}/${o.startDate.month}/${o.startDate.year}', isDark: isDark),
            _DetailRow(label: 'النهاية', value: '${o.endDate.day}/${o.endDate.month}/${o.endDate.year}', isDark: isDark),
            if (o.products.isNotEmpty) _DetailRow(label: 'المنتجات', value: o.products.join('، '), isDark: isDark),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: OutlinedButton.icon(onPressed: () { Navigator.pop(context); setState(() => _offers.remove(o)); }, icon: const Icon(Icons.delete, color: AppColors.error), label: const Text('حذف', style: TextStyle(color: AppColors.error)))),
              const SizedBox(width: 12),
              Expanded(child: FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.edit), label: const Text('تعديل'), style: FilledButton.styleFrom(backgroundColor: AppColors.primary))),
            ]),
          ],
        ),
      ),
    );
  }
}

class _Offer {
  final String id, name, type;
  final double discount;
  final DateTime startDate, endDate;
  final List<String> products;
  bool active;
  _Offer({required this.id, required this.name, required this.type, required this.discount, required this.startDate, required this.endDate, required this.products, required this.active});
}

class _DetailRow extends StatelessWidget {
  final String label, value;
  final bool isDark;
  const _DetailRow({required this.label, required this.value, this.isDark = false});
  @override
  Widget build(BuildContext context) => Padding(
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
