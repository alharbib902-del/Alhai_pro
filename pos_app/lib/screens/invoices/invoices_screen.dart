/// شاشة الفواتير - Invoices Screen
///
/// تعرض قائمة الفواتير مع إحصائيات، مخطط إيرادات،
/// فلاتر، جدول بيانات، وإنشاء فاتورة جديدة
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/router/routes.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/layout/app_sidebar.dart';
import '../../widgets/invoices/invoice_stat_card.dart';
import '../../widgets/invoices/invoice_revenue_chart.dart';
import '../../widgets/invoices/invoice_payment_methods.dart';
import '../../widgets/invoices/invoice_data_table.dart';
import '../../widgets/invoices/invoice_filters.dart';
import '../../widgets/invoices/create_invoice_dialog.dart';
import '../../widgets/invoices/delete_invoice_dialog.dart';

/// نموذج بيانات الفاتورة
class InvoiceModel {
  final String id;
  final String customer;
  final String? customerAvatar;
  final DateTime date;
  final double amount;
  final String status; // paid, pending, overdue, cancelled
  final String paymentMethod; // cash, card, wallet
  final int itemsCount;

  const InvoiceModel({
    required this.id,
    required this.customer,
    this.customerAvatar,
    required this.date,
    required this.amount,
    required this.status,
    required this.paymentMethod,
    this.itemsCount = 0,
  });
}

class InvoicesScreen extends ConsumerStatefulWidget {
  const InvoicesScreen({super.key});

