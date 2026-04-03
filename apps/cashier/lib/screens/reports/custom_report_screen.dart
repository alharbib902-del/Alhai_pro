/// Custom Report Screen - Flexible report builder
///
/// Report type selector (sales, inventory, customers, payments),
/// date range picker, group by (day, week, month), generate button,
/// results table display. Read-only for cashier.
/// Supports: RTL Arabic, dark/light theme, responsive layout.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_design_system/alhai_design_system.dart' show AlhaiSpacing;
// alhai_design_system is re-exported via alhai_shared_ui
import '../../core/services/sentry_service.dart';

/// شاشة التقارير المخصصة
class CustomReportScreen extends ConsumerStatefulWidget {
  const CustomReportScreen({super.key});

  @override
  ConsumerState<CustomReportScreen> createState() =>
      _CustomReportScreenState();
}

class _CustomReportScreenState extends ConsumerState<CustomReportScreen> {
  final _db = GetIt.I<AppDatabase>();

  // Report config
  String _reportType = 'sales';
  String _groupBy = 'day';
  DateTimeRange? _dateRange;
  bool _isLoading = false;
  bool _hasGenerated = false;

  // Results
  List<Map<String, dynamic>> _results = [];
  double _totalValue = 0;
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    // Default to current month
    final now = DateTime.now();
    _dateRange = DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: now,
    );
  }

  Future<void> _generateReport() async {
    setState(() {
      _isLoading = true;
      _hasGenerated = false;
    });
    try {
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null || _dateRange == null) return;

      List<Map<String, dynamic>> results = [];
      double total = 0;
      int count = 0;

      switch (_reportType) {
        case 'sales':
          results = await _generateSalesReport(storeId);
          break;
        case 'inventory':
          results = await _generateInventoryReport(storeId);
          break;
        case 'customers':
          results = await _generateCustomersReport(storeId);
          break;
        case 'payments':
          results = await _generatePaymentsReport(storeId);
          break;
      }

      for (final row in results) {
        total += (row['value'] as double?) ?? 0;
        count += (row['count'] as int?) ?? 0;
      }

      if (mounted) {
        setState(() {
          _results = results;
          _totalValue = total;
          _totalCount = count;
          _isLoading = false;
          _hasGenerated = true;
        });
      }
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Generate custom report');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasGenerated = true;
          _results = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<List<Map<String, dynamic>>> _generateSalesReport(
      String storeId) async {
    final sales = await _db.salesDao.getAllSales(storeId);
    final filtered = sales.where((o) {
      return o.createdAt.isAfter(_dateRange!.start) &&
          o.createdAt
              .isBefore(_dateRange!.end.add(const Duration(days: 1)));
    }).toList();

    return _groupResults(filtered.map((o) => _GroupItem(
      date: o.createdAt,
      value: o.total,
      count: 1,
    )).toList());
  }

  Future<List<Map<String, dynamic>>> _generateInventoryReport(
      String storeId) async {
    final products = await _db.productsDao.getAllProducts(storeId);
    // For inventory, show product stock levels grouped by category
    final Map<String, _GroupItem> grouped = {};
    for (final product in products) {
      final key = product.categoryId ?? 'uncategorized';
      final existing = grouped[key];
      if (existing != null) {
        grouped[key] = _GroupItem(
          date: DateTime.now(),
          value: existing.value + (product.price * product.stockQty),
          count: existing.count + product.stockQty,
          label: key,
        );
      } else {
        grouped[key] = _GroupItem(
          date: DateTime.now(),
          value: product.price * product.stockQty,
          count: product.stockQty,
          label: key,
        );
      }
    }
    return grouped.entries.map((e) => {
      'label': e.key,
      'value': e.value.value,
      'count': e.value.count,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _generateCustomersReport(
      String storeId) async {
    final customers = await _db.customersDao.getAllCustomers(storeId);
    final filtered = customers.where((c) {
      return c.createdAt.isAfter(_dateRange!.start) &&
          c.createdAt
              .isBefore(_dateRange!.end.add(const Duration(days: 1)));
    }).toList();

    return _groupResults(filtered.map((c) => _GroupItem(
      date: c.createdAt,
      value: 0,
      count: 1,
    )).toList());
  }

  Future<List<Map<String, dynamic>>> _generatePaymentsReport(
      String storeId) async {
    final sales = await _db.salesDao.getAllSales(storeId);
    final filtered = sales.where((o) {
      return o.createdAt.isAfter(_dateRange!.start) &&
          o.createdAt
              .isBefore(_dateRange!.end.add(const Duration(days: 1)));
    }).toList();

    // Group by payment method instead of date
    final Map<String, double> byMethod = {};
    final Map<String, int> countByMethod = {};
    for (final order in filtered) {
      final method = order.paymentMethod;
      byMethod[method] = (byMethod[method] ?? 0) + order.total;
      countByMethod[method] = (countByMethod[method] ?? 0) + 1;
    }

    return byMethod.entries.map((e) => {
      'label': e.key,
      'value': e.value,
      'count': countByMethod[e.key] ?? 0,
    }).toList();
  }

  List<Map<String, dynamic>> _groupResults(List<_GroupItem> items) {
    final Map<String, Map<String, dynamic>> grouped = {};

    for (final item in items) {
      final key = _getGroupKey(item.date);
      if (grouped.containsKey(key)) {
        grouped[key]!['value'] =
            (grouped[key]!['value'] as double) + item.value;
        grouped[key]!['count'] =
            (grouped[key]!['count'] as int) + item.count;
      } else {
        grouped[key] = {
          'label': key,
          'value': item.value,
          'count': item.count,
        };
      }
    }

    final result = grouped.values.toList();
    result.sort((a, b) =>
        (a['label'] as String).compareTo(b['label'] as String));
    return result;
  }

  String _getGroupKey(DateTime date) {
    switch (_groupBy) {
      case 'day':
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      case 'week':
        final weekStart = date.subtract(Duration(days: date.weekday - 1));
        return '${weekStart.year}-W${_weekNumber(weekStart).toString().padLeft(2, '0')}';
      case 'month':
        return '${date.year}-${date.month.toString().padLeft(2, '0')}';
      default:
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }

  int _weekNumber(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
    return ((dayOfYear + 10) / 7).floor();
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = context.isDesktop;
    final isMediumScreen = !context.isMobile;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        AppHeader(
          title: 'Custom Report',
          subtitle:
              'Report Builder \u2022 ${l10n.mainBranch}',
          showSearch: false,
          searchHint: l10n.searchPlaceholder,
          onMenuTap: isWideScreen
              ? null
              : () => Scaffold.of(context).openDrawer(),
          onNotificationsTap: () => context.push('/notifications'),
          notificationsCount: 3,
          userName: l10n.cashCustomer,
          userRole: l10n.branchManager,
          onUserTap: () {},
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Config section
                if (isWideScreen)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          flex: 3,
                          child: _buildConfigCard(isDark, l10n)),
                      const SizedBox(width: AlhaiSpacing.lg),
                      Expanded(
                          flex: 2,
                          child: _buildDateRangeCard(
                              isDark, l10n, isMediumScreen)),
                    ],
                  )
                else ...[
                  _buildConfigCard(isDark, l10n),
                  SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
                  _buildDateRangeCard(isDark, l10n, isMediumScreen),
                ],
                SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
                // Generate button
                _buildGenerateButton(isDark, l10n),
                SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
                // Results
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(AlhaiSpacing.xxxl),
                    child: AppLoadingState(),
                  )
                else if (_hasGenerated)
                  _buildResults(isWideScreen, isMediumScreen, isDark, l10n),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfigCard(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.tune_rounded,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text('Report Settings',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.getTextPrimary(isDark))),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.mdl),
          // Report type
          Text('Report Type',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getTextSecondary(isDark))),
          const SizedBox(height: 10),
          _buildReportTypeSelector(isDark, l10n),
          const SizedBox(height: AlhaiSpacing.mdl),
          // Group by
          Text('Group By',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getTextSecondary(isDark))),
          const SizedBox(height: 10),
          _buildGroupBySelector(isDark, l10n),
        ],
      ),
    );
  }

  Widget _buildReportTypeSelector(bool isDark, AppLocalizations l10n) {
    final types = [
      _ReportTypeOption(
        key: 'sales',
        label: l10n.sales,
        icon: Icons.point_of_sale_rounded,
        color: AppColors.primary,
      ),
      _ReportTypeOption(
        key: 'inventory',
        label: l10n.inventory,
        icon: Icons.inventory_2_rounded,
        color: const Color(0xFF8B5CF6),
      ),
      _ReportTypeOption(
        key: 'customers',
        label: l10n.customers,
        icon: Icons.people_rounded,
        color: const Color(0xFFF97316),
      ),
      _ReportTypeOption(
        key: 'payments',
        label: l10n.payments,
        icon: Icons.payment_rounded,
        color: AppColors.success,
      ),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: types.map((type) {
        final isSelected = _reportType == type.key;
        return InkWell(
          onTap: () => setState(() => _reportType = type.key),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: AlhaiSpacing.md, vertical: AlhaiSpacing.sm),
            decoration: BoxDecoration(
              color: isSelected
                  ? type.color.withValues(alpha: isDark ? 0.2 : 0.1)
                  : AppColors.getSurfaceVariant(isDark),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? type.color
                    : AppColors.getBorder(isDark),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(type.icon,
                    size: 18,
                    color: isSelected
                        ? type.color
                        : AppColors.getTextSecondary(isDark)),
                const SizedBox(width: AlhaiSpacing.xs),
                Text(type.label,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? type.color
                            : AppColors.getTextSecondary(isDark))),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGroupBySelector(bool isDark, AppLocalizations l10n) {
    final options = [
      ('day', l10n.daily, Icons.today_rounded),
      ('week', l10n.weekly, Icons.view_week_rounded),
      ('month', l10n.monthly, Icons.calendar_month_rounded),
    ];

    return Row(
      children: options.map((option) {
        final isSelected = _groupBy == option.$1;
        return Expanded(
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              end: option.$1 != 'month' ? 8 : 0,
            ),
            child: InkWell(
              onTap: () => setState(() => _groupBy = option.$1),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.sm),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.getSurfaceVariant(isDark),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.getBorder(isDark),
                  ),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(option.$3,
                        size: 16,
                        color: isSelected
                            ? Colors.white
                            : AppColors.getTextSecondary(isDark)),
                    const SizedBox(width: 6),
                    Text(option.$2,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : AppColors.getTextSecondary(isDark))),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateRangeCard(
      bool isDark, AppLocalizations l10n, bool isMediumScreen) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.date_range_rounded,
                    color: AppColors.info, size: 20),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text('Date Range',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.getTextPrimary(isDark))),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.mdl),
          // Quick date selectors
          _buildQuickDateChips(isDark, l10n),
          const SizedBox(height: AlhaiSpacing.md),
          // Selected range display
          InkWell(
            onTap: _pickDateRange,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(AlhaiSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.getSurfaceVariant(isDark),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.getBorder(isDark)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('From',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.getTextMuted(isDark))),
                        const SizedBox(height: AlhaiSpacing.xxs),
                        Text(
                          _dateRange != null
                              ? _formatDate(_dateRange!.start)
                              : '--/--/----',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.getTextPrimary(isDark)),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_rounded,
                      size: 18,
                      color: AppColors.getTextMuted(isDark)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('To',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.getTextMuted(isDark))),
                        const SizedBox(height: AlhaiSpacing.xxs),
                        Text(
                          _dateRange != null
                              ? _formatDate(_dateRange!.end)
                              : '--/--/----',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.getTextPrimary(isDark)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_dateRange != null) ...[
            const SizedBox(height: 10),
            Center(
              child: Text(
                '${_dateRange!.duration.inDays + 1} ${l10n.days}',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.getTextMuted(isDark)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickDateChips(bool isDark, AppLocalizations l10n) {
    final now = DateTime.now();
    final chips = [
      (l10n.today, DateTimeRange(
        start: DateTime(now.year, now.month, now.day),
        end: now,
      )),
      (l10n.thisWeek, DateTimeRange(
        start: now.subtract(Duration(days: now.weekday - 1)),
        end: now,
      )),
      (l10n.thisMonthPeriod, DateTimeRange(
        start: DateTime(now.year, now.month, 1),
        end: now,
      )),
      ('Last Month', DateTimeRange(
        start: DateTime(now.year, now.month - 1, 1),
        end: DateTime(now.year, now.month, 0),
      )),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: chips.map((chip) {
          return Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: InkWell(
              onTap: () => setState(() => _dateRange = chip.$2),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: AlhaiSpacing.sm, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.getSurfaceVariant(isDark),
                  borderRadius: BorderRadius.circular(999),
                  border:
                      Border.all(color: AppColors.getBorder(isDark)),
                ),
                child: Text(chip.$1,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.getTextSecondary(isDark))),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );
    if (picked != null) {
      setState(() => _dateRange = picked);
    }
  }

  Widget _buildGenerateButton(bool isDark, AppLocalizations l10n) {
    return SizedBox(
      height:52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _generateReport,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.analytics_rounded, size: 20),
                  SizedBox(width: 10),
                  Text('Generate Report',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                ],
              ),
      ),
    );
  }

  Widget _buildResults(bool isWideScreen, bool isMediumScreen, bool isDark,
      AppLocalizations l10n) {
    if (_results.isEmpty) {
      return _buildEmptyState(isDark, l10n);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Summary cards
        if (isWideScreen)
          Row(
            children: [
              Expanded(
                  child: _buildSummaryCard(
                      l10n.total,
                      '${_totalValue.toStringAsFixed(0)} ${l10n.sar}',
                      Icons.monetization_on_rounded,
                      AppColors.primary,
                      isDark)),
              const SizedBox(width: AlhaiSpacing.md),
              Expanded(
                  child: _buildSummaryCard(
                      l10n.count,
                      '$_totalCount',
                      Icons.format_list_numbered_rounded,
                      AppColors.info,
                      isDark)),
              const SizedBox(width: AlhaiSpacing.md),
              Expanded(
                  child: _buildSummaryCard(
                      'Periods',
                      '${_results.length}',
                      Icons.calendar_view_day_rounded,
                      const Color(0xFF8B5CF6),
                      isDark)),
            ],
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = (constraints.maxWidth - 12) / 2;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: cardWidth,
                    child: _buildSummaryCard(
                        l10n.total,
                        '${_totalValue.toStringAsFixed(0)} ${l10n.sar}',
                        Icons.monetization_on_rounded,
                        AppColors.primary,
                        isDark),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _buildSummaryCard(
                        l10n.count,
                        '$_totalCount',
                        Icons.format_list_numbered_rounded,
                        AppColors.info,
                        isDark),
                  ),
                ],
              );
            },
          ),
        SizedBox(height: isMediumScreen ? AlhaiSpacing.lg : AlhaiSpacing.md),
        // Results table
        _buildResultsTable(isMediumScreen, isDark, l10n),
      ],
    );
  }

  Widget _buildSummaryCard(String label, String value, IconData icon,
      Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AlhaiSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.getTextMuted(isDark))),
                const SizedBox(height: AlhaiSpacing.xxxs),
                Text(value,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.getTextPrimary(isDark)),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsTable(
      bool isMediumScreen, bool isDark, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Table header
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: isMediumScreen ? 20 : 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.getSurfaceVariant(isDark),
            ),
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Text('Period',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.getTextSecondary(isDark)))),
                Expanded(
                    flex: 2,
                    child: Text(l10n.count,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.getTextSecondary(isDark)))),
                Expanded(
                    flex: 3,
                    child: Text('Value',
                        textAlign: TextAlign.end,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.getTextSecondary(isDark)))),
                if (isMediumScreen)
                  Expanded(
                      flex: 2,
                      child: Text(l10n.percentage,
                          textAlign: TextAlign.end,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color:
                                  AppColors.getTextSecondary(isDark)))),
              ],
            ),
          ),
          // Table rows
          ...List.generate(_results.length, (index) {
            final row = _results[index];
            final label = row['label'] as String? ?? '';
            final value = row['value'] as double? ?? 0;
            final count = row['count'] as int? ?? 0;
            final percentage = _totalValue > 0
                ? (value / _totalValue * 100).toStringAsFixed(1)
                : '0.0';
            final isEven = index % 2 == 0;

            return Container(
              padding: EdgeInsets.symmetric(
                  horizontal: isMediumScreen ? 20 : 16, vertical: 14),
              decoration: BoxDecoration(
                color: isEven
                    ? Colors.transparent
                    : AppColors.getSurfaceVariant(isDark)
                        .withValues(alpha: 0.4),
                border: Border(
                  bottom: index < _results.length - 1
                      ? BorderSide(
                          color: AppColors.getBorder(isDark)
                              .withValues(alpha: 0.5))
                      : BorderSide.none,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(label,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.getTextPrimary(isDark))),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('$count',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13,
                            color: AppColors.getTextSecondary(isDark))),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      '${value.toStringAsFixed(0)} ${l10n.sar}',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.getTextPrimary(isDark)),
                    ),
                  ),
                  if (isMediumScreen)
                    Expanded(
                      flex: 2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AlhaiSpacing.xs, vertical: AlhaiSpacing.xxxs),
                            decoration: BoxDecoration(
                              color: AppColors.primary
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text('$percentage%',
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary)),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          }),
          // Total row
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: isMediumScreen ? 20 : 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: isDark ? 0.1 : 0.05),
              border: Border(
                top: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.3)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Text(l10n.total,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.getTextPrimary(isDark)))),
                Expanded(
                    flex: 2,
                    child: Text('$_totalCount',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.getTextPrimary(isDark)))),
                Expanded(
                    flex: 3,
                    child: Text(
                      '${_totalValue.toStringAsFixed(0)} ${l10n.sar}',
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary),
                    )),
                if (isMediumScreen)
                  const Expanded(
                      flex: 2,
                      child: Text('100%',
                          textAlign: TextAlign.end,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AlhaiSpacing.xxxl),
        child: Column(
          children: [
            Icon(Icons.search_off_rounded,
                size: 64,
                color:
                    AppColors.getTextMuted(isDark).withValues(alpha: 0.4)),
            const SizedBox(height: AlhaiSpacing.md),
            Text(l10n.noData,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.getTextMuted(isDark))),
            const SizedBox(height: AlhaiSpacing.xs),
            Text('Try different filters',
                style: TextStyle(
                    fontSize: 13,
                    color: AppColors.getTextMuted(isDark))),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.day}/${date.month}/${date.year}';
}

class _GroupItem {
  final DateTime date;
  final double value;
  final int count;
  final String? label;

  _GroupItem({
    required this.date,
    required this.value,
    required this.count,
    this.label,
  });
}

class _ReportTypeOption {
  final String key;
  final String label;
  final IconData icon;
  final Color color;

  _ReportTypeOption({
    required this.key,
    required this.label,
    required this.icon,
    required this.color,
  });
}
