import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/layout/app_sidebar.dart';
import '../../widgets/layout/app_header.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/router/routes.dart';

/// شاشة العروض الذكية
class SmartPromotionsScreen extends ConsumerStatefulWidget {
  const SmartPromotionsScreen({super.key});

  @override
  ConsumerState<SmartPromotionsScreen> createState() => _SmartPromotionsScreenState();
}

class _SmartPromotionsScreenState extends ConsumerState<SmartPromotionsScreen>
    with SingleTickerProviderStateMixin {
  bool _sidebarCollapsed = false;
  String _selectedNavId = 'loyalty';
  late TabController _tabController;

  final List<_Promotion> _activePromotions = [
    _Promotion(id: '1', title: 'عرض نهاية الأسبوع', type: 'percentage', value: 15, status: 'active', startDate: DateTime.now().subtract(const Duration(days: 2)), endDate: DateTime.now().add(const Duration(days: 5)), products: ['حليب طازج', 'جبنة بيضاء'], usageCount: 45),
    _Promotion(id: '2', title: 'اشتري 2 واحصل على 1 مجاناً', type: 'buyXgetY', value: 1, status: 'active', startDate: DateTime.now(), endDate: DateTime.now().add(const Duration(days: 7)), products: ['عصير برتقال'], usageCount: 23),
  ];

  final List<_SuggestedPromotion> _suggestions = [
    _SuggestedPromotion(productName: 'زبادي فواكه', reason: 'حركة بطيئة - 15 يوم بدون بيع', suggestedDiscount: 20, currentStock: 35, expiryDays: 10),
    _SuggestedPromotion(productName: 'لبن رايب', reason: 'قرب انتهاء الصلاحية', suggestedDiscount: 30, currentStock: 20, expiryDays: 3),
    _SuggestedPromotion(productName: 'عصير تفاح', reason: 'مخزون زائد', suggestedDiscount: 15, currentStock: 80, expiryDays: 30),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
                  title: 'العروض الذكية', // TODO: localize
                  onMenuTap: isWideScreen
                      ? () => setState(() => _sidebarCollapsed = !_sidebarCollapsed)
                      : () => Scaffold.of(context).openDrawer(),
                  onNotificationsTap: () => context.push('/notifications'),
                  notificationsCount: 3,
                  userName: 'أحمد محمد',
                  userRole: l10n.branchManager,
                ),
                // Tab bar
                Container(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: isDark ? Colors.white60 : AppColors.textSecondary,
                    indicatorColor: AppColors.primary,
                    tabs: const [
                      Tab(icon: Icon(Icons.lightbulb), text: 'اقتراحات AI'),
                      Tab(icon: Icon(Icons.local_offer), text: 'العروض النشطة'),
                      Tab(icon: Icon(Icons.history), text: 'السجل'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildSuggestionsTab(isMediumScreen, isDark),
                      _buildActiveTab(isMediumScreen, isDark),
                      _buildHistoryTab(isDark),
                    ],
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

  Widget _buildSuggestionsTab(bool isMediumScreen, bool isDark) {
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subtextColor = isDark ? Colors.white70 : AppColors.textSecondary;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
      child: Column(
        children: [
          // AI Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.info.withValues(alpha: 0.15) : AppColors.infoSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.info,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.auto_awesome, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('اقتراحات ذكية', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                      Text('عروض مقترحة بناءً على تحليل المبيعات والمخزون', style: TextStyle(color: subtextColor)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ..._suggestions.map((s) => _buildSuggestionCard(s, isDark)),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(_SuggestedPromotion suggestion, bool isDark) {
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subtextColor = isDark ? Colors.white70 : AppColors.textSecondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(suggestion.productName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${suggestion.suggestedDiscount}% خصم مقترح', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, size: 16, color: AppColors.warning),
              const SizedBox(width: 4),
              Text(suggestion.reason, style: TextStyle(color: subtextColor)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildInfoChip(Icons.inventory, 'المخزون: ${suggestion.currentStock}', null, isDark),
              const SizedBox(width: 8),
              if (suggestion.expiryDays <= 7)
                _buildInfoChip(Icons.timer, 'الصلاحية: ${suggestion.expiryDays} يوم', AppColors.error, isDark),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(onPressed: () {}, child: const Text('تجاهل')),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: () => _applyPromotion(suggestion),
                icon: const Icon(Icons.check, size: 18),
                label: const Text('تطبيق'),
                style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color? color, bool isDark) {
    final chipColor = color ?? (isDark ? Colors.white54 : AppColors.textSecondary);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: chipColor),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: chipColor)),
        ],
      ),
    );
  }

  Widget _buildActiveTab(bool isMediumScreen, bool isDark) {
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subtextColor = isDark ? Colors.white70 : AppColors.textSecondary;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
      child: Column(
        children: _activePromotions.map((p) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
          ),
          child: ListTile(
            onTap: () => _showPromotionDetails(p),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.local_offer, color: AppColors.success),
            ),
            title: Text(p.title, style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
            subtitle: Text('استخدام: ${p.usageCount} مرة', style: TextStyle(color: subtextColor, fontSize: 12)),
            trailing: Icon(Icons.chevron_right, color: subtextColor),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildHistoryTab(bool isDark) {
    final subtextColor = isDark ? Colors.white54 : AppColors.textSecondary;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: subtextColor),
          const SizedBox(height: 16),
          Text('سجل العروض السابقة', style: TextStyle(color: subtextColor)),
        ],
      ),
    );
  }

  void _createPromotion() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('إنشاء عرض جديد', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
              const SizedBox(height: 24),
              ListTile(leading: const Icon(Icons.percent, color: AppColors.secondary), title: const Text('خصم نسبة مئوية'), subtitle: const Text('خصم 10%، 20%، إلخ'), onTap: () => Navigator.pop(context)),
              ListTile(leading: Icon(Icons.card_giftcard, color: AppColors.success), title: const Text('اشتري X واحصل على Y'), subtitle: const Text('اشتري 2 واحصل على 1 مجاناً'), onTap: () => Navigator.pop(context)),
              ListTile(leading: const Icon(Icons.money_off, color: AppColors.info), title: const Text('خصم مبلغ ثابت'), subtitle: const Text('خصم 10 ر.س على المنتج'), onTap: () => Navigator.pop(context)),
            ],
          ),
        ),
      ),
    );
  }

  void _applyPromotion(_SuggestedPromotion suggestion) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم تطبيق العرض على ${suggestion.productName}'), backgroundColor: AppColors.success),
    );
  }

  void _showPromotionDetails(_Promotion promotion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(promotion.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('النوع: ${_getTypeName(promotion.type)}'),
            Text('القيمة: ${promotion.value}'),
            Text('الاستخدام: ${promotion.usageCount} مرة'),
            const SizedBox(height: 8),
            const Text('المنتجات:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...promotion.products.map((p) => Text('- $p')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إغلاق')),
          FilledButton(onPressed: () => Navigator.pop(context), child: const Text('تعديل')),
        ],
      ),
    );
  }

  String _getTypeName(String type) {
    switch (type) {
      case 'percentage': return 'نسبة مئوية';
      case 'buyXgetY': return 'اشتري واحصل';
      case 'fixed': return 'مبلغ ثابت';
      default: return type;
    }
  }
}

class _Promotion {
  final String id, title, type, status;
  final double value;
  final DateTime startDate, endDate;
  final List<String> products;
  final int usageCount;
  _Promotion({required this.id, required this.title, required this.type, required this.value, required this.status, required this.startDate, required this.endDate, required this.products, required this.usageCount});
}

class _SuggestedPromotion {
  final String productName, reason;
  final int suggestedDiscount, currentStock, expiryDays;
  _SuggestedPromotion({required this.productName, required this.reason, required this.suggestedDiscount, required this.currentStock, required this.expiryDays});
}
