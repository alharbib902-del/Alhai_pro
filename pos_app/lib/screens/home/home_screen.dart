/// Home Screen / Dashboard
///
/// Professional web home screen with:
/// - Sales summary and stats
/// - Recent sales
/// - Stock alerts
/// - Quick actions
/// - Dark mode
/// - Notifications
/// - AI suggestions
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/responsive/responsive_utils.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/theme_colors.dart';
import '../../core/router/routes.dart';
import '../../data/local/app_database.dart';
import '../../di/injection.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/auth_providers.dart';
import '../../providers/products_providers.dart';
import '../../providers/shifts_providers.dart';
import '../../providers/theme_provider.dart';
import '../../providers/notifications_provider.dart';
import '../../services/ai_analytics_service.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_badge.dart';
import '../../widgets/common/app_empty_state.dart';

/// Home Screen (Dashboard)
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  double _todaySales = 0;
  final double _yesterdaySales = 0;
  int _todayOrders = 0;
  int _pendingSync = 0;
  int _lowStockCount = 0;
  double _averageOrderValue = 0;
  bool _isLoading = true;
  List<AiInsight> _aiInsights = [];

  List<_RecentSale> _getRecentSales(AppLocalizations l10n) {
    return [
      _RecentSale(id: '1234', customer: l10n.guestCustomer, amount: 156.50, time: '10:30', method: 'cash'),
      _RecentSale(id: '1235', customer: l10n.cashCustomer, amount: 89.00, time: '10:15', method: 'cash'),
      _RecentSale(id: '1236', customer: l10n.guestCustomer, amount: 234.75, time: '09:45', method: 'card'),
      _RecentSale(id: '1237', customer: l10n.cashCustomer, amount: 45.00, time: '09:30', method: 'cash'),
      _RecentSale(id: '1238', customer: l10n.guestCustomer, amount: 312.00, time: '09:00', method: 'credit'),
    ];
  }

  List<_LowStockItem> _getLowStockItems(AppLocalizations l10n) {
    return [
      _LowStockItem(name: l10n.freshMilk, quantity: 5, minQuantity: 10),
      _LowStockItem(name: l10n.whiteBread, quantity: 3, minQuantity: 20),
      _LowStockItem(name: l10n.localEggs, quantity: 0, minQuantity: 15),
      _LowStockItem(name: l10n.yogurt, quantity: 8, minQuantity: 12),
    ];
  }

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    setState(() => _isLoading = true);
    final l10n = AppLocalizations.of(context)!;
    try {
      final db = getIt<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider);
      final userId = ref.read(currentUserProvider)?.id ?? '';

      if (storeId != null) {
        final total = await db.salesDao.getTodayTotal(storeId, userId);
        final count = await db.salesDao.getTodayCount(storeId, userId);
        final pending = await db.syncQueueDao.getPendingItems();

        final lowStockItems = _getLowStockItems(l10n);
        final outOfStock = lowStockItems.where((i) => i.quantity <= 0).length;
        final lowStock = lowStockItems.where((i) => i.quantity > 0).length;

        final insights = AiAnalyticsService.getQuickInsights(
          todaySales: total,
          yesterdaySales: _yesterdaySales,
          lowStockCount: lowStock,
          outOfStockCount: outOfStock,
        );

        setState(() {
          _todaySales = total;
          _todayOrders = count;
          _pendingSync = pending.length;
          _lowStockCount = lowStockItems.length;
          _averageOrderValue = count > 0 ? total / count : 0;
          _aiInsights = insights;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final isDesktop = AppBreakpoints.isDesktop(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: _loadSummary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(isDesktop ? AppSpacing.xxl : AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              _buildWelcomeHeader(user?.name),

              SizedBox(height: isDesktop ? AppSpacing.xxl : AppSpacing.xl),

              // Shift Status Banner
              _ShiftStatusBanner(),

              // Stats Cards
              _buildStatsSection(),

              // AI Insights Section (if available)
              if (_aiInsights.isNotEmpty) ...[
                SizedBox(height: isDesktop ? AppSpacing.xl : AppSpacing.lg),
                _buildAiInsightsSection(),
              ],

              SizedBox(height: isDesktop ? AppSpacing.xxl : AppSpacing.xl),

              // Main Content Row (Desktop: side by side, Mobile: stacked)
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Recent Sales
                    Expanded(
                      flex: 3,
                      child: _buildRecentSalesSection(),
                    ),
                    const SizedBox(width: AppSpacing.xl),
                    // Side Column
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          _buildQuickActionsSection(),
                          const SizedBox(height: AppSpacing.xl),
                          _buildLowStockSection(),
                        ],
                      ),
                    ),
                  ],
                )
              else ...[
                _buildQuickActionsSection(),
                const SizedBox(height: AppSpacing.xl),
                _buildRecentSalesSection(),
                const SizedBox(height: AppSpacing.xl),
                _buildLowStockSection(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(String? userName) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final hour = DateTime.now().hour;
    final name = userName ?? l10n.cashCustomer;
    String greeting;
    if (hour < 12) {
      greeting = l10n.goodMorningName(name);
    } else {
      greeting = l10n.goodEveningName(name);
    }

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: AppTypography.headlineMedium.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                _getFormattedDate(),
                style: AppTypography.bodyLarge.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        // Sync Status
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: _pendingSync > 0
                ? colors.warningSurface
                : colors.successSurface,
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(
              color: _pendingSync > 0 ? colors.warning : colors.success,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _pendingSync > 0 ? Icons.sync : Icons.wifi,
                size: 18,
                color: _pendingSync > 0 ? colors.warning : colors.success,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                _pendingSync > 0 ? l10n.pendingSyncCount(_pendingSync) : l10n.connected,
                style: AppTypography.labelMedium.copyWith(
                  color: _pendingSync > 0 ? colors.warning : colors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: AppSpacing.md),

        // Notifications Button
        _NotificationsButton(),

        const SizedBox(width: AppSpacing.sm),

        // Dark Mode Toggle
        _DarkModeToggle(),

        const SizedBox(width: AppSpacing.sm),

        // Refresh Button
        AppIconButton(
          icon: Icons.refresh,
          onPressed: _loadSummary,
          tooltip: l10n.refresh,
          variant: AppButtonVariant.soft,
          color: colors.primary,
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return AppLoadingState(message: l10n.loading);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;
        final crossAxisCount = isWide ? 4 : 2;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: AppSpacing.lg,
          mainAxisSpacing: AppSpacing.lg,
          childAspectRatio: isWide ? 1.8 : 1.5,
          children: [
            StatCard(
              title: l10n.todaySalesLabel,
              value: '${_todaySales.toStringAsFixed(0)} ${l10n.currency}',
              icon: Icons.payments,
              iconColor: AppColors.success,
              change: 12.5,
              changeLabel: l10n.comparedToYesterday,
            ),
            StatCard(
              title: l10n.totalInvoices,
              value: '$_todayOrders',
              icon: Icons.receipt_long,
              iconColor: AppColors.info,
              change: 8.3,
              changeLabel: l10n.comparedToYesterday,
            ),
            StatCard(
              title: l10n.averageSale,
              value: '${_averageOrderValue.toStringAsFixed(0)} ${l10n.currency}',
              icon: Icons.trending_up,
              iconColor: AppColors.primary,
            ),
            StatCard(
              title: l10n.stockAlertsLabel,
              value: '$_lowStockCount',
              icon: Icons.warning_amber,
              iconColor: _lowStockCount > 0 ? AppColors.warning : AppColors.grey400,
              onTap: () => context.push(AppRoutes.inventory),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActionsSection() {
    final l10n = AppLocalizations.of(context)!;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flash_on, color: AppColors.secondary, size: 24),
              const SizedBox(width: AppSpacing.sm),
              Text(
                l10n.quickActions,
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Quick Actions Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: getResponsiveGridColumns(context, mobile: 2, desktop: 4),
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: 1,
            children: [
              _QuickActionTile(
                icon: Icons.point_of_sale,
                label: l10n.newSale,
                color: AppColors.primary,
                onTap: () => context.push(AppRoutes.pos),
              ),
              _QuickActionTile(
                icon: Icons.qr_code_scanner,
                label: l10n.scanBarcode,
                color: AppColors.success,
                onTap: () => context.push(AppRoutes.quickSale),
              ),
              _QuickActionTile(
                icon: Icons.person_add,
                label: l10n.newCustomer,
                color: AppColors.info,
                onTap: () => context.push(AppRoutes.customers),
              ),
              _QuickActionTile(
                icon: Icons.add_box,
                label: l10n.newProduct,
                color: AppColors.secondary,
                onTap: () => context.push(AppRoutes.products),
              ),
              _QuickActionTile(
                icon: Icons.inventory,
                label: l10n.inventory,
                color: AppColors.warning,
                onTap: () => context.push(AppRoutes.inventory),
              ),
              _QuickActionTile(
                icon: Icons.bar_chart,
                label: l10n.reports,
                color: AppColors.error,
                onTap: () => context.push('/reports'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSalesSection() {
    final l10n = AppLocalizations.of(context)!;
    final recentSales = _getRecentSales(l10n);

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                const Icon(Icons.history, color: AppColors.primary, size: 24),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  l10n.recentTransactions,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => context.push('/invoices'),
                  child: Text(
                    l10n.viewAll,
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Sales List
          if (recentSales.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: AppEmptyState.noInvoices(),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentSales.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final sale = recentSales[index];
                return _RecentSaleTile(sale: sale);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildLowStockSection() {
    final l10n = AppLocalizations.of(context)!;
    final lowStockItems = _getLowStockItems(l10n);

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                const Icon(Icons.warning_amber, color: AppColors.warning, size: 24),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  l10n.stockAlertsLabel,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                if (lowStockItems.isNotEmpty)
                  AppBadge(
                    label: '${lowStockItems.length}',
                    color: AppColors.warning,
                    variant: AppBadgeVariant.soft,
                    size: AppBadgeSize.small,
                  ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Items List
          if (lowStockItems.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 48,
                      color: AppColors.success,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      l10n.stockGood,
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: lowStockItems.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = lowStockItems[index];
                return _LowStockTile(item: item);
              },
            ),

          // Action Button
          if (lowStockItems.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: l10n.manageInventory,
                  icon: Icons.inventory_2,
                  variant: AppButtonVariant.outlined,
                  onPressed: () => context.push(AppRoutes.inventory),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final locale = Localizations.localeOf(context).toString();
    final formatter = DateFormat.yMMMMEEEEd(locale);
    return formatter.format(now);
  }

  /// Build AI insights section
  Widget _buildAiInsightsSection() {
    final l10n = AppLocalizations.of(context)!;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                l10n.aiSuggestions,
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const AppBadge(
                label: 'AI',
                color: AppColors.primary,
                variant: AppBadgeVariant.soft,
                size: AppBadgeSize.small,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: _aiInsights.map((insight) {
              return _AiInsightChip(insight: insight);
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Models
// ============================================================================

class _RecentSale {
  final String id;
  final String customer;
  final double amount;
  final String time;
  final String method;

  const _RecentSale({
    required this.id,
    required this.customer,
    required this.amount,
    required this.time,
    required this.method,
  });
}

class _LowStockItem {
  final String name;
  final int quantity;
  final int minQuantity;

  const _LowStockItem({
    required this.name,
    required this.quantity,
    required this.minQuantity,
  });
}

// ============================================================================
// Sub Widgets
// ============================================================================

class _ShiftStatusBanner extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shiftAsync = ref.watch(openShiftProvider);
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return shiftAsync.when(
      data: (shift) {
        if (shift != null) {
          // Shift is open -- no banner needed
          return const SizedBox.shrink();
        }
        // No open shift -- show warning banner
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: colors.warningSurface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: colors.warning),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: colors.warning, size: 24),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'لا توجد وردية مفتوحة',
                        style: AppTypography.titleSmall.copyWith(
                          color: colors.warning,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        'افتح وردية للبدء باستخدام نقطة البيع',
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.warning,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => context.push(AppRoutes.shiftOpen),
                  icon: const Icon(Icons.login_rounded, size: 18),
                  label: Text(l10n.openShift),
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.warning,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _QuickActionTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_QuickActionTile> createState() => _QuickActionTileState();
}

class _QuickActionTileState extends State<_QuickActionTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: AppDurations.fast,
        decoration: BoxDecoration(
          color: _isHovered
              ? widget.color.withValues(alpha: 0.1)
              : AppColors.grey50,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: _isHovered ? widget.color : AppColors.border,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: AppDurations.fast,
                  width: _isHovered ? 44 : 40,
                  height: _isHovered ? 44 : 40,
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    widget.icon,
                    color: widget.color,
                    size: _isHovered ? 24 : 22,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  widget.label,
                  style: AppTypography.labelSmall.copyWith(
                    color: _isHovered ? widget.color : AppColors.textSecondary,
                    fontWeight: _isHovered ? FontWeight.w600 : FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecentSaleTile extends StatelessWidget {
  final _RecentSale sale;

  const _RecentSaleTile({required this.sale});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          // Invoice Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(
              Icons.receipt,
              color: AppColors.primary,
              size: 22,
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sale.customer,
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Row(
                  children: [
                    Text(
                      '#${sale.id}',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      sale.time,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Amount & Method
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${sale.amount.toStringAsFixed(2)} ${l10n.currency}',
                style: AppTypography.priceSmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              AppBadge.paymentMethod(context, sale.method),
            ],
          ),
        ],
      ),
    );
  }
}

class _LowStockTile extends StatelessWidget {
  final _LowStockItem item;

  const _LowStockTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isOutOfStock = item.quantity <= 0;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          // Warning Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isOutOfStock
                  ? AppColors.errorSurface
                  : AppColors.warningSurface,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              isOutOfStock ? Icons.error : Icons.warning_amber,
              color: isOutOfStock ? AppColors.error : AppColors.warning,
              size: 20,
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  l10n.minQuantityLabel(item.minQuantity),
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          // Quantity Badge
          AppBadge.stock(context, item.quantity, minQuantity: item.minQuantity),
        ],
      ),
    );
  }
}

// ============================================================================
// Dark Mode Toggle
// ============================================================================

class _DarkModeToggle extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final themeState = ref.watch(themeProvider);
    final colors = context.colors;
    final isDark = themeState.isDarkMode ||
        (themeState.isSystemMode &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    return Tooltip(
      message: isDark ? l10n.lightMode : l10n.darkMode,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        decoration: BoxDecoration(
          color: colors.surfaceContainer,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              ref.read(themeProvider.notifier).toggleDarkMode();
            },
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: AnimatedSwitcher(
                duration: AppDurations.fast,
                transitionBuilder: (child, animation) {
                  return RotationTransition(
                    turns: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: Icon(
                  isDark ? Icons.light_mode : Icons.dark_mode,
                  key: ValueKey(isDark),
                  size: 22,
                  color: isDark ? colors.warning : colors.textSecondary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Notifications Button
// ============================================================================

class _NotificationsButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final notificationsState = ref.watch(notificationsProvider);
    final unreadCount = notificationsState.unreadCount;
    final colors = context.colors;

    return Tooltip(
      message: l10n.notifications,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: colors.surfaceContainer,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showNotificationsPanel(context, ref),
                borderRadius: BorderRadius.circular(AppRadius.full),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Icon(
                    unreadCount > 0
                        ? Icons.notifications_active
                        : Icons.notifications_outlined,
                    size: 22,
                    color: unreadCount > 0 ? colors.primary : colors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
          // Badge
          if (unreadCount > 0)
            PositionedDirectional(
              end: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colors.error,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                child: Text(
                  unreadCount > 9 ? '9+' : '$unreadCount',
                  style: AppTypography.badge.copyWith(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showNotificationsPanel(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _NotificationsPanel(),
    );
  }
}

// ============================================================================
// Notifications Panel
// ============================================================================

class _NotificationsPanel extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final notificationsState = ref.watch(notificationsProvider);
    final notifications = notificationsState.notifications;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: AppSpacing.md),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                const Icon(Icons.notifications, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  l10n.notifications,
                  style: AppTypography.titleLarge,
                ),
                const Spacer(),
                if (notificationsState.hasUnread)
                  TextButton(
                    onPressed: () {
                      ref.read(notificationsProvider.notifier).markAllAsRead();
                    },
                    child: Text(
                      l10n.markAllRead,
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Notifications List
          Expanded(
            child: notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.notifications_off,
                          size: 64,
                          color: AppColors.grey300,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          l10n.noNotifications,
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: notifications.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return _NotificationTile(
                        notification: notification,
                        onTap: () {
                          ref
                              .read(notificationsProvider.notifier)
                              .markAsRead(notification.id);
                          if (notification.actionRoute != null) {
                            Navigator.pop(context);
                            context.push(notification.actionRoute!);
                          }
                        },
                        onDismiss: () {
                          ref
                              .read(notificationsProvider.notifier)
                              .deleteNotification(notification.id);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        color: AppColors.error,
        alignment: AlignmentDirectional.centerStart,
        padding: const EdgeInsetsDirectional.only(start: AppSpacing.lg),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: notification.color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(
            notification.icon,
            color: notification.color,
            size: 22,
          ),
        ),
        title: Text(
          notification.title,
          style: AppTypography.titleSmall.copyWith(
            fontWeight: notification.isRead ? FontWeight.w400 : FontWeight.w600,
          ),
        ),
        subtitle: Text(
          notification.message,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatTime(context, notification.createdAt),
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            if (!notification.isRead) ...[
              const SizedBox(height: AppSpacing.xs),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
        tileColor: notification.isRead ? null : AppColors.primarySurface,
      ),
    );
  }

  String _formatTime(BuildContext context, DateTime dateTime) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return l10n.justNow;
    if (diff.inMinutes < 60) return l10n.minutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.hoursAgo(diff.inHours);
    if (diff.inDays < 7) return l10n.daysAgo(diff.inDays);
    return '${dateTime.day}/${dateTime.month}';
  }
}

// ============================================================================
// AI Insight Chip
// ============================================================================

class _AiInsightChip extends StatelessWidget {
  final AiInsight insight;

  const _AiInsightChip({required this.insight});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    switch (insight.priority) {
      case InsightPriority.critical:
        bgColor = AppColors.errorSurface;
        textColor = AppColors.error;
        break;
      case InsightPriority.high:
        bgColor = AppColors.warningSurface;
        textColor = AppColors.warning;
        break;
      case InsightPriority.medium:
        bgColor = AppColors.infoSurface;
        textColor = AppColors.info;
        break;
      case InsightPriority.low:
        bgColor = AppColors.successSurface;
        textColor = AppColors.success;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(insight.emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  insight.title,
                  style: AppTypography.labelMedium.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  insight.description,
                  style: AppTypography.labelSmall.copyWith(
                    color: textColor.withValues(alpha: 0.8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (insight.actionRoute != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: textColor,
            ),
          ],
        ],
      ),
    );
  }
}
