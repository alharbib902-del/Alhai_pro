import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

// ============================================================================
// LOYALTY TIER MODEL
// ============================================================================

/// نموذج مستوى الولاء
class LoyaltyTierConfig {
  final String id;
  final String name; // الاسم بالعربية  "ذهبي"
  final String nameEn; // الاسم بالإنجليزية "Gold"
  final int minPoints; // الحد الأدنى من النقاط
  final int maxPoints; // الحد الأقصى (-1 يعني غير محدود)
  final double discount; // نسبة الخصم (0.05 = 5%)
  final double multiplier; // مضاعف النقاط (2.0 = ضعف النقاط)
  final Color color; // لون المستوى

  const LoyaltyTierConfig({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.minPoints,
    this.maxPoints = -1,
    required this.discount,
    required this.multiplier,
    required this.color,
  });

  LoyaltyTierConfig copyWith({
    String? name,
    String? nameEn,
    int? minPoints,
    int? maxPoints,
    double? discount,
    double? multiplier,
    Color? color,
  }) {
    return LoyaltyTierConfig(
      id: id,
      name: name ?? this.name,
      nameEn: nameEn ?? this.nameEn,
      minPoints: minPoints ?? this.minPoints,
      maxPoints: maxPoints ?? this.maxPoints,
      discount: discount ?? this.discount,
      multiplier: multiplier ?? this.multiplier,
      color: color ?? this.color,
    );
  }
}

// ============================================================================
// TIER COLORS
// ============================================================================

/// Semantic tier colors as static constants
abstract class LoyaltyTierColors {
  static const Map<String, Color> colors = {
    'bronze': Color(0xFF8D6E63),
    'silver': Color(0xFF757575),
    'gold': Color(0xFFFFA000),
    'platinum': Color(0xFF546E7A),
  };
}

// ============================================================================
// DEFAULT TIERS
// ============================================================================

/// المستويات الافتراضية
final List<LoyaltyTierConfig> _defaultTiers = [
  LoyaltyTierConfig(
    id: 'bronze',
    name: 'برونزي',
    nameEn: 'Bronze',
    minPoints: 0,
    maxPoints: 499,
    discount: 0.0,
    multiplier: 1.0,
    color: LoyaltyTierColors.colors['bronze']!,
  ),
  LoyaltyTierConfig(
    id: 'silver',
    name: 'فضي',
    nameEn: 'Silver',
    minPoints: 500,
    maxPoints: 999,
    discount: 0.03,
    multiplier: 1.5,
    color: LoyaltyTierColors.colors['silver']!,
  ),
  LoyaltyTierConfig(
    id: 'gold',
    name: 'ذهبي',
    nameEn: 'Gold',
    minPoints: 1000,
    maxPoints: 2499,
    discount: 0.05,
    multiplier: 2.0,
    color: LoyaltyTierColors.colors['gold']!,
  ),
  LoyaltyTierConfig(
    id: 'platinum',
    name: 'بلاتيني',
    nameEn: 'Platinum',
    minPoints: 2500,
    maxPoints: -1,
    discount: 0.10,
    multiplier: 3.0,
    color: LoyaltyTierColors.colors['platinum']!,
  ),
];

// ============================================================================
// TIER HELPER
// ============================================================================

/// تحديد مستوى العميل بناء على نقاطه
LoyaltyTierConfig _getTierForPoints(
  int points,
  List<LoyaltyTierConfig> tiers,
) {
  LoyaltyTierConfig result = tiers.first;
  for (final tier in tiers) {
    if (points >= tier.minPoints) result = tier;
  }
  return result;
}

/// Loyalty Program Screen - Admin version
/// Manages loyalty settings, members, rewards, and tier configuration
class LoyaltyProgramScreen extends ConsumerStatefulWidget {
  const LoyaltyProgramScreen({super.key});

  @override
  ConsumerState<LoyaltyProgramScreen> createState() =>
      _LoyaltyProgramScreenState();
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

  // ---------- Tier management ----------
  final List<LoyaltyTierConfig> _tiers = List.from(_defaultTiers);

