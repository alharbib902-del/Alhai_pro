/// Lite Dashboard Screen
///
/// Main dashboard for the Admin Lite app with:
/// - 4 stat cards: Pending Approvals, Today Sales, Low Stock, Active Shifts
/// - Quick Actions section
/// - Recent Activity feed from audit log
/// Supports RTL, dark mode, and responsive layouts.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';

import '../../providers/lite_dashboard_providers.dart';

/// Lite Dashboard Screen - Admin overview
class LiteDashboardScreen extends ConsumerWidget {
  const LiteDashboardScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(liteStatsProvider);
    ref.invalidate(recentActivityProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final statsAsync = ref.watch(liteStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dashboardTitle),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () => context.go(AppRoutes.notificationsCenter),
            icon: const Icon(Icons.notifications_outlined),
            tooltip: l10n.notifications,
          ),
          const SizedBox(width: AlhaiSpacing.xs),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 900;
            final isMedium = constraints.maxWidth > 600;
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(
                isMedium ? AlhaiSpacing.lg : AlhaiSpacing.md,
              ),
              child: statsAsync.when(
                data: (stats) => _buildContent(
                  context,
                  ref,
                  stats,
                  isWide,
                  isMedium,
                  isDark,
                  l10n,
                ),
                loading: () => _buildSkeleton(isDark),
                error: (error, _) => _buildError(context, ref, isDark, l10n),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    LiteStatsData stats,
    bool isWide,
    bool isMedium,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date subtitle
        Text(
          _getDateSubtitle(l10n),
          style: TextStyle(
            fontSize: 14,
            color: isDark
                ? Colors.white54
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: isMedium ? AlhaiSpacing.mdl : 14),

        // Stat cards
        _buildStatCards(context, stats, isWide, isMedium, isDark, l10n),

        SizedBox(height: isMedium ? AlhaiSpacing.lg : AlhaiSpacing.md),

        // Quick Actions + Recent Activity
        if (isWide)
          _buildWideLayout(context, ref, isDark, l10n)
        else
          _buildNarrowLayout(context, ref, isDark, l10n),
      ],
    );
  }

  // ===========================================================================
  // STAT CARDS
  // ===========================================================================

  Widget _buildStatCards(
    BuildContext context,
    LiteStatsData stats,
    bool isWide,
    bool isMedium,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final cards = [
      _StatCardData(
        title: l10n.pending,
        value: '${stats.pendingApprovals}',
        icon: Icons.approval_rounded,
        color: AlhaiColors.warning,
        onTap: () => context.go('/approvals'),
      ),
      _StatCardData(
        title: l10n.todaySales,
        value: stats.todaySales.toStringAsFixed(0),
        icon: Icons.trending_up_rounded,
        color: AlhaiColors.success,
        change: stats.salesChangePercent,
        onTap: () => context.go(AppRoutes.reports),
      ),
      _StatCardData(
        title: l10n.lowStock,
        value: '${stats.lowStockCount}',
        icon: Icons.inventory_2_outlined,
        color: stats.lowStockCount > 0 ? AlhaiColors.error : AlhaiColors.info,
        onTap: () => context.go(AppRoutes.inventory),
      ),
      _StatCardData(
        title: l10n.shiftsTitle,
        value: '${stats.activeShifts}',
        icon: Icons.access_time_rounded,
        color: AlhaiColors.primary,
        onTap: () => context.go(AppRoutes.shifts),
      ),
    ];

    final spacing = isMedium ? AlhaiSpacing.md : AlhaiSpacing.sm;

    if (isWide) {
      return Row(
        children: cards.asMap().entries.map((entry) {
          return Expanded(
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                end: entry.key < cards.length - 1 ? spacing : 0,
              ),
              child: _buildStatCard(entry.value, isDark, context),
            ),
          );
        }).toList(),
      );
    }

    // Mobile: 2x2 grid
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStatCard(cards[0], isDark, context)),
            SizedBox(width: spacing),
            Expanded(child: _buildStatCard(cards[1], isDark, context)),
          ],
        ),
        SizedBox(height: spacing),
        Row(
          children: [
            Expanded(child: _buildStatCard(cards[2], isDark, context)),
            SizedBox(width: spacing),
            Expanded(child: _buildStatCard(cards[3], isDark, context)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(_StatCardData data, bool isDark, BuildContext context) {
    return InkWell(
      onTap: data.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(AlhaiSpacing.md),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white12
                : Theme.of(context).colorScheme.outlineVariant,
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: data.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(data.icon, color: data.color, size: 20),
                ),
                const Spacer(),
                if (data.change != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: AlhaiSpacing.xxxs,
                    ),
                    decoration: BoxDecoration(
                      color: data.change! >= 0
                          ? AlhaiColors.success.withValues(alpha: 0.1)
                          : AlhaiColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          data.change! >= 0
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: 12,
                          color: data.change! >= 0
                              ? AlhaiColors.success
                              : AlhaiColors.error,
                        ),
                        Text(
                          '${data.change!.abs().toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: data.change! >= 0
                                ? AlhaiColors.success
                                : AlhaiColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AlhaiSpacing.sm),
            Semantics(
              label: data.title,
              value: data.value,
              child: Text(
                data.value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: AlhaiSpacing.xxs),
            Text(
              data.title,
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? Colors.white54
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // LAYOUTS
  // ===========================================================================

  Widget _buildWideLayout(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: _buildRecentActivity(context, ref, isDark, l10n),
        ),
        const SizedBox(width: AlhaiSpacing.lg),
        Expanded(flex: 1, child: _buildQuickActions(context, isDark, l10n)),
      ],
    );
  }

  Widget _buildNarrowLayout(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Column(
      children: [
        _buildQuickActions(context, isDark, l10n),
        const SizedBox(height: AlhaiSpacing.md),
        _buildRecentActivity(context, ref, isDark, l10n),
      ],
    );
  }

  // ===========================================================================
  // QUICK ACTIONS
  // ===========================================================================

  Widget _buildQuickActions(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white12
              : Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.quickActions,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : null,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.md),
          _QuickActionTile(
            icon: Icons.approval_rounded,
            title: l10n.returns,
            color: AlhaiColors.warning,
            isDark: isDark,
            onTap: () => context.go('/approvals'),
          ),
          _QuickActionTile(
            icon: Icons.bar_chart_rounded,
            title: l10n.reports,
            color: AlhaiColors.info,
            isDark: isDark,
            onTap: () => context.go(AppRoutes.reports),
          ),
          _QuickActionTile(
            icon: Icons.inventory_2_outlined,
            title: l10n.inventory,
            color: AlhaiColors.success,
            isDark: isDark,
            onTap: () => context.go(AppRoutes.inventory),
          ),
          _QuickActionTile(
            icon: Icons.access_time_rounded,
            title: l10n.shiftsTitle,
            color: AlhaiColors.primary,
            isDark: isDark,
            onTap: () => context.go(AppRoutes.shifts),
          ),
          _QuickActionTile(
            icon: Icons.auto_awesome_rounded,
            title: l10n.aiAssistant,
            color: AlhaiColors.secondary,
            isDark: isDark,
            onTap: () => context.go(AppRoutes.aiAssistant),
          ),
          _QuickActionTile(
            icon: Icons.settings_outlined,
            title: l10n.settings,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            isDark: isDark,
            onTap: () => context.go(AppRoutes.settings),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // RECENT ACTIVITY
  // ===========================================================================

  Widget _buildRecentActivity(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final activityAsync = ref.watch(recentActivityProvider);

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white12
              : Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.history_rounded,
                size: 20,
                color: isDark
                    ? Colors.white54
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AlhaiSpacing.xs),
              Text(
                l10n.activityLog,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.md),
          activityAsync.when(
            data: (activities) {
              if (activities.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(AlhaiSpacing.lg),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.history_toggle_off,
                          size: 40,
                          color: isDark
                              ? Colors.white24
                              : Theme.of(context).colorScheme.outlineVariant,
                        ),
                        const SizedBox(height: AlhaiSpacing.xs),
                        Text(
                          l10n.noResults,
                          style: TextStyle(
                            color: isDark
                                ? Colors.white38
                                : Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return Column(
                children: activities.take(10).toList().asMap().entries.map((
                  entry,
                ) {
                  final index = entry.key;
                  final activity = entry.value;
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 300 + (index * 50)),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: _ActivityTile(activity: activity, isDark: isDark),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(AlhaiSpacing.lg),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // ERROR STATE
  // ===========================================================================

  Widget _buildError(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AlhaiSpacing.massive),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: isDark
                  ? Colors.white30
                  : Theme.of(context).colorScheme.outlineVariant,
            ),
            const SizedBox(height: AlhaiSpacing.md),
            Text(
              l10n.errorOccurred,
              style: TextStyle(
                color: isDark
                    ? Colors.white54
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AlhaiSpacing.sm),
            TextButton.icon(
              onPressed: () => _refresh(ref),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.tryAgain),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // HELPERS
  // ===========================================================================

  Widget _buildSkeleton(bool isDark) {
    final baseColor = isDark ? Colors.white10 : const Color(0xFFE0E0E0);
    return Padding(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      child: Column(
        children: [
          // Stats row skeleton
          Row(
            children: List.generate(
              3,
              (_) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AlhaiSpacing.xs,
                  ),
                  child: _SkeletonBox(height: 80, baseColor: baseColor),
                ),
              ),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.lg),
          // Activity list skeleton
          ...List.generate(
            5,
            (_) => Padding(
              padding: const EdgeInsets.only(bottom: AlhaiSpacing.sm),
              child: _SkeletonBox(height: 60, baseColor: baseColor),
            ),
          ),
        ],
      ),
    );
  }

  String _getDateSubtitle(AppLocalizations l10n) {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year} \u2022 ${l10n.mainBranch}';
  }
}

// =============================================================================
// STAT CARD DATA
// =============================================================================

class _StatCardData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final double? change;
  final VoidCallback? onTap;

  const _StatCardData({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.change,
    this.onTap,
  });
}

// =============================================================================
// QUICK ACTION TILE
// =============================================================================

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.title,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AlhaiSpacing.xs),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AlhaiSpacing.sm,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.08 : 0.06),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: isDark
                    ? Colors.white24
                    : Theme.of(context).colorScheme.outlineVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// ACTIVITY TILE
// =============================================================================

class _ActivityTile extends StatelessWidget {
  final ActivityEntry activity;
  final bool isDark;

  const _ActivityTile({required this.activity, required this.isDark});

  IconData _getActionIcon(String action) {
    switch (action) {
      case 'login':
        return Icons.login;
      case 'logout':
        return Icons.logout;
      case 'saleCreate':
        return Icons.shopping_cart;
      case 'saleRefund':
        return Icons.receipt_long;
      case 'saleCancel':
        return Icons.cancel_outlined;
      case 'productCreate':
        return Icons.add_box;
      case 'productEdit':
        return Icons.edit;
      case 'priceChange':
        return Icons.attach_money;
      case 'stockAdjust':
        return Icons.inventory;
      case 'shiftOpen':
        return Icons.play_circle_outline;
      case 'shiftClose':
        return Icons.stop_circle_outlined;
      case 'settingsChange':
        return Icons.settings;
      default:
        return Icons.circle;
    }
  }

  Color _getActionColor(String action) {
    switch (action) {
      case 'login':
      case 'logout':
        return AlhaiColors.info;
      case 'saleCreate':
        return AlhaiColors.success;
      case 'saleRefund':
      case 'saleCancel':
        return AlhaiColors.warning;
      case 'productCreate':
      case 'productEdit':
        return AlhaiColors.primary;
      case 'priceChange':
        return AlhaiColors.secondary;
      case 'stockAdjust':
        return Colors.teal;
      case 'shiftOpen':
      case 'shiftClose':
        return AlhaiColors.info;
      case 'settingsChange':
        return AlhaiColors.disabled;
      default:
        return AlhaiColors.disabled;
    }
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final color = _getActionColor(activity.action);

    return Padding(
      padding: const EdgeInsets.only(bottom: AlhaiSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getActionIcon(activity.action),
              size: 16,
              color: color,
            ),
          ),
          const SizedBox(width: AlhaiSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.description ?? activity.action,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AlhaiSpacing.xxxs),
                Text(
                  '${activity.userName} \u2022 ${_formatTime(activity.timestamp)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? Colors.white38
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SKELETON BOX (shimmer loading placeholder)
// =============================================================================

class _SkeletonBox extends StatefulWidget {
  final double height;
  final Color baseColor;
  const _SkeletonBox({required this.height, required this.baseColor});

  @override
  State<_SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<_SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          height: widget.height,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2.0 * _controller.value, 0),
              end: Alignment(-1.0 + 2.0 * _controller.value + 1, 0),
              colors: [
                widget.baseColor,
                widget.baseColor.withValues(alpha: 0.5),
                widget.baseColor,
              ],
            ),
          ),
        );
      },
    );
  }
}
