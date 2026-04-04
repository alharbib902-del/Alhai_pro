import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_design_system/alhai_design_system.dart' show AlhaiSpacing;

/// شاشة تقرير المقارنة بين الفترات
class ComparisonReportScreen extends ConsumerStatefulWidget {
  const ComparisonReportScreen({super.key});

  @override
  ConsumerState<ComparisonReportScreen> createState() =>
      _ComparisonReportScreenState();
}

class _ComparisonReportScreenState
    extends ConsumerState<ComparisonReportScreen> {
  String _compareMode = 'month'; // month, quarter, year
  bool _isLoading = true;
  String? _error;

  _PeriodData? _current;
  _PeriodData? _previous;

  ({DateTime start, DateTime end}) _getCurrent() {
    final now = DateTime.now();
    switch (_compareMode) {
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

  ({DateTime start, DateTime end}) _getPrevious() {
    final now = DateTime.now();
    switch (_compareMode) {
      case 'month':
        final prevMonth = now.month == 1 ? 12 : now.month - 1;
        final prevYear = now.month == 1 ? now.year - 1 : now.year;
        return (
          start: DateTime(prevYear, prevMonth, 1),
          end: DateTime(now.year, now.month, 1),
        );
      case 'quarter':
        final currentQStart = ((now.month - 1) ~/ 3) * 3 + 1;
        final prevQStart = currentQStart <= 3 ? 10 : currentQStart - 3;
        final prevYear = currentQStart <= 3 ? now.year - 1 : now.year;
        return (
          start: DateTime(prevYear, prevQStart, 1),
          end: DateTime(now.year, currentQStart, 1),
        );
      case 'year':
        return (
          start: DateTime(now.year - 1, 1, 1),
          end: DateTime(now.year, 1, 1),
        );
      default:
        final prevMonth = now.month == 1 ? 12 : now.month - 1;
        final prevYear = now.month == 1 ? now.year - 1 : now.year;
        return (
          start: DateTime(prevYear, prevMonth, 1),
          end: DateTime(now.year, now.month, 1),
        );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<_PeriodData> _fetchPeriod(
      AppDatabase db, String storeId, DateTime start, DateTime end) async {
    final salesResult = await db.customSelect(
      '''SELECT
           COUNT(*) as cnt,
           COALESCE(SUM(total), 0) as revenue,
           COALESCE(SUM(tax), 0) as tax
         FROM sales
         WHERE store_id = ? AND status = 'completed'
           AND created_at >= ? AND created_at < ?''',
      variables: [
        Variable.withString(storeId),
        Variable.withDateTime(start),
        Variable.withDateTime(end),
      ],
    ).getSingle();

    final purchResult = await db.customSelect(
      '''SELECT COALESCE(SUM(total), 0) as total
         FROM purchases WHERE store_id = ? AND created_at >= ? AND created_at < ?''',
      variables: [
        Variable.withString(storeId),
        Variable.withDateTime(start),
        Variable.withDateTime(end),
      ],
    ).getSingle();

    final expResult = await db.customSelect(
      '''SELECT COALESCE(SUM(amount), 0) as total
         FROM expenses WHERE store_id = ? AND created_at >= ? AND created_at < ?''',
      variables: [
        Variable.withString(storeId),
        Variable.withDateTime(start),
        Variable.withDateTime(end),
      ],
    ).getSingle();

    final revenue = _toDouble(salesResult.data['revenue']);
    final purchases = _toDouble(purchResult.data['total']);
    final expenses = _toDouble(expResult.data['total']);
    final tax = _toDouble(salesResult.data['tax']);
    final invoices = (salesResult.data['cnt'] as int?) ?? 0;
    final profit = revenue - purchases - expenses - tax;

    return _PeriodData(
      revenue: revenue,
      purchases: purchases,
      expenses: expenses,
      tax: tax,
      profit: profit,
      invoices: invoices,
    );
  }

  static double _toDouble(dynamic v) {
    if (v is int) return v.toDouble();
    if (v is double) return v;
    return 0.0;
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
      final cur = _getCurrent();
      final prev = _getPrevious();
      final curData = await _fetchPeriod(db, storeId, cur.start, cur.end);
      final prevData = await _fetchPeriod(db, storeId, prev.start, prev.end);
      if (mounted) {
        setState(() {
          _current = curData;
          _previous = prevData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted)
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
    }
  }

  String _currentLabel() {
    switch (_compareMode) {
      case 'month':
        return 'هذا الشهر';
      case 'quarter':
        return 'هذا الربع';
      case 'year':
        return 'هذه السنة';
      default:
        return 'الفترة الحالية';
    }
  }

  String _previousLabel() {
    switch (_compareMode) {
      case 'month':
        return 'الشهر الماضي';
      case 'quarter':
        return 'الربع الماضي';
      case 'year':
        return 'السنة الماضية';
      default:
        return 'الفترة السابقة';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('تقرير المقارنة')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null || _current == null || _previous == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('تقرير المقارنة')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: AlhaiSpacing.sm),
              Text(_error ?? 'خطأ في تحميل البيانات'),
              TextButton(
                  onPressed: _loadData, child: const Text('إعادة المحاولة')),
            ],
          ),
        ),
      );
    }

    final cur = _current!;
    final prev = _previous!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تقرير المقارنة'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'month', label: Text('شهري')),
                ButtonSegment(value: 'quarter', label: Text('ربعي')),
                ButtonSegment(value: 'year', label: Text('سنوي')),
              ],
              selected: {_compareMode},
              onSelectionChanged: (s) {
                setState(() => _compareMode = s.first);
                _loadData();
              },
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(AlhaiSpacing.md),
          children: [
            // Header labels
            Row(
              children: [
                Expanded(
                    flex: 2,
                    child: Text('المؤشر',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant))),
                Expanded(
                  child: Text(_currentLabel(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.blue)),
                ),
                Expanded(
                  child: Text(_previousLabel(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant)),
                ),
                Expanded(
                  child: Text('التغيير',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant)),
                ),
              ],
            ),
            const Divider(height: 20, thickness: 2),

            _CompRow(
              label: 'المبيعات',
              current: cur.revenue,
              previous: prev.revenue,
              higherIsBetter: true,
            ),
            _CompRow(
              label: 'عدد الفواتير',
              current: cur.invoices.toDouble(),
              previous: prev.invoices.toDouble(),
              higherIsBetter: true,
              isCount: true,
            ),
            _CompRow(
              label: 'المشتريات',
              current: cur.purchases,
              previous: prev.purchases,
              higherIsBetter: false,
            ),
            _CompRow(
              label: 'المصروفات',
              current: cur.expenses,
              previous: prev.expenses,
              higherIsBetter: false,
            ),
            _CompRow(
              label: 'الضريبة',
              current: cur.tax,
              previous: prev.tax,
              higherIsBetter: false,
            ),
            const Divider(),
            _CompRow(
              label: 'صافي الربح',
              current: cur.profit,
              previous: prev.profit,
              higherIsBetter: true,
              bold: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _CompRow extends StatelessWidget {
  final String label;
  final double current;
  final double previous;
  final bool higherIsBetter;
  final bool isCount;
  final bool bold;

  const _CompRow({
    required this.label,
    required this.current,
    required this.previous,
    required this.higherIsBetter,
    this.isCount = false,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final change = previous != 0
        ? ((current - previous) / previous) * 100
        : (current != 0 ? 100.0 : 0.0);
    final isPositive = higherIsBetter ? change >= 0 : change <= 0;
    final changeColor =
        isPositive ? Colors.green.shade700 : Colors.red.shade700;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xs),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                fontSize: bold ? 14 : 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              isCount
                  ? current.toStringAsFixed(0)
                  : '${current.toStringAsFixed(0)} ر.س',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.w500,
                fontSize: bold ? 14 : 13,
                color: Colors.blue.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              isCount
                  ? previous.toStringAsFixed(0)
                  : '${previous.toStringAsFixed(0)} ر.س',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  change >= 0
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  size: 14,
                  color: changeColor,
                ),
                Text(
                  '${change.abs().toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: changeColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodData {
  final double revenue;
  final double purchases;
  final double expenses;
  final double tax;
  final double profit;
  final int invoices;

  const _PeriodData({
    required this.revenue,
    required this.purchases,
    required this.expenses,
    required this.tax,
    required this.profit,
    required this.invoices,
  });
}
