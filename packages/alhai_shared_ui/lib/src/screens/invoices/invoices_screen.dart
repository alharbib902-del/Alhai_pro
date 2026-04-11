/// شاشة الفواتير - Invoices Screen
///
/// تعرض قائمة الفواتير مع إحصائيات، مخطط إيرادات،
/// فلاتر، جدول بيانات، وإنشاء فاتورة جديدة
///
/// البيانات تأتي من قاعدة البيانات عبر invoicesListProvider
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import '../../core/validators/input_sanitizer.dart';
import '../../core/router/routes.dart';
import '../../core/utils/currency_formatter.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../providers/invoices_providers.dart';
import '../../widgets/invoices/invoice_stat_card.dart';
import '../../widgets/invoices/invoice_revenue_chart.dart';
import '../../widgets/invoices/invoice_payment_methods.dart';
import '../../widgets/invoices/invoice_data_table.dart';
import '../../widgets/invoices/invoice_filters.dart';
import '../../widgets/invoices/create_invoice_dialog.dart';
import '../../widgets/invoices/delete_invoice_dialog.dart';
import '../../widgets/common/app_empty_state.dart';
import '../../widgets/common/shimmer_loading.dart';

/// نموذج بيانات الفاتورة (واجهة UI)
/// يتم تحويل SalesTableData إلى هذا النموذج للعرض
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

  /// تحويل بيانات البيع من قاعدة البيانات إلى نموذج الفاتورة
  factory InvoiceModel.fromSalesData(SalesTableData sale) {
    // تحويل حالة البيع إلى حالة الفاتورة
    String status;
    switch (sale.status) {
      case 'completed':
        status = 'paid';
        break;
      case 'voided':
        status = 'cancelled';
        break;
      case 'pending':
        status = 'pending';
        break;
      default:
        status = sale.status;
    }

    return InvoiceModel(
      id: sale.receiptNo,
      customer: sale.customerName ?? '', // cashCustomer set in UI with l10n
      date: sale.createdAt,
      amount: sale.total,
      status: status,
      paymentMethod: sale.paymentMethod,
    );
  }
}

class InvoicesScreen extends ConsumerStatefulWidget {
  const InvoicesScreen({super.key});

  @override
  ConsumerState<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends ConsumerState<InvoicesScreen> {
  String _activeTab = 'all';
  String _searchQuery = '';
  final Set<String> _selectedInvoices = {};
  bool _isGridView = false;
  Timer? _searchDebounce;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  List<InvoiceModel> _filterInvoices(List<InvoiceModel> allInvoices) {
    var list = allInvoices;
    if (_activeTab != 'all') {
      list = list.where((i) => i.status == _activeTab).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where(
            (i) =>
                i.id.toLowerCase().contains(q) ||
                i.customer.toLowerCase().contains(q),
          )
          .toList();
    }
    return list;
  }

  void _copyInvoiceId(String id) {
    Clipboard.setData(ClipboardData(text: id));
    final l10n = AppLocalizations.of(context);
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
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const CreateInvoiceDialog(),
    );
  }

