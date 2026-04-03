import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alhai_design_system/alhai_design_system.dart' show AlhaiSpacing;
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_database/alhai_database.dart';
import 'purchase_report_screen.dart';
import 'balance_sheet_screen.dart';
import 'cash_flow_screen.dart';
import 'debt_aging_report_screen.dart';
import 'comparison_report_screen.dart';
import 'zakat_report_screen.dart';

// ============================================================================
// LOCAL PROVIDER: fallback for when reportsServiceProvider is not initialized
// ============================================================================

/// Provider for today's sales stats, querying DB directly
final _reportsTodayStatsProvider = FutureProvider.autoDispose<SalesStats?>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return null;
  final db = GetIt.I<AppDatabase>();
  final today = DateTime.now();
  final startOfDay = DateTime(today.year, today.month, today.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));
  return db.salesDao.getSalesStats(storeId, startDate: startOfDay, endDate: endOfDay);
});

/// Provider for this week's sales stats
final _reportsWeekStatsProvider = FutureProvider.autoDispose<SalesStats?>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return null;
  final db = GetIt.I<AppDatabase>();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final startOfWeek = today.subtract(Duration(days: today.weekday % 7));
  return db.salesDao.getSalesStats(storeId, startDate: startOfWeek, endDate: now);
});

/// Provider for this month's sales stats
final _reportsMonthStatsProvider = FutureProvider.autoDispose<SalesStats?>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return null;
  final db = GetIt.I<AppDatabase>();
  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);
  return db.salesDao.getSalesStats(storeId, startDate: startOfMonth, endDate: now);
});

/// Provider for custom date range stats
final _reportsCustomStatsProvider = FutureProvider.autoDispose
    .family<SalesStats?, ({DateTime start, DateTime end})>((ref, range) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return null;
  final db = GetIt.I<AppDatabase>();
  return db.salesDao.getSalesStats(storeId, startDate: range.start, endDate: range.end);
});

/// Provider for payment method stats for the period
final _reportsPeriodPaymentStatsProvider = FutureProvider.autoDispose
    .family<List<PaymentMethodStats>, ({DateTime start, DateTime end})>((ref, range) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return [];
  final db = GetIt.I<AppDatabase>();
  return db.salesDao.getPaymentMethodStats(storeId, startDate: range.start, endDate: range.end);
});

/// Provider for inventory summary
final _reportsInventorySummaryProvider = FutureProvider.autoDispose<({int total, int lowStock, int outOfStock})>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return (total: 0, lowStock: 0, outOfStock: 0);
  final db = GetIt.I<AppDatabase>();
  final products = await db.productsDao.getAllProducts(storeId);
  int lowStock = 0;
  int outOfStock = 0;
  for (final p in products) {
    if (p.stockQty <= 0) {
      outOfStock++;
    } else if (p.stockQty <= p.minQty) {
      lowStock++;
    }
  }
  return (total: products.length, lowStock: lowStock, outOfStock: outOfStock);
});