  @override
  ConsumerState<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends ConsumerState<InvoicesScreen> {
  bool _sidebarCollapsed = false;
  String _selectedNavId = 'sales';
  String _activeTab = 'all';
  String _searchQuery = '';
  final Set<String> _selectedInvoices = {};
  bool _isGridView = false;

  final List<InvoiceModel> _allInvoices = [
    InvoiceModel(id: 'INV-2024-001', customer: 'محمد العلي', date: DateTime(2026, 2, 9), amount: 1250.00, status: 'paid', paymentMethod: 'card', itemsCount: 5),
    InvoiceModel(id: 'INV-2024-002', customer: 'سارة أحمد', date: DateTime(2026, 2, 8), amount: 540.50, status: 'pending', paymentMethod: 'cash', itemsCount: 3),
    InvoiceModel(id: 'INV-2024-003', customer: 'خالد يوسف', date: DateTime(2026, 2, 1), amount: 3200.00, status: 'overdue', paymentMethod: 'wallet', itemsCount: 8),
    InvoiceModel(id: 'INV-2024-004', customer: 'منى سالم', date: DateTime(2026, 1, 28), amount: 850.00, status: 'paid', paymentMethod: 'card', itemsCount: 4),
    InvoiceModel(id: 'INV-2024-005', customer: 'فهد عبدالله', date: DateTime(2026, 1, 25), amount: 1780.00, status: 'paid', paymentMethod: 'cash', itemsCount: 7),
    InvoiceModel(id: 'INV-2024-006', customer: 'نورة خالد', date: DateTime(2026, 1, 20), amount: 920.00, status: 'cancelled', paymentMethod: 'card', itemsCount: 2),
  ];

  List<InvoiceModel> get _filteredInvoices {
    var list = _allInvoices;
    if (_activeTab != 'all') {
      list = list.where((i) => i.status == _activeTab).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((i) => i.id.toLowerCase().contains(q) || i.customer.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  int get _pendingCount => _allInvoices.where((i) => i.status == 'pending').length;

  void _handleNavigation(AppSidebarItem item) {
    setState(() => _selectedNavId = item.id);
    switch (item.id) {
      case 'dashboard': context.go(AppRoutes.dashboard); break;
      case 'pos': context.go(AppRoutes.pos); break;
      case 'products': context.push(AppRoutes.products); break;
      case 'inventory': context.push(AppRoutes.inventory); break;
      case 'customers': context.push(AppRoutes.customers); break;
      case 'invoices': break;
      case 'sales': break;
      case 'orders': context.push(AppRoutes.orders); break;
      case 'reports': context.push(AppRoutes.reports); break;
    }
  }

  void _copyInvoiceId(String id) {
    Clipboard.setData(ClipboardData(text: id));
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${l10n.copiedSuccess}: $id'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showCreateInvoiceDialog() {
    showDialog(context: context, barrierDismissible: true, builder: (context) => const CreateInvoiceDialog());
  }

  void _showDeleteDialog(InvoiceModel invoice) {
    showDialog(
      context: context,
      builder: (ctx) => DeleteInvoiceDialog(
        onConfirm: () {
          setState(() => _allInvoices.remove(invoice));
          Navigator.pop(ctx);
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.invoiceDeleted), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          );
        },
      ),
    );
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
      floatingActionButton: !isWideScreen
          ? FloatingActionButton(
              onPressed: _showCreateInvoiceDialog,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            )
          : null,
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
                _buildHeader(context, isWideScreen, isDark, l10n),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
                    child: Column(
                      children: [
                        _buildStatsSection(l10n, isDark, isWideScreen),
                        SizedBox(height: isMediumScreen ? 24 : 16),
                        _buildChartSection(l10n, isDark, isWideScreen),
                        SizedBox(height: isMediumScreen ? 24 : 16),
                        InvoiceFilters(
                          activeTab: _activeTab,
                          onTabChanged: (tab) => setState(() => _activeTab = tab),
                          isGridView: _isGridView,
                          onViewToggle: () => setState(() => _isGridView = !_isGridView),
                          onReset: () => setState(() { _activeTab = 'all'; _searchQuery = ''; }),
                        ),
                        const SizedBox(height: 16),
                        InvoiceDataTable(
                          invoices: _filteredInvoices,
                          selectedIds: _selectedInvoices,
                          onSelectAll: (selected) {
                            setState(() {
                              if (selected) { _selectedInvoices.addAll(_filteredInvoices.map((i) => i.id)); }
                              else { _selectedInvoices.clear(); }
                            });
                          },
                          onSelectInvoice: (id, selected) {
                            setState(() { if (selected) { _selectedInvoices.add(id); } else { _selectedInvoices.remove(id); } });
                          },
                          onCopyId: _copyInvoiceId,
                          onView: (invoice) => context.push(AppRoutes.invoiceDetailPath(invoice.id)),
                          onDelete: _showDeleteDialog,
                          isMobile: !isMediumScreen,
                        ),
                        const SizedBox(height: 24),
                        _buildFooter(l10n, isDark),
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

  Widget _buildHeader(BuildContext context, bool isWideScreen, bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        border: Border(bottom: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: isWideScreen ? () => setState(() => _sidebarCollapsed = !_sidebarCollapsed) : () => Scaffold.of(context).openDrawer(),
            icon: Icon(Icons.menu_rounded, color: isDark ? AppColors.textMutedDark : AppColors.textSecondary),
          ),
          const SizedBox(width: 8),
          Text(l10n.invoicesTitle, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
          if (isWideScreen) ...[
            Container(height: 28, width: 1, margin: const EdgeInsets.symmetric(horizontal: 16), color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
            FilledButton.icon(
              onPressed: _showCreateInvoiceDialog,
              icon: const Icon(Icons.add, size: 18),
              label: Text(l10n.createInvoice),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              onSelected: (value) {},
              offset: const Offset(0, 40),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              itemBuilder: (context) => [
                PopupMenuItem(value: 'export', child: Row(children: [const Icon(Icons.file_download_outlined, size: 18, color: AppColors.primary), const SizedBox(width: 8), Text(l10n.exportAll)])),
                PopupMenuItem(value: 'print', child: Row(children: [const Icon(Icons.print_outlined, size: 18, color: AppColors.primary), const SizedBox(width: 8), Text(l10n.printReport)])),
              ],
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border)),
                child: Row(children: [
                  Text(l10n.more, style: TextStyle(fontSize: 14, color: isDark ? AppColors.textMutedDark : AppColors.textSecondary)),
                  const SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down, size: 16, color: isDark ? AppColors.textMutedDark : AppColors.textSecondary),
                ]),
              ),
            ),
          ],
          const Spacer(),
          if (isWideScreen)
            SizedBox(
              width: 300,
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: l10n.searchInvoiceHint,
                  hintStyle: TextStyle(color: isDark ? AppColors.textMutedDark : AppColors.textMuted, fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: isDark ? AppColors.textMutedDark : AppColors.textMuted),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF0F172A) : AppColors.backgroundSecondary,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.5))),
                ),
                style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary, fontSize: 14),
              ),
            ),
          const SizedBox(width: 8),
          IconButton(onPressed: () {}, icon: Badge(smallSize: 8, backgroundColor: AppColors.secondary, child: Icon(Icons.notifications_outlined, color: isDark ? AppColors.textMutedDark : AppColors.textSecondary))),
          IconButton(onPressed: () {}, icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: isDark ? const Color(0xFFFBBF24) : AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildStatsSection(AppLocalizations l10n, bool isDark, bool isWideScreen) {
    final stats = [
      InvoiceStatData(title: l10n.totalInvoices, value: '1,248', icon: Icons.receipt_long, iconBgColor: AppColors.info.withValues(alpha: 0.1), iconColor: AppColors.info, gradientColor: AppColors.info, changeValue: '+12.5%', isPositive: true, subtitle: l10n.comparedToLastMonth),
      InvoiceStatData(title: l10n.totalPaid, value: '45,200 ${l10n.sar}', icon: Icons.check_circle, iconBgColor: AppColors.success.withValues(alpha: 0.1), iconColor: AppColors.success, gradientColor: AppColors.success, subtitle: l10n.ofTotalDue('75'), progressValue: 0.75),
      InvoiceStatData(title: l10n.totalPending, value: '12,450 ${l10n.sar}', icon: Icons.access_time, iconBgColor: AppColors.warning.withValues(alpha: 0.1), iconColor: AppColors.warning, gradientColor: AppColors.warning, subtitle: l10n.invoicesWaitingPayment(_pendingCount)),
      InvoiceStatData(title: l10n.totalOverdue, value: '2,300 ${l10n.sar}', icon: Icons.warning_amber, iconBgColor: AppColors.error.withValues(alpha: 0.1), iconColor: AppColors.error, gradientColor: AppColors.error, actionText: l10n.sendReminderNow, onAction: () {}),
    ];

    if (isWideScreen) {
      return Row(children: stats.map((s) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: InvoiceStatCard(data: s)))).toList());
    }
    return Wrap(
      spacing: 12, runSpacing: 12,
      children: stats.map((s) => SizedBox(width: (MediaQuery.of(context).size.width - 56) / 2, child: InvoiceStatCard(data: s, compact: true))).toList(),
    );
  }

  Widget _buildChartSection(AppLocalizations l10n, bool isDark, bool isWideScreen) {
    if (isWideScreen) {
      return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(flex: 2, child: InvoiceRevenueChart(isDark: isDark)),
        const SizedBox(width: 16),
        Expanded(flex: 1, child: InvoicePaymentMethods(isDark: isDark)),
      ]);
    }
    return Column(children: [
      InvoiceRevenueChart(isDark: isDark),
      const SizedBox(height: 16),
      InvoicePaymentMethods(isDark: isDark),
    ]);
  }

  Widget _buildFooter(AppLocalizations l10n, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Column(children: [
        Divider(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
        const SizedBox(height: 12),
        Text(l10n.allRightsReservedFooter, style: TextStyle(fontSize: 12, color: isDark ? AppColors.textMutedDark : AppColors.textMuted)),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          TextButton(onPressed: () {}, style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap), child: Text(l10n.privacyPolicyFooter, style: TextStyle(fontSize: 12, color: isDark ? AppColors.textMutedDark : AppColors.textMuted))),
          Text(' | ', style: TextStyle(fontSize: 12, color: isDark ? AppColors.textMutedDark : AppColors.textMuted)),
          TextButton(onPressed: () {}, style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap), child: Text(l10n.termsFooter, style: TextStyle(fontSize: 12, color: isDark ? AppColors.textMutedDark : AppColors.textMuted))),
          Text(' | ', style: TextStyle(fontSize: 12, color: isDark ? AppColors.textMutedDark : AppColors.textMuted)),
          TextButton(onPressed: () {}, style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap), child: Text(l10n.supportFooter, style: TextStyle(fontSize: 12, color: isDark ? AppColors.textMutedDark : AppColors.textMuted))),
        ]),
      ]),
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
}
