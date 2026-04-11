import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

/// شاشة قائمة التدفق النقدي
class CashFlowScreen extends ConsumerStatefulWidget {
  const CashFlowScreen({super.key});

  @override
  ConsumerState<CashFlowScreen> createState() => _CashFlowScreenState();
}

class _CashFlowScreenState extends ConsumerState<CashFlowScreen> {
  String _period = 'month';
  bool _isLoading = true;
  String? _error;

  // Operating
  double _salesReceipts = 0;
  double _expensesPaid = 0;
  double _taxesPaid = 0;

  // Investing
  double _purchasesPaid = 0;

  // Financing
  double _cashIn = 0;
  double _cashOut = 0;

  double get _operatingNet => _salesReceipts - _expensesPaid - _taxesPaid;
  double get _investingNet => -_purchasesPaid;
  double get _financingNet => _cashIn - _cashOut;
  double get _netCashFlow => _operatingNet + _investingNet + _financingNet;

  ({DateTime start, DateTime end}) _getDateRange() {
    final now = DateTime.now();
    switch (_period) {
      case 'week':
        final s = now.subtract(Duration(days: now.weekday - 1));
        return (start: DateTime(s.year, s.month, s.day), end: now);
      case 'month':
        return (start: DateTime(now.year, now.month, 1), end: now);
      case 'quarter':
        final qm = ((now.month - 1) ~/ 3) * 3 + 1;
        return (start: DateTime(now.year, qm, 1), end: now);
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
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final db = GetIt.I<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) {
        setState(() {
          _error = 'لم يتم تحديد المتجر';
          _isLoading = false;
        });
        return;
      }
      final dr = _getDateRange();

      // Cash from sales
      final salesResult = await db
          .customSelect(
            '''SELECT COALESCE(SUM(total), 0) as total
           FROM sales
           WHERE store_id = ? AND status = 'completed'
             AND created_at >= ? AND created_at < ?''',
            variables: [
              Variable.withString(storeId),
              Variable.withDateTime(dr.start),
              Variable.withDateTime(dr.end),
            ],
          )
          .getSingle();

      // Expenses paid
      final expResult = await db
          .customSelect(
            '''SELECT COALESCE(SUM(amount), 0) as total
           FROM expenses
           WHERE store_id = ? AND created_at >= ? AND created_at < ?''',
            variables: [
              Variable.withString(storeId),
              Variable.withDateTime(dr.start),
              Variable.withDateTime(dr.end),
            ],
          )
          .getSingle();

      // Taxes paid
      final taxResult = await db
          .customSelect(
            '''SELECT COALESCE(SUM(tax), 0) as total
           FROM sales
           WHERE store_id = ? AND status = 'completed'
             AND created_at >= ? AND created_at < ?''',
            variables: [
              Variable.withString(storeId),
              Variable.withDateTime(dr.start),
              Variable.withDateTime(dr.end),
            ],
          )
          .getSingle();

      // Purchases paid
      final purchResult = await db
          .customSelect(
            '''SELECT COALESCE(SUM(total), 0) as total
           FROM purchases
           WHERE store_id = ? AND created_at >= ? AND created_at < ?''',
            variables: [
              Variable.withString(storeId),
              Variable.withDateTime(dr.start),
              Variable.withDateTime(dr.end),
            ],
          )
          .getSingle();

      // Cash movements
      final cashMovResult = await db
          .customSelect(
            '''SELECT
             COALESCE(SUM(CASE WHEN type = 'cash_in' THEN amount ELSE 0 END), 0) as cash_in,
             COALESCE(SUM(CASE WHEN type = 'cash_out' THEN amount ELSE 0 END), 0) as cash_out
           FROM transactions
           WHERE store_id = ? AND created_at >= ? AND created_at < ?''',
            variables: [
              Variable.withString(storeId),
              Variable.withDateTime(dr.start),
              Variable.withDateTime(dr.end),
            ],
          )
          .getSingle();

      if (mounted) {
        setState(() {
          _salesReceipts = _toDouble(salesResult.data['total']);
          _expensesPaid = _toDouble(expResult.data['total']);
          _taxesPaid = _toDouble(taxResult.data['total']);
          _purchasesPaid = _toDouble(purchResult.data['total']);
          _cashIn = _toDouble(cashMovResult.data['cash_in']);
          _cashOut = _toDouble(cashMovResult.data['cash_out']);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  double _toDouble(dynamic v) {
    if (v is int) return v.toDouble();
    if (v is double) return v;
    return 0.0;
  }

  String _periodLabel() {
    switch (_period) {
      case 'week':
        return 'هذا الأسبوع';
      case 'month':
        return 'هذا الشهر';
      case 'quarter':
        return 'هذا الربع';
      case 'year':
        return 'هذه السنة';
      default:
        return 'هذا الشهر';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('قائمة التدفق النقدي')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('قائمة التدفق النقدي')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: AlhaiColors.error),
              const SizedBox(height: AlhaiSpacing.sm),
              Text(_error!),
              const SizedBox(height: AlhaiSpacing.sm),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('قائمة التدفق النقدي'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) {
              setState(() => _period = v);
              _loadData();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'week', child: Text('هذا الأسبوع')),
              const PopupMenuItem(value: 'month', child: Text('هذا الشهر')),
              const PopupMenuItem(value: 'quarter', child: Text('ربع سنوي')),
              const PopupMenuItem(value: 'year', child: Text('سنوي')),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.md),
              child: Row(
                children: [
                  Text(_periodLabel()),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: ListView(
            padding: const EdgeInsets.all(AlhaiSpacing.md),
            children: [
              // Net cash flow card
              _NetCard(
                label: 'صافي التدفق النقدي',
                amount: _netCashFlow,
                isPositive: _netCashFlow >= 0,
              ),
              const SizedBox(height: AlhaiSpacing.mdl),

              // Operating activities
              _ActivitySection(
                title: 'الأنشطة التشغيلية',
                icon: Icons.storefront_rounded,
                color: AlhaiColors.info,
                netAmount: _operatingNet,
                isDark: isDark,
                rows: [
                  _FlowRow(
                    label: 'إيرادات المبيعات',
                    amount: _salesReceipts,
                    isInflow: true,
                  ),
                  _FlowRow(
                    label: 'المصروفات المدفوعة',
                    amount: -_expensesPaid,
                    isInflow: false,
                  ),
                  _FlowRow(
                    label: 'الضرائب المدفوعة (ضريبة القيمة المضافة)',
                    amount: -_taxesPaid,
                    isInflow: false,
                  ),
                ],
              ),
              const SizedBox(height: AlhaiSpacing.md),

              // Investing activities
              _ActivitySection(
                title: 'الأنشطة الاستثمارية',
                icon: Icons.trending_up_rounded,
                color: Colors.orange,
                netAmount: _investingNet,
                isDark: isDark,
                rows: [
                  _FlowRow(
                    label: 'مدفوعات المشتريات',
                    amount: -_purchasesPaid,
                    isInflow: false,
                  ),
                ],
              ),
              const SizedBox(height: AlhaiSpacing.md),

              // Financing activities
              _ActivitySection(
                title: 'الأنشطة التمويلية',
                icon: Icons.account_balance_rounded,
                color: AlhaiColors.success,
                netAmount: _financingNet,
                isDark: isDark,
                rows: [
                  _FlowRow(
                    label: 'إيداع نقدي',
                    amount: _cashIn,
                    isInflow: true,
                  ),
                  _FlowRow(
                    label: 'سحب نقدي',
                    amount: -_cashOut,
                    isInflow: false,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NetCard extends StatelessWidget {
  final String label;
  final double amount;
  final bool isPositive;

  const _NetCard({
    required this.label,
    required this.amount,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    final color = isPositive ? AlhaiColors.successDark : AlhaiColors.errorDark;
    final bg = isPositive
        ? AlhaiColors.success.withValues(alpha: 0.1)
        : AlhaiColors.error.withValues(alpha: 0.1);
    return Card(
      color: bg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AlhaiSpacing.mdl),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AlhaiSpacing.xs),
            Text(
              '${isPositive ? '+' : ''}${amount.toStringAsFixed(0)} ر.س',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Icon(
              isPositive
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              color: color,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivitySection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final double netAmount;
  final bool isDark;
  final List<_FlowRow> rows;

  const _ActivitySection({
    required this.title,
    required this.icon,
    required this.color,
    required this.netAmount,
    required this.isDark,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AlhaiSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: AlhaiSpacing.xs),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${netAmount >= 0 ? '+' : ''}${netAmount.toStringAsFixed(0)} ر.س',
                    style: TextStyle(
                      color: netAmount >= 0 ? color : AlhaiColors.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            ...rows.map(
              (row) => Padding(
                padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xxs),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          row.isInflow
                              ? Icons.add_circle_outline
                              : Icons.remove_circle_outline,
                          size: 14,
                          color: row.isInflow
                              ? AlhaiColors.success
                              : AlhaiColors.error,
                        ),
                        const SizedBox(width: 6),
                        Text(row.label, style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                    Text(
                      '${row.amount >= 0 ? '+' : ''}${row.amount.toStringAsFixed(0)} ر.س',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: row.amount >= 0
                            ? AlhaiColors.successDark
                            : AlhaiColors.errorDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlowRow {
  final String label;
  final double amount;
  final bool isInflow;
  const _FlowRow({
    required this.label,
    required this.amount,
    required this.isInflow,
  });
}
