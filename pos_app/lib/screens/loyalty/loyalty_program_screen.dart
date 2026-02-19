import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/layout/app_sidebar.dart';
import '../../widgets/layout/app_header.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/router/routes.dart';

/// شاشة برنامج الولاء
class LoyaltyProgramScreen extends ConsumerStatefulWidget {
  const LoyaltyProgramScreen({super.key});

  @override
  ConsumerState<LoyaltyProgramScreen> createState() => _LoyaltyProgramScreenState();
}

class _LoyaltyProgramScreenState extends ConsumerState<LoyaltyProgramScreen>
    with SingleTickerProviderStateMixin {
  bool _sidebarCollapsed = false;
  String _selectedNavId = 'loyalty';
  late TabController _tabController;
  bool _programEnabled = true;
  double _pointsPerRiyal = 1;
  double _redemptionRate = 100;

  final List<_LoyaltyMember> _members = [
    _LoyaltyMember(id: '1', name: 'أحمد محمد', phone: '0501234567', points: 2500, tier: 'gold', totalSpent: 25000, joinDate: DateTime(2024, 1, 15)),
    _LoyaltyMember(id: '2', name: 'خالد عمر', phone: '0551234567', points: 1200, tier: 'silver', totalSpent: 12000, joinDate: DateTime(2024, 3, 20)),
    _LoyaltyMember(id: '3', name: 'محمد علي', phone: '0561234567', points: 450, tier: 'bronze', totalSpent: 4500, joinDate: DateTime(2024, 6, 10)),
  ];

  final List<_Reward> _rewards = [
    _Reward(id: '1', name: 'خصم 10%', pointsCost: 500, type: 'discount'),
    _Reward(id: '2', name: 'خصم 25%', pointsCost: 1000, type: 'discount'),
    _Reward(id: '3', name: 'منتج مجاني', pointsCost: 2000, type: 'freeProduct'),
    _Reward(id: '4', name: 'توصيل مجاني', pointsCost: 300, type: 'freeDelivery'),
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
                  title: l10n.loyaltyProgram,
                  onMenuTap: isWideScreen
                      ? () => setState(() => _sidebarCollapsed = !_sidebarCollapsed)
                      : () => Scaffold.of(context).openDrawer(),
                  onNotificationsTap: () => context.push('/notifications'),
                  notificationsCount: 3,
                  userName: 'أحمد محمد',
                  userRole: l10n.branchManager,
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Switch(
                        value: _programEnabled,
                        onChanged: (v) => setState(() => _programEnabled = v),
                        activeColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                if (_programEnabled) ...[
                  Container(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    child: TabBar(
                      controller: _tabController,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: isDark ? Colors.white60 : AppColors.textSecondary,
                      indicatorColor: AppColors.primary,
                      tabs: const [
                        Tab(text: 'الأعضاء'),
                        Tab(text: 'المكافآت'),
                        Tab(text: 'الإعدادات'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildMembersTab(isMediumScreen, isDark),
                        _buildRewardsTab(isMediumScreen, isDark),
                        _buildSettingsTab(isMediumScreen, isDark),
                      ],
                    ),
                  ),
                ] else
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.loyalty, size: 64, color: isDark ? Colors.white30 : AppColors.textTertiary),
                          const SizedBox(height: 16),
                          Text('برنامج الولاء معطل', style: TextStyle(fontSize: 18, color: isDark ? Colors.white70 : AppColors.textPrimary)),
                          const SizedBox(height: 8),
                          Text('فعّل البرنامج من الزر أعلى الشاشة', style: TextStyle(color: isDark ? Colors.white54 : AppColors.textSecondary)),
                        ],
                      ),
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

  Widget _buildMembersTab(bool isMediumScreen, bool isDark) {
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subtextColor = isDark ? Colors.white70 : AppColors.textSecondary;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
      child: Column(
        children: [
          // Stats
          Row(
            children: [
              Expanded(child: _buildStatCard(Icons.people, 'الأعضاء', '${_members.length}', AppColors.info, isDark)),
              SizedBox(width: isMediumScreen ? 16 : 12),
              Expanded(child: _buildStatCard(Icons.stars, 'ذهبي', '${_members.where((m) => m.tier == "gold").length}', AppColors.warning, isDark)),
              SizedBox(width: isMediumScreen ? 16 : 12),
              Expanded(child: _buildStatCard(Icons.monetization_on, 'إجمالي النقاط', '${_members.fold(0, (sum, m) => sum + m.points)}', AppColors.success, isDark)),
            ],
          ),
          const SizedBox(height: 20),

          // Members
          ..._members.map((member) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: CircleAvatar(
                backgroundColor: _getTierColor(member.tier).withValues(alpha: 0.1),
                child: Icon(Icons.person, color: _getTierColor(member.tier)),
              ),
              title: Row(
                children: [
                  Expanded(child: Text(member.name, style: TextStyle(color: textColor, fontWeight: FontWeight.w500))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getTierColor(member.tier).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(_getTierName(member.tier), style: TextStyle(fontSize: 11, color: _getTierColor(member.tier), fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
              subtitle: Text('${member.points} نقطة - مصروف: ${member.totalSpent.toStringAsFixed(0)} ر.س', style: TextStyle(color: subtextColor, fontSize: 12)),
              trailing: IconButton(
                icon: const Icon(Icons.redeem, color: AppColors.primary),
                tooltip: 'استبدال نقاط',
                onPressed: () => _redeemPoints(member),
              ),
              onTap: () => _showMemberDetails(member),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildRewardsTab(bool isMediumScreen, bool isDark) {
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subtextColor = isDark ? Colors.white70 : AppColors.textSecondary;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FilledButton.icon(
                onPressed: _addReward,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('إضافة مكافأة'),
                style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._rewards.map((reward) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getRewardColor(reward.type).withValues(alpha: 0.1),
                child: Icon(_getRewardIcon(reward.type), color: _getRewardColor(reward.type)),
              ),
              title: Text(reward.name, style: TextStyle(color: textColor)),
              subtitle: Text('${reward.pointsCost} نقطة', style: TextStyle(color: subtextColor, fontSize: 12)),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('تعديل')),
                  const PopupMenuItem(value: 'delete', child: Text('حذف', style: TextStyle(color: AppColors.error))),
                ],
                onSelected: (value) {
                  if (value == 'delete') setState(() => _rewards.remove(reward));
                },
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildSettingsTab(bool isMediumScreen, bool isDark) {
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subtextColor = isDark ? Colors.white70 : AppColors.textSecondary;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('إعدادات النقاط', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                Divider(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
                ListTile(
                  title: Text('نقاط لكل ريال', style: TextStyle(color: textColor)),
                  subtitle: Text('$_pointsPerRiyal نقطة', style: TextStyle(color: subtextColor)),
                  trailing: SizedBox(
                    width: 150,
                    child: Slider(value: _pointsPerRiyal, min: 0.5, max: 5, divisions: 9, label: '$_pointsPerRiyal', onChanged: (v) => setState(() => _pointsPerRiyal = v), activeColor: AppColors.primary),
                  ),
                ),
                ListTile(
                  title: Text('نقاط الاستبدال', style: TextStyle(color: textColor)),
                  subtitle: Text('$_redemptionRate نقطة = 1 ر.س', style: TextStyle(color: subtextColor)),
                  trailing: SizedBox(
                    width: 150,
                    child: Slider(value: _redemptionRate, min: 50, max: 200, divisions: 6, label: '$_redemptionRate', onChanged: (v) => setState(() => _redemptionRate = v), activeColor: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('المستويات', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                Divider(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
                _buildTierRow('برونزي', 0, Colors.brown, isDark),
                _buildTierRow('فضي', 5000, Colors.grey, isDark),
                _buildTierRow('ذهبي', 15000, Colors.amber, isDark),
                _buildTierRow('بلاتيني', 50000, Colors.blueGrey, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierRow(String name, int minSpent, Color color, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(Icons.star, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Text(name, style: TextStyle(fontWeight: FontWeight.w500, color: color)),
          const Spacer(),
          Text('${minSpent.toStringAsFixed(0)}+ ر.س', style: TextStyle(color: isDark ? Colors.white60 : AppColors.textSecondary)),
        ],
      ),
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

  Color _getTierColor(String tier) => {'bronze': Colors.brown, 'silver': Colors.grey, 'gold': Colors.amber, 'platinum': Colors.blueGrey}[tier] ?? Colors.grey;
  String _getTierName(String tier) => {'bronze': 'برونزي', 'silver': 'فضي', 'gold': 'ذهبي', 'platinum': 'بلاتيني'}[tier] ?? tier;
  Color _getRewardColor(String type) => {'discount': AppColors.success, 'freeProduct': AppColors.info, 'freeDelivery': AppColors.secondary}[type] ?? AppColors.textSecondary;
  IconData _getRewardIcon(String type) => {'discount': Icons.discount, 'freeProduct': Icons.card_giftcard, 'freeDelivery': Icons.local_shipping}[type] ?? Icons.redeem;

  void _showMemberDetails(_LoyaltyMember member) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(radius: 40, backgroundColor: _getTierColor(member.tier).withValues(alpha: 0.1), child: Icon(Icons.person, size: 40, color: _getTierColor(member.tier))),
            const SizedBox(height: 16),
            Text(member.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: _getTierColor(member.tier).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
              child: Text(_getTierName(member.tier), style: TextStyle(color: _getTierColor(member.tier), fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(children: [
                  Text('${member.points}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.success)),
                  Text('نقطة', style: TextStyle(color: isDark ? Colors.white70 : AppColors.textSecondary)),
                ]),
                Column(children: [
                  Text(member.totalSpent.toStringAsFixed(0), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.info)),
                  Text('ر.س مصروف', style: TextStyle(color: isDark ? Colors.white70 : AppColors.textSecondary)),
                ]),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () { Navigator.pop(context); _redeemPoints(member); },
              icon: const Icon(Icons.redeem),
              label: const Text('استبدال نقاط'),
              style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 48), backgroundColor: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  void _redeemPoints(_LoyaltyMember member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('استبدال نقاط - ${member.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الرصيد الحالي: ${member.points} نقطة'),
            const SizedBox(height: 16),
            const Text('اختر مكافأة:'),
            const SizedBox(height: 8),
            ..._rewards.where((r) => r.pointsCost <= member.points).map((r) => ListTile(
              leading: Icon(_getRewardIcon(r.type), color: _getRewardColor(r.type)),
              title: Text(r.name),
              subtitle: Text('${r.pointsCost} نقطة'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم استبدال ${r.pointsCost} نقطة بـ ${r.name}')));
              },
            )),
            if (_rewards.where((r) => r.pointsCost <= member.points).isEmpty)
              const Padding(padding: EdgeInsets.all(16), child: Text('لا توجد مكافآت متاحة بهذا الرصيد', style: TextStyle(color: AppColors.textSecondary))),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('إغلاق'))],
      ),
    );
  }

  void _addReward() {
    final nameController = TextEditingController();
    final pointsController = TextEditingController();
    String type = 'discount';
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('إضافة مكافأة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'اسم المكافأة', prefixIcon: Icon(Icons.card_giftcard))),
              const SizedBox(height: 12),
              TextField(controller: pointsController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'النقاط المطلوبة', prefixIcon: Icon(Icons.stars))),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: type,
                decoration: const InputDecoration(labelText: 'النوع', prefixIcon: Icon(Icons.category)),
                items: const [
                  DropdownMenuItem(value: 'discount', child: Text('خصم')),
                  DropdownMenuItem(value: 'freeProduct', child: Text('منتج مجاني')),
                  DropdownMenuItem(value: 'freeDelivery', child: Text('توصيل مجاني')),
                ],
                onChanged: (v) => setDialogState(() => type = v!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            FilledButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && pointsController.text.isNotEmpty) {
                  setState(() => _rewards.add(_Reward(id: 'new_${_rewards.length}', name: nameController.text, pointsCost: int.tryParse(pointsController.text) ?? 100, type: type)));
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

class _LoyaltyMember {
  final String id, name, phone, tier;
  final int points;
  final double totalSpent;
  final DateTime joinDate;
  _LoyaltyMember({required this.id, required this.name, required this.phone, required this.points, required this.tier, required this.totalSpent, required this.joinDate});
}

class _Reward {
  final String id, name, type;
  final int pointsCost;
  _Reward({required this.id, required this.name, required this.pointsCost, required this.type});
}
