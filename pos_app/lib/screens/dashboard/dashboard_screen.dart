import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/products_providers.dart';
import '../../data/local/app_database.dart';
import '../../di/injection.dart';
import '../../widgets/layout/app_sidebar.dart';
import '../../widgets/layout/app_header.dart';
import '../../widgets/dashboard/stat_card.dart';
import '../../widgets/dashboard/sales_chart.dart';
import '../../widgets/dashboard/elegant_quick_actions.dart';
import '../../widgets/dashboard/recent_transactions.dart';

/// لوحة التحكم الرئيسية بالتصميم الجديد
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  // البيانات
  double _todaySales = 0;
  int _todayOrders = 0;
  int _lowStockCount = 0;
  int _newCustomers = 0;
  bool _isLoading = true;
  List<SalesTableData> _recentSales = [];

  // حالة الـ UI
  bool _sidebarCollapsed = false;
  String _selectedNavId = 'dashboard';

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      final db = getIt<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider);
      const userId = '';

      if (storeId != null) {
        final total = await db.salesDao.getTodayTotal(storeId, userId);
        final count = await db.salesDao.getTodayCount(storeId, userId);
        final lowStock = await db.productsDao.getLowStockProducts(storeId);
        final today = DateTime.now();
        final recent = await db.salesDao.getSalesByDate(storeId, today);

        setState(() {
          _todaySales = total;
          _todayOrders = count;
          _lowStockCount = lowStock.length;
          _newCustomers = 12;
          _recentSales = recent.take(5).toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _handleNavigation(AppSidebarItem item) {
    setState(() => _selectedNavId = item.id);

    switch (item.id) {
      case 'dashboard':
        break;
      case 'pos':
        context.go(AppRoutes.pos);
        break;
      case 'products':
        context.push(AppRoutes.products);
        break;
      case 'categories':
        context.push(AppRoutes.categories);
        break;
      case 'inventory':
        context.push(AppRoutes.inventory);
        break;
      case 'customers':
        context.push(AppRoutes.customers);
        break;
      case 'sales':
        context.push(AppRoutes.invoices);
        break;
      case 'returns':
        context.push(AppRoutes.returns);
        break;
      case 'orders':
        context.push(AppRoutes.orders);
        break;
      case 'void-transaction':
        context.push(AppRoutes.voidTransaction);
        break;
      case 'reports':
        context.push('/reports');
        break;
      case 'employees':
        context.push('/employees');
        break;
      case 'loyalty':
        context.push('/loyalty');
        break;
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
                  title: l10n.dashboardTitle,
                  subtitle: _getDateSubtitle(l10n),
                  showSearch: isWideScreen,
                  searchHint: l10n.searchPlaceholder,
                  onMenuTap: isWideScreen
                      ? () => setState(() => _sidebarCollapsed = !_sidebarCollapsed)
                      : () => Scaffold.of(context).openDrawer(),
                  onNotificationsTap: () => context.push('/notifications'),
                  notificationsCount: 3,
                  userName: 'أحمد محمد',
                  userRole: l10n.branchManager,
                  onUserTap: () {},
                ),

                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadDashboardData,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
                      child: _buildContent(isWideScreen, isMediumScreen, l10n),
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
        onItemTap: (item) {
          Navigator.pop(context);
          _handleNavigation(item);
        },
        onSettingsTap: () {
          Navigator.pop(context);
          context.push(AppRoutes.settings);
        },
        onSupportTap: () => Navigator.pop(context),
        onLogoutTap: () {
          Navigator.pop(context);
          context.go('/login');
        },
        userName: 'أحمد محمد',
        userRole: l10n.branchManager,
        onUserTap: () {},
      ),
    );
  }

  /// المحتوى الرئيسي
  Widget _buildContent(bool isWideScreen, bool isMediumScreen, AppLocalizations l10n) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(64),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // كروت الإحصائيات
        _buildStatsSection(isWideScreen, isMediumScreen, l10n),

        SizedBox(height: isMediumScreen ? 24 : 16),

        // الرسم البياني + الإجراءات السريعة + الأكثر مبيعاً
        if (isWideScreen)
          _buildMainRow(l10n)
        else
          _buildMainColumn(l10n),

        SizedBox(height: isMediumScreen ? 24 : 16),

        // أحدث العمليات
        _buildRecentTransactions(l10n),
      ],
    );
  }

  /// قسم الإحصائيات - باستخدام Row/Column بدلاً من GridView لإصلاح الـ overflow
  Widget _buildStatsSection(bool isWideScreen, bool isMediumScreen, AppLocalizations l10n) {
    final cards = [
      DefaultStatCards.todaySales(
        l10n: l10n,
        value: _todaySales.toStringAsFixed(0),
        change: 12.5,
        onTap: () => context.push('/sales'),
      ),
      DefaultStatCards.ordersCount(
        l10n: l10n,
        value: '$_todayOrders',
        change: 5.2,
        onTap: () => context.push('/sales'),
      ),
      DefaultStatCards.newCustomers(
        l10n: l10n,
        value: '$_newCustomers',
        change: 0,
        onTap: () => context.push(AppRoutes.customers),
      ),
      DefaultStatCards.lowStock(
        l10n: l10n,
        value: '$_lowStockCount',
        alertIncrease: 2,
        onTap: () => context.push(AppRoutes.inventory),
      ),
    ];

    final spacing = isMediumScreen ? 16.0 : 12.0;

    if (isWideScreen) {
      return Row(
        children: cards.asMap().entries.map((entry) {
          return Expanded(
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                end: entry.key < cards.length - 1 ? spacing : 0,
              ),
              child: entry.value,
            ),
          );
        }).toList(),
      );
    }

    // Mobile/Tablet: 2x2
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: cards[0]),
            SizedBox(width: spacing),
            Expanded(child: cards[1]),
          ],
        ),
        SizedBox(height: spacing),
        Row(
          children: [
            Expanded(child: cards[2]),
            SizedBox(width: spacing),
            Expanded(child: cards[3]),
          ],
        ),
      ],
    );
  }

  /// الصف الرئيسي (Desktop): Chart(8) + QuickActions+TopSelling(4)
  Widget _buildMainRow(AppLocalizations l10n) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: SalesChartCard(
            title: l10n.salesAnalysis,
            subtitle: l10n.storePerformance,
            data: _getSampleChartData(),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              ElegantQuickActions(
                onNewSale: () => context.go(AppRoutes.pos),
                onAddProduct: () => context.push(AppRoutes.products),
                onRefund: () => context.push(AppRoutes.returns),
                onDailyReport: () => context.push('/reports'),
              ),
              const SizedBox(height: 24),
              TopProductsList(
                products: _getSampleTopProducts(),
                onProductTap: (id) => context.push(AppRoutes.productDetailPath(id)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// العمود الرئيسي (Mobile/Tablet)
  Widget _buildMainColumn(AppLocalizations l10n) {
    return Column(
      children: [
        SalesChartCard(
          title: l10n.salesAnalysis,
          subtitle: l10n.storePerformance,
          data: _getSampleChartData(),
        ),
        const SizedBox(height: 16),
        ElegantQuickActions(
          onNewSale: () => context.go(AppRoutes.pos),
          onAddProduct: () => context.push(AppRoutes.products),
          onRefund: () => context.push(AppRoutes.returns),
          onDailyReport: () => context.push('/reports'),
        ),
        const SizedBox(height: 16),
        TopProductsList(
          products: _getSampleTopProducts(),
          onProductTap: (id) => context.push(AppRoutes.productDetailPath(id)),
        ),
      ],
    );
  }

  /// أحدث العمليات
  Widget _buildRecentTransactions(AppLocalizations l10n) {
    final transactions = _recentSales.map((sale) {
      return Transaction(
        id: sale.receiptNo,
        customerName: sale.customerName ?? l10n.cashCustomer,
        amount: sale.total,
        type: TransactionType.sale,
        timestamp: sale.createdAt,
        paymentMethod: sale.paymentMethod,
      );
    }).toList();

    // بيانات نموذجية إذا كانت القائمة فارغة
    if (transactions.isEmpty) {
      final now = DateTime.now();
      transactions.addAll([
        Transaction(
          id: '#ORD-0245',
          customerName: 'محمد علي',
          amount: 125.00,
          type: TransactionType.sale,
          timestamp: now.subtract(const Duration(minutes: 5)),
        ),
        Transaction(
          id: '#ORD-0244',
          customerName: 'سارة أحمد',
          amount: 45.50,
          type: TransactionType.sale,
          timestamp: now.subtract(const Duration(minutes: 12)),
        ),
        Transaction(
          id: '#ORD-0243',
          customerName: l10n.guestCustomer,
          amount: 32.00,
          type: TransactionType.refund,
          timestamp: now.subtract(const Duration(minutes: 25)),
        ),
      ]);
    }

    return RecentTransactionsList(
      transactions: transactions,
      onViewAll: () => context.push('/sales'),
      onViewDetails: (orderId) {},
    );
  }

  String _getDateSubtitle(AppLocalizations l10n) {
    final now = DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year}';
    return '$dateStr • ${l10n.mainBranch}';
  }

  Map<ChartPeriod, List<ChartDataPoint>> _getSampleChartData() {
    return {
      ChartPeriod.weekly: const [
        ChartDataPoint(label: 'سبت', value: 1200),
        ChartDataPoint(label: 'أحد', value: 1500),
        ChartDataPoint(label: 'إثنين', value: 1100),
        ChartDataPoint(label: 'ثلاثاء', value: 1800),
        ChartDataPoint(label: 'أربعاء', value: 1600),
        ChartDataPoint(label: 'خميس', value: 2100),
        ChartDataPoint(label: 'جمعة', value: 1900),
      ],
      ChartPeriod.monthly: const [
        ChartDataPoint(label: 'أسبوع 1', value: 8500),
        ChartDataPoint(label: 'أسبوع 2', value: 9200),
        ChartDataPoint(label: 'أسبوع 3', value: 7800),
        ChartDataPoint(label: 'أسبوع 4', value: 10500),
      ],
      ChartPeriod.yearly: const [
        ChartDataPoint(label: 'يناير', value: 32000),
        ChartDataPoint(label: 'فبراير', value: 28000),
        ChartDataPoint(label: 'مارس', value: 35000),
        ChartDataPoint(label: 'أبريل', value: 31000),
        ChartDataPoint(label: 'مايو', value: 38000),
        ChartDataPoint(label: 'يونيو', value: 42000),
      ],
    };
  }

  List<TopProductItem> _getSampleTopProducts() {
    return const [
      TopProductItem(
        name: 'قهوة لاتيه وسط',
        icon: Icons.coffee_rounded,
        quantity: 42,
        revenue: 630,
      ),
      TopProductItem(
        name: 'كوكيز شوكولاتة',
        icon: Icons.cookie_rounded,
        quantity: 28,
        revenue: 280,
      ),
      TopProductItem(
        name: 'مياه معدنية',
        icon: Icons.water_drop_rounded,
        quantity: 25,
        revenue: 50,
      ),
    ];
  }
}
