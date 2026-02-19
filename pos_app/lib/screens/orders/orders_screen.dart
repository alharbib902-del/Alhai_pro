/// شاشة سجل الطلبات - Orders History Screen
///
/// تعرض قائمة الطلبات مع:
/// - إحصائيات سريعة (إجمالي، مكتملة، معلقة، ملغاة)
/// - شريط بحث وفلاتر (حالة، قناة، تاريخ)
/// - جدول طلبات (Desktop) / بطاقات (Mobile)
/// - لوحة جانبية لتفاصيل الطلب
/// - ترقيم الصفحات
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/router/routes.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/layout/app_sidebar.dart';

/// نموذج بيانات الطلب
class OrderModel {
  final String id;
  final String customer;
  final String? customerPhone;
  final DateTime date;
  final double amount;
  final String status; // completed, pending, cancelled
  final String channel; // pos, online, whatsapp
  final String paymentStatus; // paid, unpaid
  final int itemsCount;
  final List<OrderItemModel> items;

  const OrderModel({
    required this.id,
    required this.customer,
    this.customerPhone,
    required this.date,
    required this.amount,
    required this.status,
    this.channel = 'pos',
    this.paymentStatus = 'paid',
    this.itemsCount = 0,
    this.items = const [],
  });
}

/// نموذج صنف في الطلب
class OrderItemModel {
  final String name;
  final String sku;
  final int quantity;
  final double price;

  const OrderItemModel({
    required this.name,
    required this.sku,
    required this.quantity,
    required this.price,
  });

