import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../data/local/app_database.dart';
import '../../di/injection.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/layout/app_sidebar.dart';

/// Customer Detail Screen - multi-tab screen with profile, purchases,
/// account ledger, debts, analytics, and internal notes.
class CustomerDetailScreen extends ConsumerStatefulWidget {
  final String? customerId;
  const CustomerDetailScreen({super.key, this.customerId});

  @override
  ConsumerState<CustomerDetailScreen> createState() =>
      _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends ConsumerState<CustomerDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  // Sidebar state
  bool _sidebarCollapsed = false;
  String _selectedNavId = 'customers';

  // Account from DB (nullable)
  AccountsTableData? _account;

  // Mock customer data used when no DB record
  final Map<String, dynamic> _mockCustomer = {
    'id': 'CUST-001',
    'name': 'Mohammed Ahmed',
    'nameAr': '\u0645\u062d\u0645\u062f \u0623\u062d\u0645\u062f',
    'phone': '+966 50 123 4567',
    'email': 'mohammed@email.com',
    'joinedDate': '2024-01-15',
    'isVip': true,
    'isActive': true,
    'totalPurchases': 25750.0,
    'balance': 1250.0,
    'creditLimit': 5000.0,
    'loyaltyPoints': 2450,
    'lastVisit': '2026-02-07',
    'avatarColor': const Color(0xFF3B82F6),
  };

  // Mock purchases
  final List<Map<String, dynamic>> _mockPurchases = [
    {
      'date': '2026-02-07',
      'invoice': 'INV-2024-0156',
      'amount': 450.00,
      'status': 'completed',
      'items': 5,
    },
    {
      'date': '2026-02-03',
      'invoice': 'INV-2024-0148',
      'amount': 280.00,
      'status': 'completed',
      'items': 3,
    },
    {
      'date': '2026-01-28',
      'invoice': 'INV-2024-0139',
      'amount': 750.00,
      'status': 'returned',
      'items': 8,
    },
    {
      'date': '2026-01-20',
      'invoice': 'INV-2024-0125',
      'amount': 320.00,
      'status': 'completed',
      'items': 4,
    },
    {
      'date': '2026-01-15',
      'invoice': 'INV-2024-0118',
      'amount': 1200.00,
      'status': 'completed',
      'items': 12,
    },
    {
      'date': '2026-01-10',
      'invoice': 'INV-2024-0110',
      'amount': 95.00,
      'status': 'completed',
      'items': 2,
    },
  ];

  // Mock ledger entries
  final List<Map<String, dynamic>> _mockLedger = [
    {
      'date': '2026-02-07',
      'type': 'payment',
      'description': 'Cash Payment',
      'amount': -500.0,
      'balance': 1250.0,
      'icon': Icons.payments_outlined,
      'color': const Color(0xFF22C55E),
    },
    {
      'date': '2026-02-03',
      'type': 'invoice',
      'description': 'Invoice INV-0148',
      'amount': 280.0,
      'balance': 1750.0,
      'icon': Icons.receipt_long_outlined,
      'color': const Color(0xFF3B82F6),
    },
    {
      'date': '2026-01-28',
      'type': 'topup',
      'description': 'Wallet Top-up',
      'amount': -1000.0,
      'balance': 1470.0,
      'icon': Icons.account_balance_wallet_outlined,
      'color': const Color(0xFF8B5CF6),
    },
    {
      'date': '2026-01-20',
      'type': 'deduction',
      'description': 'Loyalty Points Deduction',
      'amount': -150.0,
      'balance': 2470.0,
      'icon': Icons.star_outline_rounded,
      'color': const Color(0xFFF59E0B),
    },
  ];

  // Mock debts
  final List<Map<String, dynamic>> _mockDebts = [
    {
      'id': 'DEBT-001',
      'invoice': 'INV-2024-0125',
      'amount': 320.0,
      'dueDate': '2026-01-30',
      'isOverdue': true,
      'daysOverdue': 10,
    },
    {
      'id': 'DEBT-002',
      'invoice': 'INV-2024-0148',
      'amount': 280.0,
      'dueDate': '2026-02-15',
      'isOverdue': false,
      'daysOverdue': 0,
    },
    {
      'id': 'DEBT-003',
      'invoice': 'INV-2024-0156',
      'amount': 450.0,
      'dueDate': '2026-03-01',
      'isOverdue': false,
      'daysOverdue': 0,
    },
  ];

