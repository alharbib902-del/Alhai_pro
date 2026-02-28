import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:alhai_design_system/alhai_design_system.dart';
import '../../core/theme/app_sizes.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

import 'customer_purchases_tab.dart';
import 'customer_account_tab.dart';
import 'customer_analytics_tab.dart';
import 'customer_notes_section.dart';
import '../../widgets/common/shimmer_loading.dart';
// WhatsApp providers are provided by consuming app (cashier)
// import '../../providers/whatsapp_queue_providers.dart';
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

  // Real data from DB
  AccountsTableData? _account;
  List<TransactionsTableData> _transactions = [];

  // =====================================================
  // Customer getters (from DB data)
  // =====================================================
  String get _customerName => _account?.name ?? '';
  String get _customerPhone => _account?.phone ?? '';
  String get _customerEmail => ''; // No email in accounts table
  bool get _isVip => false; // No VIP flag in accounts table
  bool get _isActive => _account?.isActive ?? true;
  double get _totalPurchases {
    // Sum of positive (debit) transactions = total invoiced
    return _transactions
        .where((t) => t.type == 'invoice')
        .fold(0.0, (sum, t) => sum + t.amount.abs());
  }

  double get _balance => _account?.balance ?? 0.0;
  double get _creditLimit => _account?.creditLimit ?? 0.0;
  int get _loyaltyPoints => 0; // No loyalty points in accounts table
  String get _lastVisit {
    if (_account?.lastTransactionAt != null) {
      final d = _account!.lastTransactionAt!;
      return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    }
    return '-';
  }

  String get _joinedDate {
    final d = _account?.createdAt;
    if (d == null) return '-';
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  Color get _avatarColor => const Color(0xFF3B82F6);
  String get _initials {
    final parts = _customerName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return _customerName.isNotEmpty ? _customerName[0].toUpperCase() : '?';
  }

  // Derived data from transactions
  List<TransactionsTableData> get _invoiceTransactions =>
      _transactions.where((t) => t.type == 'invoice').toList();

  List<Map<String, dynamic>> get _debtEntries {
    // Derive debts from unpaid invoice transactions
    // If account has positive balance, show recent invoices as debt entries
    if (_balance <= 0) return [];
    final invoices = _invoiceTransactions;
    double remaining = _balance;
    final debts = <Map<String, dynamic>>[];
    for (final inv in invoices) {
      if (remaining <= 0) break;
      final amount = inv.amount.abs().clamp(0, remaining);
      final dueDate = inv.createdAt.add(const Duration(days: 30));
      final isOverdue = dueDate.isBefore(DateTime.now());
      final daysOverdue =
          isOverdue ? DateTime.now().difference(dueDate).inDays : 0;
      debts.add({
        'id': inv.id,
        'invoice': inv.referenceId ?? inv.id,
        'amount': amount,
        'dueDate':
            '${dueDate.year}-${dueDate.month.toString().padLeft(2, '0')}-${dueDate.day.toString().padLeft(2, '0')}',
        'isOverdue': isOverdue,
        'daysOverdue': daysOverdue,
      });
      remaining -= amount;
    }
    return debts;
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
    super.dispose();
  }

  Future<void> _loadCustomerData() async {
    setState(() => _isLoading = true);
    try {
      if (widget.customerId != null) {
        final db = GetIt.I<AppDatabase>();
        final account =
            await db.accountsDao.getAccountById(widget.customerId!);
        final transactions = await db.transactionsDao
            .getAccountTransactions(widget.customerId!);
        if (mounted) {
          setState(() {
            _account = account;
            _transactions = transactions;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // =====================================================
  // BUILD
  // =====================================================
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = context.screenWidth;
    final isDesktop = screenWidth >= AppBreakpoints.laptop;
    final isMobile = screenWidth < AppBreakpoints.tablet;

    return _isLoading
        ? const Padding(
            padding: EdgeInsets.all(16),
            child: ShimmerList(itemCount: 5, itemHeight: 72),
          )
        : _account == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_off_outlined,
                        size: 64,
                        color: AppColors.getTextMuted(isDark)),
                    const SizedBox(height: 16),
                    Text(
                      'Customer not found',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.getTextSecondary(isDark),
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () => context.pop(),
                      child: Text(l10n.back),
                    ),
                  ],
                ),
              )
            : CustomScrollView(
                slivers: [
                  // Top bar
                  SliverToBoxAdapter(
                      child: _buildTopBar(isDark, l10n)),
                  // Profile card
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 32 : 16,
                        vertical: 8,
                      ),
                      child: _buildProfileCard(
                          isDark, l10n, isMobile),
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
                  const SliverToBoxAdapter(
                      child: SizedBox(height: 16)),
                  // Tab content
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 32 : 16,
                      ),
                      child: _buildTabContent(
                          isDark, l10n, isMobile, isDesktop),
                    ),
                  ),
                  const SliverToBoxAdapter(
                      child: SizedBox(height: 24)),
                  // Internal notes (always visible)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 32 : 16,
                      ),
                      child: CustomerNotesSection(isDark: isDark),
                    ),
                  ),
                  const SliverToBoxAdapter(
                      child: SizedBox(height: 32)),
                ],
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
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    _customerName,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.getTextSecondary(isDark),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: _loadCustomerData,
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
        Hero(
          tag: 'customer-avatar-${widget.customerId ?? ''}',
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _avatarColor,
                  _avatarColor.withValues(alpha: 0.7),
                ],
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
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
        ),
        // Status dot
        PositionedDirectional(
          bottom: 0,
          end: 0,
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
                  borderRadius:
                      BorderRadius.circular(AppSizes.radiusFull),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_rounded,
                        size: 12, color: Colors.white),
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
        if (_customerPhone.isNotEmpty)
          _buildInfoChip(
            Icons.phone_outlined,
            _customerPhone,
            isDark,
          ),
        if (_customerPhone.isNotEmpty) const SizedBox(height: 4),
        // Email
        if (_customerEmail.isNotEmpty)
          _buildInfoChip(
            Icons.email_outlined,
            _customerEmail,
            isDark,
          ),
        if (_customerEmail.isNotEmpty) const SizedBox(height: 4),
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
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                      size: 18,
                      color: AppColors.getTextSecondary(isDark)),
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
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.getSurfaceVariant(isDark),
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              border: Border.all(color: AppColors.getBorder(isDark)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.more_horiz_rounded,
                    size: 18,
                    color: AppColors.getTextSecondary(isDark)),
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

  Future<void> _handleMoreAction(String action) async {
    switch (action) {
      case 'edit':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('${AppLocalizations.of(context)!.edit}...')),
        );
        break;
      case 'whatsapp':
        if (_customerPhone.isNotEmpty) {
          try {
            // WhatsApp service is provided by consuming app (cashier)
            // TODO: Wire whatsappServiceProvider when assembling final apps
            throw UnimplementedError('WhatsApp service not available in shared_ui');
          } catch (_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(context)!.messageSendFailed)),
              );
            }
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.noPhoneForCustomer)),
          );
        }
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
                Flexible(child: Text(l10n.sales, overflow: TextOverflow.ellipsis, maxLines: 1)),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.account_balance_wallet_outlined,
                    size: 16),
                const SizedBox(width: 6),
                Flexible(child: Text(l10n.balance, overflow: TextOverflow.ellipsis, maxLines: 1)),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_amber_rounded, size: 16),
                const SizedBox(width: 6),
                Flexible(child: Text(l10n.debt, overflow: TextOverflow.ellipsis, maxLines: 1)),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.analytics_outlined, size: 16),
                const SizedBox(width: 6),
                Flexible(child: Text(l10n.reports, overflow: TextOverflow.ellipsis, maxLines: 1)),
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
      duration: AlhaiDurations.standard,
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
        return CustomerPurchasesTab(
          invoiceTransactions: _invoiceTransactions,
          isMobile: isMobile,
          isDesktop: isDesktop,
          isDark: isDark,
        );
      case 1:
        return CustomerAccountTab(
          transactions: _transactions,
          balance: _balance,
          creditLimit: _creditLimit,
          customerId: widget.customerId,
          customerName: _customerName,
          isMobile: isMobile,
          isDesktop: isDesktop,
          isDark: isDark,
        );
      case 2:
        return _buildDebtsTab(isDark, l10n, isMobile, isDesktop);
      case 3:
        return CustomerAnalyticsTab(
          invoiceTransactions: _invoiceTransactions,
          totalPurchases: _totalPurchases,
          isMobile: isMobile,
          isDesktop: isDesktop,
          isDark: isDark,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  // =====================================================
  // DEBTS TAB
  // =====================================================
  Widget _buildDebtsTab(
      bool isDark, AppLocalizations l10n, bool isMobile, bool isDesktop) {
    final debts = _debtEntries;
    if (debts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: AppColors.getSurface(isDark),
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
          border: Border.all(color: AppColors.getBorder(isDark)),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_outline_rounded,
                  size: 64,
                  color: AppColors.success.withValues(alpha: 0.5)),
              const SizedBox(height: 16),
              Text(
                l10n.noTransactions,
                style: TextStyle(
                    color: AppColors.getTextMuted(isDark)),
              ),
            ],
          ),
        ),
      );
    }
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
      itemCount: debts.length,
      itemBuilder: (context, index) {
        final debt = debts[index];
        final isOverdue = debt['isOverdue'] as bool;
        return _buildDebtCard(debt, isOverdue, isDark, l10n);
      },
    );
  }

  Widget _buildDebtCard(Map<String, dynamic> debt, bool isOverdue,
      bool isDark, AppLocalizations l10n) {
    final accentColor =
        isOverdue ? AppColors.error : AppColors.warning;
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
          // Start accent stripe
          PositionedDirectional(
            start: 0,
            top: 0,
            bottom: 0,
            child: Container(width: 4, color: accentColor),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(
                start: 16, end: 12, top: 16, bottom: 12),
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
                          color: AppColors.error
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(
                              AppSizes.radiusFull),
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
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
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
                                fontSize: 11,
                                fontWeight: FontWeight.w600),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppSizes.radiusMd),
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
                              side:
                                  BorderSide(color: accentColor),
                              padding: EdgeInsets.zero,
                              textStyle: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                        AppSizes.radiusMd),
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
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
