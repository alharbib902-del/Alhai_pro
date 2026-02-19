import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';
import '../../widgets/layout/app_header.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../data/local/app_database.dart';
import '../../data/local/daos/loyalty_dao.dart';
import '../../di/injection.dart';
import '../../providers/products_providers.dart';
import '../../widgets/common/app_empty_state.dart';

/// شاشة برنامج الولاء
class LoyaltyProgramScreen extends ConsumerStatefulWidget {
  const LoyaltyProgramScreen({super.key});

  @override
  ConsumerState<LoyaltyProgramScreen> createState() => _LoyaltyProgramScreenState();
}

class _LoyaltyProgramScreenState extends ConsumerState<LoyaltyProgramScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _programEnabled = true;
  double _pointsPerRiyal = 1;
  double _redemptionRate = 100;

  List<LoyaltyPointsTableData> _members = [];
  List<LoyaltyRewardsTableData> _rewards = [];
  LoyaltyStats? _stats;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) return;
      final db = getIt<AppDatabase>();
      final members = await db.loyaltyDao.getAllLoyaltyAccounts(storeId);
      final rewards = await db.loyaltyDao.getAvailableRewards(storeId);
      final stats = await db.loyaltyDao.getStats(storeId);
      if (mounted) {
        setState(() {
          _members = members;
          _rewards = rewards;
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; _error = e.toString(); });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isMediumScreen = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Column(
              children: [
                AppHeader(
                  title: l10n.loyaltyProgram,
                  onMenuTap: isWideScreen
                      ? null
                      : () => Scaffold.of(context).openDrawer(),
                  onNotificationsTap: () => context.push('/notifications'),
                  notificationsCount: 3,
                  userName: l10n.defaultUserName,
                  userRole: l10n.branchManager,
                  actions: [
                    Padding(
                      padding: const EdgeInsetsDirectional.only(start: 8),
                      child: Switch(
                        value: _programEnabled,
                        onChanged: (v) => setState(() => _programEnabled = v),
                        activeThumbColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                if (_error != null)
                  Expanded(child: AppErrorState.general(message: _error, onRetry: _loadData))
                else if (_programEnabled) ...[
                  Container(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    child: TabBar(
                      controller: _tabController,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: isDark ? Colors.white60 : AppColors.textSecondary,
                      indicatorColor: AppColors.primary,
                      tabs: [
                        Tab(text: l10n.loyaltyMembers),
                        Tab(text: l10n.loyaltyRewards),
                        Tab(text: l10n.settings),
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
            );
  }
  Widget _buildMembersTab(bool isMediumScreen, bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subtextColor = isDark ? Colors.white70 : AppColors.textSecondary;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
      child: Column(
        children: [
          // Stats
          Row(
            children: [
              Expanded(child: _buildStatCard(Icons.people, l10n.loyaltyMembers, '${_members.length}', AppColors.info, isDark)),
              SizedBox(width: isMediumScreen ? 16 : 12),
              Expanded(child: _buildStatCard(Icons.stars, 'ذهبي', '${_members.where((m) => m.tierLevel == "gold").length}', AppColors.warning, isDark)),
              SizedBox(width: isMediumScreen ? 16 : 12),
              Expanded(child: _buildStatCard(Icons.monetization_on, l10n.pointsIssued, '${_stats != null ? _stats!.totalEarned : _members.fold<int>(0, (sum, m) => sum + m.currentPoints)}', AppColors.success, isDark)),
            ],
          ),
          const SizedBox(height: 20),

          // Members
          if (_members.isEmpty)
            AppEmptyState.noData(title: 'لا يوجد أعضاء', description: 'سيظهر الأعضاء هنا عند تسجيلهم')
          else
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
                  backgroundColor: _getTierColor(member.tierLevel).withValues(alpha: 0.1),
                  child: Icon(Icons.person, color: _getTierColor(member.tierLevel)),
                ),
                title: Row(
                  children: [
                    Expanded(child: Text(member.customerId, style: TextStyle(color: textColor, fontWeight: FontWeight.w500))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getTierColor(member.tierLevel).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(_getTierName(member.tierLevel), style: TextStyle(fontSize: 11, color: _getTierColor(member.tierLevel), fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
                subtitle: Text('${member.currentPoints} نقطة - مكتسب: ${member.totalEarned} نقطة', style: TextStyle(color: subtextColor, fontSize: 12)),
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
    final l10n = AppLocalizations.of(context)!;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subtextColor = isDark ? Colors.white70 : AppColors.textSecondary;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

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
          if (_rewards.isEmpty)
            AppEmptyState.noData(title: 'لا توجد مكافآت', description: 'أضف مكافآت لبرنامج الولاء')
          else
            ..._rewards.map((reward) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getRewardColor(reward.rewardType).withValues(alpha: 0.1),
                  child: Icon(_getRewardIcon(reward.rewardType), color: _getRewardColor(reward.rewardType)),
                ),
                title: Text(reward.name, style: TextStyle(color: textColor)),
                subtitle: Text('${reward.pointsRequired} نقطة', style: TextStyle(color: subtextColor, fontSize: 12)),
                trailing: PopupMenuButton(
                  itemBuilder: (ctx) => [
                    PopupMenuItem(value: 'edit', child: Text(l10n.edit)),
                    PopupMenuItem(value: 'delete', child: Text(l10n.delete, style: const TextStyle(color: AppColors.error))),
                  ],
                  onSelected: (value) async {
                    if (value == 'delete') {
                      try {
                        final db = getIt<AppDatabase>();
                        await db.loyaltyDao.deactivateReward(reward.id);
                        await _loadData();
                      } catch (_) {}
                    }
                  },
                ),
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildSettingsTab(bool isMediumScreen, bool isDark) {
    final l10n = AppLocalizations.of(context)!;
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
                Text(l10n.loyaltyTiers, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
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
  Color _getRewardColor(String type) => {'discount_percentage': AppColors.success, 'discount_fixed': AppColors.info, 'free_item': AppColors.secondary}[type] ?? AppColors.textSecondary;
  IconData _getRewardIcon(String type) => {'discount_percentage': Icons.discount, 'discount_fixed': Icons.money, 'free_item': Icons.card_giftcard}[type] ?? Icons.redeem;

  void _showMemberDetails(LoyaltyPointsTableData member) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(radius: 40, backgroundColor: _getTierColor(member.tierLevel).withValues(alpha: 0.1), child: Icon(Icons.person, size: 40, color: _getTierColor(member.tierLevel))),
            const SizedBox(height: 16),
            Text(member.customerId, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: _getTierColor(member.tierLevel).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
              child: Text(_getTierName(member.tierLevel), style: TextStyle(color: _getTierColor(member.tierLevel), fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(children: [
                  Text('${member.currentPoints}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.success)),
                  Text('نقطة', style: TextStyle(color: isDark ? Colors.white70 : AppColors.textSecondary)),
                ]),
                Column(children: [
                  Text('${member.totalEarned}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.info)),
                  Text('نقطة مكتسبة', style: TextStyle(color: isDark ? Colors.white70 : AppColors.textSecondary)),
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

  void _redeemPoints(LoyaltyPointsTableData member) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('استبدال نقاط - ${member.customerId}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${l10n.currentBalance}: ${member.currentPoints} نقطة'),
            const SizedBox(height: 16),
            const Text('اختر مكافأة:'),
            const SizedBox(height: 8),
            ..._rewards.where((r) => r.pointsRequired <= member.currentPoints).map((r) => ListTile(
              leading: Icon(_getRewardIcon(r.rewardType), color: _getRewardColor(r.rewardType)),
              title: Text(r.name),
              subtitle: Text('${r.pointsRequired} نقطة'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم استبدال ${r.pointsRequired} نقطة بـ ${r.name}')));
              },
            )),
            if (_rewards.where((r) => r.pointsRequired <= member.currentPoints).isEmpty)
              const Padding(padding: EdgeInsets.all(16), child: Text('لا توجد مكافآت متاحة بهذا الرصيد', style: TextStyle(color: AppColors.textSecondary))),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.close))],
      ),
    );
  }

  void _addReward() {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController();
    final pointsController = TextEditingController();
    String type = 'discount_percentage';
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
                initialValue: type,
                decoration: const InputDecoration(labelText: 'النوع', prefixIcon: Icon(Icons.category)),
                items: [
                  DropdownMenuItem(value: 'discount_percentage', child: Text(l10n.percentageDiscountOption)),
                  DropdownMenuItem(value: 'discount_fixed', child: Text(l10n.fixedDiscountOption)),
                  const DropdownMenuItem(value: 'free_item', child: Text('منتج مجاني')),
                ],
                onChanged: (v) => setDialogState(() => type = v!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
            FilledButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty && pointsController.text.isNotEmpty) {
                  try {
                    final storeId = ref.read(currentStoreIdProvider);
                    if (storeId == null) return;
                    final db = getIt<AppDatabase>();
                    final now = DateTime.now();
                    await db.loyaltyDao.createReward(LoyaltyRewardsTableCompanion(
                      id: Value(const Uuid().v4()),
                      storeId: Value(storeId),
                      name: Value(nameController.text),
                      description: const Value(''),
                      pointsRequired: Value(int.tryParse(pointsController.text) ?? 100),
                      rewardType: Value(type),
                      rewardValue: const Value(10),
                      minPurchase: const Value(0),
                      isActive: const Value(true),
                      createdAt: Value(now),
                    ));
                    await _loadData();
                  } catch (_) {}
                }
                if (!context.mounted) return;
                Navigator.pop(context);
              },
              child: Text(l10n.add),
            ),
          ],
        ),
      ),
    ).then((_) {
      nameController.dispose();
      pointsController.dispose();
    });
  }
}