/// شاشة التقارير - تصميم Web محسّن مع بطاقات تقارير احترافية
class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  final FocusNode _keyboardFocusNode = FocusNode();
  String _selectedPeriod = 'today'; // today, week, month, custom
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  /// Get the date range for the current period
  ({DateTime start, DateTime end}) _getDateRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (_selectedPeriod) {
      case 'week':
        final startOfWeek = today.subtract(Duration(days: today.weekday % 7));
        return (start: startOfWeek, end: now);
      case 'month':
        final startOfMonth = DateTime(now.year, now.month, 1);
        return (start: startOfMonth, end: now);
      case 'custom':
        if (_startDate != null && _endDate != null) {
          return (start: _startDate!, end: _endDate!.add(const Duration(days: 1)));
        }
        return (start: today, end: today.add(const Duration(days: 1)));
      case 'today':
      default:
        return (start: today, end: today.add(const Duration(days: 1)));
    }
  }

  /// Get the active stats provider based on the selected period
  AsyncValue<SalesStats?> _getActiveStats() {
    switch (_selectedPeriod) {
      case 'today':
        return ref.watch(_reportsTodayStatsProvider);
      case 'week':
        return ref.watch(_reportsWeekStatsProvider);
      case 'month':
        return ref.watch(_reportsMonthStatsProvider);
      case 'custom':
        if (_startDate != null && _endDate != null) {
          return ref.watch(_reportsCustomStatsProvider(
              (start: _startDate!, end: _endDate!.add(const Duration(days: 1)))));
        }
        return ref.watch(_reportsTodayStatsProvider);
      default:
        return ref.watch(_reportsTodayStatsProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.screenWidth >= AppSizes.breakpointTablet;
    final l10n = AppLocalizations.of(context)!;

    return KeyboardListener(
      focusNode: _keyboardFocusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Column(
          children: [
            // Header
            _buildHeader(context, l10n),
            // Period Selector
            _buildPeriodSelector(l10n),
            // Reports Grid
            Expanded(
              child: _buildReportsGrid(isDesktop, l10n),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    final isDesktop = context.screenWidth >= AppSizes.breakpointTablet;

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSizes.sm),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      ),
                      child: const Icon(
                        Icons.analytics_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Text(
                      l10n.reports,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  l10n.reportsAnalysis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Actions
          if (isDesktop) ...[
            AppButton.secondary(
              onPressed: () {},
              icon: Icons.download_rounded,
              label: l10n.exportAll,
            ),
            const SizedBox(width: AppSizes.sm),
          ],
          AppButton.primary(
            onPressed: () => _showCustomDateDialog(),
            icon: Icons.calendar_today_rounded,
            label: isDesktop ? l10n.customPeriod : '',
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Row(
        children: [
          _PeriodChip(
            label: l10n.today,
            icon: Icons.today_rounded,
            isSelected: _selectedPeriod == 'today',
            onTap: () => setState(() => _selectedPeriod = 'today'),
          ),
          const SizedBox(width: AppSizes.sm),
          _PeriodChip(
            label: l10n.thisWeek,
            icon: Icons.date_range_rounded,
            isSelected: _selectedPeriod == 'week',
            onTap: () => setState(() => _selectedPeriod = 'week'),
          ),
          const SizedBox(width: AppSizes.sm),
          _PeriodChip(
            label: l10n.thisMonth,
            icon: Icons.calendar_month_rounded,
            isSelected: _selectedPeriod == 'month',
            onTap: () => setState(() => _selectedPeriod = 'month'),
          ),
          if (_selectedPeriod == 'custom' && _startDate != null && _endDate != null) ...[
            const SizedBox(width: AppSizes.sm),
            _PeriodChip(
              label: '${_formatDate(_startDate!)} - ${_formatDate(_endDate!)}',
              icon: Icons.tune_rounded,
              isSelected: true,
              onTap: () => _showCustomDateDialog(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReportsGrid(bool isDesktop, AppLocalizations l10n) {
    final statsAsync = _getActiveStats();
    final inventoryAsync = ref.watch(_reportsInventorySummaryProvider);
    final dateRange = _getDateRange();
    final paymentAsync = ref.watch(_reportsPeriodPaymentStatsProvider(dateRange));

    // Derive sales data from the stats provider
    return statsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: AlhaiSpacing.md),
            Text(l10n.errorOccurred,
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: AlhaiSpacing.xs),
            TextButton(
              onPressed: () {
                ref.invalidate(_reportsTodayStatsProvider);
                ref.invalidate(_reportsWeekStatsProvider);
                ref.invalidate(_reportsMonthStatsProvider);
              },
              child: Text(l10n.retry),
            ),
          ],
        ),
      ),
      data: (stats) {
        final salesTotal = stats?.total ?? 0.0;
        final salesCount = stats?.count ?? 0;
        final salesAvg = stats?.average ?? 0.0;

        // Inventory data
        final inv = inventoryAsync.valueOrNull;
        final invTotal = inv?.total ?? 0;
        final invLowStock = inv?.lowStock ?? 0;
        final invOutOfStock = inv?.outOfStock ?? 0;

        // Payment stats (used in purchase reports when available)
        final _ = paymentAsync.valueOrNull ?? [];

        // Tax estimate (15% VAT from total)
        final taxEstimate = salesTotal * 0.15 / 1.15;

        final reports = [
          _ReportData(
            id: 'sales',
            icon: Icons.point_of_sale_rounded,
            title: l10n.salesReport,
            subtitle: l10n.salesReportDesc,
            color: AppColors.primary,
            stats: [
              _ReportStat(l10n.totalSales, '${salesTotal.toStringAsFixed(0)} ${l10n.sar}'),
              _ReportStat(l10n.invoices, '$salesCount'),
              _ReportStat(l10n.averageAmount, '${salesAvg.toStringAsFixed(0)} ${l10n.sar}'),
            ],
          ),
          _ReportData(
            id: 'profit',
            icon: Icons.trending_up_rounded,
            title: l10n.profitReport,
            subtitle: l10n.profitReportDesc,
            color: AppColors.success,
            stats: [
              _ReportStat(l10n.revenue, '${salesTotal.toStringAsFixed(0)} ${l10n.sar}'),
              _ReportStat(l10n.costs, '-'),
              _ReportStat(l10n.netProfit, '-'),
            ],
          ),
          _ReportData(
            id: 'inventory',
            icon: Icons.inventory_2_rounded,
            title: l10n.inventoryReport,
            subtitle: l10n.inventoryReportDesc,
            color: AppColors.info,
            stats: [
              _ReportStat(l10n.products, '$invTotal'),
              _ReportStat(l10n.lowStock, '$invLowStock'),
              _ReportStat(l10n.outOfStock, '$invOutOfStock'),
            ],
          ),
          _ReportData(
            id: 'vat',
            icon: Icons.percent_rounded,
            title: l10n.vatReport,
            subtitle: l10n.vatReportDesc,
            color: AppColors.secondary,
            stats: [
              _ReportStat(l10n.salesTax, '${taxEstimate.toStringAsFixed(0)} ${l10n.sar}'),
              _ReportStat(l10n.purchasesTax, '-'),
              _ReportStat(l10n.taxDue, '${taxEstimate.toStringAsFixed(0)} ${l10n.sar}'),
            ],
          ),
          _ReportData(
            id: 'customers',
            icon: Icons.people_rounded,
            title: l10n.customerReport,
            subtitle: l10n.customerReportDesc,
            color: Colors.indigo,
            stats: [
              _ReportStat(l10n.customers, '-'),
              _ReportStat(l10n.debts, '-'),
              _ReportStat(l10n.paidDebts, '-'),
            ],
          ),
          _ReportData(
            id: 'purchases',
            icon: Icons.shopping_cart_rounded,
            title: l10n.purchasesReport,
            subtitle: l10n.purchasesReportDesc,
            color: Colors.orange,
            stats: [
              _ReportStat(l10n.purchases, '-'),
              _ReportStat(l10n.invoices, '-'),
              _ReportStat(l10n.suppliers, '-'),
            ],
            screen: const PurchaseReportScreen(),
          ),
          _ReportData(
            id: 'balance_sheet',
            icon: Icons.account_balance_rounded,
            title: 'الميزانية العمومية',
            subtitle: 'الأصول والالتزامات وحقوق الملكية',
            color: Colors.indigo,
            stats: [
              _ReportStat('الأصول', '-'),
              _ReportStat('الالتزامات', '-'),
              _ReportStat('حقوق الملكية', '-'),
            ],
            screen: const BalanceSheetScreen(),
          ),
          _ReportData(
            id: 'cash_flow',
            icon: Icons.water_rounded,
            title: 'قائمة التدفق النقدي',
            subtitle: 'التدفقات التشغيلية والاستثمارية والتمويلية',
            color: Colors.teal,
            stats: [
              _ReportStat('التشغيلي', '-'),
              _ReportStat('الاستثماري', '-'),
              _ReportStat('صافي التدفق', '-'),
            ],
            screen: const CashFlowScreen(),
          ),
          _ReportData(
            id: 'debt_aging',
            icon: Icons.hourglass_bottom_rounded,
            title: 'تقرير أعمار الديون',
            subtitle: 'تصنيف الديون: 30 / 60 / 90 يوم',
            color: Colors.deepOrange,
            stats: [
              _ReportStat('0-30 يوم', '-'),
              _ReportStat('31-90 يوم', '-'),
              _ReportStat('+90 يوم', '-'),
            ],
            screen: const DebtAgingReportScreen(),
          ),
          _ReportData(
            id: 'comparison',
            icon: Icons.compare_arrows_rounded,
            title: 'تقرير المقارنة',
            subtitle: 'مقارنة الفترة الحالية بالسابقة',
            color: Colors.purple,
            stats: [
              _ReportStat('المبيعات', '-'),
              _ReportStat('المشتريات', '-'),
              _ReportStat('الربح', '-'),
            ],
            screen: const ComparisonReportScreen(),
          ),
          _ReportData(
            id: 'zakat',
            icon: Icons.mosque_rounded,
            title: 'حساب الزكاة',
            subtitle: 'تقدير الزكاة الواجبة وفق الشريعة',
            color: Colors.green,
            stats: [
              _ReportStat('وعاء الزكاة', '-'),
              _ReportStat('نسبة الزكاة', '2.5%'),
              _ReportStat('المبلغ الواجب', '-'),
            ],
            screen: const ZakatReportScreen(),
          ),
        ];

        return GridView.builder(
          padding: const EdgeInsets.all(AppSizes.md),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: isDesktop ? 400 : 500,
            childAspectRatio: isDesktop ? 1.4 : 1.2,
            crossAxisSpacing: AppSizes.md,
            mainAxisSpacing: AppSizes.md,
          ),
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final report = reports[index];
            return _ReportCard(
              report: report,
              onTap: () {
                if (report.screen != null) {
                  Navigator.push(context,
                    MaterialPageRoute(builder: (_) => report.screen!));
                } else {
                  _showReportDialog(report);
                }
              },
              onExport: () => _exportReport(report.id),
            );
          },
        );
      },
    );
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    // Keyboard shortcuts for period selection
    if (event.logicalKey == LogicalKeyboardKey.digit1) {
      setState(() => _selectedPeriod = 'today');
    } else if (event.logicalKey == LogicalKeyboardKey.digit2) {
      setState(() => _selectedPeriod = 'week');
    } else if (event.logicalKey == LogicalKeyboardKey.digit3) {
      setState(() => _selectedPeriod = 'month');
    }
  }

  void _showReportDialog(_ReportData report) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: context.screenHeight * 0.8,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSizes.radiusXl),
          ),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: AppSizes.sm),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSizes.md),
                    decoration: BoxDecoration(
                      color: report.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                    child: Icon(report.icon, color: report.color, size: 28),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _getPeriodLabel(),
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  AppIconButton(
                    icon: Icons.download_rounded,
                    onPressed: () => _exportReport(report.id),
                    tooltip: l10n.exportAction,
                  ),
                  const SizedBox(width: AppSizes.xs),
                  AppIconButton(
                    icon: Icons.print_rounded,
                    onPressed: () {},
                    tooltip: l10n.printAction,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Stats Summary
            Padding(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Row(
                children: report.stats.map((stat) {
                  return Expanded(
                    child: Column(
                      children: [
                        Text(
                          stat.value,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: report.color,
                          ),
                        ),
                        const SizedBox(height: AppSizes.xs),
                        Text(
                          stat.label,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const Divider(height: 1),
            // Content
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bar_chart_rounded,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: AppSizes.md),
                    Text(
                      l10n.viewReport,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
            // Actions
            Padding(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Row(
                children: [
                  Expanded(
                    child: AppButton.secondary(
                      onPressed: () => Navigator.pop(context),
                      label: l10n.close,
                      isFullWidth: true,
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: AppButton.primary(
                      onPressed: () {
                        Navigator.pop(context);
                        _exportReport(report.id);
                      },
                      icon: Icons.download_rounded,
                      label: l10n.exportPdf,
                      isFullWidth: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomDateDialog() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : DateTimeRange(
              start: DateTime.now().subtract(const Duration(days: 30)),
              end: DateTime.now(),
            ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedPeriod = 'custom';
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _exportReport(String reportId) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.download_rounded, color: Colors.white),
            const SizedBox(width: AppSizes.sm),
            Text(l10n.exportingReport),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
      ),
    );
  }

  String _getPeriodLabel() {
    final l10n = AppLocalizations.of(context)!;
    switch (_selectedPeriod) {
      case 'today':
        return l10n.today;
      case 'week':
        return l10n.thisWeek;
      case 'month':
        return l10n.thisMonth;
      case 'custom':
        if (_startDate != null && _endDate != null) {
          return '${_formatDate(_startDate!)} - ${_formatDate(_endDate!)}';
        }
        return l10n.customPeriod;
      default:
        return '';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Period Selection Chip
class _PeriodChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: isSelected ? AppColors.primary : theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: AppSizes.xs),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Report Data Model
class _ReportData {
  final String id;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final List<_ReportStat> stats;
  final Widget? screen;

  const _ReportData({
    required this.id,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.stats,
    this.screen,
  });
}

class _ReportStat {
  final String label;
  final String value;

  const _ReportStat(this.label, this.value);
}

/// Report Card Widget
class _ReportCard extends StatefulWidget {
  final _ReportData report;
  final VoidCallback onTap;
  final VoidCallback onExport;

  const _ReportCard({
    required this.report,
    required this.onTap,
    required this.onExport,
  });

  @override
  State<_ReportCard> createState() => _ReportCardState();
}

class _ReportCardState extends State<_ReportCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(
            color: _isHovered ? widget.report.color : Theme.of(context).dividerColor,
          ),
          boxShadow: _isHovered ? AppSizes.shadowMd : AppSizes.shadowSm,
        ),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSizes.sm),
                      decoration: BoxDecoration(
                        color: widget.report.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      ),
                      child: Icon(
                        widget.report.icon,
                        color: widget.report.color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.report.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.report.subtitle,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_isHovered)
                      AppIconButton(
                        icon: Icons.download_rounded,
                        onPressed: widget.onExport,
                        tooltip: AppLocalizations.of(context)!.exportAction,
                      ),
                  ],
                ),
                const Spacer(),
                // Stats
                Row(
                  children: widget.report.stats.map((stat) {
                    return Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stat.value,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: widget.report.color,
                            ),
                          ),
                          const SizedBox(height: AlhaiSpacing.xxxs),
                          Text(
                            stat.label,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSizes.md),
                // View Report Button
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
                  decoration: BoxDecoration(
                    color: widget.report.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.viewReport,
                        style: TextStyle(
                          color: widget.report.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: AppSizes.xs),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                        color: widget.report.color,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