  // Mock notes
  final List<Map<String, dynamic>> _mockNotes = [
    {
      'author': 'Ahmed',
      'initials': 'A',
      'color': const Color(0xFF3B82F6),
      'date': '2026-02-07 14:30',
      'text':
          'Customer requested delivery for the next order. Preferred time: morning.',
    },
    {
      'author': 'Sara',
      'initials': 'S',
      'color': const Color(0xFF8B5CF6),
      'date': '2026-02-01 10:15',
      'text':
          'VIP customer - always give priority. Prefers organic products.',
    },
  ];

  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 0;
  static const int _pageSize = 5;

  // =====================================================
  // Customer getters (from DB or mock)
  // =====================================================
  String get _customerName =>
      _account?.name ?? _mockCustomer['nameAr'] as String;
  String get _customerPhone =>
      _account?.phone ?? _mockCustomer['phone'] as String;
  String get _customerEmail => _mockCustomer['email'] as String;
  bool get _isVip => _mockCustomer['isVip'] as bool;
  bool get _isActive => _account?.isActive ?? _mockCustomer['isActive'] as bool;
  double get _totalPurchases => _mockCustomer['totalPurchases'] as double;
  double get _balance =>
      _account?.balance ?? _mockCustomer['balance'] as double;
  double get _creditLimit =>
      _account?.creditLimit ?? _mockCustomer['creditLimit'] as double;
  int get _loyaltyPoints => _mockCustomer['loyaltyPoints'] as int;
  String get _lastVisit => _mockCustomer['lastVisit'] as String;
  String get _joinedDate => _mockCustomer['joinedDate'] as String;
  Color get _avatarColor => _mockCustomer['avatarColor'] as Color;
  String get _initials {
    final parts = _customerName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return _customerName.isNotEmpty ? _customerName[0].toUpperCase() : '?';
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadCustomerData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _noteController.dispose();
    _searchController.dispose();
    super.dispose();
  }

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
      case 'sales':
        context.push(AppRoutes.invoices);
        break;
      case 'orders':
        context.push(AppRoutes.orders);
        break;
      case 'returns':
        context.push(AppRoutes.returns);
        break;
      case 'reports':
        context.push(AppRoutes.reports);
        break;
    }
  }

  Future<void> _loadCustomerData() async {
    setState(() => _isLoading = true);
    try {
      if (widget.customerId != null) {
        final db = getIt<AppDatabase>();
        final account =
            await db.accountsDao.getAccountById(widget.customerId!);
        if (account != null) {
          setState(() => _account = account);
        }
      }
    } catch (_) {
      // fallback to mock data
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // =====================================================
  // BUILD
  // =====================================================
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 900;
    final isDesktop = screenWidth >= AppBreakpoints.laptop;
    final isMobile = screenWidth < AppBreakpoints.tablet;

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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : CustomScrollView(
                    slivers: [
                      // Top bar
                      SliverToBoxAdapter(child: _buildTopBar(isDark, l10n)),
                      // Profile card
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 32 : 16,
                            vertical: 8,
                          ),
                          child: _buildProfileCard(isDark, l10n, isMobile),
                        ),
                      ),
                      // Tabs
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 32 : 16,
                          ),
                          child: _buildTabBar(isDark, l10n),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 16)),
                      // Tab content
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 32 : 16,
                          ),
                          child: _buildTabContent(isDark, l10n, isMobile, isDesktop),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),
                      // Internal notes (always visible)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 32 : 16,
                          ),
                          child: _buildNotesSection(isDark, l10n),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 32)),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // TOP BAR
  // =====================================================
  Widget _buildTopBar(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        border: Border(
          bottom: BorderSide(color: AppColors.getBorder(isDark), width: 1),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              onPressed: () => context.pop(),
              icon: Icon(
                Icons.arrow_back_rounded,
                color: AppColors.getTextPrimary(isDark),
              ),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.getSurfaceVariant(isDark),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.customer,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.getTextPrimary(isDark),
                    ),
                  ),
                  Text(
                    _customerName,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.getTextSecondary(isDark),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.refresh_rounded,
                color: AppColors.getTextSecondary(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // PROFILE CARD
  // =====================================================
  Widget _buildProfileCard(
      bool isDark, AppLocalizations l10n, bool isMobile) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(color: AppColors.getBorder(isDark)),
        boxShadow: isDark ? null : AppSizes.shadowSm,
      ),
      child: Column(
        children: [
          // Avatar + Info + Actions
          isMobile
              ? _buildProfileMobile(isDark, l10n)
              : _buildProfileDesktop(isDark, l10n),
          const SizedBox(height: 20),
          // Stats chips
          _buildStatsChips(isDark, l10n, isMobile),
        ],
      ),
    );
  }

  Widget _buildProfileDesktop(bool isDark, AppLocalizations l10n) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar
        _buildAvatar(isDark, 56),
        const SizedBox(width: 20),
        // Info
        Expanded(child: _buildProfileInfo(isDark, l10n)),
        const SizedBox(width: 16),
        // Actions
        _buildProfileActions(isDark, l10n),
      ],
    );
  }

  Widget _buildProfileMobile(bool isDark, AppLocalizations l10n) {
    return Column(
      children: [
        Row(
          children: [
            _buildAvatar(isDark, 48),
            const SizedBox(width: 16),
            Expanded(child: _buildProfileInfo(isDark, l10n)),
          ],
        ),
        const SizedBox(height: 16),
        _buildProfileActions(isDark, l10n),
      ],
    );
  }

  Widget _buildAvatar(bool isDark, double size) {
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _avatarColor,
                _avatarColor.withValues(alpha: 0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppSizes.radiusXl),
          ),
          alignment: Alignment.center,
          child: Text(
            _initials,
            style: TextStyle(
              fontSize: size * 0.36,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        // Status dot
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: _isActive ? AppColors.success : AppColors.grey400,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.getSurface(isDark),
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfo(bool isDark, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name + VIP badge
        Row(
          children: [
            Flexible(
              child: Text(
                _customerName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.getTextPrimary(isDark),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (_isVip) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFEA580C)],
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_rounded, size: 12, color: Colors.white),
                    SizedBox(width: 2),
                    Text(
                      'VIP',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        // Phone
        _buildInfoChip(
          Icons.phone_outlined,
          _customerPhone,
          isDark,
        ),
        const SizedBox(height: 4),
        // Email
        _buildInfoChip(
          Icons.email_outlined,
          _customerEmail,
          isDark,
        ),
        const SizedBox(height: 4),
        // Joined
        _buildInfoChip(
          Icons.calendar_today_outlined,
          '${l10n.date}: $_joinedDate',
          isDark,
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String text, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.getTextMuted(isDark)),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.getTextSecondary(isDark),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileActions(bool isDark, AppLocalizations l10n) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // New Sale button
        FilledButton.icon(
          onPressed: () => context.go('/pos'),
          icon: const Icon(Icons.shopping_cart_outlined, size: 18),
          label: Text(l10n.newSale),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // More dropdown
        PopupMenuButton<String>(
          onSelected: _handleMoreAction,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          ),
          color: AppColors.getSurface(isDark),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit_outlined,
                      size: 18, color: AppColors.getTextSecondary(isDark)),
                  const SizedBox(width: 8),
                  Text(l10n.edit),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'whatsapp',
              child: Row(
                children: [
                  const Icon(Icons.message_outlined,
                      size: 18, color: Color(0xFF25D366)),
                  const SizedBox(width: 8),
                  Text('WhatsApp',
                      style: TextStyle(
                          color: AppColors.getTextPrimary(isDark))),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'block',
              child: Row(
                children: [
                  const Icon(Icons.block_outlined,
                      size: 18, color: AppColors.error),
                  const SizedBox(width: 8),
                  Text(l10n.inactive,
                      style: const TextStyle(color: AppColors.error)),
                ],
              ),
            ),
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.getSurfaceVariant(isDark),
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              border: Border.all(color: AppColors.getBorder(isDark)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.more_horiz_rounded,
                    size: 18, color: AppColors.getTextSecondary(isDark)),
                const SizedBox(width: 4),
                Text(
                  l10n.more,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.getTextSecondary(isDark),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _handleMoreAction(String action) {
    switch (action) {
      case 'edit':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.edit}...')),
        );
        break;
      case 'whatsapp':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Opening WhatsApp...')),
        );
        break;
      case 'block':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Customer blocked')),
        );
        break;
    }
  }

  // Stats chips row
  Widget _buildStatsChips(
      bool isDark, AppLocalizations l10n, bool isMobile) {
    final chips = [
      _StatChip(
        icon: Icons.shopping_bag_outlined,
        label: l10n.totalSales,
        value: '${_totalPurchases.toStringAsFixed(0)} ${l10n.sar}',
        color: AppColors.primary,
        isDark: isDark,
      ),
      _StatChip(
        icon: Icons.account_balance_wallet_outlined,
        label: l10n.balance,
        value: '${_balance.toStringAsFixed(0)} ${l10n.sar}',
        color: _balance > 0 ? AppColors.warning : AppColors.success,
        isDark: isDark,
      ),
      _StatChip(
        icon: Icons.star_outline_rounded,
        label: l10n.loyaltyProgram,
        value: '$_loyaltyPoints',
        color: const Color(0xFFF59E0B),
        isDark: isDark,
      ),
      _StatChip(
        icon: Icons.access_time_rounded,
        label: l10n.lastSale,
        value: _lastVisit,
        color: const Color(0xFF8B5CF6),
        isDark: isDark,
      ),
    ];

    if (isMobile) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: chips,
      );
    }

    return Row(
      children: chips
          .map((chip) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: chip,
                ),
              ))
          .toList(),
    );
  }

  // =====================================================
  // TABS
  // =====================================================
  Widget _buildTabBar(bool isDark, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: TabBar(
        controller: _tabController,
        onTap: (_) => setState(() {}),
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.getTextSecondary(isDark),
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorWeight: 2.5,
        dividerColor: AppColors.getBorder(isDark),
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
        tabs: [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.receipt_long_outlined, size: 16),
                const SizedBox(width: 6),
                Text(l10n.sales),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.account_balance_wallet_outlined, size: 16),
                const SizedBox(width: 6),
                Text(l10n.balance),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_amber_rounded, size: 16),
                const SizedBox(width: 6),
                Text(l10n.debt),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.analytics_outlined, size: 16),
                const SizedBox(width: 6),
                Text(l10n.reports),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(
      bool isDark, AppLocalizations l10n, bool isMobile, bool isDesktop) {
    // AnimatedSwitcher on tab index
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: KeyedSubtree(
        key: ValueKey(_tabController.index),
        child: _buildCurrentTab(isDark, l10n, isMobile, isDesktop),
      ),
    );
  }

  Widget _buildCurrentTab(
      bool isDark, AppLocalizations l10n, bool isMobile, bool isDesktop) {
    switch (_tabController.index) {
      case 0:
        return _buildPurchasesTab(isDark, l10n, isMobile, isDesktop);
      case 1:
        return _buildAccountTab(isDark, l10n, isMobile, isDesktop);
      case 2:
        return _buildDebtsTab(isDark, l10n, isMobile, isDesktop);
      case 3:
        return _buildAnalyticsTab(isDark, l10n, isMobile, isDesktop);
      default:
        return const SizedBox.shrink();
    }
  }

  // =====================================================
  // PURCHASES TAB
  // =====================================================
  Widget _buildPurchasesTab(
      bool isDark, AppLocalizations l10n, bool isMobile, bool isDesktop) {
    final filteredPurchases = _searchController.text.isEmpty
        ? _mockPurchases
        : _mockPurchases
            .where((p) => (p['invoice'] as String)
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()))
            .toList();

    final totalPages = (filteredPurchases.length / _pageSize).ceil();
    final pagedPurchases = filteredPurchases
        .skip(_currentPage * _pageSize)
        .take(_pageSize)
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(color: AppColors.getBorder(isDark)),
        boxShadow: isDark ? null : AppSizes.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.receipt_long_outlined,
                    size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  l10n.recentTransactions,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
                const Spacer(),
                // Search
                SizedBox(
                  width: isMobile ? 160 : 240,
                  height: 36,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() => _currentPage = 0),
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.getTextPrimary(isDark),
                    ),
                    decoration: InputDecoration(
                      hintText: '${l10n.search}...',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: AppColors.getTextMuted(isDark),
                      ),
                      prefixIcon: Icon(Icons.search_rounded,
                          size: 18, color: AppColors.getTextMuted(isDark)),
                      filled: true,
                      fillColor: AppColors.getSurfaceVariant(isDark),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusMd),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                if (!isMobile) ...[
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.download_outlined, size: 16),
                    label: const Text('CSV'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.getTextSecondary(isDark),
                      side: BorderSide(color: AppColors.getBorder(isDark)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusMd),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.getBorder(isDark)),

          // Content: DataTable on desktop, cards on mobile
          if (isMobile)
            _buildPurchaseCards(pagedPurchases, isDark, l10n)
          else
            _buildPurchaseTable(pagedPurchases, isDark, l10n),

          // Pagination
          if (totalPages > 1)
            _buildPagination(isDark, totalPages, filteredPurchases.length),
        ],
      ),
    );
  }

  Widget _buildPurchaseTable(List<Map<String, dynamic>> purchases,
      bool isDark, AppLocalizations l10n) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width - 96,
        ),
        child: DataTable(
          headingRowColor: WidgetStatePropertyAll(
            AppColors.getSurfaceVariant(isDark),
          ),
          headingTextStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.getTextSecondary(isDark),
          ),
          dataTextStyle: TextStyle(
            fontSize: 13,
            color: AppColors.getTextPrimary(isDark),
          ),
          columnSpacing: 24,
          horizontalMargin: 16,
          columns: [
            DataColumn(label: Text(l10n.date)),
            DataColumn(label: Text(l10n.invoiceNumber)),
            DataColumn(label: Text(l10n.amount), numeric: true),
            DataColumn(label: Text(l10n.status)),
            DataColumn(label: Text(l10n.quantity)),
            DataColumn(label: Text(l10n.action)),
          ],
          rows: purchases.map((p) {
            final isReturned = p['status'] == 'returned';
            return DataRow(
              cells: [
                DataCell(Text(p['date'] as String)),
                DataCell(
                  Text(
                    p['invoice'] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppColors.info,
                    ),
                  ),
                ),
                DataCell(Text(
                    '${(p['amount'] as double).toStringAsFixed(2)} ${l10n.sar}')),
                DataCell(_buildStatusBadge(
                    isReturned ? l10n.returned : l10n.completed,
                    isReturned, isDark)),
                DataCell(Text('${p['items']}')),
                DataCell(Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.visibility_outlined,
                          size: 18, color: AppColors.info),
                      tooltip: l10n.viewAll,
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.print_outlined,
                          size: 18,
                          color: AppColors.getTextSecondary(isDark)),
                      tooltip: l10n.printReceipt,
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                  ],
                )),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPurchaseCards(List<Map<String, dynamic>> purchases,
      bool isDark, AppLocalizations l10n) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      itemCount: purchases.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final p = purchases[index];
        final isReturned = p['status'] == 'returned';
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.getSurfaceVariant(isDark),
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    p['invoice'] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.info,
                      fontSize: 14,
                    ),
                  ),
                  _buildStatusBadge(
                      isReturned ? l10n.returned : l10n.completed,
                      isReturned, isDark),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(p['date'] as String,
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.getTextMuted(isDark))),
                  Text(
                    '${(p['amount'] as double).toStringAsFixed(2)} ${l10n.sar}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.getTextPrimary(isDark),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${p['items']} ${l10n.products}',
                style: TextStyle(
                    fontSize: 12, color: AppColors.getTextMuted(isDark)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String label, bool isReturned, bool isDark) {
    final color = isReturned ? AppColors.warning : AppColors.success;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildPagination(bool isDark, int totalPages, int totalItems) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${_currentPage * _pageSize + 1}-${((_currentPage + 1) * _pageSize).clamp(0, totalItems)} / $totalItems',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.getTextMuted(isDark),
            ),
          ),
          Row(
            children: [
              _PaginationButton(
                icon: Icons.chevron_left_rounded,
                enabled: _currentPage > 0,
                isDark: isDark,
                onTap: () => setState(() => _currentPage--),
              ),
              const SizedBox(width: 4),
              ...List.generate(totalPages, (i) {
                final isSelected = i == _currentPage;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: InkWell(
                    onTap: () => setState(() => _currentPage = i),
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusMd),
                    child: Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.transparent,
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusMd),
                      ),
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected
                              ? Colors.white
                              : AppColors.getTextSecondary(isDark),
                        ),
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(width: 4),
              _PaginationButton(
                icon: Icons.chevron_right_rounded,
                enabled: _currentPage < totalPages - 1,
                isDark: isDark,
                onTap: () => setState(() => _currentPage++),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =====================================================
  // ACCOUNT TAB
  // =====================================================
  Widget _buildAccountTab(
      bool isDark, AppLocalizations l10n, bool isMobile, bool isDesktop) {
    if (isMobile) {
      return Column(
        children: [
          _buildBalanceSummaryCard(isDark, l10n),
          const SizedBox(height: 16),
          _buildLedgerList(isDark, l10n),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: Financial Ledger
        Expanded(flex: 3, child: _buildLedgerList(isDark, l10n)),
        const SizedBox(width: 16),
        // Right: Balance summary card
        Expanded(flex: 2, child: _buildBalanceSummaryCard(isDark, l10n)),
      ],
    );
  }

  Widget _buildLedgerList(bool isDark, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(color: AppColors.getBorder(isDark)),
        boxShadow: isDark ? null : AppSizes.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.receipt_long_outlined,
                    size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  l10n.finance,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    final id = widget.customerId ?? '';
                    context.push(
                      '${AppRoutes.customerLedgerPath(id)}?name=${Uri.encodeComponent(_customerName)}',
                    );
                  },
                  child: Text(l10n.viewAll,
                      style: const TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.getBorder(isDark)),
          // Entries
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            itemCount: _mockLedger.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final entry = _mockLedger[index];
              final amount = entry['amount'] as double;
              final isCredit = amount < 0;
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.getSurfaceVariant(isDark),
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                ),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color:
                            (entry['color'] as Color).withValues(alpha: 0.12),
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusMd),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        entry['icon'] as IconData,
                        size: 20,
                        color: entry['color'] as Color,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry['description'] as String,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.getTextPrimary(isDark),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            entry['date'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.getTextMuted(isDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Amount
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${isCredit ? '-' : '+'}${amount.abs().toStringAsFixed(0)} ${l10n.sar}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color:
                                isCredit ? AppColors.success : AppColors.error,
                          ),
                        ),
                        Text(
                          '${l10n.balance}: ${(entry['balance'] as double).toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.getTextMuted(isDark),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceSummaryCard(bool isDark, AppLocalizations l10n) {
    final usedPercent =
        _creditLimit > 0 ? (_balance / _creditLimit * 100).clamp(0, 100) : 0.0;
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            alignment: Alignment.center,
            child: const Icon(
                Icons.account_balance_wallet_rounded,
                size: 24,
                color: Colors.white),
          ),
          const SizedBox(height: 16),
          const Text(
            'Current Balance',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_balance.toStringAsFixed(0)} ${l10n.sar}',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          // Credit Limit
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.credit,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
              Text(
                '${usedPercent.toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
            child: LinearProgressIndicator(
              value: usedPercent / 100,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_balance.toStringAsFixed(0)} / ${_creditLimit.toStringAsFixed(0)} ${l10n.sar}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 20),
          // Top-up button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(l10n.payment),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primaryDark,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // DEBTS TAB
  // =====================================================
  Widget _buildDebtsTab(
      bool isDark, AppLocalizations l10n, bool isMobile, bool isDesktop) {
    final crossAxisCount = isMobile ? 1 : (isDesktop ? 3 : 2);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: isMobile ? 2.2 : 1.6,
      ),
      itemCount: _mockDebts.length,
      itemBuilder: (context, index) {
        final debt = _mockDebts[index];
        final isOverdue = debt['isOverdue'] as bool;
        return _buildDebtCard(debt, isOverdue, isDark, l10n);
      },
    );
  }

  Widget _buildDebtCard(Map<String, dynamic> debt, bool isOverdue,
      bool isDark, AppLocalizations l10n) {
    final accentColor = isOverdue ? AppColors.error : AppColors.warning;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(color: AppColors.getBorder(isDark)),
        boxShadow: isDark ? null : AppSizes.shadowSm,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Left accent stripe
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(width: 4, color: accentColor),
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 16, right: 12, top: 16, bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + badge
                Row(
                  children: [
                    Icon(
                      isOverdue
                          ? Icons.error_outline_rounded
                          : Icons.schedule_rounded,
                      size: 18,
                      color: accentColor,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        isOverdue ? l10n.overdue : l10n.pending,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: accentColor,
                        ),
                      ),
                    ),
                    if (isOverdue)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.12),
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusFull),
                        ),
                        child: Text(
                          '${debt['daysOverdue']}d',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                // Invoice
                Text(
                  debt['invoice'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.getTextSecondary(isDark),
                  ),
                ),
                const Spacer(),
                // Amount
                Text(
                  '${(debt['amount'] as double).toStringAsFixed(0)} ${l10n.sar}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
                const SizedBox(height: 4),
                // Due date
                Text(
                  '${l10n.dueDate}: ${debt['dueDate']}',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.getTextMuted(isDark),
                  ),
                ),
                const SizedBox(height: 10),
                // Actions
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 32,
                        child: FilledButton(
                          onPressed: () {},
                          style: FilledButton.styleFrom(
                            backgroundColor: accentColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.zero,
                            textStyle: const TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w600),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusMd),
                            ),
                          ),
                          child: Text(l10n.pay),
                        ),
                      ),
                    ),
                    if (!isOverdue) ...[
                      const SizedBox(width: 6),
                      Expanded(
                        child: SizedBox(
                          height: 32,
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              foregroundColor: accentColor,
                              side: BorderSide(color: accentColor),
                              padding: EdgeInsets.zero,
                              textStyle: const TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w600),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusMd),
                              ),
                            ),
                            child: Text(l10n.reminder),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // ANALYTICS TAB
  // =====================================================
  Widget _buildAnalyticsTab(
      bool isDark, AppLocalizations l10n, bool isMobile, bool isDesktop) {
    return Column(
      children: [
        // Charts row
        if (isMobile)
          Column(
            children: [
              _buildChartPlaceholder(
                isDark,
                l10n.monthly,
                Icons.bar_chart_rounded,
                AppColors.primary,
                'Monthly Spending',
              ),
              const SizedBox(height: 12),
              _buildChartPlaceholder(
                isDark,
                l10n.categories,
                Icons.pie_chart_outline_rounded,
                const Color(0xFF8B5CF6),
                'Purchase Distribution',
              ),
            ],
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildChartPlaceholder(
                  isDark,
                  l10n.monthly,
                  Icons.bar_chart_rounded,
                  AppColors.primary,
                  'Monthly Spending',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildChartPlaceholder(
                  isDark,
                  l10n.categories,
                  Icons.pie_chart_outline_rounded,
                  const Color(0xFF8B5CF6),
                  'Purchase Distribution',
                ),
              ),
            ],
          ),
        const SizedBox(height: 16),
        // Stats cards row
        _buildAnalyticsStatsGrid(isDark, l10n, isMobile),
      ],
    );
  }

  Widget _buildChartPlaceholder(
    bool isDark,
    String subtitle,
    IconData icon,
    Color color,
    String title,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(color: AppColors.getBorder(isDark)),
        boxShadow: isDark ? null : AppSizes.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.getTextMuted(isDark),
            ),
          ),
          const SizedBox(height: 24),
          // Placeholder chart bars
          SizedBox(
            height: 160,
            child: icon == Icons.bar_chart_rounded
                ? _buildBarChartPlaceholder(isDark, color)
                : _buildPieChartPlaceholder(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChartPlaceholder(bool isDark, Color color) {
    final values = [0.4, 0.7, 0.55, 0.85, 0.65, 0.9];
    final months = ['Sep', 'Oct', 'Nov', 'Dec', 'Jan', 'Feb'];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(values.length, (i) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AnimatedContainer(
                  duration: Duration(milliseconds: 400 + i * 100),
                  height: 120 * values[i],
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color,
                        color.withValues(alpha: 0.6),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4)),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  months[i],
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.getTextMuted(isDark),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPieChartPlaceholder(bool isDark) {
    final items = [
      {'label': 'Groceries', 'pct': 45, 'color': AppColors.primary},
      {'label': 'Dairy', 'pct': 25, 'color': AppColors.info},
      {'label': 'Meat', 'pct': 18, 'color': AppColors.warning},
      {'label': 'Other', 'pct': 12, 'color': const Color(0xFF8B5CF6)},
    ];
    return Row(
      children: [
        // Circle placeholder
        Expanded(
          child: Center(
            child: SizedBox(
              width: 120,
              height: 120,
              child: CustomPaint(
                painter: _PieChartPainter(
                  items
                      .map((e) => _PieSegment(
                            value: (e['pct'] as int).toDouble(),
                            color: e['color'] as Color,
                          ))
                      .toList(),
                ),
              ),
            ),
          ),
        ),
        // Legend
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: items.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: item['color'] as Color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${item['label']} ${item['pct']}%',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.getTextSecondary(isDark),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildAnalyticsStatsGrid(
      bool isDark, AppLocalizations l10n, bool isMobile) {
    final stats = [
      {
        'icon': Icons.receipt_outlined,
        'label': l10n.averageSale,
        'value': '285 ${l10n.sar}',
        'change': '+12%',
        'color': AppColors.primary,
        'isPositive': true,
      },
      {
        'icon': Icons.calendar_month_outlined,
        'label': l10n.monthly,
        'value': '3.2x',
        'change': '+0.5',
        'color': AppColors.info,
        'isPositive': true,
      },
      {
        'icon': Icons.trending_up_rounded,
        'label': l10n.salesAnalytics,
        'value': '+18%',
        'change': 'vs last quarter',
        'color': AppColors.success,
        'isPositive': true,
      },
      {
        'icon': Icons.favorite_outline_rounded,
        'label': l10n.topSelling,
        'value': 'Organic Milk',
        'change': '42 purchases',
        'color': const Color(0xFF8B5CF6),
        'isPositive': true,
      },
    ];

    if (isMobile) {
      return Column(
        children: stats.map((s) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildAnalyticStatCard(s, isDark),
          );
        }).toList(),
      );
    }

    return Row(
      children: stats.asMap().entries.map((entry) {
        return Expanded(
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              end: entry.key < stats.length - 1 ? 12 : 0,
            ),
            child: _buildAnalyticStatCard(entry.value, isDark),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAnalyticStatCard(
      Map<String, dynamic> stat, bool isDark) {
    final color = stat['color'] as Color;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(color: AppColors.getBorder(isDark)),
        boxShadow: isDark ? null : AppSizes.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            alignment: Alignment.center,
            child: Icon(stat['icon'] as IconData, size: 18, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            stat['label'] as String,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.getTextMuted(isDark),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            stat['value'] as String,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            stat['change'] as String,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: (stat['isPositive'] as bool)
                  ? AppColors.success
                  : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // NOTES SECTION
  // =====================================================
  Widget _buildNotesSection(bool isDark, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(color: AppColors.getBorder(isDark)),
        boxShadow: isDark ? null : AppSizes.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.sticky_note_2_outlined,
                    size: 20, color: Color(0xFFF59E0B)),
                const SizedBox(width: 8),
                Text(
                  'Internal Notes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.getSurfaceVariant(isDark),
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusFull),
                  ),
                  child: Text(
                    '${_mockNotes.length}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.getTextSecondary(isDark),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.getBorder(isDark)),
          // Notes list
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            itemCount: _mockNotes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final note = _mockNotes[index];
              return _buildNoteItem(note, isDark);
            },
          ),
          // Add note input
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _noteController,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.getTextPrimary(isDark),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Add a note...',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: AppColors.getTextMuted(isDark),
                      ),
                      filled: true,
                      fillColor: AppColors.getSurfaceVariant(isDark),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusLg),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _addNote(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addNote,
                  icon: const Icon(Icons.send_rounded, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(10),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusLg),
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

  Widget _buildNoteItem(Map<String, dynamic> note, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: (note['color'] as Color).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          alignment: Alignment.center,
          child: Text(
            note['initials'] as String,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: note['color'] as Color,
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Note content
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.getSurfaceVariant(isDark),
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      note['author'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.getTextPrimary(isDark),
                      ),
                    ),
                    Text(
                      note['date'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.getTextMuted(isDark),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  note['text'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.getTextSecondary(isDark),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _addNote() {
    final text = _noteController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _mockNotes.insert(0, {
        'author': 'You',
        'initials': 'Y',
        'color': AppColors.primary,
        'date': _formatNow(),
        'text': text,
      });
    });
    _noteController.clear();
  }

  String _formatNow() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }
}

// =======================================================================
// SUPPORTING WIDGETS
// =======================================================================

/// Stat chip for profile card
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.25 : 0.15),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.getTextMuted(isDark),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Pagination arrow button
class _PaginationButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final bool isDark;
  final VoidCallback onTap;

  const _PaginationButton({
    required this.icon,
    required this.enabled,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.getSurfaceVariant(isDark),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: AppColors.getBorder(isDark)),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled
              ? AppColors.getTextPrimary(isDark)
              : AppColors.getTextMuted(isDark),
        ),
      ),
    );
  }
}

// =======================================================================
// PIE CHART PAINTER
// =======================================================================

class _PieSegment {
  final double value;
  final Color color;
  const _PieSegment({required this.value, required this.color});
}

class _PieChartPainter extends CustomPainter {
  final List<_PieSegment> segments;

  _PieChartPainter(this.segments);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final innerRadius = radius * 0.55;
    final total = segments.fold<double>(0, (s, e) => s + e.value);

    double startAngle = -1.5708; // -pi/2 (start from top)

    for (final segment in segments) {
      final sweepAngle = (segment.value / total) * 6.2832; // 2*pi
      final paint = Paint()
        ..color = segment.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius - innerRadius
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: (radius + innerRadius) / 2),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) => false;
}