  double get total => price * quantity;
}

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  bool _sidebarCollapsed = false;
  String _selectedNavId = 'orders';
  String _activeTab = 'all';
  String _activeChannel = 'all';
  String _searchQuery = '';
  OrderModel? _selectedOrder;

  // ─── Sample Data ─────────────────────────────────────────────
  final List<OrderModel> _allOrders = [
    OrderModel(
      id: 'ORD-2401',
      customer: '\u0645\u062d\u0645\u062f \u0627\u0644\u0639\u0644\u064a',
      customerPhone: '0501234567',
      date: DateTime(2026, 2, 9, 14, 30),
      amount: 124.50,
      status: 'completed',
      channel: 'online',
      paymentStatus: 'paid',
      itemsCount: 5,
      items: [
        const OrderItemModel(name: '\u0637\u0645\u0627\u0637\u0645 \u0639\u0636\u0648\u064a\u0629 (\u0643\u062c\u0645)', sku: '8901', quantity: 2, price: 12.50),
        const OrderItemModel(name: '\u062d\u0644\u064a\u0628 \u0643\u0627\u0645\u0644 \u0627\u0644\u062f\u0633\u0645', sku: '2201', quantity: 1, price: 8.00),
        const OrderItemModel(name: '\u062e\u0628\u0632 \u0628\u0631\u064a\u0648\u0634', sku: '4402', quantity: 3, price: 5.50),
      ],
    ),
    OrderModel(
      id: 'ORD-2400',
      customer: '\u0633\u0627\u0631\u0629 \u0623\u062d\u0645\u062f',
      customerPhone: '0559876543',
      date: DateTime(2026, 2, 9, 13, 15),
      amount: 45.00,
      status: 'pending',
      channel: 'pos',
      paymentStatus: 'paid',
      itemsCount: 2,
      items: [
        const OrderItemModel(name: '\u0634\u0648\u0643\u0648\u0644\u0627\u062a\u0629 \u062f\u0627\u0643\u0646\u0629', sku: '9912', quantity: 1, price: 15.00),
        const OrderItemModel(name: '\u0639\u0635\u064a\u0631 \u0628\u0631\u062a\u0642\u0627\u0644', sku: '5501', quantity: 2, price: 15.00),
      ],
    ),
    OrderModel(
      id: 'ORD-2399',
      customer: '\u0641\u0647\u062f \u0627\u0644\u0639\u062a\u064a\u0628\u064a',
      customerPhone: '0541112233',
      date: DateTime(2026, 2, 8, 21, 45),
      amount: 320.75,
      status: 'cancelled',
      channel: 'whatsapp',
      paymentStatus: 'unpaid',
      itemsCount: 12,
      items: [
        const OrderItemModel(name: '\u0623\u0631\u0632 \u0628\u0633\u0645\u062a\u064a', sku: '3301', quantity: 5, price: 25.00),
        const OrderItemModel(name: '\u0632\u064a\u062a \u0632\u064a\u062a\u0648\u0646', sku: '4401', quantity: 2, price: 45.00),
      ],
    ),
  ];

  List<OrderModel> get _filteredOrders {
    var list = _allOrders;
    if (_activeTab != 'all') {
      list = list.where((o) => o.status == _activeTab).toList();
    }
    if (_activeChannel != 'all') {
      list = list.where((o) => o.channel == _activeChannel).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where((o) =>
              o.id.toLowerCase().contains(q) ||
              o.customer.toLowerCase().contains(q) ||
              (o.customerPhone?.contains(q) ?? false))
          .toList();
    }
    return list;
  }

  int get _completedCount =>
      _allOrders.where((o) => o.status == 'completed').length;
  int get _pendingCount =>
      _allOrders.where((o) => o.status == 'pending').length;
  int get _cancelledCount =>
      _allOrders.where((o) => o.status == 'cancelled').length;

  void _handleNavigation(AppSidebarItem item) {
    setState(() => _selectedNavId = item.id);
    switch (item.id) {
      case 'dashboard':
        context.go(AppRoutes.dashboard);
        break;
      case 'pos':
        context.go(AppRoutes.pos);
        break;
      case 'products':
        context.push(AppRoutes.products);
        break;
      case 'inventory':
        context.push(AppRoutes.inventory);
        break;
      case 'customers':
        context.push(AppRoutes.customers);
        break;
      case 'invoices':
        context.push(AppRoutes.invoices);
        break;
      case 'sales':
        context.push(AppRoutes.invoices);
        break;
      case 'orders':
        break;
      case 'reports':
        context.push(AppRoutes.reports);
        break;
    }
  }

  // Note: _copyOrderId method removed - can be re-added when needed

  void _openOrderPanel(OrderModel order) {
    setState(() => _selectedOrder = order);
  }

  void _closeOrderPanel() {
    setState(() => _selectedOrder = null);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isMediumScreen = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : AppColors.backgroundSecondary,
      drawer: isWideScreen ? null : _buildDrawer(l10n),
      body: Stack(
        children: [
          Row(
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
                  userName: '\u0623\u062d\u0645\u062f \u0645\u062d\u0645\u062f',
                  userRole: l10n.branchManager,
                  onUserTap: () {},
                ),
              Expanded(
                child: Column(
                  children: [
                    _buildHeader(context, isWideScreen, isDark, l10n),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(isMediumScreen ? 32 : 16),
                        child: Column(
                          children: [
                            _buildStatsSection(l10n, isDark, isWideScreen),
                            const SizedBox(height: 24),
                            _buildFilterSection(isDark, l10n, isWideScreen),
                            const SizedBox(height: 16),
                            _buildOrdersList(
                                isDark, l10n, isWideScreen, isMediumScreen),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Side Panel Overlay
          if (_selectedOrder != null) ...[
            GestureDetector(
              onTap: _closeOrderPanel,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                color: Colors.black.withValues(alpha: 0.5),
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: isWideScreen ? 420 : size.width,
              child: _buildSidePanel(isDark, l10n, isWideScreen),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Header ──────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, bool isWideScreen, bool isDark,
      AppLocalizations l10n) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B).withValues(alpha: 0.8)
            : Colors.white.withValues(alpha: 0.8),
        border: Border(
            bottom: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : AppColors.border)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: isWideScreen
                ? () =>
                    setState(() => _sidebarCollapsed = !_sidebarCollapsed)
                : () => Scaffold.of(context).openDrawer(),
            icon: Icon(Icons.menu_rounded,
                color:
                    isDark ? AppColors.textMutedDark : AppColors.textSecondary),
          ),
          const SizedBox(width: 8),
          Text(l10n.ordersHistory,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary)),
          if (isWideScreen) ...[
            Container(
                height: 28,
                width: 1,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : AppColors.border),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0F172A)
                    : AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : AppColors.border),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.receipt_long_rounded,
                    size: 14, color: AppColors.primary),
                const SizedBox(width: 6),
                Text('${_allOrders.length}',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        fontFamily: 'Source Code Pro')),
                const SizedBox(width: 4),
                Text(l10n.totalOrdersLabel,
                    style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textMuted)),
              ]),
            ),
          ],
          const Spacer(),
          if (isWideScreen) ...[
            PopupMenuButton<String>(
              onSelected: (value) {},
              offset: const Offset(0, 48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              itemBuilder: (context) => [
                PopupMenuItem(
                    value: 'csv',
                    child: Row(children: [
                      const Icon(Icons.table_chart_outlined,
                          size: 18, color: AppColors.success),
                      const SizedBox(width: 8),
                      Text(l10n.exportCsv),
                    ])),
                PopupMenuItem(
                    value: 'pdf',
                    child: Row(children: [
                      const Icon(Icons.picture_as_pdf_outlined,
                          size: 18, color: AppColors.error),
                      const SizedBox(width: 8),
                      Text(l10n.exportPdf),
                    ])),
              ],
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : AppColors.border),
                ),
                child: Row(children: [
                  Icon(Icons.download_rounded,
                      size: 18,
                      color: isDark
                          ? AppColors.textMutedDark
                          : AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(l10n.exportData,
                      style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? Colors.white
                              : AppColors.textPrimary)),
                  const SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down,
                      size: 16,
                      color: isDark
                          ? AppColors.textMutedDark
                          : AppColors.textMuted),
                ]),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {},
              icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode,
                  color: isDark
                      ? const Color(0xFFFBBF24)
                      : AppColors.textSecondary),
              style: IconButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Stats Section ───────────────────────────────────────────
  Widget _buildStatsSection(
      AppLocalizations l10n, bool isDark, bool isWideScreen) {
    final stats = [
      _StatData(
          l10n.totalOrdersLabel, '${_allOrders.length}',
          Icons.receipt_long_rounded, AppColors.primary),
      _StatData(
          l10n.completedOrders, '$_completedCount',
          Icons.check_circle_rounded, AppColors.success),
      _StatData(
          l10n.pendingOrders, '$_pendingCount',
          Icons.schedule_rounded, AppColors.warning),
      _StatData(
          l10n.cancelledOrders, '$_cancelledCount',
          Icons.cancel_rounded, AppColors.error),
    ];

    if (isWideScreen) {
      return Row(
        children: stats
            .map((s) => Expanded(
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: _buildStatCard(s, isDark))))
            .toList(),
      );
    }
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: stats.map((s) => _buildStatCard(s, isDark)).toList(),
    );
  }

  Widget _buildStatCard(_StatData stat, bool isDark) {
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor =
        isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2))
              ],
      ),
      child: Row(children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: stat.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(stat.icon, color: stat.color, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(stat.label,
                  style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.textMutedDark
                          : AppColors.textMuted)),
              const SizedBox(height: 4),
              Text(stat.value,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color:
                          isDark ? Colors.white : AppColors.textPrimary)),
            ],
          ),
        ),
      ]),
    );
  }

  // ─── Filter Section ──────────────────────────────────────────
  Widget _buildFilterSection(
      bool isDark, AppLocalizations l10n, bool isWideScreen) {
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor =
        isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: l10n.searchOrderHint,
              hintStyle: TextStyle(
                  color:
                      isDark ? AppColors.textMutedDark : AppColors.textMuted,
                  fontSize: 14),
              prefixIcon: Icon(Icons.search,
                  color:
                      isDark ? AppColors.textMutedDark : AppColors.textMuted),
              filled: true,
              fillColor: isDark
                  ? const Color(0xFF0F172A)
                  : AppColors.backgroundSecondary,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.5))),
            ),
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary,
                fontSize: 14),
          ),
          const SizedBox(height: 16),
          // Status & Channel Filters
          isWideScreen
              ? Row(children: [
                  _buildStatusChips(isDark, l10n),
                  const SizedBox(width: 24),
                  _buildChannelChips(isDark, l10n),
                  const Spacer(),
                  _buildDateChip(isDark, l10n),
                ])
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: _buildStatusChips(isDark, l10n),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(children: [
                        _buildChannelChips(isDark, l10n),
                        const SizedBox(width: 12),
                        _buildDateChip(isDark, l10n),
                      ]),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildStatusChips(bool isDark, AppLocalizations l10n) {
    final tabs = [
      ('all', l10n.all),
      ('completed', l10n.completedOrders),
      ('pending', l10n.pendingOrders),
      ('cancelled', l10n.cancelledOrders),
    ];
    return Row(
      children: [
        Text('${l10n.status}:',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color:
                    isDark ? AppColors.textMutedDark : AppColors.textMuted)),
        const SizedBox(width: 8),
        ...tabs.map((t) => Padding(
              padding: const EdgeInsets.only(left: 6),
              child: _buildChip(t.$2, _activeTab == t.$1, isDark,
                  () => setState(() => _activeTab = t.$1)),
            )),
      ],
    );
  }

  Widget _buildChannelChips(bool isDark, AppLocalizations l10n) {
    final channels = [
      ('pos', 'POS', Icons.store_rounded),
      ('online', 'Online', Icons.language_rounded),
      ('whatsapp', 'WhatsApp', Icons.message_rounded),
    ];
    return Row(
      children: [
        Text('${l10n.channelLabel}:',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color:
                    isDark ? AppColors.textMutedDark : AppColors.textMuted)),
        const SizedBox(width: 8),
        ...channels.map((c) => Padding(
              padding: const EdgeInsets.only(left: 6),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => setState(() => _activeChannel =
                    _activeChannel == c.$1 ? 'all' : c.$1),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _activeChannel == c.$1
                        ? AppColors.primary
                        : (isDark
                            ? const Color(0xFF0F172A)
                            : AppColors.backgroundSecondary),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: _activeChannel == c.$1
                            ? AppColors.primary
                            : borderColor(isDark)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(c.$3,
                        size: 14,
                        color: _activeChannel == c.$1
                            ? Colors.white
                            : (isDark
                                ? AppColors.textMutedDark
                                : AppColors.textMuted)),
                    const SizedBox(width: 4),
                    Text(c.$2,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _activeChannel == c.$1
                                ? Colors.white
                                : (isDark
                                    ? Colors.white
                                    : AppColors.textPrimary))),
                  ]),
                ),
              ),
            )),
      ],
    );
  }

  Color borderColor(bool isDark) =>
      isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border;

  Widget _buildDateChip(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor(isDark)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.calendar_today_rounded,
            size: 14, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(l10n.last30Days,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : AppColors.textPrimary)),
      ]),
    );
  }

  Widget _buildChip(
      String label, bool isActive, bool isDark, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary
              : (isDark
                  ? const Color(0xFF0F172A)
                  : Colors.white),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: isActive ? AppColors.primary : borderColor(isDark)),
          boxShadow: isActive
              ? [
                  BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ]
              : null,
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isActive
                    ? Colors.white
                    : (isDark ? Colors.white : AppColors.textPrimary))),
      ),
    );
  }

  // ─── Orders List ─────────────────────────────────────────────
  Widget _buildOrdersList(
      bool isDark, AppLocalizations l10n, bool isWideScreen, bool isMediumScreen) {
    final orders = _filteredOrders;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final bColor = borderColor(isDark);
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final mutedColor = isDark ? AppColors.textMutedDark : AppColors.textMuted;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bColor),
      ),
      child: Column(
        children: [
          // Desktop Table Header
          if (isMediumScreen)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0F172A).withValues(alpha: 0.5)
                    : AppColors.backgroundSecondary.withValues(alpha: 0.5),
                border: Border(bottom: BorderSide(color: bColor)),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Expanded(flex: 2, child: Text(l10n.orderNumber, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: mutedColor))),
                  Expanded(flex: 2, child: Text(l10n.customerNameCol, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: mutedColor))),
                  Expanded(flex: 1, child: Text(l10n.dateCol, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: mutedColor))),
                  Expanded(flex: 2, child: Text(l10n.amountCol, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: mutedColor), textAlign: TextAlign.center)),
                  Expanded(flex: 1, child: Text(l10n.statusCol, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: mutedColor), textAlign: TextAlign.center)),
                  Expanded(flex: 1, child: Text(l10n.channelLabel, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: mutedColor), textAlign: TextAlign.center)),
                  Expanded(flex: 1, child: Text(l10n.paymentCol, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: mutedColor), textAlign: TextAlign.center)),
                  Expanded(flex: 2, child: Text(l10n.actionsCol, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: mutedColor), textAlign: TextAlign.end)),
                ],
              ),
            ),
          // Orders
          if (orders.isEmpty)
            Padding(
              padding: const EdgeInsets.all(48),
              child: Column(children: [
                Icon(Icons.receipt_long_rounded,
                    size: 48, color: mutedColor),
                const SizedBox(height: 12),
                Text(l10n.noResults,
                    style: TextStyle(fontSize: 14, color: mutedColor)),
              ]),
            )
          else
            ...orders.asMap().entries.map((entry) {
              final order = entry.value;
              final isSelected = _selectedOrder?.id == order.id;
              if (isMediumScreen) {
                return _buildDesktopOrderRow(
                    order, isDark, l10n, isSelected, textColor, mutedColor, bColor);
              }
              return _buildMobileOrderCard(
                  order, isDark, l10n, isSelected, textColor, mutedColor, bColor);
            }),
          // Pagination
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF0F172A).withValues(alpha: 0.3)
                  : AppColors.backgroundSecondary.withValues(alpha: 0.3),
              border: Border(top: BorderSide(color: bColor)),
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    l10n.showingResults(1, orders.length, _allOrders.length),
                    style: TextStyle(fontSize: 12, color: mutedColor)),
                Row(children: [
                  _pageBtn(Icons.chevron_right, isDark, null),
                  _pageNumBtn(1, isDark, true),
                  _pageNumBtn(2, isDark, false),
                  _pageNumBtn(3, isDark, false),
                  _pageBtn(Icons.chevron_left, isDark, null),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopOrderRow(OrderModel order, bool isDark,
      AppLocalizations l10n, bool isSelected, Color textColor, Color mutedColor, Color bColor) {
    return InkWell(
      onTap: () => _openOrderPanel(order),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: isDark ? 0.1 : 0.05)
              : null,
          border: Border(
            bottom: BorderSide(color: bColor),
            right: isSelected
                ? const BorderSide(color: AppColors.primary, width: 3)
                : BorderSide.none,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : (isDark
                          ? const Color(0xFF0F172A)
                          : AppColors.backgroundSecondary),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.2)
                          : bColor),
                ),
                child: Text('#${order.id}',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color:
                            isSelected ? AppColors.primary : textColor,
                        fontFamily: 'Source Code Pro')),
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(order.customer,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: textColor)),
                  if (order.customerPhone != null)
                    Text(order.customerPhone!,
                        style: TextStyle(
                            fontSize: 11,
                            color: mutedColor,
                            fontFamily: 'Source Code Pro')),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_formatDate(order.date),
                      style: TextStyle(fontSize: 12, color: mutedColor)),
                  Text(_formatTime(order.date),
                      style: TextStyle(fontSize: 10, color: mutedColor)),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(children: [
                Text('${order.amount.toStringAsFixed(2)} ${l10n.currency}',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        fontFamily: 'Source Code Pro')),
                Text('${order.itemsCount} ${l10n.items}',
                    style: TextStyle(fontSize: 10, color: mutedColor)),
              ]),
            ),
            Expanded(
                flex: 1,
                child: Center(
                    child: _buildStatusBadge(order.status, isDark, l10n))),
            Expanded(
                flex: 1,
                child: Center(child: _buildChannelBadge(order.channel, isDark))),
            Expanded(
              flex: 1,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : AppColors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                      order.paymentStatus == 'paid'
                          ? l10n.paid
                          : l10n.unpaidLabel,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: mutedColor)),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _iconBtn(Icons.print_rounded, isDark,
                      () {}, AppColors.primary),
                  const SizedBox(width: 6),
                  _iconBtn(Icons.share_rounded, isDark,
                      () {}, AppColors.info),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileOrderCard(OrderModel order, bool isDark,
      AppLocalizations l10n, bool isSelected, Color textColor, Color mutedColor, Color bColor) {
    return InkWell(
      onTap: () => _openOrderPanel(order),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: isDark ? 0.1 : 0.05)
              : null,
          border: Border(bottom: BorderSide(color: bColor)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text('#${order.id}',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? AppColors.primary
                                : textColor,
                            fontFamily: 'Source Code Pro')),
                    const SizedBox(width: 8),
                    _buildStatusBadge(order.status, isDark, l10n),
                  ]),
                  const SizedBox(height: 6),
                  Text(order.customer,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textColor)),
                  const SizedBox(height: 2),
                  Text(
                      '${order.amount.toStringAsFixed(2)} ${l10n.currency} \u2022 ${order.itemsCount} ${l10n.items}',
                      style: TextStyle(
                          fontSize: 12,
                          color: mutedColor,
                          fontFamily: 'Source Code Pro')),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${_formatDate(order.date)}\u060C ${_formatTime(order.date)}',
                    style: TextStyle(fontSize: 11, color: mutedColor)),
                const SizedBox(height: 8),
                _buildChannelBadge(order.channel, isDark),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Side Panel ──────────────────────────────────────────────
  Widget _buildSidePanel(bool isDark, AppLocalizations l10n, bool isWideScreen) {
    final order = _selectedOrder!;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final bColor = borderColor(isDark);
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final mutedColor = isDark ? AppColors.textMutedDark : AppColors.textMuted;

    return Material(
      color: cardBg,
      elevation: 16,
      child: Column(
        children: [
          // Panel Header
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: bColor)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.orderDetails,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor)),
                      Row(children: [
                        Text('#${order.id}',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                fontFamily: 'Source Code Pro')),
                        Container(
                            width: 4,
                            height: 4,
                            margin:
                                const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                                color: mutedColor, shape: BoxShape.circle)),
                        Text(
                            '${_formatDate(order.date)}\u060C ${_formatTime(order.date)}',
                            style: TextStyle(
                                fontSize: 12, color: mutedColor)),
                      ]),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _closeOrderPanel,
                  icon: Icon(Icons.close, color: mutedColor),
                ),
              ],
            ),
          ),
          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status & Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatusBadge(order.status, isDark, l10n,
                          large: true),
                      Row(children: [
                        _iconBtn(Icons.print_rounded, isDark, () {},
                            AppColors.primary),
                        const SizedBox(width: 8),
                        _iconBtn(Icons.share_rounded, isDark, () {},
                            AppColors.info),
                      ]),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Customer Block
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF0F172A).withValues(alpha: 0.5)
                          : AppColors.backgroundSecondary.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: bColor),
                    ),
                    child: Column(children: [
                      Row(children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor:
                              AppColors.primary.withValues(alpha: 0.2),
                          child: Text(
                              order.customer.isNotEmpty
                                  ? order.customer[0]
                                  : '?',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary)),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(order.customer,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: textColor)),
                            Text('VIP Member',
                                style: TextStyle(
                                    fontSize: 11, color: mutedColor)),
                          ],
                        ),
                      ]),
                      if (order.customerPhone != null) ...[
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Row(children: [
                              const Icon(Icons.phone_rounded,
                                  size: 14, color: AppColors.primary),
                              const SizedBox(width: 6),
                              Text(order.customerPhone!,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.primary,
                                      fontFamily: 'Source Code Pro')),
                            ]),
                            Text(l10n.mainBranch,
                                style: TextStyle(
                                    fontSize: 12, color: mutedColor)),
                          ],
                        ),
                      ],
                    ]),
                  ),
                  const SizedBox(height: 24),
                  // Items List
                  Text(
                      '${l10n.items} (${order.items.length})',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textColor)),
                  const SizedBox(height: 12),
                  ...order.items.map((item) => Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: bColor.withValues(alpha: 0.5))),
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(item.name,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: textColor)),
                                Text('SKU: ${item.sku}',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: mutedColor,
                                        fontFamily: 'Source Code Pro')),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                    '${item.total.toStringAsFixed(2)} ${l10n.currency}',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                        fontFamily: 'Source Code Pro')),
                                Text('\u00d7${item.quantity}',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: mutedColor)),
                              ],
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 24),
                  // Totals
                  _buildTotals(order, isDark, l10n, textColor, mutedColor),
                  const SizedBox(height: 24),
                  // Payment Method
                  Text(l10n.paymentMethodLabel,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textColor)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: bColor),
                    ),
                    child: Row(children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.credit_card,
                            size: 20, color: AppColors.info),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Visa ending 4242',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: textColor)),
                            Text(l10n.paidSuccessfully,
                                style: TextStyle(
                                    fontSize: 12, color: mutedColor)),
                          ],
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 24),
                  // Actions
                  Row(children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          side: BorderSide(color: bColor),
                        ),
                        child: Text(l10n.printReceipt,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: textColor)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          side: BorderSide(color: bColor),
                        ),
                        child: Text(l10n.returnMerchandise,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: textColor)),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ),
          // Panel Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF0F172A).withValues(alpha: 0.5)
                  : AppColors.backgroundSecondary.withValues(alpha: 0.5),
              border: Border(top: BorderSide(color: bColor)),
            ),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _closeOrderPanel,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(l10n.close,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotals(OrderModel order, bool isDark, AppLocalizations l10n,
      Color textColor, Color mutedColor) {
    final subtotal = order.items.fold<double>(0, (s, i) => s + i.total);
    final vat = subtotal * 0.15;
    const discount = 4.50;
    final total = subtotal + vat - discount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: [
        _totalRow(l10n.subtotalLabel, subtotal, mutedColor, textColor),
        const SizedBox(height: 8),
        _totalRow(l10n.vatLabel, vat, mutedColor, textColor),
        const SizedBox(height: 8),
        _totalRow(l10n.discount, -discount, mutedColor, AppColors.success,
            isDiscount: true),
        Divider(
            height: 24,
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : AppColors.border),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.grandTotalLabel,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textColor)),
            Text('${total.toStringAsFixed(2)} ${l10n.currency}',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontFamily: 'Source Code Pro')),
          ],
        ),
      ]),
    );
  }

  Widget _totalRow(String label, double amount, Color labelColor,
      Color valueColor,
      {bool isDiscount = false}) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: labelColor)),
        Text(
            '${isDiscount ? "-" : ""}${amount.abs().toStringAsFixed(2)} ${l10n.currency}',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor,
                fontFamily: 'Source Code Pro')),
      ],
    );
  }

  // ─── Badges & Helpers ────────────────────────────────────────
  Widget _buildStatusBadge(String status, bool isDark, AppLocalizations l10n,
      {bool large = false}) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case 'completed':
        bgColor = AppColors.success;
        textColor = AppColors.success;
        label = l10n.completedOrders;
        break;
      case 'pending':
        bgColor = AppColors.warning;
        textColor = AppColors.warning;
        label = l10n.pendingOrders;
        break;
      case 'cancelled':
        bgColor = AppColors.error;
        textColor = AppColors.error;
        label = l10n.cancelledOrders;
        break;
      default:
        bgColor = AppColors.textMuted;
        textColor = AppColors.textMuted;
        label = status;
    }

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: large ? 16 : 10, vertical: large ? 6 : 3),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bgColor.withValues(alpha: 0.3)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: large ? 13 : 11,
              fontWeight: FontWeight.bold,
              color: textColor)),
    );
  }

  Widget _buildChannelBadge(String channel, bool isDark) {
    IconData icon;
    Color bgColor;
    Color iconColor;

    switch (channel) {
      case 'online':
        icon = Icons.language_rounded;
        bgColor = AppColors.info;
        iconColor = AppColors.info;
        break;
      case 'whatsapp':
        icon = Icons.message_rounded;
        bgColor = AppColors.success;
        iconColor = AppColors.success;
        break;
      default: // pos
        icon = Icons.store_rounded;
        bgColor = AppColors.success;
        iconColor = AppColors.success;
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: isDark ? 0.15 : 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 14, color: iconColor),
    );
  }

  Widget _iconBtn(
      IconData icon, bool isDark, VoidCallback onTap, Color hoverColor) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor(isDark)),
        ),
        child: Icon(icon,
            size: 14,
            color: isDark ? AppColors.textMutedDark : AppColors.textMuted),
      ),
    );
  }

  Widget _pageBtn(IconData icon, bool isDark, VoidCallback? onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor(isDark)),
          ),
          child: Icon(icon,
              size: 14,
              color: isDark ? AppColors.textMutedDark : AppColors.textMuted),
        ),
      ),
    );
  }

  Widget _pageNumBtn(int num, bool isDark, bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        onTap: () {}, // TODO: Implement pagination state management
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : null,
            borderRadius: BorderRadius.circular(8),
            border: isActive ? null : Border.all(color: borderColor(isDark)),
          ),
          child: Center(
            child: Text('$num',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isActive
                        ? Colors.white
                        : (isDark ? Colors.white : AppColors.textPrimary))),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final months = [
      '', 'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month]}';
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
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
        userName: '\u0623\u062d\u0645\u062f \u0645\u062d\u0645\u062f',
        userRole: l10n.branchManager,
        onUserTap: () {},
      ),
    );
  }
}

class _StatData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatData(this.label, this.value, this.icon, this.color);
}
