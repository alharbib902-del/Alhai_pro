/// الشاشة الرئيسية - Home Screen / Dashboard
///
/// شاشة رئيسية احترافية للويب مع:
/// - ملخص المبيعات والإحصائيات
/// - المبيعات الأخيرة
/// - تنبيهات المخزون
/// - إجراءات سريعة
/// - الوضع المظلم
/// - الإشعارات
/// - اقتراحات AI
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/theme_colors.dart';
import '../../core/router/routes.dart';
import '../../data/local/app_database.dart';
import '../../di/injection.dart';
import '../../providers/auth_providers.dart';
import '../../providers/products_providers.dart';
import '../../providers/theme_provider.dart';
import '../../providers/notifications_provider.dart';
import '../../services/ai_analytics_service.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_badge.dart';
import '../../widgets/common/app_empty_state.dart';

/// الشاشة الرئيسية (Dashboard)
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

  // Mock recent sales
  final List<_RecentSale> _recentSales = [
    const _RecentSale(id: '1234', customer: 'أحمد محمد', amount: 156.50, time: '10:30', method: 'cash'),
    const _RecentSale(id: '1235', customer: 'عميل نقدي', amount: 89.00, time: '10:15', method: 'cash'),
    const _RecentSale(id: '1236', customer: 'فاطمة علي', amount: 234.75, time: '09:45', method: 'card'),
    const _RecentSale(id: '1237', customer: 'عميل نقدي', amount: 45.00, time: '09:30', method: 'cash'),
    const _RecentSale(id: '1238', customer: 'محمد أحمد', amount: 312.00, time: '09:00', method: 'credit'),
  ];

  // Mock low stock items
  final List<_LowStockItem> _lowStockItems = [
    const _LowStockItem(name: 'حليب طازج', quantity: 5, minQuantity: 10),
    const _LowStockItem(name: 'خبز أبيض', quantity: 3, minQuantity: 20),
    const _LowStockItem(name: 'بيض بلدي', quantity: 0, minQuantity: 15),
    const _LowStockItem(name: 'زبادي', quantity: 8, minQuantity: 12),
  ];

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    setState(() => _isLoading = true);
    try {
      final db = getIt<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider);
      final userId = ref.read(currentUserProvider)?.id ?? '';

      if (storeId != null) {
        final total = await db.salesDao.getTodayTotal(storeId, userId);
        final count = await db.salesDao.getTodayCount(storeId, userId);
        final pending = await db.syncQueueDao.getPendingItems();

        // حساب عدد المنتجات النافدة ومنخفضة المخزون
        final outOfStock = _lowStockItems.where((i) => i.quantity <= 0).length;
        final lowStock = _lowStockItems.where((i) => i.quantity > 0).length;

        // الحصول على اقتراحات AI السريعة
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
          _lowStockCount = _lowStockItems.length;
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
    final colors = context.colors;
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'صباح الخير';
    } else if (hour < 17) {
      greeting = 'مساء الخير';
    } else {
      greeting = 'مساء الخير';
    }

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting، ${userName ?? 'المستخدم'} 👋',
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
                _pendingSync > 0 ? '$_pendingSync قيد المزامنة' : 'متصل',
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
          tooltip: 'تحديث',
          variant: AppButtonVariant.soft,
          color: colors.primary,
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    if (_isLoading) {
      return const AppLoadingState(message: 'جاري تحميل الإحصائيات...');
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
              title: 'مبيعات اليوم',
              value: '${_todaySales.toStringAsFixed(0)} ر.س',
              icon: Icons.payments,
              iconColor: AppColors.success,
              change: 12.5,
              changeLabel: 'من الأمس',
            ),
            StatCard(
              title: 'عدد الفواتير',
              value: '$_todayOrders',
              icon: Icons.receipt_long,
              iconColor: AppColors.info,
              change: 8.3,
              changeLabel: 'من الأمس',
            ),
            StatCard(
              title: 'متوسط الفاتورة',
              value: '${_averageOrderValue.toStringAsFixed(0)} ر.س',
              icon: Icons.trending_up,
              iconColor: AppColors.primary,
            ),
            StatCard(
              title: 'تنبيهات المخزون',
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
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flash_on, color: AppColors.secondary, size: 24),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'إجراءات سريعة',
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
            crossAxisCount: 3,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: 1,
            children: [
              _QuickActionTile(
                icon: Icons.point_of_sale,
                label: 'بيع جديد',
                color: AppColors.primary,
                onTap: () => context.push(AppRoutes.pos),
              ),
              _QuickActionTile(
                icon: Icons.qr_code_scanner,
                label: 'مسح سريع',
                color: AppColors.success,
                onTap: () => context.push(AppRoutes.quickSale),
              ),
              _QuickActionTile(
                icon: Icons.person_add,
                label: 'عميل جديد',
                color: AppColors.info,
                onTap: () => context.push(AppRoutes.customers),
              ),
              _QuickActionTile(
                icon: Icons.add_box,
                label: 'منتج جديد',
                color: AppColors.secondary,
                onTap: () => context.push(AppRoutes.products),
              ),
              _QuickActionTile(
                icon: Icons.inventory,
                label: 'جرد',
                color: AppColors.warning,
                onTap: () => context.push(AppRoutes.inventory),
              ),
              _QuickActionTile(
                icon: Icons.bar_chart,
                label: 'التقارير',
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
                  'المبيعات الأخيرة',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => context.push('/invoices'),
                  child: Text(
                    'عرض الكل',
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
          if (_recentSales.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: AppEmptyState.noInvoices(),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentSales.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final sale = _recentSales[index];
                return _RecentSaleTile(sale: sale);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildLowStockSection() {
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
                  'تنبيهات المخزون',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                if (_lowStockItems.isNotEmpty)
                  AppBadge(
                    label: '${_lowStockItems.length}',
                    color: AppColors.warning,
                    variant: AppBadgeVariant.soft,
                    size: AppBadgeSize.small,
                  ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Items List
          if (_lowStockItems.isEmpty)
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
                      'المخزون جيد!',
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
              itemCount: _lowStockItems.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = _lowStockItems[index];
                return _LowStockTile(item: item);
              },
            ),

          // Action Button
          if (_lowStockItems.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: 'إدارة المخزون',
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
    final days = ['الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
    final months = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
    return '${days[now.weekday % 7]}، ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  /// بناء قسم اقتراحات AI
  Widget _buildAiInsightsSection() {
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
                'اقتراحات ذكية',
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
                '${sale.amount.toStringAsFixed(2)} ر.س',
                style: AppTypography.priceSmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              AppBadge.paymentMethod(sale.method),
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
                  'الحد الأدنى: ${item.minQuantity}',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          // Quantity Badge
          AppBadge.stock(item.quantity, minQuantity: item.minQuantity),
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
    final themeState = ref.watch(themeProvider);
    final colors = context.colors;
    final isDark = themeState.isDarkMode ||
        (themeState.isSystemMode &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    return Tooltip(
      message: isDark ? 'الوضع الفاتح' : 'الوضع المظلم',
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
    final notificationsState = ref.watch(notificationsProvider);
    final unreadCount = notificationsState.unreadCount;
    final colors = context.colors;

    return Tooltip(
      message: 'الإشعارات',
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
            Positioned(
              right: 0,
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
                const Text(
                  'الإشعارات',
                  style: AppTypography.titleLarge,
                ),
                const Spacer(),
                if (notificationsState.hasUnread)
                  TextButton(
                    onPressed: () {
                      ref.read(notificationsProvider.notifier).markAllAsRead();
                    },
                    child: Text(
                      'تعيين الكل كمقروء',
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
                          'لا توجد إشعارات',
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
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: AppSpacing.lg),
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
              _formatTime(notification.createdAt),
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

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} د';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} س';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';
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