  void _showDeleteDialog(InvoiceModel invoice) {
    showDialog(
      context: context,
      builder: (ctx) => DeleteInvoiceDialog(
        onConfirm: () {
          Navigator.pop(ctx);
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.invoiceDeleted),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = context.isDesktop;
    final isMediumScreen = !context.isMobile;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    // جلب البيانات من قاعدة البيانات
    final invoicesAsync = ref.watch(invoicesListProvider);
    final statsAsync = ref.watch(invoicesStatsProvider);

    return Scaffold(
      floatingActionButton: !isWideScreen
          ? FloatingActionButton(
              onPressed: _showCreateInvoiceDialog,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            )
          : null,
      body: Column(
        children: [
          _buildHeader(context, isWideScreen, isDark, l10n),
          Expanded(
            child: invoicesAsync.when(
              loading: () => Padding(
                padding: EdgeInsets.all(
                  isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md,
                ),
                child: Column(
                  children: [
                    ShimmerStats(count: 4, isWide: isWideScreen),
                    SizedBox(height: AlhaiSpacing.lg),
                    const ShimmerList(itemCount: 6, itemHeight: 72),
                  ],
                ),
              ),
              error: (e, _) => AppErrorState.general(
                context,
                message: e.toString(),
                onRetry: () => ref.invalidate(invoicesListProvider),
              ),
              data: (salesList) {
                // تحويل بيانات المبيعات إلى نموذج الفواتير
                final allInvoices = salesList
                    .map((s) => InvoiceModel.fromSalesData(s))
                    .toList();
                final filteredInvoices = _filterInvoices(allInvoices);
                final pendingCount = allInvoices
                    .where((i) => i.status == 'pending')
                    .length;

                if (allInvoices.isEmpty) {
                  return AppEmptyState.noInvoices(context);
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(invoicesListProvider);
                    ref.invalidate(invoicesStatsProvider);
                  },
                  color: AppColors.primary,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(
                      isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md,
                    ),
                    child: Column(
                      children: [
                        _buildStatsSection(
                          l10n,
                          isDark,
                          isWideScreen,
                          statsAsync,
                          pendingCount,
                        ),
                        SizedBox(
                          height: isMediumScreen
                              ? AlhaiSpacing.lg
                              : AlhaiSpacing.md,
                        ),
                        _buildChartSection(l10n, isDark, isWideScreen),
                        SizedBox(
                          height: isMediumScreen
                              ? AlhaiSpacing.lg
                              : AlhaiSpacing.md,
                        ),
                        InvoiceFilters(
                          activeTab: _activeTab,
                          onTabChanged: (tab) =>
                              setState(() => _activeTab = tab),
                          isGridView: _isGridView,
                          onViewToggle: () =>
                              setState(() => _isGridView = !_isGridView),
                          onReset: () => setState(() {
                            _activeTab = 'all';
                            _searchQuery = '';
                          }),
                        ),
                        SizedBox(height: AlhaiSpacing.md),
                        InvoiceDataTable(
                          invoices: filteredInvoices,
                          selectedIds: _selectedInvoices,
                          onSelectAll: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedInvoices.addAll(
                                  filteredInvoices.map((i) => i.id),
                                );
                              } else {
                                _selectedInvoices.clear();
                              }
                            });
                          },
                          onSelectInvoice: (id, selected) {
                            setState(() {
                              if (selected) {
                                _selectedInvoices.add(id);
                              } else {
                                _selectedInvoices.remove(id);
                              }
                            });
                          },
                          onCopyId: _copyInvoiceId,
                          onView: (invoice) => context.push(
                            AppRoutes.invoiceDetailPath(invoice.id),
                          ),
                          onDelete: _showDeleteDialog,
                          isMobile: !isMediumScreen,
                        ),
                        SizedBox(height: AlhaiSpacing.lg),
                        _buildFooter(l10n, isDark),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    bool isWideScreen,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AlhaiSpacing.lg,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: isWideScreen
                ? null
                : () => Scaffold.of(context).openDrawer(),
            icon: Icon(
              Icons.menu_rounded,
              color: isDark ? AppColors.textMutedDark : AppColors.textSecondary,
            ),
          ),
          SizedBox(width: AlhaiSpacing.xs),
          Text(
            l10n.invoicesTitle,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          if (isWideScreen) ...[
            Container(
              height: 28,
              width: 1,
              margin: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.md),
              color: Theme.of(context).dividerColor,
            ),
            FilledButton.icon(
              onPressed: _showCreateInvoiceDialog,
              icon: const Icon(Icons.add, size: 18),
              label: Text(l10n.createInvoice),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AlhaiSpacing.mdl,
                  vertical: AlhaiSpacing.sm,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(width: AlhaiSpacing.xs),
            PopupMenuButton<String>(
              onSelected: (value) {},
              offset: const Offset(0, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'export',
                  child: Row(
                    children: [
                      const Icon(
                        Icons.file_download_outlined,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: AlhaiSpacing.xs),
                      Text(l10n.exportAll),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'print',
                  child: Row(
                    children: [
                      const Icon(
                        Icons.print_outlined,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: AlhaiSpacing.xs),
                      Text(l10n.printReport),
                    ],
                  ),
                ),
              ],
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AlhaiSpacing.sm,
                  vertical: AlhaiSpacing.xs,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Row(
                  children: [
                    Text(
                      l10n.more,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(width: AlhaiSpacing.xxs),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 16,
                      color: isDark
                          ? AppColors.textMutedDark
                          : AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ],
          const Spacer(),
          if (isWideScreen)
            SizedBox(
              width: 300,
              child: TextField(
                maxLength: 100,
                onChanged: (v) {
                  final sanitized = InputSanitizer.sanitize(v);
                  _searchDebounce?.cancel();
                  _searchDebounce = Timer(
                    const Duration(milliseconds: 300),
                    () {
                      setState(() => _searchQuery = sanitized);
                    },
                  );
                },
                decoration: InputDecoration(
                  counterText: '',
                  hintText: l10n.searchInvoiceHint,
                  hintStyle: TextStyle(
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMuted,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMuted,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AlhaiSpacing.md,
                    vertical: AlhaiSpacing.sm,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 14,
                ),
              ),
            ),
          SizedBox(width: AlhaiSpacing.xs),
          IconButton(
            onPressed: () {},
            icon: Badge(
              smallSize: 8,
              backgroundColor: AppColors.secondary,
              child: Icon(
                Icons.notifications_outlined,
                color: isDark
                    ? AppColors.textMutedDark
                    : AppColors.textSecondary,
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: isDark ? AppColors.warning : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(
    AppLocalizations l10n,
    bool isDark,
    bool isWideScreen,
    AsyncValue statsAsync,
    int pendingCount,
  ) {
    // استخدام الإحصائيات الحقيقية من قاعدة البيانات
    final statsData = statsAsync.valueOrNull;
    final totalCount = statsData?.count ?? 0;
    final totalAmount = statsData?.total ?? 0.0;
    final formattedTotal = CurrencyFormatter.formatCompact(totalAmount);
    final formattedAverage = CurrencyFormatter.formatCompact(
      statsData?.average ?? 0,
    );

    final stats = [
      InvoiceStatData(
        title: l10n.totalInvoices,
        value: '$totalCount',
        icon: Icons.receipt_long,
        iconBgColor: AppColors.info.withValues(alpha: 0.1),
        iconColor: AppColors.info,
        gradientColor: AppColors.info,
        changeValue: '',
        isPositive: true,
        subtitle: l10n.comparedToLastMonth,
      ),
      InvoiceStatData(
        title: l10n.totalPaid,
        value: formattedTotal,
        icon: Icons.check_circle,
        iconBgColor: AppColors.success.withValues(alpha: 0.1),
        iconColor: AppColors.success,
        gradientColor: AppColors.success,
        subtitle: l10n.sar,
      ),
      InvoiceStatData(
        title: l10n.totalPending,
        value: '$pendingCount',
        icon: Icons.access_time,
        iconBgColor: AppColors.warning.withValues(alpha: 0.1),
        iconColor: AppColors.warning,
        gradientColor: AppColors.warning,
        subtitle: l10n.invoicesWaitingPayment(pendingCount),
      ),
      InvoiceStatData(
        title: l10n.totalOverdue,
        value: formattedAverage,
        icon: Icons.trending_up,
        iconBgColor: AppColors.error.withValues(alpha: 0.1),
        iconColor: AppColors.error,
        gradientColor: AppColors.error,
        subtitle: l10n.averageInvoice,
      ),
    ];

    if (isWideScreen) {
      return Row(
        children: stats
            .map(
              (s) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: InvoiceStatCard(data: s),
                ),
              ),
            )
            .toList(),
      );
    }
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: stats
          .map(
            (s) => SizedBox(
              width: (context.screenWidth - 56) / 2,
              child: InvoiceStatCard(data: s, compact: true),
            ),
          )
          .toList(),
    );
  }

  Widget _buildChartSection(
    AppLocalizations l10n,
    bool isDark,
    bool isWideScreen,
  ) {
    if (isWideScreen) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: InvoiceRevenueChart(isDark: isDark)),
          SizedBox(width: AlhaiSpacing.md),
          Expanded(flex: 1, child: InvoicePaymentMethods(isDark: isDark)),
        ],
      );
    }
    return Column(
      children: [
        InvoiceRevenueChart(isDark: isDark),
        SizedBox(height: AlhaiSpacing.md),
        InvoicePaymentMethods(isDark: isDark),
      ],
    );
  }

  Widget _buildFooter(AppLocalizations l10n, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AlhaiSpacing.md,
        bottom: AlhaiSpacing.xs,
      ),
      child: Column(
        children: [
          Divider(color: Theme.of(context).dividerColor),
          SizedBox(height: AlhaiSpacing.sm),
          Text(
            l10n.allRightsReservedFooter,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
            ),
          ),
          SizedBox(height: AlhaiSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AlhaiSpacing.xs,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  l10n.privacyPolicyFooter,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMuted,
                  ),
                ),
              ),
              Text(
                ' | ',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AlhaiSpacing.xs,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  l10n.termsFooter,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMuted,
                  ),
                ),
              ),
              Text(
                ' | ',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AlhaiSpacing.xs,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  l10n.supportFooter,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
