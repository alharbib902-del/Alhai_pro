import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';

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
      final result = await db.customSelect(
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
      ).get();

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

  String _periodLabel() {
    switch (_period) {
      case 'week': return 'هذا الأسبوع';
      case 'month': return 'هذا الشهر';
      case 'year': return 'هذه السنة';
      default: return 'هذا الشهر';
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalCommissions = _employees.fold(0.0, (sum, e) => sum + e.commission);

    return Scaffold(
      appBar: AppBar(
        title: const Text('عمولات الموظفين'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) { setState(() => _period = v); _loadData(); },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'week', child: Text('هذا الأسبوع')),
              const PopupMenuItem(value: 'month', child: Text('هذا الشهر')),
              const PopupMenuItem(value: 'year', child: Text('هذه السنة')),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [
                Text(_periodLabel()),
                const Icon(Icons.arrow_drop_down),
              ]),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Total commissions banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1A8FE3), Color(0xFF0EC9C9)],
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text('إجمالي العمولات المستحقة',
                          style: TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(
                        '${totalCommissions.toStringAsFixed(2)} ر.س',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'لـ ${_employees.length} موظف',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: _employees.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.people_outline, size: 64, color: Theme.of(context).hintColor),
                              SizedBox(height: 12),
                              Text('لا توجد مبيعات في هذه الفترة',
                                  style: TextStyle(color: Theme.of(context).hintColor)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _employees.length,
                          itemBuilder: (ctx, i) {
                            final emp = _employees[i];
                            final achievedPct =
                                emp.target > 0 ? (emp.totalSales / emp.target).clamp(0.0, 1.0) : 0.0;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 22,
                                          backgroundColor: Colors.blue.withValues(alpha: 0.1),
                                          child: Text(
                                            emp.name.isNotEmpty ? emp.name[0] : '?',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(emp.name,
                                                  style: const TextStyle(
                                                      fontWeight: FontWeight.bold)),
                                              Text(
                                                '${emp.saleCount} فاتورة - مبيعات: ${emp.totalSales.toStringAsFixed(0)} ر.س',
                                                style: TextStyle(
                                                    fontSize: 12, color: Theme.of(context).hintColor),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.green.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Column(
                                            children: [
                                              Text('عمولة',
                                                  style: TextStyle(
                                                      fontSize: 10, color: Theme.of(context).hintColor)),
                                              Text(
                                                '${emp.commission.toStringAsFixed(0)} ر.س',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green,
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
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'الهدف: ${emp.target.toStringAsFixed(0)} ر.س',
                                          style: TextStyle(fontSize: 11, color: Theme.of(context).hintColor),
                                        ),
                                        Text(
                                          '${(achievedPct * 100).toStringAsFixed(0)}% مُحقق',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: achievedPct >= 1 ? Colors.green : Colors.orange,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    LinearProgressIndicator(
                                      value: achievedPct,
                                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        achievedPct >= 1 ? Colors.green : Colors.orange,
                                      ),
                                      minHeight: 6,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'نسبة العمولة: ${(emp.commissionRate * 100).toStringAsFixed(0)}%',
                                      style: TextStyle(fontSize: 10, color: Theme.of(context).hintColor),
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
