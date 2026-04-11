import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

/// شاشة عمولات وأهداف الموظفين
class CommissionScreen extends ConsumerStatefulWidget {
  const CommissionScreen({super.key});

  @override
  ConsumerState<CommissionScreen> createState() => _CommissionScreenState();
}

class _CommissionScreenState extends ConsumerState<CommissionScreen> {
  String _period = 'month';
  bool _isLoading = true;
  List<_EmployeeCommission> _employees = [];

  ({DateTime start, DateTime end}) _getDateRange() {
    final now = DateTime.now();
    switch (_period) {
      case 'week':
        final s = now.subtract(Duration(days: now.weekday - 1));
        return (start: DateTime(s.year, s.month, s.day), end: now);
      case 'month':
        return (start: DateTime(now.year, now.month, 1), end: now);
      case 'year':
        return (start: DateTime(now.year, 1, 1), end: now);
      default:
        return (start: DateTime(now.year, now.month, 1), end: now);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final db = GetIt.I<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
      final dr = _getDateRange();

      // Get sales per cashier (using opened_by from shifts or cashier_id from sales)
      final result = await db
          .customSelect(
            '''SELECT
             u.id,
             COALESCE(u.name, u.phone) as emp_name,
             COUNT(DISTINCT s.id) as sale_count,
             COALESCE(SUM(s.total), 0) as total_sales
           FROM sales s
           JOIN users u ON u.id = s.cashier_id
           WHERE s.store_id = ?
             AND s.status = 'completed'
             AND s.created_at >= ?
             AND s.created_at < ?
           GROUP BY u.id
           ORDER BY total_sales DESC''',
            variables: [
              Variable.withString(storeId),
              Variable.withDateTime(dr.start),
              Variable.withDateTime(dr.end),
            ],
          )
          .get();

      if (mounted) {
        setState(() {
          _employees = result.map((row) {
            final sales = _toDouble(row.data['total_sales']);
            // 2% commission rate (configurable in future)
            const commissionRate = 0.02;
            const targetSales = 50000.0; // monthly target
            return _EmployeeCommission(
              id: row.data['id'] as String,
              name: row.data['emp_name'] as String,
              saleCount: (row.data['sale_count'] as int?) ?? 0,
              totalSales: sales,
              commission: sales * commissionRate,
              target: targetSales,
              commissionRate: commissionRate,
            );
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  double _toDouble(dynamic v) {
    if (v is int) return v.toDouble();
    if (v is double) return v;
    return 0.0;
  }

  String _periodLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (_period) {
      case 'week':
        return l10n.thisWeek;
      case 'month':
        return l10n.thisMonth;
      case 'year':
        return l10n.thisYear;
      default:
        return l10n.thisMonth;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final totalCommissions = _employees.fold(
      0.0,
      (sum, e) => sum + e.commission,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.employeeCommissions),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) {
              setState(() => _period = v);
              _loadData();
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'week', child: Text(l10n.thisWeek)),
              PopupMenuItem(value: 'month', child: Text(l10n.thisMonth)),
              PopupMenuItem(value: 'year', child: Text(l10n.thisYear)),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.md),
              child: Row(
                children: [
                  Text(_periodLabel(context)),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Total commissions banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AlhaiSpacing.md),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          l10n.totalDueCommissions,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimary.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: AlhaiSpacing.xxs),
                        Text(
                          l10n.amountSar(totalCommissions.toStringAsFixed(2)),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          l10n.forEmployees(_employees.length),
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimary.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: _employees.isEmpty
                        ? AppEmptyState.noData(
                            context,
                            title: l10n.noCommissions,
                            description: l10n.noSalesInPeriod,
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(AlhaiSpacing.sm),
                            itemCount: _employees.length,
                            itemBuilder: (ctx, i) {
                              final emp = _employees[i];
                              final achievedPct = emp.target > 0
                                  ? (emp.totalSales / emp.target).clamp(
                                      0.0,
                                      1.0,
                                    )
                                  : 0.0;
                              return Card(
                                margin: const EdgeInsets.only(
                                  bottom: AlhaiSpacing.xs,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(
                                    AlhaiSpacing.md,
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 22,
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withValues(alpha: 0.1),
                                            child: Text(
                                              emp.name.isNotEmpty
                                                  ? emp.name[0]
                                                  : '?',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: AlhaiSpacing.sm,
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  emp.name,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  l10n.invoicesSales(
                                                    emp.saleCount,
                                                    emp.totalSales
                                                        .toStringAsFixed(0),
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Theme.of(
                                                      context,
                                                    ).hintColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.all(
                                              AlhaiSpacing.xs,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.success
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Column(
                                              children: [
                                                Text(
                                                  l10n.commissionLabel,
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: Theme.of(
                                                      context,
                                                    ).hintColor,
                                                  ),
                                                ),
                                                Text(
                                                  l10n.amountSar(
                                                    emp.commission
                                                        .toStringAsFixed(0),
                                                  ),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.success,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      // Target progress
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            l10n.targetLabel(
                                              emp.target.toStringAsFixed(0),
                                            ),
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Theme.of(
                                                context,
                                              ).hintColor,
                                            ),
                                          ),
                                          Text(
                                            l10n.achievedPercent(
                                              (achievedPct * 100)
                                                  .toStringAsFixed(0),
                                            ),
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: achievedPct >= 1
                                                  ? AppColors.success
                                                  : AppColors.warning,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: AlhaiSpacing.xxs),
                                      LinearProgressIndicator(
                                        value: achievedPct,
                                        backgroundColor: Theme.of(
                                          context,
                                        ).colorScheme.surfaceContainerLow,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              achievedPct >= 1
                                                  ? AppColors.success
                                                  : AppColors.warning,
                                            ),
                                        minHeight: 6,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      const SizedBox(height: AlhaiSpacing.xxs),
                                      Text(
                                        l10n.commissionRate(
                                          (emp.commissionRate * 100)
                                              .toStringAsFixed(0),
                                        ),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Theme.of(context).hintColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _EmployeeCommission {
  final String id;
  final String name;
  final int saleCount;
  final double totalSales;
  final double commission;
  final double target;
  final double commissionRate;

  const _EmployeeCommission({
    required this.id,
    required this.name,
    required this.saleCount,
    required this.totalSales,
    required this.commission,
    required this.target,
    required this.commissionRate,
  });
}