  @override
  void initState() {
    super.initState();
    // 4 tabs now: Members, Rewards, Tiers, Settings
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
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
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
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
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        AppHeader(
          title: l10n.loyaltyProgram,
          onMenuTap:
              isWideScreen ? null : () => Scaffold.of(context).openDrawer(),
          onNotificationsTap: () => context.push('/notifications'),
          notificationsCount: 0,
          userName: l10n.defaultUserName,
          userRole: l10n.branchManager,
          actions: [
            Padding(
              padding: const EdgeInsetsDirectional.only(start: AlhaiSpacing.xs),
              child: Switch(
                value: _programEnabled,
                onChanged: (v) => setState(() => _programEnabled = v),
                activeTrackColor: AppColors.primary.withValues(alpha: 0.4),
                activeColor: AppColors.primary,
              ),
            ),
          ],
        ),
        if (_error != null)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 64, color: AppColors.error),
                  const SizedBox(height: AlhaiSpacing.md),
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AlhaiSpacing.md),
                  FilledButton.icon(
                    onPressed: _loadData,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: Text(l10n.retry),
                  ),
                ],
              ),
            ),
          )
        else if (_programEnabled) ...[
          Container(
            color: Theme.of(context).colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor:
                  isDark ? Colors.white60 : AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: [
                Tab(text: l10n.loyaltyMembers),
                Tab(text: l10n.loyaltyRewards),
                Tab(text: l10n.loyaltyTiers),
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
                _buildTiersTab(isMediumScreen, isDark),
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
                  Icon(Icons.loyalty,
                      size: 64,
                      color: isDark ? Colors.white30 : AppColors.textTertiary),
                  const SizedBox(height: AlhaiSpacing.md),
                  Text(
                    l10n.loyaltyProgram,
                    style: TextStyle(
                      fontSize: 18,
                      color: isDark ? Colors.white70 : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.xs),
                  Text(
                    l10n.settings,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ===========================================================================
  // MEMBERS TAB
  // ===========================================================================

  Widget _buildMembersTab(bool isMediumScreen, bool isDark) {
    final l10n = AppLocalizations.of(context);
    final cardColor = Theme.of(context).colorScheme.surface;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final subtextColor = Theme.of(context).colorScheme.onSurfaceVariant;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
      child: Column(
        children: [
          // Stats row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  Icons.people,
                  l10n.loyaltyMembers,
                  '${_members.length}',
                  AppColors.info,
                  isDark,
                ),
              ),
              SizedBox(width: isMediumScreen ? 16 : 12),
              Expanded(
                child: _buildStatCard(
                  Icons.stars,
                  l10n.loyaltyTiers,
                  // حساب عدد أعضاء المستوى الذهبي ديناميكياً
                  '${_members.where((m) => _getTierForPoints(m.currentPoints, _tiers).id == 'gold').length}',
                  AppColors.warning,
                  isDark,
                ),
              ),
              SizedBox(width: isMediumScreen ? 16 : 12),
              Expanded(
                child: _buildStatCard(
                  Icons.monetization_on,
                  l10n.pointsIssued,
                  '${_stats != null ? _stats!.totalEarned : _members.fold<int>(0, (sum, m) => sum + m.currentPoints)}',
                  AppColors.success,
                  isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.mdl),

          // Members list
          if (_members.isEmpty)
            AppEmptyState(
              icon: Icons.people_outline,
              title: l10n.loyaltyMembers,
              description: l10n.noTransactions,
            )
          else
            ..._members.map((member) {
              // تحديد المستوى الحقيقي بناءً على النقاط الحالية
              final memberTier =
                  _getTierForPoints(member.currentPoints, _tiers);
              return Container(
                margin: const EdgeInsets.only(bottom: AlhaiSpacing.sm),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: CircleAvatar(
                    backgroundColor: memberTier.color.withValues(alpha: 0.1),
                    child: Icon(Icons.person, color: memberTier.color),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          member.customerId,
                          style: TextStyle(
                              color: textColor, fontWeight: FontWeight.w500),
                        ),
                      ),
                      // شارة المستوى الديناميكية
                      _buildTierBadge(memberTier),
                    ],
                  ),
                  subtitle: Text(
                    '${member.currentPoints} ${l10n.pointsIssued}'
                    ' · ${l10n.loyaltyTiers}: ${memberTier.name}',
                    style: TextStyle(color: subtextColor, fontSize: 12),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.redeem, color: AppColors.primary),
                    onPressed: () => _redeemPoints(member),
                  ),
                  onTap: () => _showMemberDetails(member),
                ),
              );
            }),
        ],
      ),
    );
  }

  // ===========================================================================
  // REWARDS TAB
  // ===========================================================================

  Widget _buildRewardsTab(bool isMediumScreen, bool isDark) {
    final l10n = AppLocalizations.of(context);
    final cardColor = Theme.of(context).colorScheme.surface;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final subtextColor = Theme.of(context).colorScheme.onSurfaceVariant;

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
                label: Text(l10n.add),
                style:
                    FilledButton.styleFrom(backgroundColor: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.md),
          if (_rewards.isEmpty)
            AppEmptyState(
              icon: Icons.card_giftcard,
              title: l10n.loyaltyRewards,
              description: l10n.noTransactions,
            )
          else
            ..._rewards.map((reward) => Container(
                  margin: const EdgeInsets.only(bottom: AlhaiSpacing.sm),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getRewardColor(reward.rewardType)
                          .withValues(alpha: 0.1),
                      child: Icon(_getRewardIcon(reward.rewardType),
                          color: _getRewardColor(reward.rewardType)),
                    ),
                    title:
                        Text(reward.name, style: TextStyle(color: textColor)),
                    subtitle: Text(
                      '${reward.pointsRequired} ${l10n.pointsIssued}',
                      style: TextStyle(color: subtextColor, fontSize: 12),
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (ctx) => [
                        PopupMenuItem(value: 'edit', child: Text(l10n.edit)),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text(l10n.delete,
                              style: const TextStyle(color: AppColors.error)),
                        ),
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

  // ===========================================================================
  // TIERS TAB (NEW)
  // ===========================================================================

  Widget _buildTiersTab(bool isMediumScreen, bool isDark) {
    final l10n = AppLocalizations.of(context);
    final cardColor = Theme.of(context).colorScheme.surface;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final subtextColor = Theme.of(context).colorScheme.onSurfaceVariant;
    final dividerColor = Theme.of(context).dividerColor;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsetsDirectional.fromSTEB(
            isMediumScreen ? 24 : 16,
            isMediumScreen ? 24 : 16,
            isMediumScreen ? 24 : 16,
            80, // extra padding for FAB
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header description
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: AppColors.primary, size: 18),
                    const SizedBox(width: AlhaiSpacing.xs),
                    Expanded(
                      child: Text(
                        l10n.loyaltyTierCustomizeHint,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AlhaiSpacing.mdl),

              // Tier cards
              ..._tiers.asMap().entries.map((entry) {
                final index = entry.key;
                final tier = entry.value;
                final memberCount = _members
                    .where((m) =>
                        _getTierForPoints(m.currentPoints, _tiers).id ==
                        tier.id)
                    .length;

                return Container(
                  margin: const EdgeInsets.only(bottom: AlhaiSpacing.md),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: tier.color.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: tier.color.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Tier header
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: tier.color.withValues(alpha: 0.1),
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(14)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: tier.color.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.star_rounded,
                                  color: tier.color, size: 22),
                            ),
                            const SizedBox(width: AlhaiSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tier.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: tier.color,
                                    ),
                                  ),
                                  Text(
                                    tier.nameEn,
                                    style: TextStyle(
                                        fontSize: 12, color: subtextColor),
                                  ),
                                ],
                              ),
                            ),
                            // عدد الأعضاء في هذا المستوى
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: tier.color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                l10n.memberCount(memberCount),
                                style: TextStyle(
                                    fontSize: 12,
                                    color: tier.color,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(width: AlhaiSpacing.xs),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 20),
                              color: tier.color,
                              onPressed: () =>
                                  _showEditTierDialog(index, tier, isDark),
                              tooltip: l10n.edit,
                            ),
                          ],
                        ),
                      ),

                      // Tier details
                      Padding(
                        padding: const EdgeInsets.all(AlhaiSpacing.md),
                        child: Column(
                          children: [
                            // النقاط المطلوبة
                            _buildTierDetailRow(
                              icon: Icons.star_border_rounded,
                              label: l10n.pointsRequired,
                              value: tier.maxPoints == -1
                                  ? '${tier.minPoints}+ ${l10n.pointsUnit}'
                                  : '${tier.minPoints} - ${tier.maxPoints} ${l10n.pointsUnit}',
                              color: tier.color,
                              textColor: textColor,
                              subtextColor: subtextColor,
                            ),
                            Divider(color: dividerColor, height: 20),
                            // نسبة الخصم
                            _buildTierDetailRow(
                              icon: Icons.discount_outlined,
                              label: l10n.discountPercentage,
                              value:
                                  '${(tier.discount * 100).toStringAsFixed(0)}%',
                              color: tier.discount > 0
                                  ? AppColors.success
                                  : subtextColor,
                              textColor: textColor,
                              subtextColor: subtextColor,
                            ),
                            Divider(color: dividerColor, height: 20),
                            // مضاعف النقاط
                            _buildTierDetailRow(
                              icon: Icons.multiple_stop_rounded,
                              label: l10n.pointsMultiplier,
                              value: '${tier.multiplier}x',
                              color: AppColors.info,
                              textColor: textColor,
                              subtextColor: subtextColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),

        // FAB: إضافة مستوى
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Center(
            child: FloatingActionButton.extended(
              onPressed: () => _showAddTierDialog(isDark),
              backgroundColor: AppColors.primary,
              icon: Icon(Icons.add,
                  color: Theme.of(context).colorScheme.onPrimary),
              label: Text(
                l10n.addTier,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onPrimary),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// صف تفاصيل المستوى
  Widget _buildTierDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color textColor,
    required Color subtextColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: AlhaiSpacing.xs),
        Text(label, style: TextStyle(color: subtextColor, fontSize: 13)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // SETTINGS TAB
  // ===========================================================================

  Widget _buildSettingsTab(bool isMediumScreen, bool isDark) {
    final l10n = AppLocalizations.of(context);
    final cardColor = Theme.of(context).colorScheme.surface;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final subtextColor = Theme.of(context).colorScheme.onSurfaceVariant;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AlhaiSpacing.md),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).dividerColor,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.settings,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: textColor)),
                Divider(color: Theme.of(context).dividerColor),
                ListTile(
                  title: Text(l10n.pointsIssued,
                      style: TextStyle(color: textColor)),
                  subtitle: Text('$_pointsPerRiyal',
                      style: TextStyle(color: subtextColor)),
                  trailing: ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width > 600
                            ? 150
                            : 100),
                    child: Slider(
                      value: _pointsPerRiyal,
                      min: 0.5,
                      max: 5,
                      divisions: 9,
                      label: '$_pointsPerRiyal',
                      onChanged: (v) => setState(() => _pointsPerRiyal = v),
                      activeColor: AppColors.primary,
                    ),
                  ),
                ),
                ListTile(
                  title: Text(l10n.loyaltyRewards,
                      style: TextStyle(color: textColor)),
                  subtitle: Text('$_redemptionRate ${l10n.sar}',
                      style: TextStyle(color: subtextColor)),
                  trailing: ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width > 600
                            ? 150
                            : 100),
                    child: Slider(
                      value: _redemptionRate,
                      min: 50,
                      max: 200,
                      divisions: 6,
                      label: '$_redemptionRate',
                      onChanged: (v) => setState(() => _redemptionRate = v),
                      activeColor: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AlhaiSpacing.md),
          // عرض ملخص المستويات في إعدادات (للاطلاع فقط)
          Container(
            padding: const EdgeInsets.all(AlhaiSpacing.md),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).dividerColor,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.loyaltyTiers,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: textColor)),
                Divider(color: Theme.of(context).dividerColor),
                ..._tiers.map((tier) => _buildTierRow(tier, isDark)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // COMMON WIDGETS
  // ===========================================================================

  /// شارة المستوى
  Widget _buildTierBadge(LoyaltyTierConfig tier) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: tier.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: tier.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 12, color: tier.color),
          const SizedBox(width: 3),
          Text(
            tier.name,
            style: TextStyle(
              fontSize: 11,
              color: tier.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierRow(LoyaltyTierConfig tier, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xs),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
                color: tier.color.withValues(alpha: 0.1),
                shape: BoxShape.circle),
            child: Icon(Icons.star, color: tier.color, size: 18),
          ),
          const SizedBox(width: AlhaiSpacing.sm),
          Text(tier.name,
              style: TextStyle(fontWeight: FontWeight.w500, color: tier.color)),
          const SizedBox(width: AlhaiSpacing.xxs),
          Text(
            '(${tier.nameEn})',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Text(
            tier.maxPoints == -1
                ? '${tier.minPoints}+'
                : '${tier.minPoints}-${tier.maxPoints}',
            style: TextStyle(
              color: isDark ? Colors.white60 : AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: AlhaiSpacing.xs),
          Text(
            '${(tier.discount * 100).toStringAsFixed(0)}%',
            style: TextStyle(
              color:
                  tier.discount > 0 ? AppColors.success : AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      IconData icon, String label, String value, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AlhaiSpacing.xs),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: color, fontSize: 20)),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  // ===========================================================================
  // TIER DIALOGS
  // ===========================================================================

  /// نافذة تعديل مستوى موجود
  void _showEditTierDialog(int index, LoyaltyTierConfig tier, bool isDark) {
    final l10n = AppLocalizations.of(context);
    final nameController = TextEditingController(text: tier.name);
    final nameEnController = TextEditingController(text: tier.nameEn);
    final minPointsController =
        TextEditingController(text: tier.minPoints.toString());
    final maxPointsController = TextEditingController(
        text: tier.maxPoints == -1 ? '' : tier.maxPoints.toString());
    double discount = tier.discount;
    double multiplier = tier.multiplier;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.star_rounded, color: tier.color, size: 20),
              const SizedBox(width: AlhaiSpacing.xs),
              Text('${l10n.edit}: ${tier.name}'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: l10n.nameArabic,
                    prefixIcon: const Icon(Icons.translate),
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.sm),
                TextField(
                  controller: nameEnController,
                  decoration: InputDecoration(
                    labelText: 'Name (English)',
                    prefixIcon: const Icon(Icons.translate),
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.sm),
                TextField(
                  controller: minPointsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.minPoints,
                    prefixIcon: const Icon(Icons.star_border),
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.sm),
                TextField(
                  controller: maxPointsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.maxPointsHint,
                    prefixIcon: const Icon(Icons.star),
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.md),
                Row(
                  children: [
                    const Icon(Icons.discount_outlined,
                        size: 18, color: AppColors.success),
                    const SizedBox(width: AlhaiSpacing.xs),
                    Text(l10n
                        .discountLabel((discount * 100).toStringAsFixed(0))),
                  ],
                ),
                Slider(
                  value: discount,
                  min: 0,
                  max: 0.30,
                  divisions: 30,
                  label: '${(discount * 100).toStringAsFixed(0)}%',
                  onChanged: (v) => setDialogState(() => discount = v),
                  activeColor: AppColors.success,
                ),
                const SizedBox(height: AlhaiSpacing.xs),
                Row(
                  children: [
                    const Icon(Icons.multiple_stop_rounded,
                        size: 18, color: AppColors.info),
                    const SizedBox(width: AlhaiSpacing.xs),
                    Text(l10n.multiplierLabel(multiplier.toStringAsFixed(1))),
                  ],
                ),
                Slider(
                  value: multiplier,
                  min: 1.0,
                  max: 5.0,
                  divisions: 8,
                  label: '${multiplier.toStringAsFixed(1)}x',
                  onChanged: (v) => setDialogState(() => multiplier = v),
                  activeColor: AppColors.info,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel)),
            FilledButton(
              onPressed: () {
                final minPts =
                    int.tryParse(minPointsController.text) ?? tier.minPoints;
                final maxPts = maxPointsController.text.isEmpty
                    ? -1
                    : int.tryParse(maxPointsController.text) ?? tier.maxPoints;
                setState(() {
                  _tiers[index] = tier.copyWith(
                    name: nameController.text.isNotEmpty
                        ? nameController.text
                        : tier.name,
                    nameEn: nameEnController.text.isNotEmpty
                        ? nameEnController.text
                        : tier.nameEn,
                    minPoints: minPts,
                    maxPoints: maxPts,
                    discount: discount,
                    multiplier: multiplier,
                  );
                });
                Navigator.pop(context);
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    ).then((_) {
      nameController.dispose();
      nameEnController.dispose();
      minPointsController.dispose();
      maxPointsController.dispose();
    });
  }

  /// نافذة إضافة مستوى جديد
  void _showAddTierDialog(bool isDark) {
    final l10n = AppLocalizations.of(context);
    final nameController = TextEditingController();
    final nameEnController = TextEditingController();
    final minPointsController = TextEditingController();
    final maxPointsController = TextEditingController();
    double discount = 0.0;
    double multiplier = 1.0;
    Color selectedColor = Colors.purple;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.addNewTier),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: l10n.nameArabic,
                    prefixIcon: const Icon(Icons.translate),
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.sm),
                TextField(
                  controller: nameEnController,
                  decoration: const InputDecoration(
                    labelText: 'Name (English)',
                    prefixIcon: Icon(Icons.translate),
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.sm),
                TextField(
                  controller: minPointsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.minPoints,
                    prefixIcon: const Icon(Icons.star_border),
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.sm),
                TextField(
                  controller: maxPointsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.maxPointsHint,
                    prefixIcon: const Icon(Icons.star),
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.md),
                // Color picker (simple)
                Wrap(
                  spacing: 8,
                  children: [
                    Colors.purple,
                    Colors.teal,
                    Colors.indigo,
                    Colors.deepOrange,
                    Colors.cyan,
                  ]
                      .map((color) => GestureDetector(
                            onTap: () =>
                                setDialogState(() => selectedColor = color),
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: selectedColor == color
                                    ? Border.all(color: Colors.white, width: 3)
                                    : null,
                              ),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: AlhaiSpacing.md),
                Row(
                  children: [
                    const Icon(Icons.discount_outlined,
                        size: 18, color: AppColors.success),
                    const SizedBox(width: AlhaiSpacing.xs),
                    Text(l10n
                        .discountLabel((discount * 100).toStringAsFixed(0))),
                  ],
                ),
                Slider(
                  value: discount,
                  min: 0,
                  max: 0.30,
                  divisions: 30,
                  label: '${(discount * 100).toStringAsFixed(0)}%',
                  onChanged: (v) => setDialogState(() => discount = v),
                  activeColor: AppColors.success,
                ),
                const SizedBox(height: AlhaiSpacing.xs),
                Row(
                  children: [
                    const Icon(Icons.multiple_stop_rounded,
                        size: 18, color: AppColors.info),
                    const SizedBox(width: AlhaiSpacing.xs),
                    Text(l10n.multiplierLabel(multiplier.toStringAsFixed(1))),
                  ],
                ),
                Slider(
                  value: multiplier,
                  min: 1.0,
                  max: 5.0,
                  divisions: 8,
                  label: '${multiplier.toStringAsFixed(1)}x',
                  onChanged: (v) => setDialogState(() => multiplier = v),
                  activeColor: AppColors.info,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel)),
            FilledButton(
              onPressed: () {
                if (nameController.text.isEmpty) return;
                final minPts = int.tryParse(minPointsController.text) ?? 0;
                final maxPts = maxPointsController.text.isEmpty
                    ? -1
                    : int.tryParse(maxPointsController.text) ?? -1;
                setState(() {
                  _tiers.add(LoyaltyTierConfig(
                    id: 'tier_${DateTime.now().millisecondsSinceEpoch}',
                    name: nameController.text,
                    nameEn: nameEnController.text.isEmpty
                        ? nameController.text
                        : nameEnController.text,
                    minPoints: minPts,
                    maxPoints: maxPts,
                    discount: discount,
                    multiplier: multiplier,
                    color: selectedColor,
                  ));
                  // ترتيب المستويات حسب الحد الأدنى
                  _tiers.sort((a, b) => a.minPoints.compareTo(b.minPoints));
                });
                Navigator.pop(context);
              },
              child: Text(l10n.add),
            ),
          ],
        ),
      ),
    ).then((_) {
      nameController.dispose();
      nameEnController.dispose();
      minPointsController.dispose();
      maxPointsController.dispose();
    });
  }

  // ===========================================================================
  // HELPERS
  // ===========================================================================

  Color _getRewardColor(String type) =>
      {
        'discount_percentage': AppColors.success,
        'discount_fixed': AppColors.info,
        'free_item': AppColors.secondary,
      }[type] ??
      AppColors.textSecondary;

  IconData _getRewardIcon(String type) =>
      {
        'discount_percentage': Icons.discount,
        'discount_fixed': Icons.money,
        'free_item': Icons.card_giftcard,
      }[type] ??
      Icons.redeem;

  // ===========================================================================
  // MEMBER DETAILS
  // ===========================================================================

  void _showMemberDetails(LoyaltyPointsTableData member) {
    final l10n = AppLocalizations.of(context);
    final memberTier = _getTierForPoints(member.currentPoints, _tiers);

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AlhaiSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: memberTier.color.withValues(alpha: 0.1),
              child: Icon(Icons.person, size: 40, color: memberTier.color),
            ),
            const SizedBox(height: AlhaiSpacing.md),
            Text(
              member.customerId,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            // شارة المستوى الديناميكية
            const SizedBox(height: AlhaiSpacing.xs),
            _buildTierBadge(memberTier),
            const SizedBox(height: AlhaiSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(children: [
                  Text('${member.currentPoints}',
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success)),
                  Text(l10n.pointsIssued,
                      style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant)),
                ]),
                Column(children: [
                  Text('${member.totalEarned}',
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.info)),
                  Text(l10n.totalDebit,
                      style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant)),
                ]),
              ],
            ),
            const SizedBox(height: AlhaiSpacing.md),
            // مزايا المستوى الحالي
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AlhaiSpacing.sm),
              decoration: BoxDecoration(
                color: memberTier.color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.tierBenefits(memberTier.name),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: memberTier.color,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.discountOnPurchases(
                        (memberTier.discount * 100).toStringAsFixed(0)),
                    style: const TextStyle(fontSize: 13),
                  ),
                  Text(
                    l10n.pointsPerPurchase('${memberTier.multiplier}'),
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AlhaiSpacing.md),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _redeemPoints(member);
              },
              icon: const Icon(Icons.redeem),
              label: Text(l10n.loyaltyRewards),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _redeemPoints(LoyaltyPointsTableData member) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${l10n.loyaltyRewards} - ${member.customerId}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                '${l10n.balanceCol}: ${member.currentPoints} ${l10n.pointsIssued}'),
            const SizedBox(height: AlhaiSpacing.md),
            Text(l10n.loyaltyRewards),
            const SizedBox(height: AlhaiSpacing.xs),
            ..._rewards
                .where((r) => r.pointsRequired <= member.currentPoints)
                .map((r) => ListTile(
                      leading: Icon(_getRewardIcon(r.rewardType),
                          color: _getRewardColor(r.rewardType)),
                      title: Text(r.name),
                      subtitle:
                          Text('${r.pointsRequired} ${l10n.pointsIssued}'),
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                '${r.pointsRequired} ${l10n.pointsIssued} - ${r.name}'),
                          ),
                        );
                      },
                    )),
            if (_rewards
                .where((r) => r.pointsRequired <= member.currentPoints)
                .isEmpty)
              Padding(
                padding: const EdgeInsets.all(AlhaiSpacing.md),
                child: Text(
                  l10n.noTransactions,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text(l10n.close)),
        ],
      ),
    );
  }

  void _addReward() {
    final l10n = AppLocalizations.of(context);
    final nameController = TextEditingController();
    final pointsController = TextEditingController();
    String type = 'discount_percentage';
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.add),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: l10n.loyaltyRewards,
                  prefixIcon: const Icon(Icons.card_giftcard),
                ),
              ),
              const SizedBox(height: AlhaiSpacing.sm),
              TextField(
                controller: pointsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.pointsIssued,
                  prefixIcon: const Icon(Icons.stars),
                ),
              ),
              const SizedBox(height: AlhaiSpacing.sm),
              DropdownButtonFormField<String>(
                value: type,
                decoration: InputDecoration(
                  labelText: l10n.type,
                  prefixIcon: const Icon(Icons.category),
                ),
                items: [
                  DropdownMenuItem(
                      value: 'discount_percentage',
                      child: Text(l10n.percentageDiscountOption)),
                  DropdownMenuItem(
                      value: 'discount_fixed',
                      child: Text(l10n.fixedDiscountOption)),
                  DropdownMenuItem(
                      value: 'free_item', child: Text(l10n.loyaltyRewards)),
                ],
                onChanged: (v) => setDialogState(() => type = v!),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel)),
            FilledButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    pointsController.text.isNotEmpty) {
                  try {
                    final storeId = ref.read(currentStoreIdProvider);
                    if (storeId == null) return;
                    final db = getIt<AppDatabase>();
                    final now = DateTime.now();
                    await db.loyaltyDao
                        .createReward(LoyaltyRewardsTableCompanion(
                      id: Value(const Uuid().v4()),
                      storeId: Value(storeId),
                      name: Value(nameController.text),
                      description: const Value(''),
                      pointsRequired:
                          Value(int.tryParse(pointsController.text) ?? 100),
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
